'use client'

import { useState } from 'react'
import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { Button } from '@/app/components/ui/button'
import { Card, CardContent } from '@/app/components/ui/card'
import type { AuthUser, AdminUser } from '@/lib/types/auth'
import { 
  LayoutDashboard, 
  Users, 
  MessageSquareWarning, 
  BookOpen, 
  MapPin, 
  LogOut,
  Menu,
  X,
  AlarmClock
} from 'lucide-react'
import { signOutClient } from '@/lib/auth-client'
import NotificationBell from './NotificationBell'

interface DashboardLayoutProps {
  children: React.ReactNode
  user: AuthUser
  adminUser: AdminUser
}

const navigationItems = [
  {
    name: 'Dashboard',
    href: '/dashboard',
    icon: LayoutDashboard,
  },
  {
    name: 'Users',
    href: '/dashboard/users',
    icon: Users,
  },
  {
    name: 'Reports',
    href: '/dashboard/reports',
    icon: MessageSquareWarning,
  },
  {
    name: 'Quran Requests',
    href: '/dashboard/quran-requests',
    icon: BookOpen,
  },
  {
    name: 'Mosques',
    href: '/dashboard/mosques',
    icon: MapPin,
  },
  {
    name: 'Send Push Notification',
    href: '/dashboard/notifications',
    icon: AlarmClock,
  },
]

export default function DashboardLayout({ children, user, adminUser }: DashboardLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const pathname = usePathname()
  const router = useRouter()

  const handleSignOut = async () => {
    try {
      await signOutClient()
      router.push('/login')
    } catch (error) {
      console.error('Sign out error:', error)
      // Force redirect even if signOut fails
      router.push('/login')
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar backdrop */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`
        fixed inset-y-0 left-0 z-50 w-72 bg-white shadow-xl border-r border-gray-200 transition-transform duration-300 ease-in-out lg:translate-x-0 
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <div className="flex h-full flex-col">
          {/* Logo Section */}
          <div className="flex h-16 items-center justify-between px-6 border-b border-gray-200 bg-gradient-to-r from-emerald-600 to-green-600">
            <div className="flex items-center">
              <div className="h-10 w-10 bg-white/20 rounded-xl flex items-center justify-center backdrop-blur">
                <span className="text-white font-bold text-lg">DH</span>
              </div>
              <div className="ml-3">
                <h1 className="text-lg font-bold text-white">DeenHub</h1>
                <p className="text-xs text-emerald-100">Admin Dashboard</p>
              </div>
            </div>
            <Button
              variant="ghost"
              size="icon"
              className="lg:hidden text-white hover:bg-white/10"
              onClick={() => setSidebarOpen(false)}
            >
              <X className="h-5 w-5" />
            </Button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
            <div className="mb-4">
              <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider px-3 mb-3">
                MAIN MENU
              </p>
              {navigationItems.map((item) => {
                const isActive = pathname === item.href
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={`
                      group flex items-center px-3 py-3 text-sm font-medium rounded-xl transition-all duration-200
                      ${isActive
                        ? 'bg-emerald-50 text-emerald-700 border-l-4 border-emerald-500 shadow-sm'
                        : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900 border-l-4 border-transparent hover:border-gray-200'
                      }
                    `}
                    onClick={() => setSidebarOpen(false)}
                  >
                    <item.icon className={`mr-4 h-5 w-5 transition-colors ${
                      isActive ? 'text-emerald-600' : 'text-gray-400 group-hover:text-gray-600'
                    }`} />
                    <span className="truncate">{item.name}</span>
                    {isActive && (
                      <div className="ml-auto">
                        <div className="h-2 w-2 bg-emerald-500 rounded-full"></div>
                      </div>
                    )}
                  </Link>
                )
              })}
            </div>
          </nav>

          {/* User Profile Section */}
          <div className="border-t border-gray-200 p-4 bg-gray-50">
            <div className="flex items-center mb-4">
              <div className="h-12 w-12 bg-gradient-to-r from-emerald-500 to-green-500 rounded-xl flex items-center justify-center shadow-md">
                {user.raw_user_meta_data.avatar_url || user.raw_user_meta_data.picture ? (
                  <img
                    src={user.raw_user_meta_data.avatar_url || user.raw_user_meta_data.picture}
                    alt="Profile"
                    className="h-12 w-12 rounded-xl object-cover"
                  />
                ) : (
                  <span className="text-white font-bold text-lg">
                    {(user.raw_user_meta_data.full_name || user.raw_user_meta_data.name || user.email)?.[0]?.toUpperCase()}
                  </span>
                )}
              </div>
              <div className="ml-3 flex-1 min-w-0">
                <p className="text-sm font-semibold text-gray-900 truncate">
                  {user.raw_user_meta_data.full_name || user.raw_user_meta_data.name || user.email}
                </p>
                <div className="flex items-center gap-2">
                  <div className="h-2 w-2 bg-green-500 rounded-full"></div>
                  <p className="text-xs text-gray-500 capitalize">
                    {adminUser.role.replace('_', ' ')}
                  </p>
                </div>
              </div>
            </div>
            <Button
              variant="outline"
              size="sm"
              className="w-full bg-white hover:bg-gray-50 border-gray-200 shadow-sm"
              onClick={handleSignOut}
            >
              <LogOut className="mr-2 h-4 w-4" />
              Sign Out
            </Button>
          </div>
        </div>
      </aside>

      {/* Main content area */}
      <div className="lg:pl-72">
        {/* Top Header */}
        <header className="bg-white/80 backdrop-blur-sm border-b border-gray-200 sticky top-0 z-30 shadow-sm">
        
          <div className="flex h-16 items-center justify-between px-6">
            <div className="flex items-center gap-4">
              <Button
                variant="ghost"
                size="icon"
                className="lg:hidden hover:bg-gray-100"
                onClick={() => setSidebarOpen(true)}
              >
                <Menu className="h-5 w-5" />
                
              </Button>
              <div className="hidden sm:block">
                <h2 className="text-lg font-semibold text-gray-900">
                  {navigationItems.find(item => item.href === pathname)?.name || 'Dashboard'}
                  
                </h2>
              </div>
            </div>
            
            <div className="flex items-center gap-4">
              <div className="hidden md:flex items-center gap-2 px-3 py-1 bg-emerald-50 rounded-full">
                <div className="h-2 w-2 bg-emerald-500 rounded-full animate-pulse"></div>
                <span className="text-xs font-medium text-emerald-700">
                  {adminUser.role.replace('_', ' ')}

                  
                </span>

                <NotificationBell />
              </div>
            </div>
          </div>
        </header>

        {/* Page content with proper spacing */}
        <main className="min-h-[calc(100vh-4rem)] bg-gray-50">
          <div className="p-6 lg:p-8">
            {children}
          </div>
        </main>
      </div>
    </div>
  )
} 