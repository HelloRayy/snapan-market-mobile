import React, { useState, useRef } from 'react';
import { X, Send, MapPin } from 'lucide-react';
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
  const [dragY, setDragY] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const startYRef = useRef(0);

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

  // Clean title: remove emojis and keep short headline
  const rawCaption = post.caption || '';
  const cleanTitle = rawCaption
    .replace(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu, '')
    .trim();

  const titleText = cleanTitle.length > 55 ? cleanTitle.slice(0, 53) + '...' : cleanTitle;

  const handleWhatsAppCheckout = () => {
    const sellerName = post.seller.name;
    const itemTitle = cleanTitle;
    
    const message = `Halo ${sellerName}, saya tertarik dengan *${itemTitle}* (${formatRupiah(post.price)}) di Snapan Market.\n\nBisa minta info ketersediaan & janjian COD di sekolah? Terima kasih!`;

    const waNumber = '6281234567890';
    const waUrl = `https://wa.me/${waNumber}?text=${encodeURIComponent(message)}`;
    
    window.open(waUrl, '_blank');
    onClose();
  };

  const images = post.images && post.images.length > 0 ? post.images : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  return (
    <div
      className={`fixed inset-0 z-50 flex items-end justify-center font-gt-standard transition-all duration-300 ${
        isOpen ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'
      }`}
    >
      {/* Overlay Backdrop Click */}
      <div
        className={`absolute inset-0 bg-black/60 backdrop-blur-xs transition-opacity duration-300 ${
          isOpen ? 'opacity-100' : 'opacity-0'
        }`}
        onClick={onClose}
      />

      {/* Bottom Sheet Card - Pure Native Bottom Slide Up/Down Expansion */}
      <div
        style={{
          transform: !isOpen
            ? 'translateY(100%)'
            : dragY > 0
            ? `translateY(${dragY}px)`
            : 'translateY(0%)',
          transition: isDragging
            ? 'none'
            : 'transform 0.35s cubic-bezier(0.32, 0.72, 0, 1)',
        }}
        className="relative w-full max-w-md bg-white rounded-t-[32px] p-5 pb-8 z-10 shadow-[0_-12px_50px_rgba(0,0,0,0.3)] space-y-3.5 will-change-transform"
      >
        {/* Top Handle Bar Indicator with Drag Listener */}
        <div
          onTouchStart={handleTouchStart}
          onTouchMove={handleTouchMove}
          onTouchEnd={handleTouchEnd}
          className="py-2 -mt-3 -mx-5 cursor-grab active:cursor-grabbing flex justify-center items-center touch-pan-y"
        >
          <div className="w-12 h-1.5 bg-neutral-300 rounded-full" />
        </div>

        {/* Header: [Spacer Left] --- [Title Center] --- [Circle X Right] */}
        <div className="flex items-center justify-between border-b border-neutral-100 pb-2.5">
          <div className="w-8 h-8 pointer-events-none" />
          <h2 className="font-bold text-base text-slate-900">Informasi {isService ? 'Jasa' : 'Pembelian'}</h2>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-neutral-100 hover:bg-neutral-200/80 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-95"
            aria-label="Tutup Modal"
          >
            <X className="w-4 h-4 stroke-[2.2]" />
          </button>
        </div>

        {/* 1. Thumbnail / Preview Karya Carousel */}
        <div className="relative group">
          <div
            className="w-full h-44 rounded-2xl overflow-x-auto flex snap-x snap-mandatory scrollbar-none border border-neutral-200/80 bg-neutral-50 shadow-2xs"
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

          {/* High-Contrast Glass Pagination Dot Container */}
          {images.length > 1 && (
            <div className="absolute bottom-2.5 left-0 right-0 flex justify-center pointer-events-none">
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

        {/* 2. Badge Kategori + Slot Tersisa (Kiri) & Harga (Kanan) */}
        <div className="flex items-center justify-between pt-0.5">
          <div className="flex items-center gap-2">
            <span className="px-2.5 py-0.5 rounded-md text-[11px] font-semibold bg-neutral-100 text-slate-700 uppercase tracking-wider border border-neutral-200/60">
              {post.category}
            </span>
            <span className="px-2.5 py-0.5 rounded-md text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200/80">
              {stockBadgeText}
            </span>
          </div>

          {/* Harga - Menonjol Kanan */}
          <span className="font-bold text-lg text-[#1d64ec]">
            {formatRupiah(post.price)}
          </span>
        </div>

        {/* 3. Judul Singkat & Bold (Tanpa Emoji) */}
        <h3 className="font-bold text-base text-slate-900 leading-snug">
          {titleText}
        </h3>

        {/* 4. Deskripsi Pendek (Body Text) */}
        <p className="text-xs text-neutral-500 font-normal leading-relaxed">
          {rawCaption.length > 55 ? rawCaption : 'Menerima pembuatan desain UI/UX, prototype Figma, dan engineering PWA responsive untuk project/tugas sekolah.'}
        </p>

        {/* 5. Info Penjual (Avatar Kecil + Nama + Kelas) */}
        <div className="flex items-center gap-2.5 p-2.5 bg-neutral-50 rounded-xl border border-neutral-200/70">
          <img
            src={post.seller.avatar}
            alt={post.seller.name}
            className="w-8 h-8 rounded-full object-cover border border-neutral-200 shrink-0 shadow-2xs"
          />
          <div className="flex flex-col min-w-0">
            <div className="flex items-center gap-1.5">
              <span className="font-bold text-xs text-slate-900 truncate">
                {post.seller.name}
              </span>
              <span className="text-[10px] font-medium px-1.5 py-0.2 rounded bg-neutral-200/70 text-slate-700 shrink-0">
                {post.seller.classGroup}
              </span>
            </div>
            <span className="text-[10px] text-neutral-400 font-medium">Penjual Terverifikasi Siswa</span>
          </div>
        </div>

        {/* 6. Tombol CTA WhatsApp Jelas: Left Label --- Right Price (Exact Match to User Reference) */}
        <div className="pt-1 space-y-2">
          <button
            type="button"
            onClick={handleWhatsAppCheckout}
            className="relative inline-flex items-center justify-between w-full h-12 px-5 rounded-2xl text-white bg-[#18181b] hover:bg-black active:scale-[0.98] font-bold text-sm shadow-md transition-all cursor-pointer overflow-hidden select-none group"
          >
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
            
            {/* Left Label */}
            <span className="relative z-10 flex items-center gap-2 shrink-0">
              <Send className="w-4 h-4 stroke-[2.2]" />
              <span>Chat via WhatsApp</span>
            </span>

            {/* Right Price */}
            <span className="relative z-10 font-bold text-sm text-white tracking-tight shrink-0">
              {formatRupiah(post.price)}
            </span>
          </button>

          {/* 7. Caption Kecil COD di Bawah Tombol */}
          <p className="text-[11px] text-center text-neutral-400 font-normal flex items-center justify-center gap-1">
            <MapPin className="w-3 h-3 text-neutral-400 shrink-0" />
            <span>COD & Janjian Ketemuan di Lingkungan SMKN 8</span>
          </p>
        </div>
      </div>
    </div>
  );
};
