'use client'

import AuthWrapper from '@/components/AuthWrapper'
import DashboardLayout from '@/app/dashboard/components/DashboardLayout'
import DonationsManagement from './components/DonationsManagement'
import { Toaster } from 'react-hot-toast'

export default function DonationsPage() {
  return (
    <AuthWrapper requireAdmin>
      {({ user, adminUser }) => (
        <DashboardLayout user={user} adminUser={adminUser}>
          <Toaster />
          <div className="space-y-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Donations</h1>
              <p className="text-gray-600 mt-2">
                Stripe Connect donation accounts and transaction history
              </p>
            </div>
            <DonationsManagement />
          </div>
        </DashboardLayout>
      )}
    </AuthWrapper>
  )
}
