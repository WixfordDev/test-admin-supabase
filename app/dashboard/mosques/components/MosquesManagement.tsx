'use client'

import { useState, useEffect } from 'react'
import { Card } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Plus, Download, RefreshCw, Clock } from 'lucide-react'
import type { Mosque, MosqueFilters, MosqueStats } from '@/lib/types/mosques'
import MosqueStatsCards from './MosqueStatsCards'
import MosqueFiltersPanel from './MosqueFiltersPanel'
import MosqueTable from './MosqueTable'
import AddMosqueDialog from './AddMosqueDialog'

export default function MosquesManagement() {
  const [mosques, setMosques] = useState<Mosque[]>([])
  const [stats, setStats] = useState<MosqueStats>({
    total: 0,
    thisWeek: 0,
    thisMonth: 0,
    byTimezone: {},
    byFacility: {}
  })
  const [filters, setFilters] = useState<MosqueFilters>({
    search: '',
    timezone: '',
    hasFacilities: [],
    dateRange: { from: null, to: null }
  })
  const [loading, setLoading] = useState(true)
  const [selectedMosques, setSelectedMosques] = useState<string[]>([])
  const [showAddDialog, setShowAddDialog] = useState(false)
  const [activeTab, setActiveTab] = useState<'all' | 'user_submitted'>('all')

  const fetchMosques = async () => {
    try {
      setLoading(true)

      const params = new URLSearchParams()
      if (filters.search) params.set('search', filters.search)
      if (filters.timezone) params.set('timezone', filters.timezone)
      if (filters.hasFacilities.length > 0) params.set('facility', filters.hasFacilities[0])

      const response = await fetch(`/api/admin/mosques?${params.toString()}`)
      if (!response.ok) throw new Error('Failed to fetch mosques')

      const data = await response.json()
      setMosques(data.mosques || [])
      setStats({
        total: data.stats?.total_mosques || 0,
        thisWeek: data.stats?.this_week || 0,
        thisMonth: data.stats?.this_month || 0,
        byTimezone: data.stats?.by_timezone || {},
        byFacility: data.stats?.by_facility || {}
      })
    } catch (error) {
      console.error('Error fetching mosques:', error)
      setMosques([])
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateMosque = async (id: string, updates: Partial<Mosque>) => {
    try {
      const response = await fetch(`/api/admin/mosques?id=${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      })
      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to update mosque')
      }
      await fetchMosques()
    } catch (error) {
      console.error('Error updating mosque:', error)
    }
  }

  const handleDeleteMosque = async (id: string) => {
    if (!confirm('Are you sure you want to delete this mosque? This action cannot be undone.')) return
    try {
      const response = await fetch(`/api/admin/mosques?id=${id}`, { method: 'DELETE' })
      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to delete mosque')
      }
      await fetchMosques()
    } catch (error) {
      console.error('Error deleting mosque:', error)
    }
  }

  const handleApproveMosque = async (id: string) => {
    try {
      const response = await fetch(`/api/admin/mosques?id=${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ is_approved: true })
      })
      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to approve mosque')
      }
      await fetchMosques()
    } catch (error) {
      console.error('Error approving mosque:', error)
    }
  }

  const handleBulkAction = async (action: string) => {
    if (selectedMosques.length === 0) return
    console.log('Bulk action functionality needs API implementation:', action, selectedMosques)
    setSelectedMosques([])
    await fetchMosques()
  }

  const handleExport = async () => {
    console.log('Export functionality needs API implementation')
  }

  useEffect(() => {
    fetchMosques()
  }, [filters])

  const userSubmittedMosques = mosques.filter(m => m.mosque_id.startsWith('user_mosque_'))
  const pendingCount = userSubmittedMosques.filter(m => !m.is_approved).length
  const displayMosques = activeTab === 'user_submitted' ? userSubmittedMosques : mosques

  return (
    <div className="space-y-6">
      <MosqueStatsCards stats={stats} loading={loading} />

      {/* Header Actions */}
      <Card className="p-6">
        <div className="flex flex-col text-black lg:flex-row gap-4 items-start lg:items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Mosque Database</h2>
            <p className="text-gray-600">Manage mosque locations and metadata</p>
          </div>

          <div className="flex items-center gap-2">
            <Button onClick={() => setShowAddDialog(true)} className="flex items-center gap-2">
              <Plus className="h-4 w-4" />
              Add Mosque
            </Button>
            <Button variant="outline" onClick={fetchMosques} className="flex items-center gap-2">
              <RefreshCw className="h-4 w-4" />
              Refresh
            </Button>
            <Button variant="outline" onClick={handleExport} className="flex items-center gap-2">
              <Download className="h-4 w-4" />
              Export CSV
            </Button>
          </div>
        </div>

        {selectedMosques.length > 0 && (
          <div className="border-t mt-6 pt-4">
            <div className="flex items-center gap-2">
              <span className="text-sm text-gray-600">
                {selectedMosques.length} mosque{selectedMosques.length !== 1 ? 's' : ''} selected:
              </span>
              <Button size="sm" variant="destructive" onClick={() => handleBulkAction('delete')}>
                Delete Selected
              </Button>
            </div>
          </div>
        )}
      </Card>

      <MosqueFiltersPanel filters={filters} onFiltersChange={setFilters} mosques={mosques} />

      {/* Tabs */}
      <div className="flex gap-1 border-b border-gray-200">
        <button
          onClick={() => setActiveTab('all')}
          className={`px-4 py-2 text-sm font-medium rounded-t-md transition-colors ${
            activeTab === 'all'
              ? 'bg-white border border-b-white border-gray-200 text-blue-600 -mb-px'
              : 'text-gray-500 hover:text-gray-700'
          }`}
        >
          All Mosques ({mosques.length})
        </button>
        <button
          onClick={() => setActiveTab('user_submitted')}
          className={`px-4 py-2 text-sm font-medium rounded-t-md transition-colors flex items-center gap-2 ${
            activeTab === 'user_submitted'
              ? 'bg-white border border-b-white border-gray-200 text-blue-600 -mb-px'
              : 'text-gray-500 hover:text-gray-700'
          }`}
        >
          <Clock className="h-3.5 w-3.5" />
          User Submitted ({userSubmittedMosques.length})
          {pendingCount > 0 && (
            <span className="bg-yellow-500 text-white text-xs font-bold px-1.5 py-0.5 rounded-full">
              {pendingCount}
            </span>
          )}
        </button>
      </div>

      <MosqueTable
        mosques={displayMosques}
        selectedMosques={selectedMosques}
        onSelectionChange={setSelectedMosques}
        onUpdateMosque={handleUpdateMosque}
        onDeleteMosque={handleDeleteMosque}
        onApproveMosque={handleApproveMosque}
        loading={loading}
      />

      {showAddDialog && (
        <AddMosqueDialog
          isOpen={showAddDialog}
          onClose={() => setShowAddDialog(false)}
          onSuccess={() => {
            setShowAddDialog(false)
            fetchMosques()
          }}
        />
      )}
    </div>
  )
}
