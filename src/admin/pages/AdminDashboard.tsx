import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/services/api/supabase';
import { adminService, type AdminStats, type ProfileRow } from '../services/adminService';
import { AdminSidebar, type AdminTab } from '../components/AdminSidebar';
import { AdminHeader } from '../components/AdminHeader';
import { OverviewTab } from './OverviewTab';
import { UsersManagementTab } from './UsersManagementTab';
import { ContentModerationTab } from './ContentModerationTab';
import { MeetingPointsTab } from './MeetingPointsTab';
import { ServerMonitorTab } from './ServerMonitorTab';
import { Loader2 } from 'lucide-react';
import '../styles/cooladmin.css';

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
  const [adminProfile, setAdminProfile] = useState<ProfileRow | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  // Apply body.app for CoolAdmin stylesheet scoping
  useEffect(() => {
    document.body.classList.add('app');
    return () => {
      document.body.classList.remove('app');
      document.body.classList.remove('sidebar-open');
    };
  }, []);

  // Sync sidebar-open class on body for responsive mobile drawer
  useEffect(() => {
    if (isMobileSidebarOpen) {
      document.body.classList.add('sidebar-open');
    } else {
      document.body.classList.remove('sidebar-open');
    }
  }, [isMobileSidebarOpen]);

  // Verify auth on mount & connect logged-in profile from Supabase DB
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

        // Fetch connected profile from Supabase database
        const { data: profile } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', session.user.id)
          .single();

        if (isMounted) {
          if (profile) {
            setAdminProfile(profile);
            setAdminEmail(session.user.email || profile.username || 'admin@snapan.id');
            setAdminRole(profile.role || 'admin');
          } else {
            setAdminEmail(session.user.email || 'admin@snapan.id');
            setAdminRole('admin');
          }
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
    <div className="page-wrapper">
      {/* CoolAdmin Sidebar */}
      <AdminSidebar
        activeTab={activeTab}
        onTabChange={(tab) => {
          setActiveTab(tab);
          setIsMobileSidebarOpen(false);
        }}
        onLogout={handleLogout}
        isOpenMobile={isMobileSidebarOpen}
        onCloseMobile={() => setIsMobileSidebarOpen(false)}
        adminProfile={adminProfile}
        adminEmail={adminEmail}
        stats={stats}
      />

      {/* CoolAdmin Page Container */}
      <div className="page-container">
        {/* CoolAdmin Header Desktop */}
        <AdminHeader
          activeTab={activeTab}
          adminEmail={adminEmail}
          adminRole={adminRole}
          adminProfile={adminProfile}
          onRefresh={loadStats}
          isRefreshing={isRefreshing}
          onToggleMobileSidebar={() => setIsMobileSidebarOpen((prev) => !prev)}
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
          onNavigateTab={setActiveTab}
          onLogout={handleLogout}
        />

        {/* CoolAdmin Main Content */}
        <main className="main-content" id="main-content">
          <div className="section__content section__content--p30">
            <div className="container-fluid">
              <div className={activeTab === 'overview' ? 'block' : 'hidden'}>
                <OverviewTab
                  stats={stats}
                  isLoading={isLoadingStats}
                  onNavigateTab={(tab) => setActiveTab(tab)}
                  onRefresh={loadStats}
                  isRefreshing={isRefreshing}
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

              <div className={activeTab === 'server' ? 'block' : 'hidden'}>
                <ServerMonitorTab />
              </div>
            </div>
          </div>
        </main>
      </div>

      {/* Mobile Drawer Backdrop */}
      <div
        className="sidebar-backdrop"
        onClick={() => setIsMobileSidebarOpen(false)}
      />
    </div>
  );
}
