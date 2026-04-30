'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Input } from '@/app/components/ui/input'
import { Badge } from '@/app/components/ui/badge'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/app/components/ui/table'
import type { Report, ReportFilters, ReportStats, ReportType, ReportStatus, ReportCategory } from '@/lib/types/reports'
import {
  Search,
  Download,
  AlertTriangle,
  MessageSquareWarning,
  BookOpen,
  Bot,
  Clock,
  CheckCircle,
  XCircle,
  Eye,
  X,
} from 'lucide-react'
import { formatDateTime } from '@/lib/utils'

export default function ReportsManagement() {
  const [reports, setReports] = useState<Report[]>([])
  const [stats, setStats] = useState<ReportStats>({
    total_reports: 0,
    pending_reports: 0,
    reviewing_reports: 0,
    resolved_reports: 0,
    dismissed_reports: 0,
    reports_this_week: 0,
    avg_resolution_time_hours: 0,
    by_type: { ai_chatbot: 0, ai_explanation: 0, hadith: 0 },
    by_category: {
      incorrect_information: 0,
      inappropriate_content: 0,
      misleading_guidance: 0,
      technical_error: 0,
      inconsistency: 0,
      offensive_content: 0,
      other: 0
    }
  })
  const [filters, setFilters] = useState<ReportFilters>({
    search: '',
    report_type: 'all',
    status: 'all',
    sort_by: 'created_at',
    sort_order: 'desc'
  })
  const [isLoading, setIsLoading] = useState(true)
  const [selectedReports, setSelectedReports] = useState<string[]>([])
  const [viewingReport, setViewingReport] = useState<Report | null>(null)
  const [adminNotes, setAdminNotes] = useState('')
  const [isUpdating, setIsUpdating] = useState(false)

  const fetchReports = async () => {
    try {
      setIsLoading(true)
      const params = new URLSearchParams()
      if (filters.status && filters.status !== 'all') params.set('status', filters.status)
      if (filters.search) params.set('search', filters.search)
      if (filters.report_type && filters.report_type !== 'all') params.set('report_type', filters.report_type)

      const response = await fetch(`/api/admin/reports?${params.toString()}`)
      if (!response.ok) throw new Error('Failed to fetch reports')

      const data = await response.json()
      setReports(data.reports || [])

        console.log(data.reports)

      const reportsByType = (data.reports || []).reduce((acc: any, report: any) => {
        acc[report.report_type] = (acc[report.report_type] || 0) + 1
        return acc
      }, {})
      const reportsByCategory = (data.reports || []).reduce((acc: any, report: any) => {
        acc[report.category] = (acc[report.category] || 0) + 1
        return acc
      }, {})

      setStats({
        total_reports: data.stats?.total_reports || 0,
        pending_reports: data.stats?.pending_reports || 0,
        reviewing_reports: data.stats?.reviewed_reports || 0,
        resolved_reports: data.stats?.resolved_reports || 0,
        dismissed_reports: data.stats?.dismissed_reports || 0,
        reports_this_week: 0,
        avg_resolution_time_hours: 0,
        by_type: {
          ai_chatbot: reportsByType.ai_chatbot || 0,
          ai_explanation: reportsByType.ai_explanation || 0,
          hadith: reportsByType.hadith || 0
        },
        by_category: {
          incorrect_information: reportsByCategory.incorrect_information || 0,
          inappropriate_content: reportsByCategory.inappropriate_content || 0,
          misleading_guidance: reportsByCategory.misleading_guidance || 0,
          technical_error: reportsByCategory.technical_error || 0,
          inconsistency: reportsByCategory.inconsistency || 0,
          offensive_content: reportsByCategory.offensive_content || 0,
          other: reportsByCategory.other || 0
        }
      })
    } catch (error) {
      console.error('Error fetching reports:', error)
      setReports([])
    } finally {
      setIsLoading(false)
    }
  }

  const handleUpdateReport = async (reportId: string, updates: { status?: ReportStatus; admin_notes?: string }) => {
    try {
      setIsUpdating(true)
      const response = await fetch(`/api/admin/reports?id=${reportId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updates)
      })
      if (!response.ok) throw new Error('Failed to update report')

      await fetchReports()

      // Update viewingReport state to reflect changes
      if (viewingReport && viewingReport.id === reportId) {
        setViewingReport(prev => prev ? { ...prev, ...updates } : null)
      }
    } catch (error) {
      console.error('Error updating report:', error)
    } finally {
      setIsUpdating(false)
    }
  }

  const handleOpenReport = (report: Report) => {
    setViewingReport(report)
    setAdminNotes(report.admin_notes || '')
  }

  const handleSaveNotes = () => {
    if (viewingReport) {
      handleUpdateReport(viewingReport.id, { admin_notes: adminNotes })
    }
  }

  useEffect(() => {
    fetchReports()
  }, [filters])

  const getTypeIcon = (type: ReportType) => {
    switch (type) {
      case 'ai_chatbot': return <Bot className="h-4 w-4" />
      case 'ai_explanation': return <MessageSquareWarning className="h-4 w-4" />
      case 'hadith': return <BookOpen className="h-4 w-4" />
    }
  }

  const getTypeBadge = (type: ReportType) => {
    const configs = {
      ai_chatbot: { variant: 'default' as const, label: 'AI Chat' },
      ai_explanation: { variant: 'secondary' as const, label: 'AI Explanation' },
      hadith: { variant: 'outline' as const, label: 'Hadith' }
    }
    const config = configs[type]
    return (
      <Badge variant={config.variant} className="flex items-center gap-1">
        {getTypeIcon(type)}
        {config.label}
      </Badge>
    )
  }

  const getStatusBadge = (status: ReportStatus) => {
    switch (status) {
      case 'pending':
        return <Badge variant="warning" className="flex items-center gap-1"><Clock className="h-3 w-3" />Pending</Badge>
      case 'reviewing':
        return <Badge variant="default" className="flex items-center gap-1"><Eye className="h-3 w-3" />Reviewing</Badge>
      case 'resolved':
        return <Badge variant="success" className="flex items-center gap-1"><CheckCircle className="h-3 w-3" />Resolved</Badge>
      case 'dismissed':
        return <Badge variant="secondary" className="flex items-center gap-1"><XCircle className="h-3 w-3" />Dismissed</Badge>
    }
  }

  const getCategoryLabel = (category: ReportCategory) =>
    category.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')

  const handleSelectReport = (reportId: string) => {
    setSelectedReports(prev =>
      prev.includes(reportId) ? prev.filter(id => id !== reportId) : [...prev, reportId]
    )
  }

  const handleSelectAll = () => {
    setSelectedReports(selectedReports.length === reports.length ? [] : reports.map(r => r.id))
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardHeader className="pb-2"><div className="h-4 bg-gray-200 rounded w-3/4"></div></CardHeader>
              <CardContent><div className="h-8 bg-gray-200 rounded w-1/2 mb-2"></div></CardContent>
            </Card>
          ))}
        </div>
        <Card>
          <CardContent className="space-y-4 pt-6">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-200 rounded animate-pulse"></div>
            ))}
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Reports</CardTitle>
            <AlertTriangle className="h-4 w-4 text-gray-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total_reports}</div>
            <p className="text-xs text-muted-foreground">All time</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending</CardTitle>
            <Clock className="h-4 w-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">{stats.pending_reports}</div>
            <p className="text-xs text-muted-foreground">Require attention</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Resolved</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.resolved_reports}</div>
            <p className="text-xs text-muted-foreground">Closed reports</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Dismissed</CardTitle>
            <XCircle className="h-4 w-4 text-gray-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.dismissed_reports}</div>
            <p className="text-xs text-muted-foreground">Not actionable</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
        <div className="flex flex-1 items-center space-x-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
            <Input
              placeholder="Search reports..."
              value={filters.search || ''}
              onChange={(e) => setFilters({ ...filters, search: e.target.value })}
              className="pl-10 w-72"
            />
          </div>
          <select
            value={filters.report_type || 'all'}
            onChange={(e) => setFilters({ ...filters, report_type: e.target.value as any })}
            className="px-3 py-1 text-sm border border-gray-300 rounded-md bg-white"
          >
            <option value="all">All Types</option>
            <option value="ai_chatbot">AI Chatbot</option>
            <option value="ai_explanation">AI Explanation</option>
            <option value="hadith">Hadith</option>
          </select>
          <select
            value={filters.status || 'all'}
            onChange={(e) => setFilters({ ...filters, status: e.target.value as any })}
            className="px-3 py-1 text-sm border border-gray-300 rounded-md bg-white"
          >
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="reviewing">Reviewing</option>
            <option value="resolved">Resolved</option>
            <option value="dismissed">Dismissed</option>
          </select>
        </div>
        <div className="flex items-center space-x-2">
          {selectedReports.length > 0 && (
            <span className="text-sm text-gray-500">{selectedReports.length} selected</span>
          )}
          <Button variant="outline" className="text-black" size="sm">
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
        </div>
      </div>

      {/* Reports Table */}
      <Card>
        <CardHeader>
          <CardTitle>Reports ({reports.length})</CardTitle>
          <CardDescription>Review and moderate user-reported content</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">
                  <input
                    type="checkbox"
                    checked={selectedReports.length === reports.length && reports.length > 0}
                    onChange={handleSelectAll}
                    className="rounded border-gray-300"
                  />
                </TableHead>
                <TableHead>Report</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Reporter</TableHead>
                <TableHead>Admin Notes</TableHead>
                <TableHead>Created</TableHead>
                <TableHead className="w-12">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {reports.map((report) => (
                <TableRow key={report.id} className="cursor-pointer hover:bg-gray-50">
                  <TableCell>
                    <input
                      type="checkbox"
                      checked={selectedReports.includes(report.id)}
                      onChange={() => handleSelectReport(report.id)}
                      className="rounded border-gray-300"
                      onClick={(e) => e.stopPropagation()}
                    />
                  </TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>
                    <div className="space-y-1">
                      <div className="font-medium">{report.title}</div>
                      {report.description && (
                        <div className="text-sm text-gray-500 line-clamp-1">{report.description}</div>
                      )}
                    </div>
                  </TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>{getTypeBadge(report.report_type)}</TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>
                    <span className="text-sm">{getCategoryLabel(report.category)}</span>
                  </TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>{getStatusBadge(report.status)}</TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>
                    <div className="text-sm">
                      <div className="font-medium">
                        {report.reporter?.full_name || report.reporter?.email?.split('@')[0] || 'Anonymous'}
                      </div>
                      {report.reporter?.email && (
                        <div className="text-gray-500 text-xs truncate max-w-32">{report.reporter.email}</div>
                      )}
                    </div>
                  </TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>
                    {report.admin_notes ? (
                      <div className="text-xs text-blue-700 bg-blue-50 border border-blue-100 rounded px-2 py-1 max-w-36 truncate" title={report.admin_notes}>
                        {report.admin_notes}
                      </div>
                    ) : (
                      <span className="text-xs text-gray-400">—</span>
                    )}
                  </TableCell>
                  <TableCell onClick={() => handleOpenReport(report)}>
                    <div className="text-sm text-gray-500">{formatDateTime(new Date(report.created_at))}</div>
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" onClick={() => handleOpenReport(report)} className="h-8 w-8 p-0 text-blue-600">
                      <Eye className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {reports.length === 0 && (
            <div className="text-center py-12 text-gray-500">No reports found</div>
          )}
        </CardContent>
      </Card>

      {/* Report Details Modal */}
      {viewingReport && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            {/* Modal Header */}
            <div className="flex items-start justify-between p-6 border-b">
              <div>
                <h3 className="text-lg font-semibold text-gray-900">{viewingReport.title}</h3>
                <p className="text-xs text-gray-400 mt-1">ID: {viewingReport.id}</p>
              </div>
              <div className="flex items-center gap-2">
                {getStatusBadge(viewingReport.status)}
                <Button variant="ghost" size="sm" onClick={() => setViewingReport(null)} className="h-8 w-8 p-0">
                  <X className="h-4 w-4" />
                </Button>
              </div>
            </div>

            <div className="p-6 space-y-5">
              {/* Type, Category, Reporter */}
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Type</p>
                  {getTypeBadge(viewingReport.report_type)}
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Category</p>
                  <p className="text-sm text-gray-900">{getCategoryLabel(viewingReport.category)}</p>
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Reporter</p>
                  <p className="text-sm font-medium">{viewingReport.reporter?.full_name || 'Anonymous'}</p>
                  {viewingReport.reporter?.email && (
                    <p className="text-xs text-gray-500">{viewingReport.reporter.email}</p>
                  )}
                </div>
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Reported At</p>
                  <p className="text-sm text-gray-900">{formatDateTime(new Date(viewingReport.created_at))}</p>
                </div>
              </div>

              {/* Description */}
              {viewingReport.description && (
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Description</p>
                  <p className="text-sm text-gray-900 bg-gray-50 rounded p-3">{viewingReport.description}</p>
                </div>
              )}

              {/* Content Data */}
              {viewingReport.content_data && Object.keys(viewingReport.content_data).length > 0 && (
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Content Details</p>
                  <div className="bg-gray-50 rounded p-3 space-y-1">
                    {Object.entries(viewingReport.content_data).map(([key, value]) => (
                      value != null && (
                        <div key={key} className="flex gap-2 text-sm">
                          <span className="text-gray-500 capitalize min-w-24">{key.replace(/_/g, ' ')}:</span>
                          <span className="text-gray-900">{String(value)}</span>
                        </div>
                      )
                    ))}
                  </div>
                </div>
              )}

              {/* Context Data */}
              {viewingReport.context_data && Object.keys(viewingReport.context_data).length > 0 && (
                <div>
                  <p className="text-xs font-medium text-gray-500 uppercase mb-1">Context</p>
                  <div className="bg-gray-50 rounded p-3 space-y-1">
                    {Object.entries(viewingReport.context_data).map(([key, value]) => (
                      value != null && (
                        <div key={key} className="flex gap-2 text-sm">
                          <span className="text-gray-500 capitalize min-w-24">{key.replace(/_/g, ' ')}:</span>
                          <span className="text-gray-900 truncate">{String(value)}</span>
                        </div>
                      )
                    ))}
                  </div>
                </div>
              )}

              {/* Resolution Info */}
              {(viewingReport.status === 'resolved' || viewingReport.status === 'dismissed') && viewingReport.resolved_at && (
                <div className="bg-green-50 border border-green-200 rounded p-3">
                  <p className="text-xs font-medium text-green-700 uppercase mb-1">Resolution</p>
                  <p className="text-sm text-green-800">
                    {viewingReport.status === 'resolved' ? 'Resolved' : 'Dismissed'} on{' '}
                    {formatDateTime(new Date(viewingReport.resolved_at))}
                  </p>
                  {viewingReport.resolved_by && (
                    <p className="text-xs text-green-600 mt-0.5">By: {viewingReport.resolved_by}</p>
                  )}
                </div>
              )}

              {/* Admin Notes */}
              <div>
                <p className="text-xs font-medium text-gray-500 uppercase mb-1">Admin Notes</p>
                <textarea
                  value={adminNotes}
                  onChange={(e) => setAdminNotes(e.target.value)}
                  placeholder="Add notes about this report..."
                  className="w-full p-2 text-sm border border-gray-300 rounded-md focus:border-blue-500 focus:outline-none resize-none"
                  rows={3}
                />
                {adminNotes !== (viewingReport.admin_notes || '') && (
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={handleSaveNotes}
                    disabled={isUpdating}
                    className="mt-1"
                  >
                    Save Notes
                  </Button>
                )}
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex items-center justify-between gap-2 px-6 py-4 border-t bg-gray-50 rounded-b-lg">
              <div className="flex gap-2">
                {viewingReport.status !== 'reviewing' && (
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={isUpdating}
                    onClick={() => handleUpdateReport(viewingReport.id, { status: 'reviewing' })}
                    className="flex items-center gap-1"
                  >
                    <Eye className="h-3.5 w-3.5" />
                    Mark Reviewing
                  </Button>
                )}
                {viewingReport.status !== 'resolved' && (
                  <Button
                    size="sm"
                    disabled={isUpdating}
                    onClick={() => handleUpdateReport(viewingReport.id, {
                      status: 'resolved',
                      admin_notes: adminNotes || viewingReport.admin_notes || undefined
                    })}
                    className="bg-green-600 hover:bg-green-700 text-white flex items-center gap-1"
                  >
                    <CheckCircle className="h-3.5 w-3.5" />
                    Resolve
                  </Button>
                )}
                {viewingReport.status !== 'dismissed' && (
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={isUpdating}
                    onClick={() => handleUpdateReport(viewingReport.id, { status: 'dismissed' })}
                    className="text-red-600 border-red-300 hover:bg-red-50 flex items-center gap-1"
                  >
                    <XCircle className="h-3.5 w-3.5" />
                    Dismiss
                  </Button>
                )}
              </div>
              <Button variant="outline" size="sm" onClick={() => setViewingReport(null)}>
                Close
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
