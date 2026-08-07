import React, { useState } from 'react';
import { Heart, MoreHorizontal, BadgeCheck, Box } from 'lucide-react';
import { MarketThreadItem } from '@/types/marketFeed';
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
  variant?: 'feed' | 'detail';
}

export const MarketPostCard: React.FC<MarketPostCardProps> = ({
  item,
  onPostClick,
  variant = 'feed',
}) => {
  const [isLiked, setIsLiked] = useState(item.isLiked || false);
  const [likesCount, setLikesCount] = useState(item.likesCount);

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

  // Content Snippets used in both variants
  const renderImages = () => (
    <>
      {item.images && item.images.length === 1 && (
        <div
          onClick={(e) => handleImageClick(e, 0)}
          className="relative w-full rounded-2xl overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[340px] aspect-[16/10] mt-2.5 cursor-pointer touch-pan-y"
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
          className="flex gap-2.5 overflow-x-auto scrollbar-none mt-2.5 -mx-4 px-4 cursor-grab active:cursor-grabbing select-none touch-pan-x touch-pan-y"
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
    </>
  );

  const renderActionBar = () => (
    <div className="pt-1 flex items-center gap-1 text-slate-600 -ml-1">
      {/* Like Button */}
      <button
        type="button"
        onClick={handleLikeToggle}
        className={`flex items-center gap-1.5 min-h-[36px] px-2.5 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
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
        className="flex items-center gap-1.5 min-h-[36px] px-2.5 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
        aria-label={`Komentar postingan. ${item.commentsCount} komentar`}
      >
        <SmoothCommentIcon className="w-5 h-5 stroke-[2]" />
        <span className="font-normal text-[14px] text-slate-700">{item.commentsCount}</span>
      </button>

      {/* Stock Indicator (Icon + Number) */}
      {item.stock !== undefined && (
        <div className="flex items-center gap-1.5 min-h-[36px] px-2.5 py-1 text-slate-500 hover:text-slate-700 transition-colors select-none" title={`Stok tersisa ${item.stock}`}>
          <Box className="w-4.5 h-4.5 stroke-[2] text-slate-500" />
          <span className="font-normal text-[14px] text-slate-700">{item.stock}</span>
        </div>
      )}
    </div>
  );

  return (
    <article
      onClick={() => onPostClick?.(item)}
      className={`w-full border-b border-neutral-200 bg-pure-white hover:bg-neutral-50/50 transition-colors cursor-pointer font-gt-standard select-none overflow-visible ${
        variant === 'detail' ? 'px-3 pt-1 pb-3' : 'px-4 py-3.5'
      }`}
    >
      {variant === 'detail' ? (
        /* DETAIL PAGE VARIANT: Single column, caption & images aligned full-width with top header avatar */
        <div className="space-y-2.5">
          {/* Top Header Row: Profile Picture + Name + Class/Timestamp + More Options (...) */}
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2.5 min-w-0 flex-1 overflow-hidden">
              <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0">
                <img
                  src={item.seller.avatar}
                  alt={item.seller.name}
                  className="w-full h-full object-cover"
                />
              </div>

              <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                <span className="font-semibold text-[15px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
                  {item.seller.name}
                </span>

                {item.seller.isVerified && (
                  <BadgeCheck className="w-[17px] h-[17px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified Seller" />
                )}

                <span className="text-[14px] font-normal text-neutral-400 truncate min-w-0 shrink">
                  {item.timestamp}
                </span>
              </div>
            </div>

            <button
              type="button"
              onClick={(e) => e.stopPropagation()}
              className="text-slate-500 hover:text-slate-900 p-1.5 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
              aria-label="Opsi postingan"
            >
              <MoreHorizontal className="w-4 h-4" />
            </button>
          </div>

          {/* Caption Text: Full Width Aligned with Avatar */}
          <p className="text-[15px] text-slate-900 font-normal leading-snug break-words">
            {item.caption}
          </p>

          {/* Product Images: Full Width */}
          {renderImages()}

          {/* Action Bar */}
          {renderActionBar()}
        </div>
      ) : (
        /* HOME FEED VARIANT: 2-Column layout, caption & images indented under seller name */
        <div className="flex items-start gap-3">
          {/* Left Column: Seller Avatar 40x40px */}
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
            {/* Header Row: Name + Verified + Class/Timestamp + More Options (...) */}
            <div className="flex items-center justify-between gap-2 min-w-0">
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

            {/* Caption Text: Indented under name */}
            <p className="text-[16px] text-slate-900 font-normal leading-snug break-words">
              {item.caption}
            </p>

            {/* Product Images */}
            {renderImages()}

            {/* Action Bar */}
            {renderActionBar()}
          </div>
        </div>
      )}

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
