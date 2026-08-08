import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
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
      className="fixed inset-0 z-[100000] flex items-center justify-center p-4 font-gt-standard select-none animate-in fade-in duration-200"
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
  const [tooltipPos, setTooltipPos] = useState<{ top: number; left: number; arrowLeft: number } | null>(null);

  const buttonRef = useRef<HTMLButtonElement>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);

  const updatePosition = () => {
    if (buttonRef.current) {
      const rect = buttonRef.current.getBoundingClientRect();
      const tooltipWidth = 260; // 260px width
      const centerLeft = rect.left + rect.width / 2;

      // Ensure tooltip stays within viewport screen padding
      const clampedLeft = Math.max(
        tooltipWidth / 2 + 12,
        Math.min(window.innerWidth - tooltipWidth / 2 - 12, centerLeft)
      );

      // Arrow position relative to tooltip box center
      const arrowOffset = centerLeft - clampedLeft;

      setTooltipPos({
        top: rect.top - 10, // 10px above icon
        left: clampedLeft,
        arrowLeft: tooltipWidth / 2 + arrowOffset,
      });
    }
  };

  const handleToggleTooltip = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!isTooltipOpen) {
      updatePosition();
      setShowDetailsInline(false);
      setIsTooltipOpen(true);
    } else {
      setIsTooltipOpen(false);
    }
  };

  // Update position on scroll or resize when open & handle click outside
  useEffect(() => {
    if (!isTooltipOpen) return;

    const handleScrollOrResize = () => updatePosition();
    const handleClickOutside = (event: MouseEvent) => {
      if (
        buttonRef.current &&
        !buttonRef.current.contains(event.target as Node) &&
        tooltipRef.current &&
        !tooltipRef.current.contains(event.target as Node)
      ) {
        setIsTooltipOpen(false);
        setShowDetailsInline(false);
      }
    };

    window.addEventListener('scroll', handleScrollOrResize, true);
    window.addEventListener('resize', handleScrollOrResize);
    document.addEventListener('mousedown', handleClickOutside);

    return () => {
      window.removeEventListener('scroll', handleScrollOrResize, true);
      window.removeEventListener('resize', handleScrollOrResize);
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isTooltipOpen]);

  return (
    <span className="inline-flex items-center">
      {/* Clickable Badge Checkmark Trigger */}
      <button
        ref={buttonRef}
        type="button"
        onClick={handleToggleTooltip}
        className="inline-flex items-center shrink-0 cursor-pointer hover:opacity-80 active:scale-90 transition-transform select-none"
        title="Klik untuk info Penjual Terverifikasi"
        aria-label="Penjual Terverifikasi"
      >
        <BadgeCheck className={`${className} text-[#1d64ec] fill-[#1d64ec] text-white`} />
      </button>

      {/* Floating React Portal Popover Tooltip (Rendered to document.body with max z-index: 999999) */}
      {isTooltipOpen &&
        tooltipPos &&
        createPortal(
          <div
            ref={tooltipRef}
            onClick={(e) => e.stopPropagation()}
            style={{
              position: 'fixed',
              top: `${tooltipPos.top}px`,
              left: `${tooltipPos.left}px`,
              transform: 'translate(-50%, -100%)',
              zIndex: 999999,
            }}
            className="w-65 bg-white text-slate-900 rounded-2xl p-3.5 shadow-[0_12px_45px_rgba(0,0,0,0.22)] border border-neutral-200/90 font-gt-standard select-none animate-in fade-in zoom-in-95 duration-150 space-y-2 pointer-events-auto"
          >
            {/* Bottom Caret Pointer pointing down to badge icon */}
            <div
              style={{ left: `${tooltipPos.arrowLeft}px` }}
              className="absolute -bottom-1.5 -translate-x-1/2 w-3.5 h-3.5 bg-white rotate-45 border-b border-r border-neutral-200/90"
            />

            {/* Tooltip Header */}
            <div className="flex items-center justify-between relative z-10">
              <div className="flex items-center gap-1.5 font-bold text-xs text-slate-900">
                <BadgeCheck className="w-4 h-4 text-[#1d64ec] fill-[#1d64ec] text-white shrink-0" />
                <span>Penjual Terverifikasi</span>
              </div>
              <button
                type="button"
                onClick={() => setIsTooltipOpen(false)}
                className="text-neutral-400 hover:text-slate-900 p-0.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* Short Tooltip Description */}
            <p className="text-[11.5px] text-neutral-600 font-normal leading-relaxed relative z-10">
              <strong className="text-slate-900 font-medium">{sellerName}</strong> terverifikasi resmi oleh Admin Snapan Market.
            </p>

            {/* Clickable "? Cara Mendapatkan Badge" Trigger */}
            {!showDetailsInline ? (
              <button
                type="button"
                onClick={() => setShowDetailsInline(true)}
                className="flex items-center gap-1 text-[11px] font-semibold text-[#1d64ec] hover:underline pt-1 cursor-pointer transition-colors relative z-10"
              >
                <HelpCircle className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                <span>? Cara Mendapatkan Badge</span>
              </button>
            ) : (
              /* Expanded Inline Details inside Tooltip */
              <div className="pt-2 border-t border-neutral-100 space-y-1.5 animate-in fade-in duration-200 bg-neutral-50 -mx-1.5 p-2 rounded-xl border border-neutral-200/60 relative z-10">
                <span className="text-[11px] font-semibold text-[#1d64ec] flex items-center gap-1">
                  <HelpCircle className="w-3.5 h-3.5 stroke-[2.2]" />
                  Syarat Verifikasi:
                </span>
                <ul className="space-y-1 text-[11px] text-slate-700 leading-normal">
                  <li className="flex items-start gap-1.5">
                    <CheckCircle2 className="w-3 h-3 text-emerald-500 shrink-0 mt-0.5" />
                    <span>Minimal <strong>3 penjualan berhasil</strong>.</span>
                  </li>
                  <li className="flex items-start gap-1.5">
                    <CheckCircle2 className="w-3 h-3 text-emerald-500 shrink-0 mt-0.5" />
                    <span>Siswa aktif & terverifikasi admin.</span>
                  </li>
                </ul>
                <button
                  type="button"
                  onClick={() => {
                    setIsTooltipOpen(false);
                    setIsModalOpen(true);
                  }}
                  className="text-[10.5px] text-[#1d64ec] font-semibold hover:underline pt-1 block cursor-pointer"
                >
                  Lihat detail lengkap modal...
                </button>
              </div>
            )}
          </div>,
          document.body
        )}

      {/* Full Modal fallback if clicked detail */}
      <VerifiedBadgeModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        sellerName={sellerName}
      />
    </span>
  );
};
