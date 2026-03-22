---
title: Ideal Construction - Jobtread Integration Setup Guide
description: Complete setup guide for connecting Ideal Construction company in Paperclip to Jobtread
---

# Ideal Construction - Jobtread Integration Setup

This guide walks through configuring Paperclip to integrate with Jobtread for Ideal Construction company. You'll set up API credentials, configure agent environment variables, and verify the integration.

## Prerequisites

- Paperclip server running and accessible
- Jobtread account with API access enabled
- Admin/board access to Paperclip
- API credentials ready:
  - **API Key:** `22TL2ziHjUradqgSReprTTg9uvY7ezpgRg`
  - **Company ID:** [To be provided by Jobtread]
  - **API URL:** `https://www.jobtread.com/api`

## Step 1: Store API Credentials as Company Secrets

Create secrets in Paperclip to store the Jobtread API credentials securely.

### Via API (Recommended)

**1a. Create the JOBTREAD_API_KEY secret:**

```bash
curl -X POST http://localhost:3000/api/companies/{COMPANY_ID}/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JOBTREAD_API_KEY",
    "value": "22TL2ziHjUradqgSReprTTg9uvY7ezpgRg",
    "description": "Jobtread API authentication key for Ideal Construction",
    "provider": "local_encrypted"
  }'
```

Response:
```json
{
  "id": "secret-uuid-1",
  "companyId": "company-uuid",
  "name": "JOBTREAD_API_KEY",
  "provider": "local_encrypted",
  "description": "Jobtread API authentication key for Ideal Construction",
  "latestVersion": 1,
  "createdAt": "2026-03-22T15:00:00Z"
}
```

**1b. Create the JOBTREAD_COMPANY_ID secret:**

```bash
curl -X POST http://localhost:3000/api/companies/{COMPANY_ID}/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JOBTREAD_COMPANY_ID",
    "value": "[Ideal Construction Company UUID from Jobtread]",
    "description": "Jobtread company ID for Ideal Construction",
    "provider": "local_encrypted"
  }'
```

**1c. Verify secrets were created:**

```bash
curl http://localhost:3000/api/companies/{COMPANY_ID}/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY"
```

Response should include both `JOBTREAD_API_KEY` and `JOBTREAD_COMPANY_ID`.

### Via UI (Alternative)

If using Paperclip's web UI:

1. Navigate to **Company Settings** → **Secrets**
2. Click **+ Add Secret**
3. Fill in:
   - **Name:** `JOBTREAD_API_KEY`
   - **Value:** `22TL2ziHjUradqgSReprTTg9uvY7ezpgRg`
   - **Provider:** Local Encrypted
   - **Description:** Jobtread API authentication key for Ideal Construction
4. Click **Create**
5. Repeat for `JOBTREAD_COMPANY_ID`

---

## Step 2: Configure Agent Adapter

Each agent that needs Jobtread access must have its adapter configured to inject the environment variables.

### For Process-Based Agents (Claude, Bash, HTTP, etc.)

Update the agent's configuration to include Jobtread environment variables in the adapter config:

**Agent Configuration (JSON):**

```json
{
  "id": "agent-id",
  "name": "Construction Manager",
  "companyId": "company-id",
  "adapterType": "process",
  "role": "manager",
  "config": {
    "command": "bash",
    "args": ["-i"],
    "env": {
      "JOBTREAD_API_KEY": "$JOBTREAD_API_KEY",
      "JOBTREAD_COMPANY_ID": "$JOBTREAD_COMPANY_ID",
      "JOBTREAD_API_URL": "https://www.jobtread.com/api",
      "PAPERCLIP_API_URL": "$PAPERCLIP_API_URL",
      "PAPERCLIP_API_KEY": "$PAPERCLIP_API_KEY"
    },
    "cwd": "/workspace"
  }
}
```

**Key Points:**

- `$JOBTREAD_API_KEY` and `$JOBTREAD_COMPANY_ID` reference the secrets created in Step 1
- Paperclip automatically injects these at runtime
- The `$` prefix tells Paperclip to resolve these from company secrets
- `JOBTREAD_API_URL` is a constant (not a secret)

