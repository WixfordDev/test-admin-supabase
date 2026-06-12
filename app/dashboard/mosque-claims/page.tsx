'use client'

import AuthWrapper from '@/components/AuthWrapper'
import DashboardLayout from '@/app/dashboard/components/DashboardLayout'
import MosqueClaimsManagement from './components/MosqueClaimsManagement'

export default function MosqueClaimsPage() {
  return (
    <AuthWrapper requireAdmin>
      {({ user, adminUser }) => (
        <DashboardLayout user={user} adminUser={adminUser}>
          <div className="space-y-6">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">Mosque Claims</h1>
              <p className="text-gray-600 mt-2">
                Review and manage mosque ownership claim requests
              </p>
            </div>
            <MosqueClaimsManagement />
          </div>
        </DashboardLayout>
      )}
    </AuthWrapper>
  )
}
