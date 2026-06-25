'use client'

import AuthWrapper from '@/components/AuthWrapper'
import DashboardLayout from '@/app/dashboard/components/DashboardLayout'
import MosqueViewPage from './components/MosqueViewPage'

export default function MosqueClaimViewPage() {
  return (
    <AuthWrapper requireAdmin>
      {({ user, adminUser }) => (
        <DashboardLayout user={user} adminUser={adminUser}>
          <MosqueViewPage />
        </DashboardLayout>
      )}
    </AuthWrapper>
  )
}
