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

      {/* Ultra Compact Bottom Sheet Card */}
      <div className="relative w-full max-w-md bg-white rounded-t-[28px] p-5 z-10 shadow-2xl animate-in slide-in-from-bottom duration-300 space-y-3.5">
        {/* Top Handle Bar Indicator */}
        <div className="w-10 h-1 bg-neutral-200 rounded-full mx-auto -mt-1 mb-1" />

        {/* Header: [← Arrow] [Title] */}
        <div className="flex items-center gap-2.5 border-b border-neutral-100 pb-2.5">
          <button
            type="button"
            onClick={onClose}
            className="w-7 h-7 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer"
            aria-label="Tutup"
          >
            <ArrowLeft className="w-4.5 h-4.5 stroke-[2.2]" />
          </button>
          <h2 className="font-bold text-base text-slate-900">Informasi Pembelian</h2>
        </div>

        {/* Compact Media Card: Image Left (80x80px) + Info Right */}
        <div className="flex gap-3 bg-neutral-50 p-3 rounded-2xl border border-neutral-200/80">
          {/* Product Image */}
          <img
            src={post.images[0]}
            alt={post.caption}
            className="w-20 h-20 rounded-xl object-cover border border-neutral-200/80 shrink-0"
          />

          {/* Product & Seller Details */}
          <div className="flex-1 min-w-0 space-y-1">
            {/* User & Class Info */}
            <div className="flex items-center gap-1.5 min-w-0">
              <img
                src={post.seller.avatar}
                alt={post.seller.name}
                className="w-4 h-4 rounded-full object-cover shrink-0 border border-neutral-200"
              />
              <span className="text-[12px] font-semibold text-slate-900 truncate">
                {post.seller.name}
              </span>
              <span className="text-[11px] font-medium text-neutral-400 shrink-0 truncate">
                • {post.seller.classGroup}
              </span>
            </div>

            {/* Item Name */}
            <h3 className="font-bold text-[13px] text-slate-900 leading-snug line-clamp-2">
              {post.caption}
            </h3>

            {/* Price & Stock Badge */}
            <div className="flex items-center justify-between pt-0.5">
              <span className="font-bold text-[14px] text-[#1d64ec]">
                {formatRupiah(post.price)}
              </span>
              <span className="text-[10px] font-semibold px-2 py-0.5 rounded-md bg-emerald-100 text-emerald-700">
                Stok {post.stock || 5}
              </span>
            </div>
          </div>
        </div>

        {/* Short Description */}
        <p className="text-[12px] text-neutral-500 font-normal leading-relaxed px-0.5">
          Kirim pesan langsung ke WhatsApp <strong>{post.seller.name}</strong> untuk sepakat tempat & waktu COD di sekolah.
        </p>

        {/* Kumo Black Action Button ("Pesan via WhatsApp") */}
        <div className="pt-1">
          <button
            type="button"
            onClick={handleWhatsAppCheckout}
            className="relative inline-flex items-center justify-center gap-2 w-full h-11 rounded-full text-white bg-[#18181b] hover:bg-black active:scale-[0.98] font-bold text-xs shadow-md transition-all cursor-pointer overflow-hidden select-none group"
          >
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
            <span className="relative z-10 flex items-center justify-center gap-2">
              <Send className="w-3.5 h-3.5 stroke-[2.2]" />
              <span>Pesan via WhatsApp</span>
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};
