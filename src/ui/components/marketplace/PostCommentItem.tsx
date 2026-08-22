import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Heart, Repeat, Send, BadgeCheck, MoreHorizontal, Crown } from 'lucide-react';
import { PostComment } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { formatSmartTimestamp } from '@/utils/formatters';

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
  currentUserAvatar?: string;
  activeReplyingCommentId?: string | null;
  onReplyClick?: (username: string, commentId?: string) => void;
  onCancelReply?: () => void;
  onSubmitReply?: (commentId: string, text: string) => void;
  onOpenCommentDetail?: (comment: PostComment) => void;
  isNested?: boolean;
}

export const PostCommentItem: React.FC<PostCommentItemProps> = ({
  comment,
  currentUserAvatar,
  activeReplyingCommentId,
  onReplyClick,
  onCancelReply,
  onSubmitReply,
  onOpenCommentDetail,
  isNested = false,
}) => {
  const [isLiked, setIsLiked] = useState(comment.isLiked || false);
  const [likesCount, setLikesCount] = useState(comment.likesCount);
  const [repliesState, setRepliesState] = useState(comment.replies || []);
  const [replyDraftText, setReplyDraftText] = useState('');
  const inputRef = React.useRef<HTMLInputElement>(null);

  const isReplying = activeReplyingCommentId === comment.id;

  React.useEffect(() => {
    setRepliesState(comment.replies || []);
  }, [comment.replies]);

  React.useEffect(() => {
    if (isReplying) {
      setTimeout(() => {
        inputRef.current?.focus();
      }, 100);
    } else {
      setReplyDraftText('');
    }
  }, [isReplying]);

  const handleLikeToggle = () => {
    if (isLiked) {
      setIsLiked(false);
      setLikesCount((prev) => prev - 1);
    } else {
      setIsLiked(true);
      setLikesCount((prev) => prev + 1);
    }
  };

  const handleNestedReplyLike = (replyId: string) => {
    setRepliesState((prev) =>
      prev.map((r) => {
        if (r.id === replyId) {
          const liked = !r.isLiked;
          return {
            ...r,
            isLiked: liked,
            likesCount: liked ? r.likesCount + 1 : Math.max(0, r.likesCount - 1),
          };
        }
        return r;
      })
    );
  };

  const handleInlineSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!replyDraftText.trim()) return;
    onSubmitReply?.(comment.id, replyDraftText.trim());
    setReplyDraftText('');
  };

  const hasReplies = repliesState.length > 0;
  const isThreadConnected = hasReplies || isReplying;

  const renderActionBar = (
    liked: boolean,
    count: number,
    onLike?: () => void,
    onReply?: () => void
  ) => (
    <motion.div
      initial={{ opacity: 0, y: 6 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.2, ease: "easeOut" }}
      onClick={(e) => e.stopPropagation()}
      className="flex items-center text-slate-600 font-normal pt-1.5 -ml-2 text-[13px] select-none"
    >
      {/* 1. Suka (Like) Slot */}
      <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
        <div className="flex items-stretch font-normal cursor-pointer transition-all">
          <motion.button
            type="button"
            whileTap={{ scale: 0.88 }}
            whileHover={{ scale: 1.04 }}
            transition={{ type: "spring", stiffness: 400, damping: 17 }}
            onClick={(e) => {
              e.stopPropagation();
              onLike?.();
            }}
            className={`flex items-center justify-center gap-1 px-2.5 py-1 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 transition-all cursor-pointer select-none ${
              liked ? 'text-rose-500' : 'text-slate-500 hover:text-slate-900'
            }`}
          >
            <motion.div
              animate={liked ? { scale: [1, 1.35, 0.95, 1], rotate: [0, -12, 12, 0] } : { scale: 1, rotate: 0 }}
              transition={{ duration: 0.35, ease: "easeOut" }}
            >
              <Heart className={`w-4 h-4 stroke-[1.75] ${liked ? 'fill-rose-500 text-rose-500' : ''}`} />
            </motion.div>
            {count > 0 && <span className="font-normal text-slate-600 tabular-nums">{count}</span>}
          </motion.button>
        </div>
      </div>

      {/* 2. Balas (Comment) Slot */}
      <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
        <div className="flex items-stretch font-normal cursor-pointer transition-all">
          <motion.button
            type="button"
            whileTap={{ scale: 0.88 }}
            whileHover={{ scale: 1.04 }}
            transition={{ type: "spring", stiffness: 400, damping: 17 }}
            onClick={(e) => {
              e.stopPropagation();
              onReply?.();
            }}
            className="flex items-center justify-center px-2.5 py-1 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 hover:text-slate-900 transition-all cursor-pointer text-slate-500 select-none"
          >
            <SmoothCommentIcon className="w-4 h-4 stroke-[1.75]" />
          </motion.button>
        </div>
      </div>

      {/* 3. Posting Ulang (Repost) Slot */}
      <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
        <div className="flex items-stretch font-normal cursor-pointer transition-all">
          <motion.button
            type="button"
            whileTap={{ scale: 0.88 }}
            whileHover={{ scale: 1.04 }}
            transition={{ type: "spring", stiffness: 400, damping: 17 }}
            onClick={(e) => e.stopPropagation()}
            className="flex items-center justify-center px-2.5 py-1 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 hover:text-slate-900 transition-all cursor-pointer text-slate-500 select-none"
          >
            <Repeat className="w-4 h-4 stroke-[1.75]" />
          </motion.button>
        </div>
      </div>

      {/* 4. Bagikan (Share) Slot */}
      <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
        <div className="flex items-stretch px-0.5 font-normal cursor-pointer transition-all">
          <motion.button
            type="button"
            whileTap={{ scale: 0.88 }}
            whileHover={{ scale: 1.08 }}
            transition={{ type: "spring", stiffness: 400, damping: 17 }}
            onClick={(e) => e.stopPropagation()}
            className="flex items-center justify-center p-1.5 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 hover:text-slate-900 transition-all cursor-pointer text-slate-500 select-none"
          >
            <Send className="w-4 h-4 stroke-[1.75]" />
          </motion.button>
        </div>
      </div>
    </motion.div>
  );

  return (
    <div className={`w-full ${isNested ? 'pt-3.5 pl-0' : 'py-3.5 border-b border-neutral-200'}`}>
      {!isThreadConnected ? (
        /* SINGLE COMMENT (NO REPLIES & NOT CURRENTLY REPLYING): Entire Card is Clickable Trigger with Tactile Feedback */
        <div
          onClick={() => onOpenCommentDetail?.(comment)}
          className={`flex items-start gap-3 w-full -mx-2 px-2 py-1.5 rounded-2xl ${
            onOpenCommentDetail
              ? 'cursor-pointer active:bg-neutral-100/70 active:scale-[0.995] transition-all duration-75'
              : ''
          }`}
        >
          {/* Left Column: Avatar (36x36px) */}
          <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 mt-0.5">
            <img
              src={comment.user.avatar}
              alt={comment.user.name}
              className="w-full h-full object-cover"
            />
          </div>

          {/* Right Column: Header + Content + Action Bar */}
          <div className="flex-1 min-w-0 space-y-1">
            {/* Header Row: Username + Verified + Timestamp + Options (...) */}
            <div className="flex items-center justify-between gap-2">
              <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                <span className="font-semibold text-[14px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
                  {comment.user.username || comment.user.name}
                </span>

                {comment.user.isVerified && (
                  <BadgeCheck className="w-[15px] h-[15px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                )}

                {comment.user.isAuthor && (
                  <span className="relative inline-flex items-center gap-1 px-1.5 py-0.5 rounded-[5px] text-[10.5px] font-medium text-white bg-[#18181b] border border-black/40 shadow-2xs overflow-hidden shrink-0 select-none">
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

              {/* Option (...) Icon */}
              <button
                type="button"
                onClick={(e) => e.stopPropagation()}
                className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                aria-label="Opsi komentar"
              >
                <MoreHorizontal className="w-4 h-4" />
              </button>
            </div>

            {/* Comment Content (UX Reading Flow leading-snug text-[14px] sm:text-[14.5px]) */}
            <div className="text-[14px] sm:text-[14.5px] text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] pt-0.5">
              <FormattedText text={comment.content} />
              {comment.threadPart && comment.totalParts && (
                <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11px] tabular-nums select-none ml-1.5 align-middle">
                  {comment.threadPart}/{comment.totalParts}
                </span>
              )}
            </div>

            {/* Attached Images in Comment */}
            {comment.images && comment.images.length > 0 && (
              <div className="pt-2">
                {comment.images.length === 1 ? (
                  <div className="relative w-full rounded-2xl overflow-hidden border border-black/10 shadow-2xs max-h-[300px] aspect-[16/10] bg-neutral-100">
                    <img
                      src={comment.images[0]}
                      alt="Attachment"
                      className="w-full h-full object-cover"
                      loading="lazy"
                      decoding="async"
                    />
                  </div>
                ) : (
                  <div className="flex gap-2 overflow-x-auto py-1 scrollbar-none">
                    {comment.images.map((img, idx) => (
                      <div key={idx} className="relative w-44 h-32 rounded-2xl overflow-hidden border border-black/10 shadow-2xs shrink-0 bg-neutral-100">
                        <img
                          src={img}
                          alt="Attachment"
                          className="w-full h-full object-cover"
                          loading="lazy"
                          decoding="async"
                        />
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {/* Action Bar */}
            {renderActionBar(
              isLiked,
              likesCount,
              handleLikeToggle,
              () => onReplyClick?.(comment.user.username || comment.user.name, comment.id)
            )}
          </div>
        </div>
      ) : (
        /* THREAD COMMENT WITH CONNECTED BRANCH (REPLIES OR CURRENTLY TYPING INLINE REPLY) */
        <div className="space-y-3">
          {/* Parent Comment Row (Full Row Clickable Trigger with Tactile Feedback) */}
          <div
            onClick={() => onOpenCommentDetail?.(comment)}
            className={`flex items-start gap-3 relative w-full -mx-2 px-2 py-1.5 rounded-2xl ${
              onOpenCommentDetail
                ? 'cursor-pointer active:bg-neutral-100/70 active:scale-[0.995] transition-all duration-75'
                : ''
            }`}
          >
            {/* Left Column: Avatar + Continuous Branch Line */}
            <div className="flex flex-col items-center shrink-0 self-stretch z-10">
              <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 bg-white">
                <img
                  src={comment.user.avatar}
                  alt={comment.user.name}
                  className="w-full h-full object-cover"
                />
              </div>

              {/* Vertical branch line extending down to connect child replies */}
              <div className="w-[2px] flex-1 bg-[#d1d5db] mt-1 -mb-3.5 rounded-full" />
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
                    <span className="relative inline-flex items-center gap-1 px-2 py-0.5 rounded-[6px] text-[11px] font-medium text-white bg-[#18181b] border border-black/40 shadow-2xs overflow-hidden shrink-0 select-none">
                      <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
                      <Crown className="w-3 h-3 text-white fill-white relative z-10 shrink-0" />
                      <span className="relative z-10 leading-none">Pembuat Utas</span>
                    </span>
                  )}

                  <span className="text-[14px] font-normal text-neutral-400 truncate min-w-0 shrink">
                    {comment.timestamp}
                  </span>
                </div>

                <button
                  type="button"
                  onClick={(e) => e.stopPropagation()}
                  className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                  aria-label="Opsi komentar"
                >
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>

              <div className="text-[14px] sm:text-[14.5px] text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] pt-0.5">
                <FormattedText text={comment.content} />
              </div>

              {renderActionBar(
                isLiked,
                likesCount,
                handleLikeToggle,
                () => onReplyClick?.(comment.user.username || comment.user.name, comment.id)
              )}
            </div>
          </div>

          {/* Child Replies List (Indented right with ml-7) */}
          <div className="space-y-3">
            {(onOpenCommentDetail && repliesState.length > 1
              ? repliesState.slice(0, 1)
              : repliesState
            ).map((reply, idx) => {
              const isFirstChild = idx === 0;
              const isLastChild =
                (onOpenCommentDetail && repliesState.length > 1
                  ? true
                  : idx === repliesState.length - 1) && !isReplying;

              return (
                <div
                  key={reply.id || idx}
                  onClick={() => onOpenCommentDetail?.(reply)}
                  className={`flex items-start gap-3 ml-7 relative w-full -mx-2 px-2 py-1.5 rounded-2xl ${
                    onOpenCommentDetail
                      ? 'cursor-pointer active:bg-neutral-100/70 active:scale-[0.995] transition-all duration-75'
                      : ''
                  }`}
                >
                  {/* First reply gets the initial L-Curve (└─) from Parent */}
                  {isFirstChild && (
                    <div className="absolute -left-[11px] -top-3.5 h-[32px] w-[12px] border-l-2 border-b-2 border-[#d1d5db] rounded-bl-xl pointer-events-none z-0" />
                  )}

                  {/* Left Column: Avatar + Straight Vertical Line Between Sub-Replies */}
                  <div className="flex flex-col items-center shrink-0 self-stretch z-10">
                    {/* For 2nd, 3rd, ... replies: Straight line entering top of avatar from previous reply */}
                    {!isFirstChild && (
                      <div className="w-[2px] h-3.5 bg-[#d1d5db] -mt-3.5 shrink-0" />
                    )}

                    <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 bg-white">
                      <img
                        src={reply.user.avatar}
                        alt={reply.user.name}
                        className="w-full h-full object-cover"
                      />
                    </div>

                    {/* Straight vertical line continuing under avatar to subsequent replies */}
                    {(!isLastChild || (onOpenCommentDetail && repliesState.length > 1)) && (
                      <div className="w-[2px] flex-1 bg-[#d1d5db] mt-1 -mb-3.5 rounded-full" />
                    )}
                  </div>

                  {/* Right Child Content */}
                  <div className="flex-1 min-w-0 space-y-1">
                    <div className="flex items-center justify-between gap-2 min-w-0">
                      <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                        <span className="font-semibold text-[14px] text-slate-900 truncate hover:underline shrink-0 max-w-[55%]">
                          {reply.user.username || reply.user.name}
                        </span>

                        {reply.user.isVerified && (
                          <BadgeCheck className="w-[15px] h-[15px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                        )}

                        {reply.user.isAuthor && (
                          <span className="relative inline-flex items-center gap-1 px-1.5 py-0.5 rounded-[5px] text-[10.5px] font-medium text-white bg-[#18181b] border border-black/40 shadow-2xs overflow-hidden shrink-0 select-none">
                            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
                            <Crown className="w-2.5 h-2.5 text-white fill-white relative z-10 shrink-0" />
                            <span className="relative z-10 leading-none">Pembuat Utas</span>
                          </span>
                        )}

                        <span
                          className="text-[12px] sm:text-[12.5px] font-normal text-slate-500 truncate min-w-0 shrink tabular-nums cursor-default select-none"
                          title={formatSmartTimestamp(reply.timestamp).full}
                        >
                          {formatSmartTimestamp(reply.timestamp).display}
                        </span>
                      </div>

                      <button
                        type="button"
                        onClick={(e) => e.stopPropagation()}
                        className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                        aria-label="Opsi komentar"
                      >
                        <MoreHorizontal className="w-4 h-4" />
                      </button>
                    </div>

                    <div className="text-[14px] sm:text-[14.5px] text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] pt-0.5">
                      <FormattedText text={reply.content} />
                    </div>

                    {renderActionBar(
                      reply.isLiked || false,
                      reply.likesCount,
                      () => handleNestedReplyLike(reply.id),
                      () => onReplyClick?.(reply.user.username || reply.user.name, comment.id)
                    )}
                  </div>
                </div>
              );
            })}

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

            {/* INLINE IN-PLACE SUB-REPLY INPUT (Straight line below last reply) */}
            {isReplying && (
              <div className="flex items-start gap-3 ml-7 relative pt-0.5 animate-in fade-in slide-in-from-top-1 duration-150">
                {/* If no existing replies, initial L-Curve from Parent; else straight line from previous avatar */}
                {repliesState.length === 0 ? (
                  <div className="absolute -left-[11px] -top-3.5 h-[32px] w-[12px] border-l-2 border-b-2 border-[#d1d5db] rounded-bl-xl pointer-events-none z-0" />
                ) : null}

                {/* Left Child Avatar */}
                <div className="flex flex-col items-center shrink-0 z-10">
                  {repliesState.length > 0 && (
                    <div className="w-[2px] h-3.5 bg-[#d1d5db] -mt-3.5 shrink-0" />
                  )}
                  <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 bg-white mt-0.5">
                    <img
                      src={currentUserAvatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80'}
                      alt="Profil Saya"
                      className="w-full h-full object-cover"
                    />
                  </div>
                </div>

                {/* Right Inline Form */}
                <form
                  onSubmit={handleInlineSubmit}
                  className="flex-1 min-w-0 flex items-center gap-2 bg-neutral-100 focus-within:bg-white focus-within:border-[#1d64ec] border border-neutral-200/80 rounded-full px-3.5 py-1.5 transition-all shadow-2xs"
                >
                  <input
                    ref={inputRef}
                    type="text"
                    value={replyDraftText}
                    onChange={(e) => setReplyDraftText(e.target.value)}
                    placeholder={`Balas @${comment.user.username || comment.user.name}...`}
                    className="flex-1 min-w-0 bg-transparent text-[13.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none"
                    autoFocus
                  />

                  <div className="flex items-center gap-1.5 shrink-0">
                    <button
                      type="button"
                      onClick={onCancelReply}
                      className="text-[12px] font-medium text-neutral-400 hover:text-rose-500 px-1 py-0.5 cursor-pointer transition-colors"
                    >
                      Batal
                    </button>

                    <button
                      type="submit"
                      disabled={!replyDraftText.trim()}
                      className={`px-3 py-1 rounded-full text-xs font-bold transition-all ${
                        replyDraftText.trim()
                          ? 'bg-[#18181b] text-white shadow-xs active:scale-95 cursor-pointer'
                          : 'bg-neutral-200 text-neutral-400 cursor-not-allowed'
                      }`}
                    >
                      Kirim
                    </button>
                  </div>
                </form>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
