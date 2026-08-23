import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Heart, MoreHorizontal, Box, Repeat2, Send, PartyPopper, ChevronRight, MapPin, Bookmark, BookmarkCheck, Copy, Flag, BellOff, X } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { formatSmartTimestamp } from '@/utils/formatters';
import { MediaLightboxModal } from './MediaLightboxModal';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';
import { togglePostBookmark } from '@/services/api/bookmarkService';
import { triggerHaptic } from '@/utils/haptics';
import { ProgressiveImage } from '@/ui/components/ui/ProgressiveImage';
import { ThreadsTopicIcon, SmoothCommentIcon } from '@/ui/components/icons';

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

  const [isSaved, setIsSaved] = useState(item.isSaved || false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
  };

  const handleBookmarkToggle = async (e: React.MouseEvent) => {
    e.stopPropagation();
    setIsMenuOpen(false);
    const nextState = !isSaved;
    setIsSaved(nextState);
    showToast(nextState ? 'Postingan disimpan ke Markah 📌' : 'Dihapus dari Markah');

    try {
      if (item.id && item.seller?.id) {
        await togglePostBookmark(item.id, item.seller.id, !nextState);
      }
    } catch (err) {
      // Graceful fallback for guest/offline
    }
  };

  // Fullscreen Media Lightbox State
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);

  // Drag to Scroll Refs for Multi-Image Carousel (Zero-re-render 120 FPS + Pointer Capture)
  const scrollContainerRef = React.useRef<HTMLDivElement>(null);
  const isMouseDownRef = React.useRef(false);
  const startXRef = React.useRef(0);
  const scrollLeftRef = React.useRef(0);
  const hasDraggedRef = React.useRef(false);

  const handlePointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    if (e.button !== 0 && e.pointerType === 'mouse') return;
    if (!scrollContainerRef.current) return;
    isMouseDownRef.current = true;
    hasDraggedRef.current = false;
    startXRef.current = e.clientX;
    scrollLeftRef.current = scrollContainerRef.current.scrollLeft;

    if (e.pointerType === 'mouse') {
      try {
        e.currentTarget.setPointerCapture(e.pointerId);
      } catch {}
    }
  };

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    if (!isMouseDownRef.current || !scrollContainerRef.current) return;
    const dx = e.clientX - startXRef.current;
    if (Math.abs(dx) > 3) {
      hasDraggedRef.current = true;
      scrollContainerRef.current.scrollLeft = scrollLeftRef.current - dx * 1.3;
    }
  };

  const handlePointerUp = (e: React.PointerEvent<HTMLDivElement>) => {
    isMouseDownRef.current = false;
    if (e.pointerType === 'mouse') {
      try {
        e.currentTarget.releasePointerCapture(e.pointerId);
      } catch {}
    }
  };

  const handleImageClick = (e: React.MouseEvent, index: number) => {
    e.stopPropagation();
    if (hasDraggedRef.current) {
      hasDraggedRef.current = false;
      return;
    }
    triggerHaptic('selection');
    setSelectedImageIndex(index);
    setIsLightboxOpen(true);
  };

  const handleLikeToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (isLiked) {
      triggerHaptic('light');
      setIsLiked(false);
      setLikesCount((prev) => prev - 1);
    } else {
      triggerHaptic('medium');
      setIsLiked(true);
      setLikesCount((prev) => prev + 1);
    }
  };

  const handleRepostToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('medium');
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
    triggerHaptic('light');
    const authorHandle = item.seller.username || item.seller.name.toLowerCase().replace(/\s+/g, '') || 'post';
    const shareUrl = `${window.location.origin}/@${authorHandle.replace(/^@/, '')}/post/${item.id}`;
    const shareText = item.price
      ? `🛍️ ${item.caption}\n💰 Rp ${item.price.toLocaleString('id-ID')}\n👤 Penjual: ${item.seller.name} (@${authorHandle})`
      : `🧵 ${item.caption}\n👤 Oleh: ${item.seller.name} (@${authorHandle})`;

    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({
          title: item.title || 'Snapan Market',
          text: shareText,
          url: shareUrl,
        });
      } catch (err) {
        // User cancelled native share dialog
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
  const renderImages = (_isDetail?: boolean) => (
    <>
      {item.images && item.images.length === 1 && (
        <div
          onClick={(e) => handleImageClick(e, 0)}
          className="relative w-full rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[420px] aspect-[4/5] sm:aspect-[16/10] mt-2.5 cursor-pointer touch-pan-y"
        >
          <ProgressiveImage
            src={item.images[0]}
            alt={item.caption}
            className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300 pointer-events-none select-none"
          />
          <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
        </div>
      )}

      {item.images && item.images.length > 1 && (
        <div
          ref={scrollContainerRef}
          data-lenis-prevent
          onPointerDown={handlePointerDown}
          onPointerMove={handlePointerMove}
          onPointerUp={handlePointerUp}
          onPointerCancel={handlePointerUp}
          onClick={(e) => e.stopPropagation()}
          className={`flex gap-2.5 overflow-x-auto scrollbar-none mt-2.5 cursor-grab active:cursor-grabbing select-none overscroll-x-contain touch-auto ${
            _isDetail
              ? '-mx-3.5 pl-3.5 pr-3.5 w-[calc(100%+28px)] max-w-[calc(100%+28px)]'
              : '-ml-[62px] -mr-3.5 pl-[62px] pr-3.5 w-[calc(100%+76px)] max-w-[calc(100%+76px)]'
          }`}
          style={{ WebkitOverflowScrolling: 'touch', touchAction: 'auto' }}
        >
          {item.images.map((imgUrl, idx) => (
            <div
              key={idx}
              onClick={(e) => handleImageClick(e, idx)}
              className="relative shrink-0 w-[84%] sm:w-[76%] rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[420px] aspect-[4/5] sm:aspect-[16/10] cursor-pointer touch-pan-y"
            >
              <ProgressiveImage
                src={imgUrl}
                alt={`${item.caption} - ${idx + 1}`}
                className="w-full h-full object-cover pointer-events-none select-none"
              />
              <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
            </div>
          ))}
        </div>
      )}
    </>
  );

  const renderActionBar = () => (
    <motion.div
      initial={{ opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.2, ease: "easeOut" }}
      className="pt-1 flex items-center justify-between text-slate-700 font-normal -ml-1.5 select-none max-w-full"
    >
      {/* Left Action Buttons Container (Threads Nested Flex Layout) */}
      <div className="flex items-center gap-2 text-slate-700 text-sm font-normal cursor-pointer select-none">
        {/* 1. Suka (Like) Slot */}
        <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
          <div className="flex items-stretch font-normal cursor-pointer">
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleLikeToggle}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer select-none group active:bg-neutral-100 rounded-full transition-colors"
              aria-label={`Sukai postingan. ${likesCount} suka`}
            >
              <motion.div
                animate={isLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
                transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
              >
                <Heart
                  className={`w-[19px] h-[19px] stroke-[1.85] transition-colors duration-200 ${
                    isLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
                  }`}
                />
              </motion.div>
              {likesCount > 0 && (
                <motion.span
                  key={likesCount}
                  initial={{ opacity: 0.6, y: -2 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.15 }}
                  className={`font-medium text-[13.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                    isLiked ? 'text-rose-600 font-bold' : 'text-slate-700'
                  }`}
                >
                  {likesCount}
                </motion.span>
              )}
            </motion.button>
          </div>
        </div>

        {/* 2. Balas (Comment) Slot */}
        <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
          <div className="flex items-stretch font-normal cursor-pointer">
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={(e) => {
                e.stopPropagation();
                onPostClick?.(item);
              }}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer transition-colors text-slate-700 group select-none active:bg-neutral-100 rounded-full"
              aria-label={`Komentar postingan. ${item.commentsCount} komentar`}
            >
              <motion.div
                whileTap={{ scale: [1, 0.85, 1.2, 0.95, 1], y: [0, -2, 0] }}
                transition={{ duration: 0.25 }}
              >
                <SmoothCommentIcon className="w-[19px] h-[19px] stroke-[1.85] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
              </motion.div>
              {item.commentsCount > 0 && (
                <span className="font-medium text-[13.5px] text-slate-700 tabular-nums tracking-tight">{item.commentsCount}</span>
              )}
            </motion.button>
          </div>
        </div>

        {/* 3. Posting Ulang (Repost) Slot */}
        <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
          <div className="flex items-stretch font-normal cursor-pointer">
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleRepostToggle}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer transition-colors select-none group active:bg-neutral-100 rounded-full"
              aria-label={`Post ulang postingan. ${repostsCount} posting ulang`}
            >
              <motion.div
                animate={isReposted ? { rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] } : { rotate: 0, scale: 1 }}
                transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
              >
                <Repeat2
                  className={`w-[19px] h-[19px] stroke-[1.85] transition-colors duration-200 ${
                    isReposted ? 'text-emerald-500 stroke-emerald-500' : 'text-slate-700'
                  }`}
                />
              </motion.div>
              {repostsCount > 0 && (
                <motion.span
                  key={repostsCount}
                  initial={{ opacity: 0.6, y: -2 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.15 }}
                  className={`font-medium text-[13.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                    isReposted ? 'text-emerald-600 font-bold' : 'text-slate-700'
                  }`}
                >
                  {repostsCount}
                </motion.span>
              )}
            </motion.button>
          </div>
        </div>

        {/* 4. Bagikan (Share) Slot */}
        <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
          <div className="flex items-stretch px-0.5 font-normal cursor-pointer">
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleShare}
              className="flex items-center justify-center p-2 min-h-[36px] min-w-[36px] cursor-pointer transition-colors text-slate-700 group select-none active:bg-neutral-100 rounded-full"
              aria-label="Bagikan postingan"
              title="Bagikan / Kirim"
            >
              <motion.div
                whileTap={{ x: [0, 4, -1, 0], y: [0, -4, 1, 0], scale: [1, 1.2, 1] }}
                transition={{ duration: 0.3 }}
              >
                <Send className="w-[19px] h-[19px] stroke-[1.85] text-slate-700 group-hover:text-slate-900 transition-colors duration-200" />
              </motion.div>
            </motion.button>
          </div>
        </div>
      </div>

      {/* 5. Stock Indicator: Compact Inline Pill [ 📦 3 ] (Zero-Wrap Guaranteed) */}
      {item.postType !== 'thread' && !!item.price && item.price > 0 && item.stock !== undefined && item.stock > 0 && (
        <div
          className="flex items-center gap-1 min-h-[26px] px-2 py-0.5 text-neutral-600 bg-neutral-100/90 border border-neutral-200/60 rounded-full text-[12px] select-none ml-auto shrink-0 whitespace-nowrap font-medium transition-colors"
          title={`Sisa stok: ${item.stock} item`}
        >
          <Box className="w-3.5 h-3.5 stroke-[1.8] text-neutral-500 shrink-0" />
          <span className="font-semibold text-slate-800 tabular-nums tracking-tight whitespace-nowrap">{item.stock}</span>
        </div>
      )}
    </motion.div>
  );

  return (
    <article
      onClick={() => onPostClick?.(item)}
      className={`w-full border-b border-neutral-200 bg-pure-white hover:bg-neutral-50/50 transition-colors cursor-pointer font-gt-standard select-none overflow-x-hidden feed-card-perf ${
        variant === 'detail' ? 'px-3.5 pt-3 pb-3.5' : 'px-3.5 py-3'
      }`}
    >
      {variant === 'detail' ? (
        /* DETAIL PAGE VARIANT: Single column, caption & images aligned full-width with top header avatar */
        <div className="space-y-2.5">
          {/* Top Header Row: Profile Picture + Name + Class/Timestamp + More Options (...) */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            <div className="flex items-center gap-2 min-w-0 flex-1 overflow-hidden">
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
                  className="font-semibold text-[14.5px] text-slate-900 truncate hover:underline shrink-1 max-w-[45%] cursor-pointer"
                >
                  {item.seller.name}
                </span>

                {item.seller.isVerified && (
                  <ClickableVerifiedBadge sellerName={item.seller.name} className="w-[16px] h-[16px] shrink-0" />
                )}

                {item.topicTag ? (
                  <div className="flex items-center gap-x-0.5 shrink-1 min-w-0 overflow-hidden ml-0.5 h-[21px] leading-snug">
                    {/* Subtle Grey Chevron Arrow Separator */}
                    <span className="h-[21px] leading-snug flex items-center">
                      <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />
                    </span>

                    {/* Render special blue icon if official topic */}
                    {item.isOfficialTopic && (
                      item.topicIcon === 'presentation' || item.topicIcon === 'party-popper' ? (
                        <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                      ) : (
                        <ThreadsTopicIcon className="w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" />
                      )
                    )}

                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        onTopicClick?.(item.topicTag!);
                      }}
                      className={`font-semibold text-base h-[21px] leading-snug transition-colors cursor-pointer truncate max-w-[140px] sm:max-w-[220px] flex items-center ${
                        item.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:underline'
                      }`}
                    >
                      <span className="leading-snug">{item.topicTag}</span>
                    </button>
                  </div>
                ) : (
                  <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {item.seller.classGroup}
                  </span>
                )}
              </div>
            </div>

            <div className="flex items-center gap-1 shrink-0 ml-auto">
              <span
                className="text-[12px] sm:text-[12.5px] font-normal text-slate-500 whitespace-nowrap tabular-nums cursor-default select-none"
                title={formatSmartTimestamp(item.timestamp).full}
              >
                {formatSmartTimestamp(item.timestamp).display}
              </span>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  setIsMenuOpen(true);
                }}
                className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer"
                aria-label="Opsi postingan"
              >
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Caption Text: Full Width Aligned with Avatar (UX Reading Flow text-base leading-snug) */}
          <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere]">
            <FormattedText text={item.caption} />
            {item.totalThreadParts && item.totalThreadParts > 1 && (
              <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11px] tabular-nums select-none ml-1.5 align-middle">
                1/{item.totalThreadParts}
              </span>
            )}
          </div>

          {/* Product Images: Full Width */}
          {renderImages(true)}

          {/* Location Tag (Placed under media for optimal UX flow) */}
          {item.locationTag && (
            <div className="pt-1 flex items-center gap-1.5 text-[12px] sm:text-[12.5px] text-slate-600 font-medium leading-snug">
              <MapPin className="w-3.5 h-3.5 text-slate-500 stroke-[2] shrink-0" />
              <span className="truncate">{item.locationTag}</span>
            </div>
          )}

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
                  className="font-semibold text-[14.5px] text-slate-900 truncate hover:underline shrink-1 max-w-[45%] cursor-pointer"
                >
                  {item.seller.name}
                </span>
                {item.seller.isVerified && (
                  <ClickableVerifiedBadge sellerName={item.seller.name} className="w-[16px] h-[16px] shrink-0" />
                )}

                {item.topicTag ? (
                  <div className="flex items-center gap-x-0.5 shrink-1 min-w-0 overflow-hidden ml-0.5 h-[21px] leading-snug">
                    {/* Chevron Arrow Separator */}
                    <span className="h-[21px] leading-snug flex items-center">
                      <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />
                    </span>

                    {/* Render special blue icon if official topic */}
                    {item.isOfficialTopic && (
                      item.topicIcon === 'presentation' || item.topicIcon === 'party-popper' ? (
                        <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                      ) : (
                        <ThreadsTopicIcon className="w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" />
                      )
                    )}

                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        onTopicClick?.(item.topicTag!);
                      }}
                      className={`font-semibold text-base h-[21px] leading-snug transition-colors cursor-pointer truncate max-w-[135px] sm:max-w-[200px] flex items-center ${
                        item.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:underline'
                      }`}
                    >
                      <span className="leading-snug">{item.topicTag}</span>
                    </button>
                  </div>
                ) : (
                  <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {item.seller.classGroup}
                  </span>
                )}
              </div>

              <div className="flex items-center gap-1 shrink-0 ml-auto">
                <span
                  className="text-[12px] sm:text-[12.5px] font-normal text-slate-500 whitespace-nowrap tabular-nums cursor-default select-none"
                  title={formatSmartTimestamp(item.timestamp).full}
                >
                  {formatSmartTimestamp(item.timestamp).display}
                </span>
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsMenuOpen(true);
                  }}
                  className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer"
                  aria-label="Opsi postingan"
                >
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Caption Text: Indented under name (UX Reading Flow text-base leading-snug) */}
            <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere]">
              <FormattedText text={item.caption} />
              {item.totalThreadParts && item.totalThreadParts > 1 && (
                <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11px] tabular-nums select-none ml-1.5 align-middle">
                  1/{item.totalThreadParts}
                </span>
              )}
            </div>

            {/* Product Images */}
            {renderImages(false)}

            {/* Location Tag (Placed under media for optimal UX flow) */}
            {item.locationTag && (
              <div className="pt-1 flex items-center gap-1.5 text-[12px] sm:text-[12.5px] text-slate-600 font-medium leading-snug">
                <MapPin className="w-3.5 h-3.5 text-slate-500 stroke-[2] shrink-0" />
                <span className="truncate">{item.locationTag}</span>
              </div>
            )}

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
        likesCount={likesCount}
        repliesCount={item.commentsCount}
        repostsCount={repostsCount}
        isLiked={isLiked}
        isReposted={isReposted}
        onLike={() => {
          if (isLiked) {
            setIsLiked(false);
            setLikesCount((prev) => prev - 1);
          } else {
            setIsLiked(true);
            setLikesCount((prev) => prev + 1);
          }
        }}
        onComment={() => {
          setIsLightboxOpen(false);
          onPostClick?.(item);
        }}
        onRepost={() => {
          if (isReposted) {
            setIsReposted(false);
            setRepostsCount((prev) => Math.max(0, prev - 1));
            showToast('Batal diposting ulang');
          } else {
            setIsReposted(true);
            setRepostsCount((prev) => prev + 1);
            showToast('Postingan berhasil diposting ulang! 🚀');
          }
        }}
        onShare={() => {
          const shareUrl = window.location.href;
          if (navigator.share) {
            navigator.share({
              title: item.title || 'Snapan Market',
              text: `Cek postingan ${item.seller.name} di Snapan Market!`,
              url: shareUrl,
            }).catch(() => {});
          } else {
            navigator.clipboard.writeText(shareUrl).then(() => {
              showToast('Tautan postingan berhasil disalin! 📋');
            }).catch(() => {});
          }
        }}
      />

      {/* 3-Dot Options Action Modal / Bottom Sheet */}
      <AnimatePresence>
        {isMenuOpen && (
          <div
            onClick={(e) => {
              e.stopPropagation();
              setIsMenuOpen(false);
            }}
            className="fixed inset-0 z-[99990] bg-black/40 backdrop-blur-[2px] flex items-end sm:items-center justify-center p-0 sm:p-4"
          >
            <motion.div
              initial={{ y: '100%', opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: '100%', opacity: 0 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full sm:max-w-md bg-white rounded-t-[24px] sm:rounded-[24px] p-4 shadow-2xl border border-neutral-200 select-none overflow-hidden"
            >
              {/* Drag Handle Bar for Mobile */}
              <div className="w-10 h-1 bg-neutral-200 rounded-full mx-auto mb-3 sm:hidden" />

              {/* Modal Header */}
              <div className="flex items-center justify-between pb-3 border-b border-neutral-100 mb-2">
                <div className="flex items-center gap-2">
                  <span className="font-semibold text-slate-900 text-sm">Opsi Postingan</span>
                </div>
                <button
                  type="button"
                  onClick={() => setIsMenuOpen(false)}
                  className="p-1 text-slate-400 hover:text-slate-600 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* Options List */}
              <div className="space-y-1">
                {/* 1. Bookmark / Save Option */}
                <button
                  type="button"
                  onClick={handleBookmarkToggle}
                  className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors text-left group cursor-pointer"
                >
                  <div className={`p-2 rounded-lg ${isSaved ? 'bg-blue-50 text-blue-600' : 'bg-neutral-100 text-slate-700'}`}>
                    {isSaved ? <BookmarkCheck className="w-4 h-4 stroke-[2]" /> : <Bookmark className="w-4 h-4 stroke-[2]" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">
                      {isSaved ? 'Hapus dari Markah' : 'Simpan ke Markah'}
                    </p>
                    <p className="text-[11px] text-slate-500 truncate">
                      {isSaved ? 'Hapus dari daftar postingan tersimpan' : 'Simpan postingan ini ke koleksi markah Anda'}
                    </p>
                  </div>
                </button>

                {/* 2. Copy Link Option */}
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsMenuOpen(false);
                    handleShare(e);
                  }}
                  className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors text-left group cursor-pointer"
                >
                  <div className="p-2 rounded-lg bg-neutral-100 text-slate-700">
                    <Copy className="w-4 h-4 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">Salin Tautan</p>
                    <p className="text-[11px] text-slate-500 truncate">Salin link postingan ke papan klip</p>
                  </div>
                </button>

                {/* 3. Mute User Notifications Option */}
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsMenuOpen(false);
                    showToast(`Notifikasi dari @${item.seller.username || item.seller.name} disenyapkan 🔇`);
                  }}
                  className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-neutral-100 active:bg-neutral-200/80 transition-colors text-left group cursor-pointer"
                >
                  <div className="p-2 rounded-lg bg-neutral-100 text-slate-700">
                    <BellOff className="w-4 h-4 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-900">Senyapkan @{item.seller.username || item.seller.name}</p>
                    <p className="text-[11px] text-slate-500 truncate">Sembunyikan notifikasi dari pengguna ini</p>
                  </div>
                </button>

                {/* 4. Report Option */}
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    setIsMenuOpen(false);
                    showToast('Laporan terkirim! Terima kasih atas masukan Anda 🛡️');
                  }}
                  className="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-rose-50 active:bg-rose-100 transition-colors text-left group cursor-pointer"
                >
                  <div className="p-2 rounded-lg bg-rose-100 text-rose-600">
                    <Flag className="w-4 h-4 stroke-[2]" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-rose-600">Laporkan Postingan</p>
                    <p className="text-[11px] text-rose-500 truncate">Laporkan jika mengandung spam atau konten tidak layak</p>
                  </div>
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Floating Feedback Toast Notification for Repost & Share */}
      {toastMessage && (
        <div className="fixed bottom-20 left-1/2 -translate-x-1/2 z-[99999] px-4 py-2 rounded-full bg-slate-900/95 text-white text-xs font-semibold shadow-2xl border border-white/20 backdrop-blur-md animate-in fade-in slide-in-from-bottom-3 duration-200 pointer-events-none">
          {toastMessage}
        </div>
      )}
    </article>
  );
};
