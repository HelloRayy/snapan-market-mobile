import React from 'react';
import { ShoppingBag, ArrowRight } from 'lucide-react';

interface StickyBuyBarProps {
  price?: number;
  originalPrice?: number;
  stockCount?: number;
  onBuyClick?: () => void;
}

export const StickyBuyBar: React.FC<StickyBuyBarProps> = ({
  price = 150000,
  originalPrice,
  stockCount = 5,
  onBuyClick,
}) => {
  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val);

  return (
    <div className="fixed bottom-0 left-0 right-0 max-w-xl mx-auto bg-white/95 backdrop-blur-md border-t border-neutral-200/80 px-4 py-2.5 z-40 font-gt-standard shadow-[0_-4px_20px_rgba(0,0,0,0.06)] flex items-center justify-between gap-3">
      {/* Left: Price & Stock Status */}
      <div className="flex flex-col justify-center min-w-0">
        <div className="flex items-center gap-1.5 min-w-0">
          <span className="text-xs text-neutral-400 font-normal">Harga</span>
          {stockCount > 0 && (
            <span className="inline-flex items-center px-1.5 py-0.5 rounded-full text-[10px] font-medium bg-emerald-50 text-emerald-600 border border-emerald-200/60">
              Stok: {stockCount}
            </span>
          )}
        </div>
        <div className="flex items-baseline gap-1.5">
          <span className="text-[17px] font-bold text-slate-900 tracking-tight">
            {formatRupiah(price)}
          </span>
          {originalPrice && originalPrice > price && (
            <span className="text-xs text-neutral-400 line-through">
              {formatRupiah(originalPrice)}
            </span>
          )}
        </div>
      </div>

      {/* Right: Kumo UI Primary Black "Beli Sekarang" CTA Button */}
      <button
        type="button"
        onClick={onBuyClick}
        className="relative inline-flex items-center justify-center gap-2 h-11 px-5 rounded-xl text-[14px] font-semibold text-white bg-[#18181b] border border-black/40 shadow-md active:scale-[0.98] transition-all cursor-pointer overflow-hidden shrink-0 select-none group"
      >
        {/* Kumo Inset Top Rim Highlight Gradient */}
        <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] group-hover:from-neutral-600/80 transition-all pointer-events-none" />

        {/* Content Layer */}
        <span className="relative z-10 flex items-center gap-2">
          <ShoppingBag className="w-4 h-4 text-white stroke-[2.2]" />
          <span>Beli Sekarang</span>
          <ArrowRight className="w-3.5 h-3.5 text-white/80 group-hover:translate-x-0.5 transition-transform" />
        </span>
      </button>
    </div>
  );
};
