# Flutter Mosque App — New API Integration Prompt

Copy everything below the line and paste into Claude inside your Flutter project.

---

## WHAT IS ALREADY DONE (do NOT re-implement these)

- ✅ User login / logout — token is already stored
- ✅ Mosque list screen — mosques are already fetched and displayed
- ✅ Prayer times — already showing and updatable on the mosque detail screen

## WHAT YOU NEED TO BUILD NOW

The app already has a logged-in user with a valid JWT token stored in the app.
The mosque object is already available (has `mosque_id`, `name`, `is_claimed`, etc.).

You need to update the **MosqueDetailScreen** to add:

1. **"Claim this mosque" banner** — shown when mosque is unclaimed
2. **4 tabs** — Prayers (already exists) | Updates | Events | Donate
3. **Updates tab** — list announcements; owner/admin can create/edit/delete
4. **Events tab** — list events; owner/admin can create/edit/delete; users can RSVP
5. **Donate tab** — UI placeholder only (backend not ready)

---

## TARGET UI DESIGN

The mosque detail screen must follow this layout (based on reference design):

```
┌─────────────────────────────────────────────┐
│  < Back                              🔔      │
│                                             │
│  Mosque Name                                │
│  📍 0.88 miles · 1105 Concord Ave           │
│                                             │
│  [  ✓ Follow  ]   [  ➤ Directions  ]        │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │ ⚠ This mosque is unclaimed          │    │  ← show only if NOT claimed
│  │                  [ Claim this mosque]│    │
│  └─────────────────────────────────────┘    │
│                                             │
│  [ Prayers ] [ Updates ] [ Events ] [Donate]│  ← TabBar
│  ─────────────────────────────────────────  │
│                                             │
│  (tab content here)                         │
│                                             │
└─────────────────────────────────────────────┘
```

### Claim Banner Logic
```dart
// Show the yellow "unclaimed" banner ONLY when:
mosque.isClaimed == false

// Hide it when:
mosque.isClaimed == true  OR  userRole == 'owner' || 'admin'
```

### Tab Visibility
All 4 tabs are always visible to everyone.
The difference is what each tab shows based on role:

| Tab      | Regular User          | Owner / Admin                      |
|----------|-----------------------|------------------------------------|
| Prayers  | Read only             | Read + Update button               |
| Updates  | Read list only        | Read list + FAB to create/edit/del |
| Events   | Read list + RSVP      | Read list + FAB to create/edit/del |
| Donate   | "Coming Soon" screen  | "Coming Soon" screen               |

### Updates Tab UI
```
┌─────────────────────────────────────────┐
│ Updates                          [+ Add] │  ← show [+ Add] only if owner/admin
│                                          │
│  ┌───────────────────────────────────┐   │
│  │ 📢 Friday Prayer Change           │   │
│  │ Prayer will be at 1:30 PM         │   │
│  │ Jun 14, 2026            [Edit][Del]│  │  ← Edit/Del only for owner/admin
│  └───────────────────────────────────┘   │
│  ┌───────────────────────────────────┐   │
│  │ 📢 Ramadan Schedule Updated       │   │
│  └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Events Tab UI
```
┌─────────────────────────────────────────┐
│ Events                           [+ Add] │  ← show [+ Add] only if owner/admin
│                                          │
│  ┌───────────────────────────────────┐   │
│  │ 📅 Eid Celebration                │   │
│  │ Jul 1, 2026 · 8:00 AM             │   │
│  │ Main Prayer Hall                  │   │
│  │ 38 going · 7 maybe                │   │
│  │ [ Going ]  [ Maybe ]  [ Cancel ]  │   │  ← RSVP buttons for users
│  └───────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### Donate Tab UI
```
┌─────────────────────────────────────────┐
│                                          │
│        💰                                │
│   No active campaign right now           │
│   Check back soon — admins can           │
│   launch a fundraiser any time.          │
│                                          │
└─────────────────────────────────────────┘
```
(matches the "SUPPORT YOUR MASJID" card from reference image)

---

