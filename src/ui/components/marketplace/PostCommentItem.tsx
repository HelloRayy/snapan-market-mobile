import React, { useState } from 'react';
import { Heart, Repeat, Send, BadgeCheck, MoreHorizontal } from 'lucide-react';
import { PostComment } from '@/types/marketFeed';

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

interface PostCommentItemProps {
  comment: PostComment;
  onReplyClick?: (username: string) => void;
  isNested?: boolean;
}

export const PostCommentItem: React.FC<PostCommentItemProps> = ({
  comment,
  onReplyClick,
  isNested = false,
}) => {
  const [isLiked, setIsLiked] = useState(comment.isLiked || false);
  const [likesCount, setLikesCount] = useState(comment.likesCount);

  const handleLikeToggle = () => {
    if (isLiked) {
      setIsLiked(false);
      setLikesCount((prev) => prev - 1);
    } else {
      setIsLiked(true);
      setLikesCount((prev) => prev + 1);
    }
  };

  const hasReplies = comment.replies && comment.replies.length > 0;

  // Filter to display ONLY 1 top reply (highest likes count or author reply)
  const topReply = hasReplies
    ? [...comment.replies!].sort(
        (a, b) => (b.user.isAuthor ? 1 : 0) - (a.user.isAuthor ? 1 : 0) || b.likesCount - a.likesCount
      )[0]
    : null;

  const renderActionBar = (
    liked: boolean,
    count: number,
    onLike?: () => void,
    onReply?: () => void
  ) => (
    <div className="flex items-center gap-4 text-slate-500 pt-2 text-[13px]">
      {/* Like Button */}
      <button
        type="button"
        onClick={onLike}
        className={`flex items-center gap-1 hover:opacity-80 active:scale-90 transition-all cursor-pointer ${
          liked ? 'text-rose-500' : 'text-slate-500 hover:text-slate-900'
        }`}
      >
        <Heart className={`w-4 h-4 stroke-[1.75] ${liked ? 'fill-rose-500 text-rose-500' : ''}`} />
        {count > 0 && <span className="font-normal text-slate-600">{count}</span>}
      </button>

      {/* Reply Button */}
      <button
        type="button"
        onClick={onReply}
        className="flex items-center gap-1 hover:text-slate-900 active:scale-90 transition-all cursor-pointer text-slate-500"
      >
        <SmoothCommentIcon className="w-4 h-4 stroke-[1.75]" />
      </button>

      {/* Repost Button */}
      <button
        type="button"
        className="hover:text-slate-900 active:scale-90 transition-all cursor-pointer text-slate-500"
      >
        <Repeat className="w-4 h-4 stroke-[1.75]" />
      </button>

      {/* Share Button */}
      <button
        type="button"
        className="hover:text-slate-900 active:scale-90 transition-all cursor-pointer text-slate-500"
      >
        <Send className="w-4 h-4 stroke-[1.75]" />
      </button>
    </div>
  );

  return (
    <div className={`w-full ${isNested ? 'pt-3.5 pl-0' : 'py-3.5 border-b border-neutral-200'}`}>
      {!topReply ? (
        /* SINGLE COMMENT (NO REPLIES): Full-width layout */
        <div className="space-y-2">
          {/* Header Row: Avatar + Username + Verified + Timestamp + Option (...) Icon */}
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2.5 min-w-0 flex-1 overflow-hidden">
              {/* Avatar (w-9 h-9) */}
              <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0">
                <img
                  src={comment.user.avatar}
                  alt={comment.user.name}
                  className="w-full h-full object-cover"
                />
              </div>

              {/* Username + Verified + Timestamp */}
              <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                <span className="font-semibold text-[15px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
                  {comment.user.username || comment.user.name}
                </span>

                {comment.user.isVerified && (
                  <BadgeCheck className="w-[17px] h-[17px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                )}

                {comment.user.isAuthor && (
                  <span className="px-2 py-0.5 rounded-md bg-neutral-100 dark:bg-neutral-800 text-[11px] font-medium text-slate-600 dark:text-neutral-300 shrink-0">
                    Pembuat
                  </span>
                )}

                <span className="text-[14px] font-normal text-neutral-400 truncate min-w-0 shrink">
                  {comment.timestamp}
                </span>
              </div>
            </div>

            {/* Option (...) Icon */}
            <button
              type="button"
              className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
              aria-label="Opsi komentar"
            >
              <MoreHorizontal className="w-4 h-4" />
            </button>
          </div>

          {/* Comment Content (Full Width Aligned with Avatar) */}
          <p className="text-[15px] text-slate-900 font-normal leading-snug break-words">
            {comment.content}
          </p>

          {/* Action Bar */}
          {renderActionBar(
            isLiked,
            likesCount,
            handleLikeToggle,
            () => onReplyClick?.(comment.user.username || comment.user.name)
          )}
        </div>
      ) : (
        /* THREAD COMMENT WITH TOP REPLY: Indented child reply + L-shaped curved connecting line (└─) */
        <div className="relative space-y-3">
          {/* 1. Continuous Vertical Line: Starts touching bottom of Person A avatar (top-[32px]) down to Person B row */}
          <div className="absolute left-[17px] top-[32px] bottom-[28px] w-[2px] bg-[#e5e7eb] pointer-events-none z-0" />

          {/* Parent Comment Row */}
          <div className="flex items-start gap-3">
            {/* Left Parent Avatar (36x36px) */}
            <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 z-10 bg-white">
              <img
                src={comment.user.avatar}
                alt={comment.user.name}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Right Parent Content */}
            <div className="flex-1 min-w-0 space-y-1">
              <div className="flex items-center justify-between gap-2 min-w-0">
                <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                  <span className="font-semibold text-[15px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
                    {comment.user.username || comment.user.name}
                  </span>

                  {comment.user.isVerified && (
                    <BadgeCheck className="w-[17px] h-[17px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                  )}

                  {comment.user.isAuthor && (
                    <span className="px-2 py-0.5 rounded-md bg-neutral-100 dark:bg-neutral-800 text-[11px] font-medium text-slate-600 dark:text-neutral-300 shrink-0">
                      Pembuat
                    </span>
                  )}

                  <span className="text-[14px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {comment.timestamp}
                  </span>
                </div>

                <button
                  type="button"
                  className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                  aria-label="Opsi komentar"
                >
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>

              <p className="text-[15px] text-slate-900 font-normal leading-snug break-words pt-0.5">
                {comment.content}
              </p>

              {renderActionBar(
                isLiked,
                likesCount,
                handleLikeToggle,
                () => onReplyClick?.(comment.user.username || comment.user.name)
              )}
            </div>
          </div>

          {/* Child Reply Row (Indented right with ml-7) */}
          <div className="flex items-start gap-3 ml-7 relative">
            {/* 2. L-Shaped Elbow Curve: Connects vertical line seamlessly into left center of Person B avatar (18px down) */}
            <div className="absolute -left-[11px] top-0 h-[18px] w-[12px] border-l-2 border-b-2 border-[#e5e7eb] rounded-bl-xl pointer-events-none z-0" />

            {/* Left Child Avatar (36x36px) */}
            <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 z-10 bg-white">
              <img
                src={topReply.user.avatar}
                alt={topReply.user.name}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Right Child Content */}
            <div className="flex-1 min-w-0 space-y-1">
              <div className="flex items-center justify-between gap-2 min-w-0">
                <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                  <span className="font-semibold text-[15px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
                    {topReply.user.username || topReply.user.name}
                  </span>

                  {topReply.user.isVerified && (
                    <BadgeCheck className="w-[17px] h-[17px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                  )}

                  {topReply.user.isAuthor && (
                    <span className="px-2 py-0.5 rounded-md bg-neutral-100 dark:bg-neutral-800 text-[11px] font-medium text-slate-600 dark:text-neutral-300 shrink-0">
                      Pembuat
                    </span>
                  )}

                  <span className="text-[14px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {topReply.timestamp}
                  </span>
                </div>

                <button
                  type="button"
                  className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                  aria-label="Opsi komentar"
                >
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>

              <p className="text-[15px] text-slate-900 font-normal leading-snug break-words pt-0.5">
                {topReply.content}
              </p>

              {renderActionBar(
                topReply.isLiked || false,
                topReply.likesCount,
                undefined,
                () => onReplyClick?.(topReply.user.username || topReply.user.name)
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
