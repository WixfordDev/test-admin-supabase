'use client'

import { useEffect, useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { RefreshCw } from 'lucide-react'
import toast, { Toaster } from 'react-hot-toast'
import type { MosqueClaim, MosqueClaimStats } from '@/lib/types/mosque-claims'
import MosqueClaimsStatsCards from './MosqueClaimsStatsCards'
import MosqueClaimsTable from './MosqueClaimsTable'

const STATUS_TABS = [
  { label: 'All', value: 'all' },
  { label: 'Pending', value: 'pending' },
  { label: 'Approved', value: 'approved' },
  { label: 'Rejected', value: 'rejected' },
  { label: 'Verified', value: 'verified' },
]

export default function MosqueClaimsManagement() {
  const [claims, setClaims] = useState<MosqueClaim[]>([])
  const [stats, setStats] = useState<MosqueClaimStats>({
    total: 0,
    pending: 0,
    approved: 0,
    rejected: 0,
    verified: 0,
  })
  const [activeTab, setActiveTab] = useState('all')
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const [isActing, setIsActing] = useState(false)
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 20,
    total: 0,
    totalPages: 0,
  })

  const fetchClaims = async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams()
      if (activeTab !== 'all') params.set('status', activeTab)
      if (search) params.set('search', search)
      params.set('page', pagination.page.toString())
      params.set('limit', pagination.limit.toString())

      const response = await fetch(`/api/admin/mosque-claims?${params}`)
      if (!response.ok) throw new Error('Failed to fetch claims')

      const data = await response.json()
      setClaims(data.claims ?? [])
      setStats(data.stats)
      setPagination((prev) => ({
        ...prev,
        total: data.pagination?.total ?? 0,
        totalPages: data.pagination?.totalPages ?? 0,
      }))
    } catch {
      toast.error('Failed to load claims')
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (id: string) => {
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${id}/approve`, {
        method: 'PUT',
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      toast.success(
        `Claim approved! Verification code: ${data.verification_code}`,
        { duration: 8000 }
      )
      await fetchClaims()
    } catch (err: any) {
      toast.error(err.message || 'Failed to approve claim')
    } finally {
      setIsActing(false)
    }
  }

  const handleReject = async (id: string) => {
    if (!confirm('Are you sure you want to reject this claim?')) return
    setIsActing(true)
    try {
      const response = await fetch(`/api/admin/mosque-claims/${id}/reject`, {
        method: 'PUT',
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error)

      toast.success('Claim rejected')
      await fetchClaims()
    } catch (err: any) {
      toast.error(err.message || 'Failed to reject claim')
    } finally {
      setIsActing(false)
    }
  }

  useEffect(() => {
    fetchClaims()
  }, [activeTab, pagination.page, pagination.limit])

  // Debounced search
  useEffect(() => {
    const t = setTimeout(() => {
      setPagination((prev) => ({ ...prev, page: 1 }))
      fetchClaims()
    }, 400)
    return () => clearTimeout(t)
  }, [search])

  return (
    <div className="space-y-6">
      <Toaster />

      {/* Stats */}
      <MosqueClaimsStatsCards stats={stats} />

      {/* Toolbar */}
      <Card className="p-4">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
          <input
            type="text"
            placeholder="Search by email, position, notes..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="border rounded-lg px-3 py-2 text-sm w-full sm:w-72 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <Button
            variant="outline"
            className="text-black flex items-center gap-2"
            onClick={fetchClaims}
          >
            <RefreshCw className="h-4 w-4" />
            Refresh
          </Button>
        </div>
      </Card>

      {/* Status tabs */}
      <div className="flex gap-2 flex-wrap">
        {STATUS_TABS.map((tab) => (
          <button
            key={tab.value}
            onClick={() => {
              setActiveTab(tab.value)
              setPagination((prev) => ({ ...prev, page: 1 }))
            }}
            className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
              activeTab === tab.value
                ? 'bg-gray-900 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            {tab.label}
            {tab.value !== 'all' && (
              <span className="ml-1.5 opacity-70">
                {stats[tab.value as keyof MosqueClaimStats]}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Table */}
      {loading ? (
        <div className="flex items-center justify-center h-48">
          <RefreshCw className="h-7 w-7 animate-spin text-gray-400" />
        </div>
      ) : (
        <MosqueClaimsTable
          claims={claims}
          onApprove={handleApprove}
          onReject={handleReject}
          isActing={isActing}
        />
      )}

      {/* Pagination */}
      {pagination.totalPages > 1 && (
        <Card className="p-4">
          <div className="flex items-center justify-between">
            <p className="text-sm text-gray-600">
              Showing {(pagination.page - 1) * pagination.limit + 1}–
              {Math.min(pagination.page * pagination.limit, pagination.total)} of{' '}
              {pagination.total} claims
            </p>
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                className="text-black"
                onClick={() => setPagination((p) => ({ ...p, page: p.page - 1 }))}
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
                onClick={() => setPagination((p) => ({ ...p, page: p.page + 1 }))}
                disabled={pagination.page === pagination.totalPages}
              >
                Next
              </Button>
            </div>
          </div>
        </Card>
      )}
    </div>
  )
}
