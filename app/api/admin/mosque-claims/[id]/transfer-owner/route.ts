import { createAdminClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'
import { randomInt } from 'crypto'

type RouteContext = {
  params: Promise<{ id: string }>
}

const TEMP_PASSWORD_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%'

function generateTempPassword(length = 12): string {
  let password = ''
  for (let i = 0; i < length; i++) {
    password += TEMP_PASSWORD_CHARS[randomInt(TEMP_PASSWORD_CHARS.length)]
  }
  return password
}

// Admin: PUT /api/admin/mosque-claims/[id]/transfer-owner
// body: { email: string }
// Reassigns mosque ownership to a user found by email — or creates a fresh,
// unverified account for that email if none exists yet (matches the pattern
// used by /api/admin/users/add).
// The previous owner's mosque_roles row is removed entirely (not demoted to admin).
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
        { error: 'Only a verified mosque claim has an owner to transfer' },
        { status: 409 }
      )
    }

    const body = await request.json().catch(() => ({} as Record<string, unknown>))
    const email = typeof body?.email === 'string' ? body.email.trim() : ''

    if (!email) {
      return NextResponse.json({ error: 'email is required' }, { status: 400 })
    }

    const { data: { users } } = await adminClient.auth.admin.listUsers({ page: 1, perPage: 10000 })
    let newOwner = users.find((u) => u.email?.toLowerCase() === email.toLowerCase())
    let createdNewAccount = false
    let tempPassword: string | null = null

    if (!newOwner) {
      // No account with this email yet — create one with a temporary password
      // so ownership can be assigned right away; they log in and change it.
      tempPassword = generateTempPassword()
      const { data: created, error: createError } = await adminClient.auth.admin.createUser({
        email,
        password: tempPassword,
        email_confirm: true,
      })

      if (createError || !created?.user) {
        // Could be a genuine race (account created between our lookup and here) —
        // surface a clear message either way instead of a generic 500.
        const alreadyExists = createError?.message?.toLowerCase().includes('already registered')
        return NextResponse.json(
          {
            error: alreadyExists
              ? 'An account with that email already exists but could not be matched — please retry.'
              : `Failed to create account for that email: ${createError?.message ?? 'Unknown error'}`,
          },
          { status: alreadyExists ? 409 : 500 }
        )
      }

      newOwner = created.user
      createdNewAccount = true
    }

    if (newOwner.id === claim.user_id) {
      return NextResponse.json({ error: 'This user is already the owner' }, { status: 409 })
    }

    const now = new Date().toISOString()

    // Remove the previous owner's role entirely
    const { error: removeError } = await adminClient
      .from('mosque_roles')
      .delete()
      .eq('mosque_id', claim.mosque_id)
      .eq('user_id', claim.user_id)
      .eq('role', 'owner')

    if (removeError) {
      console.error('[transfer-owner] Failed to remove previous owner:', removeError)
      return NextResponse.json({ error: 'Failed to remove previous owner' }, { status: 500 })
    }

    // Grant ownership to the new user. Done as an explicit check + insert/update
    // instead of upsert(onConflict) — that requires a matching unique constraint
    // on (user_id, mosque_id) to exist, which mosque_roles isn't guaranteed to have.
    // This also handles the case where they were already an admin here (promotes to owner).
    const { data: existingRole } = await adminClient
      .from('mosque_roles')
      .select('id')
      .eq('mosque_id', claim.mosque_id)
      .eq('user_id', newOwner.id)
      .maybeSingle()

    const { error: roleError } = existingRole
      ? await adminClient
          .from('mosque_roles')
          .update({ role: 'owner', is_blocked: false })
          .eq('id', existingRole.id)
      : await adminClient
          .from('mosque_roles')
          .insert({ mosque_id: claim.mosque_id, user_id: newOwner.id, role: 'owner', is_blocked: false })

    if (roleError) {
      console.error('[transfer-owner] Failed to assign new owner:', roleError)
      return NextResponse.json(
        { error: `Failed to assign new owner: ${roleError.message}` },
        { status: 500 }
      )
    }

    // Keep mosques_metadata denormalized owner in sync
    const { error: mosqueError } = await adminClient
      .from('mosques_metadata')
      .update({ owner_user_id: newOwner.id, updated_at: now })
      .eq('mosque_id', claim.mosque_id)

    if (mosqueError) {
      console.error('[transfer-owner] Failed to update mosque owner record:', mosqueError)
      return NextResponse.json(
        { error: `Failed to update mosque owner record: ${mosqueError.message}` },
        { status: 500 }
      )
    }

    // Repoint the claim itself so block/unblock and claim lookups follow the new owner
    const { error: claimUpdateError } = await adminClient
      .from('mosque_claims')
      .update({ user_id: newOwner.id })
      .eq('id', id)

    if (claimUpdateError) {
      console.error('[transfer-owner] Failed to update claim record:', claimUpdateError)
      return NextResponse.json(
        { error: `Failed to update claim record: ${claimUpdateError.message}` },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      message: createdNewAccount
        ? 'Mosque ownership transferred to a newly created account. Share the temporary password with them so they can log in and change it.'
        : 'Mosque ownership transferred successfully.',
      data: {
        new_owner_user_id: newOwner.id,
        new_owner_email: newOwner.email,
        created_new_account: createdNewAccount,
        temporary_password: createdNewAccount ? tempPassword : undefined,
      },
    })
  } catch (err) {
    console.error('[transfer-owner] Unhandled error:', err)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
