'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { X, CheckCircle, XCircle, Clock, Building2, Unplug, Plug } from 'lucide-react'
import toast from 'react-hot-toast'
import ConfirmDialog from '@/app/components/ui/confirm-dialog'

interface Account {
  id: string
  mosque_id: string
  mosque_name: string
  account_status: string
  charges_enabled: boolean
  payouts_enabled: boolean
  details_submitted: boolean
  stripe_account_id: string | null
  country?: string | null
  currency?: string | null
  created_at: string
}

interface Props {
  account: Account
  onClose: () => void
  onStatusChanged?: () => void
}

function BoolIcon({ value }: { value: boolean }) {
  return value
    ? <CheckCircle className="h-4 w-4 text-green-500" />
    : <XCircle className="h-4 w-4 text-gray-300" />
}

export default function MosqueAccountDetailModal({ account: a, onClose, onStatusChanged }: Props) {
  const [showDisconnectConfirm, setShowDisconnectConfirm] = useState(false)
  const [disconnecting, setDisconnecting] = useState(false)
  const [enabling, setEnabling] = useState(false)
  const [currentStatus, setCurrentStatus] = useState(a.account_status)

  const statusConfig = {
    active: { label: 'Connected', cls: 'bg-green-100 text-green-800', icon: <CheckCircle className="h-4 w-4" /> },
    pending: { label: 'Pending Setup', cls: 'bg-yellow-100 text-yellow-800', icon: <Clock className="h-4 w-4" /> },
    disabled: { label: 'Disconnected', cls: 'bg-red-100 text-red-700', icon: <XCircle className="h-4 w-4" /> },
  }[currentStatus] ?? { label: 'Unknown', cls: 'bg-gray-100 text-gray-600', icon: <XCircle className="h-4 w-4" /> }

  const handleDisconnect = async () => {
    setDisconnecting(true)
    try {
      const res = await fetch(`/api/admin/donations/accounts/${a.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'disable' }),
      })
      const json = await res.json()
      if (!res.ok) throw new Error(json.message ?? 'Failed')
      toast.success('Mosque account disconnected.')
      setCurrentStatus('disabled')
      onStatusChanged?.()
      setShowDisconnectConfirm(false)
    } catch (err: any) {
      toast.error(err.message ?? 'Failed to disconnect')
    } finally {
      setDisconnecting(false)
    }
  }

  const handleEnable = async () => {
    setEnabling(true)
    try {
      const res = await fetch(`/api/admin/donations/accounts/${a.id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'enable' }),
      })
      const json = await res.json()
      if (!res.ok) throw new Error(json.message ?? 'Failed')
      toast.success(json.message ?? 'Account re-enabled.')
      setCurrentStatus(json.data?.account_status ?? 'pending')
      onStatusChanged?.()
    } catch (err: any) {
      toast.error(err.message ?? 'Failed to re-enable')
    } finally {
      setEnabling(false)
    }
  }

  const rows: { label: string; value: React.ReactNode }[] = [
    { label: 'Mosque Name', value: <span className="font-semibold">{a.mosque_name}</span> },
    { label: 'Mosque ID', value: <span className="font-mono text-xs break-all">{a.mosque_id}</span> },
    {
      label: 'Account Status', value: (
        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold ${statusConfig.cls}`}>
          {statusConfig.icon}
          {statusConfig.label}
        </span>
      )
    },
    { label: 'Stripe Account ID', value: a.stripe_account_id ? <span className="font-mono text-xs">{a.stripe_account_id}</span> : '—' },
    {
      label: 'Charges Enabled', value: (
        <span className="flex items-center gap-1">
          <BoolIcon value={currentStatus === 'active' && a.charges_enabled} />
          <span className="text-sm">{currentStatus === 'active' && a.charges_enabled ? 'Yes' : 'No'}</span>
        </span>
      )
    },
    {
      label: 'Payouts Enabled', value: (
        <span className="flex items-center gap-1">
          <BoolIcon value={currentStatus === 'active' && a.payouts_enabled} />
          <span className="text-sm">{currentStatus === 'active' && a.payouts_enabled ? 'Yes' : 'No'}</span>
        </span>
      )
    },
    {
      label: 'Details Submitted', value: (
        <span className="flex items-center gap-1">
          <BoolIcon value={a.details_submitted} />
          <span className="text-sm">{a.details_submitted ? 'Yes' : 'No'}</span>
        </span>
      )
    },
    { label: 'Country', value: a.country ? a.country.toUpperCase() : '—' },
    { label: 'Currency', value: a.currency ? a.currency.toUpperCase() : '—' },
    { label: 'Connected On', value: new Date(a.created_at).toLocaleDateString() },
  ]

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white w-full max-w-lg rounded-2xl shadow-xl flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-gray-100 rounded-full">
              <Building2 className="h-5 w-5 text-gray-600" />
            </div>
            <h2 className="text-xl font-bold text-gray-900">Stripe Account Details</h2>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Body */}
        <div className="overflow-y-auto flex-1 p-6 space-y-4">
          <Card className="divide-y divide-gray-100">
            {rows.map((r) => (
              <div key={r.label} className="flex justify-between items-center gap-4 px-4 py-3">
                <span className="text-sm text-gray-500 shrink-0 w-36">{r.label}</span>
                <span className="text-sm text-gray-900 text-right">{r.value}</span>
              </div>
            ))}
          </Card>

          {/* Status-based info banners */}
          {currentStatus === 'pending' && (
            <div className="p-3 rounded-lg bg-yellow-50 border border-yellow-200 text-sm text-yellow-800">
              ⚠️ Mosque owner has not completed Stripe onboarding. Donations are disabled until setup is complete.
            </div>
          )}
          {currentStatus === 'disabled' && (
            <div className="p-3 rounded-lg bg-red-50 border border-red-200 text-sm text-red-700">
              🔴 This account has been disconnected by admin. Mosque cannot receive donations, and the owner cannot reconnect Stripe on their own — re-enable it below once you've verified with them.
            </div>
          )}
          {currentStatus === 'active' && (
            <div className="p-3 rounded-lg bg-green-50 border border-green-200 text-sm text-green-700">
              ✅ Active — Mosque can accept donations. Money goes directly to their connected bank account.
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex justify-between items-center p-6 border-t gap-3">
          {currentStatus !== 'disabled' ? (
            <Button
              variant="outline"
              className="flex items-center gap-2 text-red-600 border-red-300 hover:bg-red-50"
              onClick={() => setShowDisconnectConfirm(true)}
              disabled={disconnecting}
            >
              <Unplug className="h-4 w-4" />
              Disconnect
            </Button>
          ) : (
            <Button
              variant="outline"
              className="flex items-center gap-2 text-green-700 border-green-300 hover:bg-green-50"
              onClick={handleEnable}
              disabled={enabling}
            >
              <Plug className="h-4 w-4" />
              Re-enable
            </Button>
          )}
          <Button variant="outline" className="text-black" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>

      <ConfirmDialog
        open={showDisconnectConfirm}
        title="Disconnect Stripe Account"
        description={`Are you sure you want to disconnect "${a.mosque_name}" from Stripe? They will no longer be able to receive donations until they reconnect.`}
        confirmText="Disconnect"
        variant="danger"
        isLoading={disconnecting}
        onConfirm={handleDisconnect}
        onCancel={() => setShowDisconnectConfirm(false)}
      />
    </div>
  )
}
