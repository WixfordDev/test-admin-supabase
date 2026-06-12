import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

// Admin: PUT /api/admin/mosque-claims/[id]/reject
// Body (optional): { reason: string }
export async function PUT(request: NextRequest, context: RouteContext) {
  try {
    const adminClient = await createAdminClient()
    const { id } = await context.params

    const { data: claim, error: fetchError } = await adminClient
      .from('mosque_claims')
      .select('*')
      .eq('id', id)
      .single()

    if (fetchError || !claim) {
      return NextResponse.json({ error: 'Claim not found' }, { status: 404 })
    }

    if (claim.status === 'verified') {
      return NextResponse.json(
        { error: 'Cannot reject a verified claim' },
        { status: 409 }
      )
    }

    if (claim.status === 'rejected') {
      return NextResponse.json(
        { error: 'Claim is already rejected' },
        { status: 409 }
      )
    }

    const { data: updated, error: updateError } = await adminClient
      .from('mosque_claims')
      .update({ status: 'rejected' })
      .eq('id', id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: 'Failed to reject claim' }, { status: 500 })
    }

    return NextResponse.json({ success: true, claim: updated })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
