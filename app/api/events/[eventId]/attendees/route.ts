import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ eventId: string }>
}

// GET /api/events/:eventId/attendees — any authenticated user
export async function GET(request: NextRequest, context: RouteContext) {
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

    // Verify event exists
    const { data: event, error: eventError } = await adminClient
      .from('mosque_events')
      .select('id')
      .eq('id', eventId)
      .single()

    if (eventError || !event) {
      return NextResponse.json({ error: 'Event not found' }, { status: 404 })
    }

    const { data: attendees, error } = await adminClient
      .from('mosque_event_attendees')
      .select('*')
      .eq('event_id', eventId)
      .order('created_at', { ascending: true })

    if (error) {
      return NextResponse.json(
        { error: 'Failed to fetch attendees', details: error.message },
        { status: 500 }
      )
    }

    const list = attendees ?? []
    const summary = {
      total: list.length,
      going: list.filter((a) => a.attendance_status === 'going').length,
      maybe: list.filter((a) => a.attendance_status === 'maybe').length,
    }

    return NextResponse.json({ attendees: list, summary })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
