import React, { useState, useRef } from 'react';
import { X, Send, MapPin } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';

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
  const [dragY, setDragY] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const startYRef = useRef(0);

  // Body scroll lock & state reset effect (Native Modal Behavior)
  React.useEffect(() => {
    if (isOpen) {
      setActiveImageIndex(0);
      setDragY(0);

      const originalOverflow = document.body.style.overflow;
      const originalPosition = document.body.style.position;
      const originalWidth = document.body.style.width;
      const scrollY = window.scrollY;

      document.body.style.overflow = 'hidden';
      document.body.style.position = 'fixed';
      document.body.style.width = '100%';
      document.body.style.top = `-${scrollY}px`;

      return () => {
        document.body.style.overflow = originalOverflow;
        document.body.style.position = originalPosition;
        document.body.style.width = originalWidth;
        document.body.style.top = '';
        window.scrollTo(0, scrollY);
      };
    }
  }, [isOpen, post.id]);

  const handleTouchStart = (e: React.TouchEvent) => {
    startYRef.current = e.touches[0].clientY;
    setIsDragging(true);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    const currentY = e.touches[0].clientY;
    const deltaY = currentY - startYRef.current;
    if (deltaY > 0) {
      setDragY(deltaY);
    }
  };

  const handleTouchEnd = () => {
    setIsDragging(false);
    if (dragY > 90) {
      onClose();
    }
    setDragY(0);
  };

  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val);

  // Detect if service category (Jasa, Service, Commission, etc.)
  const isService =
    post.category?.toLowerCase().includes('jasa') ||
    post.category?.toLowerCase().includes('prakerin') ||
    post.category?.toLowerCase().includes('service');

  // Badge text: "3 Slot Tersisa" vs "Stok 3"
  const stockBadgeText = isService
    ? `${post.stock || 3} Slot Tersisa`
    : `Stok ${post.stock || 5}`;

  // Clean title: prioritize explicit post.title, remove emojis
  const rawCaption = post.caption || '';
  const cleanTitle = (post.title || rawCaption)
    .replace(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu, '')
    .trim();

  const titleText = post.title || (cleanTitle.length > 55 ? cleanTitle.slice(0, 53) + '...' : cleanTitle);

  const handleWhatsAppCheckout = () => {
    const sellerName = post.seller.name;
    const itemTitle = cleanTitle;
    
    const message = `Halo ${sellerName}, saya tertarik dengan *${itemTitle}* (${formatRupiah(post.price ?? 0)}) di Snapan Market.\n\nBisa minta info ketersediaan & janjian COD di sekolah? Terima kasih!`;

    const waNumber = '6281234567890';
    const waUrl = `https://wa.me/${waNumber}?text=${encodeURIComponent(message)}`;
    
    window.open(waUrl, '_blank');
    onClose();
  };

  const images = post.images && post.images.length > 0 ? post.images : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-end justify-center font-gt-standard pointer-events-auto"
    >
      {/* Dark Backdrop Overlay */}
      <div
        onClick={onClose}
        className="absolute inset-0 bg-black/60 backdrop-blur-xs transition-opacity duration-180 animate-backdrop-fade"
        onTouchMove={(e) => e.preventDefault()}
      />

      {/* Bottom Sheet White Card - GPU Accelerated Subtle Zoom-In (matching HomePage -> DetailPage transition) */}
      <div
        style={{
          transform: dragY > 0 ? `translate3d(0, ${dragY}px, 0)` : undefined,
          transition: isDragging ? 'none' : 'transform 0.18s cubic-bezier(0.25, 1, 0.5, 1)',
          willChange: 'transform, opacity',
        }}
        className="relative w-full max-w-md bg-white text-slate-900 rounded-t-[20px] p-5 pb-7 z-10 shadow-[0_-12px_50px_rgba(0,0,0,0.15)] space-y-4 border-t border-neutral-100 transform-gpu animate-page-zoom"
      >
        {/* Floating Close X Button Floating Above Card Center (Kumo UI Style) */}
        <button
          type="button"
          onClick={onClose}
          className="absolute -top-12 left-1/2 -translate-x-1/2 w-9.5 h-9.5 rounded-full bg-white text-slate-800 flex items-center justify-center shadow-md border border-neutral-200 active:scale-90 transition-all cursor-pointer z-20 overflow-hidden group"
          aria-label="Tutup Modal"
        >
          {/* Kumo Inset Top Rim Highlight Gradient */}
          <span className="absolute inset-0 rounded-full bg-gradient-to-b from-white to-neutral-100/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.9)] group-hover:from-neutral-50 transition-all pointer-events-none" />

          {/* X Icon */}
          <X className="w-4 h-4 stroke-[2.2] text-slate-800 relative z-10" />
        </button>

        {/* 1. Header Penjual (Avatar + Nama + Badge Kelas & Slot Tersisa) with Drag Gesture */}
        <div
          onTouchStart={handleTouchStart}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
          className="flex items-center justify-between gap-3 pt-0.5 cursor-grab active:cursor-grabbing touch-pan-y"
        >
          <div className="flex items-center gap-3 min-w-0">
            {/* Avatar Penjual */}
            <img
              src={post.seller.avatar}
              alt={post.seller.name}
              className="w-11 h-11 rounded-full object-cover border border-neutral-200 shrink-0 shadow-2xs"
            />

            <div className="flex flex-col min-w-0 space-y-1">
              <div className="flex items-center gap-1.5">
                <span className="font-bold text-base text-slate-900 truncate">
                  {post.seller.name}
                </span>
                {post.seller.isVerified && (
                  <ClickableVerifiedBadge sellerName={post.seller.name} className="w-[17px] h-[17px]" />
                )}
              </div>

              {/* Badges: Kelas & Slot/Stok */}
              <div className="flex items-center gap-1.5 flex-wrap">
                <span className="px-2 py-0.5 rounded-md text-[10.5px] font-semibold bg-neutral-100 text-slate-700 border border-neutral-200/80">
                  {post.seller.classGroup}
                </span>
                <span className="px-2 py-0.5 rounded-md text-[10.5px] font-semibold bg-amber-50 text-amber-700 border border-amber-200/80">
                  {stockBadgeText}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* 2. Main Product Image (Replaces QR Code in Reference Image) */}
        <div className="relative rounded-2xl overflow-hidden border border-neutral-200/80 bg-neutral-50 group shadow-2xs">
          <div
            className="w-full h-52 overflow-x-auto flex snap-x snap-mandatory scrollbar-none"
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
                alt={`${post.caption} - Preview ${idx + 1}`}
                className="w-full h-full object-cover shrink-0 snap-center"
              />
            ))}
          </div>

          {/* Pagination Dot Indicator */}
          {images.length > 1 && (
            <div className="absolute bottom-2.5 left-0 right-0 flex justify-center pointer-events-none">
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-black/60 backdrop-blur-md border border-white/20">
                {images.map((_, idx) => (
                  <div
                    key={idx}
                    className={`h-1.5 rounded-full transition-all duration-300 ${
                      idx === activeImageIndex
                        ? 'w-4 bg-white'
                        : 'w-1.5 bg-white/50'
                    }`}
                  />
                ))}
              </div>
            </div>
          )}
        </div>

        {/* 3. Detail Produk (Nama Barang & Deskripsi Singkat Saja) */}
        <div className="space-y-1.5">
          <h3 className="font-bold text-lg text-slate-900 leading-snug">
            {post.title || titleText}
          </h3>
          {(post.description || (post.caption && post.caption !== post.title)) && (
            <p className="text-[13px] text-neutral-600 font-normal leading-relaxed line-clamp-4 whitespace-pre-line">
              {post.description || post.caption}
            </p>
          )}
        </div>

        {/* 4. Tombol Bottom Action (WhatsApp Checkout & Pricing) */}
        <div className="pt-1 space-y-2">
          <button
            type="button"
            onClick={handleWhatsAppCheckout}
            className="relative inline-flex items-center justify-between w-full h-12 px-5 rounded-2xl text-white bg-[#1d64ec] hover:bg-[#154ec1] border border-[#154ec1] active:scale-[0.98] font-medium text-sm shadow-md shadow-blue-500/25 transition-all cursor-pointer overflow-hidden select-none group"
          >
            {/* Kumo Inset Top Rim Highlight Gradient */}
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] transition-all pointer-events-none" />
            
            {/* Left Label */}
            <span className="relative z-10 flex items-center gap-2 shrink-0 font-medium">
              <Send className="w-4 h-4 stroke-[1.8] text-white" />
              <span>Chat via WhatsApp</span>
            </span>

            {/* Right Price */}
            <span className="relative z-10 font-medium text-sm text-white/95 tracking-tight shrink-0">
              {formatRupiah(post.price ?? 0)}
            </span>
          </button>

          {/* COD Info */}
          <p className="text-[11px] text-center text-neutral-400 font-normal flex items-center justify-center gap-1">
            <MapPin className="w-3 h-3 text-neutral-400 shrink-0" />
            <span>COD & Janjian Ketemuan di Lingkungan SMKN 8</span>
          </p>
        </div>
      </div>
    </div>
  );
};
