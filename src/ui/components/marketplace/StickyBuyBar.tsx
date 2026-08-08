import React from 'react';
import { ShoppingCart, MessageSquare } from 'lucide-react';

interface StickyBuyBarProps {
  price?: number;
  originalPrice?: number;
  stockCount?: number;
  onBuyClick?: () => void;
  onChatClick?: () => void;
}

export const StickyBuyBar: React.FC<StickyBuyBarProps> = ({
  price = 150000,
  originalPrice,
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
    <div className="fixed bottom-0 left-0 right-0 max-w-xl mx-auto bg-white/95 backdrop-blur-md border-t border-neutral-200/80 px-4 py-2.5 z-40 font-gt-standard shadow-[0_-4px_20px_rgba(0,0,0,0.06)] flex items-center gap-2.5">
      {/* 1. Secondary Action: "Tanya" Button */}
      <button
        type="button"
        onClick={onChatClick}
        className="h-12 px-3.5 rounded-2xl bg-neutral-100 hover:bg-neutral-200/80 active:scale-95 text-slate-800 font-semibold text-[13px] flex items-center justify-center gap-1.5 border border-neutral-200/60 transition-all cursor-pointer shrink-0 select-none"
        title="Tanyakan ke Penjual / Kolom Komentar"
        aria-label="Tanya Penjual di Komentar"
      >
        <MessageSquare className="w-4 h-4 text-slate-700 stroke-[2.2]" />
        <span>Tanya</span>
      </button>

      {/* 2. Primary Action: Kumo UI Electric Blue Centered Single-Line CTA Button */}
      <button
        type="button"
        onClick={onBuyClick}
        className="relative inline-flex items-center justify-center flex-1 h-12 px-4 rounded-2xl text-white bg-[#1d64ec] border border-[#154ec1] shadow-md shadow-blue-500/20 active:scale-[0.98] transition-all cursor-pointer overflow-hidden shrink-0 select-none group min-w-0"
      >
        {/* Kumo Inset Top Rim Highlight Gradient */}
        <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] transition-all pointer-events-none" />

        {/* Centered Single-Line Content: [🛒 Beli Sekarang • Rp 150.000] */}
        <span className="relative z-10 flex items-center justify-center gap-2 font-semibold text-[15px] text-white tracking-tight truncate">
          <ShoppingCart className="w-4 h-4 text-white stroke-[2.2] shrink-0" />
          <span className="truncate">Beli Sekarang</span>
          <span className="opacity-40 font-normal">•</span>
          <span className="font-bold text-[15px] tracking-tight shrink-0">
            {formatRupiah(price)}
          </span>
          {originalPrice && originalPrice > price && (
            <span className="text-[11px] text-white/70 line-through font-normal shrink-0">
              {formatRupiah(originalPrice)}
            </span>
          )}
        </span>
      </button>
    </div>
  );
};
