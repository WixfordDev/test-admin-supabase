export interface Mosque {
  mosque_id: string
  name: string
  latitude?: number
  longitude?: number
  timezone: string
  address?: string
  phone?: string
  website?: string
  additional_info?: string
  is_approved?: boolean
  created_at: string
  updated_at: string
  // Computed fields that might be added by API
  facilities?: MosqueFacilityRecord[]
}

export interface MosqueFacilityRecord {
  mosque_id: string
  facility_type: string
  availability: string
  description?: string
  additional_info?: string
  last_updated: string
  created_at: string
  updated_by?: string
}

// Dashboard-level stats used across the admin UI
export interface MosqueStats {
  total: number
  thisWeek: number
  thisMonth: number
  byTimezone: Record<string, number>
  byFacility: Record<string, number>
}

export interface MosqueFilters {
  search: string
  timezone: string
  hasFacilities: string[]
  dateRange: {
    from: Date | null
    to: Date | null
  }
}

export interface CreateMosqueData {
  mosque_id: string
  name: string
  address?: string
  latitude?: number
  longitude?: number
  timezone?: string
  phone?: string
  website?: string
  additional_info?: string
  facilities?: CreateMosqueFacilityData[]
}

export interface CreateMosqueFacilityData {
  facility_type: string
  availability: string
  description?: string
  additional_info?: string
}

export const MOSQUE_FACILITIES = [
  'parking',
  'wudu',
  'toilets',
  'shower',
  'wifi',
  'library',
  'kitchen',
  'accessibility',
  'womenSection',
  'childcare',
  'bookstore',
  'conferenceRoom'
] as const

export const FACILITY_AVAILABILITY = [
  'available',
  'notAvailable',
  'limitedAvailability',
  'easilyAvailable',
  'unknown'
] as const

export type MosqueFacility = typeof MOSQUE_FACILITIES[number]
export type FacilityAvailability = typeof FACILITY_AVAILABILITY[number] 