import React, { useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { Heart, MoreHorizontal, Repeat2, Send, ChevronRight, PartyPopper, Box } from 'lucide-react';
import { UserReplyThread, MarketPostItem } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';
import { MediaLightboxModal } from './MediaLightboxModal';
import { PostOptionsModal } from './PostOptionsModal';
import { ProgressiveImage } from '@/ui/components/ui/ProgressiveImage';
import { triggerHaptic } from '@/utils/haptics';
import { ThreadsTopicIcon, SmoothCommentIcon } from '@/ui/components/icons';

interface ReplyThreadCardProps {
  thread: UserReplyThread;
  onPostClick?: (post: MarketPostItem) => void;
  onTopicClick?: (topic: string) => void;
  onUserClick?: (username: string) => void;
}

export const ReplyThreadCard: React.FC<ReplyThreadCardProps> = ({
  thread,
  onPostClick,
  onTopicClick,
  onUserClick,
}) => {
  const { parentPost, reply } = thread;

  // Parent Post State
  const [parentLiked, setParentLiked] = useState(parentPost.isLiked || false);
  const [parentLikesCount, setParentLikesCount] = useState(parentPost.likesCount);
  const [parentReposted, setParentReposted] = useState(parentPost.isReposted || false);
  const [parentRepostsCount, setParentRepostsCount] = useState(parentPost.repostsCount);

  // Reply Post State
  const [replyLiked, setReplyLiked] = useState(reply.isLiked || false);
  const [replyLikesCount, setReplyLikesCount] = useState(reply.likesCount);
  const [replyReposted, setReplyReposted] = useState(reply.isReposted || false);
  const [replyRepostsCount, setReplyRepostsCount] = useState(reply.repostsCount || 0);

  // 3-Dot Options Modal States
  const [isParentMenuOpen, setIsParentMenuOpen] = useState(false);
  const [isReplyMenuOpen, setIsReplyMenuOpen] = useState(false);

  // Lightbox State
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);

  // Drag to Scroll State for Multi-Image Carousel
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const isMouseDownRef = useRef(false);
  const startXRef = useRef(0);
  const scrollLeftRef = useRef(0);
  const hasDraggedRef = useRef(false);

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

  const handleParentLike = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (parentLiked) {
      triggerHaptic('light');
      setParentLiked(false);
      setParentLikesCount((prev) => Math.max(0, prev - 1));
    } else {
      triggerHaptic('medium');
      setParentLiked(true);
      setParentLikesCount((prev) => prev + 1);
    }
  };

  const handleParentRepost = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (parentReposted) {
      triggerHaptic('light');
      setParentReposted(false);
      setParentRepostsCount((prev) => Math.max(0, prev - 1));
    } else {
      triggerHaptic('medium');
      setParentReposted(true);
      setParentRepostsCount((prev) => prev + 1);
    }
  };

  const handleReplyLike = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (replyLiked) {
      triggerHaptic('light');
      setReplyLiked(false);
      setReplyLikesCount((prev) => Math.max(0, prev - 1));
    } else {
      triggerHaptic('medium');
      setReplyLiked(true);
      setReplyLikesCount((prev) => prev + 1);
    }
  };

  const handleReplyRepost = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('medium');
    if (replyReposted) {
      setReplyReposted(false);
      setReplyRepostsCount((prev) => Math.max(0, prev - 1));
    } else {
      setReplyReposted(true);
      setReplyRepostsCount((prev) => prev + 1);
    }
  };

  const handleShare = (e: React.MouseEvent, title: string, text: string) => {
    e.stopPropagation();
    triggerHaptic('light');
    if (navigator.share) {
      navigator.share({
        title,
        text,
        url: window.location.href,
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(window.location.href);
      alert('Tautan postingan berhasil disalin!');
    }
  };

  const renderParentImages = () => {
    if (!parentPost.images || parentPost.images.length === 0) return null;

    if (parentPost.images.length === 1) {
      return (
        <div
          onClick={(e) => {
            e.stopPropagation();
            setSelectedImageIndex(0);
            setIsLightboxOpen(true);
          }}
          className="relative w-full rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[420px] aspect-[4/5] sm:aspect-[16/10] mt-2.5 cursor-pointer touch-pan-y"
        >
          <ProgressiveImage
            src={parentPost.images[0]}
            alt={parentPost.title || parentPost.caption}
            className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300 pointer-events-none select-none"
          />
          <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
        </div>
      );
    }

    return (
      <div
        ref={scrollContainerRef}
        data-lenis-prevent
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
        onClick={(e) => e.stopPropagation()}
        className="flex gap-2.5 overflow-x-auto no-scrollbar scrollbar-none mt-2.5 cursor-grab active:cursor-grabbing select-none overscroll-x-contain touch-auto -ml-[64px] -mr-4 pl-[64px] pr-4 w-[calc(100%+80px)] max-w-[calc(100%+80px)]"
        style={{ WebkitOverflowScrolling: 'touch', touchAction: 'auto' }}
      >
        {parentPost.images.map((imgUrl, idx) => (
          <div
            key={idx}
            onClick={(e) => {
              e.stopPropagation();
              if (hasDraggedRef.current) {
                hasDraggedRef.current = false;
                return;
              }
              setSelectedImageIndex(idx);
              setIsLightboxOpen(true);
            }}
            className="relative shrink-0 w-[84%] sm:w-[76%] rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[420px] aspect-[4/5] sm:aspect-[16/10] cursor-pointer touch-pan-y"
          >
            <ProgressiveImage
              src={imgUrl}
              alt={`${parentPost.caption} - ${idx + 1}`}
              className="w-full h-full object-cover pointer-events-none select-none"
            />
            <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
          </div>
        ))}
      </div>
    );
  };

  return (
    <article className="w-full border-b border-neutral-200 bg-pure-white font-gt-standard select-none px-4 py-3.5 hover:bg-neutral-50/40 transition-colors overflow-x-hidden">
      {/* 1. PARENT POST SECTION WITH THREAD LINE */}
      <div className="flex gap-3 items-start min-w-0">
        {/* Left Column: Parent Avatar + Continuous Thread Line */}
        <div className="flex flex-col items-center shrink-0 self-stretch">
          <div
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(parentPost.seller.username || parentPost.seller.name);
            }}
            className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 cursor-pointer active:scale-95 transition-transform"
          >
            <img
              src={parentPost.seller.avatar}
              alt={parentPost.seller.name}
              className="w-full h-full object-cover"
            />
          </div>
          {/* Continuous Thread Connector Line */}
          <div className="w-[2px] flex-1 bg-neutral-200 my-1 rounded-full min-h-[28px]" />
        </div>

        {/* Right Column: Parent Content (Identical to Home Feed MarketPostCard) */}
        <div
          onClick={() => onPostClick?.(parentPost)}
          className="flex-1 min-w-0 space-y-1 overflow-visible pb-3 cursor-pointer"
        >
          {/* Header Row: Name + Verified + (Topic OR Class) + Timestamp + More Options (...) */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
              <span
                onClick={(e) => {
                  e.stopPropagation();
                  onUserClick?.(parentPost.seller.username || parentPost.seller.name);
                }}
                className="font-semibold text-[15.5px] text-slate-900 truncate hover:underline shrink-1 max-w-[45%] cursor-pointer"
              >
                {parentPost.seller.name}
              </span>
              {parentPost.seller.isVerified && (
                <ClickableVerifiedBadge sellerName={parentPost.seller.name} className="w-[17.5px] h-[17.5px] shrink-0" />
              )}

              {parentPost.topicTag ? (
                <div className="flex items-center gap-x-1 shrink-1 min-w-0 overflow-hidden ml-0.5 h-[21px] leading-snug">
                  {/* Subtle Grey Chevron Arrow Separator */}
                  <span className="h-[21px] leading-snug flex items-center">
                    <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />
                  </span>

                  {/* Render special blue icon if official topic */}
                  {parentPost.isOfficialTopic && (
                    parentPost.topicIcon === 'presentation' || parentPost.topicIcon === 'party-popper' ? (
                      <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                    ) : (
                      <ThreadsTopicIcon className="w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" />
                    )
                  )}

                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      onTopicClick?.(parentPost.topicTag!);
                    }}
                    className={`font-semibold text-base h-[21px] leading-snug transition-colors cursor-pointer truncate max-w-[135px] sm:max-w-[200px] flex items-center ${
                      parentPost.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:underline'
                    }`}
                  >
                    <span className="leading-snug">{parentPost.topicTag}</span>
                  </button>
                </div>
              ) : (
                <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 shrink">
                  {parentPost.seller.classGroup}
                </span>
              )}
            </div>

            <div className="flex items-center gap-1.5 shrink-0 ml-auto">
              <span className="text-[13.5px] sm:text-[14px] font-normal text-neutral-400 whitespace-nowrap">{parentPost.timestamp}</span>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  setIsParentMenuOpen(true);
                }}
                className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer active:scale-[0.96]"
                aria-label="Opsi postingan"
              >
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Caption Text: Indented under name */}
          <p className="text-[16px] text-slate-900 font-normal leading-snug break-words">
            <FormattedText text={parentPost.caption} />
          </p>

          {/* Multi-Image Carousel / Images */}
          {renderParentImages()}

          {/* Parent Action Bar (Identical layout and icons as Home Feed) */}
          <div className="flex items-center gap-2 -ml-1 pt-1 text-slate-700">
            {/* 1. Like Button */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleParentLike}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer select-none group active:bg-neutral-100 rounded-full transition-colors"
            >
              <motion.div
                animate={parentLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
                transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
              >
                <Heart
                  className={`w-[19px] h-[19px] stroke-[1.85] transition-colors duration-200 ${
                    parentLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
                  }`}
                />
              </motion.div>
              {parentLikesCount > 0 && (
                <motion.span
                  key={parentLikesCount}
                  initial={{ opacity: 0.6, y: -2 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.15 }}
                  className={`font-medium text-[13.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                    parentLiked ? 'text-rose-600 font-bold' : 'text-slate-700'
                  }`}
                >
                  {parentLikesCount}
                </motion.span>
              )}
            </motion.button>

            {/* 2. Comment Button */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={() => onPostClick?.(parentPost)}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer text-slate-700 group select-none active:bg-neutral-100 rounded-full"
            >
              <motion.div
                whileTap={{ scale: [1, 0.85, 1.2, 0.95, 1], y: [0, -2, 0] }}
                transition={{ duration: 0.25 }}
              >
                <SmoothCommentIcon className="w-[19px] h-[19px] stroke-[1.85] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
              </motion.div>
              {parentPost.commentsCount > 0 && (
                <span className="font-medium text-[13.5px] text-slate-700 tabular-nums tracking-tight">{parentPost.commentsCount}</span>
              )}
            </motion.button>

            {/* 3. Repost Button */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleParentRepost}
              className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer select-none group active:bg-neutral-100 rounded-full"
            >
              <motion.div
                animate={parentReposted ? { rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] } : { rotate: 0, scale: 1 }}
                transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
              >
                <Repeat2
                  className={`w-[19px] h-[19px] stroke-[1.85] transition-colors duration-200 ${
                    parentReposted ? 'text-emerald-500 stroke-emerald-500' : 'text-slate-700'
                  }`}
                />
              </motion.div>
              {parentRepostsCount > 0 && (
                <motion.span
                  key={parentRepostsCount}
                  initial={{ opacity: 0.6, y: -2 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.15 }}
                  className={`font-medium text-[13.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                    parentReposted ? 'text-emerald-600 font-bold' : 'text-slate-700'
                  }`}
                >
                  {parentRepostsCount}
                </motion.span>
              )}
            </motion.button>

            {/* 4. Send / Share Button */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={(e) => handleShare(e, `Utas dari ${parentPost.seller.name}`, parentPost.caption)}
              className="flex items-center justify-center p-2 min-h-[36px] min-w-[36px] cursor-pointer text-slate-700 group select-none active:bg-neutral-100 rounded-full"
              aria-label="Bagikan postingan"
            >
              <motion.div
                whileTap={{ x: [0, 4, -1, 0], y: [0, -4, 1, 0], scale: [1, 1.2, 1] }}
                transition={{ duration: 0.3 }}
              >
                <Send className="w-[19px] h-[19px] stroke-[1.85] text-slate-700 group-hover:text-slate-900 transition-colors duration-200" />
              </motion.div>
            </motion.button>

            {/* 5. Stock Indicator: Compact Inline Pill [ 📦 3 ] (Zero-Wrap Guaranteed) */}
            {parentPost.postType !== 'thread' && !!parentPost.price && parentPost.price > 0 && parentPost.stock !== undefined && parentPost.stock > 0 && (
              <div
                className="flex items-center gap-1 min-h-[26px] px-2 py-0.5 text-neutral-600 bg-neutral-100/90 border border-neutral-200/60 rounded-full text-[12px] select-none ml-auto shrink-0 whitespace-nowrap font-medium transition-colors"
                title={`Sisa stok: ${parentPost.stock} item`}
              >
                <Box className="w-3.5 h-3.5 stroke-[1.8] text-neutral-500 shrink-0" />
                <span className="font-semibold text-slate-800 tabular-nums tracking-tight whitespace-nowrap">{parentPost.stock}</span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* 2. USER REPLY POST SECTION */}
      <div className="flex gap-3 items-start min-w-0 pt-1">
        {/* Left Column: Reply Author Avatar */}
        <div className="shrink-0">
          <div
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(reply.user.username || reply.user.name);
            }}
            className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 cursor-pointer active:scale-95 transition-transform"
          >
            <img
              src={reply.user.avatar}
              alt={reply.user.name}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Right Column: Reply Content */}
        <div className="flex-1 min-w-0 space-y-1">
          {/* Header Row: Author + Verified + Timestamp + More */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            <div className="flex items-center gap-1.5 min-w-0">
              <span
                onClick={(e) => {
                  e.stopPropagation();
                  onUserClick?.(reply.user.username || reply.user.name);
                }}
                className="font-semibold text-[15.5px] text-slate-900 truncate hover:underline cursor-pointer"
              >
                {reply.user.name}
              </span>
              {reply.user.isVerified && (
                <ClickableVerifiedBadge sellerName={reply.user.name} className="w-[17.5px] h-[17.5px] shrink-0" />
              )}
            </div>

            <div className="flex items-center gap-1.5 shrink-0 ml-auto">
              <span className="text-[13.5px] sm:text-[14px] font-normal text-neutral-400 whitespace-nowrap">{reply.timestamp}</span>
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  setIsReplyMenuOpen(true);
                }}
                className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer active:scale-[0.96]"
                aria-label="Opsi balasan"
              >
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Reply Text */}
          <p className="text-[16px] text-slate-900 font-normal leading-snug break-words">
            <FormattedText text={reply.content} />
          </p>

          {/* Reply Action Bar */}
          <div className="flex items-center gap-1.5 -ml-1 pt-0.5 text-slate-700">
            {/* Like */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleReplyLike}
              className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[34px] min-w-[34px] cursor-pointer select-none group active:bg-neutral-100 rounded-full transition-colors"
            >
              <motion.div
                animate={replyLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
                transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
              >
                <Heart
                  className={`w-[17.5px] h-[17.5px] stroke-[1.8] transition-colors duration-200 ${
                    replyLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
                  }`}
                />
              </motion.div>
              {replyLikesCount > 0 && (
                <motion.span
                  key={replyLikesCount}
                  initial={{ opacity: 0.6, y: -2 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.15 }}
                  className={`font-medium text-[12.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                    replyLiked ? 'text-rose-600 font-bold' : 'text-slate-700'
                  }`}
                >
                  {replyLikesCount}
                </motion.span>
              )}
            </motion.button>

            {/* Comment */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={() => onPostClick?.(parentPost)}
              className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[34px] min-w-[34px] cursor-pointer text-slate-700 group select-none active:bg-neutral-100 rounded-full"
            >
              <motion.div
                whileTap={{ scale: [1, 0.85, 1.2, 0.95, 1], y: [0, -2, 0] }}
                transition={{ duration: 0.25 }}
              >
                <SmoothCommentIcon className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
              </motion.div>
            </motion.button>

            {/* Repost */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={handleReplyRepost}
              className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[34px] min-w-[34px] cursor-pointer select-none group active:bg-neutral-100 rounded-full"
            >
              <motion.div
                animate={replyReposted ? { rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] } : { rotate: 0, scale: 1 }}
                transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
              >
                <Repeat2
                  className={`w-[17.5px] h-[17.5px] stroke-[1.8] transition-colors duration-200 ${
                    replyReposted ? 'text-emerald-500 stroke-emerald-500' : 'text-slate-700'
                  }`}
                />
              </motion.div>
              {replyRepostsCount > 0 && (
                <motion.span
                  key={replyRepostsCount}
                  initial={{ opacity: 0.6, y: -2 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.15 }}
                  className={`font-medium text-[12.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                    replyReposted ? 'text-emerald-600 font-bold' : 'text-slate-700'
                  }`}
                >
                  {replyRepostsCount}
                </motion.span>
              )}
            </motion.button>

            {/* Share */}
            <motion.button
              type="button"
              whileTap={{ scale: 0.9 }}
              onClick={(e) => handleShare(e, `Balasan dari ${reply.user.name}`, reply.content)}
              className="flex items-center justify-center p-1.5 min-h-[34px] min-w-[34px] cursor-pointer text-slate-700 group select-none active:bg-neutral-100 rounded-full"
            >
              <motion.div
                whileTap={{ x: [0, 4, -1, 0], y: [0, -4, 1, 0], scale: [1, 1.2, 1] }}
                transition={{ duration: 0.3 }}
              >
                <Send className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-slate-900 transition-colors duration-200" />
              </motion.div>
            </motion.button>
          </div>
        </div>
      </div>

      {/* Media Lightbox Modal */}
      {isLightboxOpen && parentPost.images && parentPost.images.length > 0 && (
        <MediaLightboxModal
          isOpen={isLightboxOpen}
          onClose={() => setIsLightboxOpen(false)}
          images={parentPost.images}
          initialIndex={selectedImageIndex}
          caption={parentPost.caption}
          likesCount={parentLikesCount}
          repliesCount={parentPost.commentsCount}
          repostsCount={parentRepostsCount}
          isLiked={parentLiked}
          isReposted={parentReposted}
          onLike={() => {
            if (parentLiked) {
              setParentLiked(false);
              setParentLikesCount((prev) => Math.max(0, prev - 1));
            } else {
              setParentLiked(true);
              setParentLikesCount((prev) => prev + 1);
            }
          }}
          onComment={() => {
            setIsLightboxOpen(false);
          }}
          onRepost={() => {
            if (parentReposted) {
              setParentReposted(false);
              setParentRepostsCount((prev) => Math.max(0, prev - 1));
            } else {
              setParentReposted(true);
              setParentRepostsCount((prev) => prev + 1);
            }
          }}
          onShare={() => {
            if (navigator.share) {
              navigator.share({
                title: 'Snapan Market',
                text: parentPost.caption,
                url: window.location.href,
              }).catch(() => {});
            }
          }}
        />
      )}

      {/* Parent Post 3-Dot Options Modal */}
      <PostOptionsModal
        isOpen={isParentMenuOpen}
        onClose={() => setIsParentMenuOpen(false)}
        authorName={parentPost.seller.name}
        authorUsername={parentPost.seller.username}
        isSaved={false}
      />

      {/* Reply Post 3-Dot Options Modal */}
      <PostOptionsModal
        isOpen={isReplyMenuOpen}
        onClose={() => setIsReplyMenuOpen(false)}
        title="Opsi Balasan"
        authorName={reply.user.name}
        authorUsername={reply.user.username}
        isSaved={false}
      />
    </article>
  );
};
