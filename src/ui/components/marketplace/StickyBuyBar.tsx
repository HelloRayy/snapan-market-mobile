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
    <div
      className="fixed left-4 right-4 max-w-md mx-auto z-40 font-gt-standard select-none transition-transform duration-200 ease-out"
      style={{
        bottom: 'max(1rem, calc(env(safe-area-inset-bottom, 0px) + 8px))',
      }}
    >
      {/* Floating White Pill Dock Container (Identical to Home Bottom Nav Style) */}
      <div className="bg-white/95 backdrop-blur-xl border border-neutral-200/80 p-1.5 rounded-full shadow-[0_12px_40px_rgba(0,0,0,0.12)] flex items-center gap-2">
        {/* Left Kumo Secondary Button: Icon Only "Tanya" */}
        <button
          type="button"
          onClick={onChatClick}
          className="w-11 h-11 rounded-full bg-white text-[#111827] border border-neutral-200 shadow-2xs hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.96] flex items-center justify-center transition-colors cursor-pointer shrink-0 select-none"
          title="Tanyakan ke Penjual / Kolom Komentar"
          aria-label="Tanya Penjual di Komentar"
        >
          <MessageSquare className="w-5 h-5 text-slate-800 stroke-[1.8]" />
        </button>

        {/* Right Kumo Primary Button: Left Label --- Right Price */}
        <button
          type="button"
          onClick={onBuyClick}
          className="relative inline-flex items-center justify-between flex-1 h-11 px-5 rounded-full text-white font-medium text-[13.5px] bg-[#3d38f5] border border-[#312bd9] shadow-md shadow-indigo-500/20 active:scale-[0.97] transition-transform duration-75 cursor-pointer overflow-hidden select-none group"
        >
          {/* Kumo Inset Top Rim Highlight Gradient */}
          <span className="absolute inset-0 rounded-full bg-gradient-to-b from-[#5550f7] to-[#3d38f5] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#4944f6] transition-opacity duration-150 pointer-events-none" />

          {/* Left Label */}
          <span className="relative z-10 flex items-center gap-1.5 shrink-0 font-medium">
            <CreditCard className="w-4 h-4 text-white stroke-[1.8]" />
            <span>Beli Sekarang</span>
          </span>

          {/* Right Price */}
          <span className="relative z-10 font-medium text-[13.5px] text-white/95 tracking-tight shrink-0">
            {formatRupiah(price)}
          </span>
        </button>
      </div>
    </div>
  );
};
