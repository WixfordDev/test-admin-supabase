# Owner Dashboard — Flutter Integration Reference

এই একটা ফাইলে owner-এর app dashboard screen বানানোর জন্য যত API লাগবে (**শুধু GET/read** — create/edit/delete আলাদা screen-এ, এখানে নেই), তার সম্পূর্ণ request/response reference।

**Base URL:** `https://admin.deenhub.app`

**Auth Header (সব API-তে):**
```
Authorization: Bearer <owner_supabase_jwt>
```
টোকেন যেই user-এর, সেই user-কে অবশ্যই সংশ্লিষ্ট মসজিদের verified, unblocked **owner** হতে হবে — নাহলে `403 Forbidden` আসবে।

Postman collection: [`DeenHub-Owner-Dashboard.postman_collection.json`](DeenHub-Owner-Dashboard.postman_collection.json) → folder **"📊 Dashboard (Read-only)"**।

---

## 1. Overview — `GET /api/mosques/{mosqueId}/overview`

App খোলার সাথে সাথে এই একটা কল দিয়েই home/overview screen-এর সব সংখ্যা পাওয়া যায়।

```json
{
  "success": true,
  "data": {
    "mosque": { "mosque_id": "user_mosque_...", "name": "Al-Noor Mosque" },
    "announcements": { "total": 5 },
    "events": { "total": 8, "upcoming": 3 },
    "campaigns": {
      "total": 4,
      "active": 2,
      "total_raised_cents": 125000,
      "total_goal_cents": 500000
    },
    "donations": {
      "total_amount_cents": 300000,
      "total_mosque_amount_cents": 294000,
      "total_transactions": 45,
      "monthly_amount_cents": 20000,
      "monthly_transactions": 3
    },
    "stripe": { "status": "connected", "account_status": "active" }
  }
}
```

| Field | ব্যবহার |
|---|---|
| `campaigns.total_raised_cents` / `total_goal_cents` | সব campaign মিলিয়ে progress bar |
| `donations.total_amount_cents` | সব-সময়ের total donation |
| `donations.monthly_amount_cents` | এই মাসের donation |
| `stripe.status` | `connected` হলে dashboard-এ green badge, `pending`/`not_connected` হলে warning দেখাও |

> সব amount **cents**-এ — `125000` = $1,250.00।

---

## 2. Announcements — `GET /api/mosques/{mosqueId}/announcements`

**Query params:** `page`, `limit` (default 20), `start_date=YYYY-MM-DD`, `end_date=YYYY-MM-DD` (সব optional)

```json
{
  "announcements": [
    {
      "id": "uuid",
      "mosque_id": "user_mosque_...",
      "title": "Jumma Prayer Time Update",
      "content": "This Friday's Jumma prayer starts at 1:30 PM.",
      "created_by": "uuid",
      "created_at": "2026-09-01T10:00:00Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 5, "totalPages": 1 }
}
```

---

## 3. Events — `GET /api/mosques/{mosqueId}/events`

**Query params:** `page`, `limit`, `upcoming=true` (শুধু ভবিষ্যতের event), `start_date=YYYY-MM-DD`, `end_date=YYYY-MM-DD`

```json
{
  "events": [
    {
      "id": "uuid",
      "mosque_id": "user_mosque_...",
      "title": "Community Iftar",
      "description": "Join us for a community iftar gathering.",
      "event_date": "2026-09-15T18:00:00Z",
      "end_date": "2026-09-15T20:00:00Z",
      "location": "Main Hall",
      "image_url": "https://example.com/iftar.jpg",
      "max_attendees": 100,
      "is_active": true,
      "attendee_count": { "going": 12, "maybe": 3, "total": 15 },
      "created_at": "2026-09-01T10:00:00Z"
    }
  ],
  "pagination": { "page": 1, "limit": 20, "total": 8, "totalPages": 1 }
}
```

> `attendee_count` প্রতিটা event-এর সাথেই আসে — list screen-এ "১৫ জন যোগ দিচ্ছে" দেখানোর জন্য আলাদা কল লাগবে না।

**Date range উদাহরণ (১ থেকে ১০ তারিখ):**
```
GET /api/mosques/{mosqueId}/events?start_date=2026-09-01&end_date=2026-09-10
```

### কোনো একটা event-এ ট্যাপ করলে (কারা attend করছে পুরো লিস্ট) — `GET /api/events/{eventId}/attendees`
```json
{
  "attendees": [
    { "id": "uuid", "event_id": "uuid", "user_id": "uuid", "attendance_status": "going", "reminder_enabled": true, "created_at": "..." }
  ],
  "summary": { "total": 15, "going": 12, "maybe": 3 }
}
```

