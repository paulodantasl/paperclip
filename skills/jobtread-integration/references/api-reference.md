# Jobtread API Reference

Complete reference for Jobtread construction management API endpoints.

## API Overview

- **Base URL:** `https://www.jobtread.com/api`
- **Authentication:** Bearer token in Authorization header
- **Response Format:** JSON
- **Rate Limit:** 100 requests/minute per API key
- **Pagination:** Supported on collection endpoints (limit, offset parameters)

## Endpoint Reference Table

| Endpoint | Method | Purpose | Auth Required |
|----------|--------|---------|---|
| `/companies/{id}` | GET | Get company details | Yes |
| `/companies/{id}/projects` | GET | List all projects in company | Yes |
| `/projects/{id}` | GET | Get single project with jobs | Yes |
| `/projects/{id}/jobs` | GET | List jobs in project | Yes |
| `/jobs/{id}` | GET | Get single job details | Yes |
| `/jobs/{id}/tasks` | GET | List tasks in job | Yes |
| `/tasks/{id}` | GET | Get single task details | Yes |
| `/jobs` | POST | Create new job | Yes |
| `/tasks` | POST | Create new task | Yes |
| `/jobs/{id}` | PATCH | Update job (status, budget, etc.) | Yes |
| `/tasks/{id}` | PATCH | Update task (status, progress, etc.) | Yes |

## Request/Response Schemas

### GET /companies/{id}

**Request:**
```bash
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"
```

**Response:** 200 OK
```json
{
  "id": "12345678-1234-1234-1234-123456789012",
  "name": "Ideal Construction",
  "address": "123 Main St, Denver, CO 80202",
  "phone": "(720) 555-0123",
  "email": "info@idealconstruction.com",
  "status": "active",
  "subscription_level": "professional",
  "api_usage": {
    "requests_this_month": 2450,
    "requests_limit": 10000
  },
  "created_at": "2020-01-15T10:30:00Z",
  "updated_at": "2026-03-22T14:45:00Z"
}
```

**Status codes:**
- `200` - Success
- `401` - Unauthorized (invalid API key)
- `403` - Forbidden (API key lacks permission)

---

### GET /companies/{id}/projects

**Request:**
```bash
# All projects
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"

# With filters
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress&limit=50&offset=0" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"
```

**Query Parameters:**
- `status` - Filter by status (prospect, estimate, in_progress, completed, archived, on_hold)
- `limit` - Rows per page (default: 50, max: 100)
- `offset` - Pagination offset (default: 0)
- `sort` - Sort field (name, status, budget, created_at)
- `sort_order` - asc or desc (default: asc)

**Response:** 200 OK
```json
[
  {
    "id": "proj-001",
    "name": "Downtown Office Renovation",
    "address": "456 Market St, Denver, CO",
    "client_id": "client-001",
    "client_name": "Modern Enterprises Inc.",
    "status": "in_progress",
    "budget": 450000,
    "actual_cost": 235680,
    "scheduled_start": "2026-03-01",
    "scheduled_end": "2026-08-31",
    "completion_percent": 52,
    "job_count": 12,
    "contact_email": "facilities@modern.com",
    "notes": "Phase 2 HVAC work pending",
    "created_at": "2026-01-15T08:00:00Z",
    "updated_at": "2026-03-20T15:30:00Z"
  },
  {
    "id": "proj-002",
    "name": "Warehouse Extension - North Bay",
    "address": "789 Industrial Blvd, San Jose, CA",
    "client_id": "client-002",
    "client_name": "Logistics Hub LLC",
    "status": "in_progress",
    "budget": 680000,
    "actual_cost": 412100,
    "scheduled_start": "2026-02-15",
    "scheduled_end": "2026-10-31",
    "completion_percent": 60,
    "job_count": 18,
    "contact_email": "ops@logisticshubb.com",
    "notes": null,
    "created_at": "2025-12-10T09:15:00Z",
    "updated_at": "2026-03-21T11:00:00Z"
  }
]
```

