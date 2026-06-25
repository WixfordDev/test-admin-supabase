import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// Admin Dashboard: GET /api/admin/mosque-events
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
      .from('mosque_events')
      .select('*', { count: 'exact' })

    if (mosqueId) {
      query = query.eq('mosque_id', mosqueId)
    }

    if (search) {
      query = query.or(`title.ilike.%${search}%,location.ilike.%${search}%`)
    }

    query = query.order('event_date', { ascending: false })

    const from = (page - 1) * limit
    const to = from + limit - 1
    query = query.range(from, to)

    const { data: events, error, count } = await query

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch events', details: error.message },
        { status: 500 }
      )
    }

    const mosqueIds = [...new Set((events ?? []).map((e) => e.mosque_id))]
    let mosqueMap: Record<string, { mosque_id: string; name: string; address: string | null }> = {}

    if (mosqueIds.length > 0) {
      const { data: mosques } = await adminClient
        .from('mosques_metadata')
        .select('mosque_id, name, address')
        .in('mosque_id', mosqueIds)

      mosqueMap = Object.fromEntries((mosques ?? []).map((m) => [m.mosque_id, m]))
    }

    const eventIds = (events ?? []).map((e) => e.id)
    let attendeeCounts: Record<string, number> = {}

    if (eventIds.length > 0) {
      const { data: attendees } = await adminClient
        .from('mosque_event_attendees')
        .select('event_id')
        .in('event_id', eventIds)

      attendeeCounts = (attendees ?? []).reduce((acc: Record<string, number>, a) => {
        acc[a.event_id] = (acc[a.event_id] ?? 0) + 1
        return acc
      }, {})
    }

    const eventsWithMosque = (events ?? []).map((e) => ({
      ...e,
      mosque: mosqueMap[e.mosque_id] ?? null,
      attendee_count: attendeeCounts[e.id] ?? 0,
    }))

    return NextResponse.json({
      events: eventsWithMosque,
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
