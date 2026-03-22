# WEEK 1: Complete Setup Guide (Non-Technical)

**Your Integration Details:**
- Job Thread API Key: `22TL2ziHjUradqgSReprTTg9uvY7ezpgRg` ✓
- Notifications: Email ✓
- Google Drive Path: `/Projects` ✓

---

## STEP 1: Prepare Your Templates (15 minutes)

**Objective:** Customize the schedule and budget templates so they match your typical projects.

### 1A: Review & Customize Schedule Template

**What is this?**
A CSV file (Excel spreadsheet format) that Paperclip will auto-fill with your project dates. This is what you'll import into Job Thread's Gantt chart.

**Current template phases** (you may customize):
```
Site Mobilization
Phase 1: [Phase Name]
Phase 2: [Phase Name]
Inspections & Punch List
Project Closeout
```

**ACTION:**
- [ ] Look at your typical projects
- [ ] What are your standard phases?
- [ ] Example: "Site Prep" → "Foundation" → "Framing" → "MEP" → "Finish" → "Inspection"
- [ ] Note down your typical phase names

**Then tell me:**
> "My typical project phases are: [list them]"

### 1B: Review & Customize Budget Template

**What is this?**
An Excel spreadsheet that shows labor vs. material costs. Paperclip will pre-fill based on your Job Thread estimate amounts.

**Current template:**
```
LABOR COSTS
- Crew Labor (60% of estimate)
- Equipment Operation
- Safety Officer
TOTAL LABOR

MATERIAL COSTS
- Materials (35% of estimate)
- Equipment Rental
TOTAL MATERIALS

OTHER COSTS
- Permits & Licenses
- Insurance
- Contingency (5%)
TOTAL OTHER

TOTAL PROJECT BUDGET
```

**ACTION:**
- [ ] Does this breakdown match how you estimate?
- [ ] Do you typically split labor/materials 60/35?
- [ ] Should we add any line items? (e.g., Travel, Subcontractors)
- [ ] Any categories you want removed?

**Then tell me:**
> "My budget breakdown looks [good as-is / needs these changes...]"

---

## STEP 2: Connect Paperclip to Job Thread API (10 minutes)

**What's happening?**
You're telling Paperclip how to talk to Job Thread so it can automatically create workflows when you start a new project.

### Step 2A: In Paperclip Settings

1. **Open Paperclip** (in your browser or app)
2. Click **Settings** (usually bottom left or gear icon)
3. Find **"Integrations"** or **"Connected Apps"**
4. Look for **"Job Thread"** integration option
5. Click **"Connect"** or **"Add Integration"**

### Step 2B: Authenticate Your Job Thread Account

6. You'll see a form or pop-up asking for your API key
7. **Paste your API key here:**
   ```
   22TL2ziHjUradqgSReprTTg9uvY7ezpgRg
   ```
8. Click **"Verify"** or **"Test Connection"**
9. You should see ✅ **"Connected Successfully"**

### Step 2C: Set Up the Webhook (Trigger)

