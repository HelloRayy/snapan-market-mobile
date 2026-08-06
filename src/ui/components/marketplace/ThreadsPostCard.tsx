import React, { useState } from 'react';
import { Heart, MessageCircle, Repeat2, Send, MoreHorizontal, ShoppingCart, Check, MapPin, ShieldCheck } from 'lucide-react';
import { MarketThreadItem } from '@/types/threadsFeed';
import { formatRupiah } from '@/utils/formatters';

interface ThreadsPostCardProps {
  item: MarketThreadItem;
  onAddToCart?: (item: MarketThreadItem) => void;
  onPostClick?: (item: MarketThreadItem) => void;
}

export const ThreadsPostCard: React.FC<ThreadsPostCardProps> = ({
  item,
  onAddToCart,
  onPostClick,
}) => {
  const [isLiked, setIsLiked] = useState(item.isLiked || false);
  const [likesCount, setLikesCount] = useState(item.likesCount);
  const [isAdded, setIsAdded] = useState(false);

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
      className="w-full border-b border-neutral-100 bg-pure-white px-4 py-3.5 hover:bg-neutral-50/50 transition-colors cursor-pointer font-gt-standard select-none"
    >
      <div className="flex items-start gap-3">
        {/* Left Column: Seller Avatar 36x36px with Threads '+' Badge + Connector Line */}
        <div className="flex flex-col items-center shrink-0 self-stretch">
          {/* Avatar Image 36x36px (w-9 h-9) */}
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

          {/* Threads Vertical Connector Line */}
          <div className="w-0.5 flex-1 bg-neutral-200/70 my-2 rounded-full min-h-[36px]" />

          {/* Mini Sub Avatar Count Indicator */}
          <div className="w-5 h-5 rounded-full bg-neutral-100 border border-neutral-200/80 flex items-center justify-center text-[9px] font-normal text-neutral-500">
            8
          </div>
        </div>

        {/* Right Column: Content */}
        <div className="flex-1 min-w-0 space-y-2">
          {/* Top Header Row: Name (16px), Class Badge, Timestamp (16px) & Menu */}
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-1.5 min-w-0 flex-wrap">
              <span className="font-semibold text-[16px] text-slate-900 truncate hover:underline">
                {item.seller.name}
              </span>
              {item.seller.isVerified && (
                <ShieldCheck className="w-4 h-4 text-[#1d64ec] shrink-0" aria-label="Verified Seller" />
              )}
              <span className="text-[11px] font-normal px-2 py-0.5 rounded-full bg-blue-50/80 text-[#1d64ec] border border-blue-100 shrink-0">
                {item.seller.classGroup}
              </span>
            </div>

            <div className="flex items-center gap-1.5 shrink-0">
              <span className="text-[16px] font-normal text-neutral-400">{item.timestamp}</span>
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="text-neutral-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors"
                aria-label="Opsi postingan"
              >
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Post Text / Caption (16px Normal Weight) */}
          <p className="text-[16px] text-slate-900 font-normal leading-snug break-words">
            {item.caption}
          </p>

          {/* Price Tag & Location Tag Badge Pill Bar */}
          <div className="flex items-center gap-2 flex-wrap pt-0.5">
            {/* Main Price Tag Pill */}
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-900 text-white shadow-2xs">
              <span className="text-[11px] font-normal text-neutral-300">Harga:</span>
              <span className="text-xs font-semibold tracking-tight">
                {formatRupiah(item.price)}
              </span>
              {item.originalPrice && item.originalPrice > item.price && (
                <span className="text-[10px] text-neutral-400 line-through font-normal">
                  {formatRupiah(item.originalPrice)}
                </span>
              )}
            </div>

            {/* Location Tag Badge */}
            {item.locationTag && (
              <div className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-neutral-100 border border-neutral-200/80 text-[11px] font-normal text-slate-700">
                <MapPin className="w-3 h-3 text-[#1d64ec]" />
                <span>{item.locationTag}</span>
              </div>
            )}
          </div>

          {/* Product Image Card (Adjustable height max 280px) */}
          {item.images && item.images.length > 0 && (
            <div className="relative w-full rounded-2xl overflow-hidden border border-neutral-200/80 shadow-2xs bg-neutral-100 max-h-[280px] aspect-[16/10.5] mt-1.5">
              <img
                src={item.images[0]}
                alt={item.caption}
                className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300"
              />
              {/* Category Badge Pill */}
              <div className="absolute top-2.5 left-2.5 px-2.5 py-0.5 rounded-md bg-black/60 backdrop-blur-md text-white text-[10px] font-medium uppercase tracking-wider">
                {item.category}
              </div>
            </div>
          )}

          {/* Bottom Threads Action Bar & Buy Button (Light Weight Counters) */}
          <div className="pt-1.5 flex items-center justify-between gap-2">
            {/* Social Actions (Like, Comment, Repost, Share) */}
            <div className="flex items-center gap-4 text-neutral-600">
              {/* Like Button */}
              <button
                type="button"
                onClick={handleLikeToggle}
                className={`flex items-center gap-1.5 text-xs font-normal hover:opacity-80 active:scale-90 transition-all cursor-pointer ${
                  isLiked ? 'text-rose-500' : 'text-neutral-600'
                }`}
              >
                <Heart className={`w-4.5 h-4.5 stroke-[1.75] ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
                <span className="text-neutral-500">{likesCount}</span>
              </button>

              {/* Comment Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="flex items-center gap-1.5 text-xs font-normal text-neutral-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
              >
                <MessageCircle className="w-4.5 h-4.5 stroke-[1.75]" />
                <span className="text-neutral-500">{item.commentsCount}</span>
              </button>

              {/* Repost Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="flex items-center gap-1.5 text-xs font-normal text-neutral-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
              >
                <Repeat2 className="w-4.5 h-4.5 stroke-[1.75]" />
                <span className="text-neutral-500">{item.repostsCount}</span>
              </button>

              {/* Share Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="text-neutral-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
                aria-label="Bagikan"
              >
                <Send className="w-4.5 h-4.5 stroke-[1.75]" />
              </button>
            </div>

            {/* Quick Buy / Add to Cart Primary Button */}
            <button
              type="button"
              onClick={handleAddToCartClick}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold transition-all shadow-2xs cursor-pointer active:scale-95 ${
                isAdded
                  ? 'bg-emerald-600 text-white'
                  : 'bg-[#1d64ec] hover:bg-blue-600 text-white'
              }`}
            >
              {isAdded ? (
                <>
                  <Check className="w-3.5 h-3.5" />
                  <span>Keranjang</span>
                </>
              ) : (
                <>
                  <ShoppingCart className="w-3.5 h-3.5" />
                  <span>Beli</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </article>
  );
};
