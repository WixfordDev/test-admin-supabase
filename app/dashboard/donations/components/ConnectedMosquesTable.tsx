'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Building2, CheckCircle, Clock, XCircle, Eye } from 'lucide-react'
import MosqueAccountDetailModal from './MosqueAccountDetailModal'

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

const statusBadge = (status: string) => {
  switch (status) {
    case 'active':
      return (
        <span className="flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-800">
          <CheckCircle className="h-3 w-3" /> Connected
        </span>
      )
    case 'pending':
      return (
        <span className="flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-800">
          <Clock className="h-3 w-3" /> Pending
        </span>
      )
    default:
      return (
        <span className="flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-600">
          <XCircle className="h-3 w-3" /> Disabled
        </span>
      )
  }
}

interface Props {
  accounts: Account[]
  onRefresh?: () => void
}

export default function ConnectedMosquesTable({ accounts, onRefresh }: Props) {
  const [selected, setSelected] = useState<Account | null>(null)

  if (accounts.length === 0) {
    return (
      <Card className="p-12 text-center">
        <Building2 className="h-10 w-10 text-gray-300 mx-auto mb-3" />
        <p className="text-gray-500">No mosques have connected Stripe yet.</p>
      </Card>
    )
  }

  return (
    <>
      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="bg-gray-50 border-b text-left">
                <th className="px-4 py-3 font-medium text-gray-600">Mosque</th>
                <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                <th className="px-4 py-3 font-medium text-gray-600">Charges</th>
                <th className="px-4 py-3 font-medium text-gray-600">Payouts</th>
                <th className="px-4 py-3 font-medium text-gray-600">Stripe Account</th>
                <th className="px-4 py-3 font-medium text-gray-600">Connected</th>
                <th className="px-4 py-3 font-medium text-gray-600">Details</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {accounts.map((a) => (
                <tr key={a.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-4 py-3 font-medium text-gray-900">{a.mosque_name}</td>
                  <td className="px-4 py-3">{statusBadge(a.account_status)}</td>
                  <td className="px-4 py-3">
                    {a.charges_enabled ? (
                      <CheckCircle className="h-4 w-4 text-green-500" />
                    ) : (
                      <XCircle className="h-4 w-4 text-gray-300" />
                    )}
                  </td>
                  <td className="px-4 py-3">
                    {a.payouts_enabled ? (
                      <CheckCircle className="h-4 w-4 text-green-500" />
                    ) : (
                      <XCircle className="h-4 w-4 text-gray-300" />
                    )}
                  </td>
                  <td className="px-4 py-3 text-gray-500 font-mono text-xs">
                    {a.stripe_account_id ?? '—'}
                  </td>
                  <td className="px-4 py-3 text-gray-500">
                    {new Date(a.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-4 py-3">
                    <button
                      onClick={() => setSelected(a)}
                      className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-800 font-medium"
                    >
                      <Eye className="h-3.5 w-3.5" />
                      View
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

      {selected && (
        <MosqueAccountDetailModal
          account={selected}
          onClose={() => setSelected(null)}
          onStatusChanged={() => {
            setSelected(null)
            onRefresh?.()
          }}
        />
      )}
    </>
  )
}
