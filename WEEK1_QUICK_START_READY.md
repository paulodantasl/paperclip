# Your Week 1 Setup - READY TO GO ✅

**Everything Customized to Your Business:**
- Your phases: Site Prep → Foundation → Framing → MEP → Finish → Inspection → Closeout
- Templates ready with these phases
- Your API key and Google Drive configured

---

## What the Automation Will Look Like in Action

### Example: New Project Approved

**In Job Thread:** You create a project
```
Project Name: Downtown Commercial Renovation
Client: ABC Corporation
Start Date: April 1, 2026
End Date: July 13, 2026 (73 days - fits your phases)
Estimated Budget: $150,000
Status: APPROVED ✓
```

### ⏱️ Automatically (within seconds):

**Paperclip creates a workflow:**
```
🔔 NEW ISSUE CREATED: "Project Startup - Downtown Commercial Renovation"

├─ Status: NEW
├─ Assigned To: YOU
├─ Due Date: March 31, 2026 (1 day before start)
├─ Priority: HIGH
│
├─ SUBTASK 1️⃣ : "Create Schedule (Gantt CSV)"
│   ├─ Assigned To: YOU
│   ├─ Status: Pending
│   └─ Attachment: SCHEDULE_TEMPLATE.csv (PRE-FILLED with your phases & dates):
│       ├─ Site Prep: April 1 - 5
│       ├─ Foundation: April 6 - 19
│       ├─ Framing: April 20 - May 10
│       ├─ MEP: May 11 - 24
│       ├─ Finish: May 25 - June 7
│       ├─ Inspection: June 8 - 10
│       └─ Closeout: June 11 - 12
│
├─ SUBTASK 2️⃣ : "Create Budget Breakdown"
│   ├─ Assigned To: YOU
│   ├─ Status: Pending
│   └─ Attachment: BUDGET_TEMPLATE.xlsx (PRE-FILLED with $150,000):
│       ├─ Labor Costs: ~$90,000 (60%)
│       ├─ Material Costs: ~$52,500 (35%)
│       ├─ Other Costs: ~$7,500 (5% contingency)
│       └─ TOTAL: $150,000
│
├─ SUBTASK 3️⃣ : "Review & Approve Documents"
│   ├─ Assigned To: YOU
│   ├─ Status: Pending
│   └─ Checklist:
│       ☐ Schedule is realistic
│       ☐ Budget is accurate
│       ☐ All documents ready for team
│
└─ SUBTASK 4️⃣ : "Send Team Notification"
    ├─ Assigned To: AUTOMATED
    ├─ Status: Waiting for approval
    └─ Will trigger when you approve #3
```

### ⏱️ What You Do (10-15 minutes):

1. **Review Schedule** - Does April 1 start date work? Are 73 days realistic?
   - Edit if needed, then click ✓ "Mark Complete"

2. **Review Budget** - Is $90k labor / $52.5k materials reasonable?
   - Adjust if needed, then click ✓ "Mark Complete"

3. **Approve Project** - Click ✓ "Approved" on the Review subtask

### ⏱️ Automatically Again:

**Everything happens at once:**

1. **Google Drive** creates folder structure:
   ```
   /Projects/Downtown Commercial Renovation/
   ├─ 01_Contracts/
   ├─ 02_Schedules/
   │  └─ Project_Schedule.csv (uploaded)
   ├─ 03_Budget/
   │  └─ Budget_Breakdown.xlsx (uploaded)
   ├─ 04_Documentation/
   ├─ 05_Communications/
   └─ 06_Field_Docs/
   ```

2. **Email sent to your team:**
   ```
   Subject: 🚀 NEW PROJECT READY TO START: Downtown Commercial Renovation

   PROJECT DETAILS:
   📋 Project: Downtown Commercial Renovation
   👤 Client: ABC Corporation
   📅 Start: April 1, 2026
   🏁 End: July 13, 2026
   💰 Budget: $150,000

   📂 Google Drive: [Link to folder]
   📊 Schedule: Download from 02_Schedules/
   💵 Budget: Download from 03_Budget/

   ✅ All documents are ready. You can start work!

   Questions? Reply to this email or check Job Thread.
   ```

3. **Job Thread updated:**
   ```
   Project Status: "STARTUP COMPLETE - Ready for Execution"
   Note: "All schedules and budgets approved. Team notified."
   ```

---

## Your 45-Minute Setup Process

### (Copy this and follow along)

**TIME: 45 minutes | DIFFICULTY: Copy & Paste Only**

---

### ✅ STEP 1: Login to Paperclip (2 min)

