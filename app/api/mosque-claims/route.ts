import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import type { SubmitClaimBody } from '@/lib/types/mosque-claims'

// Flutter sends: Authorization: Bearer <supabase_jwt>
export async function POST(request: NextRequest) {
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

    const body: SubmitClaimBody = await request.json()

    if (!body.mosque_id) {
      return NextResponse.json({ error: 'mosque_id is required' }, { status: 400 })
    }

    // Verify mosque exists
    const { data: mosque, error: mosqueError } = await adminClient
      .from('mosques_metadata')
      .select('mosque_id, name, is_claimed')
      .eq('mosque_id', body.mosque_id)
      .single()

    if (mosqueError || !mosque) {
      return NextResponse.json({ error: 'Mosque not found' }, { status: 404 })
    }

    if (mosque.is_claimed) {
      return NextResponse.json({ error: 'Mosque is already claimed' }, { status: 409 })
    }

    // Prevent any other user from claiming a mosque that already has an active claim
    const { data: existingClaims } = await adminClient
      .from('mosque_claims')
      .select('id, user_id, status')
      .eq('mosque_id', body.mosque_id)
      .in('status', ['pending', 'approved'])
      .limit(1)

    const existingClaim = existingClaims?.[0]
    if (existingClaim) {
      const message =
        existingClaim.user_id === user.id
          ? 'You already have an active claim for this mosque'
          : 'This mosque already has an active claim from another user'
      return NextResponse.json({ error: message }, { status: 409 })
    }

    const { data: claim, error: insertError } = await adminClient
      .from('mosque_claims')
      .insert({
        mosque_id: body.mosque_id,
        user_id: user.id,
        mosque_email: body.mosque_email ?? null,
        mosque_phone: body.mosque_phone ?? null,
        position: body.position ?? null,
        notes: body.notes ?? null,
        status: 'pending',
        verification_status: 'pending',
      })
      .select()
      .single()

    if (insertError) {
      return NextResponse.json(
        { error: 'Failed to submit claim', details: insertError.message, code: insertError.code },
        { status: 500 }
      )
    }

    return NextResponse.json({ success: true, claim }, { status: 201 })
  } catch (err: any) {
    return NextResponse.json({ error: 'Internal server error', details: err?.message }, { status: 500 })
  }
}
