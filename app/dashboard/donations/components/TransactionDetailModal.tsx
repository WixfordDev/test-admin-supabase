'use client'

import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { X, ExternalLink, CheckCircle, Clock, XCircle, RefreshCw } from 'lucide-react'

interface Transaction {
  id: string
  mosque_name: string
  campaign_id?: string | null
  donor_user_id: string | null
  amount: number
  currency: string
  platform_fee: number
  mosque_amount: number
  payment_method: string | null
  receipt_url: string | null
  stripe_checkout_session?: string | null
  status: string
  created_at: string
}

function fmt(cents: number, currency = 'usd') {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency.toUpperCase() }).format(cents / 100)
}

const StatusIcon = ({ status }: { status: string }) => {
  if (status === 'completed') return <CheckCircle className="h-5 w-5 text-green-500" />
  if (status === 'pending') return <Clock className="h-5 w-5 text-yellow-500" />
  return <XCircle className="h-5 w-5 text-red-500" />
}

interface Props {
  transaction: Transaction
  onClose: () => void
}

export default function TransactionDetailModal({ transaction: t, onClose }: Props) {
  const rows: { label: string; value: React.ReactNode }[] = [
    { label: 'Transaction ID', value: <span className="font-mono text-xs break-all">{t.id}</span> },
    { label: 'Mosque', value: t.mosque_name },
    {
      label: 'Status', value: (
        <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${
          t.status === 'completed' ? 'bg-green-100 text-green-800' :
          t.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
          'bg-red-100 text-red-700'
        }`}>
          <StatusIcon status={t.status} />
          {t.status}
        </span>
      )
    },
    { label: 'Total Amount', value: <span className="font-bold text-gray-900">{fmt(t.amount, t.currency)}</span> },
    { label: 'Mosque Receives', value: <span className="text-green-700 font-semibold">{fmt(t.mosque_amount, t.currency)}</span> },
    { label: 'Platform Fee (2%)', value: <span className="text-purple-700">{fmt(t.platform_fee, t.currency)}</span> },
    { label: 'Currency', value: t.currency.toUpperCase() },
    { label: 'Payment Method', value: t.payment_method ? <span className="capitalize">{t.payment_method}</span> : '—' },
    {
      label: 'Campaign', value: t.campaign_id
        ? <span className="font-mono text-xs text-blue-700">{t.campaign_id}</span>
        : <span className="text-gray-400">General donation</span>
    },
    {
      label: 'Stripe Session', value: t.stripe_checkout_session
        ? <span className="font-mono text-xs break-all">{t.stripe_checkout_session}</span>
        : '—'
    },
    { label: 'Donor User ID', value: t.donor_user_id ? <span className="font-mono text-xs">{t.donor_user_id}</span> : '—' },
    { label: 'Date', value: new Date(t.created_at).toLocaleString() },
  ]

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white w-full max-w-lg rounded-2xl shadow-xl flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-bold text-gray-900">Transaction Details</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Body */}
        <div className="overflow-y-auto flex-1 p-6">
          <Card className="divide-y divide-gray-100">
            {rows.map((r) => (
              <div key={r.label} className="flex justify-between items-start gap-4 px-4 py-3">
                <span className="text-sm text-gray-500 shrink-0 w-36">{r.label}</span>
                <span className="text-sm text-gray-900 text-right">{r.value}</span>
              </div>
            ))}
          </Card>

          {t.receipt_url && (
            <a
              href={t.receipt_url}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-4 flex items-center justify-center gap-2 w-full py-2.5 rounded-lg border border-blue-200 text-blue-700 hover:bg-blue-50 text-sm font-medium transition-colors"
            >
              <ExternalLink className="h-4 w-4" />
              View Stripe Receipt
            </a>
          )}
        </div>

        {/* Footer */}
        <div className="p-6 border-t">
          <Button variant="outline" className="w-full text-black" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>
    </div>
  )
}
