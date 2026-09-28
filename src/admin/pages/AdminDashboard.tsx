import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/services/api/supabase';
import { adminService, type AdminStats } from '../services/adminService';
import { AdminSidebar, type AdminTab } from '../components/AdminSidebar';
import { AdminHeader } from '../components/AdminHeader';
import { OverviewTab } from './OverviewTab';
import { UsersManagementTab } from './UsersManagementTab';
import { ContentModerationTab } from './ContentModerationTab';
import { MeetingPointsTab } from './MeetingPointsTab';
import { Loader2 } from 'lucide-react';

interface AdminDashboardProps {
  onLogout: () => void;
  onNavigateLogin: () => void;
}

export function AdminDashboard({ onLogout, onNavigateLogin }: AdminDashboardProps) {
  const [activeTab, setActiveTab] = useState<AdminTab>('overview');
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [isLoadingStats, setIsLoadingStats] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const [adminEmail, setAdminEmail] = useState<string>('admin@snapan.id');
  const [adminRole, setAdminRole] = useState<string>('admin');

  // Verify auth on mount
  useEffect(() => {
    let isMounted = true;

    async function verifyAdminAuth() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession();

        if (!session?.user) {
          if (isMounted) onNavigateLogin();
          return;
        }

        const isAdmin = await adminService.checkIsAdmin(session.user.id);
        if (!isAdmin) {
          await supabase.auth.signOut();
          if (isMounted) onNavigateLogin();
          return;
        }

        if (isMounted) {
          setAdminEmail(session.user.email || 'admin@snapan.id');
          setAdminRole('admin');
          setIsCheckingAuth(false);
        }
      } catch (err) {
        console.error('Admin auth check failed:', err);
        if (isMounted) onNavigateLogin();
      }
    }

    verifyAdminAuth();

    return () => {
      isMounted = false;
    };
  }, [onNavigateLogin]);

  // Load dashboard overview statistics
  const loadStats = useCallback(async () => {
    try {
      setIsRefreshing(true);
      const data = await adminService.getAdminStats();
      setStats(data);
    } catch (err) {
      console.error('Failed to load admin stats:', err);
    } finally {
      setIsLoadingStats(false);
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    if (!isCheckingAuth) {
      loadStats();
    }
  }, [isCheckingAuth, loadStats]);

  const handleLogout = async () => {
    try {
      await supabase.auth.signOut();
    } finally {
      onLogout();
    }
  };

  if (isCheckingAuth) {
    return (
      <div className="min-h-screen bg-kumo-canvas flex flex-col items-center justify-center space-y-3">
        <Loader2 className="h-8 w-8 animate-spin text-indigo-600" />
        <span className="text-xs text-kumo-subtle font-medium">
          Memverifikasi kredensial admin...
        </span>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-kumo-canvas text-kumo-default flex selection:bg-indigo-600 selection:text-white">
      {/* Fixed Sidebar */}
      <AdminSidebar
        activeTab={activeTab}
        onTabChange={(tab) => setActiveTab(tab)}
        onLogout={handleLogout}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col pl-64 min-w-0">
        {/* Top Header */}
        <AdminHeader
          activeTab={activeTab}
          adminEmail={adminEmail}
          adminRole={adminRole}
          onRefresh={loadStats}
          isRefreshing={isRefreshing}
        />

        {/* Tab Views */}
        <main className="flex-1 overflow-y-auto">
          {activeTab === 'overview' && (
            <OverviewTab
              stats={stats}
              isLoading={isLoadingStats}
              onNavigateTab={(tab) => setActiveTab(tab)}
            />
          )}

          {activeTab === 'users' && <UsersManagementTab />}

          {activeTab === 'moderation' && <ContentModerationTab />}

          {activeTab === 'meeting-points' && <MeetingPointsTab />}
        </main>
      </div>
    </div>
  );
}
