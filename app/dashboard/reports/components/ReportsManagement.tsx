// 'use client'

// import { useState, useEffect } from 'react'
// import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card'
// import { Button } from '@/app/components/ui/button'
// import { Input } from '@/app/components/ui/input'
// import { Badge } from '@/app/components/ui/badge'
// import {
//   Table,
//   TableBody,
//   TableCell,
//   TableHead,
//   TableHeader,
//   TableRow,
// } from '@/app/components/ui/table'
// import type { Report, ReportFilters, ReportStats, ReportType, ReportStatus, ReportCategory } from '@/lib/types/reports'
// import { 
//   Search, 
//   Filter, 
//   Download, 
//   AlertTriangle, 
//   MessageSquareWarning,
//   BookOpen,
//   Bot,
//   Clock,
//   CheckCircle,
//   XCircle,
//   Eye,
//   MoreHorizontal
// } from 'lucide-react'
// import { formatDateTime } from '@/lib/utils'

// export default function ReportsManagement() {
//   const [reports, setReports] = useState<Report[]>([])
//   const [stats, setStats] = useState<ReportStats>({
//     total_reports: 0,
//     pending_reports: 0,
//     reviewing_reports: 0,
//     resolved_reports: 0,
//     dismissed_reports: 0,
//     reports_this_week: 0,
//     avg_resolution_time_hours: 0,
//     by_type: {
//       ai_chatbot: 0,
//       ai_explanation: 0,
//       hadith: 0
//     },
//     by_category: {
//       incorrect_information: 0,
//       inappropriate_content: 0,
//       misleading_guidance: 0,
//       technical_error: 0,
//       inconsistency: 0,
//       offensive_content: 0,
//       other: 0
//     }
//   })
//   const [filters, setFilters] = useState<ReportFilters>({
//     search: '',
//     report_type: 'all',
//     status: 'all',
//     sort_by: 'created_at',
//     sort_order: 'desc'
//   })
//   const [isLoading, setIsLoading] = useState(true)
//   const [selectedReports, setSelectedReports] = useState<string[]>([])

//   const fetchReports = async () => {
//     try {
//       setIsLoading(true)
      
//       // Build query parameters
//       const params = new URLSearchParams()
//       if (filters.status && filters.status !== 'all') {
//         params.set('status', filters.status)
//       }
//       if (filters.search) {
//         params.set('search', filters.search)
//       }
//       if (filters.report_type && filters.report_type !== 'all') {
//         params.set('report_type', filters.report_type)
//       }

//       // Call the actual API
//       const response = await fetch(`/api/admin/reports?${params.toString()}`)
      
//       if (!response.ok) {
//         throw new Error('Failed to fetch reports')
//       }

//       const data = await response.json()
//       setReports(data.reports || [])
      
//       // Calculate additional stats from reports data
//       const reportsByType = (data.reports || []).reduce((acc: any, report: any) => {
//         acc[report.report_type] = (acc[report.report_type] || 0) + 1
//         return acc
//       }, {})

//       const reportsByCategory = (data.reports || []).reduce((acc: any, report: any) => {
//         acc[report.category] = (acc[report.category] || 0) + 1
//         return acc
//       }, {})

//       // Map API stats to component stats format
//       setStats({
//         total_reports: data.stats?.total_reports || 0,
//         pending_reports: data.stats?.pending_reports || 0,
//         reviewing_reports: data.stats?.reviewed_reports || 0,
//         resolved_reports: data.stats?.resolved_reports || 0,
//         dismissed_reports: data.stats?.dismissed_reports || 0,
//         reports_this_week: 0, // Could calculate from created_at if needed
//         avg_resolution_time_hours: 0, // Could calculate if needed
//         by_type: {
//           ai_chatbot: reportsByType.ai_chatbot || 0,
//           ai_explanation: reportsByType.ai_explanation || 0,
//           hadith: reportsByType.hadith || 0
//         },
//         by_category: {
//           incorrect_information: reportsByCategory.incorrect_information || 0,
//           inappropriate_content: reportsByCategory.inappropriate_content || 0,
//           misleading_guidance: reportsByCategory.misleading_guidance || 0,
//           technical_error: reportsByCategory.technical_error || 0,
//           inconsistency: reportsByCategory.inconsistency || 0,
//           offensive_content: reportsByCategory.offensive_content || 0,
//           other: reportsByCategory.other || 0
//         }
//       })
//     } catch (error) {
//       console.error('Error fetching reports:', error)
//       setReports([])
//     } finally {
//       setIsLoading(false)
//     }
//   }

