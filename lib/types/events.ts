export type AttendanceStatus = 'going' | 'maybe'

export interface MosqueEvent {
  id: string
  mosque_id: string
  title: string
  description: string | null
  event_date: string
  end_date: string | null
  location: string | null
  image_url: string | null
  max_attendees: number | null
  is_active: boolean
  created_by: string
  created_at: string
  updated_at: string
}

export interface CreateEventBody {
  title: string
  description?: string
  event_date: string
  end_date?: string
  location?: string
  image_url?: string
  max_attendees?: number
}

export interface UpdateEventBody {
  title?: string
  description?: string
  event_date?: string
  end_date?: string
  location?: string
  image_url?: string
  max_attendees?: number
  is_active?: boolean
}

export interface EventAttendee {
  id: string
  event_id: string
  user_id: string
  attendance_status: AttendanceStatus
  reminder_enabled: boolean
  created_at: string
  updated_at: string
}

export interface AttendEventBody {
  attendance_status: AttendanceStatus
  reminder_enabled?: boolean
}
