---
name: jobtread-integration
description: >
  Interact with Jobtread construction management system to query projects,
  jobs, tasks, and financial data for Ideal Construction company. Use this
  skill to retrieve project information, update task statuses, create new
  jobs, and sync construction management data into Paperclip workflows.
---

# Jobtread Integration Skill

Connect Paperclip agents to Jobtread construction management system for Ideal Construction company.

## Overview

This skill enables agents to:
- Query construction projects and job status from Jobtread
- Retrieve task lists, crew assignments, and material schedules
- Create and update jobs in response to Paperclip approvals
- Sync financial data (budget vs. actual) for cost tracking
- Link construction work with automated Paperclip workflows

**When to use:** Use this skill whenever you need to read from or write to the Ideal Construction account in Jobtread.

## Authentication

Jobtread integration is configured at the company level. Agents automatically receive these environment variables:

**Required Environment Variables:**

- `JOBTREAD_API_KEY` - Bearer token for API authentication
  - Value: Provided during company setup (masked in logs)
  - Scope: Ideal Construction company only
  - Expires: Quarterly rotation recommended

- `JOBTREAD_COMPANY_ID` - UUID of Ideal Construction in Jobtread
  - Value: Provided during company setup
  - Used to filter all queries to this company
  - Never expires (fixed reference)

- `JOBTREAD_API_URL` - Base API endpoint
  - Value: `https://www.jobtread.com/api`
  - Fixed standard endpoint
  - Requires HTTPS for all requests

**Verification:** Confirm your connection on startup:

```bash
curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq .
```

Should return company object with name "Ideal Construction".

## Standard Request Pattern

All Jobtread API requests follow this pattern:

```bash
curl -X METHOD \
  "$JOBTREAD_API_URL/ENDPOINT" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  [-H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID"] \
  [-d '{json_payload}']
```

**Headers:**
- `Authorization: Bearer $JOBTREAD_API_KEY` - Required for all requests
- `Content-Type: application/json` - Required for POST/PATCH requests
- `X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID` - Recommended for audit trail

## Core Workflows

### Workflow 1: Get Company Status

Verify you have access and see summary data:

```bash
curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq .
```

Response includes:
- Company name, address, contact info
- Account status and subscription level
- API usage statistics

### Workflow 2: List All Projects

Get all projects for Ideal Construction (supports filtering):

```bash
# All projects
curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq .

# Specific status only (add query parameter)
curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq .
```

**Status filters:** prospect, estimate, in_progress, completed, archived, on_hold

Response array includes:
- `id` - Project UUID (use for detail queries)
- `name` - Project display name
- `address` - Project location
- `status` - Current workflow status
- `budget` - Total budget amount
- `scheduled_start` - Project start date (ISO 8601)
- `scheduled_end` - Project end date (ISO 8601)
- `client_id` - Client UUID
- `created_at`, `updated_at` - Timestamps

### Workflow 3: Get Project Detail with Jobs

Retrieve full project hierarchy including all jobs:

```bash
curl -sS "$JOBTREAD_API_URL/projects/$PROJECT_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq .
```

Response includes:
- Project metadata (same as Workflow 2)
- `jobs` array with all jobs in project
- Each job has: id, name, status, budget, phase, assigned_crew

### Workflow 4: Get Jobs in a Project

List all jobs for a specific project:

```bash
curl -sS "$JOBTREAD_API_URL/projects/$PROJECT_ID/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq '.[] | {id, name, status, budget}'
```

Response array of job objects with fields:
- `id` - Job UUID
- `name` - Job description
- `status` - pending, in_progress, on_hold, completed
- `budget` - Budgeted amount
- `actual_cost` - Current costs (if tracked)
- `scheduled_start`, `scheduled_end` - Dates
- `phase` - Excavation, Foundation, Framing, etc.

### Workflow 5: Get Tasks in a Job

List all tasks within a specific job:

```bash
curl -sS "$JOBTREAD_API_URL/jobs/$JOB_ID/tasks" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq '.[] | {id, name, status, assignee}'
```

Response array of task objects:
- `id` - Task UUID
- `name` - Task description
- `status` - not_started, in_progress, on_hold, completed
- `assignee` - Crew member or subcontractor name
- `progress_percent` - 0-100 completion
- `due_date` - When task should be done

### Workflow 6: Create a New Job

Create a job in response to Paperclip approval (e.g., new construction phase approved):

