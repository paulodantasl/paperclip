# Jobtread Integration Examples

Worked examples showing common Jobtread integration patterns for construction project management.

## Example 1: Verify API Connection

Test that your API key and environment are configured correctly:

```bash
#!/bin/bash

echo "=== Jobtread API Connection Test ==="
echo "API URL: $JOBTREAD_API_URL"
echo "Company ID: $JOBTREAD_COMPANY_ID"
echo "API Key: ${JOBTREAD_API_KEY:0:10}..." # Show first 10 chars only

echo ""
echo "Testing connection..."

RESPONSE=$(curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

echo "$RESPONSE" | jq .

# Check if response contains company name
if echo "$RESPONSE" | jq -e '.name' > /dev/null 2>&1; then
  COMPANY_NAME=$(echo "$RESPONSE" | jq -r '.name')
  echo "✓ Connection successful! Company: $COMPANY_NAME"
else
  echo "✗ Connection failed. Check API key and Company ID."
  exit 1
fi
```

**Expected Output:**
```
=== Jobtread API Connection Test ===
API URL: https://www.jobtread.com/api
Company ID: 12345678-1234-1234-1234-123456789012
API Key: 22TL2ziHj...

Testing connection...
{
  "id": "12345678-1234-1234-1234-123456789012",
  "name": "Ideal Construction",
  "status": "active",
  ...
}
✓ Connection successful! Company: Ideal Construction
```

---

## Example 2: List All Active Projects

Get a summary of all in-progress construction projects:

```bash
#!/bin/bash

echo "=== Active Projects for Ideal Construction ==="
echo ""

PROJECTS=$(curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

# Count projects
PROJECT_COUNT=$(echo "$PROJECTS" | jq 'length')
echo "Total Active Projects: $PROJECT_COUNT"
echo ""

# Display each project
echo "$PROJECTS" | jq -r '.[] | "
Project: \(.name)
  Status: \(.status)
  Budget: $\(.budget | tonumber | floor)
  Actual: $\(.actual_cost | tonumber | floor)
  Variance: $\((.actual_cost - .budget) | tonumber | floor)
  Progress: \(.completion_percent)%
  Location: \(.address)
  Jobs: \(.job_count)
---"'

# Calculate total budget and actual
TOTAL_BUDGET=$(echo "$PROJECTS" | jq '[.[].budget] | add')
TOTAL_ACTUAL=$(echo "$PROJECTS" | jq '[.[].actual_cost] | add')

echo ""
echo "Summary:"
echo "Total Budget: $$TOTAL_BUDGET"
echo "Total Actual: $$TOTAL_ACTUAL"
echo "Total Variance: $$(($TOTAL_ACTUAL - $TOTAL_BUDGET))"
```

**Expected Output:**
```
=== Active Projects for Ideal Construction ===

Total Active Projects: 3

Project: Downtown Office Renovation
  Status: in_progress
  Budget: $450000
  Actual: $235680
  Variance: $-214320
  Progress: 52%
  Location: 456 Market St, Denver, CO
  Jobs: 12
---
Project: Warehouse Extension - North Bay
  Status: in_progress
  Budget: $680000
  Actual: $412100
  Variance: $-267900
  Progress: 60%
  Location: 789 Industrial Blvd, San Jose, CA
  Jobs: 18
---
...
```

---

## Example 3: Get Project Details with Job Breakdown

Retrieve full project hierarchy with all jobs and their status:

```bash
#!/bin/bash

PROJECT_ID="${1:-proj-001}"

echo "=== Project Detail: $PROJECT_ID ==="
echo ""

PROJECT=$(curl -sS "$JOBTREAD_API_URL/projects/$PROJECT_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

PROJECT_NAME=$(echo "$PROJECT" | jq -r '.name')
PROJECT_STATUS=$(echo "$PROJECT" | jq -r '.status')
PROJECT_BUDGET=$(echo "$PROJECT" | jq -r '.budget')
PROJECT_COMPLETION=$(echo "$PROJECT" | jq -r '.completion_percent')

echo "Project: $PROJECT_NAME"
echo "Status: $PROJECT_STATUS"
echo "Budget: $$PROJECT_BUDGET"
echo "Completion: $PROJECT_COMPLETION%"
echo ""

echo "=== Jobs in Project ==="
echo ""

echo "$PROJECT" | jq -r '.jobs[] | "
Job: \(.name) (ID: \(.id))
  Phase: \(.phase)
  Status: \(.status)
  Budget: $\(.budget | tonumber | floor)
  Actual: $\(.actual_cost | tonumber | floor)
  Progress: \(.completion_percent)%
  Crew: \(.assigned_crew)
  Dates: \(.scheduled_start) to \(.scheduled_end)
---"'
```

