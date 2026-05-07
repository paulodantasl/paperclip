---
title: Ideal Construction - Mac Mini Setup Instructions
description: Step-by-step guide for setting up Jobtread integration on Mac Mini
---

# Ideal Construction - Jobtread Integration Setup for Mac Mini

Complete guide for running the integration setup on your Mac Mini locally.

---

## Prerequisites Check

Before starting, verify you have:

```bash
# Check if Paperclip is running
curl -s http://localhost:3000 && echo "✓ Paperclip running" || echo "✗ Paperclip not running"

# Check if you have curl
which curl && echo "✓ curl available" || echo "✗ curl not found"

# Check if you have jq (for pretty-printing JSON)
which jq && echo "✓ jq available" || echo "⚠ jq not found (optional)"

# Check bash version
bash --version | head -1
```

If Paperclip isn't running, start it first:
```bash
# In the paperclip directory
cd /path/to/paperclip
pnpm dev:server
```

---

## Step 1: Prepare Your Environment

Open Terminal on Mac Mini:

```bash
# Navigate to your Paperclip directory
cd /path/to/paperclip

# Set up environment variables (replace with your actual values)
export PAPERCLIP_API_KEY="your-api-key-here"  # Get this from Paperclip settings
export PAPERCLIP_API_URL="http://localhost:3000"

# Verify they're set
echo "API URL: $PAPERCLIP_API_URL"
echo "API Key: ${PAPERCLIP_API_KEY:0:10}..."
```

### How to Get Your API Key

1. Go to `http://localhost:3000` in your browser
2. Click your **Account/Settings**
3. Find **API Keys** section
4. Copy your API key or create a new one
5. Paste into terminal: `export PAPERCLIP_API_KEY="your-key"`

---

## Step 2: Create Secrets (Copy-Paste These Commands)

Run these one at a time in your Terminal:

### Command 1: Create JOBTREAD_API_KEY Secret

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

**Expected Output:**
```json
{
  "id": "some-uuid",
  "companyId": "22P6bRn5p6Pn",
  "name": "JOBTREAD_API_KEY",
  "provider": "local_encrypted",
  "latestVersion": 1,
  ...
}
```

✅ If you see JSON response with `"name": "JOBTREAD_API_KEY"`, it worked!

---

### Command 2: Create JOBTREAD_COMPANY_ID Secret

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

**Expected Output:**
Similar JSON response with `"name": "JOBTREAD_COMPANY_ID"`

✅ If you see JSON response, it worked!

---

### Command 3: Verify Both Secrets

```bash
curl http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.[] | {name, provider}'
```

**Expected Output:**
```json
{
  "name": "JOBTREAD_API_KEY",
  "provider": "local_encrypted"
}
{
  "name": "JOBTREAD_COMPANY_ID",
  "provider": "local_encrypted"
}
```

✅ If you see both secrets listed, secrets are created successfully!

---

## Step 3: Configure Your Agents

In your Paperclip UI or via API:

### Via Paperclip UI (Easiest)

1. Go to `http://localhost:3000` → **Agents**
2. Click on each agent (e.g., "Construction Manager")
3. Find **Configuration** or **Adapter Config**
4. Add to the `env` section:
   ```json
   "JOBTREAD_API_KEY": "$JOBTREAD_API_KEY",
   "JOBTREAD_COMPANY_ID": "$JOBTREAD_COMPANY_ID",
   "JOBTREAD_API_URL": "https://www.jobtread.com/api"
   ```
5. Click **Save**
6. Repeat for each agent

### Via API (If Preferred)

First, get your agent ID:
```bash
curl http://localhost:3000/api/companies/22P6bRn5p6Pn/agents \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.[] | {id, name}'
```

Then update each agent:
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

---

## Step 4: Run Verification Tests

Create a test issue in Paperclip and have an agent run these tests:

### Test 1: Verify Environment Variables

Create a new issue or task and paste this:

```bash
#!/bin/bash
echo "Testing environment variables..."

if [[ -z "$JOBTREAD_API_KEY" ]]; then
  echo "✗ JOBTREAD_API_KEY not set"
  exit 1
fi

if [[ -z "$JOBTREAD_COMPANY_ID" ]]; then
  echo "✗ JOBTREAD_COMPANY_ID not set"
  exit 1
fi

echo "✓ All environment variables set"
echo "Company ID: $JOBTREAD_COMPANY_ID"
echo "API Key available: ${JOBTREAD_API_KEY:0:10}..."
```

✅ **Expected Output:**
```
Testing environment variables...
✓ All environment variables set
Company ID: 22P6bRn5p6Pn
API Key available: 22TL2ziHj...
```

---

### Test 2: Verify API Connection