10. After connecting, look for **"Webhooks"** or **"Automation Triggers"**
11. Click **"Add Webhook"** or **"New Trigger"**
12. Configure:
    - **Event:** "Project Created"
    - **Status Filter:** "Approved" (only auto-trigger for approved projects)
    - **Action:** "Create Paperclip Issue"
    - **Issue Template:** "Project Startup" (we'll create this next)
13. Click **"Save"**

**What this means:** Every time you create a project in Job Thread with status "Approved," Paperclip automatically creates a workflow for you.

**If webhooks aren't available:**
- No problem! You'll just manually create the Paperclip issue (takes 2 minutes per project)
- Skip this step and proceed

---

## STEP 3: Connect Paperclip to Google Drive (10 minutes)

**What's happening?**
You're giving Paperclip permission to create folders and upload documents to your Google Drive.

### Step 3A: In Paperclip Settings

1. Go back to **Settings** → **"Integrations"**
2. Find **"Google Drive"** integration option
3. Click **"Connect"** or **"Add Integration"**

### Step 3B: Authenticate Google

4. A Google login window will appear
5. **Log in with the Google account** that has access to your Projects folder
6. Click **"Allow"** when Paperclip asks for Google Drive permission
7. You'll be redirected back to Paperclip

### Step 3C: Set Root Folder

8. Back in Paperclip, you'll see a field for **"Root Folder Path"**
9. Enter: `/Projects`
10. Click **"Test"** to verify (Paperclip will confirm it can see your `/Projects` folder)
11. Click **"Save"**

### Step 3D: Configure Auto-Folder Creation

12. Look for **"Auto-Create Folder Structure"** or **"Folder Template"**
13. Select **"Enabled"**
14. Configure the subfolder structure:
    ```
    ☑ 01_Contracts
    ☑ 02_Schedules
    ☑ 03_Budget
    ☑ 04_Documentation
    ☑ 05_Communications
    ☑ 06_Field_Docs
    ```
15. Click **"Save"**

**What this means:** Every time you approve a project in Paperclip, it will automatically create all these folders in your Google Drive under `/Projects/[ProjectName]/`.

---

## STEP 4: Set Up Email Notifications (5 minutes)

**What's happening?**
Paperclip will send emails to your team when a project is ready to start.

### Step 4A: In Paperclip Settings

1. Go to **Settings** → **"Notifications"** or **"Email Settings"**
2. Find **"Email Recipients"** or **"Team Notification Settings"**
3. Click **"Add Email Address"** or **"Configure"**

### Step 4B: Add Team Email Addresses

4. Enter your team members' emails:
   - Your email (for approval notifications)
   - Any other team members who need to know when projects are ready

**Example:**
```
[your email]@gmail.com
[team member 1]@gmail.com
[team member 2]@gmail.com
```

5. For the **"Project Ready" email template**, keep the default or customize:
   - Subject: "🚀 NEW PROJECT READY TO START: [ProjectName]"
   - Body: Include project name, client, start date, budget, Google Drive link

6. Click **"Save"**

**What this means:** When you approve a project, your team automatically gets an email with all the details and Google Drive link. No more manual WhatsApp messages!

---

## STEP 5: Create the Paperclip Workflow Template (20 minutes)

**What's happening?**
You're setting up the "template" that Paperclip will use every time a new project starts.

### Step 5A: Create Parent Issue Template

1. In Paperclip, go to **Settings** → **"Issue Templates"** or **"Workflows"**
2. Click **"New Template"** or **"Create Workflow"**
3. Name it: `Project Startup`
4. Set the Parent Issue Template:
   ```
   Title: Project Startup - [ProjectName]
   Description: Auto-generated workflow for new project startup

   Status Options: New → In Progress → Approved → Completed
   Assignee: [Auto-assign to you (owner)]
   Due Date: [Auto-set to project start date - 1 day]

   Priority: High
   ```
5. Click **"Save"**

### Step 5B: Create Subtask 1 (Schedule)

6. In the same template, find **"Add Subtask"** or **"Add Child Issue"**
7. Create Subtask #1:
   ```
   Title: Create Schedule (Gantt CSV)
   Description: Generate schedule CSV for Job Thread import
   Assigned To: [You - to review before approval]
   Due Date: [Project start date - 2 days]

   Attachment: [Attach your Schedule_Template.csv file]
   Template Fields:
     - Project Name: [Auto-fill from parent issue]
     - Start Date: [Auto-fill from Job Thread]
     - Duration: [Auto-fill from Job Thread]

   Status Workflow: Pending → Completed
   ```
8. Click **"Save Subtask"**

### Step 5C: Create Subtask 2 (Budget)

9. Create Subtask #2:
   ```
   Title: Create Budget Breakdown
   Description: Generate budget with labor and material breakdown
   Assigned To: [You - to review before approval]
   Due Date: [Project start date - 2 days]

   Attachment: [Attach your Budget_Template.xlsx file]
   Template Fields:
     - Project Name: [Auto-fill from parent issue]
     - Estimate Amount: [Auto-fill from Job Thread]
     - Labor % / Material %: [60/35 default, editable]

   Status Workflow: Pending → Completed
   ```
10. Click **"Save Subtask"**

### Step 5D: Create Subtask 3 (Review)

11. Create Subtask #3:
    ```
    Title: Review & Approve Documents
    Description: Review schedule and budget, ensure they're complete and accurate
    Assigned To: [You (owner)]

    Approval Required: Yes
    Checklist:
      ☐ Schedule is realistic
      ☐ Budget is accurate
      ☐ All documents are ready

    Status Workflow: Pending → Approved
    ```
12. Click **"Save Subtask"**

### Step 5E: Create Subtask 4 (Notification)

13. Create Subtask #4:
    ```
    Title: Send Team Notification
    Description: Auto-send project ready notification to team
    Assigned To: [Automated - no manual assignment]

    Trigger: When parent issue status = "Approved"
    Action: Send email to team with:
      - Project name, client, start date
      - Budget amount
      - Google Drive folder link
      - Job Thread project link

    Status Workflow: Auto-triggered → Completed
    ```
14. Click **"Save Subtask"**

### Step 5F: Save the Complete Workflow Template

15. Review all subtasks you've created
16. Click **"Save Template"** (at the top level)
17. Confirm the template is now available for use

**What this means:** Whenever a new project is approved, Paperclip will automatically create this exact workflow with all subtasks, pre-populated data, and automations.

---

## STEP 6: Test the Integration (Optional but Recommended)

**Objective:** Make sure everything works before going live with real projects.

### Option A: Test in Job Thread

1. Create a **test project** in Job Thread:
   - Project Name: "TEST - Kitchen Remodel"
   - Client: "Test Client"
   - Start Date: Tomorrow (or next week)
   - Budget: $50,000
   - Mark as "Approved"

2. **Wait 30 seconds** (for webhook to trigger)

3. **Check Paperclip:**
   - Go to Paperclip home page
   - Look for new issue: "Project Startup - TEST - Kitchen Remodel"
   - Verify all subtasks were created
   - Verify template data was auto-filled

4. **Check Google Drive:**
   - Go to `/Projects/TEST - Kitchen Remodel/`
   - Verify folders were auto-created (01_Contracts, 02_Schedules, etc.)

### Option B: Manual Test

If webhooks aren't available:
1. Go to Paperclip
2. Click **"New Issue"**
3. Select template: **"Project Startup"**
4. Fill in project details manually
5. Verify the same result as Option A

---

## Checklist: Week 1 Complete ✅

- [ ] **Step 1:** Reviewed and customized schedule template
- [ ] **Step 1:** Reviewed and customized budget template
- [ ] **Step 2:** Connected Paperclip to Job Thread API
- [ ] **Step 2:** Set up webhook/trigger (or noted if not available)
- [ ] **Step 3:** Connected Paperclip to Google Drive
- [ ] **Step 3:** Configured auto-folder creation
- [ ] **Step 4:** Set up email notifications for team
- [ ] **Step 5:** Created "Project Startup" workflow template with 4 subtasks
- [ ] **Step 6:** Tested with a test project (recommended)

---

## Troubleshooting

**"I'm stuck on Step 2 - can't find the Integration settings"**
- Look for Settings → Integrations, Connections, or Installed Apps
- If still stuck, what does your Paperclip menu look like? (describe it)

**"The webhook didn't trigger"**
- No problem! Skip it - you'll just manually create the Paperclip issue (2 min per project)
- Or email Paperclip support to help set up webhooks

**"Google Drive connection failed"**
- Make sure you're logged into the correct Google account
- Make sure that account has access to `/Projects` folder
- Try disconnecting and reconnecting

**"The email notification test didn't work"**
- Check email spam folder
- Verify email addresses are spelled correctly
- Try sending a test manually first

---

## Next: Week 2 (Starting After You Complete Week 1)

Once you finish this checklist, you'll be ready for **Week 2: Testing & Go-Live**

This is when we:
1. Run your first real project through the automation
2. Make sure everything works smoothly
3. Train your team
4. Go live with real projects

---

**Status:** Week 1 - Setup Phase
**Estimated Time to Complete:** 45-60 minutes total
**Next Step:** Work through Steps 1-5 above, then report back!

---

**Any questions or getting stuck? Let me know which step and I'll help!**
