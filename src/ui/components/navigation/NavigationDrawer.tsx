import React from 'react';
import {
  X,
  Home,
  User,
  ShoppingBag,
  ShoppingCart,
  Bookmark,
  Store,
  Smartphone,
  Settings,
  LogOut,
  ChevronRight,
  PlusCircle,
  MessageCircle,
  Bell,
  BarChart2,
  Search,
  Sparkles,
  Layers,
} from 'lucide-react';
import { useAuth } from '@/ui/hooks/useAuth';
import { useCartStore } from '@/ui/store/cartStore';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';

interface NavigationDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  onNavigateHome: () => void;
  onNavigateProfile: (username: string) => void;
  onNavigateDownload: () => void;
  onOpenCreateModal?: () => void;
}

export const NavigationDrawer: React.FC<NavigationDrawerProps> = ({
  isOpen,
  onClose,
  onNavigateHome,
  onNavigateProfile,
  onNavigateDownload,
  onOpenCreateModal,
}) => {
  const { user, profile, signOut } = useAuth();
  const cartItems = useCartStore((s) => s.items);
  const totalCartCount = cartItems.reduce((acc, i) => acc + i.quantity, 0);

  const myName = profile?.full_name || 'Raditya Rayhan';
  const myUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';
  const myAvatar =
    profile?.avatar_url ||
    user?.user_metadata?.avatar_url ||
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';
  const myClassGroup = profile?.class_group || 'XII PPLG 1 · SMKN 8';

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

      {/* Drawer Slide-Over Panel from Left (Clean Light Mode Sizing & Layout) */}
      <aside
        className="absolute top-0 bottom-0 left-0 w-[240px] sm:w-[250px] bg-white text-slate-900 text-base leading-snug shadow-2xl flex flex-col z-10 select-none overflow-hidden transform-gpu animate-drawer-slide border-r border-neutral-200/80 px-[15px]"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
          paddingBottom: 'env(safe-area-inset-bottom, 0px)',
          willChange: 'transform',
        }}
      >
        {/* 1. Header (h-[50px] pl-[7px] leading-snug) */}
        <div className="flex items-center justify-between pl-[7px] pr-1 h-[50px] w-full border-b border-neutral-100 shrink-0 leading-snug">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-neutral-100 border border-neutral-200/80 flex items-center justify-center text-slate-900 shadow-2xs">
              <Store className="w-3.5 h-3.5 text-slate-900 stroke-[2.2]" />
            </div>
            <span className="font-bold text-[14.5px] text-slate-900 tracking-tight leading-snug">Snapan Market</span>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="w-7 h-7 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-neutral-400 hover:text-slate-800 active:scale-90 transition-all cursor-pointer leading-snug"
            aria-label="Tutup Menu"
          >
            <X className="w-4 h-4 stroke-[2]" />
          </button>
        </div>

        {/* 2. User Profile Summary Box */}
        <div
          onClick={() => {
            onNavigateProfile(myUsername);
            onClose();
          }}
          className="p-2.5 my-2 bg-neutral-50/80 hover:bg-neutral-100 border border-neutral-200/70 rounded-xl transition-all cursor-pointer flex items-center gap-2.5 group shadow-2xs shrink-0 leading-snug"
        >
          <div className="w-9 h-9 rounded-full overflow-hidden ring-1.5 ring-neutral-200/80 shadow-2xs shrink-0">
            <img src={myAvatar} alt={myName} className="w-full h-full object-cover" />
          </div>

          <div className="flex-1 min-w-0 leading-snug">
            <div className="flex items-center gap-1">
              <h3 className="font-bold text-[13px] text-slate-900 truncate leading-tight">{myName}</h3>
              <ClickableVerifiedBadge className="w-3.5 h-3.5" />
            </div>
            <p className="text-[11px] text-neutral-500 truncate leading-tight">@{myUsername}</p>
            <p className="text-[10px] font-semibold text-[#1d64ec] truncate leading-tight mt-0.5">{myClassGroup}</p>
          </div>

          <ChevronRight className="w-3.5 h-3.5 text-neutral-400 group-hover:text-slate-800 group-hover:translate-x-0.5 transition-all" />
        </div>

        {/* 3. Scrollable Navigation Menu (h-[34px] Item Rows, Grouped by UX) */}
        <div className="flex-1 overflow-y-auto py-1 space-y-3.5 scrollbar-none leading-snug">
          {/* Section 1: Feed Utama & Aksi Cepat */}
          <div className="flex flex-col gap-y-px leading-snug">
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Home className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Untuk Anda</span>
            </button>

            {onOpenCreateModal && (
              <button
                type="button"
                onClick={() => {
                  onClose();
                  onOpenCreateModal();
                }}
                className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-semibold text-[#1d64ec] hover:bg-blue-50 active:bg-blue-100/80 transition-colors cursor-pointer leading-snug text-left"
              >
                <PlusCircle className="w-4 h-4 text-[#1d64ec] stroke-[2] shrink-0" />
                <span className="truncate">Utas baru</span>
              </button>
            )}

            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Search className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Cari & Jelajah</span>
            </button>
          </div>

          {/* Section 2: Aktivitas & Profil Pengguna */}
          <div className="flex flex-col gap-y-px pt-2 border-t border-neutral-100 leading-snug">
            {/* Pesan */}
            <button
              type="button"
              onClick={() => {
                onClose();
              }}
              className="flex items-center justify-between h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="flex items-center gap-2.5 min-w-0">
                <MessageCircle className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
                <span className="truncate">Pesan</span>
              </div>
              <span className="min-w-[16px] h-[16px] px-1 rounded-full bg-[#ff3040] text-white text-[10px] font-bold flex items-center justify-center leading-none shadow-2xs">
                1
              </span>
            </button>

            {/* Notifikasi / Aktivitas */}
            <button
              type="button"
              onClick={() => {
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Bell className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Notifikasi</span>
            </button>

            {/* Profil */}
            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <User className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Profil</span>
            </button>

            {/* Insight & Statistik */}
            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <BarChart2 className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Insight</span>
            </button>

            {/* Tersimpan */}
            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Bookmark className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Tersimpan</span>
            </button>
          </div>

          {/* Section 3: Kabar & Topik */}
          <div className="flex flex-col gap-y-px pt-2 border-t border-neutral-100 leading-snug">
            <div className="flex justify-between items-center py-1 px-2 h-[21px] text-[11px] font-semibold text-neutral-400 uppercase tracking-wider leading-snug">
              <span>Kabar</span>
              <span className="text-[10.5px] text-neutral-400 font-normal lowercase">kategori</span>
            </div>

            {/* AI Threads */}
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Sparkles className="w-4 h-4 text-amber-500 stroke-[2] shrink-0" />
              <span className="truncate">AI Threads</span>
            </button>

            {/* Design Threads */}
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Layers className="w-4 h-4 text-purple-600 stroke-[2] shrink-0" />
              <span className="truncate">Design Threads</span>
            </button>

            {/* Keranjang Belanja */}
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center justify-between h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <div className="flex items-center gap-2.5 min-w-0">
                <ShoppingCart className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
                <span className="truncate">Keranjang</span>
              </div>
              {totalCartCount > 0 && (
                <span className="px-1.5 py-0.2 text-[10.5px] font-bold bg-[#1d64ec] text-white rounded-full leading-none">
                  {totalCartCount}
                </span>
              )}
            </button>

            {/* Pesanan */}
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <ShoppingBag className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Pesanan</span>
            </button>
          </div>

          {/* Section 4: Lebih Banyak */}
          <div className="flex flex-col gap-y-px pt-2 border-t border-neutral-100 leading-snug">
            <div className="py-1 px-2 text-[11px] font-semibold text-neutral-400 uppercase tracking-wider leading-snug">
              Lebih banyak
            </div>

            <button
              type="button"
              onClick={() => {
                onNavigateDownload();
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-semibold text-emerald-600 hover:bg-emerald-50 active:bg-emerald-100/80 transition-colors cursor-pointer leading-snug text-left"
            >
              <Smartphone className="w-4 h-4 text-emerald-600 stroke-[2] shrink-0" />
              <span className="truncate">Pasang PWA</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[14px] font-medium text-slate-700 hover:text-slate-950 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer leading-snug text-left"
            >
              <Settings className="w-4 h-4 text-neutral-500 stroke-[2] shrink-0" />
              <span className="truncate">Pengaturan</span>
            </button>
          </div>
        </div>

        {/* 4. Footer: Logout & Version Subtext */}
        <div className="py-2.5 border-t border-neutral-100 bg-white space-y-1 shrink-0 leading-snug">
          <button
            type="button"
            onClick={handleLogout}
            className="flex items-center gap-2.5 h-[34px] w-full px-2 rounded-lg text-[13.5px] font-semibold text-rose-600 hover:bg-rose-50 active:bg-rose-100/80 transition-colors cursor-pointer leading-snug"
          >
            <LogOut className="w-4 h-4 text-rose-600 stroke-[2] shrink-0" />
            <span className="truncate">Keluar Akun</span>
          </button>

          <div className="text-center pt-0.5">
            <p className="text-[10.5px] text-neutral-400 font-medium leading-tight">
              Snapan Market PWA v0.1.0
            </p>
          </div>
        </div>
      </aside>
    </div>
  );
};