**Usage:**
```bash
./example3.sh proj-001
```

**Expected Output:**
```
=== Project Detail: proj-001 ===

Project: Downtown Office Renovation
Status: in_progress
Budget: $450000
Completion: 52%

=== Jobs in Project ===

Job: Electrical Rough-In (ID: job-001)
  Phase: Electrical
  Status: completed
  Budget: $45000
  Actual: $44850
  Progress: 100%
  Crew: Elite Electric LLC
  Dates: 2026-03-15 to 2026-04-15
---
Job: HVAC Installation (ID: job-002)
  Phase: Mechanical
  Status: in_progress
  Budget: $120000
  Actual: $87650
  Progress: 73%
  Crew: Climate Control Systems
  Dates: 2026-04-01 to 2026-06-30
---
```

---

## Example 4: Check Tasks for a Job

Get all tasks in a specific job and filter by status:

```bash
#!/bin/bash

JOB_ID="${1:-job-002}"

echo "=== Tasks for Job: $JOB_ID ==="
echo ""

TASKS=$(curl -sS "$JOBTREAD_API_URL/jobs/$JOB_ID/tasks" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

# Count tasks by status
echo "Summary:"
echo "- Not Started: $(echo "$TASKS" | jq '[.[] | select(.status=="not_started")] | length')"
echo "- In Progress: $(echo "$TASKS" | jq '[.[] | select(.status=="in_progress")] | length')"
echo "- On Hold: $(echo "$TASKS" | jq '[.[] | select(.status=="on_hold")] | length')"
echo "- Completed: $(echo "$TASKS" | jq '[.[] | select(.status=="completed")] | length')"
echo ""

echo "=== In Progress Tasks ==="
echo ""
echo "$TASKS" | jq -r '.[] | select(.status=="in_progress") | "
Task: \(.name)
  Assigned to: \(.assigned_to // "Unassigned")
  Progress: \(.progress_percent)%
  Due: \(.due_date)
  Notes: \(.notes // "None")
---"'

echo ""
echo "=== Overdue or At Risk ==="
echo ""
CURRENT_DATE=$(date -u +%Y-%m-%d)
echo "$TASKS" | jq -r --arg today "$CURRENT_DATE" '.[] | select(.due_date < $today and .status != "completed") | "
OVERDUE: \(.name)
  Due: \(.due_date)
  Status: \(.status)
  Progress: \(.progress_percent)%
---"'
```

**Usage:**
```bash
./example4.sh job-002
```

**Expected Output:**
```
=== Tasks for Job: job-002 ===

Summary:
- Not Started: 3
- In Progress: 5
- On Hold: 1
- Completed: 9

=== In Progress Tasks ===

Task: Install ductwork - Section B
  Assigned to: Tommy Rodriguez
  Progress: 65%
  Due: 2026-04-27
  Notes: Waiting for materials from supplier (ETA Wed)
---
...

=== Overdue or At Risk ===

OVERDUE: Install unit test framework
  Due: 2026-03-15
  Status: in_progress
  Progress: 40%
---
```

---

## Example 5: Create a New Job from Paperclip Approval

When a Paperclip approval adds a new construction phase, automatically create the job in Jobtread:

