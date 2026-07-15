'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { X, RefreshCw, ExternalLink, Target, TrendingUp, Receipt, CheckCircle, Clock, XCircle } from 'lucide-react'
import toast from 'react-hot-toast'
import { CAMPAIGN_CATEGORIES } from '@/lib/types/campaigns'
import ConfirmDialog from '@/app/components/ui/confirm-dialog'

interface Props {
  campaignId: string
  onClose: () => void
  onDeleted: () => void
}

function fmt(cents: number, currency = 'usd') {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: currency.toUpperCase() }).format(cents / 100)
}

export default function CampaignDetailModal({ campaignId, onClose, onDeleted }: Props) {
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)
  const [deleting, setDeleting] = useState(false)

  const fetchDetail = async () => {
    try {
      setLoading(true)
      const res = await fetch(`/api/admin/campaigns/${campaignId}`)
      if (!res.ok) throw new Error('Failed to load')
      setData(await res.json())
    } catch {
      toast.error('Failed to load campaign details')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => { fetchDetail() }, [campaignId])

  const handleDelete = async () => {
    setDeleting(true)
    try {
      const res = await fetch(`/api/admin/campaigns/${campaignId}`, { method: 'DELETE' })
      if (!res.ok) throw new Error('Failed')
      toast.success('Campaign deleted')
      onDeleted()
    } catch {
      toast.error('Failed to delete campaign')
    } finally {
      setDeleting(false)
      setShowDeleteConfirm(false)
    }
  }

  const campaign = data?.campaign
  const stats = data?.stats
  const transactions = data?.transactions ?? []
  const pct = campaign ? Math.min(Math.round((campaign.raised_amount / campaign.goal_amount) * 100), 100) : 0
  const categoryLabel = CAMPAIGN_CATEGORIES.find((c) => c.value === campaign?.category)?.label ?? campaign?.category

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
      <div className="bg-white w-full max-w-2xl rounded-2xl shadow-xl flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-bold text-gray-900">Campaign Details</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-700">
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Body */}
        <div className="overflow-y-auto flex-1 p-6 space-y-6">
          {loading ? (
            <div className="flex items-center justify-center h-40">
              <RefreshCw className="h-7 w-7 animate-spin text-gray-400" />
            </div>
          ) : !campaign ? (
            <p className="text-gray-500 text-center">Campaign not found.</p>
          ) : (
            <>
              {/* Campaign info */}
              <div className="space-y-3">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h3 className="text-lg font-bold text-gray-900">{campaign.title}</h3>
                    <p className="text-sm text-gray-500">{campaign.mosque?.name ?? campaign.mosque_id}</p>
                  </div>
                  <span className={`shrink-0 px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                    campaign.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-500'
                  }`}>
                    {campaign.is_active ? 'Active' : 'Inactive'}
                  </span>
                </div>
                <p className="text-sm text-gray-600">{campaign.description}</p>

                <div className="flex flex-wrap gap-2 text-xs">
                  <span className="px-2.5 py-0.5 rounded-full bg-blue-50 text-blue-700 font-medium">{categoryLabel}</span>
                  {campaign.no_end_date ? (
                    <span className="px-2.5 py-0.5 rounded-full bg-yellow-50 text-yellow-700 font-medium">
                      No end date
                    </span>
                  ) : campaign.end_date && (
                    <span className="px-2.5 py-0.5 rounded-full bg-yellow-50 text-yellow-700 font-medium">
                      Deadline: {new Date(campaign.end_date).toLocaleDateString()}
                    </span>
                  )}
                </div>
              </div>

              {/* Progress */}
              <Card className="p-4 space-y-3">
                <div className="flex justify-between text-sm">
                  <span className="font-medium text-gray-700">Progress</span>
                  <span className="font-bold text-gray-900">{pct}%</span>
                </div>
                <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                  <div className={`h-full rounded-full ${pct >= 100 ? 'bg-emerald-500' : 'bg-blue-500'}`}
                    style={{ width: `${pct}%` }} />
                </div>
                <div className="flex justify-between text-sm text-gray-600">
                  <span>Raised: <span className="font-semibold text-gray-900">{fmt(campaign.raised_amount, campaign.currency)}</span></span>
                  <span>Goal: <span className="font-semibold text-gray-900">{fmt(campaign.goal_amount, campaign.currency)}</span></span>
                </div>
              </Card>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-3">
                {[
                  { label: 'Completed', value: stats?.completed ?? 0, icon: CheckCircle, color: 'text-green-600', bg: 'bg-green-50' },
                  { label: 'Pending', value: stats?.pending ?? 0, icon: Clock, color: 'text-yellow-600', bg: 'bg-yellow-50' },
                  { label: 'Failed', value: stats?.failed ?? 0, icon: XCircle, color: 'text-red-500', bg: 'bg-red-50' },
                ].map((s) => (
                  <Card key={s.label} className="p-3 flex items-center gap-3">
                    <div className={`p-2 rounded-full ${s.bg}`}>
                      <s.icon className={`h-4 w-4 ${s.color}`} />
                    </div>
                    <div>
                      <p className="text-xs text-gray-500">{s.label}</p>
                      <p className="text-lg font-bold text-gray-900">{s.value}</p>
                    </div>
                  </Card>
                ))}
              </div>

              {/* Recent Transactions */}
              <div>
                <h4 className="text-sm font-semibold text-gray-700 mb-3">Recent Transactions</h4>
                {transactions.length === 0 ? (
                  <Card className="p-6 text-center">
                    <Receipt className="h-8 w-8 text-gray-300 mx-auto mb-2" />
                    <p className="text-sm text-gray-500">No transactions yet.</p>
                  </Card>
                ) : (
                  <Card className="overflow-hidden">
                    <table className="w-full text-sm">
                      <thead>
                        <tr className="bg-gray-50 border-b text-left">
                          <th className="px-3 py-2 font-medium text-gray-600">Amount</th>
                          <th className="px-3 py-2 font-medium text-gray-600">Mosque Gets</th>
                          <th className="px-3 py-2 font-medium text-gray-600">Status</th>
                          <th className="px-3 py-2 font-medium text-gray-600">Date</th>
                          <th className="px-3 py-2 font-medium text-gray-600">Receipt</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-100">
                        {transactions.map((t: any) => (
                          <tr key={t.id} className="hover:bg-gray-50">
                            <td className="px-3 py-2 font-semibold text-gray-900">{fmt(t.amount, t.currency)}</td>
                            <td className="px-3 py-2 text-green-700">{fmt(t.mosque_amount, t.currency)}</td>
                            <td className="px-3 py-2">
                              <span className={`px-2 py-0.5 rounded-full text-xs font-semibold capitalize ${
                                t.status === 'completed' ? 'bg-green-100 text-green-800' :
                                t.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                                'bg-red-100 text-red-700'
                              }`}>{t.status}</span>
                            </td>
                            <td className="px-3 py-2 text-gray-500">{new Date(t.created_at).toLocaleDateString()}</td>
                            <td className="px-3 py-2">
                              {t.receipt_url ? (
                                <a href={t.receipt_url} target="_blank" rel="noopener noreferrer"
                                  className="text-blue-600 hover:text-blue-800">
                                  <ExternalLink className="h-3.5 w-3.5" />
                                </a>
                              ) : '—'}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </Card>
                )}
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        {!loading && campaign && (
          <div className="flex justify-between items-center p-6 border-t">
            <Button
              variant="outline"
              className="text-red-600 border-red-300 hover:bg-red-50"
              onClick={() => setShowDeleteConfirm(true)}
              disabled={deleting}
            >
              Delete Campaign
            </Button>
            <Button variant="outline" className="text-black" onClick={onClose}>
              Close
            </Button>
          </div>
        )}
      </div>

      <ConfirmDialog
        open={showDeleteConfirm}
        title="Delete Campaign"
        description={`Are you sure you want to delete "${campaign?.title}"? All related data will be removed.`}
        confirmText="Delete"
        variant="danger"
        isLoading={deleting}
        onConfirm={handleDelete}
        onCancel={() => setShowDeleteConfirm(false)}
      />
    </div>
  )
}
