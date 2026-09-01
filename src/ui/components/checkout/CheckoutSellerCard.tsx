import React from 'react';
import { User } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { triggerHaptic } from '@/utils/haptics';

interface CheckoutSellerCardProps {
  seller: MarketPostItem['seller'];
  productTitle?: string;
  productPrice?: number;
  onUserClick?: (username: string) => void;
}

export const CheckoutSellerCard: React.FC<CheckoutSellerCardProps> = ({
  seller,
  onUserClick,
}) => {
  const sellerUsername = seller.username || seller.name.toLowerCase().replace(/\s+/g, '');

  const handleProfileClick = () => {
    triggerHaptic('light');
    if (onUserClick) {
      onUserClick(sellerUsername);
    } else {
      window.location.href = `/@${sellerUsername}`;
    }
  };

  const handleChatClick = () => {
    triggerHaptic('medium');
    alert(`Membuka percakapan pesan in-app dengan ${seller.name} (@${sellerUsername})`);
  };

  return (
    <div className="bg-neutral-50/90 rounded-2xl p-3.5 border border-neutral-200/80 flex items-center justify-between gap-3 select-none font-gt-standard shadow-2xs">
      {/* Sisi Kiri: Avatar & Info Penjual (Bisa diketuk ke profil) */}
      <div
        onClick={handleProfileClick}
        className="flex items-center gap-3 min-w-0 flex-1 cursor-pointer group"
      >
        <img
          src={seller.avatar}
          alt={seller.name}
          className="w-11 h-11 rounded-full object-cover shrink-0 shadow-2xs border border-white/80 group-hover:scale-105 transition-transform"
        />

        <div className="min-w-0 flex-1">
          <h4 className="font-bold text-[14.5px] text-slate-900 leading-tight truncate flex items-center gap-1.5 group-hover:text-[#3d38f5] transition-colors">
            <span>{seller.name}</span>
            {seller.isVerified && (
              <ClickableVerifiedBadge sellerName={seller.name} className="w-[14px] h-[14px]" />
            )}
          </h4>
          <p className="text-[12.5px] text-slate-500 font-normal mt-0.5 truncate">
            @{sellerUsername}
          </p>
        </div>
      </div>

      {/* Sisi Kanan: Kumo UI Action Buttons (Secondary Profile + Primary Chat) */}
      <div className="flex items-center gap-2 shrink-0">
        {/* 1. Kumo Secondary Button: Kunjungi Profil Penjual */}
        <button
          type="button"
          onClick={handleProfileClick}
          className="w-10 h-10 rounded-full bg-white text-slate-800 border border-neutral-200/90 shadow-2xs hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.95] flex items-center justify-center transition-all cursor-pointer select-none"
          aria-label={`Lihat Profil ${seller.name}`}
          title="Lihat Profil Penjual"
        >
          <User className="w-4.5 h-4.5 stroke-[2] text-slate-800" />
        </button>

        {/* 2. Kumo Primary Button: Kirim Pesan In-App (Electric Indigo) */}
        <button
          type="button"
          onClick={handleChatClick}
          className="relative w-10 h-10 rounded-full text-white bg-[#3d38f5] border border-[#312bd9] shadow-md shadow-indigo-500/25 active:scale-[0.95] transition-transform duration-75 flex items-center justify-center cursor-pointer overflow-hidden select-none group"
          aria-label="Kirim Pesan ke Penjual"
          title="Kirim Pesan In-App"
        >
          {/* Kumo Inset Top Rim Highlight Gradient */}
          <span className="absolute inset-0 rounded-full bg-gradient-to-b from-[#5550f7] to-[#3d38f5] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.4)] group-hover:from-[#4944f6] transition-opacity duration-150 pointer-events-none" />
          <svg
            className="relative z-10 w-[19px] h-[19px] text-white"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
          >
            <path
              d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <circle cx="8" cy="12" r="1.2" fill="currentColor" />
            <circle cx="12" cy="12" r="1.2" fill="currentColor" />
            <circle cx="16" cy="12" r="1.2" fill="currentColor" />
          </svg>
        </button>
      </div>
    </div>
  );
};
