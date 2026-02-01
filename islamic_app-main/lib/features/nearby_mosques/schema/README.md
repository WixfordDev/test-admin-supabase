# Mosque Notification System - Database Schema

This folder contains all database schema files for the mosque notification system. This organized approach ensures proper version control and easy maintenance of the Supabase database structure.

## 📁 File Structure

```
schema/
├── README.md                           # This file - documentation
├── 001_mosque_notification_schema.sql  # Main schema migration
├── 002_verification_queries.sql        # Verification and testing queries
├── webhook_setup_instructions.md       # Webhook setup guide
└── version_history.md                  # Schema change history
```

## 🚀 Quick Start

### 1. Deploy Database Schema

1. **Open Supabase Dashboard** → SQL Editor
2. **Copy content** from `001_mosque_notification_schema.sql`
3. **Paste and run** the migration
4. **Verify installation** using `002_verification_queries.sql`

### 2. Set Up Webhook

1. **Follow instructions** in `webhook_setup_instructions.md`
2. **Deploy Edge Function** for FCM notifications
3. **Test end-to-end** functionality

### 3. Verify Everything Works

Run the verification queries to ensure:
- ✅ All tables created successfully
- ✅ Triggers are active and firing
- ✅ Webhook function responds correctly
- ✅ Notifications are sent properly

## 📋 Schema Components

### Tables

| Table Name | Purpose | Key Fields |
|------------|---------|------------|
| `mosques_metadata` | Store mosque information | `mosque_id`, `name`, `latitude`, `longitude` |
| `mosque_adjustments` | Prayer time adjustments | `mosque_id`, `prayer_name`, `adjustment_minutes` |
| `mosque_time_change_history` | Track all changes | `mosque_id`, `previous_adjustment`, `new_adjustment` |

### Functions

| Function Name | Purpose |
|---------------|---------|
| `update_updated_at_column()` | Auto-update timestamp fields |
| `track_mosque_time_change()` | Record changes in history table |
| `notify_mosque_time_change()` | Send webhook notifications |
| `test_mosque_notification()` | Test the notification system |

### Triggers

| Trigger Name | Table | Purpose |
|-------------|--------|---------|
| `mosque_time_change_trigger` | `mosque_adjustments` | Track changes to history |
| `mosque_notification_webhook_trigger` | `mosque_adjustments` | Send notifications |

## 🔧 Usage Instructions

### Running Schema Migration

```sql
-- Step 1: Run the main schema migration
-- Copy and paste content from 001_mosque_notification_schema.sql

-- Step 2: Verify installation
-- Copy and paste content from 002_verification_queries.sql

-- Step 3: Test the system
SELECT test_mosque_notification('my_mosque', 'fajr', 10);
```

### Testing the System

```sql
-- Test notification trigger
INSERT INTO mosque_adjustments (mosque_id, prayer_name, adjustment_minutes, change_source)
VALUES ('test_mosque_123', 'maghrib', 15, 'user');

-- Check if history was recorded
SELECT * FROM mosque_time_change_history 
WHERE mosque_id = 'test_mosque_123' 
ORDER BY changed_at DESC;
```

### Monitoring Notifications

```sql
-- See recent notification activity
SELECT 
    mosque_id,
    prayer_name,
    new_adjustment,
    notification_sent,
    changed_at
FROM mosque_time_change_history 
ORDER BY changed_at DESC 
LIMIT 10;

-- Check notification success rate
SELECT 
    COUNT(*) as total_changes,
    SUM(CASE WHEN notification_sent THEN 1 ELSE 0 END) as notifications_sent,
    ROUND(100.0 * SUM(CASE WHEN notification_sent THEN 1 ELSE 0 END) / COUNT(*), 2) as success_rate
FROM mosque_time_change_history
WHERE changed_at >= NOW() - INTERVAL '24 hours';
```

## 🔄 Schema Version Management

### Current Version: 001
- ✅ Basic mosque metadata table
- ✅ Prayer time adjustments tracking
- ✅ Change history logging
- ✅ Webhook notification triggers
- ✅ Test functions for debugging

### Future Versions
Future schema changes should be added as `003_description.sql`, `004_description.sql`, etc.

### Migration Best Practices

1. **Always backup** before running migrations
2. **Test in development** environment first
3. **Use transactions** for complex migrations
4. **Document changes** in version_history.md
5. **Verify schema** after deployment

## 🧪 Testing Checklist

After running schema migration, verify:

- [ ] **Tables exist**: All 3 tables created successfully
- [ ] **Functions work**: All 4 functions callable without errors
- [ ] **Triggers active**: Triggers fire when data changes
- [ ] **Indexes created**: Performance indexes in place
- [ ] **Test notification**: `test_mosque_notification()` works
- [ ] **Webhook responds**: Edge Function receives webhook calls
- [ ] **History tracked**: Changes recorded in history table
- [ ] **FCM sent**: Notifications delivered to devices

## 🐛 Troubleshooting

### Common Issues

**Issue**: "relation does not exist"
```sql
-- Solution: Check if tables were created
SELECT tablename FROM pg_tables WHERE tablename LIKE 'mosque%';
```

**Issue**: "function does not exist"
```sql
-- Solution: Verify functions were created
SELECT proname FROM pg_proc WHERE proname LIKE '%mosque%';
```

**Issue**: "triggers not firing"
```sql
-- Solution: Check trigger status
SELECT * FROM information_schema.triggers WHERE table_name = 'mosque_adjustments';
```

**Issue**: "webhook not called"
```sql
-- Solution: Test manually and check logs
SELECT test_mosque_notification();
-- Then check Supabase Edge Function logs
```

## 📞 Support

For issues with the schema:

1. **Check verification queries** in `002_verification_queries.sql`
2. **Review webhook setup** in `webhook_setup_instructions.md`
3. **Test system** with provided test functions
4. **Check Supabase logs** for Edge Function errors
5. **Verify Firebase** credentials and permissions

## 🔐 Security Notes

- **Foreign keys** ensure data integrity
- **Authorization headers** protect webhook endpoints
- **Error handling** prevents transaction failures
- **Minimal permissions** for database functions
- **No sensitive data** exposed in triggers

This schema provides a robust, scalable foundation for the mosque notification system! 🕌📱 