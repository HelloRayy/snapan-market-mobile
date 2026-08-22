import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, Heart, Repeat, Send, BadgeCheck, MoreHorizontal, Crown } from 'lucide-react';
import { MarketPostItem, PostComment } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { formatSmartTimestamp } from '@/utils/formatters';
import { PostCommentItem } from './PostCommentItem';
import { useAuth } from '@/ui/hooks/useAuth';

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

interface CommentDetailPageProps {
  parentPost: MarketPostItem;
  focusedComment: PostComment;
  onBack: () => void;
  onUpdateComment?: (updatedComment: PostComment) => void;
}

export const CommentDetailPage: React.FC<CommentDetailPageProps> = ({
  parentPost,
  focusedComment,
  onBack,
  onUpdateComment,
}) => {
  const { profile } = useAuth();
  const [commentStack, setCommentStack] = useState<PostComment[]>([focusedComment]);
  const [replyInputText, setReplyInputText] = useState('');
  const [replyToCommentId, setReplyToCommentId] = useState<string | null>(null);

  const containerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const activeComment = commentStack[commentStack.length - 1] || focusedComment;
  const parentContext = commentStack.length > 1 ? commentStack[commentStack.length - 2] : null;

  const [isHeroLiked, setIsHeroLiked] = useState(activeComment.isLiked || false);
  const [heroLikesCount, setHeroLikesCount] = useState(activeComment.likesCount);

  useEffect(() => {
    setCommentStack([focusedComment]);
  }, [focusedComment]);

  useEffect(() => {
    setIsHeroLiked(activeComment.isLiked || false);
    setHeroLikesCount(activeComment.likesCount);
    if (containerRef.current) {
      containerRef.current.scrollTop = 0;
    }
  }, [activeComment]);

  // OPTIMIZATION 1: Hardware Back Button & Mobile Swipe Back History Integration (popstate)
  useEffect(() => {
    window.history.pushState({ modal: 'comment-detail', depth: commentStack.length }, '');

    const handlePopState = () => {
      if (commentStack.length > 1) {
        setCommentStack((prev) => prev.slice(0, -1));
      } else {
        onBack();
      }
    };

    window.addEventListener('popstate', handlePopState);
    return () => {
      window.removeEventListener('popstate', handlePopState);
    };
  }, [commentStack.length, onBack]);

  const handleHeroLikeToggle = () => {
    const nextLiked = !isHeroLiked;
    const nextCount = nextLiked ? heroLikesCount + 1 : Math.max(0, heroLikesCount - 1);
    setIsHeroLiked(nextLiked);
    setHeroLikesCount(nextCount);

    const updated = {
      ...activeComment,
      isLiked: nextLiked,
      likesCount: nextCount,
    };
    setCommentStack((prev) =>
      prev.map((c, i) => (i === prev.length - 1 ? updated : c))
    );
    onUpdateComment?.(updated);
  };

  const handleBack = () => {
    window.history.back();
  };

  // OPTIMIZATION 3: Smart Auto-Mention & Auto-Focus on 💬 Action Click
  const handleReplyToUser = (targetUsername: string, targetCommentId?: string) => {
    const mentionPrefix = `@${targetUsername} `;
    setReplyInputText(mentionPrefix);
    setReplyToCommentId(targetCommentId || null);
    setTimeout(() => {
      if (inputRef.current) {
        inputRef.current.focus();
        inputRef.current.setSelectionRange(mentionPrefix.length, mentionPrefix.length);
      }
    }, 50);
  };

  const handleAddDirectReply = (e: React.FormEvent) => {
    e.preventDefault();
    if (!replyInputText.trim()) return;

    const newReply: PostComment = {
      id: `comment-${Date.now()}`,
      postId: parentPost.id,
      user: {
        id: profile?.id || 'user-current',
        name: profile?.full_name || 'Raditya Rayhan',
        username: profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn',
        avatar: profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: profile?.class_group || 'XII PPLG 1',
        isVerified: true,
        isAuthor:
          (profile?.id || 'current-user') === parentPost.seller.id ||
          parentPost.seller.username === 'radityarayhannnn',
      },
      content: replyInputText.trim(),
      timestamp: 'Baru saja',
      likesCount: 0,
      isLiked: false,
    };

    const updatedComment: PostComment = {
      ...activeComment,
      replies: [...(activeComment.replies || []), newReply],
    };

    setCommentStack((prev) =>
      prev.map((c, i) => (i === prev.length - 1 ? updatedComment : c))
    );
    onUpdateComment?.(updatedComment);
    setReplyInputText('');
    setReplyToCommentId(null);
  };

  const handleNestedReplySubmit = (targetChildId: string, text: string) => {
    const newNestedReply: PostComment = {
      id: `comment-${Date.now()}`,
      postId: parentPost.id,
      user: {
        id: profile?.id || 'user-current',
        name: profile?.full_name || 'Raditya Rayhan',
        username: profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn',
        avatar: profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: profile?.class_group || 'XII PPLG 1',
        isVerified: true,
        isAuthor:
          (profile?.id || 'current-user') === parentPost.seller.id ||
          parentPost.seller.username === 'radityarayhannnn',
      },
      content: text,
      timestamp: 'Baru saja',
      likesCount: 0,
      isLiked: false,
    };

    const updatedComment: PostComment = {
      ...activeComment,
      replies: (activeComment.replies || []).map((r) => {
        if (r.id === targetChildId) {
          return {
            ...r,
            replies: [...(r.replies || []), newNestedReply],
          };
        }
        return r;
      }),
    };

    setCommentStack((prev) =>
      prev.map((c, i) => (i === prev.length - 1 ? updatedComment : c))
    );
    onUpdateComment?.(updatedComment);
    setReplyToCommentId(null);
  };

  const userAvatar =
    profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

  const repliesList = activeComment.replies || [];

  return (
    <div
      ref={containerRef}
      className="fixed inset-0 z-50 overflow-y-auto overscroll-contain bg-white pb-32 font-gt-standard animate-in slide-in-from-right-3 duration-200"
      style={{
        WebkitOverflowScrolling: 'touch',
      }}
    >
      {/* Top Header Bar: [Left: ← Back] --- [Center: Utas Komentar] --- [Right: Spacer] */}
      <header
        className="sticky top-0 left-0 right-0 z-40 bg-white border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between max-w-xl mx-auto"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
        }}
      >
        <button
          type="button"
          onClick={handleBack}
          className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
        </button>

        <h1 className="font-semibold text-base text-slate-900">Utas Komentar</h1>

        <div className="w-10 h-10 pointer-events-none" />
      </header>

      {/* Main Content Area */}
      <main className="max-w-xl mx-auto px-4 pt-3 space-y-4">
        {/* OPTIMIZATION 4: Pixel-Perfect Context Header (Connected via Vertical Line down to Hero Avatar with 0 Gap) */}
        <div className="flex items-start gap-3 relative">
          {/* Left Avatar + Continuous Vertical Line */}
          <div className="flex flex-col items-center shrink-0 self-stretch">
            <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 bg-white z-10">
              <img
                src={parentContext ? parentContext.user.avatar : parentPost.seller.avatar}
                alt={parentContext ? parentContext.user.name : parentPost.seller.name}
                className="w-full h-full object-cover"
              />
            </div>
            {/* Continuous line passing down with 0 gap into hero */}
            <div className="w-[2px] flex-1 bg-[#d1d5db] mt-1 -mb-2 rounded-full z-0" />
          </div>

          {/* Right Snippet Content */}
          <div className="flex-1 min-w-0 pb-3">
            <div className="flex items-center gap-1.5 min-w-0">
              <span className="font-semibold text-[14.5px] text-slate-900 truncate">
                {parentContext
                  ? parentContext.user.username || parentContext.user.name
                  : parentPost.seller.username || parentPost.seller.name}
              </span>
              {(parentContext ? parentContext.user.isVerified : parentPost.seller.isVerified) && (
                <BadgeCheck className="w-4 h-4 text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" />
              )}
            </div>
            <p className="text-[13.5px] text-neutral-500 font-normal line-clamp-2 leading-relaxed pt-0.5">
              {parentContext ? (
                parentContext.content
              ) : (
                <>
                  {parentPost.title ? `${parentPost.title} • ` : ''}
                  {parentPost.caption}
                </>
              )}
            </p>
          </div>
        </div>

        {/* 2. Hero Focused Comment Card (Active Focused Item) */}
        <div className="pt-0 space-y-2 border-b border-neutral-200/80 pb-4">
          <div className="flex items-start gap-3">
            {/* Avatar Column with line coming in from top */}
            <div className="flex flex-col items-center shrink-0 self-stretch">
              <div className="w-[2px] h-2 bg-[#d1d5db] -mt-2 shrink-0 z-0" />
              <div className="w-10 h-10 rounded-full overflow-hidden border border-neutral-200 shadow-2xs shrink-0 bg-white z-10">
                <img
                  src={activeComment.user.avatar}
                  alt={activeComment.user.name}
                  className="w-full h-full object-cover"
                />
              </div>
            </div>

            {/* Author Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between gap-2">
                <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden">
                  <span className="font-bold text-[15.5px] text-slate-900 truncate">
                    {activeComment.user.username || activeComment.user.name}
                  </span>

                  {activeComment.user.isVerified && (
                    <BadgeCheck className="w-[17px] h-[17px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" />
                  )}

                  {activeComment.user.isAuthor && (
                    <span className="relative inline-flex items-center gap-1 px-2 py-0.5 rounded-[6px] text-[11px] font-medium text-white bg-[#18181b] border border-black/40 shadow-2xs overflow-hidden shrink-0 select-none">
                      <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
                      <Crown className="w-3 h-3 text-white fill-white relative z-10 shrink-0" />
                      <span className="relative z-10 leading-none">Pembuat Utas</span>
                    </span>
                  )}

                  <span
                    className="text-[13px] sm:text-[13.5px] font-normal text-slate-500 truncate min-w-0 shrink tabular-nums cursor-default select-none"
                    title={formatSmartTimestamp(activeComment.timestamp).full}
                  >
                    {formatSmartTimestamp(activeComment.timestamp).display}
                  </span>
                </div>

                <button
                  type="button"
                  className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0"
                >
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          {/* Large Focused Comment Text (UX Reading Flow text-[16px] leading-snug) */}
          <div className="pl-0 pt-1">
            <div className="text-[16px] text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere]">
              <FormattedText text={activeComment.content} />
            </div>

            {/* Attached Images */}
            {activeComment.images && activeComment.images.length > 0 && (
              <div className="pt-3">
                <div className="relative w-full rounded-[18px] overflow-hidden border border-black/10 shadow-2xs max-h-[420px] aspect-[4/5] sm:aspect-[16/10] bg-neutral-100">
                  <picture className="block w-full h-full cursor-pointer">
                    <img
                      src={activeComment.images[0]}
                      alt="Attachment"
                      className="w-full h-full object-cover select-none"
                    />
                  </picture>
                  <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
                </div>
              </div>
            )}

            {/* Action Bar with Threads Nested Layout */}
            <motion.div
              initial={{ opacity: 0, y: 6 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.2, ease: "easeOut" }}
              className="flex items-center text-slate-700 font-normal pt-3 -ml-2 text-[14px] select-none"
            >
              {/* 1. Like Slot */}
              <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
                <div className="flex items-stretch font-normal cursor-pointer transition-all">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.88 }}
                    whileHover={{ scale: 1.04 }}
                    transition={{ type: "spring", stiffness: 400, damping: 17 }}
                    onClick={handleHeroLikeToggle}
                    className={`flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 transition-all cursor-pointer select-none ${
                      isHeroLiked ? 'text-rose-500' : 'text-slate-500 hover:text-slate-900'
                    }`}
                  >
                    <motion.div
                      animate={isHeroLiked ? { scale: [1, 1.35, 0.95, 1], rotate: [0, -12, 12, 0] } : { scale: 1, rotate: 0 }}
                      transition={{ duration: 0.35, ease: "easeOut" }}
                    >
                      <Heart className={`w-4.5 h-4.5 stroke-[1.75] ${isHeroLiked ? 'fill-rose-500 text-rose-500' : ''}`} />
                    </motion.div>
                    {heroLikesCount > 0 && (
                      <span className="font-semibold text-slate-700 tabular-nums">{heroLikesCount}</span>
                    )}
                  </motion.button>
                </div>
              </div>

              {/* 2. Comment Slot */}
              <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
                <div className="flex items-stretch font-normal cursor-pointer transition-all">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.88 }}
                    whileHover={{ scale: 1.04 }}
                    transition={{ type: "spring", stiffness: 400, damping: 17 }}
                    onClick={() => {
                      inputRef.current?.focus();
                    }}
                    className="flex items-center justify-center gap-1.5 px-3 py-1.5 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 hover:text-slate-900 transition-all cursor-pointer text-slate-500 select-none"
                  >
                    <SmoothCommentIcon className="w-4.5 h-4.5 stroke-[1.75]" />
                    {repliesList.length > 0 && (
                      <span className="font-semibold text-slate-700 tabular-nums">{repliesList.length}</span>
                    )}
                  </motion.button>
                </div>
              </div>

              {/* 3. Repost Slot */}
              <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
                <div className="flex items-stretch font-normal cursor-pointer transition-all">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.88 }}
                    whileHover={{ scale: 1.04 }}
                    transition={{ type: "spring", stiffness: 400, damping: 17 }}
                    className="flex items-center justify-center px-3 py-1.5 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 hover:text-slate-900 transition-all cursor-pointer text-slate-500 select-none"
                  >
                    <Repeat className="w-4.5 h-4.5 stroke-[1.75]" />
                  </motion.button>
                </div>
              </div>

              {/* 4. Share Slot */}
              <div className="flex items-center justify-center font-normal cursor-pointer transition-all">
                <div className="flex items-stretch px-1 font-normal cursor-pointer transition-all">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.88 }}
                    whileHover={{ scale: 1.08 }}
                    transition={{ type: "spring", stiffness: 400, damping: 17 }}
                    className="flex items-center justify-center p-2 rounded-[1000px] hover:bg-neutral-100/80 active:bg-neutral-200/80 hover:text-slate-900 transition-all cursor-pointer text-slate-500 select-none"
                  >
                    <Send className="w-4.5 h-4.5 stroke-[1.75]" />
                  </motion.button>
                </div>
              </div>
            </motion.div>
          </div>
        </div>

        {/* 3. Reply Input Bar into Active Hero Comment */}
        <form
          onSubmit={handleAddDirectReply}
          className="flex items-center gap-2.5 bg-neutral-100 focus-within:bg-white focus-within:border-[#1d64ec] border border-neutral-200/80 rounded-full px-4 py-2 transition-all shadow-2xs"
        >
          <div className="w-7 h-7 rounded-full overflow-hidden border border-neutral-200 shrink-0">
            <img src={userAvatar} alt="Profil Saya" className="w-full h-full object-cover" />
          </div>

          <input
            ref={inputRef}
            type="text"
            value={replyInputText}
            onChange={(e) => setReplyInputText(e.target.value)}
            placeholder={`Balas @${activeComment.user.username || activeComment.user.name}...`}
            className="flex-1 min-w-0 bg-transparent text-[14px] text-slate-900 placeholder:text-neutral-400 focus:outline-none"
          />

          <button
            type="submit"
            disabled={!replyInputText.trim()}
            className={`px-3.5 py-1.5 rounded-full text-xs font-bold transition-all shrink-0 ${
              replyInputText.trim()
                ? 'bg-[#18181b] text-white shadow-xs active:scale-95 cursor-pointer'
                : 'bg-neutral-200 text-neutral-400 cursor-not-allowed'
            }`}
          >
            Kirim
          </button>
        </form>

        {/* 4. Sub-Replies List (P3, P4, etc.) */}
        <div className="pt-2 space-y-2">
          <div className="flex items-center justify-between pb-1">
            <h2 className="font-semibold text-sm text-slate-900">
              Balasan ({repliesList.length})
            </h2>
            <span className="text-xs text-neutral-400">Urutkan dari Terlama</span>
          </div>

          {repliesList.length > 0 ? (
            <div className="divide-y divide-neutral-200">
              {repliesList.map((reply) => (
                <PostCommentItem
                  key={reply.id}
                  comment={reply}
                  currentUserAvatar={userAvatar}
                  activeReplyingCommentId={replyToCommentId}
                  onReplyClick={(username, cid) => handleReplyToUser(username, cid)}
                  onCancelReply={() => setReplyToCommentId(null)}
                  onSubmitReply={handleNestedReplySubmit}
                  onOpenCommentDetail={(clickedReply) => {
                    setCommentStack((prev) => [...prev, clickedReply]);
                  }}
                />
              ))}
            </div>
          ) : (
            <div className="py-10 text-center space-y-1">
              <p className="text-slate-600 font-medium text-sm">Belum ada balasan</p>
              <p className="text-neutral-400 text-xs">Jadilah yang pertama membalas!</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};
