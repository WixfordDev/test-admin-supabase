# Donation Module — Flutter API Reference

**Base URL:** `https://test-admin-supabase-kappa.vercel.app`

**Auth Header (সব API তে):**
```
Authorization: Bearer <supabase_jwt>
Content-Type: application/json
```

> Full architecture, DB schema এবং step-by-step flow (connect → donate → webhook → admin lock)-এর জন্য দেখো [`DONATION_MODULE.md`](DONATION_MODULE.md)। এই ফাইলটা শুধু request/response reference।

---

## 1. Stripe Connect APIs (Mosque Owner)

### Stripe Connect করো
```
POST /api/mosques/{mosqueId}/stripe/connect
```
**Body:** none

**Response (success):**
```json
{
  "success": true,
  "message": "Stripe onboarding link generated.",
  "data": {
    "onboarding_url": "https://connect.stripe.com/setup/..."
  }
}
```
> `onboarding_url` WebView বা browser এ খোলো। Owner onboarding শেষ করলে Stripe `GET /api/stripe/connect/return`-এ redirect করবে, যেটা status update করে `/stripe-connect?status=success|pending` ওয়েব পেজে পাঠায়।

**Response (409 — already connected):**
```json
{ "success": false, "message": "Stripe account is already fully connected" }
```

**Response (403 — admin disabled this account):**
```json
{
  "success": false,
  "message": "Your donation account was disabled by an admin. Please contact admin to re-enable it before reconnecting."
}
```
> **গুরুত্বপূর্ণ:** admin কোনো মসজিদের Stripe account disconnect করলে, owner **নিজে থেকে reconnect করতে পারবে না** — এই 403 আসবে। Owner-কে admin-এর সাথে যোগাযোগ করে account re-enable করাতে হবে, তারপর আবার এই endpoint কল করলে normal onboarding flow চলবে (একই Stripe account, স্ক্র্যাচ থেকে না)।

---

### Connection Status চেক করো
```
GET /api/mosques/{mosqueId}/stripe/status
```
**Body:** none

**Response:**
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
> `status` values: `connected` | `pending` | `not_connected`
> ⚠️ একটা admin-disabled account-ও এখানে `"pending"` দেখাবে — এই endpoint থেকে `disabled` আলাদা করে বোঝা যায় না। Owner নিজের mosque-এর জন্য raw status দেখতে চাইলে নিচের `/stripe/dashboard` ব্যবহার করবে (সেখানে raw `disabled` string দেখা যায়)।

---