## EXISTING TOKEN USAGE

The app already stores the token. For every new API call, just add this header:

```dart
// Token already exists — get it from your existing auth storage
final token = await authService.getToken(); // or however token is stored

headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

If using `dio`, add an interceptor once:

```dart
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await authService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

---

## BASE URL

```dart
// Android emulator
const baseUrl = 'http://10.0.2.2:3002';

// iOS simulator / physical device on same wifi
// const baseUrl = 'http://localhost:3002';
```

---

## PERMISSION SYSTEM

| Role  | Announcements       | Events              | Donations | Manage Admins |
|-------|---------------------|---------------------|-----------|---------------|
| owner | create/edit/delete  | create/edit/delete  | TBD       | ✅            |
| admin | create/edit/delete  | create/edit/delete  | TBD       | ❌            |
| user  | read only           | read only + RSVP    | TBD       | ❌            |

Check the user's role for a mosque to show/hide management buttons (owner dashboard).
Role is stored in `mosque_roles` table in Supabase — the claim verify API automatically creates it.

---

## DATA MODELS

```dart
class MosqueClaim {
  final String id;
  final String mosqueId;
  final String userId;
  final String? mosqueEmail;
  final String? mosquePhone;
  final String? position;
  final String? notes;
  // status: 'pending' | 'approved' | 'rejected' | 'verified'
  final String status;
  final String? verificationCode;
  // verificationStatus: 'pending' | 'verified'
  final String verificationStatus;
  final String? verifiedAt;
  final String createdAt;
  // mosque info nested:
  final String? mosqueName;
  final String? mosqueAddress;
}

class MosqueAnnouncement {
  final String id;
  final String mosqueId;
  final String title;
  final String content;
  final String createdBy;
  final String createdAt;
}

class MosqueEvent {
  final String id;
  final String mosqueId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime? endDate;
  final String? location;
  final String? imageUrl;
  final int? maxAttendees;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
}

class EventAttendance {
  final String id;
  final String eventId;
  final String userId;
  // attendanceStatus: 'going' | 'maybe'
  final String attendanceStatus;
  final bool reminderEnabled;
  final String createdAt;
}
```

---

## API REFERENCE

All routes are relative to `baseUrl = 'http://10.0.2.2:3002'`

---

### 1. MOSQUE CLAIM FLOW

```
User taps "Claim Mosque"
  → POST /api/mosque-claims          (submit claim)

User goes to "My Claims" screen
  → GET  /api/mosque-claims/my       (see claim status)

When status == 'approved', user enters postal code
  → POST /api/mosque-claims/verify   (becomes owner)
```

#### POST /api/mosque-claims
```
Headers: Authorization: Bearer <token>

Body:
{
  "mosque_id": "uuid",           // required — from existing mosque object
  "mosque_email": "...",         // optional
  "mosque_phone": "...",         // optional
  "position": "Imam",            // optional
  "notes": "I manage this..."    // optional
}

Success 201:
{ "success": true, "claim": { ...MosqueClaim } }

Errors:
  400 — mosque_id missing
  404 — mosque not found
  409 — mosque already claimed OR duplicate active claim from same user
```

#### GET /api/mosque-claims/my
```
Headers: Authorization: Bearer <token>

Response:
{
  "claims": [
    {
      "id": "uuid",
      "mosque_id": "uuid",
      "status": "pending",            // pending | approved | rejected | verified
      "verification_status": "pending",
      "created_at": "2026-06-14T...",
      "mosque": {
        "mosque_id": "uuid",
        "name": "Al-Aqsa Mosque",
        "address": "..."
      }
    }
  ]
}
```

#### POST /api/mosque-claims/verify
```
Headers: Authorization: Bearer <token>

Body:
{
  "mosque_id": "uuid",
  "verification_code": "DH-ABC123"   // code sent by postal mail
}

Success:
{ "success": true, "message": "Mosque ownership verified successfully" }

Errors:
  404 — no approved claim for this mosque
  400 — wrong verification code
```

---

### 2. ANNOUNCEMENTS

