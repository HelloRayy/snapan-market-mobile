import React, { useState } from 'react';
import { Heart, MessageCircle, Repeat2, Send, MoreHorizontal, ShoppingCart, Check, BadgeCheck } from 'lucide-react';
import { MarketThreadItem } from '@/types/threadsFeed';

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
        <div className="flex-1 min-w-0 space-y-1">
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



          {/* Product Image Card (Max height 280px) */}
          {item.images && item.images.length > 0 && (
            <div className="relative w-full rounded-2xl overflow-hidden border border-neutral-200/80 shadow-2xs bg-neutral-100 max-h-[280px] aspect-[16/10.5] mt-1">
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

          {/* Bottom Threads Action Bar & Buy Button */}
          <div className="pt-1 flex items-center justify-between gap-2">
            {/* Social Actions (Like, Comment, Repost, Share) */}
            <div className="flex items-center gap-4 text-slate-600">
              {/* Like Button */}
              <button
                type="button"
                onClick={handleLikeToggle}
                className={`flex items-center gap-1.5 text-xs font-medium hover:opacity-80 active:scale-90 transition-all cursor-pointer ${
                  isLiked ? 'text-rose-500' : 'text-slate-600'
                }`}
              >
                <Heart className={`w-4.5 h-4.5 stroke-[1.75] ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
                <span className="text-slate-600">{likesCount}</span>
              </button>

              {/* Comment Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="flex items-center gap-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
              >
                <MessageCircle className="w-4.5 h-4.5 stroke-[1.75]" />
                <span className="text-slate-600">{item.commentsCount}</span>
              </button>

              {/* Repost Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="flex items-center gap-1.5 text-xs font-medium text-slate-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
              >
                <Repeat2 className="w-4.5 h-4.5 stroke-[1.75]" />
                <span className="text-slate-600">{item.repostsCount}</span>
              </button>

              {/* Share Button */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="text-slate-600 hover:text-slate-900 active:scale-90 transition-all cursor-pointer"
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