```bash
#!/bin/bash

# This would be called from a Paperclip agent when an approval is finalized

PROJECT_ID="proj-001"
JOB_NAME="Plumbing Final"
JOB_DESCRIPTION="Install all final plumbing fixtures per plan"
JOB_PHASE="Finish"
BUDGET=35000
START_DATE="2026-07-01"
END_DATE="2026-07-20"
CREW_NAME="AquaPro Plumbing"

echo "Creating job in Jobtread..."
echo "Project: $PROJECT_ID"
echo "Job: $JOB_NAME"
echo "Budget: $$BUDGET"
echo ""

# Create the job
JOB_RESPONSE=$(curl -sS -X POST "$JOBTREAD_API_URL/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": "'$PROJECT_ID'",
    "name": "'$JOB_NAME'",
    "description": "'$JOB_DESCRIPTION'",
    "phase": "'$JOB_PHASE'",
    "budget_amount": '$BUDGET',
    "scheduled_start": "'$START_DATE'",
    "scheduled_end": "'$END_DATE'",
    "assigned_crew": "'$CREW_NAME'"
  }')

# Check if successful
if echo "$JOB_RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  JOB_ID=$(echo "$JOB_RESPONSE" | jq -r '.id')
  echo "✓ Job created successfully!"
  echo "Job ID: $JOB_ID"

  # Now create Paperclip issue for this job
  if [ -n "$PAPERCLIP_API_URL" ]; then
    echo ""
    echo "Creating Paperclip tracking issue..."

    PAPERCLIP_RESPONSE=$(curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/issues" \
      -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
      -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
      -d '{
        "title": "'$JOB_NAME' (Jobtread #'$JOB_ID')",
        "description": "Created: Jobtread job for construction phase\n\n**Budget:** $'$BUDGET'\n**Dates:** '$START_DATE' to '$END_DATE'\n**Crew:** '$CREW_NAME'\n\n[View in Jobtread](https://www.jobtread.com/jobs/'$JOB_ID')",
        "status": "todo",
        "priority": "high"
      }')

    PC_ISSUE_ID=$(echo "$PAPERCLIP_RESPONSE" | jq -r '.id // empty')
    if [ -n "$PC_ISSUE_ID" ]; then
      echo "✓ Paperclip issue created: $PC_ISSUE_ID"
    fi
  fi
else
  echo "✗ Failed to create job"
  echo "$JOB_RESPONSE" | jq .
  exit 1
fi
```

**Expected Output:**
```
Creating job in Jobtread...
Project: proj-001
Job: Plumbing Final
Budget: $35000

✓ Job created successfully!
Job ID: job-003

Creating Paperclip tracking issue...
✓ Paperclip issue created: PAP-1234
```

---

## Example 6: Update Job Status as Work Completes

Mark a job as completed in Jobtread when the Paperclip task is done:

```bash
#!/bin/bash

JOB_ID="${1:-job-003}"
ACTUAL_COST="${2:-34950}"

echo "Completing job in Jobtread: $JOB_ID"
echo "Actual Cost: $$ACTUAL_COST"
echo ""

CURRENT_DATE=$(date -u +%Y-%m-%d)

RESPONSE=$(curl -sS -X PATCH "$JOBTREAD_API_URL/jobs/$JOB_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed",
    "actual_cost": '$ACTUAL_COST',
    "completed_date": "'$CURRENT_DATE'"
  }')

if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  BUDGET=$(echo "$RESPONSE" | jq -r '.budget')
  VARIANCE=$(echo "$RESPONSE" | jq -r '.actual_cost - .budget')

  echo "✓ Job completed in Jobtread"
  echo ""
  echo "Budget: $$BUDGET"
  echo "Actual: $$ACTUAL_COST"
  echo "Variance: $$VARIANCE"

  if (( $(echo "$VARIANCE < 0" | bc -l) )); then
    echo "Status: UNDER BUDGET ✓"
  elif (( $(echo "$VARIANCE > 0" | bc -l) )); then
    echo "Status: OVER BUDGET ✗"
  else
    echo "Status: ON BUDGET ✓"
  fi
else
  echo "✗ Failed to update job"
  echo "$RESPONSE" | jq .
  exit 1
fi
```

**Usage:**
```bash
./example6.sh job-003 34950
```

**Expected Output:**
```
Completing job in Jobtread: job-003
Actual Cost: $34950

✓ Job completed in Jobtread

Budget: $35000
Actual: $34950
Variance: $-50
Status: UNDER BUDGET ✓
```

---

## Example 7: Update Task Progress Daily

Update task status and progress as crew reports work:

