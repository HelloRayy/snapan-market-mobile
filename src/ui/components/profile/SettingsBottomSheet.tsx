import React, { useState } from 'react';
import { X, LogOut, ShieldCheck, Share2, Smartphone } from 'lucide-react';
import { useAuth } from '@/ui/hooks/useAuth';
import { ConfirmActionModal } from '@/ui/components/ui/ConfirmActionModal';

interface SettingsBottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  onEditProfileClick: () => void;
}

export const SettingsBottomSheet: React.FC<SettingsBottomSheetProps> = ({
  isOpen,
  onClose,
  onEditProfileClick,
}) => {
  const { signOut, user, profile } = useAuth();
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  if (!isOpen) return null;

  const handleLogout = async () => {
    try {
      await signOut();
      setShowLogoutConfirm(false);
      onClose();
      window.location.href = '/';
    } catch (err) {
      console.error('Logout error:', err);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-xs font-gt-standard animate-backdrop-fade">
      {/* Backdrop */}
      <div
        onClick={onClose}
        className="absolute inset-0 cursor-pointer"
      />

      {/* Modal Container (GPU Accelerated) */}
      <div
        className="relative w-full max-w-lg bg-white rounded-t-3xl sm:rounded-3xl p-5 shadow-2xl z-10 space-y-4 max-h-[85vh] overflow-y-auto transform-gpu animate-sheet-slide"
        style={{ willChange: 'transform' }}
      >
          {/* Header */}
          <div className="flex items-center justify-between pb-3 border-b border-neutral-100">
            <h3 className="font-bold text-base text-slate-900">Pengaturan & Akun</h3>
            <button
              type="button"
              onClick={onClose}
              className="p-1 text-slate-400 hover:text-slate-900 rounded-full hover:bg-neutral-100 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Account Summary */}
          <div className="p-3.5 bg-neutral-50 rounded-2xl border border-neutral-200/80 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-11 h-11 rounded-full overflow-hidden border border-neutral-200 shrink-0">
                <img
                  src={
                    profile?.avatar_url ||
                    user?.user_metadata?.avatar_url ||
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80'
                  }
                  alt="Avatar"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="min-w-0">
                <p className="font-bold text-sm text-slate-900 truncate">
                  {profile?.full_name || user?.user_metadata?.full_name || 'Raditya Rayhan'}
                </p>
                <p className="text-xs text-neutral-400 truncate">
                  {user?.email || 'radityarayhannnn@smkn8.sch.id'}
                </p>
              </div>
            </div>
            <button
              type="button"
              onClick={() => {
                onClose();
                onEditProfileClick();
              }}
              className="px-3 py-1.5 rounded-full text-xs font-bold text-[#1d64ec] bg-blue-50 hover:bg-blue-100 transition-colors cursor-pointer shrink-0"
            >
              Edit
            </button>
          </div>

          {/* Menu Items List */}
          <div className="divide-y divide-neutral-100 text-sm">
            <button
              type="button"
              onClick={() => {
                if (navigator.share) {
                  navigator.share({
                    title: 'Snapan Market Mobile',
                    url: window.location.href,
                  }).catch(() => {});
                }
              }}
              className="w-full py-3 px-2 flex items-center justify-between hover:bg-neutral-50 rounded-xl transition-colors cursor-pointer"
            >
              <div className="flex items-center gap-3 text-slate-700 font-medium">
                <Share2 className="w-5 h-5 text-neutral-400 stroke-[1.8]" />
                <span>Bagikan Profil</span>
              </div>
            </button>

            <div className="w-full py-3 px-2 flex items-center justify-between text-slate-700 font-medium">
              <div className="flex items-center gap-3">
                <Smartphone className="w-5 h-5 text-neutral-400 stroke-[1.8]" />
                <span>Status Aplikasi</span>
              </div>
              <span className="text-xs font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">
                PWA Siap Offline
              </span>
            </div>

            <div className="w-full py-3 px-2 flex items-center justify-between text-slate-700 font-medium">
              <div className="flex items-center gap-3">
                <ShieldCheck className="w-5 h-5 text-neutral-400 stroke-[1.8]" />
                <span>Verifikasi Sekolah</span>
              </div>
              <span className="text-xs font-semibold text-[#1d64ec] bg-blue-50 px-2 py-0.5 rounded-full">
                Siswa Aktif SMKN 8
              </span>
            </div>

            <button
              type="button"
              onClick={() => setShowLogoutConfirm(true)}
              className="w-full py-3 px-2 flex items-center justify-between text-red-600 font-bold hover:bg-red-50 rounded-xl transition-colors cursor-pointer group"
            >
              <div className="flex items-center gap-3">
                <LogOut className="w-5 h-5 stroke-[2] group-hover:translate-x-0.5 transition-transform" />
                <span>Keluar dari Akun</span>
              </div>
            </button>
          </div>

          {/* Footer Info */}
          <div className="pt-2 text-center text-xs text-neutral-400 space-y-0.5">
            <p className="font-semibold text-slate-700">Snapan Market Mobile v0.1.0 (PWA)</p>
            <p>Platform Marketplace & Komunitas Siswa SMKN 8 Jakarta</p>
          </div>
        </div>

        {/* Reusable Logout Confirmation Dialog */}
        <ConfirmActionModal
          isOpen={showLogoutConfirm}
          onClose={() => setShowLogoutConfirm(false)}
          title="Keluar dari akun?"
          description="Anda harus masuk kembali untuk membuat postingan dan berbelanja."
          actions={[
            {
              label: 'Keluar',
              variant: 'destructive',
              onClick: handleLogout,
            },
            {
              label: 'Batal',
              variant: 'cancel',
              onClick: () => setShowLogoutConfirm(false),
            },
          ]}
        />
      </div>
  );
};
