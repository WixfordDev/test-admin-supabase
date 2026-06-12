import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import type { AttendEventBody } from '@/lib/types/events'

type RouteContext = {
  params: Promise<{ eventId: string }>
}

// POST /api/events/:eventId/attend — any authenticated user
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

    const { eventId } = await context.params

    // Verify event exists and is active
    const { data: event, error: eventError } = await adminClient
      .from('mosque_events')
      .select('id, is_active, max_attendees')
      .eq('id', eventId)
      .single()

    if (eventError || !event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    if (!event.is_active) {
      return NextResponse.json({ error: 'Event is no longer active' }, { status: 409 })
    }

    const body: AttendEventBody = await request.json()

    if (!body.attendance_status || !['going', 'maybe'].includes(body.attendance_status)) {
      return NextResponse.json(
        { error: 'attendance_status must be "going" or "maybe"' },
        { status: 400 }
      )
    }

    // Check capacity if max_attendees is set and status is 'going'
    if (event.max_attendees && body.attendance_status === 'going') {
      const { count } = await adminClient
        .from('mosque_event_attendees')
        .select('*', { count: 'exact', head: true })
        .eq('event_id', eventId)
        .eq('attendance_status', 'going')
        .neq('user_id', user.id) // exclude current user (might be updating)

      if ((count ?? 0) >= event.max_attendees) {
        return NextResponse.json({ error: 'Event is at full capacity' }, { status: 409 })
      }
    }

    const now = new Date().toISOString()

    // Upsert attendance (insert or update if already exists)
    const { data: attendance, error: upsertError } = await adminClient
      .from('mosque_event_attendees')
      .upsert(
        {
          event_id: eventId,
          user_id: user.id,
          attendance_status: body.attendance_status,
          reminder_enabled: body.reminder_enabled ?? false,
          updated_at: now,
        },
        { onConflict: 'event_id,user_id' }
      )
      .select()
      .single()

    if (upsertError) {
      return NextResponse.json(
        { error: 'Failed to register attendance', details: upsertError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, attendance })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

// DELETE /api/events/:eventId/attend — any authenticated user
export async function DELETE(request: NextRequest, context: RouteContext) {
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

    const { eventId } = await context.params

    const { error: deleteError } = await adminClient
      .from('mosque_event_attendees')
      .delete()
      .eq('event_id', eventId)
      .eq('user_id', user.id)

    if (deleteError) {
      return NextResponse.json(
        { error: 'Failed to remove attendance', details: deleteError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, message: 'Attendance removed' })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
