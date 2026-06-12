import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageEvents } from '@/lib/helpers/mosque-permissions'
import type { UpdateEventBody } from '@/lib/types/events'

type RouteContext = {
  params: Promise<{ eventId: string }>
}

export async function PUT(request: NextRequest, context: RouteContext) {
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

    const { data: existing, error: fetchError } = await adminClient
      .from('mosque_events')
      .select('*')
      .eq('id', eventId)
      .single()

    if (fetchError || !existing) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    const allowed = await canManageEvents(user.id, existing.mosque_id)
    if (!allowed) {
      return NextResponse.json({ error: 'Forbidden: owner or admin role required' }, { status: 403 })
    }

    const body: UpdateEventBody = await request.json()
    const updateData: Partial<UpdateEventBody> & { updated_at: string } = {
      updated_at: new Date().toISOString(),
    }

    if (body.title !== undefined) updateData.title = body.title
    if (body.description !== undefined) updateData.description = body.description
    if (body.event_date !== undefined) updateData.event_date = body.event_date
    if (body.end_date !== undefined) updateData.end_date = body.end_date
    if (body.location !== undefined) updateData.location = body.location
    if (body.image_url !== undefined) updateData.image_url = body.image_url
    if (body.max_attendees !== undefined) updateData.max_attendees = body.max_attendees
    if (body.is_active !== undefined) updateData.is_active = body.is_active

    const { data: updated, error: updateError } = await adminClient
      .from('mosque_events')
      .update(updateData)
      .eq('id', eventId)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json(
        { error: 'Failed to update event', details: updateError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, event: updated })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

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

    const { data: existing, error: fetchError } = await adminClient
      .from('mosque_events')
      .select('mosque_id')
      .eq('id', eventId)
      .single()

    if (fetchError || !existing) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    const allowed = await canManageEvents(user.id, existing.mosque_id)
    if (!allowed) {
      return NextResponse.json({ error: 'Forbidden: owner or admin role required' }, { status: 403 })
    }

    const { error: deleteError } = await adminClient
      .from('mosque_events')
      .delete()
      .eq('id', eventId)

    if (deleteError) {
      return NextResponse.json(
        { error: 'Failed to delete event', details: deleteError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, message: 'Event deleted' })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
