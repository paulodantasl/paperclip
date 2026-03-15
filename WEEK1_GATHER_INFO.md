# Quick Setup: Gather Your Integration Information

## Step 1: Get Your Job Thread API Key

**In Job Thread, follow these steps:**

1. Log into Job Thread
2. Go to **Settings** (usually bottom left or gear icon)
3. Look for **"API"** or **"Integrations"** or **"Developer Settings"**
4. Find or create an **API Key**
5. Copy the key (long string of characters)
6. Keep it safe - don't share it

**What it looks like:** `jt_abc123def456ghi789jkl`

**Can't find it?**
- Check Settings → Account → API
- Or Settings → Developer → API Keys
- Contact Job Thread support if still stuck

---

## Step 2: Get Your WhatsApp Group ID

This is trickier since WhatsApp doesn't show IDs directly. Here are two ways:

### Method A: Via WhatsApp Chat (Simplest)
1. Open WhatsApp on your phone (or WhatsApp Web in browser)
2. Open your **team group chat**
3. Look at the group info:
   - **Phone:** Click group name at top → Group Info
   - **Desktop:** Click group name → Info on right
4. You're looking for the **Group ID** (might be listed, or might need to ask in group)

### Method B: Using a Bot (Alternative)
If Method A doesn't work, we can use a WhatsApp bot service that auto-captures the group ID when you add it to the group. (I can guide you through this if needed)

**What it looks like:** `123456789-1234567890@g.us` or similar

---

## Step 3: Your Google Drive Projects Folder Path

You said you know this, which is great!

**Examples of typical paths:**
- `/Projects`
- `/My Drive/Projects`
- `/Shared drives/Construction/Projects`
- `/Companies/Your Company Name/Projects`

**To verify your path:**
1. Open Google Drive
2. Navigate to your Projects folder
3. Click on it
4. The path is in the URL bar

**What it looks like in the URL:**
```
https://drive.google.com/drive/folders/1A-bC2_deFgHiJkLmNoPqRsTuVwXyZ
                                        ↑ This folder ID is what we need
```

---

## Next Steps

**Once you have all three pieces:**
1. Job Thread API Key ✓
2. WhatsApp Group ID ✓
3. Google Drive Folder Path ✓

**Tell me:**
- [ ] I have my Job Thread API key
- [ ] I have my WhatsApp group ID
- [ ] I can confirm my Google Drive path

**Then I'll guide you through the actual Paperclip integration setup (15-20 minutes).**

---

## Quick Troubleshooting

**"I can't find the API key in Job Thread"**
→ Job Thread calls it different things. Look in Settings → Integrations, or ask Job Thread chat support.

**"I don't want to use WhatsApp, can we use something else?"**
→ Yes! We can use email, SMS, or Slack instead. Let me know your preference.

**"My Google Drive is messy, how should I organize it?"**
→ The implementation guide shows a recommended structure. We can set that up automatically when Paperclip is running.

---

**Ready? Get these three items and let me know when you have them!**
