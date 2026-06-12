import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import type { VerifyClaimBody } from '@/lib/types/mosque-claims'

// Flutter: POST /api/mosque-claims/verify
// User enters the verification code received by postal mail
export async function POST(request: NextRequest) {
  try {
    const authHeader = request.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return NextResponse.json(
        { error: 'Unauthorized', reason: 'Missing or invalid Authorization header' },
        { status: 401 }
      )
    }
    const token = authHeader.split(' ')[1]

    const adminClient = await createAdminClient()
    const { data: { user }, error: authError } = await adminClient.auth.getUser(token)
    if (authError || !user) {
      return NextResponse.json(
        { error: 'Unauthorized', reason: authError?.message ?? 'Invalid or expired token' },
        { status: 401 }
      )
    }

    const body: VerifyClaimBody = await request.json()

    if (!body.mosque_id || !body.verification_code) {
      return NextResponse.json(
        { error: 'mosque_id and verification_code are required' },
        { status: 400 }
      )
    }

    // Find the approved claim for this user + mosque
    const { data: claim, error: claimError } = await adminClient
      .from('mosque_claims')
      .select('*')
      .eq('mosque_id', body.mosque_id)
      .eq('user_id', user.id)
      .eq('status', 'approved')
      .eq('verification_status', 'pending')
      .maybeSingle()

    if (claimError || !claim) {
      return NextResponse.json(
        { error: 'No approved claim found for this mosque' },
        { status: 404 }
      )
    }

    if (claim.verification_code !== body.verification_code) {
      return NextResponse.json({ error: 'Invalid verification code' }, { status: 400 })
    }

    const now = new Date().toISOString()

    // Step 1: Mark claim as verified
    const { error: updateClaimError } = await adminClient
      .from('mosque_claims')
      .update({
        status: 'verified',
        verification_status: 'verified',
        verified_at: now,
      })
      .eq('id', claim.id)

    if (updateClaimError) {
      return NextResponse.json({ error: 'Failed to verify claim' }, { status: 500 })
    }

    // Step 2: Create owner role in mosque_roles
    const { error: roleError } = await adminClient
      .from('mosque_roles')
      .insert({
        mosque_id: body.mosque_id,
        user_id: user.id,
        role: 'owner',
      })

    if (roleError) {
      return NextResponse.json({ error: 'Failed to assign owner role' }, { status: 500 })
    }

    // Step 3: Mark mosque as claimed and set owner
    const { error: mosqueError } = await adminClient
      .from('mosques_metadata')
      .update({
        is_claimed: true,
        owner_user_id: user.id,
        updated_at: now,
      })
      .eq('mosque_id', body.mosque_id)

    if (mosqueError) {
      return NextResponse.json({ error: 'Failed to update mosque' }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      message: 'Mosque ownership verified successfully',
    })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
