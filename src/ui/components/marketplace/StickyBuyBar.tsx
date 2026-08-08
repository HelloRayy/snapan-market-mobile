import React from 'react';
import { ShoppingBag, ArrowRight, MessageSquare } from 'lucide-react';

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
  stockCount = 5,
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
      {/* 1. Secondary Action: "Tanya" Button (Scrolls to comment section & focuses input) */}
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

      {/* 2. Primary Action: Kumo UI Electric Blue "Beli Sekarang" CTA Button */}
      <button
        type="button"
        onClick={onBuyClick}
        className="relative inline-flex items-center justify-between flex-1 h-12 px-3.5 rounded-2xl text-white bg-[#1d64ec] border border-[#154ec1] shadow-md shadow-blue-500/20 active:scale-[0.98] transition-all cursor-pointer overflow-hidden shrink-0 select-none group min-w-0"
      >
        {/* Kumo Inset Top Rim Highlight Gradient */}
        <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] transition-all pointer-events-none" />

        {/* Left Side: Shopping Bag Icon + Text */}
        <span className="relative z-10 flex items-center gap-2 font-semibold text-[14px] tracking-tight truncate">
          <div className="w-6.5 h-6.5 rounded-lg bg-white/10 flex items-center justify-center border border-white/15 shrink-0">
            <ShoppingBag className="w-3.5 h-3.5 text-white stroke-[2.2]" />
          </div>
          <span className="truncate">Beli</span>
        </span>

        {/* Right Side: Stock Badge + Price + Arrow */}
        <span className="relative z-10 flex items-center gap-1.5 shrink-0">
          {stockCount > 0 && (
            <span className="px-1.5 py-0.5 rounded-md text-[10px] font-medium bg-white/10 text-neutral-200 border border-white/15 hidden sm:inline-flex">
              Stok {stockCount}
            </span>
          )}
          <div className="flex flex-col items-end leading-none">
            <span className="font-bold text-[15px] text-white tracking-tight">
              {formatRupiah(price)}
            </span>
            {originalPrice && originalPrice > price && (
              <span className="text-[9px] text-neutral-400 line-through">
                {formatRupiah(originalPrice)}
              </span>
            )}
          </div>
          <ArrowRight className="w-4 h-4 text-white/80 group-hover:translate-x-0.5 transition-transform stroke-[2.25] shrink-0" />
        </span>
      </button>
    </div>
  );
};
