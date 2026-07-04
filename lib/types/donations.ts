export type DonationAccountStatus = 'pending' | 'active' | 'restricted' | 'disabled'
export type DonationTransactionStatus = 'pending' | 'completed' | 'failed' | 'refunded'
export type StripeConnectStatusLabel = 'connected' | 'pending' | 'not_connected'

export interface MosqueDonationAccount {
  id: string
  mosque_id: string
  provider: string
  stripe_account_id: string | null
  account_status: DonationAccountStatus
  charges_enabled: boolean
  payouts_enabled: boolean
  details_submitted: boolean
  country: string | null
  currency: string
  created_at: string
  updated_at: string
}

export interface DonationTransaction {
  id: string
  mosque_id: string
  donor_user_id: string | null
  stripe_checkout_session: string | null
  stripe_payment_intent: string | null
  amount: number
  currency: string
  platform_fee: number
  mosque_amount: number
  payment_method: string | null
  receipt_url: string | null
  status: DonationTransactionStatus
  created_at: string
}

export interface CreateDonationCheckoutBody {
  amount: number
  currency?: string
}

export interface StripeConnectStatusResponse {
  status: StripeConnectStatusLabel
  charges_enabled: boolean
  payouts_enabled: boolean
  details_submitted: boolean
  stripe_account_id: string | null
  onboarding_url?: string
}
