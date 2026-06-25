import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

function generateVerificationCode(): string {
  const digits = Math.floor(100000 + Math.random() * 900000)
  return `DH-${digits}`
}

// Admin: PUT /api/admin/mosque-claims/[id]/regenerate-code
// Generates a fresh postal verification code for a claim that is approved
// but not yet verified (e.g. the user lost the original postal code).
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

    if (claim.status !== 'approved') {
      return NextResponse.json(
        { error: `Cannot regenerate code for a claim that is ${claim.status}` },
        { status: 409 }
      )
    }

    const verificationCode = generateVerificationCode()

    const { data: updated, error: updateError } = await adminClient
      .from('mosque_claims')
      .update({ verification_code: verificationCode })
      .eq('id', id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: 'Failed to regenerate code' }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      claim: updated,
      verification_code: verificationCode,
    })
  } catch {
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