```bash
#!/bin/bash

TASK_ID="${1:-task-202}"
STATUS="${2:-in_progress}"
PROGRESS="${3:-75}"
NOTES="${4:-Continuing work on schedule}"

echo "Updating task: $TASK_ID"
echo "Status: $STATUS"
echo "Progress: $PROGRESS%"
echo ""

RESPONSE=$(curl -sS -X PATCH "$JOBTREAD_API_URL/tasks/$TASK_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "'$STATUS'",
    "progress_percent": '$PROGRESS',
    "notes": "'$NOTES'"
  }')

if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  TASK_NAME=$(echo "$RESPONSE" | jq -r '.name')
  ASSIGNED_TO=$(echo "$RESPONSE" | jq -r '.assigned_to // "Unassigned"')

  echo "✓ Task updated: $TASK_NAME"
  echo "  Assigned to: $ASSIGNED_TO"
  echo "  Progress: $PROGRESS%"
  echo "  Status: $STATUS"
else
  echo "✗ Failed to update task"
  echo "$RESPONSE" | jq .
  exit 1
fi
```

**Usage:**
```bash
./example7.sh task-202 in_progress 75 "Ductwork Section B 75% complete. Installing connections."
```

**Expected Output:**
```
Updating task: task-202
Status: in_progress
Progress: 75%

✓ Task updated: Install ductwork - Section B
  Assigned to: Tommy Rodriguez
  Progress: 75%
  Status: in_progress
```

---

## Example 8: Generate Daily Status Report

Create a daily status report from Jobtread for all active projects:

```bash
#!/bin/bash

echo "=== Daily Construction Status Report ==="
echo "Generated: $(date)"
echo ""

PROJECTS=$(curl -sS "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

PROJECT_COUNT=$(echo "$PROJECTS" | jq 'length')

echo "Active Projects: $PROJECT_COUNT"
echo ""

# For each project, get job summary
echo "$PROJECTS" | jq -r '.[] | {id, name, budget, actual_cost, completion_percent}' | while read -r LINE; do
  PROJECT_ID=$(echo "$LINE" | jq -r '.id')
  PROJECT_NAME=$(echo "$LINE" | jq -r '.name')

  JOBS=$(curl -sS "$JOBTREAD_API_URL/projects/$PROJECT_ID/jobs" \
    -H "Authorization: Bearer $JOBTREAD_API_KEY")

  JOBS_COMPLETED=$(echo "$JOBS" | jq '[.[] | select(.status=="completed")] | length')
  JOBS_IN_PROGRESS=$(echo "$JOBS" | jq '[.[] | select(.status=="in_progress")] | length')
  JOBS_TOTAL=$(echo "$JOBS" | jq 'length')

  OVER_BUDGET=$(echo "$JOBS" | jq '[.[] | select(.actual_cost > .budget)] | length')

  echo "## $PROJECT_NAME"
  echo "- Progress: $JOBS_COMPLETED/$JOBS_TOTAL jobs completed"
  echo "- Active: $JOBS_IN_PROGRESS jobs in progress"
  echo "- At Risk: $OVER_BUDGET jobs over budget"
  echo ""
done

echo "End of Report"
```

**Expected Output:**
```
=== Daily Construction Status Report ===
Generated: Mon Mar 22 15:30:00 UTC 2026

Active Projects: 3

## Downtown Office Renovation
- Progress: 6/12 jobs completed
- Active: 4 jobs in progress
- At Risk: 1 job over budget

## Warehouse Extension - North Bay
- Progress: 8/18 jobs completed
- Active: 7 jobs in progress
- At Risk: 2 jobs over budget

...

End of Report
```

---

## Example 9: Error Handling - Retry on Rate Limit

Handle rate limiting with exponential backoff:

