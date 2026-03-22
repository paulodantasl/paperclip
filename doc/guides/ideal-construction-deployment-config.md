---
title: Ideal Construction - Jobtread Integration Deployment Configuration
description: Final deployment configuration with actual API credentials and Company ID
---

# Ideal Construction - Jobtread Integration Deployment Configuration

**Status:** ✅ READY TO DEPLOY
**Company ID:** `22P6bRn5p6Pn`
**API Key:** `22TL2ziHjUradqgSReprTTg9uvY7ezpgRg`
**Date:** 2026-03-22

---

## Quick Start - Copy & Paste Commands

### 1. Create JOBTREAD_API_KEY Secret

```bash
curl -X POST http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JOBTREAD_API_KEY",
    "value": "22TL2ziHjUradqgSReprTTg9uvY7ezpgRg",
    "description": "Jobtread API authentication key for Ideal Construction",
    "provider": "local_encrypted"
  }'
```

### 2. Create JOBTREAD_COMPANY_ID Secret

```bash
curl -X POST http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "JOBTREAD_COMPANY_ID",
    "value": "22P6bRn5p6Pn",
    "description": "Jobtread company ID for Ideal Construction",
    "provider": "local_encrypted"
  }'
```

### 3. Verify Secrets Created

```bash
curl http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.[] | {name, provider, description}'
```

Expected output:
```json
{
  "name": "JOBTREAD_API_KEY",
  "provider": "local_encrypted",
  "description": "Jobtread API authentication key for Ideal Construction"
}
{
  "name": "JOBTREAD_COMPANY_ID",
  "provider": "local_encrypted",
  "description": "Jobtread company ID for Ideal Construction"
}
```

---

## Agent Configuration Template

Use this configuration for each agent that needs Jobtread access:

```json
{
  "command": "bash",
  "args": ["-i"],
  "cwd": "/workspace",
  "env": {
    "JOBTREAD_API_KEY": "$JOBTREAD_API_KEY",
    "JOBTREAD_COMPANY_ID": "$JOBTREAD_COMPANY_ID",
    "JOBTREAD_API_URL": "https://www.jobtread.com/api",
    "PAPERCLIP_API_URL": "$PAPERCLIP_API_URL",
    "PAPERCLIP_API_KEY": "$PAPERCLIP_API_KEY"
  }
}
```

### Update Agent Adapter Config via API

For each construction agent, run:

```bash
curl -X PATCH http://localhost:3000/api/agents/{AGENT_ID} \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "config": {
      "command": "bash",
      "args": ["-i"],
      "cwd": "/workspace",
      "env": {
        "JOBTREAD_API_KEY": "$JOBTREAD_API_KEY",
        "JOBTREAD_COMPANY_ID": "$JOBTREAD_COMPANY_ID",
        "JOBTREAD_API_URL": "https://www.jobtread.com/api"
      }
    }
  }'
```

---

## Verification Tests (Run These First)

After configuration, run these tests to verify everything works:

### Test 1: Environment Variables

Create an issue and run:
```bash
#!/bin/bash
echo "Testing environment variables..."
if [[ -z "$JOBTREAD_API_KEY" ]]; then echo "✗ JOBTREAD_API_KEY not set"; exit 1; fi
if [[ -z "$JOBTREAD_COMPANY_ID" ]]; then echo "✗ JOBTREAD_COMPANY_ID not set"; exit 1; fi
echo "✓ All environment variables set"
echo "Company ID: $JOBTREAD_COMPANY_ID"
```

### Test 2: API Connection

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh
echo "Testing Jobtread API connection..."
jobtread_verify_connection
```

Expected:
```
Verifying Jobtread connection...
  API URL: https://www.jobtread.com/api
  Company ID: 22P6bRn5p6Pn...

✓ Connection successful! Company: Ideal Construction
```

### Test 3: List Projects

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh
echo "Fetching active projects..."
jobtread_list_projects "in_progress" | jq '.[] | {name, status, completion_percent}' | head -20
```

### Test 4: Get Project Details

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

# Get first project
PROJECT_ID=$(jobtread_list_projects "in_progress" | jq -r '.[0].id')
echo "Getting details for project: $PROJECT_ID"
jobtread_get_project "$PROJECT_ID" | jq '{name, status, budget, actual_cost, completion_percent}'
```

---

## Deployment Checklist

### Pre-Deployment ✓
- [x] API Key: `22TL2ziHjUradqgSReprTTg9uvY7ezpgRg`
- [x] Company ID: `22P6bRn5p6Pn`
- [x] Jobtread skill: Committed to repo
- [x] Setup guide: Completed
- [x] Helper functions: Ready to use

### Deployment Phase 1: Secrets (Do This First)
- [ ] Run command 1: Create JOBTREAD_API_KEY secret
- [ ] Run command 2: Create JOBTREAD_COMPANY_ID secret
- [ ] Run command 3: Verify secrets created
- [ ] Copy secret IDs for record

### Deployment Phase 2: Configure Agents
- [ ] Identify all agents needing Jobtread access
- [ ] Update agent 1 adapter config
- [ ] Update agent 2 adapter config
- [ ] Update agent N adapter config

### Deployment Phase 3: Verify
- [ ] Run Test 1: Environment variables
- [ ] Run Test 2: API connection
- [ ] Run Test 3: List projects
- [ ] Run Test 4: Get project details

### Deployment Phase 4: Activate
- [ ] Create construction manager agent (or assign existing)
- [ ] Create daily standup agent
- [ ] Create job coordinator agent
- [ ] Configure automated workflows

### Post-Deployment
- [ ] Monitor API usage (first 7 days)
- [ ] Gather feedback from agents/team
- [ ] Iterate on workflows
- [ ] Schedule quarterly API key rotation

---

## Integration at a Glance

```
Ideal Construction in Jobtread
         ↓
