#!/bin/bash

# Jobtread API Client Helper Functions
# Source this script to use helper functions for interacting with Jobtread API
#
# Example usage:
#   source ./helpers/jobtread-client.sh
#   jobtread_list_projects "in_progress"
#   jobtread_create_job "proj-001" "New Job" 50000 "2026-05-01" "2026-05-30"

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# Core API Request Function
# ============================================================================

jobtread_request() {
  local method="${1:-GET}"
  local endpoint="${2:?Endpoint required}"
  local data="${3:-}"

  # Validate environment variables
  if [[ -z "${JOBTREAD_API_KEY:-}" ]]; then
    echo -e "${RED}ERROR: JOBTREAD_API_KEY not set${NC}" >&2
    return 1
  fi

  if [[ -z "${JOBTREAD_API_URL:-}" ]]; then
    echo -e "${RED}ERROR: JOBTREAD_API_URL not set${NC}" >&2
    return 1
  fi

  # Build curl command
  local curl_cmd=("curl" "-sS" "-X" "$method")

  # Add URL
  curl_cmd+=("${JOBTREAD_API_URL}${endpoint}")

  # Add authentication header
  curl_cmd+=("-H" "Authorization: Bearer ${JOBTREAD_API_KEY}")

  # Add content type header for POST/PATCH
  if [[ "$method" == "POST" ]] || [[ "$method" == "PATCH" ]]; then
    curl_cmd+=("-H" "Content-Type: application/json")
  fi

  # Add Paperclip run ID if available (for audit trail)
  if [[ -n "${PAPERCLIP_RUN_ID:-}" ]]; then
    curl_cmd+=("-H" "X-Paperclip-Run-Id: ${PAPERCLIP_RUN_ID}")
  fi

  # Add request body if provided
  if [[ -n "$data" ]]; then
    curl_cmd+=("-d" "$data")
  fi

  # Execute request and return response
  "${curl_cmd[@]}"
}

# ============================================================================
# Helper: Check HTTP Status Code
# ============================================================================

jobtread_check_status() {
  local response="${1:?Response required}"
  local expected_code="${2:-200}"

  local http_code=$(echo "$response" | tail -n 1)
  local body=$(echo "$response" | head -n -1)

  if [[ "$http_code" != "$expected_code" ]]; then
    echo -e "${RED}ERROR: HTTP $http_code${NC}" >&2
    echo "$body" | jq . >&2 2>/dev/null || echo "$body" >&2
    return 1
  fi

  echo "$body"
  return 0
}

# ============================================================================
# Company Operations
# ============================================================================

jobtread_get_company() {
  local company_id="${JOBTREAD_COMPANY_ID:?JOBTREAD_COMPANY_ID not set}"

  jobtread_request "GET" "/companies/$company_id"
}

# ============================================================================
# Project Operations
# ============================================================================

jobtread_list_projects() {
  local status="${1:-}"
  local limit="${2:-50}"
  local endpoint="/companies/${JOBTREAD_COMPANY_ID:?JOBTREAD_COMPANY_ID not set}/projects"

  # Add status filter if provided
  if [[ -n "$status" ]]; then
    endpoint="${endpoint}?status=${status}&limit=${limit}"
  else
    endpoint="${endpoint}?limit=${limit}"
  fi

  jobtread_request "GET" "$endpoint"
}

jobtread_get_project() {
  local project_id="${1:?Project ID required}"

  jobtread_request "GET" "/projects/$project_id"
}

jobtread_get_projects_by_client() {
  local client_id="${1:?Client ID required}"

  jobtread_list_projects "" | jq ".[] | select(.client_id == \"$client_id\")"
}

# ============================================================================
# Job Operations
# ============================================================================

jobtread_get_jobs() {
  local project_id="${1:?Project ID required}"

  jobtread_request "GET" "/projects/$project_id/jobs"
}

jobtread_get_job() {
  local job_id="${1:?Job ID required}"

  jobtread_request "GET" "/jobs/$job_id"
}

