export interface MosqueAnnouncement {
  id: string
  mosque_id: string
  title: string
  content: string
  created_by: string
  created_at: string
}

export interface CreateAnnouncementBody {
  title: string
  content: string
}

export interface UpdateAnnouncementBody {
  title?: string
  content?: string
}