//   useEffect(() => {
//     fetchReports()
//   }, [filters])

//   const getTypeIcon = (type: ReportType) => {
//     switch (type) {
//       case 'ai_chatbot':
//         return <Bot className="h-4 w-4" />
//       case 'ai_explanation':
//         return <MessageSquareWarning className="h-4 w-4" />
//       case 'hadith':
//         return <BookOpen className="h-4 w-4" />
//     }
//   }

//   const getTypeBadge = (type: ReportType) => {
//     const configs = {
//       ai_chatbot: { variant: 'default' as const, label: 'AI Chat' },
//       ai_explanation: { variant: 'secondary' as const, label: 'AI Explanation' },
//       hadith: { variant: 'outline' as const, label: 'Hadith' }
//     }
    
//     const config = configs[type]
//     return (
//       <Badge variant={config.variant} className="flex items-center gap-1">
//         {getTypeIcon(type)}
//         {config.label}
//       </Badge>
//     )
//   }

//   const getStatusBadge = (status: ReportStatus) => {
//     switch (status) {
//       case 'pending':
//         return <Badge variant="warning" className="flex items-center gap-1">
//           <Clock className="h-3 w-3" />
//           Pending
//         </Badge>
//       case 'reviewing':
//         return <Badge variant="default" className="flex items-center gap-1">
//           <Eye className="h-3 w-3" />
//           Reviewing
//         </Badge>
//       case 'resolved':
//         return <Badge variant="success" className="flex items-center gap-1">
//           <CheckCircle className="h-3 w-3" />
//           Resolved
//         </Badge>
//       case 'dismissed':
//         return <Badge variant="secondary" className="flex items-center gap-1">
//           <XCircle className="h-3 w-3" />
//           Dismissed
//         </Badge>
//     }
//   }

//   const getCategoryLabel = (category: ReportCategory) => {
//     return category.split('_').map(word => 
//       word.charAt(0).toUpperCase() + word.slice(1)
//     ).join(' ')
//   }

//   const handleSelectReport = (reportId: string) => {
//     setSelectedReports(prev => 
//       prev.includes(reportId) 
//         ? prev.filter(id => id !== reportId)
//         : [...prev, reportId]
//     )
//   }

//   const handleSelectAll = () => {
//     setSelectedReports(
//       selectedReports.length === reports.length 
//         ? [] 
//         : reports.map(report => report.id)
//     )
//   }

//   if (isLoading) {
//     return (
//       <div className="space-y-6">
//         {/* Stats Cards Loading */}
//         <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
//           {[...Array(4)].map((_, i) => (
//             <Card key={i} className="animate-pulse">
//               <CardHeader className="pb-2">
//                 <div className="h-4 bg-gray-200 rounded w-3/4"></div>
//               </CardHeader>
//               <CardContent>
//                 <div className="h-8 bg-gray-200 rounded w-1/2 mb-2"></div>
//                 <div className="h-3 bg-gray-200 rounded w-full"></div>
//               </CardContent>
//             </Card>
//           ))}
//         </div>
//         {/* Table Loading */}
//         <Card>
//           <CardHeader>
//             <div className="h-6 bg-gray-200 rounded w-1/4 animate-pulse"></div>
//             <div className="h-4 bg-gray-200 rounded w-1/2 animate-pulse"></div>
//           </CardHeader>
//           <CardContent>
//             <div className="space-y-4">
//               {[...Array(5)].map((_, i) => (
//                 <div key={i} className="h-12 bg-gray-200 rounded animate-pulse"></div>
//               ))}
//             </div>
//           </CardContent>
//         </Card>
//       </div>
//     )
//   }

//   return (
//     <div className="space-y-6">
//       {/* Stats Cards */}
//       <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
//         <Card>
//           <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
//             <CardTitle className="text-sm font-medium">Total Reports</CardTitle>
//             <AlertTriangle className="h-4 w-4 text-gray-500" />
//           </CardHeader>
//           <CardContent>
//             <div className="text-2xl font-bold">{stats.total_reports}</div>
//             <p className="text-xs text-muted-foreground">All time</p>
//           </CardContent>
//         </Card>

//         <Card>
//           <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
//             <CardTitle className="text-sm font-medium">Pending</CardTitle>
//             <Clock className="h-4 w-4 text-orange-500" />
//           </CardHeader>
//           <CardContent>
//             <div className="text-2xl font-bold text-orange-600">{stats.pending_reports}</div>
//             <p className="text-xs text-muted-foreground">Require attention</p>
//           </CardContent>
//         </Card>

