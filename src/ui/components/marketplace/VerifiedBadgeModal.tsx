import React, { useState, useRef, useEffect } from 'react';
import { BadgeCheck, X, HelpCircle, CheckCircle2 } from 'lucide-react';

interface VerifiedBadgeModalProps {
  isOpen: boolean;
  onClose: () => void;
  sellerName?: string;
}

export const VerifiedBadgeModal: React.FC<VerifiedBadgeModalProps> = ({
  isOpen,
  onClose,
  sellerName = 'Penjual',
}) => {
  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4 font-gt-standard select-none animate-in fade-in duration-200"
      onClick={onClose}
    >
      {/* Dark Overlay Backdrop */}
      <div className="absolute inset-0 bg-black/60 backdrop-blur-xs" />

      {/* Modal Dialog Card */}
      <div
        onClick={(e) => e.stopPropagation()}
        className="relative w-full max-w-sm bg-white rounded-3xl p-5 shadow-2xl border border-neutral-200/80 z-10 space-y-4 animate-in zoom-in-95 duration-200"
      >
        {/* Top Header: Badge Icon + Title + Close Button */}
        <div className="flex items-start justify-between gap-3 border-b border-neutral-100 pb-3">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-2xl bg-blue-50 border border-blue-100 flex items-center justify-center shrink-0">
              <BadgeCheck className="w-6 h-6 text-[#1d64ec] fill-[#1d64ec] text-white" />
            </div>
            <div className="flex flex-col">
              <h3 className="font-bold text-base text-slate-900 leading-tight">
                Penjual Terverifikasi
              </h3>
              <span className="text-[11px] font-medium text-[#1d64ec]">
                Verified Seller Badge
              </span>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-neutral-100 hover:bg-neutral-200/80 flex items-center justify-center text-slate-700 transition-colors cursor-pointer active:scale-95 shrink-0"
            aria-label="Tutup Informasi"
          >
            <X className="w-4 h-4 stroke-[2.2]" />
          </button>
        </div>

        {/* Description Body */}
        <div className="space-y-3">
          <p className="text-xs text-slate-700 font-normal leading-relaxed">
            <strong className="font-semibold text-slate-900">{sellerName}</strong> telah terverifikasi resmi oleh Admin Snapan Market sebagai penjual aktif & terpercaya di lingkungan sekolah.
          </p>

          {/* Requirements list */}
          <div className="rounded-2xl bg-neutral-50 border border-neutral-200/80 p-3.5 space-y-2">
            <div className="flex items-center gap-1.5 text-xs font-semibold text-slate-900">
              <HelpCircle className="w-4 h-4 text-[#1d64ec] stroke-[2.2] shrink-0" />
              <span>Syarat Mendapatkan Badge:</span>
            </div>

            <ul className="space-y-2 text-[11.5px] text-slate-600 font-normal leading-relaxed pt-1.5 border-t border-neutral-200/60">
              <li className="flex items-start gap-2">
                <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 stroke-[2.2] shrink-0 mt-0.5" />
                <span>Minimal <strong>3 transaksi penjualan berhasil</strong> yang dikonfirmasi oleh pembeli.</span>
              </li>
              <li className="flex items-start gap-2">
                <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 stroke-[2.2] shrink-0 mt-0.5" />
                <span>Identitas siswa & kelas terverifikasi di database SMKN 8.</span>
              </li>
              <li className="flex items-start gap-2">
                <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 stroke-[2.2] shrink-0 mt-0.5" />
                <span>Reputasi toko bersih tanpa laporan pelanggaran atau spam.</span>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Button */}
        <button
          type="button"
          onClick={onClose}
          className="w-full py-2.5 rounded-xl bg-slate-900 hover:bg-black text-white font-medium text-xs active:scale-[0.98] transition-all cursor-pointer shadow-xs"
        >
          Mengerti
        </button>
      </div>
    </div>
  );
};

interface ClickableVerifiedBadgeProps {
  sellerName?: string;
  className?: string;
}

