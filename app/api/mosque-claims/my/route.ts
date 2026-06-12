import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

// Flutter: GET /api/mosque-claims/my
// Returns all claims submitted by the authenticated user
export async function GET(request: NextRequest) {
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

    const { data: claims, error } = await adminClient
      .from('mosque_claims')
      .select('*')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: 'Failed to fetch claims' }, { status: 500 })
    }

    // Fetch mosque info separately
    const mosqueIds = [...new Set((claims ?? []).map((c) => c.mosque_id))]
    let mosqueMap: Record<string, { mosque_id: string; name: string; address: string | null }> = {}

    if (mosqueIds.length > 0) {
      const { data: mosques } = await adminClient
        .from('mosques_metadata')
        .select('mosque_id, name, address')
        .in('mosque_id', mosqueIds)

      mosqueMap = Object.fromEntries((mosques ?? []).map((m) => [m.mosque_id, m]))
    }

    const claimsWithMosque = (claims ?? []).map((c) => ({
      ...c,
      mosque: mosqueMap[c.mosque_id] ?? null,
    }))

    return NextResponse.json({ claims: claimsWithMosque })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