jobtread_create_job() {
  local project_id="${1:?Project ID required}"
  local name="${2:?Job name required}"
  local budget="${3:?Budget required}"
  local start_date="${4:?Start date required}"
  local end_date="${5:?End date required}"
  local description="${6:-}"
  local phase="${7:-}"
  local crew="${8:-}"

  # Build JSON payload
  local data=$(cat <<EOF
{
  "project_id": "$project_id",
  "name": "$name",
  "budget_amount": $budget,
  "scheduled_start": "$start_date",
  "scheduled_end": "$end_date"
EOF
)

  # Add optional fields if provided
  if [[ -n "$description" ]]; then
    data="${data},\"description\": \"$description\""
  fi

  if [[ -n "$phase" ]]; then
    data="${data},\"phase\": \"$phase\""
  fi

  if [[ -n "$crew" ]]; then
    data="${data},\"assigned_crew\": \"$crew\""
  fi

  data="${data}}"

  jobtread_request "POST" "/jobs" "$data"
}

jobtread_update_job() {
  local job_id="${1:?Job ID required}"
  local status="${2:-}"
  local actual_cost="${3:-}"
  local completed_date="${4:-}"

  local data="{"

  # Add fields if provided
  local first=true
  if [[ -n "$status" ]]; then
    data="${data}\"status\": \"$status\""
    first=false
  fi

  if [[ -n "$actual_cost" ]]; then
    if ! $first; then data="${data},"; fi
    data="${data}\"actual_cost\": $actual_cost"
    first=false
  fi

  if [[ -n "$completed_date" ]]; then
    if ! $first; then data="${data},"; fi
    data="${data}\"completed_date\": \"$completed_date\""
  fi

  data="${data}}"

  jobtread_request "PATCH" "/jobs/$job_id" "$data"
}

jobtread_complete_job() {
  local job_id="${1:?Job ID required}"
  local actual_cost="${2:-0}"

  local completed_date=$(date -u +%Y-%m-%d)

  jobtread_update_job "$job_id" "completed" "$actual_cost" "$completed_date"
}

jobtread_get_jobs_by_status() {
  local project_id="${1:?Project ID required}"
  local status="${2:?Status required}"

  jobtread_get_jobs "$project_id" | jq ".[] | select(.status == \"$status\")"
}

# ============================================================================
# Task Operations
# ============================================================================

jobtread_get_tasks() {
  local job_id="${1:?Job ID required}"

  jobtread_request "GET" "/jobs/$job_id/tasks"
}

jobtread_get_task() {
  local task_id="${1:?Task ID required}"

  jobtread_request "GET" "/tasks/$task_id"
}

jobtread_create_task() {
  local job_id="${1:?Job ID required}"
  local name="${2:?Task name required}"
  local due_date="${3:?Due date required}"
  local assigned_to="${4:-}"
  local priority="${5:-medium}"
  local estimated_hours="${6:-}"

  local data=$(cat <<EOF
{
  "job_id": "$job_id",
  "name": "$name",
  "due_date": "$due_date",
  "priority": "$priority"
EOF
)

  # Add optional fields
  if [[ -n "$assigned_to" ]]; then
    data="${data},\"assigned_to\": \"$assigned_to\""
  fi

  if [[ -n "$estimated_hours" ]]; then
    data="${data},\"estimated_hours\": $estimated_hours"
  fi

  data="${data}}"

  jobtread_request "POST" "/tasks" "$data"
}

jobtread_update_task() {
  local task_id="${1:?Task ID required}"
  local status="${2:-}"
  local progress="${3:-}"
  local actual_hours="${4:-}"
  local notes="${5:-}"

  local data="{"

  # Add fields if provided
  local first=true
  if [[ -n "$status" ]]; then
    data="${data}\"status\": \"$status\""
    first=false
  fi

  if [[ -n "$progress" ]]; then
    if ! $first; then data="${data},"; fi
    data="${data}\"progress_percent\": $progress"
    first=false
  fi

  if [[ -n "$actual_hours" ]]; then
    if ! $first; then data="${data},"; fi
    data="${data}\"actual_hours\": $actual_hours"
    first=false
  fi

  if [[ -n "$notes" ]]; then
    if ! $first; then data="${data},"; fi
    # Escape quotes in notes
    notes=$(echo "$notes" | sed 's/"/\\"/g')
    data="${data}\"notes\": \"$notes\""
  fi

  data="${data}}"

  jobtread_request "PATCH" "/tasks/$task_id" "$data"
}

jobtread_complete_task() {
  local task_id="${1:?Task ID required}"
  local actual_hours="${2:-0}"

  jobtread_update_task "$task_id" "completed" "100" "$actual_hours"
}

jobtread_get_overdue_tasks() {
  local project_id="${1:?Project ID required}"

  local today=$(date -u +%Y-%m-%d)

  jobtread_get_jobs "$project_id" | jq -r '.[] | .id' | while read job_id; do
    jobtread_get_tasks "$job_id" | jq ".[] | select(.due_date < \"$today\" and .status != \"completed\")"
  done
}

jobtread_get_tasks_by_status() {
  local job_id="${1:?Job ID required}"
  local status="${2:?Status required}"

  jobtread_get_tasks "$job_id" | jq ".[] | select(.status == \"$status\")"
}

# ============================================================================
# Reporting Functions
# ============================================================================

jobtread_project_budget_summary() {
  local project_id="${1:?Project ID required}"

  local project=$(jobtread_get_project "$project_id")
  local budget=$(echo "$project" | jq '.budget')
  local actual=$(echo "$project" | jq '.actual_cost')
  local variance=$((actual - budget))

  echo "Budget Summary for: $(echo "$project" | jq -r '.name')"
  echo "  Budget:   \$$budget"
  echo "  Actual:   \$$actual"
  echo "  Variance: \$$variance"

  if (( variance < 0 )); then
    echo "  Status:   ${GREEN}UNDER BUDGET${NC}"
  elif (( variance > 0 )); then
    echo "  Status:   ${RED}OVER BUDGET${NC}"
  else
    echo "  Status:   ${GREEN}ON BUDGET${NC}"
  fi
}

jobtread_project_completion() {
  local project_id="${1:?Project ID required}"

  local project=$(jobtread_get_project "$project_id")
  local completion=$(echo "$project" | jq '.completion_percent')
  local job_count=$(echo "$project" | jq '.job_count')
  local jobs=$(jobtread_get_jobs "$project_id")
  local completed=$(echo "$jobs" | jq "[.[] | select(.status == \"completed\")] | length")

  echo "Project Progress: $(echo "$project" | jq -r '.name')"
  echo "  Overall:   ${completion}% complete"
  echo "  Jobs:      $completed/$job_count completed"

  # Show upcoming jobs
  echo "  Upcoming Jobs:"
  echo "$jobs" | jq -r '.[] | select(.status != "completed") | "    - \(.name) (\(.status))"'
}

jobtread_all_projects_summary() {
  local status="${1:-in_progress}"

  echo "=== All $status Projects for Ideal Construction ==="
  echo ""

  local projects=$(jobtread_list_projects "$status")
  local count=$(echo "$projects" | jq 'length')

  echo "Total: $count projects"
  echo ""

  echo "$projects" | jq -r '.[] | "
\(.name)
  Status: \(.status)
  Budget: $\(.budget | tonumber | floor)
  Actual: $\(.actual_cost | tonumber | floor)
  Progress: \(.completion_percent)%
  Location: \(.address)
  Jobs: \(.job_count)
  ---"'
}

# ============================================================================
# Utility Functions
# ============================================================================

jobtread_verify_connection() {
  echo "Verifying Jobtread connection..."
  echo "  API URL: $JOBTREAD_API_URL"
  echo "  Company ID: ${JOBTREAD_COMPANY_ID:0:8}..."
  echo ""

  if jobtread_get_company | jq -e '.name' > /dev/null 2>&1; then
    local company_name=$(jobtread_get_company | jq -r '.name')
    echo -e "${GREEN}✓ Connection successful!${NC}"
    echo "  Company: $company_name"
    return 0
  else
    echo -e "${RED}✗ Connection failed${NC}"
    return 1
  fi
}

jobtread_error_handler() {
  local http_code="${1:?HTTP code required}"
  local response="${2:?Response required}"

  case "$http_code" in
    400)
      echo -e "${RED}Bad Request (400)${NC}"
      echo "Check request format and required fields"
      ;;
    401)
      echo -e "${RED}Unauthorized (401)${NC}"
      echo "API key invalid or expired. Contact operator."
      ;;
    403)
      echo -e "${RED}Forbidden (403)${NC}"
      echo "API key lacks permission. Check scope and company ID."
      ;;
    404)
      echo -e "${RED}Not Found (404)${NC}"
      echo "Resource not found. Verify IDs are correct."
      ;;
    422)
      echo -e "${RED}Unprocessable Entity (422)${NC}"
      echo "Validation error. Check field types and formats."
      ;;
    429)
      echo -e "${YELLOW}Rate Limited (429)${NC}"
      echo "Too many requests. Wait 60 seconds and retry."
      ;;
    *)
      echo -e "${RED}Error: HTTP $http_code${NC}"
      ;;
  esac

  echo ""
  echo "Response:"
  echo "$response" | jq . 2>/dev/null || echo "$response"
}

# ============================================================================
# Export Functions
# ============================================================================

# Make all functions available to caller
export -f jobtread_request
export -f jobtread_check_status
export -f jobtread_get_company
export -f jobtread_list_projects
export -f jobtread_get_project
export -f jobtread_get_jobs
export -f jobtread_get_job
export -f jobtread_create_job
export -f jobtread_update_job
export -f jobtread_complete_job
export -f jobtread_get_tasks
export -f jobtread_get_task
export -f jobtread_create_task
export -f jobtread_update_task
export -f jobtread_complete_task
export -f jobtread_verify_connection
export -f jobtread_error_handler
export -f jobtread_project_budget_summary
export -f jobtread_project_completion
export -f jobtread_all_projects_summary
