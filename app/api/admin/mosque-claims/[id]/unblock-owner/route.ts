import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

// Admin: PUT /api/admin/mosque-claims/[id]/unblock-owner
// Restores the owner's management access (announcements/events)
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
        { error: 'Only a verified mosque owner can be unblocked' },
        { status: 409 }
      )
    }

    const { error: updateError } = await adminClient
      .from('mosque_roles')
      .update({ is_blocked: false })
      .eq('mosque_id', claim.mosque_id)
      .eq('user_id', claim.user_id)

    if (updateError) {
      return NextResponse.json({ error: 'Failed to unblock owner access' }, { status: 500 })
    }

    return NextResponse.json({ success: true, message: 'Owner access restored' })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
