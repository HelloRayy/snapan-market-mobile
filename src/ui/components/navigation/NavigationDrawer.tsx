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

      {/* Drawer Slide-Over Panel from Left (Clean Modern Light Styling) */}
      <aside
        className="absolute top-0 bottom-0 left-0 w-[84%] max-w-[310px] bg-white text-slate-900 shadow-2xl flex flex-col z-10 select-none overflow-hidden transform-gpu animate-drawer-slide border-r border-neutral-200/80"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
          paddingBottom: 'env(safe-area-inset-bottom, 0px)',
          willChange: 'transform',
        }}
      >
        {/* 1. Header: Close Button & App Title */}
        <div className="p-4 flex items-center justify-between border-b border-neutral-100">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-neutral-100 border border-neutral-200/80 flex items-center justify-center text-slate-900 shadow-2xs">
              <Store className="w-4 h-4 text-slate-900 stroke-[2.2]" />
            </div>
            <span className="font-bold text-[15px] text-slate-900 tracking-tight">Snapan Market</span>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-neutral-100 active:bg-neutral-200/80 flex items-center justify-center text-neutral-400 hover:text-slate-800 active:scale-90 transition-all cursor-pointer"
            aria-label="Tutup Menu"
          >
            <X className="w-5 h-5 stroke-[2]" />
          </button>
        </div>

        {/* 2. User Profile Summary Box (Clickable to Profile) */}
        <div
          onClick={() => {
            onNavigateProfile(myUsername);
            onClose();
          }}
          className="p-3.5 mx-3 mt-3 bg-neutral-50/80 hover:bg-neutral-100 border border-neutral-200/70 rounded-2xl transition-all cursor-pointer flex items-center gap-3 group shadow-2xs"
        >
          <div className="w-11 h-11 rounded-full overflow-hidden ring-2 ring-neutral-200/80 shadow-2xs shrink-0">
            <img src={myAvatar} alt={myName} className="w-full h-full object-cover" />
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5">
              <h3 className="font-bold text-[14px] text-slate-900 truncate">{myName}</h3>
              <ClickableVerifiedBadge className="w-4 h-4" />
            </div>
            <p className="text-xs text-neutral-500 truncate">@{myUsername}</p>
            <p className="text-[11px] font-semibold text-[#1d64ec] mt-0.5">{myClassGroup}</p>
          </div>

          <ChevronRight className="w-4 h-4 text-neutral-400 group-hover:text-slate-800 group-hover:translate-x-0.5 transition-all" />
        </div>

        {/* 3. Scrollable Navigation Menu List (Light Theme Structure) */}
        <div className="flex-1 overflow-y-auto px-3 py-3 space-y-4 scrollbar-none">
          {/* Section 1: Feed Utama & Aksi Cepat */}
          <div className="space-y-0.5">
            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Home className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Untuk Anda</span>
            </button>

            {onOpenCreateModal && (
              <button
                type="button"
                onClick={() => {
                  onClose();
                  onOpenCreateModal();
                }}
                className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-semibold text-[#1d64ec] hover:bg-blue-50 active:bg-blue-100/80 transition-colors cursor-pointer"
              >
                <PlusCircle className="w-4.5 h-4.5 text-[#1d64ec] stroke-[2]" />
                <span>Utas baru / Jual</span>
              </button>
            )}

            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Search className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Cari & Jelajah</span>
            </button>
          </div>

          {/* Section 2: Sosial & Aktivitas */}
          <div className="space-y-0.5 pt-2 border-t border-neutral-100">
            {/* Pesan with Badge */}
            <button
              type="button"
              onClick={() => {
                onClose();
              }}
              className="w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <div className="flex items-center gap-3.5">
                <MessageCircle className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
                <span>Pesan</span>
              </div>
              <span className="min-w-[18px] h-[18px] px-1.5 rounded-full bg-[#ff3040] text-white text-[11px] font-bold flex items-center justify-center shadow-2xs">
                1
              </span>
            </button>

            <button
              type="button"
              onClick={() => {
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Bell className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Notifikasi</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <User className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Profil</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <BarChart2 className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Insight & Statistik</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Bookmark className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Tersimpan</span>
            </button>
          </div>

          {/* Section 3: Kabar & Marketplace Sekolah */}
          <div className="space-y-0.5 pt-2 border-t border-neutral-100">
            <div className="flex items-center justify-between px-3 py-1 text-[11.5px] font-semibold text-neutral-400 uppercase tracking-wider">
              <span>Kabar & Topik</span>
              <span className="text-[11px] text-neutral-400 font-normal lowercase">kategori</span>
            </div>

            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <div className="flex items-center gap-3.5">
                <ShoppingCart className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
                <span>Keranjang Belanja</span>
              </div>
              {totalCartCount > 0 && (
                <span className="px-2 py-0.5 text-xs font-bold bg-[#1d64ec] text-white rounded-full">
                  {totalCartCount}
                </span>
              )}
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <ShoppingBag className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Pesanan & Transaksi</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Sparkles className="w-4.5 h-4.5 text-amber-500 stroke-[2]" />
              <span>AI & Joki Coding</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateHome();
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Layers className="w-4.5 h-4.5 text-purple-600 stroke-[2]" />
              <span>Design & DKV Threads</span>
            </button>
          </div>

          {/* Section 4: Aplikasi & Pengaturan */}
          <div className="space-y-0.5 pt-2 border-t border-neutral-100">
            <p className="px-3 text-[11px] font-semibold tracking-wider text-neutral-400 uppercase">
              Lebih Banyak
            </p>

            <button
              type="button"
              onClick={() => {
                onNavigateDownload();
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-semibold text-emerald-600 hover:bg-emerald-50 active:bg-emerald-100/80 transition-colors cursor-pointer"
            >
              <Smartphone className="w-4.5 h-4.5 text-emerald-600 stroke-[2]" />
              <span>Pasang Aplikasi PWA</span>
            </button>

            <button
              type="button"
              onClick={() => {
                onNavigateProfile(myUsername);
                onClose();
              }}
              className="w-full flex items-center gap-3.5 px-3 py-2.5 rounded-xl text-[14px] font-medium text-slate-700 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors cursor-pointer"
            >
              <Settings className="w-4.5 h-4.5 text-neutral-500 stroke-[2]" />
              <span>Pengaturan Akun</span>
            </button>
          </div>
        </div>

        {/* 4. Footer: Logout & Version Subtext */}
        <div className="p-3 border-t border-neutral-100 bg-neutral-50/50 space-y-2">
          <button
            type="button"
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-semibold text-rose-600 hover:bg-rose-50 active:bg-rose-100/80 transition-colors cursor-pointer"
          >
            <LogOut className="w-4.5 h-4.5 text-rose-600 stroke-[2]" />
            <span>Keluar Akun</span>
          </button>

          <div className="text-center">
            <p className="text-[11px] text-neutral-400 font-medium">
              Snapan Market PWA · SMKN 8 Jakarta v0.1.0
            </p>
          </div>
        </div>
      </aside>
    </div>
  );
};

