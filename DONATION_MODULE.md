# DeenHub — Stripe Connect Donation Module

## Overview

Each **verified mosque owner** connects their own Stripe Express Account.  
Users donate directly to that mosque. DeenHub never holds donation money.

| Party | Gets |
|---|---|
| Mosque | 98% of every donation |
| DeenHub Platform | 2% application fee (automatic) |

Stripe handles all money movement via **Destination Charges** — no manual transfers.

---

## Architecture

```
Flutter App
    │
    ├─► POST /api/mosques/:mosqueId/stripe/connect   → Returns onboarding URL
    ├─► GET  /api/mosques/:mosqueId/stripe/status    → Returns connection status
    ├─► POST /api/mosques/:mosqueId/donate           → Returns Stripe Checkout URL
    │
    ↓
Next.js API (this project)
    │
    ├─► Stripe Platform Account (STRIPE_SECRET_KEY)
    │       └─► Stripe Express Accounts (per mosque)
    │
    └─► Supabase
            ├─► mosque_donation_accounts
            └─► donation_transactions
```

---

## Environment Variables

Add these to your `.env` file:

```env
# Existing Stripe Platform Account (reused — do NOT create a new one)
STRIPE_SECRET_KEY=sk_live_...

# Webhook secret for donation events (get from Stripe Dashboard > Webhooks)
STRIPE_DONATION_WEBHOOK_SECRET=whsec_...

# Public base URL (used for Stripe return/cancel URLs)
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
```

---

## Database Tables

### `mosque_donation_accounts`

Stores each mosque's Stripe Express Account.

| Column | Type | Description |
|---|---|---|
| `id` | UUID | Primary key |
| `mosque_id` | TEXT | FK → mosques_metadata |
| `provider` | TEXT | Always `'stripe'` |
| `stripe_account_id` | TEXT | Stripe Express Account ID (`acct_...`) |
| `account_status` | TEXT | `pending` / `active` / `restricted` / `disabled` |
| `charges_enabled` | BOOLEAN | Stripe charges enabled |
| `payouts_enabled` | BOOLEAN | Stripe payouts enabled |
| `details_submitted` | BOOLEAN | Owner completed onboarding |
| `country` | TEXT | e.g. `'US'` |
| `currency` | TEXT | Default `'usd'` |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | Auto-updated |

### `donation_transactions`

Records every donation attempt.

| Column | Type | Description |
|---|---|---|
| `id` | UUID | Primary key |
| `mosque_id` | TEXT | FK → mosques_metadata |
| `donor_user_id` | TEXT | Supabase user id of donor |
| `stripe_checkout_session` | TEXT | Stripe Session ID (`cs_...`) |
| `stripe_payment_intent` | TEXT | Stripe PaymentIntent ID (`pi_...`) |
| `amount` | INTEGER | Total in cents (e.g. 1000 = $10.00) |
| `currency` | TEXT | e.g. `'usd'` |
| `platform_fee` | INTEGER | 2% in cents |
| `mosque_amount` | INTEGER | 98% in cents |
| `payment_method` | TEXT | e.g. `'card'` |
| `receipt_url` | TEXT | Stripe receipt URL |
| `status` | TEXT | `pending` / `completed` / `failed` / `refunded` |
| `created_at` | TIMESTAMPTZ | |

---

## API Endpoints

### Phase 2 — Stripe Connect

#### `POST /api/mosques/:mosqueId/stripe/connect`
Flutter owner connects Stripe.

**Auth:** `Authorization: Bearer <supabase_jwt>`  
**Permission:** Verified mosque owner only

**Response:**
```json
{
  "success": true,
  "message": "Stripe onboarding link generated.",
  "data": {
    "onboarding_url": "https://connect.stripe.com/..."
  }
}
```

---

#### `GET /api/mosques/:mosqueId/stripe/status`
Check if mosque has Stripe connected.

**Auth:** `Authorization: Bearer <supabase_jwt>` (any authenticated user)

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

`status` values: `connected` | `pending` | `not_connected`

---

#### `GET /api/stripe/connect/return`
Stripe redirects here after owner completes onboarding.

**Query Params:** `account_id=acct_...`

