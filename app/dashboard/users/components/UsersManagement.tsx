'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card'
import { Button } from '@/app/components/ui/button'
import { Input } from '@/app/components/ui/input'
import { Badge } from '@/app/components/ui/badge'
import {
  Search,
  Download,
  UserPlus,
  Crown,
  Calendar,
  Mail,
  Activity,
  ChevronLeft,
  ChevronRight,
  ChevronsLeft,
  ChevronsRight,
  Users,
  TrendingUp
} from 'lucide-react'
import { formatDateTime } from '@/lib/utils'
import UserActions from './UserActions'
import AddUserDialog from './AddUserDialog'
import type { UserProfile, UserStats } from '@/lib/types/users'

export default function UsersManagement() {
  const [users, setUsers] = useState<UserProfile[]>([])
  const [stats, setStats] = useState<UserStats>({
    total_users: 0,
    barakah_access_users: 0,
    quran_lite_users: 0,
    deenhub_pro_users: 0,
    free_users: 0,
    new_users_this_month: 0,
    active_users_last_30_days: 0
  })
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 10, // Set to 10 items per page
    total: 0,
    totalPages: 0
  })
  const [filters, setFilters] = useState({
    search: '',
    subscription_status: 'all',
    sort_by: 'created_at',
    sort_order: 'desc'
  })
  const [isLoading, setIsLoading] = useState(true)
  const [selectedUsers, setSelectedUsers] = useState<(string | number)[]>([])
  const [showAddDialog, setShowAddDialog] = useState(false)

  // Fetch users with pagination
  useEffect(() => {
    const fetchUsers = async () => {
      setIsLoading(true)

      try {
        const params = new URLSearchParams()
        params.set('page', pagination.page.toString())
        params.set('limit', '10') // Explicitly set limit to 10

        if (filters.search) params.set('search', filters.search)
        if (filters.subscription_status && filters.subscription_status !== 'all') {
          params.set('subscription_status', filters.subscription_status)
        }
        if (filters.sort_by) params.set('sort_by', filters.sort_by)
        if (filters.sort_order) params.set('sort_order', filters.sort_order)

        console.log('Fetching users with params:', params.toString())

        const response = await fetch(`/api/admin/users?${params.toString()}`)

        if (!response.ok) {
          throw new Error('Failed to fetch users')
        }

        const data = await response.json()
        console.log('Fetched data:', data)
        console.log('Pagination:', data.pagination)
        
        setUsers(data.users || [])
        setStats(data.stats || {
          total_users: 0,
          barakah_access_users: 0,
          quran_lite_users: 0,
          deenhub_pro_users: 0,
          free_users: 0,
          new_users_this_month: 0,
          active_users_last_30_days: 0
        })

        // FIX: Use stats.total_users as fallback if pagination.total is 0
        if (data.pagination) {
          const actualTotal = data.pagination.total || data.stats?.total_users || 0
          const totalPages = Math.ceil(actualTotal / 10)
          
          setPagination(prev => ({
            ...prev,
            total: actualTotal,
            totalPages: totalPages
          }))
          
          console.log('Updated pagination:', {
            page: pagination.page,
            limit: 10,
            total: actualTotal,
            totalPages: totalPages
          })
        }
      } catch (error) {
        console.error('Error fetching users:', error)
        setUsers([])
      } finally {
        setIsLoading(false)
      }
    }

    fetchUsers()
  }, [pagination.page, filters.subscription_status, filters.sort_by, filters.sort_order, filters.search])

  // Handle search with debounce
  useEffect(() => {
    const timer = setTimeout(() => {
      // Reset to page 1 when search changes
      setPagination(prev => ({ ...prev, page: 1 }))
    }, 500)

    return () => clearTimeout(timer)
  }, [filters.search])

  // Reset to page 1 when subscription filter changes
  useEffect(() => {
    setPagination(prev => ({ ...prev, page: 1 }))
  }, [filters.subscription_status])

  const getSubscriptionBadge = (status: string) => {
    switch (status) {
      case 'deenhub_pro':
        return (
          <Badge className="bg-purple-100 text-purple-700 border-purple-200 flex items-center gap-1">
            <Crown className="h-3 w-3" />
            DeenHub Pro
          </Badge>
        )
      case 'barakah_access':
        return (
          <Badge className="bg-emerald-100 text-emerald-700 border-emerald-200 flex items-center gap-1">
            <Crown className="h-3 w-3" />
            Barakah Access
          </Badge>
        )
      case 'quran_lite':
        return (
          <Badge className="bg-blue-100 text-blue-700 border-blue-200 flex items-center gap-1">
            <Crown className="h-3 w-3" />
            Quran Lite
          </Badge>
        )
      case 'expired':
        return <Badge variant="outline" className="text-orange-600 border-orange-300">Expired</Badge>
      default:
        return <Badge variant="outline" className="text-gray-600">Free</Badge>
    }
  }

  const handleSelectUser = (userId: string | number) => {
    setSelectedUsers(prev =>
      prev.includes(userId)
        ? prev.filter(id => id !== userId)
        : [...prev, userId]
    )
  }

  const handleSelectAll = () => {
    setSelectedUsers(
      selectedUsers.length === users.length
        ? []
        : users.map(user => user.id)
    )
  }

  const handlePageChange = (newPage: number) => {
    console.log('Changing to page:', newPage)
    setPagination(prev => ({ ...prev, page: newPage }))
    setSelectedUsers([])
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  const refreshUsers = async () => {
    setIsLoading(true)

    try {
      const params = new URLSearchParams()
      params.set('page', pagination.page.toString())
      params.set('limit', '10')

      if (filters.search) params.set('search', filters.search)
      if (filters.subscription_status && filters.subscription_status !== 'all') {
        params.set('subscription_status', filters.subscription_status)
      }
      if (filters.sort_by) params.set('sort_by', filters.sort_by)
      if (filters.sort_order) params.set('sort_order', filters.sort_order)

      const response = await fetch(`/api/admin/users?${params.toString()}`)

      if (!response.ok) {
        throw new Error('Failed to fetch users')
      }

      const data = await response.json()
      setUsers(data.users || [])
      setStats(data.stats || {
        total_users: 0,
        barakah_access_users: 0,
        quran_lite_users: 0,
        deenhub_pro_users: 0,
        free_users: 0,
        new_users_this_month: 0,
        active_users_last_30_days: 0
      })

      console.log(data)

      // FIX: Use stats.total_users as fallback if pagination.total is 0
      if (data.pagination) {
        const actualTotal = data.pagination.total || data.stats?.total_users || 0
        const totalPages = Math.ceil(actualTotal / 10)
        
        setPagination(prev => ({
          ...prev,
          total: actualTotal,
          totalPages: totalPages
        }))
      }
    } catch (error) {
      console.error('Error fetching users:', error)
      setUsers([])
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="space-y-6 p-6">
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
        <Card className="border-l-4 border-l-blue-500 hover:shadow-lg transition-shadow">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
              <Users className="h-4 w-4" />
              Total Users
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">
              {stats.total_users.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">All registered users</p>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-purple-500 hover:shadow-lg transition-shadow">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
              <Crown className="h-4 w-4 text-purple-600" />
              DeenHub Pro
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-purple-600">
              {stats.deenhub_pro_users.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {stats.total_users > 0 ? ((stats.deenhub_pro_users / stats.total_users) * 100).toFixed(1) : '0.0'}% of total
            </p>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-emerald-500 hover:shadow-lg transition-shadow">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
              <Crown className="h-4 w-4 text-emerald-600" />
              Barakah Access
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-emerald-600">
              {stats.barakah_access_users.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {stats.total_users > 0 ? ((stats.barakah_access_users / stats.total_users) * 100).toFixed(1) : '0.0'}% of total
            </p>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-blue-500 hover:shadow-lg transition-shadow">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
              <Crown className="h-4 w-4 text-blue-600" />
              Quran Lite
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-blue-600">
              {stats.quran_lite_users.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {stats.total_users > 0 ? ((stats.quran_lite_users / stats.total_users) * 100).toFixed(1) : '0.0'}% of total
            </p>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-gray-400 hover:shadow-lg transition-shadow">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
              <TrendingUp className="h-4 w-4" />
              Free Users
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-700">
              {stats.free_users.toLocaleString()}
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {stats.total_users > 0 ? ((stats.free_users / stats.total_users) * 100).toFixed(1) : '0.0'}% of total
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Filters and Actions */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col lg:flex-row gap-4 justify-between items-start lg:items-center">
            <div className="flex flex-col sm:flex-row flex-1 items-start sm:items-center gap-3 w-full lg:w-auto">
              <div className="relative w-full sm:w-96">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Search by name or email..."
                  value={filters.search}
                  onChange={(e) => setFilters({ ...filters, search: e.target.value })}
                  className="pl-10"
                />
              </div>

              <select
                value={filters.subscription_status}
                onChange={(e) => setFilters({ ...filters, subscription_status: e.target.value })}
                className="px-4 py-2 text-sm border border-gray-300 rounded-lg bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="all">All Subscriptions</option>
                <option value="free">Free</option>
                <option value="barakah_access">Barakah Access</option>
                <option value="quran_lite">Quran Lite</option>
                <option value="deenhub_pro">DeenHub Pro</option>
                <option value="expired">Expired</option>
              </select>
            </div>

            <div className="flex items-center gap-2">
              {selectedUsers.length > 0 && (
                <span className="text-sm text-gray-600 font-medium">
                  {selectedUsers.length} selected
                </span>
              )}
              <Button variant="outline" size="sm" className="gap-2">
                <Download className="h-4 w-4" />
                Export
              </Button>
              <Button size="sm" className="gap-2 bg-blue-600 hover:bg-blue-700" onClick={() => setShowAddDialog(true)}>
                <UserPlus className="h-4 w-4" />
                Add User
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Users Table */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-xl">Users Directory</CardTitle>
              <CardDescription className="mt-1">
                Showing {pagination.total > 0 ? ((pagination.page - 1) * 10) + 1 : 0} to {Math.min(pagination.page * 10, pagination.total)} of {pagination.total} users
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="rounded-lg border overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left w-12">
                    <input
                      type="checkbox"
                      checked={selectedUsers.length === users.length && users.length > 0}
                      onChange={handleSelectAll}
                      className="rounded border-gray-300 cursor-pointer"
                    />
                  </th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">User</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Subscription</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">AI Usage</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Last Active</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Joined</th>
                  <th className="px-4 py-3 text-left text-xs font-semibold text-gray-700 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {isLoading ? (
                  [...Array(10)].map((_, i) => (
                    <tr key={i}>
                      <td colSpan={7} className="px-4 py-4">
                        <div className="h-16 bg-gray-100 rounded animate-pulse"></div>
                      </td>
                    </tr>
                  ))
                ) : users.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-4 py-12 text-center">
                      <div className="flex flex-col items-center justify-center text-gray-500">
                        <Users className="h-12 w-12 mb-2 text-gray-400" />
                        <p className="font-medium">No users found</p>
                        <p className="text-sm">Try adjusting your search or filters</p>
                      </div>
                    </td>
                  </tr>
                ) : (
                  users.map((user) => (
                    <tr key={user.id} className="hover:bg-gray-50">
                      <td className="px-4 py-4">
                        <input
                          type="checkbox"
                          checked={selectedUsers.includes(user.id)}
                          onChange={() => handleSelectUser(user.id)}
                          className="rounded border-gray-300 cursor-pointer"
                        />
                      </td>
                      <td className="px-4 py-4">
                        <div className="flex items-center gap-3">
                          <div className="h-10 w-10 bg-gradient-to-br from-blue-400 to-purple-500 rounded-full flex items-center justify-center text-white font-semibold shadow-sm flex-shrink-0">
                            {user.auth_user?.raw_user_meta_data?.picture ? (
                              <img
                                src={user.auth_user.raw_user_meta_data.picture}
                                alt="Avatar"
                                className="h-10 w-10 rounded-full object-cover"
                              />
                            ) : (
                              <span className="text-sm">
                                {user.full_name?.[0] || user.email[0].toUpperCase()}
                              </span>
                            )}
                          </div>
                          <div className="min-w-0">
                            <div className="font-medium text-gray-900 truncate">
                              {user.full_name || 'No name'}
                            </div>
                            <div className="text-sm text-gray-500 flex items-center gap-1 truncate">
                              <Mail className="h-3 w-3 flex-shrink-0" />
                              {user.email}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <div className="space-y-1">
                          {getSubscriptionBadge(user.subscription_status)}
                          {user.subscription_expiry && (
                            <div className="text-xs text-gray-500 flex items-center gap-1">
                              <Calendar className="h-3 w-3" />
                              Expires {formatDateTime(new Date(user.subscription_expiry))}
                            </div>
                          )}
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <div className="text-sm">
                          <div className="font-medium text-gray-900">
                            {(user?.ai_usage_data?.monthly_tokens ?? 0).toLocaleString()} tokens
                          </div>
                          <div className="text-gray-500">
                            ${(user?.ai_usage_data?.estimated_cost_this_month ?? 0).toFixed(2)} this month
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        {user.auth_user?.last_sign_in_at ? (
                          <div className="flex items-center gap-1 text-sm text-gray-600">
                            <Activity className="h-3 w-3 text-green-500" />
                            {formatDateTime(new Date(user.auth_user.last_sign_in_at))}
                          </div>
                        ) : (
                          <span className="text-sm text-gray-400">Never</span>
                        )}
                      </td>
                      <td className="px-4 py-4">
                        <div className="text-sm text-gray-500">
                          {formatDateTime(new Date(user.created_at))}
                        </div>
                      </td>
                      <td className="px-4 py-4">
                        <UserActions
                          user={user}
                          onUserUpdate={(updatedUser) => {
                            const updatedUsers = users.map(u => u.id === updatedUser.id ? updatedUser : u)
                            setUsers(updatedUsers)
                          }}
                          onDelete={refreshUsers}
                        />
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>

          {/* Pagination Controls */}
          {pagination.total > 10 && (
            <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mt-6">
              <div className="text-sm text-gray-600">
                Page {pagination.page} of {pagination.totalPages || 1} (10 items per page)
              </div>

              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handlePageChange(1)}
                  disabled={pagination.page === 1}
                  className="h-9 w-9 p-0"
                  title="First page"
                >
                  <ChevronsLeft className="h-4 w-4" />
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handlePageChange(pagination.page - 1)}
                  disabled={pagination.page === 1}
                  className="h-9 w-9 p-0"
                  title="Previous page"
                >
                  <ChevronLeft className="h-4 w-4" />
                </Button>

                <div className="flex items-center gap-1">
                  {[...Array(Math.min(5, pagination.totalPages))].map((_, i) => {
                    const totalPages = pagination.totalPages
                    let pageNum;
                    
                    if (totalPages <= 5) {
                      pageNum = i + 1;
                    } else if (pagination.page <= 3) {
                      pageNum = i + 1;
                    } else if (pagination.page >= totalPages - 2) {
                      pageNum = totalPages - 4 + i;
                    } else {
                      pageNum = pagination.page - 2 + i;
                    }

                    return (
                      <Button
                        key={pageNum}
                        variant={pagination.page === pageNum ? "default" : "outline"}
                        size="sm"
                        onClick={() => handlePageChange(pageNum)}
                        className="h-9 w-9 p-0"
                      >
                        {pageNum}
                      </Button>
                    );
                  })}
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handlePageChange(pagination.page + 1)}
                  disabled={pagination.page === pagination.totalPages}
                  className="h-9 w-9 p-0"
                  title="Next page"
                >
                  <ChevronRight className="h-4 w-4" />
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handlePageChange(pagination.totalPages)}
                  disabled={pagination.page === pagination.totalPages}
                  className="h-9 w-9 p-0"
                  title="Last page"
                >
                  <ChevronsRight className="h-4 w-4" />
                </Button>
              </div>

              <div className="text-sm text-gray-600">
                Showing {pagination.total > 0 ? ((pagination.page - 1) * 10) + 1 : 0}-{Math.min(pagination.page * 10, pagination.total)} of {pagination.total}
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Add User Dialog */}
      <AddUserDialog
        isOpen={showAddDialog}
        onClose={() => setShowAddDialog(false)}
        onSuccess={() => {
          setShowAddDialog(false)
          refreshUsers()
        }}
      />
    </div>
  )
}

 