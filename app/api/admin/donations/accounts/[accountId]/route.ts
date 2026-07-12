import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ accountId: string }>
}

// PATCH /api/admin/donations/accounts/:accountId — disable (disconnect) a mosque's Stripe account
export async function PATCH(request: NextRequest, context: RouteContext) {
  try {
    const { accountId } = await context.params
    const adminClient = await createAdminClient()

    const { data: account, error: fetchError } = await adminClient
      .from('mosque_donation_accounts')
      .select('id, account_status, mosque_id')
      .eq('id', accountId)
      .single()

    if (fetchError || !account) {
      return NextResponse.json({ success: false, message: 'Account not found' }, { status: 404 })
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