---

### GET /projects/{id}

**Request:**
```bash
curl "$JOBTREAD_API_URL/projects/$PROJECT_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"
```

**Response:** 200 OK
```json
{
  "id": "proj-001",
  "name": "Downtown Office Renovation",
  "address": "456 Market St, Denver, CO",
  "client_id": "client-001",
  "client_name": "Modern Enterprises Inc.",
  "status": "in_progress",
  "budget": 450000,
  "actual_cost": 235680,
  "scheduled_start": "2026-03-01",
  "scheduled_end": "2026-08-31",
  "completion_percent": 52,
  "contact_email": "facilities@modern.com",
  "notes": "Phase 2 HVAC work pending",
  "jobs": [
    {
      "id": "job-001",
      "name": "Electrical Rough-In",
      "status": "completed",
      "budget": 45000,
      "actual_cost": 44850,
      "phase": "Electrical",
      "scheduled_start": "2026-03-15",
      "scheduled_end": "2026-04-15"
    },
    {
      "id": "job-002",
      "name": "HVAC Installation",
      "status": "in_progress",
      "budget": 120000,
      "actual_cost": 87650,
      "phase": "Mechanical",
      "scheduled_start": "2026-04-01",
      "scheduled_end": "2026-06-30"
    }
  ],
  "created_at": "2026-01-15T08:00:00Z",
  "updated_at": "2026-03-20T15:30:00Z"
}
```

---

### GET /projects/{id}/jobs

**Request:**
```bash
curl "$JOBTREAD_API_URL/projects/$PROJECT_ID/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"
```

**Response:** 200 OK
```json
[
  {
    "id": "job-001",
    "name": "Electrical Rough-In",
    "description": "Run all electrical conduit and wire per plan",
    "status": "completed",
    "phase": "Rough-In",
    "budget": 45000,
    "actual_cost": 44850,
    "scheduled_start": "2026-03-15",
    "scheduled_end": "2026-04-15",
    "completed_date": "2026-04-12",
    "assigned_crew": "Elite Electric LLC",
    "task_count": 8,
    "completion_percent": 100
  },
  {
    "id": "job-002",
    "name": "HVAC Installation",
    "description": null,
    "status": "in_progress",
    "phase": "Mechanical",
    "budget": 120000,
    "actual_cost": 87650,
    "scheduled_start": "2026-04-01",
    "scheduled_end": "2026-06-30",
    "completed_date": null,
    "assigned_crew": "Climate Control Systems",
    "task_count": 12,
    "completion_percent": 73
  }
]
```

---

### GET /jobs/{id}

**Request:**
```bash
curl "$JOBTREAD_API_URL/jobs/$JOB_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"
```

**Response:** 200 OK
```json
{
  "id": "job-002",
  "project_id": "proj-001",
  "name": "HVAC Installation",
  "description": null,
  "status": "in_progress",
  "phase": "Mechanical",
  "budget": 120000,
  "actual_cost": 87650,
  "cost_variance": -32350,
  "scheduled_start": "2026-04-01",
  "scheduled_end": "2026-06-30",
  "completed_date": null,
  "assigned_crew": "Climate Control Systems",
  "crew_id": "crew-012",
  "completion_percent": 73,
  "task_count": 12,
  "tasks_completed": 9,
  "tasks_pending": 3,
  "materials": [
    {
      "name": "Ductwork 8x10",
      "quantity": 450,
      "unit": "feet",
      "cost": 12600
    },
    {
      "name": "HVAC Unit (5-ton)",
      "quantity": 2,
      "unit": "units",
      "cost": 18500
    }
  ],
  "created_at": "2026-03-15T10:00:00Z",
  "updated_at": "2026-03-20T16:45:00Z"
}
```

---

### GET /jobs/{id}/tasks

