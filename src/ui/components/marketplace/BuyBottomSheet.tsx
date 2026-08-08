import React, { useState } from 'react';
import { X, Send } from 'lucide-react';
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
  const [activeImageIndex, setActiveImageIndex] = useState(0);

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

  const images = post.images && post.images.length > 0 ? post.images : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-xs animate-in fade-in duration-200 font-gt-standard">
      {/* Overlay Backdrop Click */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* Bottom Sheet Card (Exact Match to User Reference Image) */}
      <div className="relative w-full max-w-md bg-white rounded-t-[32px] p-5 z-10 shadow-2xl animate-in slide-in-from-bottom duration-300 space-y-4">
        {/* Top Handle Bar Indicator */}
        <div className="w-10 h-1 bg-neutral-200 rounded-full mx-auto -mt-1 mb-1" />

        {/* Header: [Spacer] --- [Title] --- [Circle X] */}
        <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
          {/* Left Spacer for Title Balance */}
          <div className="w-9 h-9 pointer-events-none" />

          <h2 className="font-bold text-base text-slate-900">Informasi Pembelian</h2>

          <button
            type="button"
            onClick={onClose}
            className="w-9 h-9 rounded-full bg-neutral-100 hover:bg-neutral-200/80 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-95"
            aria-label="Tutup Modal"
          >
            <X className="w-4.5 h-4.5 stroke-[2.2]" />
          </button>
        </div>

        {/* Swipeable Image Carousel Container */}
        <div className="relative group">
          <div
            className="w-full h-48 rounded-2xl overflow-x-auto flex snap-x snap-mandatory scrollbar-none border border-neutral-200/80 bg-neutral-50 shadow-2xs"
            onScroll={(e) => {
              const scrollLeft = e.currentTarget.scrollLeft;
              const width = e.currentTarget.clientWidth;
              if (width > 0) {
                setActiveImageIndex(Math.round(scrollLeft / width));
              }
            }}
          >
            {images.map((img, idx) => (
              <img
                key={idx}
                src={img}
                alt={`${post.caption} - Foto ${idx + 1}`}
                className="w-full h-full object-cover shrink-0 snap-center"
              />
            ))}
          </div>

          {/* High-Contrast Glass Pagination Dot Container */}
          {images.length > 1 && (
            <div className="absolute bottom-3 left-0 right-0 flex justify-center pointer-events-none">
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-black/60 backdrop-blur-md border border-white/20 shadow-md">
                {images.map((_, idx) => (
                  <div
                    key={idx}
                    className={`h-1.5 rounded-full transition-all duration-300 ${
                      idx === activeImageIndex
                        ? 'w-4 bg-white shadow-sm'
                        : 'w-1.5 bg-white/50'
                    }`}
                  />
                ))}
              </div>
            </div>
          )}

          {/* Photo Counter Badge */}
          {images.length > 1 && (
            <div className="absolute top-2.5 right-2.5 px-2 py-0.5 rounded-full bg-black/60 backdrop-blur-xs text-white text-[10px] font-medium border border-white/20 pointer-events-none">
              {activeImageIndex + 1}/{images.length}
            </div>
          )}
        </div>

        {/* Product & Seller Details */}
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
            Penjual: <strong className="text-slate-900">{post.seller.name}</strong> ({post.seller.classGroup}). Hubungi langsung penjual via WhatsApp untuk sepakat tempat COD di sekolah.
          </p>
        </div>

        {/* Single Kumo Black Action Button (Matching Reference "Weiter" Button Style) */}
        <div className="pt-2">
          <button
            type="button"
            onClick={handleWhatsAppCheckout}
            className="relative inline-flex items-center justify-center gap-2 w-full h-12 rounded-2xl text-white bg-[#18181b] hover:bg-black active:scale-[0.98] font-bold text-sm shadow-md transition-all cursor-pointer overflow-hidden select-none group"
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
