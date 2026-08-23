import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Bookmark,
  BookmarkCheck,
  Copy,
  BellOff,
  EyeOff,
  Flag,
  X,
  Trash2,
  Edit3,
  Check
} from 'lucide-react';
import { ConfirmActionModal } from '@/ui/components/ui/ConfirmActionModal';

export interface PostOptionsModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  authorName: string;
  authorUsername?: string;
  isSaved?: boolean;
  onToggleSave?: () => void;
  onCopyLink?: () => void;
  onMute?: () => void;
  onHide?: () => void;
  onReport?: () => void;
  isOwner?: boolean;
  onDelete?: () => void;
  onEdit?: () => void;
}

export const PostOptionsModal: React.FC<PostOptionsModalProps> = ({
  isOpen,
  onClose,
  title = 'Opsi Postingan',
  authorName,
  authorUsername,
  isSaved = false,
  onToggleSave,
  onCopyLink,
  onMute,
  onHide,
  onReport,
  isOwner = false,
  onDelete,
  onEdit,
}) => {
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
  };

  const handleCopyLink = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (onCopyLink) {
      onCopyLink();
    } else {
      navigator.clipboard?.writeText(window.location.href);
      showToast('Tautan berhasil disalin ke papan klip! 📋');
    }
    setTimeout(() => onClose(), 600);
  };

  const handleToggleSave = (e: React.MouseEvent) => {
    e.stopPropagation();
    onToggleSave?.();
    showToast(isSaved ? 'Dihapus dari markah 🔖' : 'Disimpan ke markah tersimpan 🔖');
    setTimeout(() => onClose(), 600);
  };

  const handleMute = (e: React.MouseEvent) => {
    e.stopPropagation();
    onMute?.();
    showToast(`Notifikasi dari @${authorUsername || authorName} disenyapkan 🔇`);
    setTimeout(() => onClose(), 600);
  };

  const handleHide = (e: React.MouseEvent) => {
    e.stopPropagation();
    onHide?.();
    showToast('Postingan disembunyikan dari feed Anda 👁️');
    setTimeout(() => onClose(), 600);
  };

  const handleReport = (e: React.MouseEvent) => {
    e.stopPropagation();
    onReport?.();
    showToast('Laporan terkirim! Terima kasih atas masukan Anda 🛡️');
    setTimeout(() => onClose(), 600);
  };

  const handleDeleteClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    setShowDeleteConfirm(true);
  };

  const handleExecuteDelete = () => {
    setShowDeleteConfirm(false);
    onDelete?.();
    showToast('Postingan dihapus 🗑️');
    setTimeout(() => onClose(), 600);
  };

  const handleEdit = (e: React.MouseEvent) => {
    e.stopPropagation();
    onEdit?.();
    onClose();
  };

  const handleBackdropClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <>
      <AnimatePresence>
        {isOpen && (
          <div
            data-lenis-prevent
            onClick={handleBackdropClick}
            className="fixed inset-0 z-[99999] bg-black/50 backdrop-blur-[3px] flex items-end sm:items-center justify-center p-0 sm:p-4 select-none touch-pan-y"
          >
            {/* Toast Banner */}
            {toastMessage && (
              <div className="fixed top-5 left-1/2 -translate-x-1/2 z-[100000] bg-slate-900 text-white px-4 py-2.5 rounded-full text-xs font-semibold shadow-2xl flex items-center gap-2 border border-slate-700 animate-in fade-in slide-in-from-top-3">
                <Check className="w-3.5 h-3.5 text-emerald-400 stroke-[2.5]" />
                <span>{toastMessage}</span>
              </div>
            )}

            <motion.div
              initial={{ y: '100%', opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: '100%', opacity: 0 }}
              transition={{ type: 'spring', damping: 28, stiffness: 320 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full sm:max-w-md bg-white rounded-t-[26px] sm:rounded-[26px] p-4 pb-7 sm:pb-5 shadow-2xl border border-neutral-200 overflow-hidden font-gt-standard"
            >
              {/* Drag Handle Bar for Mobile */}
              <div className="w-10 h-1 bg-neutral-200 rounded-full mx-auto mb-3.5 sm:hidden" />

              {/* Header Title & Close Button */}
              <div className="flex items-center justify-between pb-3 border-b border-neutral-100 mb-3 px-1">
                <div>
                  <h3 className="font-bold text-[15px] text-slate-900 leading-snug">{title}</h3>
                  <p className="text-xs text-neutral-400">@{authorUsername || authorName}</p>
                </div>
                <button
                  type="button"
                  onClick={onClose}
                  className="p-1.5 rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-slate-800 transition-colors cursor-pointer"
                  aria-label="Tutup Opsi"
                >
                  <X className="w-4.5 h-4.5" />
                </button>
              </div>

              {/* Action List Grid */}
              <div className="space-y-1">
                {/* 1. Bookmark / Save Post */}
                <button
                  type="button"
                  onClick={handleToggleSave}
                  className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                >
                  <div className={`p-2.5 rounded-xl ${isSaved ? 'bg-amber-50 text-amber-600' : 'bg-neutral-100 text-slate-700'}`}>
                    {isSaved ? (
                      <BookmarkCheck className="w-4.5 h-4.5 stroke-[2]" />
                    ) : (
                      <Bookmark className="w-4.5 h-4.5 stroke-[2]" />
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">
                      {isSaved ? 'Hapus dari Markah Tersimpan' : 'Simpan ke Markah'}
                    </p>
                    <p className="text-[11px] text-neutral-400 truncate">
                      {isSaved ? 'Dihapus dari tab markah akun Anda' : 'Simpan postingan ini untuk dibaca nanti'}
                    </p>
                  </div>
                </button>

                {/* 2. Copy Link */}
                <button
                  type="button"
                  onClick={handleCopyLink}
                  className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                >
                  <div className="p-2.5 rounded-xl bg-neutral-100 text-slate-700">
                    <Copy className="w-4.5 h-4.5 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">Salin Tautan</p>
                    <p className="text-[11px] text-neutral-400 truncate">Salin URL tautan postingan ke papan klip</p>
                  </div>
                </button>

                {/* Owner Options (Edit / Delete) */}
                {isOwner ? (
                  <>
                    {/* Owner Edit Option */}
                    {onEdit && (
                      <button
                        type="button"
                        onClick={handleEdit}
                        className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                      >
                        <div className="p-2.5 rounded-xl bg-neutral-100 text-slate-700">
                          <Edit3 className="w-4.5 h-4.5 stroke-[2]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-xs font-semibold text-slate-900">Edit Postingan</p>
                          <p className="text-[11px] text-neutral-400 truncate">Ubah isi atau foto postingan ini</p>
                        </div>
                      </button>
                    )}

                    {/* Owner Delete Option */}
                    {onDelete && (
                      <button
                        type="button"
                        onClick={handleDeleteClick}
                        className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-rose-50 active:bg-rose-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                      >
                        <div className="p-2.5 rounded-xl bg-rose-50 text-rose-600">
                          <Trash2 className="w-4.5 h-4.5 stroke-[2]" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-xs font-semibold text-rose-600">Hapus Postingan</p>
                          <p className="text-[11px] text-rose-400 truncate">Hapus postingan ini secara permanen</p>
                        </div>
                      </button>
                    )}
                  </>
                ) : null}

                {/* 3. Mute User */}
                <button
                  type="button"
                  onClick={handleMute}
                  className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                >
                  <div className="p-2.5 rounded-xl bg-neutral-100 text-slate-700">
                    <BellOff className="w-4.5 h-4.5 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">
                      Senyapkan @{authorUsername || authorName}
                    </p>
                    <p className="text-[11px] text-neutral-400 truncate">Sembunyikan notifikasi dari pengguna ini</p>
                  </div>
                </button>

                {/* 4. Hide Post */}
                <button
                  type="button"
                  onClick={handleHide}
                  className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                >
                  <div className="p-2.5 rounded-xl bg-neutral-100 text-slate-700">
                    <EyeOff className="w-4.5 h-4.5 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">Sembunyikan Postingan</p>
                    <p className="text-[11px] text-neutral-400 truncate">Saya tidak tertarik dengan postingan ini</p>
                  </div>
                </button>

                {/* 5. Report Post */}
                <button
                  type="button"
                  onClick={handleReport}
                  className="w-full flex items-center gap-3 p-3 rounded-2xl hover:bg-rose-50 active:bg-rose-100 active:scale-[0.98] transition-all text-left cursor-pointer group"
                >
                  <div className="p-2.5 rounded-xl bg-rose-50 text-rose-600">
                    <Flag className="w-4.5 h-4.5 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-rose-600">Laporkan</p>
                    <p className="text-[11px] text-rose-400 truncate">Laporkan konten yang melanggar panduan komunitas</p>
                  </div>
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Reusable Delete Post Confirmation Dialog */}
      <ConfirmActionModal
        isOpen={showDeleteConfirm}
        onClose={() => setShowDeleteConfirm(false)}
        title="Hapus postingan?"
        description="Postingan ini akan dihapus secara permanen dan tidak dapat dipulihkan."
        actions={[
          {
            label: 'Hapus',
            variant: 'destructive',
            onClick: handleExecuteDelete,
          },
          {
            label: 'Batal',
            variant: 'cancel',
            onClick: () => setShowDeleteConfirm(false),
          },
        ]}
      />
    </>
  );
};
