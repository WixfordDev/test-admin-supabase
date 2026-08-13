'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import toast, { Toaster } from 'react-hot-toast'
import { ArrowLeft, RefreshCw, Eye, EyeOff, Copy, CheckCircle, XCircle, Megaphone, Calendar, RotateCcw, Ban, ShieldCheck, ArrowRightLeft } from 'lucide-react'
import type { MosqueClaim } from '@/lib/types/mosque-claims'
import AnnouncementsPanel from './AnnouncementsPanel'
import EventsPanel from './EventsPanel'
import ConfirmDialog from '@/app/components/ui/confirm-dialog'

const statusColors: Record<string, string> = {
  pending: 'bg-yellow-100 text-yellow-800',
  approved: 'bg-green-100 text-green-800',
  rejected: 'bg-red-100 text-red-800',
  verified: 'bg-purple-100 text-purple-800',
}

const TABS = [
  { label: 'Announcements', value: 'announcements', icon: Megaphone },
  { label: 'Events', value: 'events', icon: Calendar },
] as const

export default function MosqueViewPage() {
  const params = useParams()
  const router = useRouter()
  const claimId = params.id as string

  const [claim, setClaim] = useState<MosqueClaim | null>(null)
  const [ownerBlocked, setOwnerBlocked] = useState<boolean | null>(null)
  const [ownerEmail, setOwnerEmail] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [isActing, setIsActing] = useState(false)
  const [showCode, setShowCode] = useState(false)
  const [activeTab, setActiveTab] = useState<'announcements' | 'events'>('announcements')
  const [showBlockConfirm, setShowBlockConfirm] = useState(false)
  const [showTransferModal, setShowTransferModal] = useState(false)
  const [transferEmail, setTransferEmail] = useState('')
  const [isTransferring, setIsTransferring] = useState(false)
  const [newAccountCreds, setNewAccountCreds] = useState<{ email: string; password: string } | null>(null)

  const fetchClaim = async () => {
    try {
      setLoading(true)
      const response = await fetch(`/api/admin/mosque-claims/${claimId}`)
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)
      setClaim(data.claim)
      setOwnerBlocked(data.owner_blocked)
      setOwnerEmail(data.owner_email ?? null)
    } catch (err: any) {
      toast.error(err.message || 'Failed to load mosque claim')
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async () => {
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${claimId}/approve`, { method: 'PUT' })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)
      toast.success(`Claim approved! Verification code: ${data.verification_code}`, { duration: 8000 })
      await fetchClaim()
    } catch (err: any) {
      toast.error(err.message || 'Failed to approve claim')
    } finally {
      setIsActing(false)
    }
  }

  const handleRegenerateCode = async () => {
    if (!confirm('Generate a new verification code? The old code will stop working.')) return
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${claimId}/regenerate-code`, { method: 'PUT' })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)
      toast.success(`New verification code: ${data.verification_code}`, { duration: 8000 })
      setShowCode(true)
      await fetchClaim()
    } catch (err: any) {
      toast.error(err.message || 'Failed to regenerate code')
    } finally {
      setIsActing(false)
    }
  }

  const handleReject = async () => {
    if (!confirm('Are you sure you want to reject this claim?')) return
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${claimId}/reject`, { method: 'PUT' })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)
      toast.success('Claim rejected')
      await fetchClaim()
    } catch (err: any) {
      toast.error(err.message || 'Failed to reject claim')
    } finally {
      setIsActing(false)
    }
  }

  const handleToggleBlock = async () => {
    const action = ownerBlocked ? 'unblock-owner' : 'block-owner'
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${claimId}/${action}`, { method: 'PUT' })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)
      toast.success(ownerBlocked ? 'Owner access restored' : 'Owner access blocked')
      setShowBlockConfirm(false)
      await fetchClaim()
    } catch (err: any) {
      toast.error(err.message || 'Failed to update owner access')
    } finally {
      setIsActing(false)
    }
  }

  const handleTransfer = async () => {
    if (!transferEmail.trim()) {
      toast.error('Enter the new owner\'s email')
      return
    }
    setIsTransferring(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${claimId}/transfer-owner`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: transferEmail.trim() }),
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      if (data.data?.created_new_account && data.data?.temporary_password) {
        setNewAccountCreds({ email: data.data.new_owner_email, password: data.data.temporary_password })
      } else {
        toast.success(`Ownership transferred to ${data.data?.new_owner_email ?? transferEmail}`)
      }

      setShowTransferModal(false)
      setTransferEmail('')
      await fetchClaim()
    } catch (err: any) {
      toast.error(err.message || 'Failed to transfer ownership')
    } finally {
      setIsTransferring(false)
    }
  }

  const copyCreds = () => {
    if (!newAccountCreds) return
    navigator.clipboard.writeText(`Email: ${newAccountCreds.email}\nPassword: ${newAccountCreds.password}`)
    toast.success('Credentials copied!')
  }

  const copyCode = () => {
    if (claim?.verification_code) {
      navigator.clipboard.writeText(claim.verification_code)
      toast.success('Verification code copied!')
    }
  }

  useEffect(() => {
    if (claimId) fetchClaim()
  }, [claimId])

  const row = (label: string, value: string | null | undefined) => (
    <div className="flex flex-col gap-1">
      <span className="text-xs font-medium text-gray-500 uppercase tracking-wide">{label}</span>
      <span className="text-sm text-gray-900">{value || '—'}</span>
    </div>
  )

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <RefreshCw className="h-7 w-7 animate-spin text-gray-400" />
      </div>
    )
  }

  if (!claim) {
    return (
      <Card className="p-12 text-center">
        <p className="text-gray-500">Claim not found.</p>
      </Card>
    )
  }

  return (
    <div className="space-y-6">
      <Toaster />

      <button
        onClick={() => router.push('/dashboard/mosque-claims')}
        className="flex items-center gap-1.5 text-sm text-gray-600 hover:text-gray-900"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to Mosque Claims
      </button>

      <div>
        <h1 className="text-3xl font-bold text-gray-900">{claim.mosque?.name ?? 'Mosque'}</h1>
        <p className="text-gray-600 mt-1">{claim.mosque?.address ?? claim.mosque_id}</p>
      </div>

      {/* Claim info card */}
      <Card className="p-6 space-y-5">
        <div className="flex items-center gap-3">
          <span className="text-sm font-medium text-gray-600">Claim Status:</span>
          <span
            className={`px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${
              statusColors[claim.status] ?? 'bg-gray-100 text-gray-800'
            }`}
          >
            {claim.status}
          </span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
          {row('Position', claim.position)}
          {row('Email', claim.mosque_email)}
          {row('Phone', claim.mosque_phone)}
          {row('Submitted', new Date(claim.created_at).toLocaleString())}
        </div>

        {row('Notes', claim.notes)}

        {(claim.status === 'approved' || claim.status === 'verified') && claim.verification_code && (
          <div className="p-4 bg-green-50 border border-green-200 rounded-lg space-y-2">
            <p className="text-xs font-semibold text-green-700 uppercase tracking-wide">
              Verification Code (send by postal mail)
            </p>
            <div className="flex items-center gap-3">
              <span className="text-lg font-mono font-bold text-green-800 tracking-widest">
                {showCode ? claim.verification_code : '••••••••••'}
              </span>
              <button onClick={() => setShowCode((v) => !v)} className="text-green-600 hover:text-green-800">
                {showCode ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </button>
              {showCode && (
                <button onClick={copyCode} className="text-green-600 hover:text-green-800">
                  <Copy className="h-4 w-4" />
                </button>
              )}
            </div>
          </div>
        )}

        {claim.status === 'approved' && (
          <div className="flex items-center justify-end pt-2 border-t">
            <Button
              variant="outline"
              className="text-black"
              onClick={handleRegenerateCode}
              disabled={isActing}
            >
              <RotateCcw className="h-4 w-4 mr-1.5" />
              Regenerate Code
            </Button>
          </div>
        )}

        {claim.status === 'pending' && (
          <div className="flex items-center justify-end gap-3 pt-2 border-t">
            <Button
              variant="outline"
              className="text-red-600 border-red-300 hover:bg-red-50"
              onClick={handleReject}
              disabled={isActing}
            >
              <XCircle className="h-4 w-4 mr-1.5" />
              Reject
            </Button>
            <Button
              className="bg-green-600 hover:bg-green-700 text-white"
              onClick={handleApprove}
              disabled={isActing}
            >
              <CheckCircle className="h-4 w-4 mr-1.5" />
              Approve & Generate Code
            </Button>
          </div>
        )}

        {claim.status === 'verified' && (
          <div className="flex flex-col gap-3 pt-2 border-t">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span
                  className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                    ownerBlocked ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'
                  }`}
                >
                  {ownerBlocked ? 'Owner Access Blocked' : 'Owner Access Active'}
                </span>
                {ownerEmail && <span className="text-sm text-gray-500">Owner: {ownerEmail}</span>}
              </div>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  className="text-black"
                  onClick={() => setShowTransferModal(true)}
                  disabled={isActing}
                >
                  <ArrowRightLeft className="h-4 w-4 mr-1.5" />
                  Transfer Owner
                </Button>
                <Button
                  variant="outline"
                  className={ownerBlocked ? 'text-green-700 border-green-300 hover:bg-green-50' : 'text-red-600 border-red-300 hover:bg-red-50'}
                  onClick={() => setShowBlockConfirm(true)}
                  disabled={isActing}
                >
                  {ownerBlocked ? (
                    <>
                      <ShieldCheck className="h-4 w-4 mr-1.5" />
                      Unblock Owner
                    </>
                  ) : (
                    <>
                      <Ban className="h-4 w-4 mr-1.5" />
                      Block Owner
                    </>
                  )}
                </Button>
              </div>
            </div>
          </div>
        )}
      </Card>

      {/* Announcements / Events tabs */}
      <div className="flex gap-2 flex-wrap">
        {TABS.map((tab) => (
          <button
            key={tab.value}
            onClick={() => setActiveTab(tab.value)}
            className={`flex items-center gap-2 px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
              activeTab === tab.value
                ? 'bg-gray-900 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            <tab.icon className="h-4 w-4" />
            {tab.label}
          </button>
        ))}
      </div>

      {activeTab === 'announcements' ? (
        <AnnouncementsPanel mosqueId={claim.mosque_id} />
      ) : (
        <EventsPanel mosqueId={claim.mosque_id} />
      )}

      <ConfirmDialog
        open={showBlockConfirm}
        title={ownerBlocked ? 'Unblock Owner' : 'Block Owner'}
        description={
          ownerBlocked
            ? "Restore this owner's access to manage announcements and events?"
            : 'Block this owner? They will no longer be able to create, edit, or delete announcements/events for this mosque.'
        }
        confirmText={ownerBlocked ? 'Unblock' : 'Block'}
        variant={ownerBlocked ? 'default' : 'danger'}
        isLoading={isActing}
        onConfirm={handleToggleBlock}
        onCancel={() => setShowBlockConfirm(false)}
      />

      {showTransferModal && (
        <div className="fixed inset-0 z-[50] flex items-center justify-center bg-black/50 p-4">
          <Card className="w-full max-w-sm p-6 bg-white">
            <div className="flex items-start gap-3 mb-4">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-100">
                <ArrowRightLeft className="h-5 w-5 text-blue-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Transfer Ownership</h3>
                <p className="text-sm text-gray-600 mt-1">
                  Enter the email of the account that should become the new owner of this mosque.
                  {ownerEmail && <> Current owner: <span className="font-medium">{ownerEmail}</span>.</>}
                  {' '}The current owner will lose access entirely. If no account exists for this email yet, one will be created automatically with a temporary password (shown to you after transfer, to share with them).
                </p>
              </div>
            </div>

            <input
              type="email"
              placeholder="new-owner@example.com"
              value={transferEmail}
              onChange={(e) => setTransferEmail(e.target.value)}
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-blue-500"
              disabled={isTransferring}
              autoFocus
            />

            <div className="flex justify-end gap-2 mt-4">
              <Button
                variant="outline"
                className="text-black"
                onClick={() => { setShowTransferModal(false); setTransferEmail('') }}
                disabled={isTransferring}
              >
                Cancel
              </Button>
              <Button onClick={handleTransfer} disabled={isTransferring}>
                {isTransferring ? 'Transferring...' : 'Transfer'}
              </Button>
            </div>
          </Card>
        </div>
      )}

      {newAccountCreds && (
        <div className="fixed inset-0 z-[50] flex items-center justify-center bg-black/50 p-4">
          <Card className="w-full max-w-sm p-6 bg-white">
            <div className="flex items-start gap-3 mb-4">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-green-100">
                <CheckCircle className="h-5 w-5 text-green-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">New Owner Account Created</h3>
                <p className="text-sm text-gray-600 mt-1">
                  Share these credentials with the new owner. They should log in and change the password immediately — this is shown only once.
                </p>
              </div>
            </div>

            <div className="space-y-2 bg-gray-50 border border-gray-200 rounded-lg p-3 font-mono text-sm">
              <div className="flex justify-between gap-3">
                <span className="text-gray-500 shrink-0">Email</span>
                <span className="text-gray-900 break-all text-right">{newAccountCreds.email}</span>
              </div>
              <div className="flex justify-between gap-3">
                <span className="text-gray-500 shrink-0">Password</span>
                <span className="text-gray-900 break-all text-right">{newAccountCreds.password}</span>
              </div>
            </div>

            <div className="flex justify-end gap-2 mt-4">
              <Button variant="outline" className="text-black flex items-center gap-1.5" onClick={copyCreds}>
                <Copy className="h-4 w-4" />
                Copy
              </Button>
              <Button onClick={() => setNewAccountCreds(null)}>
                Done
              </Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  )
}
