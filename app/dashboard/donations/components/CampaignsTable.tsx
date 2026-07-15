'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Megaphone, Eye } from 'lucide-react'
import { CAMPAIGN_CATEGORIES } from '@/lib/types/campaigns'
import CampaignDetailModal from './CampaignDetailModal'

interface Campaign {
  id: string
  mosque_name: string
  title: string
  category: string
  goal_amount: number
  raised_amount: number
  currency: string
  start_date: string | null
  end_date: string | null
  no_end_date: boolean
  is_active: boolean
  created_at: string
}

interface Pagination {
  page: number
  limit: number
  total: number
  totalPages: number
}

function fmt(cents: number, currency: string) {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency.toUpperCase() }).format(cents / 100)
}

function categoryLabel(value: string) {
  return CAMPAIGN_CATEGORIES.find((c) => c.value === value)?.label ?? value
}

function ProgressBar({ raised, goal }: { raised: number; goal: number }) {
  const pct = goal > 0 ? Math.min(Math.round((raised / goal) * 100), 100) : 0
  return (
    <div className="w-full">
      <div className="flex justify-between text-xs text-gray-500 mb-1">
        <span>{pct}%</span>
        <span>{fmt(raised, 'usd')} / {fmt(goal, 'usd')}</span>
      </div>
      <div className="h-1.5 bg-gray-100 rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full ${pct >= 100 ? 'bg-emerald-500' : 'bg-blue-500'}`}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  )
}

interface Props {
  campaigns: Campaign[]
  pagination: Pagination
  onPageChange: (page: number) => void
  onRefresh?: () => void
}

export default function CampaignsTable({ campaigns, pagination, onPageChange, onRefresh }: Props) {
  const [selectedCampaignId, setSelectedCampaignId] = useState<string | null>(null)

  if (campaigns.length === 0) {
    return (
      <Card className="p-12 text-center">
        <Megaphone className="h-10 w-10 text-gray-300 mx-auto mb-3" />
        <p className="text-gray-500">No campaigns found.</p>
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
                  <th className="px-4 py-3 font-medium text-gray-600">Campaign</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Category</th>
                  <th className="px-4 py-3 font-medium text-gray-600 min-w-[200px]">Progress</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Deadline</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {campaigns.map((c) => (
                  <tr key={c.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-4 py-3 text-gray-600 max-w-[140px] truncate">{c.mosque_name}</td>
                    <td className="px-4 py-3 font-medium text-gray-900 max-w-[180px] truncate">{c.title}</td>
                    <td className="px-4 py-3">
                      <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-50 text-blue-700">
                        {categoryLabel(c.category)}
                      </span>
                    </td>
                    <td className="px-4 py-3 min-w-[200px]">
                      <ProgressBar raised={c.raised_amount} goal={c.goal_amount} />
                    </td>
                    <td className="px-4 py-3 text-gray-500">
                      {c.no_end_date ? 'No end date' : c.end_date ? new Date(c.end_date).toLocaleDateString() : '—'}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                        c.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-500'
                      }`}>
                        {c.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => setSelectedCampaignId(c.id)}
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
                <Button variant="outline" size="sm" className="text-black"
                  onClick={() => onPageChange(pagination.page - 1)} disabled={pagination.page === 1}>
                  Previous
                </Button>
                <span className="text-sm text-gray-600">Page {pagination.page} of {pagination.totalPages}</span>
                <Button variant="outline" size="sm" className="text-black"
                  onClick={() => onPageChange(pagination.page + 1)} disabled={pagination.page === pagination.totalPages}>
                  Next
                </Button>
              </div>
            </div>
          </Card>
        )}
      </div>

      {selectedCampaignId && (
        <CampaignDetailModal
          campaignId={selectedCampaignId}
          onClose={() => setSelectedCampaignId(null)}
          onDeleted={() => {
            setSelectedCampaignId(null)
            onRefresh?.()
          }}
        />
      )}
    </>
  )
}
