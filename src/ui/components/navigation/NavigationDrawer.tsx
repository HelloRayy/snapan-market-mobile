import React from 'react';
import {
  X,
  Home,
  User,
  Bookmark,
  Store,
  Smartphone,
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

      {/* Drawer Slide-Over Panel from Left (Super Compact Pure Threads Layout) */}
      <aside
        className="absolute top-0 bottom-0 left-0 w-[80vw] max-w-[280px] sm:max-w-[290px] bg-white text-slate-900 text-base leading-snug shadow-2xl flex flex-col z-10 select-none overflow-hidden transform-gpu animate-drawer-slide border-r border-neutral-200/80 px-3.5"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
          paddingBottom: 'env(safe-area-inset-bottom, 0px)',
          willChange: 'transform',
        }}
      >
        {/* 1. Header (h-[54px] leading-snug) */}
        <div className="flex items-center justify-between h-[54px] w-full border-b border-neutral-100 shrink-0 leading-snug px-1">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-neutral-100 border border-neutral-200/80 flex items-center justify-center text-slate-900 shadow-2xs">
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

        {/* 2. Scrollable Navigation Menu (Pure Minimalist Streamlined Flow) */}
        <div className="flex-1 overflow-y-auto py-3 space-y-1.5 scrollbar-none leading-snug">
          {/* 1. Untuk Anda (Active Hero Pill) */}
          <button
            type="button"
            onClick={() => {
              onNavigateHome();
              onClose();
            }}
            className="flex items-center gap-3.5 h-[42px] w-full px-3.5 rounded-2xl bg-neutral-100/90 text-slate-950 font-bold text-[15px] hover:bg-neutral-200/70 active:scale-98 transition-all cursor-pointer leading-snug text-left shadow-2xs"
          >
            <Home className="w-5 h-5 fill-slate-900 stroke-none shrink-0" />
            <span className="truncate">Untuk Anda</span>
          </button>

          {/* 2. Utas baru */}
          {onOpenCreateModal && (
            <button
              type="button"
              onClick={() => {
                onClose();
                onOpenCreateModal();
              }}
              className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Plus className="w-5 h-5 stroke-[2.4] text-slate-800 shrink-0" />
              <span className="truncate">Utas baru</span>
            </button>
          )}

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
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <Search className="w-5 h-5 stroke-[2.2] text-slate-800 shrink-0" />
            <span className="truncate">Cari</span>
          </button>

          {/* 4. Pesan with Overlaid Notification Badge */}
          <button
            type="button"
            onClick={() => {
              onClose();
            }}
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <div className="relative shrink-0 flex items-center justify-center">
              <Send className="w-5 h-5 stroke-[2] text-slate-800 -rotate-12" />
              <span className="absolute -top-1.5 -right-2 min-w-[15px] h-[15px] px-1 rounded-full bg-[#ff3040] text-white text-[9.5px] font-bold flex items-center justify-center border-1.5 border-white leading-none shadow-2xs">
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
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <div className="relative shrink-0 flex items-center justify-center">
              <Heart className="w-5 h-5 stroke-[2.2] text-slate-800" />
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
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <User className="w-5 h-5 stroke-[2] text-slate-800 shrink-0" />
            <span className="truncate">Profil</span>
          </button>

          {/* 7. Insight */}
          <button
            type="button"
            onClick={() => {
              onNavigateProfile(myUsername);
              onClose();
            }}
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <BarChart2 className="w-5 h-5 stroke-[2] text-slate-800 shrink-0" />
            <span className="truncate">Insight</span>
          </button>

          {/* 8. Tersimpan */}
          <button
            type="button"
            onClick={() => {
              onNavigateProfile(myUsername);
              onClose();
            }}
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <Bookmark className="w-5 h-5 stroke-[2] text-slate-800 shrink-0" />
            <span className="truncate">Tersimpan</span>
          </button>
        </div>

        {/* 3. Bottom Utility & System Section (Pinned to Bottom with Distinct Separator) */}
        <div className="pt-2.5 pb-3 border-t border-neutral-200/90 bg-white space-y-1 shrink-0 leading-snug">
          {/* Pasang PWA */}
          <button
            type="button"
            onClick={() => {
              onNavigateDownload();
              onClose();
            }}
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-semibold text-emerald-600 hover:bg-emerald-50 active:bg-emerald-100/80 transition-colors cursor-pointer leading-snug text-left"
          >
            <Smartphone className="w-5 h-5 text-emerald-600 stroke-[2] shrink-0" />
            <span className="truncate">Pasang Aplikasi PWA</span>
          </button>

          {/* Pengaturan Akun */}
          <button
            type="button"
            onClick={() => {
              onNavigateProfile(myUsername);
              onClose();
            }}
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[15px] font-medium text-slate-800 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
          >
            <Settings className="w-5 h-5 text-slate-800 stroke-[2] shrink-0" />
            <span className="truncate">Pengaturan Akun</span>
          </button>

          {/* Keluar Akun */}
          <button
            type="button"
            onClick={handleLogout}
            className="flex items-center gap-3.5 h-[38px] w-full px-3.5 rounded-xl text-[14.5px] font-semibold text-rose-600 hover:bg-rose-50 active:bg-rose-100/80 transition-colors cursor-pointer leading-snug text-left"
          >
            <LogOut className="w-4.5 h-4.5 text-rose-600 stroke-[2] shrink-0" />
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

