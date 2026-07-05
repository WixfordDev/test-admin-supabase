import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@/lib/services/stripe'
import { canConnectStripe } from '@/lib/helpers/mosque-permissions'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/stripe/dashboard
// Verified mosque owner sees their Stripe balance + donation stats
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

    // Fetch mosque donation account
    const { data: account } = await adminClient
      .from('mosque_donation_accounts')
      .select('*')
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!account?.stripe_account_id) {
      return NextResponse.json({
        success: true,
        data: {
          status: 'not_connected',
          balance: null,
          stats: null,
        },
      })
    }

    // Fetch Stripe balance for the connected account
    let balance = null
    try {
      const stripeBalance = await stripe.balance.retrieve(
        {},
        { stripeAccount: account.stripe_account_id }
      )
      balance = {
        available: stripeBalance.available.map((b) => ({
          amount: b.amount,
          currency: b.currency,
        })),
        pending: stripeBalance.pending.map((b) => ({
          amount: b.amount,
          currency: b.currency,
        })),
      }
    } catch {
      // Balance fetch failed — non-critical
    }

    // Donation stats from DB
    const { data: allTx } = await adminClient
      .from('donation_transactions')
      .select('amount, mosque_amount, platform_fee, created_at')
      .eq('mosque_id', mosqueId)
      .eq('status', 'completed')

    const totalDonations = allTx?.reduce((sum, t) => sum + (t.amount ?? 0), 0) ?? 0
    const totalMosqueAmount = allTx?.reduce((sum, t) => sum + (t.mosque_amount ?? 0), 0) ?? 0
    const totalTransactions = allTx?.length ?? 0

    // Monthly donations (current month)
    const now = new Date()
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1).toISOString()
    const monthlyTx = allTx?.filter((t) => t.created_at >= monthStart) ?? []
    const monthlyDonations = monthlyTx.reduce((sum, t) => sum + (t.amount ?? 0), 0)
    const monthlyTransactions = monthlyTx.length

    return NextResponse.json({
      success: true,
      data: {
        status: account.account_status,
        charges_enabled: account.charges_enabled,
        payouts_enabled: account.payouts_enabled,
        stripe_account_id: account.stripe_account_id,
        balance,
        stats: {
          total_donations_cents: totalDonations,
          total_mosque_amount_cents: totalMosqueAmount,
          total_transactions: totalTransactions,
          monthly_donations_cents: monthlyDonations,
          monthly_transactions: monthlyTransactions,
        },
      },
    })
  } catch (err: any) {
    console.error('[stripe/dashboard]', err)
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}