export const ClickableVerifiedBadge: React.FC<ClickableVerifiedBadgeProps> = ({
  sellerName = 'Penjual',
  className = 'w-[17px] h-[17px]',
}) => {
  const [isTooltipOpen, setIsTooltipOpen] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [showDetailsInline, setShowDetailsInline] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  // Close tooltip on click outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsTooltipOpen(false);
        setShowDetailsInline(false);
      }
    };
    if (isTooltipOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [isTooltipOpen]);

  return (
    <div ref={containerRef} className="relative inline-flex items-center">
      {/* Clickable Badge Checkmark Trigger */}
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          setIsTooltipOpen(!isTooltipOpen);
          setShowDetailsInline(false);
        }}
        className="inline-flex items-center shrink-0 cursor-pointer hover:opacity-80 active:scale-90 transition-transform select-none"
        title="Klik untuk info Penjual Terverifikasi"
        aria-label="Penjual Terverifikasi"
      >
        <BadgeCheck className={`${className} text-[#1d64ec] fill-[#1d64ec] text-white`} />
      </button>

      {/* Floating Popover Tooltip (Appears right under the badge checkmark) */}
      {isTooltipOpen && (
        <div
          onClick={(e) => e.stopPropagation()}
          className="absolute top-full mt-2 left-0 sm:left-1/2 sm:-translate-x-1/2 w-64 bg-[#18181b] text-white rounded-2xl p-3.5 shadow-2xl border border-neutral-700/80 z-50 font-gt-standard select-none animate-in fade-in zoom-in-95 duration-150 space-y-2"
        >
          {/* Top Caret Pointer */}
          <div className="absolute -top-1.5 left-3 sm:left-1/2 sm:-translate-x-1/2 w-3 h-3 bg-[#18181b] rotate-45 border-t border-l border-neutral-700/80" />

          {/* Tooltip Header */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5 font-bold text-xs text-white">
              <BadgeCheck className="w-4 h-4 text-blue-400 fill-blue-400 text-white shrink-0" />
              <span>Penjual Terverifikasi</span>
            </div>
            <button
              type="button"
              onClick={() => setIsTooltipOpen(false)}
              className="text-neutral-400 hover:text-white p-0.5 rounded-full hover:bg-neutral-800 transition-colors"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          </div>

          {/* Short Tooltip Description */}
          <p className="text-[11.5px] text-neutral-300 font-normal leading-relaxed">
            <strong className="text-white font-medium">{sellerName}</strong> terverifikasi resmi oleh Admin Snapan Market.
          </p>

          {/* Clickable "? Cara Mendapatkan Badge" Trigger */}
          {!showDetailsInline ? (
            <button
              type="button"
              onClick={() => setShowDetailsInline(true)}
              className="flex items-center gap-1 text-[11px] font-semibold text-blue-400 hover:text-blue-300 hover:underline pt-1 cursor-pointer transition-colors"
            >
              <HelpCircle className="w-3.5 h-3.5 text-blue-400 stroke-[2.2] shrink-0" />
              <span>? Cara Mendapatkan Badge</span>
            </button>
          ) : (
            /* Expanded Inline Details inside Tooltip */
            <div className="pt-2 border-t border-neutral-800 space-y-1.5 animate-in fade-in duration-200">
              <span className="text-[11px] font-semibold text-blue-400 flex items-center gap-1">
                <HelpCircle className="w-3.5 h-3.5 stroke-[2.2]" />
                Syarat Verifikasi:
              </span>
              <ul className="space-y-1 text-[11px] text-neutral-300 leading-normal">
                <li className="flex items-start gap-1.5">
                  <CheckCircle2 className="w-3 h-3 text-emerald-400 shrink-0 mt-0.5" />
                  <span>Minimal <strong>3 penjualan berhasil</strong>.</span>
                </li>
                <li className="flex items-start gap-2">
                  <CheckCircle2 className="w-3 h-3 text-emerald-400 shrink-0 mt-0.5" />
                  <span>Siswa aktif & terverifikasi admin.</span>
                </li>
              </ul>
              <button
                type="button"
                onClick={() => {
                  setIsTooltipOpen(false);
                  setIsModalOpen(true);
                }}
                className="text-[10.5px] text-neutral-400 hover:text-white underline pt-1 block cursor-pointer"
              >
                Lihat detail lengkap modal...
              </button>
            </div>
          )}
        </div>
      )}

      {/* Full Modal fallback if clicked detail */}
      <VerifiedBadgeModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        sellerName={sellerName}
      />
    </div>
  );
};
