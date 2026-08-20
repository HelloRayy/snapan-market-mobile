import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
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

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 overflow-hidden font-gt-standard">
          {/* Backdrop Blur Overlay */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.22, ease: 'easeOut' }}
            onClick={onClose}
            className="absolute inset-0 bg-black/60 backdrop-blur-xs cursor-pointer"
          />

          {/* Drawer Slide-Over Panel from Left */}
          <motion.aside
            initial={{ x: '-100%' }}
            animate={{ x: 0 }}
            exit={{ x: '-100%' }}
            transition={{ type: 'tween', duration: 0.25, ease: [0.32, 0.72, 0, 1] }}
            className="absolute top-0 bottom-0 left-0 w-[84%] max-w-[320px] bg-white shadow-2xl flex flex-col z-10 select-none overflow-hidden"
            style={{
              paddingTop: 'env(safe-area-inset-top, 0px)',
              paddingBottom: 'env(safe-area-inset-bottom, 0px)',
            }}
          >
            {/* 1. Header: Close Button & App Title */}
            <div className="p-4 flex items-center justify-between border-b border-neutral-100">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-xs">
                  <Store className="w-4 h-4 text-white stroke-[2.25]" />
                </div>
                <span className="font-bold text-[15px] text-slate-900 tracking-tight">Snapan Market</span>
              </div>

              <button
                type="button"
                onClick={onClose}
                className="w-8 h-8 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-600 active:scale-90 transition-all cursor-pointer"
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
              className="p-4 bg-neutral-50/80 hover:bg-neutral-100/70 border-b border-neutral-100 transition-colors cursor-pointer flex items-center gap-3 group"
            >
              <div className="w-12 h-12 rounded-full overflow-hidden ring-2 ring-white shadow-xs shrink-0">
                <img src={myAvatar} alt={myName} className="w-full h-full object-cover" />
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-1.5">
                  <h3 className="font-bold text-[14.5px] text-slate-900 truncate">{myName}</h3>
                  <ClickableVerifiedBadge className="w-4 h-4" />
                </div>
                <p className="text-xs text-neutral-500 truncate">@{myUsername}</p>
                <p className="text-[11.5px] font-medium text-[#1d64ec] mt-0.5">{myClassGroup}</p>
              </div>

              <ChevronRight className="w-4 h-4 text-neutral-400 group-hover:text-slate-900 group-hover:translate-x-0.5 transition-all" />
            </div>

            {/* 3. Scrollable Navigation Menu List */}
            <div className="flex-1 overflow-y-auto px-3 py-3 space-y-4">
              {/* Group 1: Navigasi Utama */}
              <div className="space-y-0.5">
                <p className="px-3 text-[11px] font-semibold tracking-wider text-neutral-400 uppercase">
                  Menu Utama
                </p>

                <button
                  type="button"
                  onClick={() => {
                    onNavigateHome();
                    onClose();
                  }}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
                >
                  <Home className="w-4.5 h-4.5 text-slate-600 stroke-[2]" />
                  <span>Beranda Feed</span>
                </button>

                <button
                  type="button"
                  onClick={() => {
                    onNavigateProfile(myUsername);
                    onClose();
                  }}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
                >
                  <User className="w-4.5 h-4.5 text-slate-600 stroke-[2]" />
                  <span>Profil Akun Saya</span>
                </button>

                {onOpenCreateModal && (
                  <button
                    type="button"
                    onClick={() => {
                      onClose();
                      onOpenCreateModal();
                    }}
                    className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-[#1d64ec] hover:bg-blue-50/70 active:bg-blue-100/70 transition-colors cursor-pointer"
                  >
                    <PlusCircle className="w-4.5 h-4.5 text-[#1d64ec] stroke-[2]" />
                    <span>Buat Utas / Jual Produk</span>
                  </button>
                )}
              </div>

              {/* Group 2: E-Commerce & Marketplace */}
              <div className="space-y-0.5 pt-2 border-t border-neutral-100">
                <p className="px-3 text-[11px] font-semibold tracking-wider text-neutral-400 uppercase">
                  Marketplace
                </p>

                <button
                  type="button"
                  onClick={() => {
                    onNavigateHome();
                    onClose();
                  }}
                  className="w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
                >
                  <div className="flex items-center gap-3">
                    <ShoppingCart className="w-4.5 h-4.5 text-slate-600 stroke-[2]" />
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
                    onNavigateProfile(myUsername);
                    onClose();
                  }}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
                >
                  <ShoppingBag className="w-4.5 h-4.5 text-slate-600 stroke-[2]" />
                  <span>Pesanan & Transaksi</span>
                </button>

                <button
                  type="button"
                  onClick={() => {
                    onNavigateProfile(myUsername);
                    onClose();
                  }}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
                >
                  <Bookmark className="w-4.5 h-4.5 text-slate-600 stroke-[2]" />
                  <span>Tersimpan / Bookmark</span>
                </button>
              </div>

              {/* Group 3: Aplikasi & Pengaturan */}
              <div className="space-y-0.5 pt-2 border-t border-neutral-100">
                <p className="px-3 text-[11px] font-semibold tracking-wider text-neutral-400 uppercase">
                  Aplikasi
                </p>

                <button
                  type="button"
                  onClick={() => {
                    onNavigateDownload();
                    onClose();
                  }}
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
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
                  className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-slate-800 hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors cursor-pointer"
                >
                  <Settings className="w-4.5 h-4.5 text-slate-600 stroke-[2]" />
                  <span>Pengaturan Akun</span>
                </button>
              </div>
            </div>

            {/* 4. Footer: Logout & App Version */}
            <div className="p-3 border-t border-neutral-100 bg-neutral-50/50 space-y-2">
              <button
                type="button"
                onClick={handleLogout}
                className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13.5px] font-medium text-red-600 hover:bg-red-50 active:bg-red-100/70 transition-colors cursor-pointer"
              >
                <LogOut className="w-4.5 h-4.5 text-red-600 stroke-[2]" />
                <span>Keluar Akun</span>
              </button>

              <div className="text-center">
                <p className="text-[11px] text-neutral-400 font-medium">
                  Snapan Market PWA · SMKN 8 Jakarta v0.1.0
                </p>
              </div>
            </div>
          </motion.aside>
        </div>
      )}
    </AnimatePresence>
  );
};
