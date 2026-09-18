import React, { useState, useEffect } from 'react';
import { BadgeCheck } from 'lucide-react';
import { PostComment } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { triggerHaptic } from '@/utils/haptics';
import { CommentRow } from './comment';

interface PostCommentItemProps {
  comment: PostComment;
  currentUserAvatar?: string;
  onReplyClick?: (username: string, commentId?: string) => void;
  onOpenCommentDetail?: (comment: PostComment) => void;
  onImageClick?: (images: string[], index: number) => void;
  isNested?: boolean;
  draftReply?: {
    targetCommentId: string;
    text: string;
    userAvatar?: string;
    username?: string;
    isVerified?: boolean;
    isAuthor?: boolean;
  } | null;
}

export const PostCommentItem: React.FC<PostCommentItemProps> = ({
  comment,
  onReplyClick,
  onOpenCommentDetail,
  onImageClick,
  isNested = false,
  draftReply,
}) => {
  const [isLiked, setIsLiked] = useState(comment.isLiked || false);
  const [likesCount, setLikesCount] = useState(comment.likesCount || 0);
  const [repliesState, setRepliesState] = useState<PostComment[]>(comment.replies || []);

  useEffect(() => {
    setRepliesState(comment.replies || []);
  }, [comment.replies]);

  const handleLikeToggle = () => {
    setIsLiked((prev) => {
      const next = !prev;
      triggerHaptic(next ? 'medium' : 'light');
      setLikesCount((c) => (next ? c + 1 : Math.max(0, c - 1)));
      return next;
    });
  };

  const handleNestedReplyLike = (replyId: string) => {
    setRepliesState((prev) =>
      prev.map((r) => {
        if (r.id === replyId) {
          const nextLiked = !r.isLiked;
          triggerHaptic(nextLiked ? 'medium' : 'light');
          return {
            ...r,
            isLiked: nextLiked,
            likesCount: nextLiked ? r.likesCount + 1 : Math.max(0, r.likesCount - 1),
          };
        }
        return r;
      })
    );
  };

  const hasDraft = Boolean(
    draftReply &&
      (draftReply.targetCommentId === comment.id ||
        repliesState.some((r) => r.id === draftReply.targetCommentId))
  );
  const hasReplies = repliesState.length > 0;
  const isThreadConnected = hasReplies || hasDraft;

  return (
    <div
      id={`comment-${comment.id}`}
      className={`w-full transition-colors duration-300 ${
        isNested ? 'pt-3.5 pl-0' : 'px-3.5 py-3.5 border-b border-neutral-200'
      }`}
    >
      {/* 1. Parent Comment Row */}
      <CommentRow
        comment={comment}
        isLiked={isLiked}
        likesCount={likesCount}
        onLikeToggle={handleLikeToggle}
        onReplyClick={onReplyClick}
        onOpenCommentDetail={onOpenCommentDetail}
        onImageClick={onImageClick}
        hasThreadlineDown={isThreadConnected}
      />

      {/* 2. Connected Branch Tree (Replies & Live Draft) */}
      {isThreadConnected && (
        <div className="space-y-3 mt-3">
          {/* Child Replies List */}
          {(onOpenCommentDetail && repliesState.length > 1
            ? repliesState.slice(0, 1)
            : repliesState
          ).map((reply, idx) => {
            const isFirstChild = idx === 0;
            const isLastChild =
              !hasDraft &&
              (onOpenCommentDetail && repliesState.length > 1
                ? true
                : idx === repliesState.length - 1);

            return (
              <div key={reply.id || idx} className="ml-7">
                <CommentRow
                  comment={reply}
                  isLiked={reply.isLiked || false}
                  likesCount={reply.likesCount}
                  onLikeToggle={() => handleNestedReplyLike(reply.id)}
                  onReplyClick={onReplyClick}
                  onOpenCommentDetail={onOpenCommentDetail}
                  onImageClick={onImageClick}
                  isFirstChildBranch={isFirstChild}
                  hasThreadlineUp={!isFirstChild}
                  hasThreadlineDown={!isLastChild || hasDraft || (Boolean(onOpenCommentDetail && repliesState.length > 1))}
                />
              </div>
            );
          })}

          {/* Live Synchronized Draft Reply Bubble */}
          {hasDraft && draftReply && (
            <div
              id={`comment-draft-${comment.id}`}
              className="flex items-start gap-3 ml-7 relative min-w-0 animate-in fade-in slide-in-from-top-1 duration-150"
            >
              {repliesState.length === 0 && (
                <div className="absolute -left-[11px] -top-3.5 h-[32px] w-[12px] border-l-2 border-b-2 border-[#d1d5db] rounded-bl-xl pointer-events-none z-0" />
              )}

              <div className="flex flex-col items-center shrink-0 self-stretch z-10">
                {repliesState.length > 0 && (
                  <div className="w-[2px] h-3.5 bg-[#d1d5db] -mt-3.5 shrink-0" />
                )}
                <div className="w-9 h-9 rounded-full overflow-hidden border border-[#1d64ec]/50 ring-2 ring-[#1d64ec]/20 shadow-2xs shrink-0 bg-white">
                  <img
                    src={draftReply.userAvatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80'}
                    alt={draftReply.username || 'Saya'}
                    className="w-full h-full object-cover"
                  />
                </div>
              </div>

              <div className="flex-1 min-w-0 pb-1">
                <div className="flex items-center gap-1.5 min-w-0 h-[21px] leading-snug">
                  <span className="font-semibold text-[14px] text-slate-900 truncate">
                    {draftReply.username || 'radityarayhannnn'}
                  </span>

                  {draftReply.isVerified && (
                    <BadgeCheck className="w-[15px] h-[15px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                  )}

                  <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full text-[11.5px] font-semibold text-[#1d64ec] bg-blue-50 border border-blue-200/60 animate-pulse shrink-0 select-none">
                    <span>Mengetik...</span>
                  </span>
                </div>

                <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] mt-1 bg-neutral-50/80 rounded-xl px-2.5 py-1.5 border border-neutral-200/60">
                  {draftReply.text ? (
                    <span>
                      <FormattedText text={draftReply.text} />
                      <span className="inline-block w-0.5 h-4 bg-[#1d64ec] animate-pulse ml-0.5 align-middle" />
                    </span>
                  ) : (
                    <span className="text-neutral-400 italic flex items-center gap-1">
                      <span>Tulis balasan...</span>
                      <span className="inline-block w-0.5 h-4 bg-[#1d64ec] animate-pulse align-middle" />
                    </span>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Threads-style "Show replies" Stacked Avatar Button */}
          {onOpenCommentDetail && repliesState.length > 1 && (
            <div className="flex items-center gap-3 ml-7 relative pt-0.5">
              <div className="flex flex-col items-center shrink-0 z-10">
                <div className="w-[2px] h-3 bg-[#d1d5db] -mt-3.5 shrink-0" />
                <div className="flex -space-x-1.5 shrink-0 py-0.5">
                  {repliesState.slice(1, 4).map((r, i) => (
                    <img
                      key={i}
                      src={r.user.avatar}
                      alt={r.user.name}
                      className="w-4.5 h-4.5 rounded-full object-cover border border-white shadow-2xs bg-white"
                    />
                  ))}
                </div>
              </div>

              <button
                type="button"
                onClick={() => onOpenCommentDetail?.(comment)}
                className="text-[13px] font-normal text-neutral-400 hover:text-slate-900 transition-colors py-0.5 cursor-pointer text-left flex items-center gap-1.5 active:scale-95"
              >
                <span>Lihat {repliesState.length - 1} balasan lainnya</span>
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
