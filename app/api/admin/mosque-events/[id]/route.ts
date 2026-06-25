import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import type { UpdateEventBody } from '@/lib/types/events'

type RouteContext = {
  params: Promise<{ id: string }>
}

// Admin Dashboard: PUT /api/admin/mosque-events/:id — admin can edit any mosque's event
export async function PUT(request: NextRequest, context: RouteContext) {
  try {
    const adminClient = await createAdminClient()
    const { id } = await context.params

    const { data: existing, error: fetchError } = await adminClient
      .from('mosque_events')
      .select('*')
      .eq('id', id)
      .single()

    if (fetchError || !existing) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
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
      .eq('id', id)
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

// Admin Dashboard: DELETE /api/admin/mosque-events/:id — admin can delete any mosque's event
export async function DELETE(request: NextRequest, context: RouteContext) {
  try {
    const adminClient = await createAdminClient()
    const { id } = await context.params

    const { data: existing, error: fetchError } = await adminClient
      .from('mosque_events')
      .select('mosque_id')
      .eq('id', id)
      .single()

    if (fetchError || !existing) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    const { error: deleteError } = await adminClient
      .from('mosque_events')
      .delete()
      .eq('id', id)

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
