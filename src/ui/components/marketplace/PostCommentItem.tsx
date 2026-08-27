import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Heart, Repeat2, Send, BadgeCheck, MoreHorizontal, Crown } from 'lucide-react';
import { PostComment } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { formatSmartTimestamp } from '@/utils/formatters';
import { SmoothCommentIcon } from '@/ui/components/icons';
import { PostSubmenuDropdown } from './PostSubmenuDropdown';
import { triggerHaptic } from '@/utils/haptics';

interface PostCommentItemProps {
  comment: PostComment;
  currentUserAvatar?: string;
  onReplyClick?: (username: string, commentId?: string) => void;
  onOpenCommentDetail?: (comment: PostComment) => void;
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
  isNested = false,
  draftReply,
}) => {
  const [isLiked, setIsLiked] = useState(comment.isLiked || false);
  const [likesCount, setLikesCount] = useState(comment.likesCount || 0);
  const [repliesState, setRepliesState] = useState<PostComment[]>(comment.replies || []);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  React.useEffect(() => {
    setRepliesState(comment.replies || []);
  }, [comment.replies]);

  const handleLikeToggle = () => {
    setIsLiked((prev) => {
      const next = !prev;
      if (next) triggerHaptic('medium');
      else triggerHaptic('light');
      setLikesCount((c) => (next ? c + 1 : Math.max(0, c - 1)));
      return next;
    });
  };

  const handleNestedReplyLike = (replyId: string) => {
    setRepliesState((prev) =>
      prev.map((r) => {
        if (r.id === replyId) {
          const nextLiked = !r.isLiked;
          if (nextLiked) triggerHaptic('medium');
          else triggerHaptic('light');
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

  const renderActionBar = (
    liked: boolean,
    count: number,
    onLike?: () => void,
    onReply?: () => void
  ) => (
    <div
      onClick={(e) => e.stopPropagation()}
      className="flex items-center gap-1.5 text-slate-700 font-normal pt-1 -ml-1 text-[13px] select-none"
    >
      {/* 1. Suka (Like) Slot */}
      <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
        <div className="flex items-stretch font-normal cursor-pointer">
          <motion.button
            type="button"
            whileTap={{ scale: 0.96 }}
            onClick={(e) => {
              e.stopPropagation();
              onLike?.();
            }}
            className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[34px] min-w-[34px] cursor-pointer select-none group active:bg-neutral-100 rounded-full transition-colors"
            aria-label={`Sukai komentar. ${count} suka`}
          >
            <motion.div
              animate={liked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
              transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
            >
              <Heart
                className={`w-[17.5px] h-[17.5px] stroke-[1.8] transition-colors duration-200 ${
                  liked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
                }`}
              />
            </motion.div>
            {count > 0 && (
              <motion.span
                key={count}
                initial={{ opacity: 0.6, y: -2 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.15 }}
                className={`font-medium text-[12.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                  liked ? 'text-rose-600 font-bold' : 'text-slate-700'
                }`}
              >
                {count}
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
            whileTap={{ scale: 0.96 }}
            onClick={(e) => {
              e.stopPropagation();
              onReply?.();
            }}
            className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[34px] min-w-[34px] cursor-pointer transition-colors text-slate-700 group select-none active:bg-neutral-100 rounded-full"
            aria-label="Balas komentar"
          >
            <SmoothCommentIcon className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
          </motion.button>
        </div>
      </div>

      {/* 3. Posting Ulang (Repost) Slot */}
      <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
        <div className="flex items-stretch font-normal cursor-pointer">
          <motion.button
            type="button"
            whileTap={{ scale: 0.96 }}
            onClick={(e) => e.stopPropagation()}
            className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[34px] min-w-[34px] cursor-pointer transition-colors select-none group active:bg-neutral-100 rounded-full"
            aria-label="Post ulang komentar"
          >
            <motion.div
              animate={Boolean(count > 0)}
              whileTap={{ rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] }}
              transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
            >
              <Repeat2 className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-emerald-500 transition-colors duration-200" />
            </motion.div>
          </motion.button>
        </div>
      </div>

      {/* 4. Bagikan (Share) Slot */}
      <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
        <div className="flex items-stretch px-0.5 font-normal cursor-pointer">
          <motion.button
            type="button"
            whileTap={{ scale: 0.96 }}
            onClick={(e) => e.stopPropagation()}
            className="flex items-center justify-center p-1.5 min-h-[34px] min-w-[34px] cursor-pointer transition-colors text-slate-700 group select-none active:bg-neutral-100 rounded-full"
            aria-label="Bagikan komentar"
            title="Bagikan / Kirim"
          >
            <Send className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
          </motion.button>
        </div>
      </div>
    </div>
  );

  return (
    <div
      id={`comment-${comment.id}`}
      className={`w-full transition-colors duration-300 ${
        isNested ? 'pt-3.5 pl-0' : 'px-3.5 py-3.5 border-b border-neutral-200'
      }`}
    >
      {!isThreadConnected ? (
        /* SINGLE COMMENT (NO REPLIES & NOT CURRENTLY REPLYING): Entire Card is Clickable Trigger with Tactile Feedback */
        <div
          onClick={() => onOpenCommentDetail?.(comment)}
          className={`flex items-start gap-3 w-full ${
            onOpenCommentDetail
              ? 'cursor-pointer active:opacity-75 transition-opacity'
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
          <div className="flex-1 min-w-0">
            {/* Header Row: Username + Verified + Timestamp + Options (...) */}
            <div className="flex items-center justify-between gap-2 h-[21px] leading-snug">
              <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden h-[21px] leading-snug">
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

              {/* Option (...) Icon & Submenu */}
              <div className="relative">
                <button
                  type="button"
                  data-submenu-trigger="true"
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
                />
              </div>
            </div>

            {/* Comment Content (UX Reading Flow leading-snug text-base with tight 2px gap) */}
            <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] mt-0.5">
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
            className={`flex items-start gap-3 relative w-full ${
              onOpenCommentDetail
                ? 'cursor-pointer active:opacity-75 transition-opacity'
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
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between gap-2 min-w-0 h-[21px] leading-snug">
                <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden h-[21px] leading-snug">
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

                <div className="relative">
                  <button
                    type="button"
                    data-submenu-trigger="true"
                    onClick={(e) => {
                      e.stopPropagation();
                      setIsMenuOpen((prev) => !prev);
                    }}
                    className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer"
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
                  />
                </div>
              </div>

              <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] mt-0.5">
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
                !hasDraft &&
                (onOpenCommentDetail && repliesState.length > 1
                  ? true
                  : idx === repliesState.length - 1);

              return (
                <div
                  key={reply.id || idx}
                  id={`comment-${reply.id}`}
                  onClick={() => onOpenCommentDetail?.(reply)}
                  className={`flex items-start gap-3 ml-7 relative min-w-0 transition-colors duration-300 ${
                    onOpenCommentDetail
                      ? 'cursor-pointer active:opacity-75 transition-opacity'
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

                    {/* Straight vertical line continuing under avatar to subsequent replies or draft */}
                    {(!isLastChild || hasDraft || (onOpenCommentDetail && repliesState.length > 1)) && (
                      <div className="w-[2px] flex-1 bg-[#d1d5db] mt-1 -mb-3.5 rounded-full" />
                    )}
                  </div>

                  {/* Right Child Content */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-2 min-w-0 h-[21px] leading-snug">
                      <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden h-[21px] leading-snug">
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

                    <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere] mt-0.5">
                      <FormattedText text={reply.content} />
                    </div>

                    {renderActionBar(
                      reply.isLiked || false,
                      reply.likesCount,
                      () => handleNestedReplyLike(reply.id),
                      () => onReplyClick?.(reply.user.username || reply.user.name, reply.id)
                    )}
                  </div>
                </div>
              );
            })}

            {/* LIVE-SYNCED DRAFT REPLY BUBBLE (Threads Style) */}
            {hasDraft && draftReply && (
              <div
                id={`comment-draft-${comment.id}`}
                className="flex items-start gap-3 ml-7 relative min-w-0 animate-in fade-in slide-in-from-top-1 duration-150"
              >
                {/* First reply gets the initial L-Curve from parent if repliesState is empty */}
                {repliesState.length === 0 && (
                  <div className="absolute -left-[11px] -top-3.5 h-[32px] w-[12px] border-l-2 border-b-2 border-[#d1d5db] rounded-bl-xl pointer-events-none z-0" />
                )}

                {/* Left Column: Current User Avatar */}
                <div className="flex flex-col items-center shrink-0 self-stretch z-10">
                  {repliesState.length > 0 && (
                    <div className="w-[2px] h-3.5 bg-[#d1d5db] -mt-3.5 shrink-0" />
                  )}
                  <div className="w-9 h-9 rounded-full overflow-hidden border border-[#1d64ec]/50 ring-2 ring-[#1d64ec]/20 shadow-2xs shrink-0 bg-white">
                    <img
                      src={draftReply.userAvatar || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"}
                      alt={draftReply.username || "Saya"}
                      className="w-full h-full object-cover"
                    />
                  </div>
                </div>

                {/* Right Child Content: Live Synchronized Text */}
                <div className="flex-1 min-w-0 pb-1">
                  <div className="flex items-center gap-1.5 min-w-0 h-[21px] leading-snug">
                    <span className="font-semibold text-[14px] text-slate-900 truncate">
                      {draftReply.username || 'radityarayhannnn'}
                    </span>

                    {draftReply.isVerified && (
                      <BadgeCheck className="w-[15px] h-[15px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" aria-label="Verified User" />
                    )}

                    <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full text-[10.5px] font-semibold text-[#1d64ec] bg-blue-50 border border-blue-200/60 animate-pulse shrink-0 select-none">
                      <span>Mengetik...</span>
                    </span>
                  </div>

                  {/* Live Text Body with Simulated Caret */}
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
        </div>
      )}

    </div>
  );
};
