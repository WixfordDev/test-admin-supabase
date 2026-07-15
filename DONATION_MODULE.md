# DeenHub — Stripe Connect Donation Module

## Overview

Each **verified mosque owner** connects their own Stripe Express Account.
Users donate directly to that mosque (optionally to a specific campaign). DeenHub never holds donation money — Stripe splits it automatically at the moment of payment.

| Party | Gets |
|---|---|
| Mosque | 98% of every donation (`mosque_amount`) |
| DeenHub Platform | 2% application fee (`platform_fee`, automatic) |

Stripe handles all money movement via **Destination Charges** (`payment_intent_data.transfer_data.destination` + `application_fee_amount`) — no manual transfers, no custom payout code.

---

## Architecture

```
Flutter App (mosque owner + donor)
    │
    ├─► POST /api/mosques/:mosqueId/stripe/connect        → onboarding URL
    ├─► GET  /api/mosques/:mosqueId/stripe/status          → connection status
    ├─► GET  /api/mosques/:mosqueId/stripe/dashboard        → balance + stats
    ├─► GET  /api/mosques/:mosqueId/stripe/login-link       → Stripe Express dashboard link
    ├─► POST /api/mosques/:mosqueId/donate                  → checkout URL (general)
    ├─► POST /api/mosques/:mosqueId/campaigns/:id/donate     → checkout URL (campaign)
    ├─► GET  /api/mosques/:mosqueId/donations                → owner's transaction history
    ├─► POST/GET/PUT/DELETE /api/mosques/:mosqueId/campaigns[...] → campaign CRUD
    │
    ↓
Next.js API (this project)
    │
    ├─► Stripe Platform Account (STRIPE_SECRET_KEY)
    │       └─► Stripe Express Accounts (per mosque)
    │
    └─► Supabase
            ├─► mosque_donation_accounts
            ├─► mosque_campaigns
            └─► donation_transactions

Admin Dashboard (Next.js, app/dashboard/donations)
    │
    ├─► GET   /api/admin/donations                          → global stats + all transactions + all accounts
    ├─► PATCH /api/admin/donations/accounts/:accountId        → disable / re-enable a mosque's Stripe account
    ├─► DELETE /api/admin/donations/accounts/:accountId       → permanently remove a mosque's Stripe account
    ├─► GET    /api/admin/campaigns                           → all campaigns across mosques + stats
    ├─► GET    /api/admin/campaigns/:id                        → single campaign + its transactions + stats
    └─► DELETE /api/admin/campaigns/:id                        → force-delete a campaign

Stripe
    │
    └─► POST /api/stripe/webhook           → payment + account events
    └─► GET  /api/stripe/connect/return    → onboarding return redirect
```

---

## Environment Variables

```env
# Existing Stripe Platform Account (reused — do NOT create a new one)
STRIPE_SECRET_KEY=sk_live_...

# Webhook secret for donation events (Stripe Dashboard > Webhooks)
STRIPE_DONATION_WEBHOOK_SECRET=whsec_...

# Public base URL (used for Stripe onboarding return/refresh + checkout success/cancel URLs)
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
```

---

## Database Tables

### `mosque_donation_accounts`

One row per mosque. Stores the mosque's Stripe Express Account + its current status.

| Column | Type | Description |
|---|---|---|
| `id` | UUID | Primary key |
| `mosque_id` | TEXT | FK → `mosques_metadata` |
| `provider` | TEXT | Always `'stripe'` |
| `stripe_account_id` | TEXT | Stripe Express Account ID (`acct_...`) |
| `account_status` | TEXT | `pending` / `active` / `restricted` / `disabled` |
| `charges_enabled` | BOOLEAN | Stripe: can accept charges |
| `payouts_enabled` | BOOLEAN | Stripe: can receive payouts |
| `details_submitted` | BOOLEAN | Owner completed onboarding form |
| `country` | TEXT | e.g. `'US'` |
| `currency` | TEXT | Default `'usd'` |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |

`account_status` meaning:
- **`pending`** — account created (or onboarding incomplete). Donations blocked.
- **`active`** — `charges_enabled && payouts_enabled && details_submitted` all true. Donations allowed.
- **`disabled`** — admin has locked this account (see "Admin Lock" flow below). Owner **cannot** self-reconnect while in this state.
- **`restricted`** — reserved for future use (not currently set anywhere in code).

