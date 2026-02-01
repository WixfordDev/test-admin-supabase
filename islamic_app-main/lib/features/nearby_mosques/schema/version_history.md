# Database Schema Version History

This file tracks all changes made to the mosque notification system database schema over time.

## Version 001 - Initial Implementation
**Date**: January 2025  
**Status**: ✅ Production Ready

### Changes Added
- **Tables Created**:
  - `mosques_metadata` - Store mosque basic information
  - `mosque_adjustments` - Store prayer time adjustments with change tracking
  - `mosque_time_change_history` - Track all changes for notifications

- **Functions Added**:
  - `update_updated_at_column()` - Auto-update timestamps
  - `track_mosque_time_change()` - Record changes in history
  - `notify_mosque_time_change()` - Send webhook notifications
  - `test_mosque_notification()` - Testing helper function

- **Triggers Added**:
  - `mosque_time_change_trigger` - Track changes (runs first)
  - `mosque_notification_webhook_trigger` - Send notifications (runs second)

- **Indexes Added**:
  - Performance indexes on frequently queried columns
  - Foreign key relationships for data integrity

### Features Implemented
- ✅ **Device-side processing**: FCM sends minimal data, device calculates prayer times
- ✅ **Change source tracking**: Distinguish between user changes and predictions
- ✅ **Notification thresholds**: User changes always notify, predictions only for 5+ min changes
- ✅ **Error handling**: Graceful failures that don't break transactions
- ✅ **Testing framework**: Built-in test functions for easy debugging

### Migration Notes
- First implementation of the notification system
- Uses `pg_net` extension for HTTP requests
- Hardcoded webhook URL for stable production deployment
- All functions use `IF NOT EXISTS` for safe re-running

---

## Future Versions (Template)

### Version 002 - [Description]
**Date**: [Date]  
**Status**: [Planning/Development/Testing/Production]

### Changes Added
- **Tables**: [List any new tables]
- **Functions**: [List any new functions]
- **Triggers**: [List any new triggers]
- **Columns**: [List any new columns added]

### Changes Modified
- **Tables**: [List any table modifications]
- **Functions**: [List any function updates]
- **Triggers**: [List any trigger changes]

### Changes Removed
- **Tables**: [List any removed tables]
- **Functions**: [List any removed functions]
- **Triggers**: [List any removed triggers]

### Breaking Changes
- [List any breaking changes that require app updates]

### Migration Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

---

## Schema Evolution Planning

### Planned Features
- **User preferences**: Store user-specific notification settings
- **Mosque verification**: Add verification status and admin approval
- **Batch notifications**: Optimize for bulk prayer time updates
- **Analytics**: Track notification delivery and engagement
- **Regional settings**: Support for different calculation methods by region

### Performance Considerations
- **Partitioning**: Consider partitioning history table by date for large datasets
- **Archival**: Implement data retention policies for old history records
- **Caching**: Add materialized views for frequently accessed data
- **Indexing**: Monitor query patterns and add indexes as needed

### Security Enhancements
- **RLS policies**: Implement Row Level Security for multi-tenant support
- **Audit logging**: Enhanced logging for security monitoring
- **API rate limiting**: Protect against abuse of notification endpoints
- **Data encryption**: Encrypt sensitive user data at rest

---

## Migration Checklist Template

For each new version, ensure:

### Pre-Migration
- [ ] **Backup database** before making changes
- [ ] **Test migration** in development environment
- [ ] **Review breaking changes** with development team
- [ ] **Plan rollback strategy** if migration fails
- [ ] **Schedule maintenance window** for production deployment

### During Migration
- [ ] **Run migration script** with transaction protection
- [ ] **Verify all objects** created successfully
- [ ] **Test critical functions** work as expected
- [ ] **Check trigger functionality** with test data
- [ ] **Validate data integrity** after migration

### Post-Migration
- [ ] **Run verification queries** to confirm system health
- [ ] **Test notification system** end-to-end
- [ ] **Monitor performance** for any degradation
- [ ] **Update documentation** with new schema details
- [ ] **Deploy app updates** if schema changes require them

---

## Rollback Procedures

### Version 001 Rollback
If issues occur with the initial implementation:

```sql
-- Drop triggers (order matters)
DROP TRIGGER IF EXISTS mosque_notification_webhook_trigger ON mosque_adjustments;
DROP TRIGGER IF EXISTS mosque_time_change_trigger ON mosque_adjustments;
DROP TRIGGER IF EXISTS update_mosque_adjustments_updated_at ON mosque_adjustments;
DROP TRIGGER IF EXISTS update_mosques_metadata_updated_at ON mosques_metadata;

-- Drop functions
DROP FUNCTION IF EXISTS notify_mosque_time_change();
DROP FUNCTION IF EXISTS track_mosque_time_change();
DROP FUNCTION IF EXISTS test_mosque_notification();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop tables (order matters due to foreign keys)
DROP TABLE IF EXISTS mosque_time_change_history;
DROP TABLE IF EXISTS mosque_adjustments;
DROP TABLE IF EXISTS mosques_metadata;
```

---

## Best Practices

### Schema Design
- **Use meaningful names** for tables, columns, and functions
- **Include comments** on all database objects
- **Follow consistent naming conventions** across all objects
- **Design for scalability** from the beginning

### Version Control
- **Number versions sequentially** (001, 002, 003...)
- **Document all changes** in this history file
- **Test migrations thoroughly** before production
- **Keep rollback scripts** for each version

### Deployment
- **Use transactions** for atomic migrations
- **Test in staging** environment first
- **Plan for downtime** if schema changes are breaking
- **Monitor performance** after deployment

This schema management approach ensures maintainable, scalable database evolution! 📊🔧 