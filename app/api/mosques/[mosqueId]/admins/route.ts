import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageAdmins } from '@/lib/helpers/mosque-permissions'

type RouteContext = {
  params: Promise<{ mosqueId: string }>
}

// GET /api/mosques/:mosqueId/admins — list all admins (owner only)
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }
    const token = authHeader.split(' ')[1]

    const adminClient = await createAdminClient()
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)
    if (authError || !user) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }

    const { mosqueId } = await context.params

    const allowed = await canManageAdmins(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json({ success: false, message: 'Forbidden: owner only' }, { status: 403 })
    }

    const { data: roles, error } = await adminClient
      .from('mosque_roles')
      .select('user_id, role, is_blocked, created_at')
      .eq('mosque_id', mosqueId)
      .in('role', ['admin', 'owner'])
      .order('created_at', { ascending: true })

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to fetch admins' }, { status: 500 })
    }

    // Enrich with user emails from auth
    const userIds = roles?.map((r) => r.user_id) ?? []
    const emailMap: Record<string, string> = {}
    for (const uid of userIds) {
      try {
        const { data: { user: u } } = await adminClient.auth.admin.getUserById(uid)
        if (u?.email) emailMap[uid] = u.email
      } catch { /* skip */ }
    }

    const members = (roles ?? []).map((r) => ({
      user_id: r.user_id,
      email: emailMap[r.user_id] ?? null,
      role: r.role,
      is_blocked: r.is_blocked,
      added_at: r.created_at,
    }))

    return NextResponse.json({ success: true, data: { members } })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}

// POST /api/mosques/:mosqueId/admins — owner adds a new admin by email
export async function POST(request: NextRequest, context: RouteContext) {
  try {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }
    const token = authHeader.split(' ')[1]

    const adminClient = await createAdminClient()
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)
    if (authError || !user) {
      return NextResponse.json({ success: false, message: 'Unauthorized' }, { status: 401 })
    }

    const { mosqueId } = await context.params

    const allowed = await canManageAdmins(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json({ success: false, message: 'Forbidden: owner only' }, { status: 403 })
    }

    const body = await request.json()
    const { email, user_id } = body

    if (!email && !user_id) {
      return NextResponse.json({ success: false, message: 'email or user_id required' }, { status: 400 })
    }

    // Resolve user_id from email if not provided
    let targetUserId = user_id
    if (!targetUserId && email) {
      const { data: { users } } = await adminClient.auth.admin.listUsers()
      const found = users.find((u) => u.email?.toLowerCase() === email.toLowerCase())
      if (!found) {
        return NextResponse.json({ success: false, message: 'No user found with that email' }, { status: 404 })
      }
      targetUserId = found.id
    }

    // Cannot add yourself
    if (targetUserId === user.id) {
      return NextResponse.json({ success: false, message: 'You cannot add yourself as admin' }, { status: 400 })
    }

    // Check if target is already owner of this mosque
    const { data: existing } = await adminClient
      .from('mosque_roles')
      .select('role')
      .eq('user_id', targetUserId)
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (existing?.role === 'owner') {
      return NextResponse.json({ success: false, message: 'This user is already the mosque owner' }, { status: 409 })
    }

    if (existing?.role === 'admin') {
      return NextResponse.json({ success: false, message: 'This user is already an admin of this mosque' }, { status: 409 })
    }

    // Add as admin
    const { error } = await adminClient
      .from('mosque_roles')
      .upsert(
        {
          user_id: targetUserId,
          mosque_id: mosqueId,
          role: 'admin',
          is_blocked: false,
        },
        { onConflict: 'user_id,mosque_id' }
      )

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to add admin' }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      message: 'Admin added successfully.',
      data: { user_id: targetUserId, role: 'admin' },
    })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}
