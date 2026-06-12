// Placeholder notification service for mosque announcements and events.
// Fetches followers from favorite_mosques and returns the payload.
// Replace the TODO blocks with your FCM provider when ready.

export interface NotificationPayload {
  title: string
  body: string
  type: 'announcement' | 'event'
  data: Record<string, string>
}

export interface NotificationResult {
  queued: true
  recipientCount: number
  payload: NotificationPayload
}

async function getFollowerIds(mosqueId: string): Promise<string[]> {
  const { createAdminClient } = await import('@/lib/supabase/server')
  const adminClient = await createAdminClient()
  const { data } = await adminClient
    .from('favorite_mosques')
    .select('user_id')
    .eq('mosque_id', mosqueId)
  return (data ?? []).map((row) => row.user_id as string)
}

export async function notifyAnnouncementCreated(
  mosqueId: string,
  mosqueName: string,
  announcementTitle: string
): Promise<NotificationResult> {
  const followerIds = await getFollowerIds(mosqueId)

  const payload: NotificationPayload = {
    title: `New Announcement from ${mosqueName}`,
    body: announcementTitle,
    type: 'announcement',
    data: { mosque_id: mosqueId },
  }

  // TODO: send push notifications to followerIds via FCM
  // Example: await sendPushToMany(followerIds, payload)

  return { queued: true, recipientCount: followerIds.length, payload }
}

export async function notifyEventCreated(
  mosqueId: string,
  mosqueName: string,
  eventTitle: string
): Promise<NotificationResult> {
  const followerIds = await getFollowerIds(mosqueId)

  const payload: NotificationPayload = {
    title: `New Event at ${mosqueName}`,
    body: eventTitle,
    type: 'event',
    data: { mosque_id: mosqueId },
  }

  // TODO: send push notifications to followerIds via FCM

  return { queued: true, recipientCount: followerIds.length, payload }
}