1. Open Paperclip in your browser
2. Log in with your account
3. You should see the home dashboard

---

### ✅ STEP 2: Connect to Job Thread (5 min)

**Location:** Settings → Integrations

1. Click **Settings** (gear icon, usually bottom left)
2. Find **"Integrations"** or **"Connected Apps"**
3. Look for **"Job Thread"** tile/option
4. Click **"Connect"** or **"Setup"**
5. **Paste your API key:**
   ```
   22TL2ziHjUradqgSReprTTg9uvY7ezpgRg
   ```
6. Click **"Verify"** or **"Test Connection"**
7. Wait for ✅ **"Connected Successfully"** message
8. Click **"Next"** or **"Continue"**

**Next part - Setup the trigger:**

9. Find **"Webhooks"** or **"Automation"** section
10. Click **"Add Webhook"** or **"New Trigger"**
11. Fill in:
    - **Event:** "Project Created" or "New Project"
    - **Condition:** "Status = Approved"
    - **Action:** "Create Paperclip Issue from Template"
    - **Template:** "Project Startup" (we'll create this next)
12. Click **"Save"** or **"Activate"**

**If you can't find webhooks:** No problem! Just skip this - you'll manually create the Paperclip issue (takes 2 minutes per project).

---

### ✅ STEP 3: Connect to Google Drive (5 min)

**Location:** Settings → Integrations

1. Back in **Integrations**, find **"Google Drive"** tile
2. Click **"Connect"** or **"Setup"**
3. A Google login window appears
4. **Log in** with the Google account that owns your Projects folder
5. Click **"Allow"** when asked for permission
6. Back in Paperclip, find **"Root Folder Path"** field
7. Enter: `/Projects`
8. Click **"Test"** (should see ✅ "Folder found")
9. Look for **"Auto-Create Folders"** or **"Folder Template"** setting
10. Enable it and select these subfolders:
    ```
    ☑ 01_Contracts
    ☑ 02_Schedules
    ☑ 03_Budget
    ☑ 04_Documentation
    ☑ 05_Communications
    ☑ 06_Field_Docs
    ```
11. Click **"Save"**

---

### ✅ STEP 4: Setup Email Notifications (5 min)

**Location:** Settings → Notifications

1. Go to **Settings** → **"Notifications"** or **"Email"**
2. Find **"Add Recipients"** or **"Team Emails"**
3. Enter your team's email addresses:
   ```
   your-email@gmail.com
   team-member-1@gmail.com
   team-member-2@gmail.com
   ```
4. Find the **"Project Ready"** email template
5. Keep the default or customize the message
6. Make sure it includes:
   - Project name
   - Client name
   - Start date
   - Budget
   - Google Drive link
7. Click **"Save"**

---

### ✅ STEP 5: Create the Workflow Template (20 min)

**Location:** Settings → Templates OR Workflows

This is the "blueprint" Paperclip uses every time a new project starts.

#### 5A: Create Parent Issue Template

1. Go to **Settings** → **"Templates"** or **"Workflows"**
2. Click **"New Template"** or **"Create Workflow"**
3. **Name:** `Project Startup`
4. **Description:** `Automated workflow for new project startup and documentation`
5. **Set these fields:**
   - Assignee: YOU (your email)
   - Priority: HIGH
   - Due Date: [Auto-calculate as: Project Start Date - 1 day]
6. Click **"Save"** or **"Next"**

#### 5B: Add Subtask #1 - Schedule

7. Click **"Add Subtask"** or **"Add Child Issue"**
8. **Title:** `Create Schedule (Gantt CSV)`
9. **Description:**
   ```
   Generate schedule CSV for Job Thread import.
   Your project phases: Site Prep → Foundation → Framing → MEP → Finish → Inspection → Closeout
   ```
10. **Assignee:** YOU
11. **Due Date:** Project Start Date - 2 days
12. **Add attachment/template:**
    - Upload file: `SCHEDULE_TEMPLATE_BLANK.csv` (I've created this for you)
    - Mark as: "Template to be filled"
13. **Auto-fill fields:**
    - Project Name: [From Job Thread]
    - Start Date: [From Job Thread]
    - Phases: Site Prep (5 days), Foundation (14 days), Framing (21 days), MEP (14 days), Finish (14 days), Inspection (3 days), Closeout (2 days)
14. Click **"Save Subtask"**

#### 5C: Add Subtask #2 - Budget

15. Click **"Add Subtask"** again
16. **Title:** `Create Budget Breakdown`
17. **Description:**
    ```
    Generate budget with labor (60%) and material (35%) breakdown.
    Auto-fill from Job Thread estimate.
    ```
18. **Assignee:** YOU
19. **Due Date:** Project Start Date - 2 days
20. **Add attachment/template:**
    - Upload file: `BUDGET_TEMPLATE_BLANK.xlsx` (I've created this for you)
    - Mark as: "Template to be filled"
21. **Auto-fill fields:**
    - Project Name: [From Job Thread]
    - Estimate Amount: [From Job Thread]
    - Labor %: 60%
    - Material %: 35%
22. Click **"Save Subtask"**

#### 5D: Add Subtask #3 - Review

23. Click **"Add Subtask"** again
24. **Title:** `Review & Approve Documents`
25. **Description:**
    ```
    Review schedule and budget.
    Checklist:
    □ Schedule is realistic for project scope
    □ Budget is accurate and complete
    □ All documents ready for team
    ```
26. **Assignee:** YOU
27. **Approval Required:** YES (toggle on)
28. **Status:** Pending → Approved
29. Click **"Save Subtask"**

#### 5E: Add Subtask #4 - Notification

30. Click **"Add Subtask"** one more time
31. **Title:** `Send Team Notification`
32. **Description:** `Automatically send project ready email to team`
33. **Assignee:** AUTOMATED (or "System")
34. **Trigger:** When parent issue status = "Approved"
35. **Action:** Send email notification with:
    - Project name, client, start date, budget
    - Google Drive folder link
    - Job Thread project link
36. Click **"Save Subtask"**

#### 5F: Save Template

37. Review all your subtasks (you should have 4)
38. Click **"Save Template"** or **"Publish Workflow"** (at the top)
39. Confirm: ✅ "Template saved successfully"

---

### ✅ STEP 6 (OPTIONAL): Test the Workflow (10 min)

This is a good idea to make sure everything works!

#### Option A: Test in Job Thread

1. Open Job Thread
2. Create a TEST project:
   ```
   Project Name: TEST - Sample Renovation
   Client: Test Client
   Start Date: April 5, 2026
   End Date: June 16, 2026 (73 days)
   Budget: $100,000
   Status: APPROVED
   ```
3. **Wait 30 seconds** (let webhook trigger)
4. Go back to Paperclip
5. You should see a new issue: `"Project Startup - TEST - Sample Renovation"`
6. Verify:
   - ✅ All 4 subtasks appeared
   - ✅ Schedule template pre-filled with dates
   - ✅ Budget template pre-filled with $100,000

7. Check Google Drive:
   - Open `/Projects/TEST - Sample Renovation/`
   - ✅ All 6 folders created (01_Contracts, 02_Schedules, 03_Budget, etc.)

8. **Delete the test project** (in both Job Thread and Google Drive) when done

#### Option B: Manual Test (if webhooks aren't working)

1. In Paperclip, click **"New Issue"**
2. Select template: **"Project Startup"**
3. Fill in test project details manually
4. Should get the same result as Option A

---

## Completion Checklist

**Mark these off as you complete:**

- [ ] Step 1: Logged into Paperclip ✓
- [ ] Step 2: Connected Job Thread (API key accepted) ✓
- [ ] Step 2: Webhook set up (or noted as optional) ✓
- [ ] Step 3: Connected Google Drive ✓
- [ ] Step 3: Auto-folder creation enabled ✓
- [ ] Step 4: Email notifications configured ✓
- [ ] Step 5: Created "Project Startup" template ✓
- [ ] Step 5A: Parent issue template saved ✓
- [ ] Step 5B: Subtask #1 (Schedule) created ✓
- [ ] Step 5C: Subtask #2 (Budget) created ✓
- [ ] Step 5D: Subtask #3 (Review) created ✓
- [ ] Step 5E: Subtask #4 (Notification) created ✓
- [ ] Step 5F: Full template published ✓
- [ ] Step 6: Test completed (optional but recommended) ✓

---

## 🎉 WEEK 1 COMPLETE!

Once you finish, you'll have:

✅ Paperclip talking to Job Thread (auto-triggers on new projects)
✅ Google Drive folders auto-created with the right structure
✅ Email notifications going to your team
✅ Templates pre-filled with your project phases and budget structure
✅ 1-2 day approval lag → Same day startup ⚡

---

## What's Next: Week 2

Once Week 1 is done, we'll do:

1. **Test with your first real project** (run through the complete automation)
2. **Train your team** on using the new workflow
3. **Go live** with all new projects

---

## Need Help?

If you get stuck on any step:
- What step number?
- What's the exact issue?
- What does the screen show?

**I'm here to help!** 📞

---

**READY? Start with Step 1 above. Report back when you finish! ✅**
