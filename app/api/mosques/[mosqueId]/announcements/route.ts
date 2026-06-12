import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageAnnouncements } from '@/lib/helpers/mosque-permissions'
import { notifyAnnouncementCreated } from '@/lib/services/mosque-notifications'
import type { CreateAnnouncementBody } from '@/lib/types/announcements'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/announcements — public read
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const { mosqueId } = await context.params
    const { searchParams } = new URL(request.url)
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')

    const adminClient = await createAdminClient()

    const from = (page - 1) * limit
    const to = from + limit - 1

    const { data: announcements, error, count } = await adminClient
      .from('mosque_announcements')
      .select('*', { count: 'exact' })
      .eq('mosque_id', mosqueId)
      .order('created_at', { ascending: false })
      .range(from, to)

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch announcements', details: error.message },
        { status: 500 }
      )
    }

    return NextResponse.json({
      announcements: announcements ?? [],
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

// POST /api/mosques/:mosqueId/announcements — owner/admin only
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

    const allowed = await canManageAnnouncements(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json({ error: 'Forbidden: owner or admin role required' }, { status: 403 })
    }

    const body: CreateAnnouncementBody = await request.json()

    if (!body.title || !body.content) {
      return NextResponse.json({ error: 'title and content are required' }, { status: 400 })
    }

    const { data: announcement, error: insertError } = await adminClient
      .from('mosque_announcements')
      .insert({
        mosque_id: mosqueId,
        title: body.title,
        content: body.content,
        created_by: user.id,
      })
      .select()
      .single()

    if (insertError) {
      return NextResponse.json(
        { error: 'Failed to create announcement', details: insertError.message },
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
    const notification = await notifyAnnouncementCreated(
      mosqueId,
      mosque?.name ?? 'Mosque',
      body.title
    ).catch(() => null)

    return NextResponse.json(
      { success: true, announcement, notification },
      { status: 201 }
    )
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
