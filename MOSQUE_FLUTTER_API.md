# Mosque API — Flutter Integration Guide

**Base URL (Local):** `http://localhost:3002`
**Base URL (Production):** `https://your-domain.com`

---

## Authentication

সব API-এ (GET ছাড়া) এই Header পাঠাতে হবে:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

### Token নেওয়ার নিয়ম

```
POST https://gbfgotocraqfbzovzzum.supabase.co/auth/v1/token?grant_type=password

Headers:
  apikey: <SUPABASE_ANON_KEY>
  Content-Type: application/json

Body:
{
  "email": "user@email.com",
  "password": "password123"
}

Response:
{
  "access_token": "eyJhbGci...",
  "expires_in": 3600
}
```

> Token **১ ঘন্টা** পর expire হয়। নতুন token নিতে হবে।

---

## Permission Rules

| Role  | Announcement | Event | Admin Management |
|-------|-------------|-------|-----------------|
| owner | ✅ Create / Edit / Delete | ✅ Create / Edit / Delete | ✅ Add / Remove |
| admin | ✅ Create / Edit / Delete | ✅ Create / Edit / Delete | ❌ |
| user  | ❌ | ❌ | ❌ |

> **Note:** Owner role পেতে হলে Claim verify করতে হবে।

---
---

# 1. CLAIM APIs

Mosque-এর ownership claim করার flow।

## Claim Flow

```
Step 1 → User claim submit করে
Step 2 → Admin review করে → Approve করে
Step 3 → System verification code তৈরি করে (DH-XXXXXX)
Step 4 → Admin postal mail-এ code পাঠায়
Step 5 → User code enter করে → Verified!
```

---

## 1.1 Claim Submit করা

```
POST /api/mosque-claims
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "mosque_id": "mosque_abc123",
  "position": "Imam",
  "mosque_email": "imam@mosque.com",
  "mosque_phone": "01700000000",
  "notes": "I have been the head imam for 5 years."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| mosque_id | string | ✅ | Mosque-এর unique ID |
| position | string | ❌ | পদবি (Imam, President, Secretary) |
| mosque_email | string | ❌ | Mosque-এর official email |
| mosque_phone | string | ❌ | Mosque-এর phone number |
| notes | string | ❌ | অতিরিক্ত তথ্য |

**Success Response `201`:**
```json
{
  "success": true,
  "claim": {
    "id": "claim_uuid",
    "mosque_id": "mosque_abc123",
    "user_id": "user_uuid",
    "position": "Imam",
    "status": "pending",
    "verification_status": "pending",
    "verified_at": null,
    "created_at": "2026-06-13T10:00:00Z"
  }
}
```

**Error Responses:**
```json
// 401 — Token নেই বা expired
{ "error": "Unauthorized" }

// 404 — Mosque পাওয়া যায়নি
{ "error": "Mosque not found" }

// 409 — Mosque already claimed
{ "error": "Mosque is already claimed" }

// 409 — Already submitted
{ "error": "You already have an active claim for this mosque" }
```

---

## 1.2 আমার Claims দেখা

```
GET /api/mosque-claims/my
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "claims": [
    {
      "id": "claim_uuid",
      "mosque_id": "mosque_abc123",
      "position": "Imam",
      "status": "approved",
      "verification_status": "pending",
      "verified_at": null,
      "created_at": "2026-06-13T10:00:00Z",
      "mosque": {
        "mosque_id": "mosque_abc123",
        "name": "Baitul Mukarram",
        "address": "Topkhana Road, Dhaka"
      }
    }
  ]
}
```

**Status Values:**
| Status | অর্থ |
|--------|------|
| `pending` | Admin review করেনি |
| `approved` | Admin approve করেছে, code পাঠানো হবে |
| `rejected` | Admin reject করেছে |
| `verified` | Code দিয়ে verify হয়েছে, owner হয়েছে |

---

## 1.3 Verification Code দিয়ে Verify করা

Admin approve করার পর postal mail-এ code পাঠাবে। User সেই code দিয়ে verify করবে।

```
POST /api/mosque-claims/verify
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "mosque_id": "mosque_abc123",
  "verification_code": "DH-728451"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| mosque_id | string | ✅ | Mosque-এর ID |
| verification_code | string | ✅ | Admin-এর দেওয়া code |

**Success Response `200`:**
```json
{
  "success": true,
  "message": "Mosque ownership verified successfully"
}
```

**Error Responses:**
```json
// 404 — Approved claim নেই
{ "error": "No approved claim found for this mosque" }

// 400 — Code ভুল
{ "error": "Invalid verification code" }
```