**Request:**
```bash
curl "$JOBTREAD_API_URL/jobs/$JOB_ID/tasks" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"
```

**Response:** 200 OK
```json
[
  {
    "id": "task-201",
    "job_id": "job-002",
    "name": "Install ductwork - Section A",
    "status": "completed",
    "progress_percent": 100,
    "assigned_to": "Tommy Rodriguez",
    "due_date": "2026-04-20",
    "completed_date": "2026-04-18",
    "priority": "high",
    "notes": null,
    "estimated_hours": 40,
    "actual_hours": 38
  },
  {
    "id": "task-202",
    "job_id": "job-002",
    "name": "Install ductwork - Section B",
    "status": "in_progress",
    "progress_percent": 65,
    "assigned_to": "Tommy Rodriguez",
    "due_date": "2026-04-27",
    "completed_date": null,
    "priority": "high",
    "notes": "Waiting for materials from supplier (ETA Wed)",
    "estimated_hours": 45,
    "actual_hours": 30
  },
  {
    "id": "task-203",
    "job_id": "job-002",
    "name": "Install HVAC units",
    "status": "not_started",
    "progress_percent": 0,
    "assigned_to": null,
    "due_date": "2026-05-15",
    "completed_date": null,
    "priority": "critical",
    "notes": "Cannot start until ductwork Section B complete",
    "estimated_hours": 60,
    "actual_hours": 0
  }
]
```

---

### POST /jobs

**Request:**
```bash
curl -X POST "$JOBTREAD_API_URL/jobs" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": "proj-001",
    "name": "Plumbing Final",
    "description": "Install all final plumbing fixtures",
    "phase": "Finish",
    "budget_amount": 35000,
    "scheduled_start": "2026-07-01",
    "scheduled_end": "2026-07-20",
    "assigned_crew": "AquaPro Plumbing"
  }'
```

**Required Fields:**
- `project_id` - UUID of parent project
- `name` - Job name/description
- `scheduled_start` - ISO 8601 date (must be after project start)
- `scheduled_end` - ISO 8601 date (must be before project end, after start)

**Optional Fields:**
- `description` - Longer description
- `phase` - Phase category (Foundation, Framing, Mechanical, Electrical, Finish, etc.)
- `budget_amount` - Budgeted cost (decimal number)
- `assigned_crew` - Crew or subcontractor name

**Response:** 201 Created
```json
{
  "id": "job-003",
  "project_id": "proj-001",
  "name": "Plumbing Final",
  "description": "Install all final plumbing fixtures",
  "phase": "Finish",
  "status": "pending",
  "budget": 35000,
  "actual_cost": 0,
  "scheduled_start": "2026-07-01",
  "scheduled_end": "2026-07-20",
  "assigned_crew": "AquaPro Plumbing",
  "completion_percent": 0,
  "created_at": "2026-03-22T14:55:00Z"
}
```

**Error Responses:**
- `400` - Missing required field or invalid format
- `422` - Validation error (e.g., end date before start date)

---

### PATCH /jobs/{id}

**Request:**
```bash
curl -X PATCH "$JOBTREAD_API_URL/jobs/$JOB_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed",
    "actual_cost": 34950,
    "completed_date": "2026-07-18"
  }'
```

**Updateable Fields:**
- `status` - pending, in_progress, on_hold, completed
- `actual_cost` - Decimal cost amount
- `completed_date` - ISO 8601 date (when job finished)
- `assigned_crew` - Update crew assignment
- `budget` - Update budget amount

**Response:** 200 OK
```json
{
  "id": "job-003",
  "project_id": "proj-001",
  "name": "Plumbing Final",
  "status": "completed",
  "budget": 35000,
  "actual_cost": 34950,
  "scheduled_end": "2026-07-20",
  "completed_date": "2026-07-18",
  "completion_percent": 100,
  "updated_at": "2026-03-22T15:10:00Z"
}
```

---

### POST /tasks

