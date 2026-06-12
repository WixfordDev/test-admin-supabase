import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageEvents } from '@/lib/helpers/mosque-permissions'
import { notifyEventCreated } from '@/lib/services/mosque-notifications'
import type { CreateEventBody } from '@/lib/types/events'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/events — public read
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const { mosqueId } = await context.params
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const upcomingOnly = searchParams.get('upcoming') === 'true'

    const adminClient = await createAdminClient()

    const from = (page - 1) * limit
    const to = from + limit - 1

    let query = adminClient
      .from('mosque_events')
      .select('*', { count: 'exact' })
      .eq('mosque_id', mosqueId)
      .eq('is_active', true)
      .order('event_date', { ascending: true })
      .range(from, to)

    if (upcomingOnly) {
      query = query.gte('event_date', new Date().toISOString())
    }

    const { data: events, error, count } = await query

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch events', details: error.message },
        { status: 500 }
      )
    }

    return NextResponse.json({
      events: events ?? [],
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
