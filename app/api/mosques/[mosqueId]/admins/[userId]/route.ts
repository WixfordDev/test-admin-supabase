import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { canManageAdmins } from '@/lib/helpers/mosque-permissions'

type RouteContext = {
  params: Promise<{ mosqueId: string; userId: string }>
}

// DELETE /api/mosques/:mosqueId/admins/:userId — owner removes an admin
export async function DELETE(request: NextRequest, context: RouteContext) {
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

    const { mosqueId, userId: targetUserId } = await context.params

    const allowed = await canManageAdmins(user.id, mosqueId)
    if (!allowed) {
      return NextResponse.json({ success: false, message: 'Forbidden: owner only' }, { status: 403 })
    }

    // Cannot remove yourself (owner)
    if (targetUserId === user.id) {
      return NextResponse.json({ success: false, message: 'Cannot remove yourself' }, { status: 400 })
    }

    // Verify target is an admin (not an owner)
    const { data: existing } = await adminClient
      .from('mosque_roles')
      .select('role')
      .eq('user_id', targetUserId)
      .eq('mosque_id', mosqueId)
      .maybeSingle()

    if (!existing) {
      return NextResponse.json({ success: false, message: 'User is not a member of this mosque' }, { status: 404 })
    }

    if (existing.role === 'owner') {
      return NextResponse.json({ success: false, message: 'Cannot remove the mosque owner' }, { status: 403 })
    }

    const { error } = await adminClient
      .from('mosque_roles')
      .delete()
      .eq('user_id', targetUserId)
      .eq('mosque_id', mosqueId)

    if (error) {
      return NextResponse.json({ success: false, message: 'Failed to remove admin' }, { status: 500 })
    }

    return NextResponse.json({ success: true, message: 'Admin removed successfully.' })
  } catch {
    return NextResponse.json({ success: false, message: 'Internal server error' }, { status: 500 })
  }
}