//         <Card>
//           <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
//             <CardTitle className="text-sm font-medium">This Week</CardTitle>
//             <AlertTriangle className="h-4 w-4 text-blue-500" />
//           </CardHeader>
//           <CardContent>
//             <div className="text-2xl font-bold">{stats.reports_this_week}</div>
//             <p className="text-xs text-muted-foreground">New reports</p>
//           </CardContent>
//         </Card>

//         <Card>
//           <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
//             <CardTitle className="text-sm font-medium">Avg Resolution</CardTitle>
//             <CheckCircle className="h-4 w-4 text-green-500" />
//           </CardHeader>
//           <CardContent>
//             <div className="text-2xl font-bold">{stats.avg_resolution_time_hours.toFixed(1)}h</div>
//             <p className="text-xs text-muted-foreground">Resolution time</p>
//           </CardContent>
//         </Card>
//       </div>

//       {/* Filters and Actions */}
//       <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
//         <div className="flex flex-1 items-center space-x-2">
//           <div className="relative">
//             <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
//             <Input
//               placeholder="Search reports by title or description..."
//               value={filters.search || ''}
//               onChange={(e) => setFilters({...filters, search: e.target.value})}
//               className="pl-10 w-80"
//             />
//           </div>
          
//           <select
//             value={filters.report_type || 'all'}
//             onChange={(e) => setFilters({
//               ...filters,
//               report_type: e.target.value as any
//             })}
//             className="px-3 py-1 text-sm border border-gray-300 rounded-md bg-white"
//           >
//             <option value="all">All Types</option>
//             <option value="ai_chatbot">AI Chatbot</option>
//             <option value="ai_explanation">AI Explanation</option>
//             <option value="hadith">Hadith</option>
//           </select>

//           <select
//             value={filters.status || 'all'}
//             onChange={(e) => setFilters({
//               ...filters,
//               status: e.target.value as any
//             })}
//             className="px-3 py-1 text-sm border border-gray-300 rounded-md bg-white"
//           >
//             <option value="all">All Status</option>
//             <option value="pending">Pending</option>
//             <option value="reviewing">Reviewing</option>
//             <option value="resolved">Resolved</option>
//             <option value="dismissed">Dismissed</option>
//           </select>
//         </div>
        
//         <div className="flex items-center space-x-2">
//           {selectedReports.length > 0 && (
//             <span className="text-sm text-gray-500">
//               {selectedReports.length} selected
//             </span>
//           )}
//           <Button variant="outline" size="sm">
//             <Download className="mr-2 h-4 w-4" />
//             Export
//           </Button>
//         </div>
//       </div>

//       {/* Reports Table */}
//       <Card>
//         <CardHeader>
//           <CardTitle>Reports ({reports.length})</CardTitle>
//           <CardDescription>
//             Review and moderate user-reported content
//           </CardDescription>
//         </CardHeader>
//         <CardContent>
//           <Table>
//             <TableHeader>
//               <TableRow>
//                 <TableHead className="w-12">
//                   <input
//                     type="checkbox"
//                     checked={selectedReports.length === reports.length}
//                     onChange={handleSelectAll}
//                     className="rounded border-gray-300"
//                   />
//                 </TableHead>
//                 <TableHead>Report</TableHead>
//                 <TableHead>Type</TableHead>
//                 <TableHead>Category</TableHead>
//                 <TableHead>Status</TableHead>
//                 <TableHead>Reporter</TableHead>
//                 <TableHead>Created</TableHead>
//                 <TableHead className="w-12">Actions</TableHead>
//               </TableRow>
//             </TableHeader>
//             <TableBody>
//               {reports.map((report) => (
//                 <TableRow key={report.id}>
//                   <TableCell>
//                     <input
//                       type="checkbox"
//                       checked={selectedReports.includes(report.id)}
//                       onChange={() => handleSelectReport(report.id)}
//                       className="rounded border-gray-300"
//                     />
//                   </TableCell>
//                   <TableCell>
//                     <div className="space-y-1">
//                       <div className="font-medium">{report.title}</div>
//                       {report.description && (
//                         <div className="text-sm text-gray-500 line-clamp-2">
//                           {report.description}
//                         </div>
//                       )}
//                     </div>
//                   </TableCell>
//                   <TableCell>
//                     {getTypeBadge(report.report_type)}
//                   </TableCell>
//                   <TableCell>
//                     <span className="text-sm">
//                       {getCategoryLabel(report.category)}
//                     </span>
//                   </TableCell>
//                   <TableCell>
//                     {getStatusBadge(report.status)}
//                   </TableCell>
//                   <TableCell>
//                     <div className="text-sm">
//                       <div className="font-medium">
//                         {report.reporter?.full_name || 'Anonymous'}
//                       </div>
//                       <div className="text-gray-500">
//                         {report.reporter?.email}
//                       </div>
//                     </div>
//                   </TableCell>
//                   <TableCell>
//                     <div className="text-sm text-gray-500">
//                       {formatDateTime(new Date(report.created_at))}
//                     </div>
//                   </TableCell>
//                   <TableCell>
//                     <Button variant="ghost" size="sm">
//                       <MoreHorizontal className="h-4 w-4" />
//                     </Button>
//                   </TableCell>
//                 </TableRow>
//               ))}
//             </TableBody>
//           </Table>

