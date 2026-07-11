import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { createDonationCheckoutSession, calculatePlatformFee } from '@/lib/services/stripe'
import type { CreateDonationCheckoutBody } from '@/lib/types/donations'

type RouteContext = {
  params: Promise<{ mosqueId: string; campaignId: string }>
}

const MIN_AMOUNT_CENTS = 50

// POST /api/mosques/:mosqueId/campaigns/:campaignId/donate
// User donates to a specific campaign
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

    const { mosqueId, campaignId } = await context.params

    const body: CreateDonationCheckoutBody = await request.json()

    if (!body.amount || body.amount < MIN_AMOUNT_CENTS) {
      return NextResponse.json(
        { success: false, message: `Amount must be at least ${MIN_AMOUNT_CENTS} cents` },
        { status: 400 }
      )
    }

    const currency = (body.currency ?? 'usd').toLowerCase()

    // Verify campaign exists, belongs to mosque, and is active
    const { data: campaign } = await adminClient
      .from('mosque_campaigns')
      .select('*')
      .eq('id', campaignId)
      .eq('mosque_id', mosqueId)
      .eq('is_active', true)
      .single()

    if (!campaign) {
      return NextResponse.json(
        { success: false, message: 'Campaign not found or inactive' },
        { status: 404 }
      )
    }

    // Check campaign deadline
    if (campaign.end_date && new Date(campaign.end_date) < new Date()) {
      return NextResponse.json(
        { success: false, message: 'This campaign has ended' },
        { status: 422 }
      )
    }

    // Fetch mosque info
    const { data: mosque } = await adminClient
      .from('mosques_metadata')
      .select('name')
      .eq('mosque_id', mosqueId)
      .single()

    // Verify mosque has active Stripe account
    const { data: donationAccount } = await adminClient
      .from('mosque_donation_accounts')
      .select('stripe_account_id, charges_enabled')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!donationAccount?.stripe_account_id || !donationAccount.charges_enabled) {
      return NextResponse.json(
        { success: false, message: 'This mosque is not set up to accept donations' },
        { status: 422 }
      )
    }

    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3002'
    const successUrl = `${baseUrl}/donation?status=success&session_id={CHECKOUT_SESSION_ID}`
    const cancelUrl = `${baseUrl}/donation?status=cancelled`

    const session = await createDonationCheckoutSession({
      mosqueStripeAccountId: donationAccount.stripe_account_id,
      amountInCents: body.amount,
      currency,
      mosqueId,
      mosqueName: `${mosque?.name ?? 'Mosque'} — ${campaign.title}`,
      donorUserId: user.id,
      successUrl,
      cancelUrl,
    })

    const platformFee = calculatePlatformFee(body.amount)
    const mosqueAmount = body.amount - platformFee

    // Save transaction with campaign_id
    await adminClient.from('donation_transactions').insert({
      mosque_id: mosqueId,
      campaign_id: campaignId,
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
        campaign_title: campaign.title,
        amount: body.amount,
        currency,
        platform_fee: platformFee,
        mosque_amount: mosqueAmount,
      },
    })
  } catch (err: any) {
    console.error('[campaign/donate]', err)
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}
