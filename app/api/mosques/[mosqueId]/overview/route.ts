import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { getMosqueRole } from '@/lib/helpers/mosque-permissions'
import type { StripeConnectStatusLabel } from '@/lib/types/donations'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/overview
// Owner-only dashboard summary: announcement/event counts, campaign totals,
// donation totals, and Stripe connection status — all in one call for the app's
// "my mosque" overview screen.
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

    const role = await getMosqueRole(user.id, mosqueId)
    if (role !== 'owner') {
      return NextResponse.json(
        { success: false, message: 'Forbidden: verified mosque owner only' },
        { status: 403 }
      )
    }

    const nowIso = new Date().toISOString()
    const monthStartIso = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString()

    const [
      mosqueRes,
      announcementsCountRes,
      eventsTotalRes,
      eventsUpcomingRes,
      campaignsRes,
      donationAccountRes,
      completedTxRes,
    ] = await Promise.all([
      adminClient.from('mosques_metadata').select('mosque_id, name').eq('mosque_id', mosqueId).single(),
      adminClient
        .from('mosque_announcements')
        .select('id', { count: 'exact', head: true })
        .eq('mosque_id', mosqueId),
      adminClient
        .from('mosque_events')
        .select('id', { count: 'exact', head: true })
        .eq('mosque_id', mosqueId)
        .eq('is_active', true),
      adminClient
        .from('mosque_events')
        .select('id', { count: 'exact', head: true })
        .eq('mosque_id', mosqueId)
        .eq('is_active', true)
        .gte('event_date', nowIso),
      adminClient
        .from('mosque_campaigns')
        .select('is_active, goal_amount, raised_amount')
        .eq('mosque_id', mosqueId),
      adminClient
        .from('mosque_donation_accounts')
        .select('stripe_account_id, account_status, charges_enabled, payouts_enabled, details_submitted')
        .eq('mosque_id', mosqueId)
        .maybeSingle(),
      adminClient
        .from('donation_transactions')
        .select('amount, mosque_amount, created_at')
        .eq('mosque_id', mosqueId)
        .eq('status', 'completed'),
    ])

    const campaigns = campaignsRes.data ?? []
    const totalRaised = campaigns.reduce((sum, c) => sum + (c.raised_amount ?? 0), 0)
    const totalGoal = campaigns.reduce((sum, c) => sum + (c.goal_amount ?? 0), 0)
    const activeCampaigns = campaigns.filter((c) => c.is_active).length

    const completedTx = completedTxRes.data ?? []
    const totalDonations = completedTx.reduce((sum, t) => sum + (t.amount ?? 0), 0)
    const totalMosqueAmount = completedTx.reduce((sum, t) => sum + (t.mosque_amount ?? 0), 0)
    const monthlyTx = completedTx.filter((t) => t.created_at >= monthStartIso)
    const monthlyDonations = monthlyTx.reduce((sum, t) => sum + (t.amount ?? 0), 0)

    const account = donationAccountRes.data
    let stripeStatus: StripeConnectStatusLabel = 'not_connected'
    if (account?.charges_enabled && account?.payouts_enabled && account?.details_submitted) {
      stripeStatus = 'connected'
    } else if (account?.stripe_account_id) {
      stripeStatus = 'pending'
    }

    return NextResponse.json({
      success: true,
      data: {
        mosque: {
          mosque_id: mosqueId,
          name: mosqueRes.data?.name ?? null,
        },
        announcements: {
          total: announcementsCountRes.count ?? 0,
        },
        events: {
          total: eventsTotalRes.count ?? 0,
          upcoming: eventsUpcomingRes.count ?? 0,
        },
        campaigns: {
          total: campaigns.length,
          active: activeCampaigns,
          total_raised_cents: totalRaised,
          total_goal_cents: totalGoal,
        },
        donations: {
          total_amount_cents: totalDonations,
          total_mosque_amount_cents: totalMosqueAmount,
          total_transactions: completedTx.length,
          monthly_amount_cents: monthlyDonations,
          monthly_transactions: monthlyTx.length,
        },
        stripe: {
          status: stripeStatus,
          account_status: account?.account_status ?? null,
        },
      },
    })
  } catch (err: any) {
    console.error('[mosques/overview]', err)
    return NextResponse.json(
      { success: false, message: 'Internal server error', details: err?.message },
      { status: 500 }
    )
  }
}
