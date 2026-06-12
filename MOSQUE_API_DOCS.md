# Mosque API Documentation

## Architecture

```
Flutter App
    ↓  Authorization: Bearer <jwt>
Next.js APIs (localhost:3002)
    ↓
Supabase (PostgreSQL)
```

## Authentication

Flutter থেকে সব request-এ JWT token পাঠাতে হবে:

```
Authorization: Bearer <access_token>
```

Token নেওয়ার উপায়:
```
POST https://gbfgotocraqfbzovzzum.supabase.co/auth/v1/token?grant_type=password

Headers:
  apikey: <SUPABASE_ANON_KEY>
  Content-Type: application/json

Body:
  { "email": "user@email.com", "password": "password" }

Response:
  { "access_token": "eyJ...", "expires_in": 3600 }
```

> Token ১ ঘন্টা পর expire হয়। নতুন token নিতে হবে।

---

## Permission System

| Role  | Announcements | Events | Admins Management |
|-------|-------------|--------|-------------------|
| owner | ✅ create/edit/delete | ✅ create/edit/delete | ✅ add/remove admins |
| admin | ✅ create/edit/delete | ✅ create/edit/delete | ❌ |
| user  | ❌ | ❌ | ❌ |

---

## Claim Flow

```
1. User submits claim        → POST /api/mosque-claims
2. Admin reviews             → GET  /api/admin/mosque-claims
3. Admin approves            → PUT  /api/admin/mosque-claims/:id/approve
                               → verification_code generated (DH-XXXXXX)
4. Admin sends code by post  → Manual postal mail
5. User enters code          → POST /api/mosque-claims/verify
                               → mosque_roles: owner role created
                               → mosques_metadata: is_claimed = true
```

---

## API Reference

---

### CLAIM APIs (Flutter)

#### POST /api/mosque-claims
Mosque claim জমা দেওয়া।

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "mosque_id": "string",          // required
  "mosque_email": "string",       // optional
  "mosque_phone": "string",       // optional
  "position": "string",           // optional (e.g. "Imam", "President")
  "notes": "string"               // optional
}

Success 201:
{
  "success": true,
  "claim": {
    "id": "uuid",
    "mosque_id": "string",
    "user_id": "uuid",
    "status": "pending",
    "verification_status": "pending",
    "created_at": "2026-06-11T..."
  }
}

Errors:
  401 → Unauthorized (no/expired token)
  400 → mosque_id is required
  404 → Mosque not found
  409 → Mosque is already claimed
  409 → You already have an active claim for this mosque
```

---

#### GET /api/mosque-claims/my
নিজের সব claims দেখা।

```
Headers:
  Authorization: Bearer <token>

Success 200:
{
  "claims": [
    {
      "id": "uuid",
      "mosque_id": "string",
      "status": "pending | approved | rejected | verified",
      "verification_code": null,
      "verification_status": "pending | verified",
      "verified_at": null,
      "created_at": "...",
      "mosque": {
        "mosque_id": "string",
        "name": "Baitul Mukarram",
        "address": "Dhaka"
      }
    }
  ]
}
```

---

#### POST /api/mosque-claims/verify
Postal mail-এ পাওয়া code দিয়ে ownership verify করা।

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "mosque_id": "string",
  "verification_code": "DH-728451"
}

Success 200:
{
  "success": true,
  "message": "Mosque ownership verified successfully"
}

Errors:
  404 → No approved claim found for this mosque
  400 → Invalid verification code
```

---

### CLAIM APIs (Admin Dashboard)

#### GET /api/admin/mosque-claims
সব claims দেখা (filter + pagination সহ)।

```
Query Params:
  status = all | pending | approved | rejected | verified
  search = string
  page   = number (default: 1)
  limit  = number (default: 50)

Success 200:
{
  "claims": [ ... ],
  "stats": {
    "total": 10,
    "pending": 4,
    "approved": 3,
    "rejected": 1,
    "verified": 2
  },
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 10,
    "totalPages": 1
  }
}
```

---

#### PUT /api/admin/mosque-claims/:id/approve
Claim approve করা + verification code তৈরি।

```
No body needed.

Success 200:
{
  "success": true,
  "verification_code": "DH-728451",
  "claim": { "status": "approved", ... }
}

Errors:
  404 → Claim not found
  409 → Claim is already approved/rejected/verified
```

---

#### PUT /api/admin/mosque-claims/:id/reject
Claim reject করা।

```
No body needed.

Success 200:
{
  "success": true,
  "claim": { "status": "rejected", ... }
}

Errors:
  404 → Claim not found
  409 → Cannot reject a verified claim
```

---

### ANNOUNCEMENT APIs (Flutter)

#### POST /api/mosques/:mosqueId/announcements
নতুন announcement তৈরি। (owner/admin only)

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "title": "string",    // required
  "content": "string"   // required
}

