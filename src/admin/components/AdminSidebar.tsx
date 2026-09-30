import React from 'react';
import {
  LayoutDashboard,
  Users,
  ShieldAlert,
  MapPin,
  LogOut,
  Sparkles,
} from 'lucide-react';
import { Button } from '@cloudflare/kumo';

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
  const navItems: { id: AdminTab; label: string; icon: React.ReactNode }[] = [
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
          className="fixed inset-0 z-40 bg-black/40 backdrop-blur-xs md:hidden"
          onClick={onCloseMobile}
        />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-50 flex w-64 flex-col border-r border-kumo-hairline bg-kumo-canvas select-none transition-transform duration-200 ease-in-out md:translate-x-0 ${
          isOpenMobile ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        }`}
      >
      {/* Brand Header */}
      <div className="flex h-14 items-center justify-between border-b border-kumo-hairline px-4">
        <div className="flex items-center gap-2.5">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-indigo-600 text-white font-bold text-sm shadow-xs">
            8
          </div>
          <div>
            <div className="text-sm font-semibold tracking-tight text-kumo-default flex items-center gap-1.5">
              sNaps Admin
              <span className="rounded bg-indigo-50 px-1.5 py-0.2 text-[10px] font-bold text-indigo-600 border border-indigo-200">
                PRO
              </span>
            </div>
            <div className="text-[11px] text-kumo-subtle">SMKN 8 Semarang</div>
          </div>
        </div>
      </div>

      {/* Navigation List */}
      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
        <div className="px-2 pb-2 text-[11px] font-semibold uppercase tracking-wider text-kumo-subtle">
          Main Menu
        </div>
        {navItems.map((item) => {
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onTabChange(item.id)}
              className={`flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-sm font-medium transition-colors cursor-pointer text-left ${
                isActive
                  ? 'bg-kumo-control text-kumo-default shadow-xs border border-kumo-hairline font-semibold'
                  : 'text-kumo-subtle hover:bg-kumo-tint hover:text-kumo-default'
              }`}
            >
              <span className={isActive ? 'text-indigo-600' : 'text-kumo-subtle'}>
                {item.icon}
              </span>
              <span>{item.label}</span>
            </button>
          );
        })}
      </div>

      {/* Footer Info & Logout */}
      <div className="border-t border-kumo-hairline p-3 space-y-2">
        <div className="rounded-lg bg-kumo-control p-2.5 border border-kumo-hairline">
          <div className="flex items-center gap-1.5 text-xs font-semibold text-kumo-default">
            <Sparkles className="h-3.5 w-3.5 text-amber-500" />
            <span>Kumo UI Design System</span>
          </div>
          <div className="mt-0.5 text-[11px] text-kumo-subtle">
            Cloudflare Clean Component Library
          </div>
        </div>

        <Button
          variant="secondary"
          className="w-full flex items-center justify-center gap-2 text-red-600 hover:bg-red-50 hover:text-red-700"
          onClick={onLogout}
        >
          <LogOut className="h-4 w-4" />
          <span>Keluar Portal</span>
        </Button>
      </div>
    </aside>
  </>
  );
}