API Key: 22TL2ziHjUradqgSReprTTg9uvY7ezpgRg
Company ID: 22P6bRn5p6Pn
API URL: https://www.jobtread.com/api
         ↓
Stored as Paperclip Secrets
JOBTREAD_API_KEY (encrypted)
JOBTREAD_COMPANY_ID (encrypted)
         ↓
Injected into Agent Environment
         ↓
Available to Skills
skills/jobtread-integration/helpers/jobtread-client.sh
         ↓
Agents Can Now
- Query projects, jobs, tasks
- Create jobs from approvals
- Update progress and costs
- Generate daily reports
- Coordinate with Paperclip
```

---

## Key Files to Reference During Deployment

| File | Purpose | When to Use |
|------|---------|------------|
| `skills/jobtread-integration/SKILL.md` | Complete agent guide | Agent reference during workflows |
| `doc/guides/construction-business-setup.md` | Setup instructions | During initial configuration |
| `skills/jobtread-integration/references/api-reference.md` | API documentation | When debugging API calls |
| `skills/jobtread-integration/references/examples.md` | Worked examples | When creating workflows |
| `skills/jobtread-integration/helpers/jobtread-client.sh` | Helper functions | Source this in agent scripts |

---

## Environment Variables Reference

Once secrets are created, agents will receive:

```bash
# From Paperclip secrets
export JOBTREAD_API_KEY="22TL2ziHjUradqgSReprTTg9uvY7ezpgRg"
export JOBTREAD_COMPANY_ID="22P6bRn5p6Pn"

# From agent config (fixed)
export JOBTREAD_API_URL="https://www.jobtread.com/api"

# Auto-injected by Paperclip
export PAPERCLIP_API_KEY="<jwt-token>"
export PAPERCLIP_API_URL="<server-url>"
export PAPERCLIP_AGENT_ID="<agent-uuid>"
export PAPERCLIP_COMPANY_ID="22P6bRn5p6Pn"
export PAPERCLIP_RUN_ID="<run-uuid>"
```

---

## Workflow Examples Ready to Deploy

### 1. Daily Standup (Recommended Start)
**Trigger:** 8 AM daily
**Action:** Query all in-progress projects
**Output:** Paperclip comment with status report
**Script:** See `examples.md` Example 2 and Example 8

### 2. Project Approval Flow
**Trigger:** Project approved in Paperclip
**Action:** Create corresponding Jobtread project structure
**Output:** Jobs created with budget and schedule
**Script:** See `examples.md` Example 5

### 3. Task Progress Tracking
**Trigger:** Crew updates in Jobtread
**Action:** Poll and update Paperclip
**Output:** Paperclip reflects current status
**Script:** See `examples.md` Example 6 and 7

### 4. Budget Variance Alert
**Trigger:** Daily polling
**Action:** Check for over-budget jobs
**Output:** Alert on Paperclip issue
**Script:** Custom - use `jobtread_project_budget_summary()`

---

## What Happens After Deployment

### Day 1
- ✓ Secrets created and verified
- ✓ Agents configured with environment variables
- ✓ 4 verification tests passing

### Day 1-7
- ✓ Agents running basic queries (list projects)
- ✓ Manual testing of workflows
- ✓ Feedback from team on setup

### Week 2+
- ✓ Daily standup reports running automatically
- ✓ New projects being coordinated through both systems
- ✓ Budget tracking and alerts active
- ✓ Full construction workflow automation

### Month 1
- ✓ All construction agents deployed
- ✓ All automated workflows active
- ✓ Team trained and comfortable
- ✓ Ready for quarterly key rotation

---

## Support During Deployment

If you encounter issues:

1. **Connection errors:** See `construction-business-setup.md` Troubleshooting section
2. **API errors:** See `api-reference.md` HTTP status codes section
3. **Environment variables:** See `SKILL.md` Authentication section
4. **Workflow issues:** See `examples.md` for worked examples

---

## Summary

Everything is ready. Execute these steps in order:

1. **Create secrets** (Commands 1 & 2 above)
2. **Verify secrets** (Command 3)
3. **Configure agents** (Use template above)
4. **Run 4 tests** (Tests listed above)
5. **Deploy agents** (See workflow examples)
6. **Monitor & iterate** (Track issues, optimize workflows)

**Ideal Construction is ready to run construction operations through Paperclip + Jobtread!** 🚀

---

## Configuration Record

```
Company: Ideal Construction
Paperclip Company ID: 22P6bRn5p6Pn
Jobtread Company ID: 22P6bRn5p6Pn
API Key: 22TL2ziHjUradqgSReprTTg9uvY7ezpgRg
API URL: https://www.jobtread.com/api
Integration Status: ✅ Ready to Deploy
Deployment Date: [TODAY]
Secret Creation Date: [DATE SECRETS CREATED]
Last Key Rotation: [TO BE SET]
Next Key Rotation Due: [QUARTERLY FROM CREATION]
```

---

**Ready to execute deployment? Run the commands in "Quick Start" section above!**