### `mosque_campaigns`

| Column | Type | Description |
|---|---|---|
| `id` | UUID | Primary key |
| `mosque_id` | TEXT | FK → `mosques_metadata` |
| `title`, `description`, `category` | TEXT | |
| `cover_image_url` | TEXT | nullable |
| `goal_amount`, `raised_amount` | INTEGER | cents |
| `currency` | TEXT | Default `'usd'` |
| `start_date`, `end_date` | DATE | nullable |
| `no_end_date` | BOOLEAN | Default `false`. When `true`, `end_date` is ignored/cleared and the campaign never expires |
| `is_active` | BOOLEAN | Owner/admin toggle |
| `created_at`, `updated_at` | TIMESTAMPTZ | |

### `donation_transactions`

One row per donation attempt (created as `pending`, updated by the webhook).

| Column | Type | Description |
|---|---|---|
| `id` | UUID | Primary key |
| `mosque_id` | TEXT | FK → `mosques_metadata` |
| `campaign_id` | UUID | nullable FK → `mosque_campaigns` |
| `donor_user_id` | TEXT | Supabase user id of donor |
| `stripe_checkout_session` | TEXT | Stripe Session ID (`cs_...`) |
| `stripe_payment_intent` | TEXT | Stripe PaymentIntent ID (`pi_...`) |
| `amount` | INTEGER | Total in cents |
| `currency` | TEXT | e.g. `'usd'` |
| `platform_fee` | INTEGER | 2% in cents |
| `mosque_amount` | INTEGER | 98% in cents |
| `payment_method` | TEXT | e.g. `'card'` |
| `receipt_url` | TEXT | Stripe receipt URL |
| `status` | TEXT | `pending` / `completed` / `failed` / `refunded` |
| `created_at` | TIMESTAMPTZ | |

---

## Full Flow #1 — Owner Connects Stripe (first time)

1. Owner app calls `POST /api/mosques/:mosqueId/stripe/connect`.
2. No `mosque_donation_accounts` row exists yet → server creates a new Stripe Express Account (`createStripeExpressAccount`) and upserts a row with `account_status: 'pending'`.
3. Server generates an onboarding link (`createAccountLink`) and returns `onboarding_url`.
4. Owner completes Stripe's hosted onboarding form in a WebView/browser.
5. Stripe redirects to `GET /api/stripe/connect/return?mosque_id=...`, which re-fetches the account from Stripe and updates `mosque_donation_accounts` (`charges_enabled`, `payouts_enabled`, `details_submitted`, `account_status = active|pending`), then redirects to `/stripe-connect?status=success|pending`.
6. Stripe also fires `account.updated` webhook events as the account changes — these keep the DB in sync going forward too.

## Full Flow #2 — Owner reconnects (onboarding was incomplete)

If `account_status` is `pending` (not `disabled`) and the Stripe account isn't fully set up yet, calling `connect` again reuses the **same** `stripe_account_id` and just issues a fresh onboarding link. If it's already fully connected (`charges_enabled && details_submitted` both true), the API returns `409 Stripe account is already fully connected`.

## Full Flow #3 — Admin Lock (disable → owner blocked → admin re-enable)

This is the moderation flow: admin can lock a mosque out of accepting donations, and the owner cannot undo it themselves.

1. **Admin disables:** `PATCH /api/admin/donations/accounts/:accountId` with `{ "action": "disable" }` (or no body, for backward compatibility). Sets `account_status = 'disabled'`, `charges_enabled = false`, `payouts_enabled = false` **in our DB only** — the real Stripe account is untouched (Stripe itself is never told to restrict it).
2. **Owner is blocked:** if the owner now calls `POST /api/mosques/:mosqueId/stripe/connect`, the API immediately returns `403` — *"Your donation account was disabled by an admin. Please contact admin to re-enable it before reconnecting."* No new onboarding link is issued.
3. **Donations are blocked:** the general and campaign donate routes check `donationAccount.charges_enabled`, which is `false`, so checkout session creation fails with `422`.
4. **Webhook can't silently undo it:** if Stripe fires `account.updated` for this account while it's `disabled`, the webhook handler checks the current DB status first and **skips the update** — the admin lock stays in place regardless of what Stripe reports.
5. **Owner contacts admin** (outside the app — no in-app notification is sent automatically when disabled; see "Known Gaps" below).
6. **Admin re-enables:** `PATCH /api/admin/donations/accounts/:accountId` with `{ "action": "enable" }`. The server re-fetches the **real** Stripe account status (`retrieveStripeAccount`) instead of blindly resetting to `pending`:
   - If Stripe still reports the account fully set up → status goes straight to `active`, owner does nothing further.
   - Otherwise → status becomes `pending`, and the owner can call `connect` again to pick up onboarding where they left off (same Stripe account, not from scratch).