---

## 4. Campaigns — `GET /api/mosques/{mosqueId}/campaigns`

**Query params:** `page`, `limit`, `active=true`, `start_date=YYYY-MM-DD`, `end_date=YYYY-MM-DD`

```json
{
  "success": true,
  "data": {
    "campaigns": [
      {
        "id": "uuid",
        "mosque_id": "user_mosque_...",
        "title": "Mosque Renovation 2026",
        "category": "renovation",
        "goal_amount": 500000,
        "raised_amount": 125000,
        "currency": "usd",
        "start_date": "2026-09-01",
        "end_date": "2026-12-31",
        "no_end_date": false,
        "is_active": true,
        "created_at": "2026-09-01T10:00:00Z"
      }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 4, "totalPages": 1 }
  }
}
```

> প্রতিটা campaign-এর progress = `raised_amount / goal_amount`। `no_end_date: true` হলে deadline দেখানোর দরকার নেই (কখনো expire হবে না)।

---

## 5. Donations — `GET /api/mosques/{mosqueId}/donations`

**Query params:** `page`, `limit`

```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "uuid",
        "mosque_id": "user_mosque_...",
        "campaign_id": "uuid or null",
        "amount": 1000,
        "mosque_amount": 980,
        "platform_fee": 20,
        "currency": "usd",
        "status": "completed",
        "receipt_url": "https://...",
        "created_at": "2026-09-01T10:00:00Z"
      }
    ],
    "pagination": { "page": 1, "limit": 20, "total": 45, "totalPages": 3 }
  }
}
```

> শুধু `status: "completed"` transaction-ই আসে — donor checkout শুরু করে শেষ না করলে (abandoned) সেটা এখানে দেখাবে না।

---

## 6. Stripe Status — `GET /api/mosques/{mosqueId}/stripe/status`

```json
{
  "success": true,
  "data": {
    "status": "connected",
    "charges_enabled": true,
    "payouts_enabled": true,
    "details_submitted": true,
    "stripe_account_id": "acct_..."
  }
}
```
`status`: `connected` | `pending` | `not_connected` (admin-disabled account-ও `pending` হিসেবে দেখায় এখানে)

---

## 7. Stripe Dashboard (Balance + Stats) — `GET /api/mosques/{mosqueId}/stripe/dashboard`

```json
{
  "success": true,
  "data": {
    "status": "active",
    "charges_enabled": true,
    "payouts_enabled": true,
    "stripe_account_id": "acct_...",
    "balance": {
      "available": [{ "amount": 9800, "currency": "usd" }],
      "pending": [{ "amount": 0, "currency": "usd" }]
    },
    "stats": {
      "total_donations_cents": 300000,
      "total_mosque_amount_cents": 294000,
      "total_transactions": 45,
      "monthly_donations_cents": 20000,
      "monthly_transactions": 3
    }
  }
}
```
> `balance` সরাসরি live Stripe থেকে আসে — Stripe account connect না থাকলে `balance: null` আসবে।

---

## Error Responses (সব endpoint-এই একই shape)

```json
{ "success": false, "message": "Error description" }
```

| Code | কারণ |
|---|---|
| 401 | Token নেই / expired |
| 403 | এই user এই মসজিদের owner না (বা blocked) |
| 404 | Mosque পাওয়া যায়নি |
| 500 | Server error |

---

## Flutter — Quick Integration Pattern

```dart
final res = await dio.get(
  '/api/mosques/$mosqueId/overview',
  options: Options(headers: {'Authorization': 'Bearer $ownerToken'}),
);
final overview = res.data['data'];
final totalDonations = overview['donations']['total_amount_cents'] / 100; // dollars
```

App খোলার সময়:
1. `overview` কল করে top summary card-গুলো ভরো
2. প্রতিটা ট্যাব (Announcements/Events/Campaigns/Donations) খোলার সময় সেই নির্দিষ্ট list endpoint আলাদা করে কল করো (pagination সহ)
3. Stripe connected না থাকলে (`overview.stripe.status !== 'connected'`) একটা banner দেখাও "Connect Stripe to receive donations"

---

সংশ্লিষ্ট আরও ডকুমেন্টেশন: [`DONATION_MODULE.md`](DONATION_MODULE.md) (পুরো architecture/flow), [`CAMPAIGN_API_REFERENCE.md`](CAMPAIGN_API_REFERENCE.md), [`DONATION_API_REFERENCE.md`](DONATION_API_REFERENCE.md)।