#### GET /api/mosques/:mosqueId/announcements
```
No auth required (public)
Query: ?page=1&limit=20

Response:
{
  "announcements": [
    {
      "id": "uuid",
      "mosque_id": "uuid",
      "title": "Friday Prayer",
      "content": "Prayer at 1:30 PM",
      "created_by": "user_uuid",
      "created_at": "2026-06-14T..."
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3
  }
}
```

#### POST /api/mosques/:mosqueId/announcements
```
Headers: Authorization: Bearer <token>

Body:
{
  "title": "Important Notice",
  "content": "Full text of the announcement here."
}

Success 201:
{
  "success": true,
  "announcement": { ...MosqueAnnouncement },
  "notification": { "queued": true, "recipientCount": 120 }
}

Errors:
  400 — title or content missing
  401 — not logged in
  403 — user is not owner or admin of this mosque
```

#### PUT /api/announcements/:id
```
Headers: Authorization: Bearer <token>

Body (all fields optional):
{
  "title": "Updated title",
  "content": "Updated content"
}

Success:
{ "success": true, "announcement": { ...MosqueAnnouncement } }

Errors:
  404 — not found
  403 — not owner or admin
```

#### DELETE /api/announcements/:id
```
Headers: Authorization: Bearer <token>

Success:
{ "success": true, "message": "Announcement deleted" }

Errors:
  404 — not found
  403 — not owner or admin
```

---

### 3. EVENTS

#### GET /api/mosques/:mosqueId/events
```
No auth required (public)
Query: ?page=1&limit=20&upcoming=true

upcoming=true → only returns future events (event_date >= now)

Response:
{
  "events": [
    {
      "id": "uuid",
      "mosque_id": "uuid",
      "title": "Eid Celebration",
      "description": "...",
      "event_date": "2026-07-01T08:00:00.000Z",
      "end_date": "2026-07-01T12:00:00.000Z",
      "location": "Main Prayer Hall",
      "image_url": null,
      "max_attendees": 300,
      "is_active": true,
      "created_at": "...",
      "updated_at": "..."
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 8, "totalPages": 1 }
}
```

#### POST /api/mosques/:mosqueId/events
```
Headers: Authorization: Bearer <token>

Body:
{
  "title": "Eid Celebration",              // required
  "event_date": "2026-07-01T08:00:00Z",   // required — ISO 8601 UTC
  "description": "...",                    // optional
  "end_date": "2026-07-01T12:00:00Z",     // optional
  "location": "Main Hall",                 // optional
  "image_url": "https://...",              // optional
  "max_attendees": 300                     // optional
}

Success 201:
{
  "success": true,
  "event": { ...MosqueEvent },
  "notification": { "queued": true, "recipientCount": 120 }
}

Errors:
  400 — title or event_date missing
  403 — not owner or admin
```

#### PUT /api/events/:eventId
```
Headers: Authorization: Bearer <token>

Body (send only fields you want to update):
{
  "title": "New title",
  "description": "...",
  "event_date": "ISO string",
  "end_date": "ISO string",
  "location": "...",
  "image_url": "...",
  "max_attendees": 200,
  "is_active": false        // set false to cancel event
}

Success:
{ "success": true, "event": { ...MosqueEvent } }
```

#### DELETE /api/events/:eventId
```
Headers: Authorization: Bearer <token>

Success:
{ "success": true, "message": "Event deleted" }
```

#### POST /api/events/:eventId/attend   (user RSVP)
```
Headers: Authorization: Bearer <token>

Body:
{
  "attendance_status": "going",   // 'going' | 'maybe'
  "reminder_enabled": true        // optional
}

Success:
{ "success": true, "attendance": { ...EventAttendance } }

Errors:
  404 — event not found or inactive
  409 — event is at full capacity
```

#### DELETE /api/events/:eventId/attend   (cancel RSVP)
```
Headers: Authorization: Bearer <token>

Success:
{ "success": true, "message": "Attendance removed" }
```

