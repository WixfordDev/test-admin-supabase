'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Receipt, Eye } from 'lucide-react'
import TransactionDetailModal from './TransactionDetailModal'

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

interface Pagination {
  page: number
  limit: number
  total: number
  totalPages: number
}

const statusBadge = (status: string) => {
  const map: Record<string, string> = {
    completed: 'bg-green-100 text-green-800',
    pending: 'bg-yellow-100 text-yellow-800',
    failed: 'bg-red-100 text-red-800',
    refunded: 'bg-gray-100 text-gray-600',
  }
  return (
    <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold capitalize ${map[status] ?? 'bg-gray-100 text-gray-600'}`}>
      {status}
    </span>
  )
}

function formatAmount(cents: number, currency: string) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency.toUpperCase(),
  }).format(cents / 100)
}

interface Props {
  transactions: Transaction[]
  pagination: Pagination
  onPageChange: (page: number) => void
}

export default function DonationTransactionsTable({ transactions, pagination, onPageChange }: Props) {
  const [selected, setSelected] = useState<Transaction | null>(null)

  if (transactions.length === 0) {
    return (
      <Card className="p-12 text-center">
        <Receipt className="h-10 w-10 text-gray-300 mx-auto mb-3" />
        <p className="text-gray-500">No donation transactions yet.</p>
      </Card>
    )
  }

  return (
    <>
      <div className="space-y-4">
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-gray-50 border-b text-left">
                  <th className="px-4 py-3 font-medium text-gray-600">Mosque</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Amount</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Mosque Gets</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Platform Fee</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Method</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Date</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Details</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {transactions.map((t) => (
                  <tr key={t.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-3 font-medium text-gray-900 max-w-40 truncate">
                      {t.mosque_name}
                    </td>
                    <td className="px-4 py-3 text-gray-900 font-semibold">
                      {formatAmount(t.amount, t.currency)}
                    </td>
                    <td className="px-4 py-3 text-green-700">
                      {formatAmount(t.mosque_amount, t.currency)}
                    </td>
                    <td className="px-4 py-3 text-purple-700">
                      {formatAmount(t.platform_fee, t.currency)}
                    </td>
                    <td className="px-4 py-3 text-gray-500 capitalize">
                      {t.payment_method ?? '—'}
                    </td>
                    <td className="px-4 py-3">{statusBadge(t.status)}</td>
                    <td className="px-4 py-3 text-gray-500">
                      {new Date(t.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => setSelected(t)}
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

        {pagination.totalPages > 1 && (
          <Card className="p-4">
            <div className="flex items-center justify-between">
              <p className="text-sm text-gray-600">
                Showing {(pagination.page - 1) * pagination.limit + 1}–
                {Math.min(pagination.page * pagination.limit, pagination.total)} of {pagination.total}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  className="text-black"
                  onClick={() => onPageChange(pagination.page - 1)}
                  disabled={pagination.page === 1}
                >
                  Previous
                </Button>
                <span className="text-sm text-gray-600">
                  Page {pagination.page} of {pagination.totalPages}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  className="text-black"
                  onClick={() => onPageChange(pagination.page + 1)}
                  disabled={pagination.page === pagination.totalPages}
                >
                  Next
                </Button>
              </div>
            </div>
          </Card>
        )}
      </div>

      {selected && (
        <TransactionDetailModal
          transaction={selected}
          onClose={() => setSelected(null)}
        />
      )}
    </>
  )
}
