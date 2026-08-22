import React from 'react';
import {
  X,
  Home,
  User,
  Bookmark,
  Store,
  Download,
  Settings,
  LogOut,
  Plus,
  Send,
  Heart,
  BarChart2,
  Search,
} from 'lucide-react';
import { useAuth } from '@/ui/hooks/useAuth';

interface NavigationDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onNavigateHome: () => void;
  onNavigateSearch?: () => void;
  onNavigateProfile: (username: string) => void;
  onNavigateDownload: () => void;
  onOpenCreateModal?: () => void;
}

export const NavigationDrawer: React.FC<NavigationDrawerProps> = ({
  isOpen,
  onClose,
  onNavigateHome,
  onNavigateSearch,
  onNavigateProfile,
  onNavigateDownload,
  onOpenCreateModal,
}) => {
  const { profile, signOut } = useAuth();
  const myUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';

  const handleLogout = async () => {
    try {
      await signOut();
      onClose();
      window.location.href = '/';
    } catch (err) {
      console.error('Logout error:', err);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-hidden font-gt-standard">
      {/* Backdrop Blur Overlay */}
      <div
        onClick={onClose}
        className="absolute inset-0 bg-black/40 backdrop-blur-xs cursor-pointer animate-backdrop-fade"
      />

      {/* Drawer Slide-Over Panel from Left (Compact Pure Threads 3-Cluster Layout) */}
      <aside
        className="absolute top-0 bottom-0 left-0 w-[82vw] max-w-[280px] sm:max-w-[290px] bg-white text-slate-900 text-base leading-snug shadow-2xl flex flex-col z-10 select-none overflow-hidden transform-gpu animate-drawer-slide border-r border-neutral-200/80 px-3.5"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
          paddingBottom: 'env(safe-area-inset-bottom, 0px)',
          willChange: 'transform',
        }}
      >
        {/* 1. Top Header */}
        <div className="flex items-center justify-between h-[52px] w-full border-b border-neutral-100 shrink-0 leading-snug px-1">
          <div className="flex items-center gap-2.5">
            <div className="w-7.5 h-7.5 rounded-xl bg-neutral-100 border border-neutral-200/80 flex items-center justify-center text-slate-900 shadow-2xs">
              <Store className="w-4 h-4 text-slate-900 stroke-[2.2]" />
            </div>
            <span className="font-bold text-[15px] text-slate-900 tracking-tight leading-snug">Snapan Market</span>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-neutral-400 hover:text-slate-800 active:scale-90 transition-all cursor-pointer leading-snug"
            aria-label="Tutup Menu"
          >
            <X className="w-4.5 h-4.5 stroke-[2]" />
          </button>
        </div>

        {/* 2. Scrollable Stream with 3 Clean Clusters & Spacing Gaps */}
        <div className="flex-1 overflow-y-auto pt-3 pb-3 scrollbar-none leading-snug">
          {/* Cluster 1: Feed Utama (Untuk Anda, Utas baru, Cari) */}
          <div className="flex flex-col gap-y-1">
            {/* 1. Untuk Anda (Active Hero Pill) */}
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center gap-x-3 h-[38px] w-full px-3 rounded-2xl bg-neutral-100/90 text-slate-950 font-bold text-[14.5px] hover:bg-neutral-200/70 active:scale-98 transition-all cursor-pointer leading-snug text-left shadow-2xs"
            >
              <div className="w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <Home className="w-[18px] h-[18px] fill-slate-900 stroke-none" />
              </div>
              <span className="truncate">Untuk Anda</span>
            </button>

            {/* 2. Utas baru */}
            <button
              type="button"
              onClick={() => {
                onClose();
                onOpenCreateModal?.();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <Plus className="w-[19px] h-[19px] stroke-[2.4] text-slate-800" />
              </div>
              <span className="truncate">Utas baru</span>
            </button>

            {/* 3. Cari */}
            <button
              type="button"
              onClick={() => {
                if (onNavigateSearch) {
                  onNavigateSearch();
                } else {
                  onNavigateHome();
                }
                onClose();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <Search className="w-[18px] h-[18px] stroke-[2.2] text-slate-800" />
              </div>
              <span className="truncate">Cari</span>
            </button>
          </div>

          {/* Distinct Spacing Gap Between Cluster 1 & Cluster 2 */}
          <div className="h-4" />

          {/* Cluster 2: Interaksi Personal & Arsip (Pesan, Aktivitas, Profil, Insight, Tersimpan) */}
          <div className="flex flex-col gap-y-1">
            {/* 4. Pesan with Overlaid Notification Badge */}
            <button
              type="button"
              onClick={() => {
                onClose();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="relative w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <Send className="w-[17px] h-[17px] stroke-[2] text-slate-800 -rotate-12" />
                <span className="absolute -top-1 -right-2 min-w-[15px] h-[15px] px-0.5 rounded-full bg-[#ff3040] text-white text-[9.5px] font-bold flex items-center justify-center border-1.5 border-white leading-none shadow-2xs">
                  1
                </span>
              </div>
              <span className="truncate">Pesan</span>
            </button>

            {/* 5. Aktivitas with Overlaid Red Dot */}
            <button
              type="button"
              onClick={() => {
                onClose();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="relative w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <Heart className="w-[18px] h-[18px] stroke-[2.2] text-slate-800" />
                <span className="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-[#ff3040] border-2 border-white" />
              </div>
              <span className="truncate">Aktivitas</span>
            </button>

            {/* 6. Profil */}
            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <User className="w-[18px] h-[18px] stroke-[2] text-slate-800" />
              </div>
              <span className="truncate">Profil</span>
            </button>

            {/* 7. Insight */}
            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <BarChart2 className="w-[18px] h-[18px] stroke-[2] text-slate-800" />
              </div>
              <span className="truncate">Insight</span>
            </button>

            {/* 8. Tersimpan */}
            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-x-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="w-[18px] h-[18px] flex items-center justify-center shrink-0">
                <Bookmark className="w-[18px] h-[18px] stroke-[2] text-slate-800" />
              </div>
              <span className="truncate">Tersimpan</span>
            </button>
          </div>
        </div>

        {/* 3. Bottom Utility & System Section (Pinned to Bottom with Distinct Separator) */}
        <div className="pt-2.5 pb-3 border-t border-neutral-200/90 bg-white space-y-1 shrink-0 leading-snug">
          {/* Unduh Aplikasi */}
          <button
            type="button"
            onClick={() => {
              onNavigateDownload();
              onClose();
            }}
            className="flex items-center gap-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-semibold text-[#1d64ec] hover:bg-blue-50/80 active:bg-blue-100/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <Download className="w-4.5 h-4.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
            <span className="truncate">Unduh Aplikasi</span>
          </button>

          {/* Pengaturan Akun */}
          <button
            type="button"
            onClick={() => {
              onNavigateProfile(myUsername);
              onClose();
            }}
            className="flex items-center gap-3 h-[36px] w-full px-3 rounded-xl text-[14.5px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <Settings className="w-4.5 h-4.5 text-slate-800 stroke-[2] shrink-0" />
            <span className="truncate">Pengaturan Akun</span>
          </button>

          {/* Keluar Akun */}
          <button
            type="button"
            onClick={handleLogout}
            className="flex items-center gap-3 h-[36px] w-full px-3 rounded-xl text-[14px] font-semibold text-rose-600 hover:bg-rose-50 active:bg-rose-100/80 transition-colors cursor-pointer leading-snug text-left"
          >
            <LogOut className="w-4 h-4 text-rose-600 stroke-[2] shrink-0" />
            <span className="truncate">Keluar Akun</span>
          </button>

          <div className="text-center pt-1">
            <p className="text-[11px] text-neutral-400 font-medium leading-tight">
              Snapan Market PWA v0.1.0
            </p>
          </div>
        </div>
      </aside>
    </div>
  );
};
