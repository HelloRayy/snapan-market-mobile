import React, { useState } from 'react';
import { Heart, MoreHorizontal, Repeat2, Send } from 'lucide-react';
import { UserReplyThread, MarketPostItem } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';
import { MediaLightboxModal } from './MediaLightboxModal';

// Custom Rounded Lucide-Family Comment Icon
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
  onUserClick?: (username: string) => void;
}

export const ReplyThreadCard: React.FC<ReplyThreadCardProps> = ({
  thread,
  onPostClick,
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
  const [lightboxImage, setLightboxImage] = useState<string | null>(null);

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

  const handleShare = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (navigator.share) {
      navigator.share({
        title: `Utas dari ${parentPost.seller.name}`,
        text: reply.content,
        url: window.location.href,
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(window.location.href);
      alert('Tautan postingan berhasil disalin!');
    }
  };

  return (
    <article className="w-full border-b border-neutral-200 bg-white font-gt-standard select-none px-4 py-3.5 hover:bg-neutral-50/40 transition-colors">
      {/* 1. PARENT POST SECTION WITH THREAD LINE */}
      <div className="flex gap-3 min-w-0">
        {/* Left Column: Parent Avatar + Continuous Thread Line */}
        <div className="flex flex-col items-center shrink-0">
          <div
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(parentPost.seller.username || parentPost.seller.name);
            }}
            className="w-9 h-9 sm:w-10 sm:h-10 rounded-full overflow-hidden border border-neutral-200/80 bg-neutral-100 shadow-2xs cursor-pointer hover:opacity-90 transition-opacity"
          >
            <img
              src={parentPost.seller.avatar}
              alt={parentPost.seller.name}
              className="w-full h-full object-cover"
            />
          </div>
          {/* Thread Connector Line */}
          <div className="w-[2px] flex-1 bg-neutral-200 my-1 rounded-full min-h-[28px]" />
        </div>

        {/* Right Column: Parent Content */}
        <div
          onClick={() => onPostClick?.(parentPost)}
          className="flex-1 min-w-0 pb-3 cursor-pointer"
        >
          {/* Header Row: Author + Verified + Timestamp + More */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            <div className="flex items-center gap-1.5 min-w-0">
              <span className="font-semibold text-[14.5px] text-slate-900 truncate">
                {parentPost.seller.name}
              </span>
              {parentPost.seller.isVerified && (
                <ClickableVerifiedBadge sellerName={parentPost.seller.name} className="w-4 h-4 shrink-0" />
              )}
              <span className="text-neutral-400 text-[13px] shrink-0 font-normal">
                · {parentPost.timestamp}
              </span>
            </div>

            <button
              type="button"
              onClick={(e) => e.stopPropagation()}
              className="w-7 h-7 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
              aria-label="Opsi lainnya"
            >
              <MoreHorizontal className="w-4 h-4" />
            </button>
          </div>

          {/* Caption Text */}
          <p className="text-[14.5px] text-slate-900 leading-relaxed font-normal mt-1 whitespace-pre-line">
            <FormattedText text={parentPost.caption} />
          </p>

          {/* Media Images (if present) */}
          {parentPost.images && parentPost.images.length > 0 && (
            <div className="mt-2.5 rounded-2xl border border-neutral-200/80 overflow-hidden bg-neutral-100 max-h-[340px]">
              <img
                src={parentPost.images[0]}
                alt="Media Utas"
                onClick={(e) => {
                  e.stopPropagation();
                  setLightboxImage(parentPost.images[0]);
                }}
                className="w-full h-full max-h-[340px] object-cover hover:scale-[1.01] transition-transform duration-200 cursor-pointer"
              />
            </div>
          )}

          {/* Parent Action Bar */}
          <div className="flex items-center gap-4 mt-2.5 -ml-1 text-slate-600 text-[13px]">
            {/* Like */}
            <button
              type="button"
              onClick={handleParentLike}
              className={`flex items-center gap-1.5 py-1 px-1.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer ${
                parentLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Heart className={`w-4 h-4 stroke-[2] ${parentLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
              <span>{parentLikesCount}</span>
            </button>

            {/* Comment */}
            <button
              type="button"
              onClick={() => onPostClick?.(parentPost)}
              className="flex items-center gap-1.5 py-1 px-1.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer text-slate-600 hover:text-slate-900"
            >
              <SmoothCommentIcon className="w-4 h-4 stroke-[2]" />
              <span>{parentPost.commentsCount}</span>
            </button>

            {/* Repost */}
            <button
              type="button"
              onClick={handleParentRepost}
              className={`flex items-center gap-1.5 py-1 px-1.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer ${
                parentReposted ? 'text-emerald-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Repeat2 className={`w-4 h-4 stroke-[2] ${parentReposted ? 'text-emerald-500' : ''}`} />
              <span>{parentRepostsCount}</span>
            </button>

            {/* Share */}
            <button
              type="button"
              onClick={handleShare}
              className="flex items-center justify-center w-7 h-7 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer text-slate-600 hover:text-slate-900"
            >
              <Send className="w-3.5 h-3.5 stroke-[1.8]" />
            </button>
          </div>
        </div>
      </div>

      {/* 2. USER REPLY POST SECTION */}
      <div className="flex gap-3 min-w-0 pt-0.5">
        {/* Left Column: Reply Author Avatar */}
        <div className="shrink-0">
          <div
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(reply.user.username || reply.user.name);
            }}
            className="w-9 h-9 sm:w-10 sm:h-10 rounded-full overflow-hidden border border-neutral-200/80 bg-neutral-100 shadow-2xs cursor-pointer hover:opacity-90 transition-opacity"
          >
            <img
              src={reply.user.avatar}
              alt={reply.user.name}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Right Column: Reply Content */}
        <div className="flex-1 min-w-0">
          {/* Header Row: Author + Timestamp + More */}
          <div className="flex items-center justify-between gap-2 min-w-0">
            <div className="flex items-center gap-1.5 min-w-0">
              <span className="font-semibold text-[14.5px] text-slate-900 truncate">
                {reply.user.name}
              </span>
              {reply.user.isVerified && (
                <ClickableVerifiedBadge sellerName={reply.user.name} className="w-4 h-4 shrink-0" />
              )}
              <span className="text-neutral-400 text-[13px] shrink-0 font-normal">
                · {reply.timestamp}
              </span>
            </div>

            <button
              type="button"
              onClick={(e) => e.stopPropagation()}
              className="w-7 h-7 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-400 hover:text-slate-700 transition-colors cursor-pointer"
              aria-label="Opsi balasan lainnya"
            >
              <MoreHorizontal className="w-4 h-4" />
            </button>
          </div>

          {/* Reply Text */}
          <p className="text-[14.5px] text-slate-900 leading-relaxed font-normal mt-1 whitespace-pre-line">
            <FormattedText text={reply.content} />
          </p>

          {/* Reply Action Bar */}
          <div className="flex items-center gap-4 mt-2 -ml-1 text-slate-600 text-[13px]">
            {/* Like */}
            <button
              type="button"
              onClick={handleReplyLike}
              className={`flex items-center gap-1.5 py-1 px-1.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer ${
                replyLiked ? 'text-rose-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Heart className={`w-4 h-4 stroke-[2] ${replyLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
              <span>{replyLikesCount}</span>
            </button>

            {/* Comment */}
            <button
              type="button"
              onClick={() => onPostClick?.(parentPost)}
              className="flex items-center gap-1.5 py-1 px-1.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer text-slate-600 hover:text-slate-900"
            >
              <SmoothCommentIcon className="w-4 h-4 stroke-[2]" />
            </button>

            {/* Repost */}
            <button
              type="button"
              onClick={handleReplyRepost}
              className={`flex items-center gap-1.5 py-1 px-1.5 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer ${
                replyReposted ? 'text-emerald-500' : 'text-slate-600 hover:text-slate-900'
              }`}
            >
              <Repeat2 className={`w-4 h-4 stroke-[2] ${replyReposted ? 'text-emerald-500' : ''}`} />
              {replyRepostsCount > 0 && <span>{replyRepostsCount}</span>}
            </button>

            {/* Share */}
            <button
              type="button"
              onClick={handleShare}
              className="flex items-center justify-center w-7 h-7 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer text-slate-600 hover:text-slate-900"
            >
              <Send className="w-3.5 h-3.5 stroke-[1.8]" />
            </button>
          </div>
        </div>
      </div>

      {/* Media Lightbox */}
      {lightboxImage && (
        <MediaLightboxModal
          isOpen={!!lightboxImage}
          onClose={() => setLightboxImage(null)}
          images={[lightboxImage]}
          initialIndex={0}
        />
      )}
    </article>
  );
};