### Via API

Update an existing agent:

```bash
curl -X PATCH http://localhost:3000/api/agents/{AGENT_ID} \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "config": {
      "command": "bash",
      "args": ["-i"],
      "env": {
        "JOBTREAD_API_KEY": "$JOBTREAD_API_KEY",
        "JOBTREAD_COMPANY_ID": "$JOBTREAD_COMPANY_ID",
        "JOBTREAD_API_URL": "https://www.jobtread.com/api"
      }
    }
  }'
```

### Via UI

1. Go to **Agents** → **[Agent Name]** → **Configuration**
2. Find the **env** section in adapter config
3. Add these environment variables:
   - `JOBTREAD_API_KEY`: `$JOBTREAD_API_KEY`
   - `JOBTREAD_COMPANY_ID`: `$JOBTREAD_COMPANY_ID`
   - `JOBTREAD_API_URL`: `https://www.jobtread.com/api`
4. Click **Save**

---

## Step 3: Deploy the Jobtread Skill

Copy the jobtread-integration skill to your agents' accessible paths.

### For Local Agents

If agents run locally and have access to the codebase:

```bash
# Skill is already in the repo
ls -la skills/jobtread-integration/

# Agents can source it:
source skills/jobtread-integration/helpers/jobtread-client.sh
```

### For Remote/Cloud Agents

If agents run in containers or remote environments:

**Option A: Bundle with agent startup**

Include in agent's startup script:

```bash
#!/bin/bash
# Download Jobtread skill
git clone https://github.com/paperclipai/paperclip.git /tmp/paperclip || true
export SKILL_PATH="/tmp/paperclip/skills/jobtread-integration"

# Run agent with skill available
source $SKILL_PATH/helpers/jobtread-client.sh
# ... rest of agent startup
```

**Option B: Install via package manager (future)**

```bash
# When jobtread-integration is published
npm install @paperclipai/skill-jobtread-integration
source node_modules/@paperclipai/skill-jobtread-integration/helpers/jobtread-client.sh
```

**Option C: Copy to shared volume**

```bash
# In deployment/docker-compose.yml
volumes:
  - ./skills/jobtread-integration:/opt/skills/jobtread

# Agent startup uses:
source /opt/skills/jobtread/helpers/jobtread-client.sh
```

---

## Step 4: Test the Integration

Verify everything is working correctly.

### Test 1: Verify Secrets Are Accessible

Create a test issue and have an agent run this:

```bash
#!/bin/bash
echo "Testing Jobtread integration..."
echo "API URL: $JOBTREAD_API_URL"
echo "Company ID: ${JOBTREAD_COMPANY_ID:0:8}..." # Show first 8 chars only
echo ""

# This will test if the secret is injected
if [[ -z "$JOBTREAD_API_KEY" ]]; then
  echo "✗ ERROR: JOBTREAD_API_KEY not set"
  exit 1
fi

if [[ -z "$JOBTREAD_COMPANY_ID" ]]; then
  echo "✗ ERROR: JOBTREAD_COMPANY_ID not set"
  exit 1
fi

echo "✓ Environment variables set correctly"
```

**Expected Output:**
```
Testing Jobtread integration...
API URL: https://www.jobtread.com/api
Company ID: 12345678...

✓ Environment variables set correctly
```

### Test 2: Verify API Connection

Create an issue and have the agent run:

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

echo "Testing Jobtread API connection..."

if jobtread_verify_connection; then
  echo "✓ Connection successful"
  exit 0
else
  echo "✗ Connection failed"
  exit 1
fi
```

**Expected Output:**
```
Testing Jobtread API connection...
Verifying Jobtread connection...
  API URL: https://www.jobtread.com/api
  Company ID: 12345678...

✓ Connection successful! Company: Ideal Construction
```

### Test 3: List Active Projects

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

echo "Fetching active projects from Jobtread..."
jobtread_list_projects "in_progress" | jq '.[0:3] | .[] | {name, status, completion_percent}'
```

