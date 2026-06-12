export type ClaimStatus = 'pending' | 'approved' | 'rejected' | 'verified'
export type VerificationStatus = 'pending' | 'verified'
export type MosqueRoleType = 'owner' | 'admin'

export interface MosqueClaim {
  id: string
  mosque_id: string
  user_id: string
  mosque_email: string | null
  mosque_phone: string | null
  position: string | null
  notes: string | null
  status: ClaimStatus
  verification_code: string | null
  verification_status: VerificationStatus
  verified_at: string | null
  created_at: string
  mosque?: {
    mosque_id: string
    name: string
    address: string | null
  }
}

export interface SubmitClaimBody {
  mosque_id: string
  mosque_email?: string
  mosque_phone?: string
  position?: string
  notes?: string
}

export interface VerifyClaimBody {
  mosque_id: string
  verification_code: string
}

export interface MosqueClaimStats {
  total: number
  pending: number
  approved: number
  rejected: number
  verified: number
}

export interface MosqueRole {
  id: string
  mosque_id: string
  user_id: string
  role: MosqueRoleType
}
