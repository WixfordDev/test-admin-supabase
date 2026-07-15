export type CampaignCategory =
  | 'renovation'
  | 'ramadan'
  | 'zakat'
  | 'sadaqah'
  | 'emergency'
  | 'education'
  | 'general'
  | 'other'

export const CAMPAIGN_CATEGORIES: { value: CampaignCategory; label: string }[] = [
  { value: 'renovation', label: 'Mosque Renovation' },
  { value: 'ramadan', label: 'Ramadan Appeal' },
  { value: 'zakat', label: 'Zakat Collection' },
  { value: 'sadaqah', label: 'Sadaqah Jariyah' },
  { value: 'emergency', label: 'Emergency Appeal' },
  { value: 'education', label: 'Islamic Education' },
  { value: 'general', label: 'General Donation' },
  { value: 'other', label: 'Other' },
]

export interface MosqueCampaign {
  id: string
  mosque_id: string
  title: string
  description: string
  category: CampaignCategory
  cover_image_url: string | null
  goal_amount: number
  raised_amount: number
  currency: string
  start_date: string | null
  end_date: string | null
  no_end_date: boolean
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface CreateCampaignBody {
  title: string
  description: string
  category: CampaignCategory
  goal_amount: number
  currency?: string
  cover_image_url?: string
  start_date?: string
  end_date?: string
  no_end_date?: boolean
  is_active?: boolean
}

export interface UpdateCampaignBody extends Partial<CreateCampaignBody> {}
