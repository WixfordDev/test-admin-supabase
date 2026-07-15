import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { constructWebhookEvent, stripe } from '@/lib/services/stripe'

// Stripe requires the raw body — do not let Next.js parse it
export const runtime = 'nodejs'

// POST /api/stripe/webhook
// Stripe sends events here after payment activity
export async function POST(request: NextRequest) {
  const body = await request.text()
  const sig = request.headers.get('stripe-signature') ?? ''
  const secret = process.env.STRIPE_DONATION_WEBHOOK_SECRET ?? ''

  if (!secret) {
    console.error('[webhook] STRIPE_DONATION_WEBHOOK_SECRET is not set')
    return NextResponse.json({ error: 'Webhook secret not configured' }, { status: 500 })
  }

  let event
  try {
    event = constructWebhookEvent(body, sig, secret)
  } catch (err: any) {
    console.error('[webhook] Signature verification failed:', err.message)
    return NextResponse.json({ error: `Webhook error: ${err.message}` }, { status: 400 })
  }

  const adminClient = await createAdminClient()

  try {
    switch (event.type) {
      // ── checkout.session.completed ──────────────────────────────────────
      // Payment confirmed — mark transaction completed
      case 'checkout.session.completed': {
        const session = event.data.object as any
        const sessionId = session.id as string
        const paymentIntentId = session.payment_intent as string | null

        // Fetch receipt URL from payment intent if available
        let receiptUrl: string | null = null
        if (paymentIntentId) {
          try {
            const pi = await stripe.paymentIntents.retrieve(paymentIntentId, {
              expand: ['latest_charge'],
            })
            receiptUrl = (pi.latest_charge as any)?.receipt_url ?? null
          } catch {
            // Non-critical — continue without receipt URL
          }
        }

        const { data: tx } = await adminClient
          .from('donation_transactions')
          .update({
            status: 'completed',
            stripe_payment_intent: paymentIntentId,
            receipt_url: receiptUrl,
          })
          .eq('stripe_checkout_session', sessionId)
          .select('campaign_id, mosque_amount')
          .single()

        // Update campaign raised_amount if this donation was for a campaign
        if (tx?.campaign_id && tx?.mosque_amount) {
          await adminClient.rpc('increment_campaign_raised', {
            p_campaign_id: tx.campaign_id,
            p_amount: tx.mosque_amount,
          })
        }

        break
      }

      // ── payment_intent.succeeded ────────────────────────────────────────
      // Extra confirmation — update payment method details
      case 'payment_intent.succeeded': {
        const pi = event.data.object as any
        const piId = pi.id as string

        let paymentMethod: string | null = null
        if (pi.payment_method) {
          try {
            const pm = await stripe.paymentMethods.retrieve(pi.payment_method)
            paymentMethod = pm.type ?? null
          } catch {
            // Non-critical
          }
        }

        const receiptUrl = pi.latest_charge?.receipt_url ?? null

        await adminClient
          .from('donation_transactions')
          .update({
            status: 'completed',
            stripe_payment_intent: piId,
            payment_method: paymentMethod,
            receipt_url: receiptUrl,
          })
          .eq('stripe_payment_intent', piId)

        break
      }

      // ── payment_intent.payment_failed ───────────────────────────────────
      // Payment failed — mark transaction failed
      case 'payment_intent.payment_failed': {
        const pi = event.data.object as any
        const piId = pi.id as string

        await adminClient
          .from('donation_transactions')
          .update({ status: 'failed' })
          .eq('stripe_payment_intent', piId)

        break
      }

      // ── account.updated ─────────────────────────────────────────────────
      // Stripe Express Account status changed — sync to DB
      case 'account.updated': {
        const account = event.data.object as any
        const stripeAccountId = account.id as string

        const { data: existing } = await adminClient
          .from('mosque_donation_accounts')
          .select('account_status')
          .eq('stripe_account_id', stripeAccountId)
          .maybeSingle()

        // Admin-disabled accounts are locked until admin re-enables —
        // don't let a Stripe-side event silently undo that
        if (existing?.account_status === 'disabled') {
          break
        }

        const chargesEnabled = account.charges_enabled ?? false
        const payoutsEnabled = account.payouts_enabled ?? false
        const detailsSubmitted = account.details_submitted ?? false
        const accountStatus =
          chargesEnabled && payoutsEnabled && detailsSubmitted ? 'active' : 'pending'

        await adminClient
          .from('mosque_donation_accounts')
          .update({
            account_status: accountStatus,
            charges_enabled: chargesEnabled,
            payouts_enabled: payoutsEnabled,
            details_submitted: detailsSubmitted,
          })
          .eq('stripe_account_id', stripeAccountId)

        break
      }

      default:
        // Unhandled event — ignore silently
        break
    }

    return NextResponse.json({ received: true })
  } catch (err: any) {
    console.error('[webhook] Handler error:', err)
    return NextResponse.json({ error: 'Webhook handler failed' }, { status: 500 })
  }
}
