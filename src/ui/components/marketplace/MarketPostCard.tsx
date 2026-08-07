import React, { useState } from 'react';
import { Heart, MoreHorizontal, Check, BadgeCheck, Box, ArrowRight } from 'lucide-react';
import { MarketThreadItem } from '@/types/marketFeed';
import { ButtonPrimary } from '../ui/ButtonPrimary';
import { MediaLightboxModal } from './MediaLightboxModal';

// Custom Smooth Rounded Lucide-Family Comment Icon (Rounded tail tip, 100% Lucide family match)
const SmoothCommentIcon: React.FC<{ className?: string }> = ({ className }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.75"
    strokeLinecap="round"
    strokeLinejoin="round"
    className={className}
  >
    <path d="M2.992 16.342a2 2 0 0 1 .094 1.167l-.8 2.5c-.25.78.47 1.5 1.25 1.25l2.5-.8a2 2 0 0 1 1.1.09 10 10 0 1 0-4.144-4.207Z" />
  </svg>
);

interface MarketPostCardProps {
  item: MarketThreadItem;
  onAddToCart?: (item: MarketThreadItem) => void;
  onPostClick?: (item: MarketThreadItem) => void;
}

export const MarketPostCard: React.FC<MarketPostCardProps> = ({
  item,
  onAddToCart,
  onPostClick,
}) => {
  const [isLiked, setIsLiked] = useState(item.isLiked || false);
  const [likesCount, setLikesCount] = useState(item.likesCount);
  const [isAdded, setIsAdded] = useState(false);

  // Fullscreen Media Lightbox State
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);

  const handleImageClick = (e: React.MouseEvent, index: number) => {
    e.stopPropagation();
    setSelectedImageIndex(index);
    setIsLightboxOpen(true);
  };

  // Drag to Scroll State for Multi-Image Carousel
  const scrollContainerRef = React.useRef<HTMLDivElement>(null);
  const [isMouseDown, setIsMouseDown] = useState(false);
  const [startX, setStartX] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);

  const handleMouseDown = (e: React.MouseEvent) => {
    if (!scrollContainerRef.current) return;
    setIsMouseDown(true);
    setStartX(e.pageX - scrollContainerRef.current.offsetLeft);
    setScrollLeft(scrollContainerRef.current.scrollLeft);
  };

  const handleMouseLeaveOrUp = () => {
    setIsMouseDown(false);
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isMouseDown || !scrollContainerRef.current) return;
    e.preventDefault();
    const x = e.pageX - scrollContainerRef.current.offsetLeft;
    const walk = (x - startX) * 1.5;
    scrollContainerRef.current.scrollLeft = scrollLeft - walk;
  };

  const handleLikeToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isLiked) {
      setIsLiked(false);
      setLikesCount((prev) => prev - 1);
    } else {
      setIsLiked(true);
      setLikesCount((prev) => prev + 1);
    }
  };

  const handleAddToCartClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    onAddToCart?.(item);
    setIsAdded(true);
    setTimeout(() => {
      setIsAdded(false);
    }, 1500);
  };

  return (
    <article
      onClick={() => onPostClick?.(item)}
      className="w-full border-b border-neutral-200 bg-pure-white px-4 py-3.5 hover:bg-neutral-50/50 transition-colors cursor-pointer font-gt-standard select-none overflow-visible"
    >
      <div className="flex items-start gap-3">
        {/* Left Column: Seller Avatar 40x40px (w-10 h-10) */}
        <div className="shrink-0 pt-0.5">
          <div className="w-10 h-10 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs">
            <img
              src={item.seller.avatar}
              alt={item.seller.name}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Right Column: Content starting directly under Name */}
        <div className="flex-1 min-w-0 space-y-1 overflow-visible">
          {/* Top Header Row: Kiri = Nama, Verif, Kelas | Kanan = Jam, Titik 3 */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            {/* Kiri Side: Nama + Verif Icon + Kelas - High contrast WCAG compliance */}
            <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
              <span className="font-semibold text-[16px] text-slate-900 truncate hover:underline shrink-0 max-w-[60%]">
                {item.seller.name}
              </span>
              {item.seller.isVerified && (
                <BadgeCheck className="w-[18px] h-[18px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified Seller" />
              )}
              <span className="text-[14px] font-normal text-neutral-400 truncate min-w-0 shrink">
                {item.seller.classGroup}
              </span>
            </div>

            {/* Kanan Side: Jam (14px) + Action Btn Titik 3 - Muted Contrast Text */}
            <div className="flex items-center gap-2 shrink-0 ml-auto">
              <span className="text-[14px] font-normal text-neutral-400 whitespace-nowrap">{item.timestamp}</span>
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                aria-label="Opsi postingan"
              >
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Bawah Nama = Description Caption Text */}
          <p className="text-[16px] text-slate-900 font-normal leading-snug break-words">
            {item.caption}
          </p>

          {/* Product Image Gallery (Supports Single & Multi-Image Carousel with Free Scroll) */}
          {item.images && item.images.length === 1 && (
            <div
              onClick={(e) => handleImageClick(e, 0)}
              className="relative w-full rounded-2xl overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[320px] aspect-[16/10] mt-2.5 cursor-pointer touch-pan-y"
            >
              <img
                src={item.images[0]}
                alt={item.caption}
                className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300 pointer-events-none"
              />
              <div className="absolute inset-0 rounded-2xl ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
            </div>
          )}

          {item.images && item.images.length > 1 && (
            <div
              ref={scrollContainerRef}
              onMouseDown={handleMouseDown}
              onMouseLeave={handleMouseLeaveOrUp}
              onMouseUp={handleMouseLeaveOrUp}
              onMouseMove={handleMouseMove}
              onClick={(e) => e.stopPropagation()}
              className="flex gap-2.5 overflow-x-auto scrollbar-none mt-2.5 -ml-[68px] pl-[68px] -mr-4 pr-4 cursor-grab active:cursor-grabbing select-none touch-pan-x touch-pan-y"
            >
              {item.images.map((imgUrl, idx) => (
                <div
                  key={idx}
                  onClick={(e) => handleImageClick(e, idx)}
                  className="relative shrink-0 w-[82%] sm:w-[75%] rounded-2xl overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[340px] aspect-[3/4] cursor-pointer"
                >
                  <img
                    src={imgUrl}
                    alt={`${item.caption} - ${idx + 1}`}
                    className="w-full h-full object-cover pointer-events-none"
                  />
                  <div className="absolute inset-0 rounded-2xl ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
                </div>
              ))}
            </div>
          )}

          {/* Bottom E-Commerce Action Bar: [Left: Love | Comment | Stock Icon] --- [Right: Button CTA] */}
          <div className="pt-2.5 flex flex-wrap items-center justify-between gap-y-2 gap-x-1 min-w-0">
            {/* Left Side: Love, Comment & Stock (Icon Only with Generous 44px Mobile Touch Target) */}
            <div className="flex items-center gap-0.5 sm:gap-1.5 text-slate-600 shrink-0 -ml-1.5">
              {/* Like Button */}
              <button
                type="button"
                onClick={handleLikeToggle}
                className={`flex items-center gap-1.5 min-h-[40px] px-2.5 py-1.5 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
                  isLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
                }`}
                aria-label={`Sukai postingan. ${likesCount} suka`}
              >
                <Heart className={`w-5 h-5 stroke-[2] ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
                <span className={`font-normal text-[14px] ${isLiked ? 'text-rose-500' : 'text-slate-700'}`}>{likesCount}</span>
              </button>

              {/* Comment Button */}
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  onPostClick?.(item);
                }}
                className="flex items-center gap-1.5 min-h-[40px] px-2.5 py-1.5 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
                aria-label={`Komentar postingan. ${item.commentsCount} komentar`}
              >
                <SmoothCommentIcon className="w-5 h-5 stroke-[2]" />
                <span className="font-normal text-[14px] text-slate-700">{item.commentsCount}</span>
              </button>

              {/* Stock Indicator (Icon + Number) */}
              {item.stock !== undefined && (
                <div className="flex items-center gap-1.5 min-h-[40px] px-2 py-1.5 text-slate-500 hover:text-slate-700 transition-colors select-none" title={`Stok tersisa ${item.stock}`}>
                  <Box className="w-4.5 h-4.5 stroke-[2] text-slate-500" />
                  <span className="font-normal text-[14px] text-slate-700">{item.stock}</span>
                </div>
              )}
            </div>

            {/* Right Side: Exact Kumo UI ButtonPrimary Component "Lihat Detail ->" */}
            <ButtonPrimary
              size="sm"
              onClick={(e) => {
                e.stopPropagation();
                if (onPostClick) {
                  onPostClick(item);
                } else {
                  handleAddToCartClick(e);
                }
              }}
              iconRight={isAdded ? null : <ArrowRight className="w-3.5 h-3.5 stroke-[2.25]" />}
              className={`rounded-full shadow-2xs px-3 h-7.5 text-[11.5px] shrink-0 ml-auto ${
                isAdded ? 'bg-emerald-600 border-emerald-700' : ''
              }`}
              aria-label="Lihat Detail Produk"
            >
              {isAdded ? (
                <span className="flex items-center gap-1.5">
                  <Check className="w-3.5 h-3.5" />
                  <span>Keranjang</span>
                </span>
              ) : (
                'Lihat Detail'
              )}
            </ButtonPrimary>
          </div>
        </div>
      </div>

      {/* Fullscreen Media Lightbox Modal */}
      <MediaLightboxModal
        isOpen={isLightboxOpen}
        images={item.images || []}
        initialIndex={selectedImageIndex}
        onClose={() => setIsLightboxOpen(false)}
        caption={item.caption}
      />
    </article>
  );
};