Success 201:
{
  "success": true,
  "announcement": {
    "id": "uuid",
    "mosque_id": "string",
    "title": "string",
    "content": "string",
    "created_by": "uuid",
    "created_at": "..."
  },
  "notification": {
    "queued": true,
    "recipientCount": 42
  }
}

Errors:
  401 → Unauthorized
  403 → Forbidden (not owner/admin)
  400 → title and content are required
```

---

#### GET /api/mosques/:mosqueId/announcements
Mosque-এর সব announcements।

```
Query Params:
  page  = number (default: 1)
  limit = number (default: 20)

Success 200:
{
  "announcements": [
    {
      "id": "uuid",
      "title": "Friday Prayer",
      "content": "...",
      "created_by": "uuid",
      "created_at": "..."
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 5, "totalPages": 1 }
}
```

---

#### PUT /api/announcements/:id
Announcement আপডেট। (owner/admin only)

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "title": "string",    // optional
  "content": "string"   // optional
}

Success 200:
{
  "success": true,
  "announcement": { ... }
}
```

---

#### DELETE /api/announcements/:id
Announcement মুছে ফেলা। (owner/admin only)

```
Headers:
  Authorization: Bearer <token>

Success 200:
{
  "success": true,
  "message": "Announcement deleted"
}
```

---

### EVENT APIs (Flutter)

#### POST /api/mosques/:mosqueId/events
নতুন event তৈরি। (owner/admin only)

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "title": "string",          // required
  "description": "string",    // optional
  "event_date": "ISO string", // required (e.g. "2026-07-01T10:00:00Z")
  "end_date": "ISO string",   // optional
  "location": "string",       // optional
  "image_url": "string",      // optional
  "max_attendees": 100        // optional
}

Success 201:
{
  "success": true,
  "event": {
    "id": "uuid",
    "mosque_id": "string",
    "title": "string",
    "event_date": "...",
    "is_active": true,
    "created_at": "..."
  },
  "notification": {
    "queued": true,
    "recipientCount": 42
  }
}
```

---

#### GET /api/mosques/:mosqueId/events
Mosque-এর সব active events।

```
Query Params:
  page     = number (default: 1)
  limit    = number (default: 20)
  upcoming = true | false (default: false → all events)

Success 200:
{
  "events": [ ... ],
  "pagination": { "page": 1, "limit": 20, "total": 3, "totalPages": 1 }
}
```

---

#### PUT /api/events/:id
Event আপডেট। (owner/admin only)

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "title": "string",
  "description": "string",
  "event_date": "ISO string",
  "end_date": "ISO string",
  "location": "string",
  "max_attendees": 200,
  "is_active": false
}

Success 200:
{
  "success": true,
  "event": { ... }
}
```

---

#### DELETE /api/events/:id
Event মুছে ফেলা। (owner/admin only)

```
Headers:
  Authorization: Bearer <token>

Success 200:
{
  "success": true,
  "message": "Event deleted"
}
```

---

### ATTENDANCE APIs (Flutter)

#### POST /api/events/:eventId/attend
Event-এ attend করা বা status update করা।

```
Headers:
  Authorization: Bearer <token>
  Content-Type: application/json

Body:
{
  "attendance_status": "going | maybe",  // required
  "reminder_enabled": true               // optional (default: false)
}

Success 200:
{
  "success": true,
  "attendance": {
    "id": "uuid",
    "event_id": "uuid",
    "user_id": "uuid",
    "attendance_status": "going",
    "reminder_enabled": true
  }
}
```

---

#### DELETE /api/events/:eventId/attend
Attendance বাতিল করা।

```
Headers:
  Authorization: Bearer <token>

Success 200:
{
  "success": true,
  "message": "Attendance removed"
}
```

---

#### GET /api/events/:eventId/attendees
Event-এর attendee list।

```
Headers:
  Authorization: Bearer <token>

Success 200:
{
  "attendees": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "attendance_status": "going",
      "reminder_enabled": true,
      "created_at": "..."
    }
  ],
  "summary": {
    "total": 25,
    "going": 18,
    "maybe": 7
  }
}
```

---

## Database Tables

```sql
mosque_claims          -- claim requests
mosque_roles           -- owner/admin roles
mosque_announcements   -- mosque announcements
mosque_events          -- mosque events
mosque_event_attendees -- event attendees
favorite_mosques       -- followers (for notifications)
mosques_metadata       -- mosque info (is_claimed, owner_user_id)
```

---

## Error Response Format

```json
{
  "error": "Human readable message",
  "details": "Technical details (dev only)",
  "code": "PGRST200"
}
```

| Status | Meaning |
|--------|---------|
| 400 | Bad request / validation error |
| 401 | Missing or expired token |
| 403 | Valid token but no permission |
| 404 | Resource not found |
| 409 | Conflict (duplicate, wrong status) |
| 500 | Server error |