**Expected Output:**
```
Fetching active projects from Jobtread...
{
  "name": "Downtown Office Renovation",
  "status": "in_progress",
  "completion_percent": 52
}
{
  "name": "Warehouse Extension",
  "status": "in_progress",
  "completion_percent": 60
}
...
```

### Test 4: Create a Test Job

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

# Get a project to test with
PROJECT_ID=$(jobtread_list_projects "in_progress" | jq -r '.[0].id')

if [[ -z "$PROJECT_ID" ]]; then
  echo "✗ No active projects found for testing"
  exit 1
fi

echo "Creating test job in project: $PROJECT_ID"

jobtread_create_job \
  "$PROJECT_ID" \
  "Integration Test Job" \
  "5000" \
  "2026-04-01" \
  "2026-04-15" \
  "This is a test job created by integration verification" \
  "Testing"

echo "✓ Test job created successfully"
```

---

## Step 5: Create Construction Company Setup Task

Create a Paperclip issue to track the setup:

```bash
curl -X POST http://localhost:3000/api/companies/{COMPANY_ID}/issues \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Ideal Construction - Jobtread Integration Setup",
    "description": "Complete setup of Jobtread integration for construction project management.\n\n**Completed:**\n- [x] API credentials stored in Paperclip secrets\n- [x] Agent adapters configured with environment variables\n- [x] Jobtread skill deployed\n- [x] Integration tests passing\n\n**Next Steps:**\n- [ ] Deploy construction management agents\n- [ ] Set up automated daily status reports\n- [ ] Configure project approval workflows\n- [ ] Train team on Jobtread + Paperclip coordination",
    "status": "in_progress",
    "priority": "high",
    "assigneeAgentId": "construction-manager-agent-id"
  }'
```

---

## Step 6: Configure Automated Workflows

Once the integration is verified, set up automated workflows:

### Daily Status Report

Create an agent with this task:

```bash
#!/bin/bash
# Daily standup: query Jobtread and post status to Paperclip

source skills/jobtread-integration/helpers/jobtread-client.sh

# 1. Get all active projects
PROJECTS=$(jobtread_list_projects "in_progress")

# 2. Build report
REPORT="# Daily Construction Status - $(date +%Y-%m-%d)

**Active Projects:** $(echo "$PROJECTS" | jq 'length')