```bash
curl -X POST "$JOBTREAD_API_URL/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": "'$PROJECT_ID'",
    "name": "Electrical Rough-In",
    "description": "Run electrical conduit and rough-in all circuits per plan",
    "phase": "Rough In",
    "budget_amount": 45000,
    "scheduled_start": "2026-05-01",
    "scheduled_end": "2026-05-15",
    "assigned_crew": "Elite Electric LLC"
  }'
```

**Required fields:** project_id, name, scheduled_start, scheduled_end
**Optional fields:** description, phase, budget_amount, assigned_crew

Response: Created job object with assigned `id`

### Workflow 7: Update Job Status

Change job status (e.g., mark as completed when Paperclip task done):

```bash
curl -X PATCH "$JOBTREAD_API_URL/jobs/$JOB_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed",
    "actual_cost": 44850,
    "completed_date": "2026-05-14"
  }'
```

**Acceptable status values:** pending, in_progress, on_hold, completed

### Workflow 8: Update Task Status with Progress

Update task progress as work happens:

```bash
curl -X PATCH "$JOBTREAD_API_URL/tasks/$TASK_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in_progress",
    "progress_percent": 50,
    "notes": "On schedule. Materials arrived Tuesday."
  }'
```

**Status values:** not_started, in_progress, on_hold, completed
**Progress:** Integer 0-100 representing completion percentage

## Helper Functions

The `helpers/jobtread-client.sh` script provides reusable functions to simplify common operations:

```bash
# Source the helper functions
source ./helpers/jobtread-client.sh

# List all projects (active status)
jobtread_list_projects "in_progress"

# Get project details
jobtread_get_project "PROJECT_UUID"

# Get all jobs in project
jobtread_get_jobs "PROJECT_UUID"

# Create a new job
jobtread_create_job "PROJECT_UUID" "Job Name" 50000 "2026-05-01" "2026-05-30"

# Update task status
jobtread_update_task "TASK_UUID" "in_progress" 75
```

See `helpers/jobtread-client.sh` for implementation details and additional functions.

## Error Handling

Jobtread API returns standard HTTP status codes:

### 400 Bad Request
- **Cause:** Invalid query parameters or malformed request body
- **Recovery:** Check SKILL.md examples for correct format. Verify all required fields present.
- **Example:** `missing required field: scheduled_start`

### 401 Unauthorized
- **Cause:** API key invalid, expired, or missing
- **Recovery:** Contact operator. API key may need rotation (quarterly).
- **Action:** Mark issue as `blocked`, post comment requesting key refresh.

### 403 Forbidden
- **Cause:** API key lacks permission for this resource or company
- **Recovery:** Verify `JOBTREAD_COMPANY_ID` matches Ideal Construction. Check API key has write permission if doing POST/PATCH.
- **Action:** Block and escalate to operator.

### 404 Not Found
- **Cause:** Project, job, or task ID doesn't exist or was deleted
- **Recovery:** Verify ID is correct. List projects/jobs to find correct ID.
- **Action:** Update Paperclip issue with correct reference or close if no longer relevant.

### 422 Unprocessable Entity
- **Cause:** Request validation failed (invalid date format, budget not number, etc.)
- **Recovery:** Review error message. Check references/api-reference.md for field types and formats.
- **Example:** `scheduled_end must be after scheduled_start`

### 429 Too Many Requests
- **Cause:** Rate limit exceeded (typically 100 requests/minute per API key)
- **Recovery:** Wait 60 seconds, then retry. Use exponential backoff.
- **Best practice:** Batch multiple operations into single API calls where possible.

### 500 Internal Server Error
- **Cause:** Server-side issue (rare)
- **Recovery:** Retry after 30 seconds. If persists, escalate to Jobtread support.
- **Action:** Don't block Paperclip issue; retry in next heartbeat.

**General Error Handling Pattern:**

```bash
RESPONSE=$(curl -sS -w "\n%{http_code}" "$ENDPOINT" ...)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "201" ]]; then
  echo "ERROR: HTTP $HTTP_CODE" >&2
  echo "$BODY" | jq . >&2

  if [[ "$HTTP_CODE" == "401" ]]; then
    # Mark as blocked, request operator action
  elif [[ "$HTTP_CODE" == "429" ]]; then
    # Back off and retry
  fi
fi
```

## Common Integration Patterns

### Pattern 1: Jobtread Project → Paperclip Issue

When a new project is approved in Jobtread, automatically create Paperclip tracking issue:

