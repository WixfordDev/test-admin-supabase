import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// GET /api/admin/donations — Admin: donation stats + transactions + connected mosques
export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const from = (page - 1) * limit
    const to = from + limit - 1

    // Donation accounts (connected mosques)
    const { data: accounts } = await adminClient
      .from('mosque_donation_accounts')
      .select('mosque_id, account_status, charges_enabled, stripe_account_id, created_at')

    const connectedCount = accounts?.filter((a) => a.account_status === 'active').length ?? 0
    const pendingCount = accounts?.filter((a) => a.account_status === 'pending').length ?? 0

    // Completed transactions for stats
    const { data: completedTx } = await adminClient
      .from('donation_transactions')
      .select('amount, platform_fee, mosque_amount')
      .eq('status', 'completed')

    const totalDonations = completedTx?.reduce((sum, t) => sum + (t.amount ?? 0), 0) ?? 0
    const platformRevenue = completedTx?.reduce((sum, t) => sum + (t.platform_fee ?? 0), 0) ?? 0

    // Recent transactions with mosque name
    const { data: transactions, count } = await adminClient
      .from('donation_transactions')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(from, to)

    // Fetch mosque names for transactions
    const mosqueIds = [...new Set(transactions?.map((t) => t.mosque_id) ?? [])]
    const { data: mosques } = mosqueIds.length
      ? await adminClient
          .from('mosques_metadata')
          .select('mosque_id, name')
          .in('mosque_id', mosqueIds)
      : { data: [] }

    const mosqueMap = Object.fromEntries((mosques ?? []).map((m) => [m.mosque_id, m.name]))

    const enrichedTransactions = (transactions ?? []).map((t) => ({
      ...t,
      mosque_name: mosqueMap[t.mosque_id] ?? t.mosque_id,
    }))

    // Connected mosques detail
    const { data: connectedAccounts } = await adminClient
      .from('mosque_donation_accounts')
      .select('*')
      .order('created_at', { ascending: false })

    const accountMosqueIds = [...new Set(connectedAccounts?.map((a) => a.mosque_id) ?? [])]
    const { data: accountMosques } = accountMosqueIds.length
      ? await adminClient
          .from('mosques_metadata')
          .select('mosque_id, name')
          .in('mosque_id', accountMosqueIds)
      : { data: [] }

    const accountMosqueMap = Object.fromEntries(
      (accountMosques ?? []).map((m) => [m.mosque_id, m.name])
    )

    const enrichedAccounts = (connectedAccounts ?? []).map((a) => ({
      ...a,
      mosque_name: accountMosqueMap[a.mosque_id] ?? a.mosque_id,
    }))

    return NextResponse.json({
      stats: {
        connected_mosques: connectedCount,
        pending_connections: pendingCount,
        total_donations_cents: totalDonations,
        platform_revenue_cents: platformRevenue,
        total_transactions: count ?? 0,
      },
      transactions: enrichedTransactions,
      accounts: enrichedAccounts,
      pagination: {
        page,
        limit,
        total: count ?? 0,
        totalPages: Math.ceil((count ?? 0) / limit),
      },
    })
  } catch (err: any) {
    console.error('[admin/donations]', err)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
