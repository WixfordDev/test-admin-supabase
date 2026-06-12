import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

type RouteContext = {
  params: Promise<{ id: string }>
}

function generateVerificationCode(): string {
  const digits = Math.floor(100000 + Math.random() * 900000)
  return `DH-${digits}`
}

// Admin: PUT /api/admin/mosque-claims/[id]/approve
// Approves a pending claim and generates a postal verification code
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

    if (claim.status !== 'pending') {
      return NextResponse.json(
        { error: `Claim is already ${claim.status}` },
        { status: 409 }
      )
    }

    const verificationCode = generateVerificationCode()

    const { data: updated, error: updateError } = await adminClient
      .from('mosque_claims')
      .update({
        status: 'approved',
        verification_code: verificationCode,
      })
      .eq('id', id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: 'Failed to approve claim' }, { status: 500 })
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