7. **Permanent removal (harsher alternative):** `DELETE /api/admin/donations/accounts/:accountId` deletes the row entirely. The owner must connect from scratch (brand-new Stripe Express Account) — this is different from disable/re-enable, which reuses the same account.

## Full Flow #4 — User Donates (general or campaign)

1. User calls `POST /api/mosques/:mosqueId/donate` (general) or `POST /api/mosques/:mosqueId/campaigns/:campaignId/donate` (campaign-specific).
2. Server validates minimum amount (50 cents), and for campaign donations also checks the campaign is `is_active` and not expired (`end_date` in the past) — **unless `no_end_date` is `true`**, in which case the expiry check is skipped entirely.
3. Server checks `mosque_donation_accounts.charges_enabled` is `true` — if the account is `pending` or `disabled`, this fails with `422`.
4. Server creates a Stripe Checkout Session as a **destination charge**: `application_fee_amount` = 2% of amount goes to the platform, the rest is transferred to `mosqueStripeAccountId`.
5. Server inserts a `pending` row into `donation_transactions` (with `campaign_id` if applicable) and returns `checkout_url`.
6. App opens `checkout_url`. User pays on Stripe's hosted checkout page.
7. Stripe fires `checkout.session.completed` → webhook marks the transaction `completed`, fetches the receipt URL, and — if `campaign_id` is set — calls `increment_campaign_raised()` to bump the campaign's `raised_amount`.
8. `payment_intent.succeeded` / `payment_intent.payment_failed` webhooks separately update payment method / mark the transaction `failed`.

## Full Flow #5 — Owner Withdraws Money

There is **no custom withdraw API**. Money movement to the mosque's bank account is entirely delegated to Stripe:

1. Owner calls `GET /api/mosques/:mosqueId/stripe/login-link` (only works if `charges_enabled` is true).
2. Server calls `stripe.accounts.createLoginLink()` and returns a one-time Stripe Express Dashboard URL.
3. Owner opens that URL — it's Stripe's own hosted dashboard, where they see balance, payout schedule, and can manage/withdraw funds directly. This app never touches payout money.

## Full Flow #6 — Owner Checks Status / Balance

- `GET /api/mosques/:mosqueId/stripe/status` — any authenticated user, coarse 3-state label (`connected` / `pending` / `not_connected`). **Note:** a `disabled` account also shows as `pending` here — there's no distinct "disabled by admin" label surfaced through this endpoint (see "Known Gaps").
- `GET /api/mosques/:mosqueId/stripe/dashboard` — owner-only. Returns the raw `account_status` (so `disabled` is visible here), live Stripe balance (`available`/`pending`), and DB-derived donation stats (totals, monthly totals).
- `GET /api/mosques/:mosqueId/donations` — owner-only, paginated transaction history for their mosque (all campaigns combined — no per-campaign filter yet).

## Full Flow #7 — Admin Views

- `GET /api/admin/donations` — global dashboard: connected/pending mosque counts, total donations, platform revenue, all transactions (enriched with mosque name), all connected accounts.
- `GET /api/admin/campaigns` — all campaigns across all mosques with aggregate stats, filterable by `search`, `category`, `status`.
- `GET /api/admin/campaigns/:id` — single campaign + its transactions + per-status counts.
- `DELETE /api/admin/campaigns/:id` — force-delete any campaign.

---

## Known Gaps (things to be aware of, not yet implemented)

