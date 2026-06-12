'use client'

import { useState } from 'react'
import { Button } from '@/app/components/ui/button'
import { Badge } from '@/app/components/ui/badge'
import type { MosqueClaim } from '@/lib/types/mosque-claims'
import { Eye, EyeOff, Copy, CheckCircle } from 'lucide-react'
import toast from 'react-hot-toast'

interface Props {
  claim: MosqueClaim
  onClose: () => void
  onApprove: (id: string) => void
  onReject: (id: string) => void
  isActing: boolean
}

const statusColors: Record<string, string> = {
  pending: 'bg-yellow-100 text-yellow-800',
  approved: 'bg-green-100 text-green-800',
  rejected: 'bg-red-100 text-red-800',
  verified: 'bg-purple-100 text-purple-800',
}

export default function ClaimDetailDialog({ claim, onClose, onApprove, onReject, isActing }: Props) {
  const [showCode, setShowCode] = useState(false)

  const copyCode = () => {
    if (claim.verification_code) {
      navigator.clipboard.writeText(claim.verification_code)
      toast.success('Verification code copied!')
    }
  }

  const row = (label: string, value: string | null | undefined) => (
    <div className="flex flex-col gap-1">
      <span className="text-xs font-medium text-gray-500 uppercase tracking-wide">{label}</span>
      <span className="text-sm text-gray-900">{value || '—'}</span>
    </div>
  )

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="bg-white rounded-xl shadow-xl w-full max-w-lg mx-4 overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b">
          <h2 className="text-lg font-semibold text-gray-900">Claim Details</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 text-xl font-bold leading-none"
          >
            ×
          </button>
        </div>

        {/* Body */}
        <div className="px-6 py-5 space-y-5">
          {/* Status */}
          <div className="flex items-center gap-3">
            <span className="text-sm font-medium text-gray-600">Status:</span>
            <span
              className={`px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${
                statusColors[claim.status] ?? 'bg-gray-100 text-gray-800'
              }`}
            >
              {claim.status}
            </span>
          </div>

          {/* Mosque info */}
          <div className="grid grid-cols-1 gap-3 p-4 bg-gray-50 rounded-lg">
            <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Mosque</p>
            {row('Name', claim.mosque?.name)}
            {row('Address', claim.mosque?.address)}
            {row('Mosque ID', claim.mosque_id)}
          </div>

          {/* Claimant info */}
          <div className="grid grid-cols-2 gap-3">
            {row('User ID', claim.user_id)}
            {row('Position', claim.position)}
            {row('Email', claim.mosque_email)}
            {row('Phone', claim.mosque_phone)}
          </div>

          {row('Notes', claim.notes)}
          {row('Submitted', new Date(claim.created_at).toLocaleString())}
          {claim.verified_at && row('Verified At', new Date(claim.verified_at).toLocaleString())}

          {/* Verification code — only show for approved/verified */}
          {(claim.status === 'approved' || claim.status === 'verified') &&
            claim.verification_code && (
              <div className="p-4 bg-green-50 border border-green-200 rounded-lg space-y-2">
                <p className="text-xs font-semibold text-green-700 uppercase tracking-wide">
                  Verification Code (send by postal mail)
                </p>
                <div className="flex items-center gap-3">
                  <span className="text-lg font-mono font-bold text-green-800 tracking-widest">
                    {showCode ? claim.verification_code : '••••••••••'}
                  </span>
                  <button
                    onClick={() => setShowCode((v) => !v)}
                    className="text-green-600 hover:text-green-800"
                    title={showCode ? 'Hide code' : 'Show code'}
                  >
                    {showCode ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                  {showCode && (
                    <button
                      onClick={copyCode}
                      className="text-green-600 hover:text-green-800"
                      title="Copy code"
                    >
                      <Copy className="h-4 w-4" />
                    </button>
                  )}
                </div>
              </div>
            )}
        </div>

        {/* Footer actions */}
        {claim.status === 'pending' && (
          <div className="flex items-center justify-end gap-3 px-6 py-4 border-t bg-gray-50">
            <Button
              variant="outline"
              className="text-red-600 border-red-300 hover:bg-red-50"
              onClick={() => onReject(claim.id)}
              disabled={isActing}
            >
              Reject
            </Button>
            <Button
              className="bg-green-600 hover:bg-green-700 text-white"
              onClick={() => onApprove(claim.id)}
              disabled={isActing}
            >
              <CheckCircle className="h-4 w-4 mr-1.5" />
              Approve & Generate Code
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}
