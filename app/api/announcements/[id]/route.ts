import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageAnnouncements } from '@/lib/helpers/mosque-permissions'
import type { UpdateAnnouncementBody } from '@/lib/types/announcements'

type RouteContext = {
  params: Promise<{ id: string }>
}

// PUT /api/announcements/:id — owner/admin only
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

    const { id } = await context.params

    const { data: existing, error: fetchError } = await adminClient
      .from('mosque_announcements')
      .select('*')
      .eq('id', id)
      .single()

    if (fetchError || !existing) {
      return NextResponse.json({ error: 'Announcement not found' }, { status: 404 })
    }

    const allowed = await canManageAnnouncements(user.id, existing.mosque_id)
    if (!allowed) {
      return NextResponse.json({ error: 'Forbidden: owner or admin role required' }, { status: 403 })
    }

    const body: UpdateAnnouncementBody = await request.json()
    const updateData: UpdateAnnouncementBody = {}
    if (body.title !== undefined) updateData.title = body.title
    if (body.content !== undefined) updateData.content = body.content

    const { data: updated, error: updateError } = await adminClient
      .from('mosque_announcements')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json(
        { error: 'Failed to update announcement', details: updateError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, announcement: updated })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

// DELETE /api/announcements/:id — owner/admin only
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

    const { id } = await context.params

    const { data: existing, error: fetchError } = await adminClient
      .from('mosque_announcements')
      .select('mosque_id')
      .eq('id', id)
      .single()

    if (fetchError || !existing) {
      return NextResponse.json({ error: 'Announcement not found' }, { status: 404 })
    }

    const allowed = await canManageAnnouncements(user.id, existing.mosque_id)
    if (!allowed) {
      return NextResponse.json({ error: 'Forbidden: owner or admin role required' }, { status: 403 })
    }

    const { error: deleteError } = await adminClient
      .from('mosque_announcements')
      .delete()
      .eq('id', id)

    if (deleteError) {
      return NextResponse.json(
        { error: 'Failed to delete announcement', details: deleteError.message },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, message: 'Announcement deleted' })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