- **No proactive notification.** When admin disables an account, nothing is pushed to the owner (no email, no push notification). They only find out by checking status in-app or by trying to reconnect and hitting the 403.
- **`/stripe/status` doesn't distinguish `disabled` from `pending`.** Both show as `"pending"` to a donor/owner checking via that endpoint. Only `/stripe/dashboard` exposes the raw `disabled` status.
- **No per-campaign filter on `/donations`.** The owner's transaction history endpoint returns everything for the mosque; there's no `?campaign_id=` query param yet even though the column exists.
- **`mosque_donation_accounts.donor_user_id` (on `donation_transactions`) is plain TEXT**, not FK-enforced against `auth.users`.
- **Platform fee (2%) is hardcoded** in `lib/services/stripe.ts`, not configurable per mosque or campaign.

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
                               minus Stripe's own processing fees (~2.9% + 30¢)
```

---

## Permission Rules

| Action | Who can do it |
|---|---|
| Connect / reconnect Stripe | Verified, unblocked mosque owner — **unless** account is admin-disabled |
| Check Stripe status / dashboard | Owner-only for `/dashboard`, `/login-link`; any authenticated user for `/status` |
| Create donation checkout | Any authenticated user |
| Create / edit / delete campaign | Verified, unblocked mosque owner (`canConnectStripe`) |
| View owner's own donation history | Verified, unblocked mosque owner |
| Disable / re-enable / delete a mosque's Stripe account | Admin only (`/api/admin/donations/accounts/:accountId`) |
| View global donation stats, all campaigns, force-delete any campaign | Admin only |

---

## Full Endpoint List

### Owner — Stripe Connect
| Method | Endpoint | Notes |
|---|---|---|
| `POST` | `/api/mosques/:mosqueId/stripe/connect` | Connect / reconnect. Blocked (403) if admin-disabled |
| `GET` | `/api/mosques/:mosqueId/stripe/status` | `connected` / `pending` / `not_connected` |
| `GET` | `/api/mosques/:mosqueId/stripe/dashboard` | Owner-only. Balance + stats + raw status |
| `GET` | `/api/mosques/:mosqueId/stripe/login-link` | Owner-only. One-time Stripe Express Dashboard link (for withdrawals) |
| `GET` | `/api/stripe/connect/return` | Stripe redirect target (not called by the app directly) |

### Donation
| Method | Endpoint | Notes |
|---|---|---|
| `POST` | `/api/mosques/:mosqueId/donate` | General donation checkout |
| `POST` | `/api/mosques/:mosqueId/campaigns/:campaignId/donate` | Campaign donation checkout |
| `GET` | `/api/mosques/:mosqueId/donations` | Owner-only transaction history |
| `POST` | `/api/stripe/webhook` | Stripe → us. Not called by the app |

### Owner — Campaigns
| Method | Endpoint | Notes |
|---|---|---|
| `POST` | `/api/mosques/:mosqueId/campaigns` | Create |
| `GET` | `/api/mosques/:mosqueId/campaigns` | Public list |
| `GET` | `/api/mosques/:mosqueId/campaigns/:campaignId` | Public single |
| `PUT` | `/api/mosques/:mosqueId/campaigns/:campaignId` | Owner-only edit |
| `DELETE` | `/api/mosques/:mosqueId/campaigns/:campaignId` | Owner-only delete |

### Admin
| Method | Endpoint | Notes |
|---|---|---|
| `GET` | `/api/admin/donations` | Global stats + transactions + accounts |
| `PATCH` | `/api/admin/donations/accounts/:accountId` | `{action:'disable'\|'enable'}` |
| `DELETE` | `/api/admin/donations/accounts/:accountId` | Permanent removal |
| `GET` | `/api/admin/campaigns` | All campaigns + stats, filterable |
| `GET` | `/api/admin/campaigns/:id` | Single campaign + transactions + stats |
| `DELETE` | `/api/admin/campaigns/:id` | Force-delete |

Detailed request/response bodies for the Flutter-facing endpoints are in [`DONATION_API_REFERENCE.md`](DONATION_API_REFERENCE.md) and [`CAMPAIGN_API_REFERENCE.md`](CAMPAIGN_API_REFERENCE.md).

---

## Test Card (Stripe Test Mode)

```
Card Number : 4242 4242 4242 4242
Expiry      : 12/34
CVC         : 123
```