#### GET /api/events/:eventId/attendees   (owner/admin view)
```
Headers: Authorization: Bearer <token>

Response:
{
  "attendees": [ { ...EventAttendance } ],
  "summary": { "total": 45, "going": 38, "maybe": 7 }
}
```

---

### 4. DONATIONS

**Backend not implemented yet.**

Build a screen with placeholder UI:

```dart
// DonationsScreen
Scaffold(
  appBar: AppBar(title: Text('Donations')),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.volunteer_activism, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text('Coming Soon', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Donation feature is being built', style: TextStyle(color: Colors.grey)),
      ],
    ),
  ),
)
```

No API calls. No service file needed yet.

---

## SCREEN FLOW TO BUILD

```
MosqueDetailScreen  (update this existing screen)
  │
  ├─ [Unclaimed banner] "Claim this mosque" button
  │     └─ opens ClaimMosqueBottomSheet
  │           └─ Form: mosque_email, mosque_phone, position, notes
  │           └─ POST /api/mosque-claims
  │           └─ On success: show toast "Claim submitted, check My Claims"
  │
  ├─ [My Claims] link/button  →  MyClaimsScreen
  │     ├─ GET /api/mosque-claims/my
  │     └─ Status badges:
  │           pending  → "Under Review" (yellow chip)
  │           approved → show "Enter verification code" input + Submit
  │                       └─ POST /api/mosque-claims/verify
  │                             └─ On success: refresh mosque detail
  │                                           (banner hides, owner tabs unlock)
  │           rejected → "Rejected" (red chip)
  │           verified → "Verified Owner ✓" (green chip)
  │
  └─ TabBar: [ Prayers ] [ Updates ] [ Events ] [ Donate ]
        │
        ├─ Prayers tab  (already built — keep as is)
        │
        ├─ Updates tab
        │     ├─ GET /api/mosques/:mosqueId/announcements  (load on tab open)
        │     ├─ ListView of announcement cards
        │     ├─ If owner/admin: FloatingActionButton → CreateAnnouncementSheet
        │     │     └─ POST /api/mosques/:mosqueId/announcements
        │     └─ If owner/admin: each card has Edit / Delete icons
        │           ├─ PUT    /api/announcements/:id
        │           └─ DELETE /api/announcements/:id
        │
        ├─ Events tab
        │     ├─ GET /api/mosques/:mosqueId/events?upcoming=true
        │     ├─ ListView of event cards
        │     ├─ Each card shows: title, date, location, going/maybe count
        │     ├─ RSVP buttons for regular users:
        │     │     ├─ POST   /api/events/:eventId/attend  { attendance_status: 'going' }
        │     │     ├─ POST   /api/events/:eventId/attend  { attendance_status: 'maybe' }
        │     │     └─ DELETE /api/events/:eventId/attend
        │     ├─ If owner/admin: FAB → CreateEventSheet
        │     │     └─ POST /api/mosques/:mosqueId/events
        │     └─ If owner/admin: each card has Edit / Delete icons
        │           ├─ PUT    /api/events/:eventId
        │           └─ DELETE /api/events/:eventId
        │
        └─ Donate tab
              └─ Static "Coming Soon" card UI (no API)
                    "No active campaign right now"
                    "Check back soon — admins can launch a fundraiser any time."
```

---

## ERROR HANDLING

All error responses:
```json
{ "error": "message", "details": "optional extra" }
```

| Status | Meaning |
|--------|---------|
| 200 | OK |
| 201 | Created |
| 400 | Bad request / validation error |
| 401 | Token missing or invalid |
| 403 | Logged in but not owner/admin |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 500 | Server error |

Show a `SnackBar` for all errors using `response['error']` as the message.

---

## IMPORTANT NOTES

- `mosque_id` is already in the existing mosque object in the app — pass it directly to all API calls
- User's token is already available — do NOT re-implement login
- All dates from API are ISO 8601 strings — parse with `DateTime.parse(str)`
- Use `DateTime.now().toUtc().toIso8601String()` when sending dates to API
- Donations: build placeholder screen only, no network calls
