import Stripe from 'stripe'

// Reuse the existing DeenHub platform Stripe account
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2025-06-30.basil' as any,
})

export const PLATFORM_FEE_PERCENT = 0.02 // 2%

// Calculate platform fee amount in smallest currency unit (cents)
export function calculatePlatformFee(amountInCents: number): number {
  return Math.round(amountInCents * PLATFORM_FEE_PERCENT)
}

// Create a new Stripe Express Account for a mosque owner
export async function createStripeExpressAccount(params: {
  email?: string
  country?: string
  mosqueId: string
  mosqueName?: string
}): Promise<Stripe.Account> {
  return stripe.accounts.create({
    type: 'express',
    country: params.country ?? 'US',
    email: params.email,
    capabilities: {
      card_payments: { requested: true },
      transfers: { requested: true },
    },
    business_type: 'non_profit',
    metadata: {
      mosque_id: params.mosqueId,
      mosque_name: params.mosqueName ?? '',
    },
  })
}

// Generate onboarding link so owner can complete Stripe Express setup
export async function createAccountLink(params: {
  accountId: string
  returnUrl: string
  refreshUrl: string
}): Promise<Stripe.AccountLink> {
  return stripe.accountLinks.create({
    account: params.accountId,
    return_url: params.returnUrl,
    refresh_url: params.refreshUrl,
    type: 'account_onboarding',
  })
}

// Retrieve current status of a connected account
export async function retrieveStripeAccount(accountId: string): Promise<Stripe.Account> {
  return stripe.accounts.retrieve(accountId)
}

// Create a Checkout Session that routes funds to the mosque's Express Account
export async function createDonationCheckoutSession(params: {
  mosqueStripeAccountId: string
  amountInCents: number
  currency: string
  mosqueId: string
  mosqueName: string
  donorUserId: string
  successUrl: string
  cancelUrl: string
}): Promise<Stripe.Checkout.Session> {
  const platformFee = calculatePlatformFee(params.amountInCents)

  return stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [
      {
        price_data: {
          currency: params.currency,
          product_data: {
            name: `Donation to ${params.mosqueName}`,
          },
          unit_amount: params.amountInCents,
        },
        quantity: 1,
      },
    ],
    mode: 'payment',
    payment_intent_data: {
      // 2% stays with DeenHub platform; 98% auto-transferred to mosque account
      application_fee_amount: platformFee,
      transfer_data: {
        destination: params.mosqueStripeAccountId,
      },
      metadata: {
        mosque_id: params.mosqueId,
        donor_user_id: params.donorUserId,
      },
    },
    success_url: params.successUrl,
    cancel_url: params.cancelUrl,
    metadata: {
      mosque_id: params.mosqueId,
      donor_user_id: params.donorUserId,
    },
  })
}

// Construct and verify a Stripe webhook event
export function constructWebhookEvent(
  payload: string | Buffer,
  sig: string,
  secret: string
): Stripe.Event {
  return stripe.webhooks.constructEvent(payload, sig, secret)
}
