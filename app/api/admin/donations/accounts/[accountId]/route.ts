import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { retrieveStripeAccount } from '@/lib/services/stripe'

type RouteContext = {
  params: Promise<{ accountId: string }>
}

// PATCH /api/admin/donations/accounts/:accountId
// body: { action?: 'disable' | 'enable' } — defaults to 'disable' for backward compatibility
export async function PATCH(request: NextRequest, context: RouteContext) {
  try {
    const { accountId } = await context.params
    const adminClient = await createAdminClient()

    const body = await request.json().catch(() => ({} as Record<string, unknown>))
    const action = body?.action === 'enable' ? 'enable' : 'disable'

    const { data: account, error: fetchError } = await adminClient
      .from('mosque_donation_accounts')
      .select('id, account_status, mosque_id, stripe_account_id')
      .eq('id', accountId)
      .single()

    if (fetchError || !account) {
      return NextResponse.json({ success: false, message: 'Account not found' }, { status: 404 })
    }

    if (action === 'enable') {
      if (account.account_status !== 'disabled') {
        return NextResponse.json({ success: false, message: 'Account is not disconnected' }, { status: 400 })
      }

      // Disabling never touched the actual Stripe account, only our local flags —
      // re-sync from Stripe's real status instead of blindly forcing 'pending',
      // so an account that was still fully set up doesn't get forced through onboarding again.
      let chargesEnabled = false
      let payoutsEnabled = false
      let detailsSubmitted = false

      if (account.stripe_account_id) {
        try {
          const stripeAccount = await retrieveStripeAccount(account.stripe_account_id)
          chargesEnabled = stripeAccount.charges_enabled ?? false
          payoutsEnabled = stripeAccount.payouts_enabled ?? false
          detailsSubmitted = stripeAccount.details_submitted ?? false
        } catch {
          // Stripe account no longer exists — fall through as not set up
        }
      }

      const newStatus = chargesEnabled && payoutsEnabled && detailsSubmitted ? 'active' : 'pending'

      const { error } = await adminClient
        .from('mosque_donation_accounts')
        .update({
          account_status: newStatus,
          charges_enabled: chargesEnabled,
          payouts_enabled: payoutsEnabled,
          details_submitted: detailsSubmitted,
          updated_at: new Date().toISOString(),
        })
        .eq('id', accountId)

      if (error) {
        return NextResponse.json({ success: false, message: 'Failed to re-enable account' }, { status: 500 })
      }

      return NextResponse.json({
        success: true,
        message:
          newStatus === 'active'
            ? 'Mosque Stripe account re-enabled and is already fully set up.'
            : 'Mosque Stripe account re-enabled. Owner can now reconnect Stripe.',
        data: { account_status: newStatus },
      })
    }

    if (account.account_status === 'disabled') {
      return NextResponse.json({ success: false, message: 'Account is already disconnected' }, { status: 400 })
    }

    const { error } = await adminClient
      .from('mosque_donation_accounts')
      .update({
        account_status: 'disabled',
        charges_enabled: false,
        payouts_enabled: false,
        updated_at: new Date().toISOString(),
      })
      .eq('id', accountId)

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to disconnect account' }, { status: 500 })
    }

    return NextResponse.json({ success: true, message: 'Mosque Stripe account disconnected.' })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}

// DELETE /api/admin/donations/accounts/:accountId — permanently remove (force mosque to reconnect from scratch)
export async function DELETE(request: NextRequest, context: RouteContext) {
  try {
    const { accountId } = await context.params
    const adminClient = await createAdminClient()

    const { error } = await adminClient
      .from('mosque_donation_accounts')
      .delete()
      .eq('id', accountId)

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to remove account' }, { status: 500 })
    }

    return NextResponse.json({ success: true, message: 'Mosque account removed. Mosque must reconnect Stripe.' })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}
