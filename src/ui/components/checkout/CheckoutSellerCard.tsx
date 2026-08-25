import React from 'react';
import { MessageCircle, Phone } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { ClickableVerifiedBadge } from '../marketplace/VerifiedBadgeModal';
import { triggerHaptic } from '@/utils/haptics';

interface CheckoutSellerCardProps {
  seller: MarketPostItem['seller'];
  productTitle?: string;
  productPrice?: number;
}

export const CheckoutSellerCard: React.FC<CheckoutSellerCardProps> = ({
  seller,
  productTitle = 'Barang',
  productPrice = 0,
}) => {
  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val);

  const handleChatClick = () => {
    triggerHaptic('light');
    alert(`Membuka percakapan pesan dengan ${seller.name} (@${seller.username || 'penjual'})`);
  };

  const handleWhatsAppClick = () => {
    triggerHaptic('medium');
    const phone = '6281234567890';
    const message = `Halo ${seller.name}, saya tertarik dengan *${productTitle}* (${formatRupiah(
      productPrice
    )}) di Snapan Market. Bisa janjian COD di sekolah? Terima kasih!`;
    const url = `https://wa.me/${phone}?text=${encodeURIComponent(message)}`;
    window.open(url, '_blank');
  };

  return (
    <div className="bg-neutral-50/90 rounded-2xl p-3.5 border border-neutral-200/80 flex items-center justify-between gap-3 select-none font-gt-standard shadow-2xs">
      {/* Sisi Kiri: Avatar & Info Penjual */}
      <div className="flex items-center gap-3 min-w-0 flex-1">
        <img
          src={seller.avatar}
          alt={seller.name}
          className="w-11 h-11 rounded-full object-cover shrink-0 shadow-2xs border border-white/80"
        />

        <div className="min-w-0 flex-1">
          <h4 className="font-bold text-[14.5px] text-slate-900 leading-tight truncate flex items-center gap-1.5">
            <span>{seller.name}</span>
            {seller.isVerified && (
              <ClickableVerifiedBadge sellerName={seller.name} className="w-[14px] h-[14px]" />
            )}
          </h4>
          <p className="text-[12.5px] text-slate-500 font-normal mt-0.5 truncate">
            @{seller.username || seller.name.toLowerCase().replace(/\s+/g, '')}
          </p>
        </div>
      </div>

      {/* Sisi Kanan: 2 Tombol Bulat Hitam (Chat & Telepon/WA) */}
      <div className="flex items-center gap-2 shrink-0">
        {/* 1. Tombol Chat */}
        <button
          type="button"
          onClick={handleChatClick}
          className="w-10 h-10 rounded-full bg-slate-900 hover:bg-black active:scale-95 text-white flex items-center justify-center shadow-xs cursor-pointer transition-all"
          aria-label="Kirim Pesan ke Penjual"
        >
          <MessageCircle className="w-4.5 h-4.5 stroke-[2] fill-white text-slate-900" />
        </button>

        {/* 2. Tombol WhatsApp / Telepon */}
        <button
          type="button"
          onClick={handleWhatsAppClick}
          className="w-10 h-10 rounded-full bg-slate-900 hover:bg-black active:scale-95 text-white flex items-center justify-center shadow-xs cursor-pointer transition-all"
          aria-label="Hubungi WhatsApp Penjual"
        >
          <Phone className="w-4.5 h-4.5 fill-white stroke-none" />
        </button>
      </div>
    </div>
  );
};
