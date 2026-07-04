'use client'

import { useEffect, useState } from 'react'
import { RefreshCw, Building2, Receipt } from 'lucide-react'
import { Button } from '@/app/components/ui/button'
import toast from 'react-hot-toast'
import DonationStatsCards from './DonationStatsCards'
import ConnectedMosquesTable from './ConnectedMosquesTable'
import DonationTransactionsTable from './DonationTransactionsTable'

const TABS = [
  { label: 'Connected Mosques', value: 'mosques', icon: Building2 },
  { label: 'Transactions', value: 'transactions', icon: Receipt },
] as const

export default function DonationsManagement() {
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState<'mosques' | 'transactions'>('mosques')
  const [page, setPage] = useState(1)

  const fetchData = async (p = 1) => {
    try {
      setLoading(true)
      const res = await fetch(`/api/admin/donations?page=${p}&limit=20`)
      if (!res.ok) throw new Error('Failed to load')
      const json = await res.json()
      setData(json)
    } catch {
      toast.error('Failed to load donation data')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData(page)
  }, [page])

  const handlePageChange = (p: number) => {
    setPage(p)
  }

  return (
    <div className="space-y-6">
      {/* Stats */}
      {data?.stats && <DonationStatsCards stats={data.stats} />}

      {/* Tabs + Refresh */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div className="flex gap-2">
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
        <Button
          variant="outline"
          className="text-black flex items-center gap-2"
          onClick={() => fetchData(page)}
          disabled={loading}
        >
          <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {/* Content */}
      {loading ? (
        <div className="flex items-center justify-center h-48">
          <RefreshCw className="h-7 w-7 animate-spin text-gray-400" />
        </div>
      ) : activeTab === 'mosques' ? (
        <ConnectedMosquesTable accounts={data?.accounts ?? []} />
      ) : (
        <DonationTransactionsTable
          transactions={data?.transactions ?? []}
          pagination={data?.pagination ?? { page: 1, limit: 20, total: 0, totalPages: 0 }}
          onPageChange={handlePageChange}
        />
      )}
    </div>
  )
}
