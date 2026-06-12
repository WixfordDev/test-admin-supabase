import { createAdminClient } from '@/lib/supabase/server'
import type { MosqueRoleType } from '@/lib/types/mosque-claims'

export async function getMosqueRole(
  userId: string,
  mosqueId: string
): Promise<MosqueRoleType | null> {
  const adminClient = await createAdminClient()
  const { data } = await adminClient
    .from('mosque_roles')
    .select('role')
    .eq('user_id', userId)
    .eq('mosque_id', mosqueId)
    .maybeSingle()
  return (data?.role as MosqueRoleType) ?? null
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
