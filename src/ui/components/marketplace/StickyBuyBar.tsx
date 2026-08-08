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
    <div className="fixed bottom-0 left-0 right-0 max-w-xl mx-auto bg-white/95 backdrop-blur-md border-t border-neutral-200/80 px-4 py-3 z-40 font-gt-standard shadow-[0_-4px_20px_rgba(0,0,0,0.06)]">
      {/* Full-Width Kumo UI Primary Black "Beli Sekarang" CTA Button */}
      <button
        type="button"
        onClick={onBuyClick}
        className="relative inline-flex items-center justify-between w-full h-12.5 px-4.5 rounded-2xl text-white bg-[#18181b] border border-black/40 shadow-lg active:scale-[0.98] transition-all cursor-pointer overflow-hidden shrink-0 select-none group"
      >
        {/* Kumo Inset Top Rim Highlight Gradient */}
        <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] group-hover:from-neutral-600/80 transition-all pointer-events-none" />

        {/* Left Side: Shopping Bag Icon + Text */}
        <span className="relative z-10 flex items-center gap-2.5 font-semibold text-[15px] tracking-tight">
          <div className="w-7 h-7 rounded-xl bg-white/10 flex items-center justify-center border border-white/15">
            <ShoppingBag className="w-4 h-4 text-white stroke-[2.2]" />
          </div>
          <span>Beli Sekarang</span>
        </span>

        {/* Right Side: Stock Badge + Price + Arrow */}
        <span className="relative z-10 flex items-center gap-2">
          {stockCount > 0 && (
            <span className="px-2 py-0.5 rounded-md text-[11px] font-medium bg-white/10 text-neutral-200 border border-white/15">
              Stok {stockCount}
            </span>
          )}
          <div className="flex flex-col items-end leading-none">
            <span className="font-bold text-[16px] text-white tracking-tight">
              {formatRupiah(price)}
            </span>
            {originalPrice && originalPrice > price && (
              <span className="text-[10px] text-neutral-400 line-through">
                {formatRupiah(originalPrice)}
              </span>
            )}
          </div>
          <ArrowRight className="w-4 h-4 text-white/80 group-hover:translate-x-0.5 transition-transform stroke-[2.25]" />
        </span>
      </button>
    </div>
  );
};