**Request:**
```bash
curl -X POST "$JOBTREAD_API_URL/tasks" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": "job-003",
    "name": "Install sink and faucets",
    "assigned_to": "Maria Garcia",
    "due_date": "2026-07-10",
    "priority": "high",
    "estimated_hours": 8
  }'
```

**Required Fields:**
- `job_id` - UUID of parent job
- `name` - Task name
- `due_date` - ISO 8601 date

**Optional Fields:**
- `assigned_to` - Crew member name
- `priority` - low, medium, high, critical (default: medium)
- `estimated_hours` - Number of hours budgeted
- `notes` - Task description/notes

**Response:** 201 Created
```json
{
  "id": "task-301",
  "job_id": "job-003",
  "name": "Install sink and faucets",
  "status": "not_started",
  "assigned_to": "Maria Garcia",
  "due_date": "2026-07-10",
  "priority": "high",
  "progress_percent": 0,
  "estimated_hours": 8,
  "actual_hours": 0,
  "created_at": "2026-03-22T15:15:00Z"
}
```

---

### PATCH /tasks/{id}

**Request:**
```bash
curl -X PATCH "$JOBTREAD_API_URL/tasks/$TASK_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in_progress",
    "progress_percent": 75,
    "actual_hours": 6,
    "notes": "Almost done. Faucets installed. Finishing plumbing connections."
  }'
```

**Updateable Fields:**
- `status` - not_started, in_progress, on_hold, completed
- `progress_percent` - 0-100 integer
- `actual_hours` - Hours spent (decimal)
- `assigned_to` - Change assignee
- `due_date` - Update due date
- `notes` - Task notes/comments
- `completed_date` - Date when task completed (ISO 8601)

**Response:** 200 OK
```json
{
  "id": "task-301",
  "job_id": "job-003",
  "name": "Install sink and faucets",
  "status": "in_progress",
  "progress_percent": 75,
  "assigned_to": "Maria Garcia",
  "actual_hours": 6,
  "notes": "Almost done. Faucets installed. Finishing plumbing connections.",
  "updated_at": "2026-03-22T15:20:00Z"
}
```

---

## Status Enums

### Project Statuses
- `prospect` - Initial inquiry/lead
- `estimate` - Quote being prepared
- `in_progress` - Active project
- `on_hold` - Paused (awaiting approval, materials, etc.)
- `completed` - Project finished
- `archived` - Historical (closed out)

### Job Statuses
- `pending` - Not yet started
- `in_progress` - Work underway
- `on_hold` - Temporarily paused
- `completed` - Finished

### Task Statuses
- `not_started` - Unstarted
- `in_progress` - Work underway
- `on_hold` - Paused
- `completed` - Finished

### Priority Levels
- `low` - Nice to have
- `medium` - Standard (default)
- `high` - Important
- `critical` - Must do ASAP

---

## Common HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK - Success | Continue |
| 201 | Created - Resource created | Use returned ID |
| 400 | Bad Request - Invalid parameters | Check request format |
| 401 | Unauthorized - Invalid API key | Request key refresh |
| 403 | Forbidden - No permission | Check API key scope |
| 404 | Not Found - Resource doesn't exist | Verify ID is correct |
| 422 | Unprocessable - Validation failed | Check field values/types |
| 429 | Too Many Requests - Rate limited | Back off and retry |
| 500 | Internal Server Error | Retry after 30s |

---

## Pagination Example

```bash
# Get page 1 (first 50 projects)
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?limit=50&offset=0" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq 'length'

# Get page 2 (next 50 projects)
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?limit=50&offset=50" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq 'length'
```

---

## Filtering Examples

```bash
# All in-progress projects
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"

# Completed projects, sorted by name
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=completed&sort=name&sort_order=asc" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY"

# Projects with high budget variance
curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID/projects?status=in_progress" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY" | jq '.[] | select(.actual_cost > (.budget * 1.1))'
```
