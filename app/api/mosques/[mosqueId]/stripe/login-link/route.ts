import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/services/stripe'
import { canConnectStripe } from '@/lib/helpers/mosque-permissions'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/stripe/login-link
// Returns a Stripe Express Dashboard login URL for the verified mosque owner
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

    const allowed = await canConnectStripe(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json(
        { success: false, message: 'Forbidden: verified mosque owner only' },
        { status: 403 }
      )
    }

    const { data: account } = await adminClient
      .from('mosque_donation_accounts')
      .select('stripe_account_id, account_status, charges_enabled')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!account?.stripe_account_id) {
      return NextResponse.json(
        { success: false, message: 'Stripe account not connected yet' },
        { status: 422 }
      )
    }

    if (!account.charges_enabled) {
      return NextResponse.json(
        { success: false, message: 'Stripe account setup is not complete' },
        { status: 422 }
      )
    }

    // Generate a one-time Stripe Express Dashboard login link
    const loginLink = await stripe.accounts.createLoginLink(account.stripe_account_id)

    return NextResponse.json({
      success: true,
      message: 'Stripe dashboard link generated.',
      data: {
        url: loginLink.url,
      },
    })
  } catch (err: any) {
    console.error('[stripe/login-link]', err)
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}
