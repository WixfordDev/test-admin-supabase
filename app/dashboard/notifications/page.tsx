"use client"
import AdminNotifications from './components/NotificationSender';
import DashboardLayout from '../components/DashboardLayout';
import AuthWrapper from '@/components/AuthWrapper';

export default function NotificationsPage() {
  return (
    <div className="">
          <AuthWrapper requireAdmin>
            {({ user, adminUser }) => (
              <DashboardLayout user={user} adminUser={adminUser}>
                <div className="space-y-6">
                
                <AdminNotifications />
                </div>
              </DashboardLayout>
            )}
          </AuthWrapper>

    </div>
  );
}