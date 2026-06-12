import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// Admin Dashboard: GET /api/admin/mosque-claims
// Supports: ?status=pending|approved|rejected|verified|all  &search=  &page=  &limit=
export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)

    const status = searchParams.get('status') || 'all'
    const search = searchParams.get('search') || ''
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '50')

    let query = adminClient
      .from('mosque_claims')
      .select('*', { count: 'exact' })

    if (status !== 'all') {
      query = query.eq('status', status)
    }

    if (search) {
      query = query.or(
        `mosque_email.ilike.%${search}%,position.ilike.%${search}%,notes.ilike.%${search}%`
      )
    }

    query = query.order('created_at', { ascending: false })

    const from = (page - 1) * limit
    const to = from + limit - 1
    query = query.range(from, to)

    const { data: claims, error, count } = await query

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch claims', details: error.message, code: error.code },
        { status: 500 }
      )
    }

    // Fetch mosque info separately (batch)
    const mosqueIds = [...new Set((claims ?? []).map((c) => c.mosque_id))]
    let mosqueMap: Record<string, { mosque_id: string; name: string; address: string | null }> = {}

    if (mosqueIds.length > 0) {
      const { data: mosques } = await adminClient
        .from('mosques_metadata')
        .select('mosque_id, name, address')
        .in('mosque_id', mosqueIds)

      mosqueMap = Object.fromEntries((mosques ?? []).map((m) => [m.mosque_id, m]))
    }

    const claimsWithMosque = (claims ?? []).map((c) => ({
      ...c,
      mosque: mosqueMap[c.mosque_id] ?? null,
    }))

    // Aggregate stats across all records (no filter)
    const { data: statsData } = await adminClient
      .from('mosque_claims')
      .select('status')

    const stats = {
      total: statsData?.length ?? 0,
      pending: statsData?.filter((c) => c.status === 'pending').length ?? 0,
      approved: statsData?.filter((c) => c.status === 'approved').length ?? 0,
      rejected: statsData?.filter((c) => c.status === 'rejected').length ?? 0,
      verified: statsData?.filter((c) => c.status === 'verified').length ?? 0,
    }

    return NextResponse.json({
      claims: claimsWithMosque,
      stats,
      pagination: {
        page,
        limit,
        total: count ?? 0,
        totalPages: Math.ceil((count ?? 0) / limit),
      },
    })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
