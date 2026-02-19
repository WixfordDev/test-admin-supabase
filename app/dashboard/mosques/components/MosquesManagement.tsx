'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Badge } from '@/app/components/ui/badge'
import { Plus, Download, RefreshCw, MapPin, CheckCircle, XCircle } from 'lucide-react'
// Removed unused createClient import
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

  // Removed unused supabase client

  const fetchMosques = async () => {
    try {
      setLoading(true)
      
      // Build query parameters
      const params = new URLSearchParams()
      if (filters.search) {
        params.set('search', filters.search)
      }
      if (filters.timezone) {
        params.set('timezone', filters.timezone)
      }
      if (filters.hasFacilities.length > 0) {
        // For now, just use the first facility filter
        params.set('facility', filters.hasFacilities[0])
      }

      // Use the admin API instead of direct database queries
      const response = await fetch(`/api/admin/mosques?${params.toString()}`)
      
      if (!response.ok) {
        throw new Error('Failed to fetch mosques')
      }

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

  // Remove calculateStats since we get stats from API

  const handleUpdateMosque = async (id: string, updates: Partial<Mosque>) => {
    try {
      const response = await fetch(`/api/admin/mosques?id=${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updates)
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to update mosque')
      }

      await fetchMosques()
    } catch (error) {
      console.error('Error updating mosque:', error)
      // You might want to show a toast notification here
    }
  }

  const handleDeleteMosque = async (id: string) => {
    if (!confirm('Are you sure you want to delete this mosque? This action cannot be undone.')) {
      return
    }

    try {
      const response = await fetch(`/api/admin/mosques?id=${id}`, {
        method: 'DELETE'
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'Failed to delete mosque')
      }

      await fetchMosques()
    } catch (error) {
      console.error('Error deleting mosque:', error)
      // You might want to show a toast notification here
    }
  }

  const handleBulkAction = async (action: string) => {
    if (selectedMosques.length === 0) return
    console.log('Bulk action functionality needs API implementation:', action, selectedMosques)
    // TODO: Implement bulk mosque actions API
    setSelectedMosques([])
    await fetchMosques()
  }

  const handleExport = async () => {
    console.log('Export functionality needs API implementation')
    // TODO: Implement export mosque data API
  }

  useEffect(() => {
    fetchMosques()
  }, [filters])

  return (
    <div className="space-y-6">
      {/* Stats Cards */}
      <MosqueStatsCards stats={stats} loading={loading} />

      {/* Header Actions */}
      <Card className="p-6">
        <div className="flex flex-col text-black lg:flex-row gap-4 items-start lg:items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Mosque Database</h2>
            <p className="text-gray-600">Manage mosque locations and metadata</p>
          </div>

          <div className="flex items-center gap-2">
            <Button
              onClick={() => setShowAddDialog(true)}
              className="flex items-center gap-2"
            >
              <Plus className="h-4 w-4" />
              Add Mosque
            </Button>
            <Button
              variant="outline"
              onClick={fetchMosques}
              className="flex items-center gap-2"
            >
              <RefreshCw className="h-4 w-4" />
              Refresh
            </Button>
            <Button
              variant="outline"
              onClick={handleExport}
              className="flex items-center gap-2"
            >
              <Download className="h-4 w-4" />
              Export CSV
            </Button>
          </div>
        </div>

        {/* Bulk Actions */}
        {selectedMosques.length > 0 && (
          <div className="border-t mt-6 pt-4">
            <div className="flex items-center gap-2">
              <span className="text-sm text-gray-600">
                {selectedMosques.length} mosque{selectedMosques.length !== 1 ? 's' : ''} selected:
              </span>

              <Button
                size="sm"
                variant="destructive"
                onClick={() => handleBulkAction('delete')}
              >
                Delete Selected
              </Button>
            </div>
          </div>
        )}
      </Card>

      {/* Filters */}
      <MosqueFiltersPanel
        filters={filters}
        onFiltersChange={setFilters}
        mosques={mosques}
      />

      {/* Mosques Table */}
      <MosqueTable
        mosques={mosques}
        selectedMosques={selectedMosques}
        onSelectionChange={setSelectedMosques}
        onUpdateMosque={handleUpdateMosque}
        onDeleteMosque={handleDeleteMosque}
        loading={loading}
      />

      {/* Add Mosque Dialog */}
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