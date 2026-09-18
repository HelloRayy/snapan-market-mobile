import React, { useState } from 'react';
import { BadgeCheck, MoreHorizontal, Crown } from 'lucide-react';
import { PostComment } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { formatSmartTimestamp } from '@/utils/formatters';
import { PostSubmenuDropdown } from '@/ui/components/marketplace/PostSubmenuDropdown';
import { CommentActionBar } from './CommentActionBar';
import { CommentImages } from './CommentImages';

interface CommentRowProps {
  comment: PostComment;
  isLiked: boolean;
  likesCount: number;
  onLikeToggle: () => void;
  onReplyClick?: (username: string, commentId?: string) => void;
  onOpenCommentDetail?: (comment: PostComment) => void;
  onImageClick?: (images: string[], index: number) => void;
  hasThreadlineDown?: boolean;
  hasThreadlineUp?: boolean;
  isFirstChildBranch?: boolean;
}

export const CommentRow: React.FC<CommentRowProps> = ({
  comment,
  isLiked,
  likesCount,
  onLikeToggle,
  onReplyClick,
  onOpenCommentDetail,
  onImageClick,
  hasThreadlineDown = false,
  hasThreadlineUp = false,
  isFirstChildBranch = false,
}) => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const username = comment.user.username || comment.user.name;

  return (
    <div
      onClick={() => onOpenCommentDetail?.(comment)}
      className={`flex items-start gap-3 relative w-full min-w-0 transition-colors duration-300 ${
        onOpenCommentDetail ? 'cursor-pointer active:opacity-75 transition-opacity' : ''
      }`}
    >
      {/* Curved L-Branch from parent line (for first child reply) */}
      {isFirstChildBranch && (
        <div className="absolute -left-[11px] -top-3.5 h-[32px] w-[12px] border-l-2 border-b-2 border-[#d1d5db] rounded-bl-xl pointer-events-none z-0" />
      )}

      {/* Left Column: Avatar + Continuous Branch Line */}
      <div className="flex flex-col items-center shrink-0 self-stretch z-10">
        {/* Straight line coming from top for subsequent replies */}
        {hasThreadlineUp && (
          <div className="w-[2px] h-3.5 bg-[#d1d5db] -mt-3.5 shrink-0" />
        )}

        <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 bg-white">
          <img
            src={comment.user.avatar}
            alt={comment.user.name}
            className="w-full h-full object-cover"
            loading="lazy"
          />
        </div>

        {/* Vertical branch line extending down to connect child replies */}
        {hasThreadlineDown && (
          <div className="w-[2px] flex-1 bg-[#d1d5db] mt-1 -mb-3.5 rounded-full" />
        )}
      </div>

      {/* Right Column: Header + Content + Images + Action Bar */}
      <div className="flex-1 min-w-0">
        {/* Header Row: Username + Badges + Timestamp + More Options */}
        <div className="flex items-center justify-between gap-2 h-[21px] leading-snug">
          <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden h-[21px] leading-snug">
            <span className="font-semibold text-[14px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
              {username}
            </span>

            {comment.user.isVerified && (
              <BadgeCheck
                className="w-[15px] h-[15px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white"
                aria-label="Verified User"
              />
            )}

            {comment.user.isAuthor && (
              <span className="relative inline-flex items-center gap-1 px-1.5 py-0.5 rounded-[5px] text-[11.5px] font-medium text-white bg-[#18181b] border border-black/40 shadow-2xs overflow-hidden shrink-0 select-none">
                <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
                <Crown className="w-2.5 h-2.5 text-white fill-white relative z-10 shrink-0" />
                <span className="relative z-10 leading-none">Pembuat Utas</span>
              </span>
            )}

            <span
              className="text-[12px] sm:text-[12.5px] font-normal text-slate-500 truncate min-w-0 shrink tabular-nums cursor-default select-none"
              title={formatSmartTimestamp(comment.timestamp).full}
            >
              {formatSmartTimestamp(comment.timestamp).display}
            </span>
          </div>

          {/* Option (...) Icon & Dropdown */}
          <div className="relative">
            <button
              type="button"
              id={`comment-options-btn-${comment.id}`}
              data-submenu-trigger="true"
              aria-haspopup="menu"
              aria-expanded={isMenuOpen}
              aria-controls={`comment-options-menu-${comment.id}`}
              onClick={(e) => {
                e.stopPropagation();
                setIsMenuOpen((prev) => !prev);
              }}
              className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer active:scale-[0.96]"
              aria-label="Opsi komentar"
            >
              <MoreHorizontal className="w-4 h-4" />
            </button>
            <PostSubmenuDropdown
              isOpen={isMenuOpen}
              onClose={() => setIsMenuOpen(false)}
              title="Opsi Komentar"
              authorName={comment.user.name}
              authorUsername={comment.user.username}
              isSaved={false}
              align="right"
              menuId={`comment-options-menu-${comment.id}`}
              triggerId={`comment-options-btn-${comment.id}`}
            />
          </div>
        </div>

        {/* Comment Content */}
        <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] mt-0.5">
          <FormattedText text={comment.content} />
          {comment.threadPart && comment.totalParts && (
            <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11px] tabular-nums select-none ml-1.5 align-middle">
              {comment.threadPart}/{comment.totalParts}
            </span>
          )}
        </div>

        {/* Attached Images */}
        <CommentImages images={comment.images} onImageClick={onImageClick} />

        {/* Action Bar */}
        <CommentActionBar
          isLiked={isLiked}
          likesCount={likesCount}
          onLike={onLikeToggle}
          onReply={() => onReplyClick?.(username, comment.id)}
        />
      </div>
    </div>
  );
};
