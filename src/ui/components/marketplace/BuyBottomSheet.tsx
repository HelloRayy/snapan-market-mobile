import React from 'react';
import { ArrowLeft, Send } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';

interface BuyBottomSheetProps {
  isOpen: boolean;
  post: MarketPostItem;
  onClose: () => void;
}

export const BuyBottomSheet: React.FC<BuyBottomSheetProps> = ({
  isOpen,
  post,
  onClose,
}) => {
  if (!isOpen) return null;

  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val);

  const handleWhatsAppCheckout = () => {
    const sellerName = post.seller.name;
    const itemTitle = post.caption.slice(0, 60);
    
    const message = `Halo ${sellerName}, saya mau beli *${itemTitle}* (${formatRupiah(post.price)}) di Snapan Market.\n\nKira-kira bisa COD di mana dan jam berapa ya kak? Terima kasih!`;

    const waNumber = '6281234567890';
    const waUrl = `https://wa.me/${waNumber}?text=${encodeURIComponent(message)}`;
    
    window.open(waUrl, '_blank');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-xs animate-in fade-in duration-200 font-gt-standard">
      {/* Overlay Backdrop Click */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* Clean Minimalist Bottom Sheet Card (Exact Reference Match) */}
      <div className="relative w-full max-w-md bg-white rounded-t-[32px] p-6 z-10 shadow-2xl animate-in slide-in-from-bottom duration-300 space-y-4">
        {/* Top Handle Bar Indicator */}
        <div className="w-10 h-1 bg-neutral-200 rounded-full mx-auto -mt-2 mb-2" />

        {/* Header: [← Arrow] [Title] */}
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer"
            aria-label="Tutup"
          >
            <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
          </button>
          <h2 className="font-bold text-lg text-slate-900">Informasi Pembelian</h2>
        </div>

        {/* Product Image & Description Content */}
        <div className="space-y-3 pt-1">
          {/* Product Image */}
          <div className="w-full h-44 rounded-2xl overflow-hidden border border-neutral-200/80 bg-neutral-50 shadow-2xs">
            <img
              src={post.images[0]}
              alt={post.caption}
              className="w-full h-full object-cover"
            />
          </div>

          {/* Title & Detail Info */}
          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <span className="text-xs font-semibold text-neutral-400 uppercase tracking-wider">
                {post.category} • Stok {post.stock || 5}
              </span>
              <span className="font-bold text-base text-[#1d64ec]">
                {formatRupiah(post.price)}
              </span>
            </div>

            <h3 className="font-bold text-base text-slate-900 leading-snug">
              {post.caption}
            </h3>

            <p className="text-xs text-neutral-500 font-normal leading-relaxed pt-0.5">
              Penjual: <strong className="text-slate-900">{post.seller.name}</strong> ({post.seller.classGroup}). Hubungi langsung penjual via WhatsApp untuk sepakat tempat COD di lingkungan sekolah.
            </p>
          </div>
        </div>

        {/* Single Kumo Black Action Button (Matching Reference "Done" Button Style) */}
        <div className="pt-2">
          <button
            type="button"
            onClick={handleWhatsAppCheckout}
            className="relative inline-flex items-center justify-center gap-2 w-full h-12 rounded-full text-white bg-[#18181b] hover:bg-black active:scale-[0.98] font-bold text-sm shadow-md transition-all cursor-pointer overflow-hidden select-none group"
          >
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
            <span className="relative z-10 flex items-center justify-center gap-2">
              <Send className="w-4 h-4 stroke-[2.2]" />
              <span>Pesan via WhatsApp</span>
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};
