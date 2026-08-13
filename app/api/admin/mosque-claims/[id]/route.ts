import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

// Admin Dashboard: GET /api/admin/mosque-claims/:id — single claim with mosque info
export async function GET(request: NextRequest, context: RouteContext) {
  try {
    const adminClient = await createAdminClient()
    const { id } = await context.params

    const { data: claim, error } = await adminClient
      .from('mosque_claims')
      .select('*')
      .eq('id', id)
      .single()

    if (error || !claim) {
      return NextResponse.json({ error: 'Claim not found' }, { status: 404 })
    }

    const { data: mosque } = await adminClient
      .from('mosques_metadata')
      .select('mosque_id, name, address')
      .eq('mosque_id', claim.mosque_id)
      .single()

    let ownerBlocked: boolean | null = null
    let ownerEmail: string | null = null
    if (claim.status === 'verified') {
      const { data: role } = await adminClient
        .from('mosque_roles')
        .select('is_blocked')
        .eq('mosque_id', claim.mosque_id)
        .eq('user_id', claim.user_id)
        .maybeSingle()
      ownerBlocked = role?.is_blocked ?? false

      const { data: { user: ownerUser } } = await adminClient.auth.admin.getUserById(claim.user_id)
      ownerEmail = ownerUser?.email ?? null
    }

    return NextResponse.json({
      claim: { ...claim, mosque: mosque ?? null },
      owner_blocked: ownerBlocked,
      owner_email: ownerEmail,
    })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