---
---

# 2. ANNOUNCEMENT APIs

Mosque-এর announcements manage করা। শুধু mosque-এর **owner** বা **admin** তৈরি / আপডেট / মুছতে পারবে।

---

## 2.1 Announcements দেখা

```
GET /api/mosques/:mosqueId/announcements
```

**Query Params (Optional):**
```
page  = 1      (default)
limit = 20     (default)
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "announcements": [
    {
      "id": "ann_uuid",
      "mosque_id": "mosque_abc123",
      "title": "Friday Prayer Notice",
      "content": "Jumma prayer will be at 1:30 PM this Friday.",
      "created_by": "user_uuid",
      "created_at": "2026-06-13T08:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "totalPages": 1
  }
}
```

---

## 2.2 Announcement তৈরি করা

```
POST /api/mosques/:mosqueId/announcements
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Friday Prayer Notice",
  "content": "Jumma prayer will be at 1:30 PM this Friday. All brothers are requested to come early."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | ✅ | Announcement-এর শিরোনাম |
| content | string | ✅ | বিস্তারিত বিবরণ |

**Success Response `201`:**
```json
{
  "success": true,
  "announcement": {
    "id": "ann_uuid",
    "mosque_id": "mosque_abc123",
    "title": "Friday Prayer Notice",
    "content": "Jumma prayer will be at 1:30 PM this Friday.",
    "created_by": "user_uuid",
    "created_at": "2026-06-13T08:00:00Z"
  },
  "notification": {
    "queued": true,
    "recipientCount": 42
  }
}
```

**Error Responses:**
```json
// 403 — Owner/Admin না হলে
{ "error": "Forbidden: owner or admin role required" }

// 400 — Required field missing
{ "error": "title and content are required" }
```

---

## 2.3 Announcement আপডেট করা

```
PUT /api/announcements/:id
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Updated: Friday Prayer Notice",
  "content": "Prayer time changed to 2:00 PM due to rain."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | ❌ | নতুন শিরোনাম |
| content | string | ❌ | নতুন বিবরণ |

**Success Response `200`:**
```json
{
  "success": true,
  "announcement": {
    "id": "ann_uuid",
    "title": "Updated: Friday Prayer Notice",
    "content": "Prayer time changed to 2:00 PM due to rain.",
    "created_at": "2026-06-13T08:00:00Z"
  }
}
```

---

## 2.4 Announcement মুছে ফেলা

```
DELETE /api/announcements/:id
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "success": true,
  "message": "Announcement deleted"
}
```

---
---

# 3. EVENT APIs

Mosque-এর events manage করা।

---

## 3.1 Events দেখা

```
GET /api/mosques/:mosqueId/events
```

**Query Params (Optional):**
```
page     = 1      (default)
limit    = 20     (default)
upcoming = true   (শুধু upcoming events)
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "events": [
    {
      "id": "event_uuid",
      "mosque_id": "mosque_abc123",
      "title": "Eid Prayer 2026",
      "description": "Eid ul-Adha prayer at the main mosque ground.",
      "event_date": "2026-07-01T06:00:00Z",
      "end_date": "2026-07-01T08:00:00Z",
      "location": "Mosque Main Ground, Dhaka",
      "max_attendees": 500,
      "is_active": true,
      "created_by": "user_uuid",
      "created_at": "2026-06-13T08:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 3,
    "totalPages": 1
  }
}
```

---

## 3.2 Event তৈরি করা

```
POST /api/mosques/:mosqueId/events
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Eid Prayer 2026",
  "description": "Eid ul-Adha prayer at the main mosque ground.",
  "event_date": "2026-07-01T06:00:00Z",
  "end_date": "2026-07-01T08:00:00Z",
  "location": "Mosque Main Ground, Dhaka",
  "image_url": "https://example.com/eid.jpg",
  "max_attendees": 500
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | ✅ | Event-এর নাম |
| event_date | string (ISO) | ✅ | শুরুর তারিখ ও সময় |
| description | string | ❌ | বিস্তারিত বিবরণ |
| end_date | string (ISO) | ❌ | শেষের তারিখ ও সময় |
| location | string | ❌ | স্থান |
| image_url | string | ❌ | Event-এর ছবির URL |
| max_attendees | number | ❌ | সর্বোচ্চ অংশগ্রহণকারী |

**Success Response `201`:**
```json
{
  "success": true,
  "event": {
    "id": "event_uuid",
    "mosque_id": "mosque_abc123",
    "title": "Eid Prayer 2026",
    "event_date": "2026-07-01T06:00:00Z",
    "is_active": true,
    "created_at": "2026-06-13T08:00:00Z"
  },
  "notification": {
    "queued": true,
    "recipientCount": 42
  }
}
```

**Error Responses:**
```json
// 403 — Owner/Admin না হলে
{ "error": "Forbidden: owner or admin role required" }

