import React, { useState } from 'react';
import { Heart, MoreHorizontal, Box, Repeat2, Send, PartyPopper, ChevronRight } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { MediaLightboxModal } from './MediaLightboxModal';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';

// Custom Threads 3-Dot Topic Icon
const ThreadsTopicIcon: React.FC<{ className?: string }> = ({ className = "w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" }) => (
  <svg className={className} viewBox="0 0 24 24">
    <circle cx="6" cy="8" r="3" />
    <circle cx="6" cy="16" r="3" />
    <circle cx="15" cy="12" r="3" />
  </svg>
);

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
  item: MarketPostItem;
  onAddToCart?: (item: MarketPostItem) => void;
  onPostClick?: (item: MarketPostItem) => void;
  onTopicClick?: (topic: string) => void;
  onUserClick?: (username: string) => void;
  variant?: 'feed' | 'detail';
}

export const MarketPostCard: React.FC<MarketPostCardProps> = ({
  item,
  onAddToCart: _onAddToCart,
  onPostClick,
  onTopicClick,
  onUserClick,
  variant = 'feed',
}) => {
  const [isLiked, setIsLiked] = useState(item.isLiked || false);
  const [likesCount, setLikesCount] = useState(item.likesCount);

  const [isReposted, setIsReposted] = useState(item.isReposted || false);
  const [repostsCount, setRepostsCount] = useState(item.repostsCount || 0);

  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
  };

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

  const handleRepostToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isReposted) {
      setIsReposted(false);
      setRepostsCount((prev) => Math.max(0, prev - 1));
      showToast('Batal diposting ulang');
    } else {
      setIsReposted(true);
      setRepostsCount((prev) => prev + 1);
      showToast('Postingan berhasil diposting ulang! 🚀');
    }
  };

  const handleShare = async (e: React.MouseEvent) => {
    e.stopPropagation();
    const shareUrl = window.location.href;
    if (navigator.share) {
      try {
        await navigator.share({
          title: item.title || 'Snapan Market',
          text: `Cek postingan ${item.seller.name} di Snapan Market!`,
          url: shareUrl,
        });
      } catch (err) {
        // User cancelled share dialog
      }
    } else {
      try {
        await navigator.clipboard.writeText(shareUrl);
        showToast('Tautan postingan berhasil disalin! 📋');
      } catch (err) {
        showToast('Tautan disalin ke papan klip');
      }
    }
  };

  // Content Snippets used in both variants
  const renderImages = (isDetail: boolean) => (
    <>
      {item.images && item.images.length === 1 && (
        <div
          onClick={(e) => handleImageClick(e, 0)}
          onPointerDown={(e) => e.stopPropagation()}
          className="relative w-full rounded-2xl overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[340px] aspect-[16/10] mt-2.5 cursor-pointer touch-pan-y"
        >
          <img
            src={item.images[0]}
            alt={item.caption}
            loading="lazy"
            decoding="async"
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
          onPointerDown={(e) => e.stopPropagation()}
          className={`flex gap-2.5 overflow-x-auto scrollbar-none mt-2.5 cursor-grab active:cursor-grabbing select-none touch-pan-x touch-pan-y ${
            isDetail ? '-mx-4 px-4' : '-ml-[68px] pl-[68px] -mr-4 pr-4 w-[calc(100%+84px)]'
          }`}
        >
          {item.images.map((imgUrl, idx) => (
            <div
              key={idx}
              onClick={(e) => handleImageClick(e, idx)}
              onPointerDown={(e) => e.stopPropagation()}
              className="relative shrink-0 w-[82%] sm:w-[75%] rounded-2xl overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[340px] aspect-[3/4] cursor-pointer"
            >
              <img
                src={imgUrl}
                alt={`${item.caption} - ${idx + 1}`}
                loading="lazy"
                decoding="async"
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
    <div className="pt-1 flex items-center justify-between text-slate-600 -ml-1 pr-1 max-w-full">
      {/* Left Action Buttons Cluster (Compact Threads-Style Spacing) */}
      <div className="flex items-center gap-1 sm:gap-2">
        {/* 1. Like Button */}
        <button
          type="button"
          onClick={handleLikeToggle}
          className={`flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
            isLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
          }`}
          aria-label={`Sukai postingan. ${likesCount} suka`}
        >
          <Heart className={`w-4.5 h-4.5 stroke-[2] ${isLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
          <span className={`font-normal text-[13.5px] ${isLiked ? 'text-rose-500 font-medium' : 'text-slate-700'}`}>{likesCount}</span>
        </button>

        {/* 2. Comment Button */}
        <button
          type="button"
          onClick={(e) => {
            e.stopPropagation();
            onPostClick?.(item);
          }}
          className="flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
          aria-label={`Komentar postingan. ${item.commentsCount} komentar`}
        >
          <SmoothCommentIcon className="w-4.5 h-4.5 stroke-[2]" />
          <span className="font-normal text-[13.5px] text-slate-700">{item.commentsCount}</span>
        </button>

        {/* 3. Repost Button */}
        <button
          type="button"
          onClick={handleRepostToggle}
          className={`flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
            isReposted ? 'text-emerald-500' : 'text-slate-600 hover:text-slate-900'
          }`}
          aria-label={`Post ulang postingan. ${repostsCount} posting ulang`}
        >
          <Repeat2 className={`w-4.5 h-4.5 stroke-[2] ${isReposted ? 'text-emerald-500' : ''}`} />
          <span className={`font-normal text-[13.5px] ${isReposted ? 'text-emerald-500 font-medium' : 'text-slate-700'}`}>
            {repostsCount}
          </span>
        </button>

        {/* 4. Send / Share Button */}
        <button
          type="button"
          onClick={handleShare}
          className="flex items-center justify-center w-8 h-8 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
          aria-label="Bagikan postingan"
          title="Bagikan / Kirim"
        >
          <Send className="w-4 h-4 stroke-[1.8] text-slate-600" />
        </button>
      </div>

      {/* 5. Stock Indicator (Icon + Label + Number) - ONLY FOR PRODUCT POSTS */}
      {item.postType !== 'thread' && !!item.price && item.price > 0 && item.stock !== undefined && item.stock > 0 && (
        <div className="flex items-center gap-1.5 min-h-[36px] px-2 py-1 text-neutral-500 bg-neutral-100/80 rounded-lg text-[12.5px] select-none ml-auto" title={`Stok tersisa ${item.stock}`}>
          <Box className="w-3.5 h-3.5 stroke-[2] text-neutral-500" />
          <span className="font-normal text-slate-600">Sisa stok: <strong className="font-semibold text-slate-900">{item.stock}</strong></span>
        </div>
      )}
    </div>
  );

  return (
    <article
      onClick={() => onPostClick?.(item)}
      className={`w-full border-b border-neutral-200 bg-pure-white hover:bg-neutral-50/50 transition-colors cursor-pointer font-gt-standard select-none overflow-visible ${
        variant === 'detail' ? 'px-4 pt-3 pb-3.5' : 'px-4 py-3.5'
      }`}
    >
      {variant === 'detail' ? (
        /* DETAIL PAGE VARIANT: Single column, caption & images aligned full-width with top header avatar */
        <div className="space-y-2.5">
          {/* Top Header Row: Profile Picture + Name + Class/Timestamp + More Options (...) */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            <div className="flex items-center gap-2.5 min-w-0 flex-1 overflow-hidden">
              <div
                onClick={(e) => {
                  e.stopPropagation();
                  onUserClick?.(item.seller.username || item.seller.name);
                }}
                className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 cursor-pointer active:scale-95 transition-transform"
              >
                <img
                  src={item.seller.avatar}
                  alt={item.seller.name}
                  className="w-full h-full object-cover"
                />
              </div>

              <div className="flex items-center gap-1 min-w-0 flex-1 overflow-hidden">
                <span
                  onClick={(e) => {
                    e.stopPropagation();
                    onUserClick?.(item.seller.username || item.seller.name);
                  }}
                  className="font-semibold text-[15px] text-slate-900 truncate hover:underline shrink-1 max-w-[45%] cursor-pointer"
                >
                  {item.seller.name}
                </span>

                {item.seller.isVerified && (
                  <ClickableVerifiedBadge sellerName={item.seller.name} className="w-[17px] h-[17px] shrink-0" />
                )}

                {item.topicTag ? (
                  <div className="flex items-center gap-1 shrink-1 min-w-0 overflow-hidden ml-0.5">
                    {/* Larger Chevron Arrow Separator */}
                    <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2.5] shrink-0" />

                    {/* Render special blue icon if official topic */}
                    {item.isOfficialTopic && (
                      item.topicIcon === 'presentation' || item.topicIcon === 'party-popper' ? (
                        <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                      ) : (
                        <ThreadsTopicIcon />
                      )
                    )}

                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        onTopicClick?.(item.topicTag!);
                      }}
                      className={`font-bold text-[14px] transition-colors cursor-pointer truncate max-w-[140px] sm:max-w-[220px] ${
                        item.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:text-[#1d64ec] hover:underline'
                      }`}
                    >
                      {item.topicTag}
                    </button>
                  </div>
                ) : (
                  <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {item.seller.classGroup}
                  </span>
                )}
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
            <FormattedText text={item.caption} />
            {item.totalThreadParts && item.totalThreadParts > 1 && (
              <span className="text-[13px] font-bold text-neutral-400 tabular-nums ml-2 select-none inline-block">
                1/{item.totalThreadParts}
              </span>
            )}
          </p>

          {/* Product Images: Full Width */}
          {renderImages(true)}

          {/* Action Bar */}
          {renderActionBar()}
        </div>
      ) : (
        /* FEED VARIANT: Two-column layout with left Avatar and right Content Column */
        <div className="flex gap-3 items-start min-w-0">
          {/* Left Column: Avatar + Profile Click Zone */}
          <div className="flex flex-col items-center shrink-0">
            <div
              onClick={(e) => {
                e.stopPropagation();
                onUserClick?.(item.seller.username || item.seller.name);
              }}
              className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 cursor-pointer active:scale-95 transition-transform"
            >
              <img
                src={item.seller.avatar}
                alt={item.seller.name}
                loading="lazy"
                decoding="async"
                className="w-full h-full object-cover"
              />
            </div>
          </div>

          {/* Right Column: Content starting directly under Name */}
          <div className="flex-1 min-w-0 space-y-1 overflow-visible">
            {/* Header Row: Name + Verified + (Topic OR Class) + Timestamp + More Options (...) */}
            <div className="flex items-center justify-between gap-2 min-w-0">
              <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                <span
                  onClick={(e) => {
                    e.stopPropagation();
                    onUserClick?.(item.seller.username || item.seller.name);
                  }}
                  className="font-semibold text-[15.5px] text-slate-900 truncate hover:underline shrink-1 max-w-[45%] cursor-pointer"
                >
                  {item.seller.name}
                </span>
                {item.seller.isVerified && (
                  <ClickableVerifiedBadge sellerName={item.seller.name} className="w-[17.5px] h-[17.5px] shrink-0" />
                )}

                {item.topicTag ? (
                  <div className="flex items-center gap-1 shrink-1 min-w-0 overflow-hidden ml-0.5">
                    {/* Larger Chevron Arrow Separator */}
                    <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2.5] shrink-0" />

                    {/* Render special blue icon if official topic */}
                    {item.isOfficialTopic && (
                      item.topicIcon === 'presentation' || item.topicIcon === 'party-popper' ? (
                        <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                      ) : (
                        <ThreadsTopicIcon />
                      )
                    )}

                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        onTopicClick?.(item.topicTag!);
                      }}
                      className={`font-bold text-[14.5px] transition-colors cursor-pointer truncate max-w-[135px] sm:max-w-[200px] ${
                        item.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:text-[#1d64ec] hover:underline'
                      }`}
                    >
                      {item.topicTag}
                    </button>
                  </div>
                ) : (
                  <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {item.seller.classGroup}
                  </span>
                )}
              </div>

              <div className="flex items-center gap-1.5 shrink-0 ml-auto">
                <span className="text-[13.5px] sm:text-[14px] font-normal text-neutral-400 whitespace-nowrap">{item.timestamp}</span>
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
              <FormattedText text={item.caption} />
              {item.totalThreadParts && item.totalThreadParts > 1 && (
                <span className="text-[13px] font-bold text-neutral-400 tabular-nums ml-2 select-none inline-block">
                  1/{item.totalThreadParts}
                </span>
              )}
            </p>

            {/* Product Images */}
            {renderImages(false)}

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

      {/* Floating Feedback Toast Notification for Repost & Share */}
      {toastMessage && (
        <div className="fixed bottom-20 left-1/2 -translate-x-1/2 z-[99999] px-4 py-2 rounded-full bg-slate-900/95 text-white text-xs font-semibold shadow-2xl border border-white/20 backdrop-blur-md animate-in fade-in slide-in-from-bottom-3 duration-200 pointer-events-none">
          {toastMessage}
        </div>
      )}
    </article>
  );
};
