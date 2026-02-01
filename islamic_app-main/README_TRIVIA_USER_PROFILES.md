# Trivia User Profiles Setup Guide

## Overview

This setup enables unique usernames and enhanced leaderboards for the DeenHub trivia game. Users can now have persistent, unique usernames that appear across all games and leaderboards.

## Files

- `supabase_user_profiles_setup.sql` - Main setup script for Supabase SQL Editor
- `test_user_profiles.sql` - Test script to verify everything works

## Setup Instructions

### 1. Run the Main Setup Script

1. Open your Supabase project dashboard
2. Go to **SQL Editor**
3. Copy and paste the contents of `supabase_user_profiles_setup.sql`
4. Click **Run** to execute the script

The script will:
- ✅ Create the `trivia_user_profiles` table
- ✅ Set up Row Level Security policies
- ✅ Create utility functions for username management
- ✅ Update the leaderboard function
- ✅ Enable real-time subscriptions
- ✅ Provide migration utilities

### 2. Run Migration (Optional)

If you have existing trivia game data, run the migration:

```sql
SELECT * FROM migrate_display_names_to_usernames();
```

This will create profiles for users who have played games but don't have profiles yet.

### 3. Test the Setup

1. Copy and paste `test_user_profiles.sql` into the SQL Editor
2. Run the test script to verify everything works
3. Check the results for any errors

## Database Schema

### trivia_user_profiles Table

```sql
CREATE TABLE public.trivia_user_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id),
    username TEXT NOT NULL UNIQUE,
    email TEXT,
    display_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Key Features

- **Unique Usernames**: Case-insensitive uniqueness enforced by database
- **User Linking**: Each profile linked to Supabase auth user
- **Email Integration**: Optional email storage for enhanced features
- **Auto-timestamps**: Created/updated timestamps maintained automatically
- **RLS Security**: Proper access control with Row Level Security

## API Functions

### Check Username Availability

```sql
SELECT is_username_available('desired_username');
-- Returns: true/false
```

### Create/Update Profile

```sql
SELECT * FROM upsert_user_profile(
    user_id := 'user-uuid-here',
    username := 'UniqueUsername',
    email := 'user@example.com',
    display_name := 'Display Name'
);
```

### Get User Profile

```sql
SELECT * FROM get_user_profile('user-uuid-here');
```

### Get Leaderboard

```sql
SELECT * FROM trivia_leaderboard(10);
-- Returns top 10 players with usernames, emails, scores, and games played
```

## Frontend Integration

The Flutter app has been updated to use these database functions:

### Shared Preferences Helper

```dart
// Get current user's username
String? username = sharedPrefsHelper.triviaUsername;

// Set username
sharedPrefsHelper.setTriviaUsername = 'NewUsername';

// Clear username
sharedPrefsHelper.clearTriviaUsername();
```

### Trivia Service

```dart
// Check username availability
bool available = await service.isUsernameAvailable('username');

// Get or create profile
Map<String, dynamic> profile = await service.getOrCreateUserProfile(
  userId: userId,
  email: email,
);

// Update username
Map<String, dynamic> updated = await service.updateUsername(
  userId: userId,
  newUsername: 'NewUsername',
);
```

## Security

- **RLS Policies**: Users can only modify their own profiles
- **Authentication Required**: All operations require authenticated users
- **Input Validation**: Functions validate inputs before processing
- **SQL Injection Protection**: Uses parameterized queries

## Real-time Features

The setup enables real-time updates for:
- Profile changes
- Leaderboard updates
- Live game synchronization

## Troubleshooting

### "Cannot Change Return Type" Error

If you get: `ERROR: 42P13: cannot change return type of existing function`

**Solution**: The leaderboard function signature has changed. Run this first:

```sql
-- Quick fix for leaderboard function
DROP FUNCTION IF EXISTS public.trivia_leaderboard(INTEGER) CASCADE;
```

Or use the `supabase_quick_fix.sql` script provided.

### Script Fails to Run

1. Check Supabase project permissions
2. Ensure you're in the correct database
3. Try running sections individually
4. If leaderboard function fails, run the quick fix first

### Username Uniqueness Issues

1. The database enforces case-insensitive uniqueness
2. Use `is_username_available()` to check before creating
3. Handle conflicts gracefully in your app

### Leaderboard Not Showing Usernames

1. Ensure migration has been run
2. Check that users have profiles created
3. Verify RLS policies allow reading

### Real-time Not Working

1. Check publication status in Supabase dashboard
2. Verify table is added to `supabase_realtime` publication
3. Test with Supabase real-time debugger

## Performance

- **Indexes**: Optimized for username lookups and user queries
- **Functions**: Marked as `STABLE` where appropriate for caching
- **Queries**: Efficient joins for leaderboard calculations

## Migration Notes

- **Safe to Run Multiple Times**: All operations use `IF NOT EXISTS` or `OR REPLACE`
- **Backward Compatible**: Existing functionality continues to work
- **Data Preservation**: Existing game data is preserved during migration

## Support

For issues with this setup:

1. Check the test script results
2. Verify Supabase project configuration
3. Review Flutter app logs for API errors
4. Check Supabase dashboard for policy/rule conflicts

---

**Last Updated**: January 24, 2025
**Version**: 1.0.0