//           {reports.length === 0 && (
//             <div className="text-center py-12">
//               <div className="text-gray-500">No reports found</div>
//             </div>
//           )}
//         </CardContent>
//       </Card>
//     </div>
//   )
// } 










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
  Filter, 
  Download, 
  AlertTriangle, 
  MessageSquareWarning,
  BookOpen,
  Bot,
  Clock,
  CheckCircle,
  XCircle,
  Eye,
  MoreHorizontal
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
    by_type: {
      ai_chatbot: 0,
      ai_explanation: 0,
      hadith: 0
    },
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

  const fetchReports = async () => {
    try {
      setIsLoading(true)
      
      // Build query parameters
      const params = new URLSearchParams()
      if (filters.status && filters.status !== 'all') {
        params.set('status', filters.status)
      }
      if (filters.search) {
        params.set('search', filters.search)
      }
      if (filters.report_type && filters.report_type !== 'all') {
        params.set('report_type', filters.report_type)
      }

      // Call the actual API
      const response = await fetch(`/api/admin/reports?${params.toString()}`)
      
      if (!response.ok) {
        throw new Error('Failed to fetch reports')
      }

      const data = await response.json()
      setReports(data.reports || [])
      
      // Calculate additional stats from reports data
      const reportsByType = (data.reports || []).reduce((acc: any, report: any) => {
        acc[report.report_type] = (acc[report.report_type] || 0) + 1
        return acc
      }, {})

      const reportsByCategory = (data.reports || []).reduce((acc: any, report: any) => {
        acc[report.category] = (acc[report.category] || 0) + 1
        return acc
      }, {})

      // Map API stats to component stats format
      setStats({
        total_reports: data.stats?.total_reports || 0,
        pending_reports: data.stats?.pending_reports || 0,
        reviewing_reports: data.stats?.reviewed_reports || 0,
        resolved_reports: data.stats?.resolved_reports || 0,
        dismissed_reports: data.stats?.dismissed_reports || 0,
        reports_this_week: 0, // Could calculate from created_at if needed
        avg_resolution_time_hours: 0, // Could calculate if needed
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

  useEffect(() => {
    fetchReports()
  }, [filters])

  const getTypeIcon = (type: ReportType) => {
    switch (type) {
      case 'ai_chatbot':
        return <Bot className="h-4 w-4" />
      case 'ai_explanation':
        return <MessageSquareWarning className="h-4 w-4" />
      case 'hadith':
        return <BookOpen className="h-4 w-4" />
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
        return <Badge variant="warning" className="flex items-center gap-1">
          <Clock className="h-3 w-3" />
          Pending
        </Badge>
      case 'reviewing':
        return <Badge variant="default" className="flex items-center gap-1">
          <Eye className="h-3 w-3" />
          Reviewing
        </Badge>
      case 'resolved':
        return <Badge variant="success" className="flex items-center gap-1">
          <CheckCircle className="h-3 w-3" />
          Resolved
        </Badge>
      case 'dismissed':
        return <Badge variant="secondary" className="flex items-center gap-1">
          <XCircle className="h-3 w-3" />
          Dismissed
        </Badge>
    }
  }

  const getCategoryLabel = (category: ReportCategory) => {
    return category.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ')
  }

  const handleSelectReport = (reportId: string) => {
    setSelectedReports(prev => 
      prev.includes(reportId) 
        ? prev.filter(id => id !== reportId)
        : [...prev, reportId]
    )
  }

  const handleSelectAll = () => {
    setSelectedReports(
      selectedReports.length === reports.length 
        ? [] 
        : reports.map(report => report.id)
    )
  }

  if (isLoading) {
    return (
      <div className="space-y-6">
        {/* Stats Cards Loading */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i} className="animate-pulse">
              <CardHeader className="pb-2">
                <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              </CardHeader>
              <CardContent>
                <div className="h-8 bg-gray-200 rounded w-1/2 mb-2"></div>
                <div className="h-3 bg-gray-200 rounded w-full"></div>
              </CardContent>
            </Card>
          ))}
        </div>
        {/* Table Loading */}
        <Card>
          <CardHeader>
            <div className="h-6 bg-gray-200 rounded w-1/4 animate-pulse"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2 animate-pulse"></div>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-12 bg-gray-200 rounded animate-pulse"></div>
              ))}
            </div>
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
            <CardTitle className="text-sm font-medium">This Week</CardTitle>
            <AlertTriangle className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.reports_this_week}</div>
            <p className="text-xs text-muted-foreground">New reports</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Avg Resolution</CardTitle>
            <CheckCircle className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.avg_resolution_time_hours.toFixed(1)}h</div>
            <p className="text-xs text-muted-foreground">Resolution time</p>
          </CardContent>
        </Card>
      </div>

      {/* Filters and Actions */}
      <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
        <div className="flex flex-1 items-center space-x-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
            <Input
              placeholder="Search reports by title or description..."
              value={filters.search || ''}
              onChange={(e) => setFilters({...filters, search: e.target.value})}
              className="pl-10 w-80"
            />
          </div>
          
          <select
            value={filters.report_type || 'all'}
            onChange={(e) => setFilters({
              ...filters,
              report_type: e.target.value as any
            })}
            className="px-3 py-1 text-sm border border-gray-300 rounded-md bg-white"
          >
            <option value="all">All Types</option>
            <option value="ai_chatbot">AI Chatbot</option>
            <option value="ai_explanation">AI Explanation</option>
            <option value="hadith">Hadith</option>
          </select>

          <select
            value={filters.status || 'all'}
            onChange={(e) => setFilters({
              ...filters,
              status: e.target.value as any
            })}
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
            <span className="text-sm text-gray-500">
              {selectedReports.length} selected
            </span>
          )}
          <Button variant="outline" className='text-black' size="sm">
            <Download className="mr-2 h-4 w-4" />
            Export
          </Button>
        </div>
      </div>

      {/* Reports Table */}
      <Card>
        <CardHeader>
          <CardTitle>Reports ({reports.length})</CardTitle>
          <CardDescription>
            Review and moderate user-reported content
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-12">
                  <input
                    type="checkbox"
                    checked={selectedReports.length === reports.length}
                    onChange={handleSelectAll}
                    className="rounded border-gray-300"
                  />
                </TableHead>
                <TableHead>Report</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Reporter</TableHead>
                <TableHead>Created</TableHead>
                <TableHead className="w-12">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {reports.map((report) => (
                <TableRow key={report.id}>
                  <TableCell>
                    <input
                      type="checkbox"
                      checked={selectedReports.includes(report.id)}
                      onChange={() => handleSelectReport(report.id)}
                      className="rounded border-gray-300"
                    />
                  </TableCell>
                  <TableCell>
                    <div className="space-y-1">
                      <div className="font-medium">{report.title}</div>
                      {report.description && (
                        <div className="text-sm text-gray-500 line-clamp-2">
                          {report.description}
                        </div>
                      )}
                    </div>
                  </TableCell>
                  <TableCell>
                    {getTypeBadge(report.report_type)}
                  </TableCell>
                  <TableCell>
                    <span className="text-sm">
                      {getCategoryLabel(report.category)}
                    </span>
                  </TableCell>
                  <TableCell>
                    {getStatusBadge(report.status)}
                  </TableCell>
                  <TableCell>
                    <div className="text-sm">
                      <div className="font-medium">
                        {report.reporter?.full_name || 'Anonymous'}
                      </div>
                      <div className="text-gray-500">
                        {report.reporter?.email}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="text-sm text-gray-500">
                      {formatDateTime(new Date(report.created_at))}
                    </div>
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm">
                      <MoreHorizontal className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>

          {reports.length === 0 && (
            <div className="text-center py-12">
              <div className="text-gray-500">No reports found</div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
} 