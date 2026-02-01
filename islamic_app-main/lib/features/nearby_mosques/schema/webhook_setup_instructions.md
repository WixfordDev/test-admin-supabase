# Supabase Webhook Setup Instructions

## Overview
This guide explains how to create and configure the Supabase Edge Function webhook for the mosque notification system.

## Prerequisites
- Supabase project with CLI installed
- Flutter Firebase project set up
- Firebase Service Account credentials

## Step 1: Environment Variables Setup

### Required Environment Variables
Set these in your Supabase project dashboard under **Settings → Edge Functions → Environment Variables**:

```bash
SUPABASE_URL=https://gbfgotocraqfbzovzzum.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
FIREBASE_PROJECT_ID=deenhub-4bf96
FIREBASE_SERVICE_ACCOUNT_EMAIL=firebase-adminsdk-xxxxx@deenhub-4bf96.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvQIBADA...your_private_key_here...\n-----END PRIVATE KEY-----
```

### Getting Firebase Credentials

1. **Go to Firebase Console** → Your Project → Settings → Service Accounts
2. **Click "Generate new private key"**
3. **Download the JSON file** and extract these values:
   - `project_id` → Use for `FIREBASE_PROJECT_ID`
   - `client_email` → Use for `FIREBASE_SERVICE_ACCOUNT_EMAIL`
   - `private_key` → Use for `FIREBASE_PRIVATE_KEY` (keep the \n characters)

## Step 2: Deploy Edge Function

### Option A: Using Supabase CLI

1. **Install Supabase CLI** (if not already installed):
```bash
npm install -g supabase
```

2. **Login to Supabase**:
```bash
supabase login
```

3. **Link your project**:
```bash
supabase link --project-ref gbfgotocraqfbzovzzum
```

4. **Deploy the function**:
```bash
supabase functions deploy fcm-mosque-notification
```

### Option B: Using Supabase Dashboard

1. **Go to your Supabase Dashboard** → Edge Functions
2. **Click "Create Function"**
3. **Function name**: `fcm-mosque-notification`
4. **Copy and paste** the content from `supabase/functions/fcm-mosque-notification/index.ts`
5. **Click "Create Function"**
6. **Set environment variables** as described above

## Step 3: Database Configuration

### Run the Schema Migration

1. **Go to Supabase Dashboard** → SQL Editor
2. **Create new query** and paste the content from `schema/001_mosque_notification_schema.sql`
3. **Run the query** to create all tables, functions, and triggers

### Verify Installation

Run this test query to ensure everything is working:

```sql
-- Test the notification system
SELECT test_mosque_notification('test_mosque_123', 'fajr', 15);

-- Check if the history record was created
SELECT * FROM mosque_time_change_history WHERE mosque_id = 'test_mosque_123';

-- Check if the mosque was created
SELECT * FROM mosques_metadata WHERE mosque_id = 'test_mosque_123';
```

## Step 4: Testing the Webhook

### Test from SQL Editor

```sql
-- This should trigger a webhook call to your Edge Function
SELECT test_mosque_notification('my_test_mosque', 'maghrib', 10);
```

### Check Edge Function Logs

1. **Go to Supabase Dashboard** → Edge Functions → `fcm-mosque-notification`
2. **Click "Logs"** to see if the function was called
3. **Look for success/error messages**

### Test from Flutter App

Use the test widget provided in your app:
```dart
// Navigate to the test screen
Navigator.push(context, MaterialPageRoute(
  builder: (context) => const NotificationFixTestScreen(),
));
```

## Step 5: Webhook Function URL

Once deployed, your webhook function will be available at:
```
https://gbfgotocraqfbzovzzum.supabase.co/functions/v1/fcm-mosque-notification
```

## Step 6: Monitoring and Debugging

### Check Function Logs
- **Supabase Dashboard** → Edge Functions → `fcm-mosque-notification` → Logs

### Check Database Triggers
```sql
-- See all triggers on mosque_adjustments table
SELECT * FROM information_schema.triggers 
WHERE event_object_table = 'mosque_adjustments';

-- Check trigger execution
SELECT * FROM mosque_time_change_history 
ORDER BY changed_at DESC LIMIT 10;
```

### Test End-to-End Flow

1. **Insert a mosque adjustment**:
```sql
INSERT INTO mosque_adjustments (mosque_id, prayer_name, time_type, adjustment_minutes, change_source)
VALUES ('test_mosque_456', 'dhuhr', 'adhan', 20, 'user');
```

2. **Check if webhook was called** (check Edge Function logs)
3. **Verify notification sent** (check `notification_sent` field in history table)

## Common Issues and Solutions

### Issue: "Missing Firebase service account configuration"
**Solution**: Double-check that all environment variables are set correctly in Supabase Dashboard.

### Issue: "Private key must be in PEM format"
**Solution**: Ensure the private key includes `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` and contains `\n` characters.

### Issue: "Failed to get access token"
**Solution**: Verify that the Firebase Service Account has the correct permissions in Firebase Console.

### Issue: Webhook not triggering
**Solution**: 
1. Check if triggers are installed: `\d+ mosque_adjustments` in SQL Editor
2. Check function logs for errors
3. Verify the webhook URL is correct in the trigger function

## Security Notes

- **Never commit Firebase private keys** to version control
- **Use environment variables** for all sensitive data
- **Test with a separate Firebase project** first if possible
- **Monitor function logs** for any security issues

## Success Indicators

✅ **Edge Function deploys successfully**  
✅ **Environment variables are set**  
✅ **Database schema migration completes**  
✅ **Test webhook calls succeed**  
✅ **Notification history records are created**  
✅ **FCM messages are sent successfully**  

Your mosque notification webhook is now ready for production! 🕌📱 