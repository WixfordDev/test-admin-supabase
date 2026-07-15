# Campaign Module — Flutter API Reference

**Base URL:** `https://test-admin-supabase-kappa.vercel.app`

**Auth Header (সব API তে):**
```
Authorization: Bearer <supabase_jwt>
Content-Type: application/json
```

> পুরো donation + Stripe Connect architecture আর flow-এর জন্য দেখো [`DONATION_MODULE.md`](DONATION_MODULE.md)।

---

## APIs Overview

| Method | Endpoint | কে | কী করে |
|---|---|---|---|
| `POST` | `/api/mosques/{mosqueId}/campaigns` | Owner | Campaign create |
| `GET` | `/api/mosques/{mosqueId}/campaigns` | সবাই | Campaign list |
| `GET` | `/api/mosques/{mosqueId}/campaigns/{campaignId}` | সবাই | Single campaign |
| `PUT` | `/api/mosques/{mosqueId}/campaigns/{campaignId}` | Owner | Campaign edit |
| `DELETE` | `/api/mosques/{mosqueId}/campaigns/{campaignId}` | Owner | Campaign delete |
| `POST` | `/api/mosques/{mosqueId}/campaigns/{campaignId}/donate` | User | Campaign এ donate |

---

## 1. Campaign Create করো

```
POST /api/mosques/{mosqueId}/campaigns
Authorization: Bearer <owner_token>
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

**Fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | string | ✅ | Min 3 characters |
| `description` | string | ✅ | Campaign details |
| `category` | string | ✅ | Category value (নিচে দেখো) |
| `goal_amount` | integer | ✅ | Cents এ, min 100 (= $1.00) |
| `currency` | string | ❌ | Default: `usd` |
| `cover_image_url` | string | ❌ | Banner image URL |
| `start_date` | string | ❌ | Format: `YYYY-MM-DD` |
| `end_date` | string | ❌ | Format: `YYYY-MM-DD`. `no_end_date: true` হলে ignore হবে |
| `no_end_date` | boolean | ❌ | Default: `false`. `true` দিলে campaign কখনো expire হবে না, `end_date` লাগবে না |
| `is_active` | boolean | ❌ | Default: `true` |

**Response (201):**
```json
{
  "success": true,
  "message": "Campaign created.",
  "data": {
    "campaign": {
      "id": "3f2a1b4c-...",
      "mosque_id": "user_mosque_...",
      "title": "Mosque Renovation 2026",
      "description": "We are raising funds...",
      "category": "renovation",
      "cover_image_url": "https://example.com/image.jpg",
      "goal_amount": 500000,
      "raised_amount": 0,
      "currency": "usd",
      "start_date": "2026-07-11",
      "end_date": "2026-12-31",
      "is_active": true,
      "created_at": "2026-07-11T10:00:00Z",
      "updated_at": "2026-07-11T10:00:00Z"
    }
  }
}
```

---

## 2. Campaign List দেখো

```
GET /api/mosques/{mosqueId}/campaigns?page=1&limit=20&active=true
```

**Query Params:**

| Param | Type | Description |
|---|---|---|
| `page` | integer | Page number (default: 1) |
| `limit` | integer | Per page (default: 20) |
| `active` | boolean | `true` = active campaign only |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "campaigns": [
      {
        "id": "3f2a1b4c-...",
        "mosque_id": "user_mosque_...",
        "title": "Mosque Renovation 2026",
        "category": "renovation",
        "cover_image_url": "https://example.com/image.jpg",
        "goal_amount": 500000,
        "raised_amount": 125000,
        "currency": "usd",
        "start_date": "2026-07-11",
        "end_date": "2026-12-31",
        "is_active": true,
        "created_at": "2026-07-11T10:00:00Z"
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

## 3. Single Campaign দেখো

```
GET /api/mosques/{mosqueId}/campaigns/{campaignId}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "campaign": {
      "id": "3f2a1b4c-...",
      "mosque_id": "user_mosque_...",
      "title": "Mosque Renovation 2026",
      "description": "We are raising funds...",
      "category": "renovation",
      "cover_image_url": "https://example.com/image.jpg",
      "goal_amount": 500000,
      "raised_amount": 125000,
      "currency": "usd",
      "start_date": "2026-07-11",
      "end_date": "2026-12-31",
      "is_active": true,
      "created_at": "2026-07-11T10:00:00Z",
      "updated_at": "2026-07-11T10:00:00Z"
    }
  }
}
```

---

## 4. Campaign Edit করো

```
PUT /api/mosques/{mosqueId}/campaigns/{campaignId}
Authorization: Bearer <owner_token>
```

**Body:** (সব field optional — শুধু যেটা change করতে চাও)
```json
{
  "title": "Updated Campaign Title",
  "description": "Updated description.",
  "goal_amount": 600000,
  "end_date": "2026-11-30",
  "is_active": false
}
```

`no_end_date: true` পাঠালে `end_date` আপনা-আপনি `null` হয়ে যাবে (deadline মুছে যাবে, campaign চলতেই থাকবে)।

**Response (200):**
```json
{
  "success": true,
  "message": "Campaign updated.",
  "data": {
    "campaign": {
      "id": "3f2a1b4c-...",
      "title": "Updated Campaign Title",
      "goal_amount": 600000,
      "is_active": false,
      "updated_at": "2026-07-11T12:00:00Z"
    }
  }
}
```

---

## 5. Campaign Delete করো

```
DELETE /api/mosques/{mosqueId}/campaigns/{campaignId}
Authorization: Bearer <owner_token>
```

**Body:** none

**Response (200):**
```json
{
  "success": true,
  "message": "Campaign deleted."
}
```

---

## 6. Campaign এ Donate করো

```
POST /api/mosques/{mosqueId}/campaigns/{campaignId}/donate
Authorization: Bearer <user_token>
```

**Body:**
```json
{
  "amount": 1000,
  "currency": "usd"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `amount` | integer | ✅ | Cents এ, min 50 (= $0.50) |
| `currency` | string | ❌ | Default: `usd` |

**Response (200):**
```json
{
  "success": true,
  "message": "Checkout session created.",
  "data": {
    "checkout_url": "https://checkout.stripe.com/pay/cs_test_...",
    "session_id": "cs_test_...",
    "campaign_title": "Mosque Renovation 2026",
    "amount": 1000,
    "currency": "usd",
    "platform_fee": 20,
    "mosque_amount": 980
  }
}
```
> `checkout_url` browser বা WebView এ খোলো।
> Payment সফল হলে `raised_amount` automatically update হবে।
> Campaign-এর `no_end_date: true` থাকলে deadline check সম্পূর্ণ skip হয়ে যায় — `end_date` অতীতে থাকলেও donate ব্লক হবে না।

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
| 400 | Validation error (title too short, goal too low, date invalid) |
| 401 | Token নেই বা invalid |
| 403 | Owner না |
| 404 | Campaign পাওয়া যায়নি |
| 422 | Campaign inactive / expired / Stripe not connected |
| 500 | Server error |

---

## Money Split

| Party | পায় |
|---|---|
| Mosque | 98% (`mosque_amount`) |
| DeenHub Platform | 2% (`platform_fee`) |

> Stripe automatically split করে।

---

## Test Card (Stripe Test Mode)

```
Card Number : 4242 4242 4242 4242
Expiry      : 12/34
CVC         : 123
```
