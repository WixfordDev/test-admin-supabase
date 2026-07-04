import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import {
  createDonationCheckoutSession,
  calculatePlatformFee,
} from '@/lib/services/stripe'
import type { CreateDonationCheckoutBody } from '@/lib/types/donations'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

const MIN_AMOUNT_CENTS = 50 // Stripe minimum: 50 cents

// POST /api/mosques/:mosqueId/donate
// Any authenticated user can donate to a mosque that has Stripe connected
export async function POST(request: NextRequest, context: RouteContext) {
  try {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }
    const token = authHeader.split(' ')[1]

    const adminClient = await createAdminClient()
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)
    if (authError || !user) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }

    const { mosqueId } = await context.params

    // Validate request body
    const body: CreateDonationCheckoutBody = await request.json()

    if (!body.amount || typeof body.amount !== 'number' || body.amount < MIN_AMOUNT_CENTS) {
      return NextResponse.json(
        { success: false, message: `Amount must be at least ${MIN_AMOUNT_CENTS} cents (e.g. 50 = $0.50)` },
        { status: 400 }
      )
    }

    const currency = (body.currency ?? 'usd').toLowerCase()

    // Fetch mosque info
    const { data: mosque } = await adminClient
      .from('mosques_metadata')
      .select('mosque_id, name')
      .eq('mosque_id', mosqueId)
      .single()

    if (!mosque) {
      return NextResponse.json({ success: false, message: 'Mosque not found' }, { status: 404 })
    }

    // Check mosque has an active Stripe account
    const { data: donationAccount } = await adminClient
      .from('mosque_donation_accounts')
      .select('stripe_account_id, charges_enabled, account_status')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!donationAccount?.stripe_account_id) {
      return NextResponse.json(
        { success: false, message: 'This mosque has not connected Stripe yet' },
        { status: 422 }
      )
    }

    if (!donationAccount.charges_enabled) {
      return NextResponse.json(
        { success: false, message: 'This mosque Stripe account is not ready to accept payments' },
        { status: 422 }
      )
    }

    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3002'
    const successUrl = `${baseUrl}/donation?status=success&session_id={CHECKOUT_SESSION_ID}`
    const cancelUrl = `${baseUrl}/donation?status=cancelled`

    // Create Stripe Checkout Session (destination charge — Stripe handles the split)
    const session = await createDonationCheckoutSession({
      mosqueStripeAccountId: donationAccount.stripe_account_id,
      amountInCents: body.amount,
      currency,
      mosqueId,
      mosqueName: mosque.name,
      donorUserId: user.id,
      successUrl,
      cancelUrl,
    })

    const platformFee = calculatePlatformFee(body.amount)
    const mosqueAmount = body.amount - platformFee

    // Save pending transaction record
    await adminClient.from('donation_transactions').insert({
      mosque_id: mosqueId,
      donor_user_id: user.id,
      stripe_checkout_session: session.id,
      amount: body.amount,
      currency,
      platform_fee: platformFee,
      mosque_amount: mosqueAmount,
      status: 'pending',
    })

    return NextResponse.json({
      success: true,
      message: 'Checkout session created.',
      data: {
        checkout_url: session.url,
        session_id: session.id,
        amount: body.amount,
        currency,
        platform_fee: platformFee,
        mosque_amount: mosqueAmount,
      },
    })
  } catch (err: any) {
    console.error('[donate] error:', err)
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}
