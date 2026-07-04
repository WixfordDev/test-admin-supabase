import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import type { StripeConnectStatusLabel } from '@/lib/types/donations'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/stripe/status
// Any authenticated user can check if a mosque accepts donations
export async function GET(request: NextRequest, context: RouteContext) {
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

    const { data: account } = await adminClient
      .from('mosque_donation_accounts')
      .select('stripe_account_id, account_status, charges_enabled, payouts_enabled, details_submitted')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!account) {
      return NextResponse.json({
        success: true,
        data: {
          status: 'not_connected' as StripeConnectStatusLabel,
          charges_enabled: false,
          payouts_enabled: false,
          details_submitted: false,
          stripe_account_id: null,
        },
      })
    }

    let status: StripeConnectStatusLabel = 'not_connected'
    if (account.charges_enabled && account.payouts_enabled && account.details_submitted) {
      status = 'connected'
    } else if (account.stripe_account_id) {
      status = 'pending'
    }

    return NextResponse.json({
      success: true,
      data: {
        status,
        charges_enabled: account.charges_enabled,
        payouts_enabled: account.payouts_enabled,
        details_submitted: account.details_submitted,
        stripe_account_id: account.stripe_account_id,
      },
    })
  } catch (err: any) {
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    )
  }
}
