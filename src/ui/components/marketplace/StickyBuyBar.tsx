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
      {/* Full Width White Container with Top-Left & Top-Right Rounded Corners */}
      <div className="bg-white border-t border-neutral-200/80 p-3 rounded-t-[24px] shadow-[0_-4px_25px_rgba(0,0,0,0.08)] flex items-center gap-3">
        {/* Left Pill Button: "Chat Seller" (Light Neutral Pill) */}
        <button
          type="button"
          onClick={onChatClick}
          className="flex-1 h-12 rounded-full border border-neutral-200/80 bg-neutral-100 hover:bg-neutral-200/80 active:scale-95 text-slate-800 font-semibold text-[14px] flex items-center justify-center gap-2 transition-all cursor-pointer shrink-0 select-none"
          title="Tanyakan ke Penjual / Kolom Komentar"
          aria-label="Tanya Penjual di Komentar"
        >
          <MessageSquare className="w-4 h-4 text-slate-800 stroke-[2.2]" />
          <span>Chat Seller</span>
        </button>

        {/* Right Pill Button: "Beli • Rp 150.000" (Vibrant Primary Blue Pill) */}
        <button
          type="button"
          onClick={onBuyClick}
          className="flex-1 h-12 rounded-full bg-[#1d64ec] hover:bg-[#154ec1] active:scale-95 text-white font-semibold text-[14px] flex items-center justify-center gap-1.5 shadow-md shadow-blue-500/20 transition-all cursor-pointer shrink-0 select-none"
        >
          <ShoppingCart className="w-4 h-4 text-white stroke-[2.2]" />
          <span>Beli • {formatRupiah(price)}</span>
        </button>
      </div>
    </div>
  );
};