// 400 — Required field missing
{ "error": "title and event_date are required" }
```

---

## 3.3 Event আপডেট করা

```
PUT /api/events/:eventId
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Eid Prayer 2026 — Updated",
  "description": "Venue changed.",
  "event_date": "2026-07-02T06:00:00Z",
  "end_date": "2026-07-02T08:00:00Z",
  "location": "Mosque Rooftop, Dhaka",
  "max_attendees": 300,
  "is_active": true
}
```

> সব field optional। শুধু যা পরিবর্তন করতে চান তা পাঠান।

**Success Response `200`:**
```json
{
  "success": true,
  "event": {
    "id": "event_uuid",
    "title": "Eid Prayer 2026 — Updated",
    "location": "Mosque Rooftop, Dhaka",
    "updated_at": "2026-06-13T10:00:00Z"
  }
}
```

---

## 3.4 Event মুছে ফেলা

```
DELETE /api/events/:eventId
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "success": true,
  "message": "Event deleted"
}
```

---
---

# 4. ATTENDANCE APIs

Event-এ অংশগ্রহণ করা বা বাতিল করা।

---

## 4.1 Event-এ Attend করা

```
POST /api/events/:eventId/attend
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "attendance_status": "going",
  "reminder_enabled": true
}
```

| Field | Type | Required | Values |
|-------|------|----------|--------|
| attendance_status | string | ✅ | `going` বা `maybe` |
| reminder_enabled | boolean | ❌ | `true` বা `false` (default: false) |

**Success Response `200`:**
```json
{
  "success": true,
  "attendance": {
    "id": "att_uuid",
    "event_id": "event_uuid",
    "user_id": "user_uuid",
    "attendance_status": "going",
    "reminder_enabled": true,
    "created_at": "2026-06-13T10:00:00Z"
  }
}
```

**Error Responses:**
```json
// 404 — Event পাওয়া যায়নি
{ "error": "Event not found" }

// 409 — Event inactive
{ "error": "Event is no longer active" }

// 409 — Full capacity
{ "error": "Event is at full capacity" }

// 400 — Wrong status value
{ "error": "attendance_status must be \"going\" or \"maybe\"" }
```

---

## 4.2 Attendance বাতিল করা

```
DELETE /api/events/:eventId/attend
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "success": true,
  "message": "Attendance removed"
}
```

---

## 4.3 Attendee List দেখা

```
GET /api/events/:eventId/attendees
```

**Headers:**
```
Authorization: Bearer <token>
```

**Request Body:** নেই

**Success Response `200`:**
```json
{
  "attendees": [
    {
      "id": "att_uuid",
      "event_id": "event_uuid",
      "user_id": "user_uuid",
      "attendance_status": "going",
      "reminder_enabled": true,
      "created_at": "2026-06-13T10:00:00Z"
    },
    {
      "id": "att_uuid2",
      "user_id": "user_uuid2",
      "attendance_status": "maybe",
      "reminder_enabled": false,
      "created_at": "2026-06-13T11:00:00Z"
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
---

# Error Reference

| HTTP Status | অর্থ | সমাধান |
|-------------|------|--------|
| `400` | Request body ভুল | Required field check করুন |
| `401` | Token নেই বা expired | নতুন token নিন |
| `403` | Permission নেই | Owner/Admin role দরকার |
| `404` | Resource পাওয়া যায়নি | ID সঠিক কিনা দেখুন |
| `409` | Conflict | Error message পড়ুন |
| `500` | Server error | details field দেখুন |

---

# Quick Test Sequence

```
1. Token নিন          → Supabase auth
2. Claim করুন         → POST /api/mosque-claims
3. Admin approve       → PUT /api/admin/mosque-claims/:id/approve
4. Verify করুন        → POST /api/mosque-claims/verify
5. Announcement দিন   → POST /api/mosques/:mosqueId/announcements
6. Event তৈরি করুন   → POST /api/mosques/:mosqueId/events
7. Attend করুন        → POST /api/events/:eventId/attend
8. List দেখুন         → GET /api/events/:eventId/attendees
```
