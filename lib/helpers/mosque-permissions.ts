import { createAdminClient } from '@/lib/supabase/server'
import type { MosqueRoleType } from '@/lib/types/mosque-claims'

// Returns the role only if it exists and is NOT blocked by an admin.
export async function getMosqueRole(
  userId: string,
  mosqueId: string
): Promise<MosqueRoleType | null> {
  const adminClient = await createAdminClient()
  const { data } = await adminClient
    .from('mosque_roles')
    .select('role, is_blocked')
    .eq('user_id', userId)
    .eq('mosque_id', mosqueId)
    .maybeSingle()

  if (!data || data.is_blocked) return null
  return data.role as MosqueRoleType
}

export async function canManageAnnouncements(
  userId: string,
  mosqueId: string
): Promise<boolean> {
  const role = await getMosqueRole(userId, mosqueId)
  return role === 'owner' || role === 'admin'
}

export async function canManageEvents(
  userId: string,
  mosqueId: string
): Promise<boolean> {
  const role = await getMosqueRole(userId, mosqueId)
  return role === 'owner' || role === 'admin'
}

// Only owner can add/remove admins
export async function canManageAdmins(
  userId: string,
  mosqueId: string
): Promise<boolean> {
  const role = await getMosqueRole(userId, mosqueId)
  return role === 'owner'
}

// Only verified, unblocked owner can connect/manage Stripe donation account
export async function canConnectStripe(
  userId: string,
  mosqueId: string
): Promise<boolean> {
  const role = await getMosqueRole(userId, mosqueId)
  return role === 'owner'
}
