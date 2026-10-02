import type { ReactNode } from 'react';
import {
  LayoutDashboard,
  Users,
  ShieldAlert,
  MapPin,
  LogOut,
} from 'lucide-react';

export type AdminTab = 'overview' | 'users' | 'moderation' | 'meeting-points';

interface AdminSidebarProps {
  activeTab: AdminTab;
  onTabChange: (tab: AdminTab) => void;
  onLogout: () => void;
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
}

export function AdminSidebar({
  activeTab,
  onTabChange,
  onLogout,
  isOpenMobile = false,
  onCloseMobile,
}: AdminSidebarProps) {
  const navItems: { id: AdminTab; label: string; icon: ReactNode; badge?: string }[] = [
    {
      id: 'overview',
      label: 'Overview',
      icon: <LayoutDashboard className="h-4 w-4" />,
    },
    {
      id: 'users',
      label: 'Manajemen Siswa',
      icon: <Users className="h-4 w-4" />,
    },
    {
      id: 'moderation',
      label: 'Moderasi Konten',
      icon: <ShieldAlert className="h-4 w-4" />,
    },
    {
      id: 'meeting-points',
      label: 'Titik Temu COD',
      icon: <MapPin className="h-4 w-4" />,
    },
  ];

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpenMobile && (
        <div
          className="fixed inset-0 z-40 bg-slate-900/30 backdrop-blur-xs md:hidden"
          onClick={onCloseMobile}
        />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-slate-200/80 bg-white select-none transition-transform duration-200 ease-in-out md:translate-x-0 ${
          isOpenMobile ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        }`}
      >
        {/* Brand Header */}
        <div className="flex h-16 items-center justify-between border-b border-slate-100 px-5">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#3D38F5] text-white font-bold text-sm shadow-[0_2px_8px_rgba(61,56,245,0.3)]">
              8
            </div>
            <div>
              <div className="text-sm font-bold tracking-tight text-slate-900 flex items-center gap-1.5">
                <span>Snaps.</span>
                <span className="rounded-full bg-[#EEF0FF] px-2 py-0.5 text-[10px] font-bold text-[#3D38F5] border border-[#D8DBFE]">
                  Admin
                </span>
              </div>
              <div className="text-[11px] font-medium text-slate-400">SMKN 8 Semarang</div>
            </div>
          </div>
        </div>

        {/* Navigation List */}
        <div className="flex-1 overflow-y-auto px-3.5 py-5 space-y-1">
          <div className="px-2.5 pb-2.5 text-[10.5px] font-semibold uppercase tracking-wider text-slate-400">
            Workspace
          </div>
          {navItems.map((item) => {
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => onTabChange(item.id)}
                className={`flex w-full items-center justify-between rounded-xl px-3 py-2.5 text-sm font-medium transition-all cursor-pointer text-left ${
                  isActive
                    ? 'bg-[#EEF0FF] text-[#3D38F5] font-semibold border border-[#D8DBFE]/80 shadow-2xs'
                    : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                }`}
              >
                <div className="flex items-center gap-2.5">
                  <span className={isActive ? 'text-[#3D38F5]' : 'text-slate-400'}>
                    {item.icon}
                  </span>
                  <span>{item.label}</span>
                </div>
                {isActive && (
                  <div className="h-1.5 w-1.5 rounded-full bg-[#3D38F5]" />
                )}
              </button>
            );
          })}
        </div>

        {/* Footer Info & Logout */}
        <div className="border-t border-slate-100 p-4 space-y-3 bg-slate-50/50">
          <div className="rounded-xl bg-white p-3 border border-slate-200/80 shadow-[0_1px_2px_rgba(0,0,0,0.02)]">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-semibold text-slate-900">Ecosystem Status</span>
              <span className="flex items-center gap-1 text-[10.5px] font-medium text-emerald-600">
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                Live
              </span>
            </div>
            <div className="mt-1 text-[11px] text-slate-500">
              Snaps Mobile App v1.0.4 • Supabase Cloud
            </div>
          </div>

          <button
            onClick={onLogout}
            className="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold text-red-600 hover:bg-red-50 hover:text-red-700 border border-transparent hover:border-red-100 transition-colors cursor-pointer"
          >
            <LogOut className="h-3.5 w-3.5" />
            <span>Keluar Portal</span>
          </button>
        </div>
      </aside>
    </>
  );
}