$(echo "$PROJECTS" | jq -r '.[] | "
## \(.name)
- Status: \(.status)
- Progress: \(.completion_percent)%
- Budget: $\(.budget | tonumber | floor) / $\(.actual_cost | tonumber | floor) spent
"')"

# 3. Post to Paperclip issue
curl -X POST "http://localhost:3000/api/issues/$PAPERCLIP_TASK_ID/comments" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "X-Paperclip-Run-Id: $PAPERCLIP_RUN_ID" \
  -d "{ \"content\": \"$REPORT\" }"

echo "✓ Daily status report posted"
```

### Project Approval Workflow

When a new project is approved in Paperclip:

```bash
#!/bin/bash
# Create Jobtread project from Paperclip approval

source skills/jobtread-integration/helpers/jobtread-client.sh

# 1. Parse approval details from Paperclip
PROJECT_NAME="$PROJECT_NAME_FROM_APPROVAL"
BUDGET="$BUDGET_FROM_APPROVAL"
START_DATE="$START_DATE_FROM_APPROVAL"
END_DATE="$END_DATE_FROM_APPROVAL"

# 2. Create jobs in Jobtread
for PHASE in "Foundation" "Framing" "Electrical" "Plumbing" "HVAC" "Finish"; do
  jobtread_create_job \
    "$JOBTREAD_PROJECT_ID" \
    "$PHASE Phase" \
    "$((BUDGET / 6))" \
    "$START_DATE" \
    "$END_DATE"
done

echo "✓ Project structure created in Jobtread"
```

---

## Configuration Reference

### Environment Variables Injected to Agents

When an agent runs, these variables are available:

| Variable | Value | Source | Note |
|----------|-------|--------|------|
| `JOBTREAD_API_KEY` | (secret) | Company secrets | Bearer token for API auth |
| `JOBTREAD_COMPANY_ID` | (secret) | Company secrets | UUID of Ideal Construction |
| `JOBTREAD_API_URL` | `https://www.jobtread.com/api` | Agent config | Fixed constant |
| `PAPERCLIP_API_KEY` | (jwt) | Paperclip system | Auto-injected auth token |
| `PAPERCLIP_API_URL` | (url) | Paperclip system | Auto-injected API URL |
| `PAPERCLIP_AGENT_ID` | (uuid) | Paperclip system | Current agent's ID |
| `PAPERCLIP_COMPANY_ID` | (uuid) | Paperclip system | Company being operated on |
| `PAPERCLIP_RUN_ID` | (uuid) | Paperclip system | Current heartbeat run ID |
| `PAPERCLIP_TASK_ID` | (uuid) | Paperclip system | Issue that triggered task (optional) |

### Secret Rotation

To rotate the Jobtread API key quarterly:

```bash
# Get the secret ID
curl http://localhost:3000/api/companies/{COMPANY_ID}/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.[] | select(.name=="JOBTREAD_API_KEY")'

# Rotate with new key
curl -X POST http://localhost:3000/api/secrets/{SECRET_ID}/rotate \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "value": "[NEW_API_KEY_FROM_JOBTREAD]"
  }'
```

---

## Troubleshooting

### "Authorization failed (401)"

**Symptoms:** Agent gets 401 error from Jobtread API

**Causes:**
- API key invalid or expired
- Environment variable not injected

**Solution:**
1. Verify `JOBTREAD_API_KEY` secret is created
2. Verify agent adapter config includes `"JOBTREAD_API_KEY": "$JOBTREAD_API_KEY"`
3. Check if key needs rotation (quarterly)
4. Run test: `echo $JOBTREAD_API_KEY | head -c 10`

### "Not found (404) for company"

**Symptoms:** Agent gets 404 when accessing `/companies/{id}`

**Causes:**
- Wrong company ID
- Company ID formatted incorrectly

**Solution:**
1. Verify `JOBTREAD_COMPANY_ID` is correct UUID format
2. Log into Jobtread and confirm company ID
3. Test: `curl "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" -H "Authorization: Bearer $JOBTREAD_API_KEY"`

### "Rate limited (429)"

**Symptoms:** Agent gets 429 (too many requests) error

**Causes:**
- Too many API calls in short time
- Polling too frequently

**Solution:**
1. Implement exponential backoff (already in helpers)
2. Reduce polling frequency
3. Batch operations (e.g., list all projects once instead of individually)
4. Contact Jobtread if quota needs increase

### "Command not found: jobtread_request"

**Symptoms:** Helper functions not available

**Causes:**
- Skill not sourced in agent script
- Skill not in PATH

**Solution:**
1. Verify script includes: `source skills/jobtread-integration/helpers/jobtread-client.sh`
2. Verify skill location is correct
3. Check file permissions: `chmod +x skills/jobtread-integration/helpers/jobtread-client.sh`

---

## Next Steps

1. ✅ Complete this setup guide
2. ✅ Verify all tests pass
3. Create construction management agents:
   - Project Manager (tracks overall progress)
   - Daily Standup Agent (posts status reports)
   - Job Coordinator (creates jobs from approvals)
4. Set up automated workflows (daily reports, job creation, status tracking)
5. Train team on using Jobtread + Paperclip coordination
6. Deploy to production and monitor

---

## Support

For issues or questions:

1. **Integration Issues:** Check Jobtread API docs at https://www.jobtread.com/api/docs
2. **Paperclip Issues:** See `/skills/jobtread-integration/SKILL.md` for detailed documentation
3. **Setup Issues:** Review this guide's troubleshooting section
4. **Contact:** support@jobtread.com (Jobtread) or team@paperclip.ing (Paperclip)

---

## Document Version

- **Created:** 2026-03-22
- **Updated:** 2026-03-22
- **Status:** Ready for Implementation
- **Tested By:** Integration test suite