- Verifies `charges_enabled`, `payouts_enabled`, `details_submitted`
- Updates `mosque_donation_accounts.account_status` to `active` or `pending`
- Redirects to Flutter deep link: `deenhub://stripe/connect/success` or `deenhub://stripe/connect/pending`

---

### Phase 3 — Donation Checkout

#### `POST /api/mosques/:mosqueId/donate`
User initiates donation.

**Auth:** `Authorization: Bearer <supabase_jwt>`

**Body:**
```json
{
  "amount": 1000,
  "currency": "usd"
}
```

- `amount` is in cents (minimum 50 cents)
- Creates Stripe Checkout Session with destination charge
- Platform fee (2%) auto-deducted by Stripe

**Response:**
```json
{
  "success": true,
  "message": "Checkout session created.",
  "data": {
    "checkout_url": "https://checkout.stripe.com/pay/cs_...",
    "session_id": "cs_..."
  }
}
```

---

### Phase 4 — Webhook

#### `POST /api/stripe/webhook`
Handles Stripe events for donations.

**Events handled:**
- `checkout.session.completed` → mark transaction `completed`, save `receipt_url`
- `payment_intent.succeeded` → update `stripe_payment_intent`, `payment_method`
- `payment_intent.payment_failed` → mark transaction `failed`

**Header:** `stripe-signature` verified with `STRIPE_DONATION_WEBHOOK_SECRET`

---

## Stripe Money Flow

```
User pays $10.00
    │
    ▼
Stripe Platform (DeenHub)
    │
    ├─► DeenHub keeps: $0.20  (2% application_fee_amount)
    └─► Mosque gets:   $9.80  (98% via transfer_data.destination)
                               minus Stripe processing fees (~2.9% + 30¢)
```

Stripe Connect Destination Charges handle this automatically. No manual code.

---

## Permission Rules

| Action | Who can do it |
|---|---|
| Connect Stripe | Verified mosque owner (not blocked) |
| Reconnect / new onboarding link | Verified mosque owner (not blocked) |
| Check Stripe status | Any authenticated user |
| Create donation checkout | Any authenticated user |
| Block owner → stops new Stripe connect | Admin via existing block-owner API |

---

## Flutter Integration

### Owner Connects Stripe
```dart
// 1. Call connect API
final res = await dio.post(
  '/api/mosques/$mosqueId/stripe/connect',
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
final url = res.data['data']['onboarding_url'];

// 2. Open in browser / WebView
launchUrl(Uri.parse(url));

// 3. Stripe redirects back to deep link
// deenhub://stripe/connect/success
```

### User Donates
```dart
// 1. Create checkout
final res = await dio.post(
  '/api/mosques/$mosqueId/donate',
  data: {'amount': 1000, 'currency': 'usd'},
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
final url = res.data['data']['checkout_url'];

// 2. Open Stripe Checkout
launchUrl(Uri.parse(url));

// 3. Stripe handles payment and webhook updates DB
```

---

## Implementation Phases

| Phase | Status | Description |
|---|---|---|
| Phase 1 | ✅ Done | Database migration, TypeScript types, Stripe service, permissions |
| Phase 2 | ⏳ Next | Connect Stripe APIs (POST connect, GET status, GET return) |
| Phase 3 | ⏳ | Donation Checkout API |
| Phase 4 | ⏳ | Webhook handler |
| Phase 5 | ⏳ | Admin Dashboard — Donations section |
| Phase 6 | ⏳ | Testing & validation |

---

## Files Created / Modified

```
lib/
  types/donations.ts                   ← TypeScript interfaces
  services/stripe.ts                   ← Stripe SDK wrapper
  helpers/mosque-permissions.ts        ← Added canConnectStripe()

app/api/
  mosques/[mosqueId]/stripe/
    connect/route.ts                   ← Phase 2
    status/route.ts                    ← Phase 2
  stripe/
    connect/return/route.ts            ← Phase 2
  mosques/[mosqueId]/
    donate/route.ts                    ← Phase 3
  stripe/
    webhook/route.ts                   ← Phase 4

app/dashboard/donations/              ← Phase 5 (Admin UI)

supabase_donation_tables.sql          ← Run in Supabase SQL Editor
```
