import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageEvents } from '@/lib/helpers/mosque-permissions'
import { notifyEventCreated } from '@/lib/services/mosque-notifications'
import type { CreateEventBody } from '@/lib/types/events'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/events — public read
// Query params: page, limit, upcoming=true, start_date=YYYY-MM-DD, end_date=YYYY-MM-DD
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const { mosqueId } = await context.params
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const upcomingOnly = searchParams.get('upcoming') === 'true'
    const startDate = searchParams.get('start_date')
    const endDate = searchParams.get('end_date')

    const adminClient = await createAdminClient()

    const rangeFrom = (page - 1) * limit
    const rangeTo = rangeFrom + limit - 1

    let query = adminClient
      .from('mosque_events')
      .select('*', { count: 'exact' })
      .eq('mosque_id', mosqueId)
      .eq('is_active', true)
      .order('event_date', { ascending: true })
      .range(rangeFrom, rangeTo)

    if (upcomingOnly) {
      query = query.gte('event_date', new Date().toISOString())
    }
    if (startDate) {
      query = query.gte('event_date', startDate)
    }
    if (endDate) {
      // end_date is a plain date (YYYY-MM-DD) — extend to end-of-day so that day's events are included
      query = query.lte('event_date', `${endDate}T23:59:59.999Z`)
    }

    const { data: events, error, count } = await query

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch events', details: error.message },
        { status: 500 }
      )
    }

    // Attach attendance counts so the list doesn't need a separate call per event
    const eventIds = (events ?? []).map((e) => e.id)
    const { data: attendees } = eventIds.length
      ? await adminClient
          .from('mosque_event_attendees')
          .select('event_id, attendance_status')
          .in('event_id', eventIds)
      : { data: [] }

    const countsByEvent: Record<string, { going: number; maybe: number; total: number }> = {}
    for (const a of attendees ?? []) {
      const bucket = (countsByEvent[a.event_id] ??= { going: 0, maybe: 0, total: 0 })
      bucket.total += 1
      if (a.attendance_status === 'going') bucket.going += 1
      if (a.attendance_status === 'maybe') bucket.maybe += 1
    }

    const enrichedEvents = (events ?? []).map((e) => ({
      ...e,
      attendee_count: countsByEvent[e.id] ?? { going: 0, maybe: 0, total: 0 },
    }))

    return NextResponse.json({
      events: enrichedEvents,
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

// POST /api/mosques/:mosqueId/events — owner/admin only
export async function POST(request: NextRequest, context: RouteContext) {
  try {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    const token = authHeader.split(' ')[1]

    const adminClient = await createAdminClient()
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)
    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { mosqueId } = await context.params

    const allowed = await canManageEvents(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json({ error: 'Forbidden: owner or admin role required' }, { status: 403 })
    }

    const body: CreateEventBody = await request.json()

    if (!body.title || !body.event_date) {
      return NextResponse.json({ error: 'title and event_date are required' }, { status: 400 })
    }

    const { data: event, error: insertError } = await adminClient
      .from('mosque_events')
      .insert({
        mosque_id: mosqueId,
        title: body.title,
        description: body.description ?? null,
        event_date: body.event_date,
        end_date: body.end_date ?? null,
        location: body.location ?? null,
        image_url: body.image_url ?? null,
        max_attendees: body.max_attendees ?? null,
        is_active: true,
        created_by: user.id,
      })
      .select()
      .single()

    if (insertError) {
      return NextResponse.json(
        { error: 'Failed to create event', details: insertError.message },
        { status: 500 }
      )
    }

    // Fetch mosque name for notification
    const { data: mosque } = await adminClient
      .from('mosques_metadata')
      .select('name')
      .eq('mosque_id', mosqueId)
      .single()

    // Fire notification (non-blocking)
    const notification = await notifyEventCreated(
      mosqueId,
      mosque?.name ?? 'Mosque',
      body.title
    ).catch(() => null)

    return NextResponse.json(
      { success: true, event, notification },
      { status: 201 }
    )
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
