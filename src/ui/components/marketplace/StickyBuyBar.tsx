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
  stockCount,
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
    <div className="fixed bottom-4 left-4 right-20 max-w-lg z-40 font-gt-standard">
      {/* Detached Floating Pill Container (Leaves room on right for floating action button) */}
      <div className="bg-[#1d64ec] p-1.5 rounded-full shadow-[0_8px_30px_rgba(29,100,236,0.35)] backdrop-blur-md border border-white/25 flex items-center gap-2">
        {/* Inner Active White Pill: "💬 Tanya" Button */}
        <button
          type="button"
          onClick={onChatClick}
          className="h-10 px-3.5 rounded-full bg-white hover:bg-neutral-50 active:scale-95 text-[#1d64ec] font-bold text-[13px] flex items-center justify-center gap-1.5 shadow-sm transition-all cursor-pointer shrink-0 select-none"
          title="Tanyakan ke Penjual / Kolom Komentar"
          aria-label="Tanya Penjual di Komentar"
        >
          <MessageSquare className="w-4 h-4 text-[#1d64ec] stroke-[2.4]" />
          <span>Tanya</span>
        </button>

        {/* Right CTA Area: "🛒 Beli • Rp 150.000" Button */}
        <button
          type="button"
          onClick={onBuyClick}
          className="flex-1 h-10 pr-3 text-white font-semibold text-[13px] flex items-center justify-between gap-2 active:scale-95 transition-all cursor-pointer select-none min-w-0"
        >
          <span className="flex items-center gap-1.5 shrink-0">
            <ShoppingCart className="w-4 h-4 text-white stroke-[2.2] shrink-0" />
            <span className="font-semibold">Beli Sekarang</span>
          </span>

          <div className="flex items-center gap-1.5 shrink-0 ml-auto">
            {stockCount !== undefined && stockCount > 0 && (
              <span className="px-1.5 py-0.5 rounded-md text-[10px] font-medium bg-white/15 text-blue-100 border border-white/20 hidden sm:inline-flex">
                Stok {stockCount}
              </span>
            )}
            <div className="flex flex-col items-end leading-none shrink-0">
              <span className="font-bold text-[14px] text-white tracking-tight whitespace-nowrap">
                {formatRupiah(price)}
              </span>
              {originalPrice && originalPrice > price && (
                <span className="text-[9px] text-blue-200 line-through whitespace-nowrap">
                  {formatRupiah(originalPrice)}
                </span>
              )}
            </div>
          </div>
        </button>
      </div>
    </div>
  );
};