```bash
# 1. Get Jobtread project
PROJECT=$(curl -sS "$JOBTREAD_API_URL/projects/$JT_PROJECT_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

PROJECT_NAME=$(echo "$PROJECT" | jq -r '.name')
BUDGET=$(echo "$PROJECT" | jq -r '.budget')

# 2. Create Paperclip parent issue
PC_ISSUE=$(curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/issues" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
  -d '{
    "title": "Project Startup - '$PROJECT_NAME'",
    "description": "Approved: Jobtread #'$JT_PROJECT_ID'\n\nBudget: $'$BUDGET'",
    "status": "todo"
  }')

# 3. Create subtasks for each job
curl -sS "$JOBTREAD_API_URL/projects/$JT_PROJECT_ID/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq -r '.[] | .id' | while read JOB_ID; do
  JOB_NAME=$(curl -sS "$JOBTREAD_API_URL/jobs/$JOB_ID" \
    -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq -r '.name')

  curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/issues" \
    -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
    -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
    -d '{
      "title": "'$JOB_NAME'",
      "parentId": "'$PC_PARENT_ID'",
      "status": "todo"
    }'
done
```

### Pattern 2: Daily Status Sync

Agents can poll Jobtread for status updates and post summaries to Paperclip:

```bash
# 1. Get all in-progress jobs
JOBS=$(curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq '.[] | .id' -r)

# 2. Build status summary
STATUS_REPORT="# Daily Construction Status\n\n"
for PROJECT_ID in $JOBS; do
  PROJECT=$(curl -sS "$JOBTREAD_API_URL/projects/$PROJECT_ID" \
    -H "Authorization: Bearer $JOBTREAD_API_KEY")

  STATUS_REPORT="$STATUS_REPORT\n## $(echo "$PROJECT" | jq -r '.name')\n"
  STATUS_REPORT="$STATUS_REPORT- Status: $(echo "$PROJECT" | jq -r '.status')\n"
  STATUS_REPORT="$STATUS_REPORT- Budget: $(echo "$PROJECT" | jq -r '.budget')\n"
done

# 3. Post to Paperclip issue
curl -sS -X POST "$PAPERCLIP_API_URL/api/issues/$PAPERCLIP_ISSUE_ID/comments" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
  -d "{ \"content\": \"$STATUS_REPORT\" }"
```

## Security

- **API Key Protection:**
  - Never log or commit API key to version control
  - Key stored only in Paperclip adapter config (secrets manager)
  - Injected at agent runtime only
  - Rotated quarterly

- **Data Access:**
  - Skill is scoped to Ideal Construction company only
  - API key has read/write permissions (no admin access)
  - All requests include `X-Paperclip-Run-Id` for audit trail

- **Error Handling:**
  - Never expose full API responses in Paperclip comments (may contain sensitive data)
  - Redact API key in error messages
  - Use generic error descriptions for agent-facing output

## Troubleshooting

### "Authorization failed (401)"

```bash
# 1. Verify environment variables are set
echo "API Key: $JOBTREAD_API_KEY" | head -c 20
echo "Company ID: $JOBTREAD_COMPANY_ID"
echo "API URL: $JOBTREAD_API_URL"

# 2. Test API connection directly
curl -v "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"

# 3. If 401, contact operator for key refresh
```

### "Not found (404) for project XYZ"

```bash
# 1. List all available projects
curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq '.[].id'

# 2. Use correct ID from output
```

### "Rate limited (429)"

```bash
# 1. Wait 60 seconds
sleep 60

# 2. Implement exponential backoff in retry loop
for attempt in 1 2 3 4; do
  RESPONSE=$(curl -sS "$ENDPOINT" ...)
  HTTP_CODE=$(echo "$RESPONSE" | jq '.http_code')

  if [[ "$HTTP_CODE" == "429" ]]; then
    WAIT=$((2 ** attempt))
    echo "Rate limited. Waiting ${WAIT}s..."
    sleep $WAIT
  else
    break
  fi
done
```

## Additional Resources

- **API Reference:** See `references/api-reference.md` for complete endpoint list and schemas
- **Examples:** See `references/examples.md` for worked curl examples
- **Helper Functions:** See `helpers/jobtread-client.sh` for bash wrapper functions
- **Jobtread Docs:** https://www.jobtread.com/api/docs
- **Support:** Contact Jobtread at support@jobtread.com for API issues
