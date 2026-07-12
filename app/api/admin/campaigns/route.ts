import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// GET /api/admin/campaigns — Admin: all campaigns with mosque info + stats
export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const search = searchParams.get('search') || ''
    const category = searchParams.get('category') || ''
    const status = searchParams.get('status') || ''
    const from = (page - 1) * limit
    const to = from + limit - 1

    // Stats
    const { data: allCampaigns } = await adminClient
      .from('mosque_campaigns')
      .select('is_active, goal_amount, raised_amount')

    const totalCampaigns = allCampaigns?.length ?? 0
    const activeCampaigns = allCampaigns?.filter((c) => c.is_active).length ?? 0
    const totalRaised = allCampaigns?.reduce((sum, c) => sum + (c.raised_amount ?? 0), 0) ?? 0
    const totalGoal = allCampaigns?.reduce((sum, c) => sum + (c.goal_amount ?? 0), 0) ?? 0

    // Campaigns with filters
    let query = adminClient
      .from('mosque_campaigns')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(from, to)

    if (category) query = query.eq('category', category)
    if (status === 'active') query = query.eq('is_active', true)
    if (status === 'inactive') query = query.eq('is_active', false)

    const { data: campaigns, count } = await query

    // Fetch mosque names
    const mosqueIds = [...new Set(campaigns?.map((c) => c.mosque_id) ?? [])]
    const { data: mosques } = mosqueIds.length
      ? await adminClient
          .from('mosques_metadata')
          .select('mosque_id, name')
          .in('mosque_id', mosqueIds)
      : { data: [] }

    const mosqueMap = Object.fromEntries((mosques ?? []).map((m) => [m.mosque_id, m.name]))

    let enriched = (campaigns ?? []).map((c) => ({
      ...c,
      mosque_name: mosqueMap[c.mosque_id] ?? c.mosque_id,
    }))

    if (search) {
      const q = search.toLowerCase()
      enriched = enriched.filter(
        (c) =>
          c.title.toLowerCase().includes(q) ||
          c.mosque_name.toLowerCase().includes(q)
      )
    }

    return NextResponse.json({
      stats: {
        total: totalCampaigns,
        active: activeCampaigns,
        inactive: totalCampaigns - activeCampaigns,
        total_raised_cents: totalRaised,
        total_goal_cents: totalGoal,
      },
      campaigns: enriched,
      pagination: {
        page,
        limit,
        total: count ?? 0,
        totalPages: Math.ceil((count ?? 0) / limit),
      },
    })
  } catch (err: any) {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
