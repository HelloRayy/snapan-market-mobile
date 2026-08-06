import React, { useState } from 'react';
import { Heart, MessageCircle, MoreHorizontal, Check, BadgeCheck, Box, ArrowRight } from 'lucide-react';
import { MarketThreadItem } from '@/types/marketFeed';
import { ButtonPrimary } from '../ui/ButtonPrimary';

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
        {/* Left Column: Seller Avatar 36x36px (w-9 h-9) */}
        <div className="shrink-0 pt-0.5">
          <div className="relative w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs">
            <img
              src={item.seller.avatar}
              alt={item.seller.name}
              className="w-full h-full object-cover"
            />
            <div className="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 rounded-full bg-slate-900 text-white border-2 border-white flex items-center justify-center text-[9px] font-bold">
              +
            </div>
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
                <BadgeCheck className="w-4 h-4 text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified Seller" />
              )}
              <span className="text-[15px] font-normal text-slate-600 truncate min-w-0 shrink">
                {item.seller.classGroup}
              </span>
            </div>

            {/* Kanan Side: Jam (16px) + Action Btn Titik 3 - High Contrast Text */}
            <div className="flex items-center gap-2 shrink-0 ml-auto">
              <span className="text-[15px] font-normal text-slate-500 whitespace-nowrap">{item.timestamp}</span>
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
            <div className="relative w-full rounded-2xl overflow-hidden border border-neutral-200/80 shadow-2xs bg-neutral-100 max-h-[320px] aspect-[16/10] mt-2.5">
              <img
                src={item.images[0]}
                alt={item.caption}
                className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300"
              />
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
              className="flex gap-2.5 overflow-x-auto scrollbar-none mt-2.5 -ml-[64px] pl-[64px] -mr-4 pr-4 cursor-grab active:cursor-grabbing select-none touch-pan-x"
            >
              {item.images.map((imgUrl, idx) => (
                <div
                  key={idx}
                  className="shrink-0 w-[82%] sm:w-[75%] rounded-2xl overflow-hidden border border-neutral-200/80 shadow-2xs bg-neutral-100 max-h-[340px] aspect-[3/4]"
                >
                  <img
                    src={imgUrl}
                    alt={`${item.caption} - ${idx + 1}`}
                    className="w-full h-full object-cover pointer-events-none"
                  />
                </div>
              ))}
            </div>
          )}

          {/* Bottom E-Commerce Action Bar: [Left: Love | Comment | Stock Icon] --- [Right: Harga & Icon-Only Buy CTA] */}
          <div className="pt-2 flex items-center justify-between gap-2 min-w-0">
            {/* Left Side: Love, Comment & Stock (Icon Only) */}
            <div className="flex items-center gap-3.5 text-slate-600 min-w-0">
              {/* Like Button */}
              <button
                type="button"
                onClick={handleLikeToggle}
                className={`flex items-center gap-1.5 text-xs font-medium hover:opacity-80 active:scale-90 transition-all cursor-pointer ${
                  isLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <Heart className={`w-4.5 h-4.5 stroke-[1.75] ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
                <span className="text-slate-700 font-normal text-[13px]">{likesCount}</span>
              </button>

              {/* Comment Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="flex items-center gap-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
              >
                <MessageCircle className="w-4.5 h-4.5 stroke-[1.75]" />
                <span className="text-slate-700 font-normal text-[13px]">{item.commentsCount}</span>
              </button>

              {/* Stock Indicator (Icon + Number) */}
              {item.stock !== undefined && (
                <div className="flex items-center gap-1 text-slate-500 hover:text-slate-700 transition-colors" title={`Stok tersisa ${item.stock}`}>
                  <Box className="w-4 h-4 stroke-[1.75]" />
                  <span className="text-[13px] font-normal text-slate-600">{item.stock}</span>
                </div>
              )}
            </div>

            {/* Right Side: Exact Kumo UI ButtonPrimary Component "Lihat Detail ->" */}
            <ButtonPrimary
              size="sm"
              onClick={handleAddToCartClick}
              iconRight={isAdded ? null : <ArrowRight className="w-3.5 h-3.5 stroke-[2.25]" />}
              className={`rounded-full shadow-2xs px-3.5 h-8 text-[12px] shrink-0 ml-auto ${
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
    </article>
  );
};
