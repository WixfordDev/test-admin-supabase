import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { retrieveStripeAccount } from '@/lib/services/stripe'

// GET /api/stripe/connect/return?mosque_id=...
// Stripe redirects here after the owner completes (or exits) onboarding
export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const mosqueId = searchParams.get('mosque_id')
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL ?? 'http://localhost:3002'

  if (!mosqueId) {
    return NextResponse.redirect(`${baseUrl}/stripe-connect?status=error&reason=missing_mosque_id`)
  }

  try {
    const adminClient = await createAdminClient()

    const { data: account } = await adminClient
      .from('mosque_donation_accounts')
      .select('stripe_account_id')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!account?.stripe_account_id) {
      return NextResponse.redirect(`${baseUrl}/stripe-connect?status=error&reason=account_not_found`)
    }

    // Fetch latest status from Stripe
    const stripeAccount = await retrieveStripeAccount(account.stripe_account_id)

    const chargesEnabled = stripeAccount.charges_enabled ?? false
    const payoutsEnabled = stripeAccount.payouts_enabled ?? false
    const detailsSubmitted = stripeAccount.details_submitted ?? false
    const accountStatus =
      chargesEnabled && payoutsEnabled && detailsSubmitted ? 'active' : 'pending'

    // Update Supabase with latest status
    await adminClient
      .from('mosque_donation_accounts')
      .update({
        account_status: accountStatus,
        charges_enabled: chargesEnabled,
        payouts_enabled: payoutsEnabled,
        details_submitted: detailsSubmitted,
        country: stripeAccount.country ?? null,
      })
      .eq('mosque_id', mosqueId)

    const status = accountStatus === 'active' ? 'success' : 'pending'
    return NextResponse.redirect(`${baseUrl}/stripe-connect?status=${status}`)
  } catch (err: any) {
    console.error('[stripe/connect/return] error:', err)
    return NextResponse.redirect(`${baseUrl}/stripe-connect?status=error&reason=stripe_error`)
  }
}
