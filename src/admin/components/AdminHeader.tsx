import { RefreshCw, Menu, Search, Command } from 'lucide-react';
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
    title: 'Overview',
    subtitle: 'Statistik ekosistem siswa dan metrik operasional SMKN 8 Semarang',
  },
  users: {
    category: 'Manajemen',
    title: 'Siswa & Hak Akses',
    subtitle: 'Kelola verifikasi identitas, NIS, kelas/jurusan, dan status akun',
  },
  moderation: {
    category: 'Keamanan',
    title: 'Moderasi Konten',
    subtitle: 'Pantau laporan feed threads, produk marketplace, dan takedown konten',
  },
  'meeting-points': {
    category: 'Logistik',
    title: 'Titik Temu COD Kampus',
    subtitle: 'Kelola titik serah terima resmi transaksi siswa di area sekolah',
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
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-slate-200/80 bg-white/95 px-4 md:px-7 backdrop-blur-md">
      {/* Left: Mobile Toggle & Breadcrumbs */}
      <div className="flex items-center gap-3.5">
        {onToggleMobileSidebar && (
          <button
            className="h-8.5 w-8.5 rounded-xl border border-slate-200 flex md:hidden items-center justify-center text-slate-600 hover:bg-slate-50 transition-colors cursor-pointer"
            onClick={onToggleMobileSidebar}
            aria-label="Buka navigasi"
          >
            <Menu className="h-4 w-4" />
          </button>
        )}

        <div>
          <div className="flex items-center gap-2 text-xs text-slate-400 font-medium">
            <span>{info.category}</span>
            <span>/</span>
            <span className="text-slate-900 font-semibold">{info.title}</span>
          </div>
          <p className="text-[11.5px] text-slate-500 hidden sm:block mt-0.5">
            {info.subtitle}
          </p>
        </div>
      </div>

      {/* Right: Search, Refresh, Live Badge & Admin Profile */}
      <div className="flex items-center gap-3">
        {/* Quick Search Bar */}
        {onSearchChange && (
          <div className="relative hidden lg:block w-64">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
            <input
              type="text"
              placeholder="Cari data..."
              value={searchQuery}
              onChange={(e) => onSearchChange(e.target.value)}
              className="w-full h-8.5 pl-8.5 pr-8 rounded-xl border border-slate-200 bg-slate-50/70 text-xs text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-[#3D38F5] focus:ring-2 focus:ring-[#3D38F5]/10 outline-none transition-all"
            />
            <div className="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none flex items-center text-[10px] text-slate-400 font-medium bg-slate-200/60 px-1.5 py-0.5 rounded">
              <Command className="h-2.5 w-2.5 mr-0.5" /> K
            </div>
          </div>
        )}

        {/* Refresh Trigger */}
        {onRefresh && (
          <button
            className="flex items-center gap-1.5 h-8.5 px-3 rounded-xl border border-slate-200 bg-white text-xs font-medium text-slate-600 hover:text-slate-900 hover:bg-slate-50 transition-all cursor-pointer shadow-2xs disabled:opacity-50"
            onClick={onRefresh}
            disabled={isRefreshing}
            title="Segarkan data terbaru"
          >
            <RefreshCw
              className={`h-3.5 w-3.5 text-[#3D38F5] ${
                isRefreshing ? 'animate-spin' : ''
              }`}
            />
            <span className="hidden sm:inline">Segarkan</span>
          </button>
        )}

        {/* Live Supabase Connection Badge */}
        <div className="hidden sm:inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium bg-emerald-50 text-emerald-700 border border-emerald-200/80">
          <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
          <span>Realtime Live</span>
        </div>

        {/* Admin Profile Pill */}
        <div className="flex items-center gap-2 pl-2 border-l border-slate-200/80">
          <div className="h-8 w-8 rounded-xl bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center text-[#3D38F5] font-bold text-xs shrink-0 shadow-2xs">
            {adminEmail[0]?.toUpperCase() || 'A'}
          </div>
          <div className="hidden xl:block text-left">
            <div className="text-xs font-semibold text-slate-900 truncate max-w-[110px]">
              {adminEmail.split('@')[0]}
            </div>
            <div className="text-[10px] font-bold uppercase tracking-wider text-[#3D38F5]">
              {adminRole}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
