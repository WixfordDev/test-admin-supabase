'use client';

import { useState } from 'react';
import { Card } from '@/app/components/ui/card';
import { Input } from '@/app/components/ui/input';
import { Button } from '@/app/components/ui/button';
import { Badge } from '@/app/components/ui/badge';
import { Search, Filter, X } from 'lucide-react';
import { QuranRequest, QuranRequestFilters } from '@/lib/types/quran-requests';

interface QuranRequestFiltersPanelProps {
  filters: QuranRequestFilters;
  onFiltersChange: (filters: QuranRequestFilters) => void;
  requests: QuranRequest[];
}

export default function QuranRequestFiltersPanel({ 
  filters, 
  onFiltersChange, 
  requests 
}: QuranRequestFiltersPanelProps) {
  const [showAdvanced, setShowAdvanced] = useState(false);

  const statusOptions = [
    { value: 'all', label: 'All Statuses', count: requests.length },
    { value: 'requested', label: 'Requested', count: requests.filter(r => r.status === 'requested').length },
    { value: 'processing', label: 'Processing', count: requests.filter(r => r.status === 'processing').length },
    { value: 'sent', label: 'Sent', count: requests.filter(r => r.status === 'sent').length },
    { value: 'delivered', label: 'Delivered', count: requests.filter(r => r.status === 'delivered').length },
    { value: 'cancelled', label: 'Cancelled', count: requests.filter(r => r.status === 'cancelled').length }
  ];

  const uniqueCountries = Array.from(new Set(requests.map(r => r.country))).filter(Boolean);
  const uniqueStates = Array.from(new Set(requests.map(r => r.state))).filter(Boolean);
  const uniqueLanguages = Array.from(new Set(requests.map(r => r.preferred_language))).filter(Boolean);

  const handleFilterChange = (key: keyof QuranRequestFilters, value: any) => {
    onFiltersChange({
      ...filters,
      [key]: value
    });
  };

  const clearFilters = () => {
    onFiltersChange({
      search: '',
      status: 'all',
      country: '',
      state: '',
      preferred_language: '',
      dateRange: { from: null, to: null }
    });
  };

  const hasActiveFilters = filters.search || filters.status !== 'all' || filters.country || filters.state || filters.preferred_language || filters.dateRange.from || filters.dateRange.to;

  return (
    <Card className="p-6">
      <div className="space-y-4">
        {/* Search and Status Row */}
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Search by name, email, or address..."
                value={filters.search}
                onChange={(e) => handleFilterChange('search', e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <div className="flex items-center text-black gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowAdvanced(!showAdvanced)}
              className="flex items-center gap-2"
            >
              <Filter className="h-4 w-4" />
              {showAdvanced ? 'Hide Filters' : 'More Filters'}
            </Button>
            
            {hasActiveFilters && (
              <Button
                variant="outline"
                size="sm"
                onClick={clearFilters}
                className="flex items-center text-black gap-2"
              >
                <X className="h-4 w-4" />
                Clear
              </Button>
            )}
          </div>
        </div>

        {/* Status Filter */}
        <div>
          <label className="text-sm text-black font-medium mb-2 block">Status</label>
          <div className="flex flex-wrap text-black gap-2">
            {statusOptions.map((option) => (
              <Badge
                key={option.value}
                variant={filters.status === option.value ? 'default' : 'secondary'}
                className="cursor-pointer hover:bg-gray-100"
                onClick={() => handleFilterChange('status', option.value)}
              >
                {option.label} ({option.count})
              </Badge>
            ))}
          </div>
        </div>

        {/* Advanced Filters */}
        {showAdvanced && (
          <div className="border-t pt-4 space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Country Filter */}
              <div>
                <label className="text-sm font-medium text-gray-700 mb-2 block">Country</label>
                <select
                  value={filters.country || ''}
                  onChange={(e) => handleFilterChange('country', e.target.value)}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                >
                  <option value="">All Countries</option>
                  {uniqueCountries.map((country) => (
                    <option key={country ?? 'unknown'} value={country ?? ''}>
                      {country ?? 'Unknown'}
                    </option>
                  ))}
                </select>
              </div>

              {/* State Filter */}
              <div>
                <label className="text-sm font-medium text-gray-700 mb-2 block">State</label>
                <select
                  value={filters.state || ''}
                  onChange={(e) => handleFilterChange('state', e.target.value)}
                  className="w-full text-black rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                >
                  <option className='text-black' value="">All States</option>
                  {uniqueStates.map((state) => (
                    <option className='text-black' key={state ?? 'unknown'} value={state ?? ''}>
                      {state ?? 'Unknown'}
                    </option>
                  ))}
                </select>
              </div>

              {/* Language Filter */}
              <div>
                <label className="text-sm font-medium text-gray-700 mb-2 block">Preferred Language</label>
                <select
                  value={filters.preferred_language || ''}
                  onChange={(e) => handleFilterChange('preferred_language', e.target.value)}
                  className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none"
                >
                  <option value="">All Languages</option>
                  {uniqueLanguages.map((language) => (
                    <option key={language ?? 'unknown'} value={language ?? ''}>
                      {language ?? 'Unknown'}
                    </option>
                  ))}
                </select>
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
                    value={filters.dateRange.to ? filters.dateRange.to.toISOString().split('T')[0] : ''}
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
        <div className="text-sm text-black font-medium">
          Showing {requests.length} request{requests.length !== 1 ? 's' : ''}
          {hasActiveFilters && ' (filtered)'}
        </div>
      </div>
    </Card>
  );
} 