import { useState, useEffect } from 'react';
import { Sun, Moon, ShieldCheck, RefreshCw, Menu } from 'lucide-react';
import { Badge, Button } from '@cloudflare/kumo';
import type { AdminTab } from './AdminSidebar';

interface AdminHeaderProps {
  activeTab: AdminTab;
  adminEmail: string;
  adminRole: string;
  onRefresh?: () => void;
  isRefreshing?: boolean;
  onToggleMobileSidebar?: () => void;
}

const tabTitles: Record<AdminTab, { title: string; subtitle: string }> = {
  overview: {
    title: 'Dashboard Overview',
    subtitle: 'Statistik ekosistem siswa dan metrik operasional SMKN 8 Semarang',
  },
  users: {
    title: 'Manajemen Siswa & Role',
    subtitle: 'Kelola akun siswa, hak otorisasi (RBAC), dan verifikasi badge',
  },
  moderation: {
    title: 'Moderasi Konten & Feed',
    subtitle: 'Pantau dan takedown postingan threads atau barang yang melanggar aturan',
  },
  'meeting-points': {
    title: 'Titik Temu COD Kampus',
    subtitle: 'Atur lokasi resmi serah terima barang COD di lingkungan sekolah',
  },
};

export function AdminHeader({
  activeTab,
  adminEmail,
  adminRole,
  onRefresh,
  isRefreshing,
  onToggleMobileSidebar,
}: AdminHeaderProps) {
  const [isDarkMode, setIsDarkMode] = useState<boolean>(() => {
    if (typeof document !== 'undefined') {
      return document.documentElement.getAttribute('data-mode') === 'dark';
    }
    return false;
  });

  const toggleTheme = () => {
    const nextMode = !isDarkMode;
    setIsDarkMode(nextMode);
    document.documentElement.setAttribute('data-mode', nextMode ? 'dark' : 'light');
    try {
      localStorage.setItem('theme', nextMode ? 'dark' : 'light');
    } catch {
      // noop
    }
  };

  useEffect(() => {
    const saved = localStorage.getItem('theme');
    if (saved === 'dark') {
      setIsDarkMode(true);
      document.documentElement.setAttribute('data-mode', 'dark');
    }
  }, []);

  const info = tabTitles[activeTab];

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-kumo-hairline bg-kumo-canvas px-4 md:px-6 backdrop-blur-md">
      <div className="flex items-center gap-3">
        {onToggleMobileSidebar && (
          <Button
            variant="secondary"
            className="h-8 w-8 p-0 flex md:hidden items-center justify-center text-kumo-default"
            onClick={onToggleMobileSidebar}
            aria-label="Buka menu"
          >
            <Menu className="h-4 w-4" />
          </Button>
        )}
        <div>
          <h1 className="text-base font-semibold tracking-tight text-kumo-default">
            {info.title}
          </h1>
          <p className="text-xs text-kumo-subtle hidden sm:block">
            {info.subtitle}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3">
        {onRefresh && (
          <Button
            variant="secondary"
            className="flex items-center gap-1.5 h-8 px-2.5 text-xs text-kumo-subtle hover:text-kumo-default"
            onClick={onRefresh}
            disabled={isRefreshing}
          >
            <RefreshCw className={`h-3.5 w-3.5 ${isRefreshing ? 'animate-spin' : ''}`} />
            <span className="hidden sm:inline">Segarkan</span>
          </Button>
        )}

        {/* Live Supabase Connection Badge */}
        <Badge variant="primary" className="hidden md:inline-flex items-center gap-1.5 py-0.5 text-xs">
          <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
          <span>Supabase Live</span>
        </Badge>

        {/* Admin User Info */}
        <div className="flex items-center gap-2 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 py-1">
          <ShieldCheck className="h-4 w-4 text-indigo-600" />
          <div className="text-xs">
            <span className="font-semibold text-kumo-default max-w-[120px] truncate inline-block align-bottom">
              {adminEmail.split('@')[0]}
            </span>
            <span className="ml-1.5 rounded bg-indigo-100 px-1 py-0.2 text-[9px] font-bold text-indigo-700 uppercase">
              {adminRole}
            </span>
          </div>
        </div>

        {/* Dark Mode Toggle */}
        <Button
          variant="secondary"
          className="h-8 w-8 p-0 flex items-center justify-center text-kumo-default"
          onClick={toggleTheme}
          aria-label="Toggle theme"
        >
          {isDarkMode ? <Sun className="h-4 w-4 text-amber-500" /> : <Moon className="h-4 w-4 text-slate-600" />}
        </Button>
      </div>
    </header>
  );
}
