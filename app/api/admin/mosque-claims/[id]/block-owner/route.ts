import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

// Admin: PUT /api/admin/mosque-claims/[id]/block-owner
// Revokes the owner's management access (announcements/events) without deleting the role record
export async function PUT(request: NextRequest, context: RouteContext) {
  try {
    const adminClient = await createAdminClient()
    const { id } = await context.params

    const { data: claim, error: fetchError } = await adminClient
      .from('mosque_claims')
      .select('mosque_id, user_id, status')
      .eq('id', id)
      .single()

    if (fetchError || !claim) {
      return NextResponse.json({ error: 'Claim not found' }, { status: 404 })
    }

    if (claim.status !== 'verified') {
      return NextResponse.json(
        { error: 'Only a verified mosque owner can be blocked' },
        { status: 409 }
      )
    }

    const { error: updateError } = await adminClient
      .from('mosque_roles')
      .update({ is_blocked: true })
      .eq('mosque_id', claim.mosque_id)
      .eq('user_id', claim.user_id)

    if (updateError) {
      return NextResponse.json({ error: 'Failed to block owner access' }, { status: 500 })
    }

    return NextResponse.json({ success: true, message: 'Owner access blocked' })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
