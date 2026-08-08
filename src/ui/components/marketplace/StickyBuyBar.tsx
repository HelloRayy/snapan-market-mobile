import React from 'react';
import { CreditCard, MessageSquare } from 'lucide-react';

interface StickyBuyBarProps {
  price?: number;
  originalPrice?: number;
  stockCount?: number;
  onBuyClick?: () => void;
  onChatClick?: () => void;
}

export const StickyBuyBar: React.FC<StickyBuyBarProps> = ({
  price = 150000,
  onBuyClick,
  onChatClick,
}) => {
  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val);

  return (
    <div className="fixed bottom-0 left-0 right-0 max-w-xl mx-auto z-40 font-gt-standard">
      {/* Full Width White Container with Top-Left & Top-Right Rounded Corners & Safe Area Bottom Padding */}
      <div className="bg-white border-t border-neutral-200/80 px-4 pt-3 pb-7 pb-[calc(1.75rem+env(safe-area-inset-bottom,0px))] rounded-t-[24px] shadow-[0_-4px_25px_rgba(0,0,0,0.08)] space-y-3.5">
        {/* Top Notch / Drag Handle Line */}
        <div className="w-10 h-1 bg-neutral-300/80 rounded-full mx-auto" />

        {/* Buttons Flex Row */}
        <div className="flex items-center gap-3">
        {/* Left Kumo Secondary Button: "Tanya" (Compact Kumo UI Secondary Style) */}
        <button
          type="button"
          onClick={onChatClick}
          className="h-11 px-3.5 rounded-xl bg-white text-[#111827] ring-1 ring-inset ring-[#e5e7eb] shadow-2xs hover:bg-[#f9fafb] active:scale-[0.98] font-semibold text-[13px] flex items-center justify-center gap-1.5 transition-all cursor-pointer shrink-0 select-none"
          title="Tanyakan ke Penjual / Kolom Komentar"
          aria-label="Tanya Penjual di Komentar"
        >
          <MessageSquare className="w-4 h-4 text-slate-700 stroke-[2.2]" />
          <span>Tanya</span>
        </button>

        {/* Right Kumo Primary Button: "Beli • Rp 150.000" (Kumo UI Primary Gradient Style) */}
        <button
          type="button"
          onClick={onBuyClick}
          className="relative inline-flex items-center justify-center gap-1.5 flex-1 h-11 px-4 rounded-xl text-white font-semibold text-[14px] bg-[#1d64ec] border border-[#154ec1] shadow-md shadow-blue-500/20 active:scale-[0.98] transition-all cursor-pointer overflow-hidden select-none group"
        >
          {/* Kumo Inset Top Rim Highlight Gradient */}
          <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] transition-all pointer-events-none" />

          {/* Content Layer */}
          <span className="relative z-10 flex items-center justify-center gap-1.5 truncate">
            <CreditCard className="w-4 h-4 text-white stroke-[2.2] shrink-0" />
            <span className="truncate">Beli • {formatRupiah(price)}</span>
          </span>
        </button>
        </div>
      </div>
    </div>
  );
};