### Owner Dashboard (Balance + Stats)
```
GET /api/mosques/{mosqueId}/stripe/dashboard
```
**Body:** none

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "active",
    "charges_enabled": true,
    "payouts_enabled": true,
    "balance": {
      "available": [{ "amount": 9800, "currency": "usd" }],
      "pending": [{ "amount": 0, "currency": "usd" }]
    },
    "stats": {
      "total_donations_cents": 100000,
      "total_mosque_amount_cents": 98000,
      "total_transactions": 10,
      "monthly_donations_cents": 20000,
      "monthly_transactions": 2
    }
  }
}
```
> সব amount cents এ — 9800 = $98.00

---

### Stripe Express Dashboard Link
```
GET /api/mosques/{mosqueId}/stripe/login-link
```
**Body:** none

**Response:**
```json
{
  "success": true,
  "message": "Stripe dashboard link generated.",
  "data": {
    "url": "https://connect.stripe.com/express/..."
  }
}
```
> One-time link। Owner এই URL এ গেলে তার Stripe dashboard দেখবে (balance, payouts, history)।
> **টাকা withdraw করার জন্য কোনো আলাদা API নেই** — withdrawal Stripe-এর নিজের Express Dashboard থেকেই হয়, এই link দিয়ে সেখানে ঢুকতে হবে। শুধু `charges_enabled = true` থাকলেই এই link কাজ করবে।

---

## 2. Donation APIs (User)

### General Donation — Mosque এ সরাসরি
```
POST /api/mosques/{mosqueId}/donate
```
**Body:**
```json
{
  "amount": 1000,
  "currency": "usd"
}
```
> `amount` cents এ। Minimum: 50 (= $0.50)

**Response:**
```json
{
  "success": true,
  "message": "Checkout session created.",
  "data": {
    "checkout_url": "https://checkout.stripe.com/pay/cs_...",
    "session_id": "cs_...",
    "amount": 1000,
    "currency": "usd",
    "platform_fee": 20,
    "mosque_amount": 980
  }
}
```
> `checkout_url` browser এ খোলো। Payment হলে mosque এর bank account এ automatically যাবে।

---

### Campaign Donation — Specific Campaign এ
```
POST /api/mosques/{mosqueId}/campaigns/{campaignId}/donate
```
**Body:**
```json
{
  "amount": 1000,
  "currency": "usd"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Checkout session created.",
  "data": {
    "checkout_url": "https://checkout.stripe.com/pay/cs_...",
    "session_id": "cs_...",
    "campaign_title": "Mosque Renovation 2026",
    "amount": 1000,
    "currency": "usd",
    "platform_fee": 20,
    "mosque_amount": 980
  }
}
```
> Campaign এর `raised_amount` automatically update হবে।

---

## 3. Campaign APIs (Mosque Owner)

> Campaign CRUD-এর সম্পূর্ণ, up-to-date reference (সব field, validation rules, error codes) আছে [`CAMPAIGN_API_REFERENCE.md`](CAMPAIGN_API_REFERENCE.md)-এ। নিচেরটা শুধু quick summary।

### Campaign তৈরি করো
```
POST /api/mosques/{mosqueId}/campaigns
```
**Body:**
```json
{
  "title": "Mosque Renovation 2026",
  "description": "We are raising funds to renovate our mosque building.",
  "category": "renovation",
  "goal_amount": 500000,
  "currency": "usd",
  "cover_image_url": "https://example.com/image.jpg",
  "start_date": "2026-07-11",
  "end_date": "2026-12-31",
  "no_end_date": false,
  "is_active": true
}
```

| Field | Required | Description |
|---|---|---|
| `title` | ✅ | Min 3 characters |
| `description` | ✅ | Campaign details |
| `category` | ✅ | নিচে দেখো |
| `goal_amount` | ✅ | Cents এ, min 100 |
| `currency` | ❌ | Default: `usd` |
| `cover_image_url` | ❌ | Banner image URL |
| `start_date` | ❌ | Format: YYYY-MM-DD |
| `end_date` | ❌ | Format: YYYY-MM-DD. `no_end_date: true` হলে ignore হবে |
| `no_end_date` | ❌ | Default: `false`. `true` দিলে campaign কখনো expire হবে না |
| `is_active` | ❌ | Default: `true` |

**Response:**
```json
{
  "success": true,
  "message": "Campaign created.",
  "data": {
    "campaign": {
      "id": "uuid",
      "mosque_id": "...",
      "title": "Mosque Renovation 2026",
      "category": "renovation",
      "goal_amount": 500000,
      "raised_amount": 0,
      "currency": "usd",
      "is_active": true,
      "created_at": "2026-07-11T..."
    }
  }
}
```

---

### Campaign List দেখো
```
GET /api/mosques/{mosqueId}/campaigns?page=1&limit=20&active=true
```
**Body:** none

**Query params:**
| Param | Description |
|---|---|
| `page` | Page number (default: 1) |
| `limit` | Per page (default: 20) |
| `active` | `true` = active only |

**Response:**
```json
{
  "success": true,
  "data": {
    "campaigns": [
      {
        "id": "uuid",
        "title": "Mosque Renovation 2026",
        "category": "renovation",
        "goal_amount": 500000,
        "raised_amount": 125000,
        "currency": "usd",
        "end_date": "2026-12-31",
        "is_active": true
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 3,
      "totalPages": 1
    }
  }
}
```

---

### Single Campaign দেখো
```
GET /api/mosques/{mosqueId}/campaigns/{campaignId}
```
**Body:** none

**Response:**
```json
{
  "success": true,
  "data": {
    "campaign": { ...full campaign object... }
  }
}
```

---

### Campaign Edit করো
```
PUT /api/mosques/{mosqueId}/campaigns/{campaignId}
```
**Body:** (সব field optional)
```json
{
  "title": "Updated Title",
  "is_active": false,
  "end_date": "2026-11-30"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Campaign updated.",
  "data": { "campaign": { ...updated campaign... } }
}
```

---

### Campaign Delete করো
```
DELETE /api/mosques/{mosqueId}/campaigns/{campaignId}
```
**Body:** none

**Response:**
```json
{
  "success": true,
  "message": "Campaign deleted."
}
```

---

### Owner এর Donation History
```
GET /api/mosques/{mosqueId}/donations?page=1&limit=20
```
**Body:** none

**Response:**
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "uuid",
        "campaign_id": "uuid or null",
        "amount": 1000,
        "mosque_amount": 980,
        "platform_fee": 20,
        "currency": "usd",
        "status": "completed",
        "receipt_url": "https://...",
        "created_at": "2026-07-11T..."
      }
    ],
    "pagination": { "page": 1, "total": 5, "totalPages": 1 }
  }
}
```

---

---

## 4. Mosque Admin Management (Owner Only)

### Admin List দেখো
```
GET /api/mosques/{mosqueId}/admins
Authorization: Bearer <owner_token>
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "members": [
      {
        "user_id": "uuid",
        "email": "admin@example.com",
        "role": "owner",
        "is_blocked": false,
        "added_at": "2026-07-12T10:00:00Z"
      },
      {
        "user_id": "uuid",
        "email": "helper@example.com",
        "role": "admin",
        "is_blocked": false,
        "added_at": "2026-07-12T11:00:00Z"
      }
    ]
  }
}
```

---

### Admin Add করো (Email দিয়ে)
```
POST /api/mosques/{mosqueId}/admins
Authorization: Bearer <owner_token>
```

**Body:**
```json
{
  "email": "helper@example.com"
}
```
> `user_id` দিয়েও add করা যাবে — যেকোনো একটা দিলেই হবে।

**Response (200):**
```json
{
  "success": true,
  "message": "Admin added successfully.",
  "data": {
    "user_id": "uuid",
    "role": "admin"
  }
}
```

| Error Code | কারণ |
|---|---|
| 400 | email বা user_id দাওনি / নিজেকে add করার চেষ্টা |
| 403 | Owner না |
| 404 | ওই email এ কোনো user নেই |
| 409 | ইতিমধ্যে admin বা owner |

---

### Admin Remove করো
```
DELETE /api/mosques/{mosqueId}/admins/{userId}
Authorization: Bearer <owner_token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Admin removed successfully."
}
```

> Admin remove হলে সে আর mosque এর announcements, events, donations manage করতে পারবে না।  
> Owner কে remove করা যাবে না।

---

## Campaign Categories

| Value | Label |
|---|---|
| `renovation` | Mosque Renovation |
| `ramadan` | Ramadan Appeal |
| `zakat` | Zakat Collection |
| `sadaqah` | Sadaqah Jariyah |
| `emergency` | Emergency Appeal |
| `education` | Islamic Education |
| `general` | General Donation |
| `other` | Other |

---

## Error Response

```json
{
  "success": false,
  "message": "Error description"
}
```

| Code | কারণ |
|---|---|
| 401 | Token নেই বা invalid |
| 403 | Owner না, অথবা admin এই Stripe account disable করে রেখেছে (reconnect ব্লকড) |
| 404 | Mosque / Campaign পাওয়া যায়নি |
| 409 | Already connected |
| 422 | Stripe setup complete না / Campaign expired বা inactive |
| 400 | Validation error |
| 500 | Server error |

---

## Money Split

| Party | পায় |
|---|---|
| Mosque | 98% (`mosque_amount`) |
| DeenHub Platform | 2% (`platform_fee`) |

> Stripe automatically split করে — কোনো manual transfer নেই।

---

## Test Card (Stripe Test Mode)

```
Card Number : 4242 4242 4242 4242
Expiry      : 12/34
CVC         : 123
```