```bash
#!/bin/bash

ENDPOINT="${1}"
METHOD="${2:-GET}"
DATA="${3:-}"
MAX_ATTEMPTS=4

attempt=0
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  attempt=$((attempt + 1))

  echo "Attempt $attempt/$MAX_ATTEMPTS: $METHOD $ENDPOINT"

  if [ -z "$DATA" ]; then
    RESPONSE=$(curl -sS -w "\n%{http_code}" -X "$METHOD" \
      "$JOBTREAD_API_URL$ENDPOINT" \
      -H "Authorization: Bearer $JOBTREAD_API_KEY")
  else
    RESPONSE=$(curl -sS -w "\n%{http_code}" -X "$METHOD" \
      "$JOBTREAD_API_URL$ENDPOINT" \
      -H "Authorization: Bearer $JOBTREAD_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$DATA")
  fi

  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  BODY=$(echo "$RESPONSE" | head -n -1)

  echo "Response: HTTP $HTTP_CODE"

  if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "201" ]; then
    echo "✓ Success"
    echo "$BODY"
    exit 0
  elif [ "$HTTP_CODE" == "429" ]; then
    WAIT=$((2 ** (attempt - 1)))
    echo "Rate limited. Waiting ${WAIT}s before retry..."
    sleep $WAIT
  elif [ "$HTTP_CODE" == "401" ] || [ "$HTTP_CODE" == "403" ]; then
    echo "✗ Authentication error. Check API key."
    echo "$BODY" | jq . >&2
    exit 1
  else
    echo "✗ Error"
    echo "$BODY" | jq . >&2
    exit 1
  fi
done

echo "✗ Max attempts reached. Giving up."
exit 1
```

**Usage:**
```bash
./example9.sh "/companies/$JOBTREAD_COMPANY_ID/projects"
```

---

## Example 10: Sync Paperclip Issues to Jobtread Tasks

Create Jobtread tasks from Paperclip issues when a project is approved:

```bash
#!/bin/bash

PROJECT_ID="proj-001"
PAPERCLIP_ISSUE_ID="PAP-1234"

echo "Syncing Paperclip issue to Jobtread tasks..."
echo ""

# 1. Get Paperclip issue details
ISSUE=$(curl -sS "$PAPERCLIP_API_URL/api/issues/$PAPERCLIP_ISSUE_ID" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY")

ISSUE_TITLE=$(echo "$ISSUE" | jq -r '.title')
ISSUE_DESCRIPTION=$(echo "$ISSUE" | jq -r '.description // ""')

echo "Paperclip Issue: $ISSUE_TITLE"
echo ""

# 2. Get Jobtread project's main job (or create if needed)
JOBS=$(curl -sS "$JOBTREAD_API_URL/projects/$PROJECT_ID/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

MAIN_JOB_ID=$(echo "$JOBS" | jq -r '.[0].id // empty')

if [ -z "$MAIN_JOB_ID" ]; then
  echo "Creating main job for project..."
  JOB_RESP=$(curl -sS -X POST "$JOBTREAD_API_URL/jobs" \
    -H "Authorization: Bearer $JOBTREAD_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{
      "project_id": "'$PROJECT_ID'",
      "name": "Project Work - Approved",
      "scheduled_start": "'$(date -u +%Y-%m-%d)'",
      "scheduled_end": "'$(date -u -d '+30 days' +%Y-%m-%d)'"
    }')
  MAIN_JOB_ID=$(echo "$JOB_RESP" | jq -r '.id')
fi

echo "Job ID: $MAIN_JOB_ID"
echo ""

# 3. Create task for the issue
TASK_RESP=$(curl -sS -X POST "$JOBTREAD_API_URL/tasks" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "'$MAIN_JOB_ID'",
    "name": "'$ISSUE_TITLE'",
    "due_date": "'$(date -u +%Y-%m-%d)'",
    "priority": "high",
    "notes": "Created from Paperclip issue '$PAPERCLIP_ISSUE_ID'\n\n'$ISSUE_DESCRIPTION'"
  }')

TASK_ID=$(echo "$TASK_RESP" | jq -r '.id // empty')

if [ -n "$TASK_ID" ]; then
  echo "✓ Task created in Jobtread: $TASK_ID"

  # 4. Update Paperclip issue with Jobtread reference
  curl -sS -X POST "$PAPERCLIP_API_URL/api/issues/$PAPERCLIP_ISSUE_ID/comments" \
    -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
    -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
    -d '{"content": "Synced to Jobtread task: ['"$TASK_ID"'](https://www.jobtread.com/tasks/'"$TASK_ID"')"}'

  echo "✓ Paperclip issue updated with link"
else
  echo "✗ Failed to create task"
  echo "$TASK_RESP" | jq . >&2
  exit 1
fi
```

**Usage:**
```bash
./example10.sh
```

---

These examples show the most common Jobtread integration patterns for construction project management with Paperclip.
