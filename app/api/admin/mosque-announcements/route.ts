import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// Admin Dashboard: GET /api/admin/mosque-announcements
// Supports: ?search=  &page=  &limit=
export async function GET(request: NextRequest) {
  try {
    const adminClient = await createAdminClient()
    const { searchParams } = new URL(request.url)

    const search = searchParams.get('search') || ''
    const mosqueId = searchParams.get('mosqueId') || ''
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')

    let query = adminClient
      .from('mosque_announcements')
      .select('*', { count: 'exact' })

    if (mosqueId) {
      query = query.eq('mosque_id', mosqueId)
    }

    if (search) {
      query = query.or(`title.ilike.%${search}%,content.ilike.%${search}%`)
    }

    query = query.order('created_at', { ascending: false })

    const from = (page - 1) * limit
    const to = from + limit - 1
    query = query.range(from, to)

    const { data: announcements, error, count } = await query

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch announcements', details: error.message },
        { status: 500 }
      )
    }

    const mosqueIds = [...new Set((announcements ?? []).map((a) => a.mosque_id))]
    let mosqueMap: Record<string, { mosque_id: string; name: string; address: string | null }> = {}

    if (mosqueIds.length > 0) {
      const { data: mosques } = await adminClient
        .from('mosques_metadata')
        .select('mosque_id, name, address')
        .in('mosque_id', mosqueIds)

      mosqueMap = Object.fromEntries((mosques ?? []).map((m) => [m.mosque_id, m]))
    }

    const announcementsWithMosque = (announcements ?? []).map((a) => ({
      ...a,
      mosque: mosqueMap[a.mosque_id] ?? null,
    }))

    return NextResponse.json({
      announcements: announcementsWithMosque,
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
