'use client'

import { useState } from 'react'
import { Card } from '@/app/components/ui/card'
import { Input } from '@/app/components/ui/input'
import { Button } from '@/app/components/ui/button'
import { Badge } from '@/app/components/ui/badge'
import { Search, Filter, X } from 'lucide-react'
import type { Mosque, MosqueFilters } from '@/lib/types/mosques'
import { MOSQUE_FACILITIES } from '@/lib/types/mosques'

interface MosqueFiltersPanelProps {
  filters: MosqueFilters
  onFiltersChange: (filters: MosqueFilters) => void
  mosques: Mosque[]
}

export default function MosqueFiltersPanel({ 
  filters, 
  onFiltersChange, 
  mosques 
}: MosqueFiltersPanelProps) {
  const [showAdvanced, setShowAdvanced] = useState(false)

  const uniqueTimezones = Array.from(new Set(mosques.map(m => m.timezone))).filter(Boolean).sort()
  const allFacilities = mosques.flatMap(m => m.facilities?.map(f => f.facility_type) || [])
  const facilityStats = allFacilities.reduce((acc, facility) => {
    acc[facility] = (acc[facility] || 0) + 1
    return acc
  }, {} as Record<string, number>)

  const handleFilterChange = (key: keyof MosqueFilters, value: any) => {
    onFiltersChange({
      ...filters,
      [key]: value
    })
  }



  const handleFacilityToggle = (facility: string) => {
    const hasFacilities = filters.hasFacilities.includes(facility)
      ? filters.hasFacilities.filter(f => f !== facility)
      : [...filters.hasFacilities, facility]
    
    handleFilterChange('hasFacilities', hasFacilities)
  }

  const clearFilters = () => {
    onFiltersChange({
      search: '',
      timezone: '',
      hasFacilities: [],
      dateRange: { from: null, to: null }
    })
  }

  const hasActiveFilters = filters.search || 
    filters.timezone ||
    filters.hasFacilities.length > 0 ||
    filters.dateRange.from || 
    filters.dateRange.to

  return (
    <Card className="p-6">
      <div className="space-y-4">
        {/* Search Row */}
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Search by name, address, or additional info..."
                value={filters.search}
                onChange={(e) => handleFilterChange('search', e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAdvanced(!showAdvanced)}
              className="flex items-center text-black gap-2"
            >
              <Filter className="h-4 w-4 text-black" />
              {showAdvanced ? 'Hide Filters' : 'More Filters'}
            </Button>
            
            {hasActiveFilters && (
              <Button
                variant="outline"
                size="sm"
                onClick={clearFilters}
                className="flex items-center gap-2"
              >
                <X className="h-4 w-4" />
                Clear
              </Button>
            )}
          </div>
        </div>

        {/* Timezone Filter */}
        <div>
          <label className="text-sm font-medium text-gray-700 mb-2 block">Timezone</label>
          <select
            value={filters.timezone || ''}
            onChange={(e) => handleFilterChange('timezone', e.target.value)}
            className="w-full max-w-xs rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
          >
            <option value="">All Timezones</option>
            {uniqueTimezones.map((timezone) => (
              <option key={timezone} value={timezone || ''}>
                {timezone}
              </option>
            ))}
          </select>
        </div>

        {/* Advanced Filters */}
        {showAdvanced && (
          <div className="border-t pt-4 space-y-4">
            {/* Facilities Filter */}
            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 block">Facilities</label>
              <div className="flex flex-wrap gap-2">
                {MOSQUE_FACILITIES.map((facility) => (
                  <Badge
                    key={facility}
                    variant={filters.hasFacilities.includes(facility) ? 'default' : 'outline'}
                    className="cursor-pointer"
                    onClick={() => handleFacilityToggle(facility)}
                  >
                    {facility.replace(/_/g, ' ')} ({facilityStats[facility] || 0})
                  </Badge>
                ))}
              </div>
            </div>

            {/* Date Range */}
            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 block">Date Range</label>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <input
                    type="date"
                    placeholder="From date"
                    value={filters.dateRange.from?.toISOString().split('T')[0] || ''}
                    onChange={(e) => handleFilterChange('dateRange', {
                      ...filters.dateRange,
                      from: e.target.value ? new Date(e.target.value) : null
                    })}
                    className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  />
                </div>
                <div>
                  <input
                    type="date"
                    placeholder="To date"
                    value={filters.dateRange.to?.toISOString().split('T')[0] || ''}
                    onChange={(e) => handleFilterChange('dateRange', {
                      ...filters.dateRange,
                      to: e.target.value ? new Date(e.target.value) : null
                    })}
                    className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                  />
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Results Summary */}
        <div className="text-sm text-gray-600">
          Showing {mosques.length} mosque{mosques.length !== 1 ? 's' : ''}
          {hasActiveFilters && ' (filtered)'}
        </div>
      </div>
    </Card>
  )
} 