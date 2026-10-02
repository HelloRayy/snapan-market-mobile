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
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

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
      <div className="min-h-screen bg-[#F8FAFC] flex flex-col items-center justify-center space-y-3">
        <Loader2 className="h-8 w-8 animate-spin text-[#3D38F5]" />
        <span className="text-xs text-slate-500 font-medium">
          Memverifikasi kredensial admin ekosistem...
        </span>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFC] text-slate-900 flex selection:bg-[#3D38F5] selection:text-white font-sans antialiased">
      {/* Sidebar (Responsive drawer on mobile, fixed on desktop) */}
      <AdminSidebar
        activeTab={activeTab}
        onTabChange={(tab) => {
          setActiveTab(tab);
          setIsMobileSidebarOpen(false);
        }}
        onLogout={handleLogout}
        isOpenMobile={isMobileSidebarOpen}
        onCloseMobile={() => setIsMobileSidebarOpen(false)}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col md:pl-64 pl-0 min-w-0 transition-[padding] duration-200">
        {/* Top Header */}
        <AdminHeader
          activeTab={activeTab}
          adminEmail={adminEmail}
          adminRole={adminRole}
          onRefresh={loadStats}
          isRefreshing={isRefreshing}
          onToggleMobileSidebar={() => setIsMobileSidebarOpen((prev) => !prev)}
        />

        {/* Tab Views with Zero-Lag State Caching */}
        <main className="flex-1 overflow-y-auto">
          <div className={activeTab === 'overview' ? 'block' : 'hidden'}>
            <OverviewTab
              stats={stats}
              isLoading={isLoadingStats}
              onNavigateTab={(tab) => setActiveTab(tab)}
            />
          </div>

          <div className={activeTab === 'users' ? 'block' : 'hidden'}>
            <UsersManagementTab />
          </div>

          <div className={activeTab === 'moderation' ? 'block' : 'hidden'}>
            <ContentModerationTab />
          </div>

          <div className={activeTab === 'meeting-points' ? 'block' : 'hidden'}>
            <MeetingPointsTab />
          </div>
        </main>
      </div>
    </div>
  );
}
