import { RefreshCw, Menu, Search, Command, Bell } from 'lucide-react';
import type { AdminTab } from './AdminSidebar';

interface AdminHeaderProps {
  activeTab: AdminTab;
  adminEmail: string;
  adminRole: string;
  onRefresh?: () => void;
  isRefreshing?: boolean;
  onToggleMobileSidebar?: () => void;
  searchQuery?: string;
  onSearchChange?: (q: string) => void;
}

const tabTitles: Record<AdminTab, { title: string; subtitle: string; category: string }> = {
  overview: {
    category: 'Dashboard',
    title: 'Overview Ekosistem',
    subtitle: 'Statistik real-time, aktivitas transaksi, dan metrik operasional SMKN 8 Semarang',
  },
  users: {
    category: 'Manajemen',
    title: 'Direktori Siswa & Otorisasi',
    subtitle: 'Kelola verifikasi identitas, NIS, kelas/jurusan, dan hak akses akun siswa',
  },
  moderation: {
    category: 'Keamanan & Moderasi',
    title: 'Moderasi Konten & Feed',
    subtitle: 'Pantau laporan karya kejuruan, threads diskusi, dan tindakan takedown konten',
  },
  'meeting-points': {
    category: 'Logistik COD',
    title: 'Titik Temu COD Kampus',
    subtitle: 'Daftar spot resmi yang diakui sekolah untuk serah terima transaksi COD siswa',
  },
};

export function AdminHeader({
  activeTab,
  adminEmail,
  adminRole,
  onRefresh,
  isRefreshing,
  onToggleMobileSidebar,
  searchQuery = '',
  onSearchChange,
}: AdminHeaderProps) {
  const info = tabTitles[activeTab];

  return (
    <div className="flex flex-col select-none">
      {/* Tier 1: Top Navigation Bar */}
      <header className="sticky top-0 z-30 flex h-14 items-center justify-between border-b border-slate-200/80 bg-white px-4 md:px-8">
        {/* Left: Mobile Drawer Trigger & Search */}
        <div className="flex items-center gap-3">
          {onToggleMobileSidebar && (
            <button
              className="h-8.5 w-8.5 rounded-xl border border-slate-200 flex md:hidden items-center justify-center text-slate-600 hover:bg-slate-50 transition-colors cursor-pointer"
              onClick={onToggleMobileSidebar}
              aria-label="Buka navigasi"
            >
              <Menu className="h-4 w-4" />
            </button>
          )}

          {/* Quick Search Bar */}
          <div className="relative w-56 sm:w-72">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
            <input
              type="text"
              placeholder="Cari data di dashboard..."
              value={searchQuery}
              onChange={(e) => onSearchChange?.(e.target.value)}
              className="w-full h-8.5 pl-8.5 pr-8 rounded-lg border border-slate-200 bg-slate-50/70 text-xs text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-[#3D38F5] focus:ring-2 focus:ring-[#3D38F5]/10 outline-none transition-all"
            />
            <div className="absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none hidden sm:flex items-center text-[10px] text-slate-400 font-medium bg-slate-200/60 px-1.5 py-0.5 rounded">
              <Command className="h-2.5 w-2.5 mr-0.5" /> K
            </div>
          </div>
        </div>

        {/* Right: Realtime status, Notification Bell & Admin Profile */}
        <div className="flex items-center gap-3">
          {/* Live Supabase Connection Badge */}
          <div className="hidden sm:inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium bg-emerald-50 text-emerald-700 border border-emerald-200/80">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
            <span>Supabase Live</span>
          </div>

          {/* Notification Bell */}
          <div className="relative">
            <button
              className="h-8.5 w-8.5 rounded-lg border border-slate-200 flex items-center justify-center text-slate-500 hover:text-slate-900 hover:bg-slate-50 transition-colors cursor-pointer"
              title="Notifikasi Sistem"
            >
              <Bell className="h-4 w-4" />
            </button>
            <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-[#3D38F5] ring-2 ring-white" />
          </div>

          {/* Admin Profile Pill */}
          <div className="flex items-center gap-2 pl-2 border-l border-slate-200">
            <div className="h-8 w-8 rounded-lg bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center text-[#3D38F5] font-bold text-xs shrink-0 shadow-2xs">
              {adminEmail[0]?.toUpperCase() || 'A'}
            </div>
            <div className="hidden lg:block text-left">
              <div className="text-xs font-semibold text-slate-900 truncate max-w-[120px]">
                {adminEmail.split('@')[0]}
              </div>
              <div className="text-[10px] font-bold uppercase tracking-wider text-[#3D38F5]">
                {adminRole}
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Tier 2: Sub-header / Page Title & Breadcrumb Bar */}
      <div className="border-b border-slate-200/80 bg-white/90 px-4 md:px-8 py-4 backdrop-blur-xs">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            {/* Breadcrumb Hierarchy */}
            <div className="flex items-center gap-1.5 text-xs text-slate-400 font-medium">
              <span>Snaps Admin</span>
              <span>/</span>
              <span>{info.category}</span>
              <span>/</span>
              <span className="text-slate-800 font-semibold">{info.title}</span>
            </div>

            {/* Page Title & Subtitle */}
            <h1 className="text-lg md:text-xl font-bold tracking-tight text-slate-900 mt-1">
              {info.title}
            </h1>
            <p className="text-xs text-slate-500 mt-0.5">
              {info.subtitle}
            </p>
          </div>

          {/* Actions / Refresh Button */}
          {onRefresh && (
            <div className="flex items-center gap-2 self-start sm:self-auto shrink-0">
              <button
                onClick={onRefresh}
                disabled={isRefreshing}
                className="flex items-center gap-1.5 h-8.5 px-3.5 rounded-lg border border-slate-200 bg-white text-xs font-semibold text-slate-700 hover:bg-slate-50 transition-colors shadow-2xs cursor-pointer disabled:opacity-50"
              >
                <RefreshCw
                  className={`h-3.5 w-3.5 text-[#3D38F5] ${
                    isRefreshing ? 'animate-spin' : ''
                  }`}
                />
                <span>Refresh Data</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
