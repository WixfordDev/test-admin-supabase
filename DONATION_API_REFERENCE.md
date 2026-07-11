# Donation Module — Flutter API Reference

**Base URL:** `https://test-admin-supabase-kappa.vercel.app`

**Auth Header (সব API তে):**
```
Authorization: Bearer <supabase_jwt>
```

---

## Mosque Owner APIs

### 1. Stripe Connect করো
```
POST /api/mosques/{mosqueId}/stripe/connect
```
Response:
```json
{
  "success": true,
  "data": { "onboarding_url": "https://connect.stripe.com/..." }
}
```
> `onboarding_url` WebView বা browser এ খোলো

---

### 2. Connection Status চেক করো
```
GET /api/mosques/{mosqueId}/stripe/status
```
Response:
```json
{
  "success": true,
  "data": {
    "status": "connected",
    "charges_enabled": true,
    "payouts_enabled": true,
    "stripe_account_id": "acct_..."
  }
}
```
> `status` values: `connected` | `pending` | `not_connected`

---

### 3. Owner Dashboard (Balance + Stats)
```
GET /api/mosques/{mosqueId}/stripe/dashboard
```
Response:
```json
{
  "success": true,
  "data": {
    "status": "active",
    "balance": {
      "available": [{ "amount": 980, "currency": "usd" }],
      "pending": [{ "amount": 0, "currency": "usd" }]
    },
    "stats": {
      "total_donations_cents": 10000,
      "total_mosque_amount_cents": 9800,
      "total_transactions": 10,
      "monthly_donations_cents": 2000,
      "monthly_transactions": 2
    }
  }
}
```
> `amount` সবসময় cents এ — 980 = $9.80

---

### 4. Stripe Dashboard Login Link
```
GET /api/mosques/{mosqueId}/stripe/login-link
```
Response:
```json
{
  "success": true,
  "data": { "url": "https://connect.stripe.com/express/..." }
}
```
> Owner এই URL এ গেলে তার Stripe dashboard দেখবে — balance, payouts, history

---

### 5. Donation History (Owner)
```
GET /api/mosques/{mosqueId}/donations?page=1&limit=20
```
Response:
```json
{
  "success": true,
  "data": {
    "transactions": [
      {
        "id": "uuid",
        "amount": 1000,
        "mosque_amount": 980,
        "platform_fee": 20,
        "currency": "usd",
        "status": "completed",
        "receipt_url": "https://...",
        "created_at": "2026-07-05T..."
      }
    ],
    "pagination": { "page": 1, "total": 5, "totalPages": 1 }
  }
}
```

---

## User Donation API

### 6. Donate করো
```
POST /api/mosques/{mosqueId}/donate
```
Body:
```json
{
  "amount": 1000,
  "currency": "usd"
}
```
> `amount` cents এ — minimum 50 (= $0.50)

Response:
```json
{
  "success": true,
  "data": {
    "checkout_url": "https://checkout.stripe.com/pay/cs_...",
    "session_id": "cs_...",
    "amount": 1000,
    "platform_fee": 20,
    "mosque_amount": 980
  }
}
```
> `checkout_url` browser এ খোলো → test card: `4242 4242 4242 4242`

---

## Error Response (সব API তে একই format)
```json
{
  "success": false,
  "message": "Error description"
}
```

| Code | কারণ |
|---|---|
| 401 | Token নেই বা invalid |
| 403 | Owner না |
| 404 | Mosque পাওয়া যায়নি |
| 409 | Already connected |
| 422 | Stripe setup complete না |
| 500 | Server error |

---

## Money Split

| Party | পায় |
|---|---|
| Mosque | 98% (mosque_amount) |
| DeenHub Platform | 2% (platform_fee) |

> Stripe automatically split করে — কোনো manual transfer নেই
