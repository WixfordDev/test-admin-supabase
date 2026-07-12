import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canConnectStripe } from '@/lib/helpers/mosque-permissions'
import {
  createStripeExpressAccount,
  createAccountLink,
  retrieveStripeAccount,
} from '@/lib/services/stripe'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// POST /api/mosques/:mosqueId/stripe/connect
// Mosque owner connects or reconnects their Stripe Express Account
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

    // Only verified, unblocked owner can connect Stripe
    const allowed = await canConnectStripe(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json(
        { success: false, message: 'Forbidden: verified mosque owner only' },
        { status: 403 }
      )
    }

    // Fetch mosque info
    const { data: mosque } = await adminClient
      .from('mosques_metadata')
      .select('mosque_id, name')
      .eq('mosque_id', mosqueId)
      .single()

    if (!mosque) {
      return NextResponse.json({ success: false, message: 'Mosque not found' }, { status: 404 })
    }

    // Fetch user email from auth
    const { data: { user: fullUser } } = await adminClient.auth.admin.getUserById(user.id)

    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3002'
    const returnUrl = `${baseUrl}/api/stripe/connect/return?mosque_id=${mosqueId}`
    const refreshUrl = `${baseUrl}/api/mosques/${mosqueId}/stripe/connect`

    // Check if a donation account already exists for this mosque
    const { data: existingAccount } = await adminClient
      .from('mosque_donation_accounts')
      .select('*')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    let stripeAccountId: string

    if (existingAccount?.stripe_account_id) {
      // Account exists — verify it still exists on Stripe then generate a new link
      try {
        const stripeAccount = await retrieveStripeAccount(existingAccount.stripe_account_id)

        // Fully connected AND not disabled by admin → block re-connect
        if (
          stripeAccount.details_submitted &&
          stripeAccount.charges_enabled &&
          existingAccount.account_status !== 'disabled'
        ) {
          return NextResponse.json(
            { success: false, message: 'Stripe account is already fully connected' },
            { status: 409 }
          )
        }

        // If admin disabled it, or onboarding incomplete → allow reconnect with same account
        stripeAccountId = existingAccount.stripe_account_id

        // Reset status to pending so donations stay blocked until onboarding confirmed
        if (existingAccount.account_status === 'disabled') {
          await adminClient
            .from('mosque_donation_accounts')
            .update({ account_status: 'pending' })
            .eq('id', existingAccount.id)
        }
      } catch {
        // Stripe account not found — create a fresh one
        stripeAccountId = ''
      }
    } else {
      stripeAccountId = ''
    }

    if (!stripeAccountId) {
      // Create a new Stripe Express Account
      const newAccount = await createStripeExpressAccount({
        email: fullUser?.email,
        mosqueId,
        mosqueName: mosque.name,
      })
      stripeAccountId = newAccount.id

      // Upsert into mosque_donation_accounts
      await adminClient
        .from('mosque_donation_accounts')
        .upsert(
          {
            mosque_id: mosqueId,
            stripe_account_id: stripeAccountId,
            account_status: 'pending',
            charges_enabled: false,
            payouts_enabled: false,
            details_submitted: false,
          },
          { onConflict: 'mosque_id' }
        )
    }

    // Generate onboarding link
    const accountLink = await createAccountLink({
      accountId: stripeAccountId,
      returnUrl,
      refreshUrl,
    })

    return NextResponse.json({
      success: true,
      message: 'Stripe onboarding link generated.',
      data: {
        onboarding_url: accountLink.url,
      },
    })
  } catch (err: any) {
    console.error('[stripe/connect] error:', err)
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}
