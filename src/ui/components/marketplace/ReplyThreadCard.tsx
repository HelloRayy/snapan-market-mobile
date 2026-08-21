import React, { useState, useRef } from 'react';
import { Heart, MoreHorizontal, Repeat2, Send, ChevronRight, PartyPopper, Box } from 'lucide-react';
import { UserReplyThread, MarketPostItem } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';
import { MediaLightboxModal } from './MediaLightboxModal';

// Custom Threads 3-Dot Topic Icon
const ThreadsTopicIcon: React.FC<{ className?: string }> = ({ className = "w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" }) => (
  <svg className={className} viewBox="0 0 24 24">
    <circle cx="6" cy="8" r="3" />
    <circle cx="6" cy="16" r="3" />
    <circle cx="15" cy="12" r="3" />
  </svg>
);

// Custom Smooth Rounded Lucide-Family Comment Icon
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

  // Lightbox State
  const [isLightboxOpen, setIsLightboxOpen] = useState(false);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);

  // Drag to Scroll State for Multi-Image Carousel
  const scrollContainerRef = useRef<HTMLDivElement>(null);
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

  const handleParentLike = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (parentLiked) {
      setParentLiked(false);
      setParentLikesCount((prev) => Math.max(0, prev - 1));
    } else {
      setParentLiked(true);
      setParentLikesCount((prev) => prev + 1);
    }
  };

  const handleParentRepost = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (parentReposted) {
      setParentReposted(false);
      setParentRepostsCount((prev) => Math.max(0, prev - 1));
    } else {
      setParentReposted(true);
      setParentRepostsCount((prev) => prev + 1);
    }
  };

  const handleReplyLike = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (replyLiked) {
      setReplyLiked(false);
      setReplyLikesCount((prev) => Math.max(0, prev - 1));
    } else {
      setReplyLiked(true);
      setReplyLikesCount((prev) => prev + 1);
    }
  };

  const handleReplyRepost = (e: React.MouseEvent) => {
    e.stopPropagation();
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
          <picture className="block w-full h-full cursor-pointer">
            <img
              src={parentPost.images[0]}
              alt={parentPost.title || parentPost.caption}
              className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300 pointer-events-none select-none"
            />
          </picture>
          <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
        </div>
      );
    }

    return (
      <div
        ref={scrollContainerRef}
        onMouseDown={handleMouseDown}
        onMouseLeave={handleMouseLeaveOrUp}
        onMouseUp={handleMouseLeaveOrUp}
        onMouseMove={handleMouseMove}
        onClick={(e) => e.stopPropagation()}
        className="flex gap-2.5 overflow-x-auto no-scrollbar scrollbar-none mt-2.5 cursor-grab active:cursor-grabbing select-none touch-pan-x touch-pan-y -ml-[64px] sm:-ml-[68px] pl-[64px] sm:pl-[68px] -mr-4 pr-4 w-[calc(100%+80px)] sm:w-[calc(100%+84px)]"
      >
        {parentPost.images.map((imgUrl, idx) => (
          <div
            key={idx}
            onClick={(e) => {
              e.stopPropagation();
              setSelectedImageIndex(idx);
              setIsLightboxOpen(true);
            }}
            className="relative shrink-0 w-[82%] sm:w-[75%] rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[380px] aspect-[3/4] cursor-pointer"
          >
            <picture className="block w-full h-full cursor-pointer">
              <img
                src={imgUrl}
                alt={`${parentPost.caption} - ${idx + 1}`}
                className="w-full h-full object-cover pointer-events-none select-none"
              />
            </picture>
            <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
          </div>
        ))}
      </div>
    );
  };

  return (
    <article className="w-full border-b border-neutral-200 bg-pure-white font-gt-standard select-none px-4 py-3.5 hover:bg-neutral-50/40 transition-colors overflow-visible">
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
                <div className="flex items-center gap-1 shrink-1 min-w-0 overflow-hidden ml-0.5">
                  {/* Subtle Grey Chevron Arrow Separator */}
                  <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />

                  {/* Render special blue icon if official topic */}
                  {parentPost.isOfficialTopic && (
                    parentPost.topicIcon === 'presentation' || parentPost.topicIcon === 'party-popper' ? (
                      <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                    ) : (
                      <ThreadsTopicIcon />
                    )
                  )}

                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      onTopicClick?.(parentPost.topicTag!);
                    }}
                    className={`font-bold text-[14.5px] transition-colors cursor-pointer truncate max-w-[135px] sm:max-w-[200px] ${
                      parentPost.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:text-[#1d64ec] hover:underline'
                    }`}
                  >
                    {parentPost.topicTag}
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
                onClick={(e) => e.stopPropagation()}
                className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer"
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
          <div className="flex items-center gap-1 -ml-2 pt-1 text-slate-600">
            {/* 1. Like Button */}
            <button
              type="button"
              onClick={handleParentLike}
              className={`flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
                parentLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Heart className={`w-4.5 h-4.5 stroke-[2] ${parentLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
              <span className={`font-normal text-[13.5px] ${parentLiked ? 'text-rose-500 font-medium' : 'text-slate-700'}`}>{parentLikesCount}</span>
            </button>

            {/* 2. Comment Button */}
            <button
              type="button"
              onClick={() => onPostClick?.(parentPost)}
              className="flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
            >
              <SmoothCommentIcon className="w-4.5 h-4.5 stroke-[2]" />
              <span className="font-normal text-[13.5px] text-slate-700">{parentPost.commentsCount}</span>
            </button>

            {/* 3. Repost Button */}
            <button
              type="button"
              onClick={handleParentRepost}
              className={`flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
                parentReposted ? 'text-emerald-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Repeat2 className={`w-4.5 h-4.5 stroke-[2] ${parentReposted ? 'text-emerald-500' : ''}`} />
              <span className={`font-normal text-[13.5px] ${parentReposted ? 'text-emerald-500 font-medium' : 'text-slate-700'}`}>
                {parentRepostsCount}
              </span>
            </button>

            {/* 4. Send / Share Button */}
            <button
              type="button"
              onClick={(e) => handleShare(e, `Utas dari ${parentPost.seller.name}`, parentPost.caption)}
              className="flex items-center justify-center w-8 h-8 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
              aria-label="Bagikan postingan"
            >
              <Send className="w-4 h-4 stroke-[1.8] text-slate-600" />
            </button>

            {/* 5. Stock Indicator (if product) */}
            {parentPost.postType !== 'thread' && !!parentPost.price && parentPost.price > 0 && parentPost.stock !== undefined && parentPost.stock > 0 && (
              <div className="flex items-center gap-1.5 min-h-[36px] px-2 py-1 text-neutral-500 bg-neutral-100/80 rounded-lg text-[12.5px] select-none ml-auto" title={`Stok tersisa ${parentPost.stock}`}>
                <Box className="w-3.5 h-3.5 stroke-[2] text-neutral-500" />
                <span className="font-normal text-slate-600">Sisa stok: <strong className="font-semibold text-slate-900">{parentPost.stock}</strong></span>
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
                onClick={(e) => e.stopPropagation()}
                className="text-slate-500 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer"
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
          <div className="flex items-center gap-1 -ml-2 pt-0.5 text-slate-600">
            {/* Like */}
            <button
              type="button"
              onClick={handleReplyLike}
              className={`flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
                replyLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Heart className={`w-4.5 h-4.5 stroke-[2] ${replyLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
              <span className={`font-normal text-[13.5px] ${replyLiked ? 'text-rose-500 font-medium' : 'text-slate-700'}`}>{replyLikesCount}</span>
            </button>

            {/* Comment */}
            <button
              type="button"
              onClick={() => onPostClick?.(parentPost)}
              className="flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
            >
              <SmoothCommentIcon className="w-4.5 h-4.5 stroke-[2]" />
            </button>

            {/* Repost */}
            <button
              type="button"
              onClick={handleReplyRepost}
              className={`flex items-center gap-1.5 min-h-[36px] px-2 py-1 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer select-none ${
                replyReposted ? 'text-emerald-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Repeat2 className={`w-4.5 h-4.5 stroke-[2] ${replyReposted ? 'text-emerald-500' : ''}`} />
              {replyRepostsCount > 0 && (
                <span className={`font-normal text-[13.5px] ${replyReposted ? 'text-emerald-500 font-medium' : 'text-slate-700'}`}>
                  {replyRepostsCount}
                </span>
              )}
            </button>

            {/* Share */}
            <button
              type="button"
              onClick={(e) => handleShare(e, `Balasan dari ${reply.user.name}`, reply.content)}
              className="flex items-center justify-center w-8 h-8 rounded-full hover:bg-neutral-100/80 active:bg-neutral-200/80 active:scale-95 transition-all cursor-pointer text-slate-600 hover:text-slate-900 select-none"
            >
              <Send className="w-4 h-4 stroke-[1.8] text-slate-600" />
            </button>
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
        />
      )}
    </article>
  );
};
