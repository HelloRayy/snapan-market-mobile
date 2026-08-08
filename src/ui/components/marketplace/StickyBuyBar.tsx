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
    <div className="fixed bottom-4 left-4 right-4 max-w-md mx-auto z-40 font-gt-standard">
      {/* Sleek Floating Dark Dock Container (Exact Match to User Reference Image) */}
      <div className="bg-[#1c1c1e]/95 backdrop-blur-xl border border-white/10 p-2 rounded-[28px] shadow-[0_12px_40px_rgba(0,0,0,0.4)] flex items-center gap-2.5">
        {/* Left Pill Button: "Chat Seller" (Outline Glass Pill) */}
        <button
          type="button"
          onClick={onChatClick}
          className="flex-1 h-12 rounded-full border border-white/25 bg-white/5 hover:bg-white/10 active:scale-95 text-white font-medium text-[14px] flex items-center justify-center gap-2 transition-all cursor-pointer shrink-0 select-none"
          title="Tanyakan ke Penjual / Kolom Komentar"
          aria-label="Tanya Penjual di Komentar"
        >
          <MessageSquare className="w-4 h-4 text-white stroke-[2.2]" />
          <span>Chat Seller</span>
        </button>

        {/* Right Pill Button: "Beli • Rp 150.000" (Vibrant Primary Blue Pill) */}
        <button
          type="button"
          onClick={onBuyClick}
          className="flex-1 h-12 rounded-full bg-[#1d64ec] hover:bg-[#154ec1] active:scale-95 text-white font-semibold text-[14px] flex items-center justify-center gap-1.5 shadow-lg transition-all cursor-pointer shrink-0 select-none"
        >
          <ShoppingCart className="w-4 h-4 text-white stroke-[2.2]" />
          <span>Beli • {formatRupiah(price)}</span>
        </button>
      </div>
    </div>
  );
};