```bash
#!/bin/bash
echo "Testing Jobtread API connection..."

# Test the API connection
RESPONSE=$(curl -s "$JOBTREAD_API_URL/companies/$JOBTREAD_COMPANY_ID" \
  -H "Authorization: Bearer $JOBTREAD_API_KEY")

if echo "$RESPONSE" | grep -q '"id"'; then
  echo "✓ Connection successful!"
  echo "$RESPONSE" | jq '.name'
else
  echo "✗ Connection failed"
  echo "$RESPONSE"
fi
```

✅ **Expected Output:**
```
Testing Jobtread API connection...
✓ Connection successful!
"Ideal Construction"
```

---

### Test 3: List Active Projects

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

echo "Fetching active projects..."
jobtread_list_projects "in_progress" | jq '.[] | {name, status, completion_percent}' | head -30
```

✅ **Expected Output:**
```
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

---

### Test 4: Verify Helper Functions

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

echo "Testing helper functions..."

# This should output company details
if jobtread_verify_connection > /dev/null 2>&1; then
  echo "✓ Helper functions working"
  jobtread_verify_connection
else
  echo "✗ Helper functions failed"
fi
```

✅ **Expected Output:**
```
Testing helper functions...
✓ Helper functions working
Verifying Jobtread connection...
  API URL: https://www.jobtread.com/api
  Company ID: 22P6bRn5p6Pn...

✓ Connection successful! Company: Ideal Construction
```

---

## Step 5: Run Your First Automation

Once tests pass, try this workflow:

### Daily Standup Report

Create an issue, paste this, and have an agent run it:

```bash
#!/bin/bash
source skills/jobtread-integration/helpers/jobtread-client.sh

echo "=== Daily Construction Status ==="
echo "Date: $(date)"
echo ""

# Get all active projects
PROJECTS=$(jobtread_list_projects "in_progress")
COUNT=$(echo "$PROJECTS" | jq 'length')

echo "**Active Projects:** $COUNT"
echo ""

# List each project with summary
echo "$PROJECTS" | jq -r '.[] | "
### \(.name)
- Status: \(.status)
- Progress: \(.completion_percent)%
- Budget: $\(.budget | tonumber | floor)
- Spent: $\(.actual_cost | tonumber | floor)
- Variance: $\((.actual_cost - .budget) | tonumber | floor)
"'

echo ""
echo "Generated: $(date)"
```

✅ This will print a formatted daily report showing all active projects!

---

## Troubleshooting on Mac Mini

### Problem: "Connection refused" on localhost

**Solution:**
```bash
# Check if Paperclip is running
ps aux | grep paperclip

# If not running, start it:
cd /path/to/paperclip
pnpm dev:server
```

### Problem: "curl: command not found"

**Solution:**
```bash
# curl comes with macOS, check if it's available:
which curl

# If not found, install Xcode command line tools:
xcode-select --install
```

### Problem: "Authorization failed" (401 error)

**Solution:**
```bash
# Check your API key is set correctly
echo $PAPERCLIP_API_KEY

# Make sure it's not empty (should show the key)
# If empty, set it again:
export PAPERCLIP_API_KEY="your-actual-key"
```

### Problem: "jq: command not found"

**Solution (Optional):**
```bash
# jq is optional for pretty-printing
# Install via Homebrew if you want it:
brew install jq

# Or use without jq (output will be compact)
curl ... | python -m json.tool
```

---

## Quick Reference - All Commands

### One-Time Setup
```bash
# 1. Set environment variables
export PAPERCLIP_API_KEY="your-api-key"
export PAPERCLIP_API_URL="http://localhost:3000"

# 2. Create secrets (run both)
curl -X POST http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "JOBTREAD_API_KEY", "value": "22TL2ziHjUradqgSReprTTg9uvY7ezpgRg", "description": "Jobtread API authentication key for Ideal Construction", "provider": "local_encrypted"}'

curl -X POST http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "JOBTREAD_COMPANY_ID", "value": "22P6bRn5p6Pn", "description": "Jobtread company ID for Ideal Construction", "provider": "local_encrypted"}'

# 3. Verify secrets created
curl http://localhost:3000/api/companies/22P6bRn5p6Pn/secrets \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.[] | {name, provider}'
```

### For Each Agent
```bash
# Add to agent's env configuration:
JOBTREAD_API_KEY=$JOBTREAD_API_KEY
JOBTREAD_COMPANY_ID=22P6bRn5p6Pn
JOBTREAD_API_URL=https://www.jobtread.com/api
```

---

## Next Steps

1. ✅ Run the 3 secret creation commands (Step 2)
2. ✅ Configure your agents (Step 3)
3. ✅ Run the 4 verification tests (Step 4)
4. ✅ Try the daily standup automation (Step 5)
5. Deploy full workflows from `doc/guides/ideal-construction-deployment-config.md`

---

## Need Help?

- **Secrets not showing?** Re-run Command 3 to verify
- **API connection failing?** Check JOBTREAD_API_KEY is correct
- **Tests timing out?** Make sure Paperclip server is running on localhost:3000
- **Need documentation?** See `skills/jobtread-integration/SKILL.md`

---

**Ready? Start with Step 1 above!** 🚀
