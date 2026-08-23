import React, { useState, useRef, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ArrowLeft, Heart, Repeat2, Send, BadgeCheck, MoreHorizontal, Crown } from 'lucide-react';
import { MarketPostItem, PostComment } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { formatSmartTimestamp } from '@/utils/formatters';
import { SmoothCommentIcon } from '@/ui/components/icons/SmoothCommentIcon';
import { PostCommentItem } from './PostCommentItem';
import { PostOptionsModal } from './PostOptionsModal';
import { CommentInputBar } from './CommentInputBar';
import { useAuth } from '@/ui/hooks/useAuth';
import { triggerHaptic } from '@/utils/haptics';

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
  const [isOptionsModalOpen, setIsOptionsModalOpen] = useState(false);
  const [replyToUser, setReplyToUser] = useState<string | null>(null);
  const [replyToCommentId, setReplyToCommentId] = useState<string | null>(null);
  const [draftText, setDraftText] = useState('');

  const containerRef = useRef<HTMLDivElement>(null);

  const activeComment = commentStack[commentStack.length - 1] || focusedComment;
  const parentContext = commentStack.length > 1 ? commentStack[commentStack.length - 2] : null;

  const [isHeroLiked, setIsHeroLiked] = useState(activeComment.isLiked || false);
  const [heroLikesCount, setHeroLikesCount] = useState(activeComment.likesCount);

  useEffect(() => {
    setCommentStack([focusedComment]);
    setReplyToUser(null);
    setReplyToCommentId(null);
    setDraftText('');
  }, [focusedComment]);

  useEffect(() => {
    setIsHeroLiked(activeComment.isLiked || false);
    setHeroLikesCount(activeComment.likesCount);
    setReplyToUser(null);
    setReplyToCommentId(null);
    setDraftText('');
    if (containerRef.current) {
      containerRef.current.scrollTop = 0;
    }
  }, [activeComment]);

  // Hardware Back Button & Mobile Swipe Back History Integration (popstate)
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

    if (nextLiked) {
      triggerHaptic('medium');
    } else {
      triggerHaptic('light');
    }

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

  // Smart Auto-Mention & Auto-Focus on 💬 Action Click
  const handleReplyToUser = (targetUsername: string, targetCommentId?: string) => {
    triggerHaptic('light');
    const cleanUser = targetUsername.replace(/^@/, '');
    const targetId = targetCommentId || '';
    setReplyToUser(cleanUser);
    setReplyToCommentId(targetId);

    // Smooth auto-scroll to the target comment
    if (targetId) {
      setTimeout(() => {
        const el = document.getElementById(`comment-${targetId}`);
        if (el) {
          el.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      }, 80);
    }
  };

  const handleAddDirectReply = (text: string) => {
    if (!text.trim()) return;
    triggerHaptic('success');

    const createdId = `comment-${Date.now()}`;
    const newReply: PostComment = {
      id: createdId,
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
      content: text.trim(),
      timestamp: 'Baru saja',
      likesCount: 0,
      isLiked: false,
    };

    let updatedComment: PostComment;
    if (replyToCommentId) {
      updatedComment = {
        ...activeComment,
        replies: (activeComment.replies || []).map((r) => {
          if (r.id === replyToCommentId) {
            return {
              ...r,
              replies: [...(r.replies || []), newReply],
            };
          }
          return r;
        }),
      };
    } else {
      updatedComment = {
        ...activeComment,
        replies: [...(activeComment.replies || []), newReply],
      };
    }

    setCommentStack((prev) =>
      prev.map((c, i) => (i === prev.length - 1 ? updatedComment : c))
    );
    onUpdateComment?.(updatedComment);
    setReplyToUser(null);
    setReplyToCommentId(null);
    setDraftText('');

    // Smooth auto-scroll to the newly created comment
    setTimeout(() => {
      const el = document.getElementById(`comment-${createdId}`);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    }, 100);
  };

  const userAvatar =
    profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

  const repliesList = activeComment.replies || [];

  const draftReplyObj = replyToUser
    ? {
        targetCommentId: replyToCommentId || activeComment.id,
        text: draftText,
        userAvatar: userAvatar,
        username: profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn',
        isVerified: true,
        isAuthor: (profile?.id || 'current-user') === parentPost.seller.id,
      }
    : null;

  return (
    <div
      ref={containerRef}
      data-lenis-prevent
      className="fixed inset-0 z-50 overflow-y-auto overscroll-contain bg-white pb-32 font-gt-standard touch-pan-y animate-in slide-in-from-right-3 duration-200"
      style={{
        WebkitOverflowScrolling: 'touch',
      }}
    >
      {/* Top Header Bar: [Left: ← Back] --- [Center: Utas Komentar] --- [Right: Spacer] */}
      <header
        className="sticky top-0 left-0 right-0 z-40 bg-white border-b border-neutral-200/80 px-3.5 h-[50px] flex items-center justify-between max-w-xl mx-auto"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
        }}
      >
        <button
          type="button"
          onClick={handleBack}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-4.5 h-4.5 stroke-[2.2]" />
        </button>

        <h1 className="font-semibold text-[15px] text-slate-900">Utas Komentar</h1>

        <div className="w-9 h-9 pointer-events-none" />
      </header>

      {/* Main Content Area */}
      <main className="max-w-xl mx-auto px-3.5 pt-3 space-y-4">
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
              <span className="font-semibold text-[14px] text-slate-900 truncate">
                {parentContext
                  ? parentContext.user.username || parentContext.user.name
                  : parentPost.seller.username || parentPost.seller.name}
              </span>
              {(parentContext ? parentContext.user.isVerified : parentPost.seller.isVerified) && (
                <BadgeCheck className="w-3.5 h-3.5 text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" />
              )}
            </div>
            <p className="text-[13px] text-neutral-500 font-normal line-clamp-2 leading-snug pt-0.5">
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
              <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200 shadow-2xs shrink-0 bg-white z-10">
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
                  <span className="font-bold text-[14.5px] text-slate-900 truncate">
                    {activeComment.user.username || activeComment.user.name}
                  </span>

                  {activeComment.user.isVerified && (
                    <BadgeCheck className="w-[15px] h-[15px] text-[#1d64ec] shrink-0 fill-[#1d64ec] text-white" />
                  )}

                  {activeComment.user.isAuthor && (
                    <span className="relative inline-flex items-center gap-1 px-1.5 py-0.5 rounded-[5px] text-[10.5px] font-medium text-white bg-[#18181b] border border-black/40 shadow-2xs overflow-hidden shrink-0 select-none">
                      <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
                      <Crown className="w-2.5 h-2.5 text-white fill-white relative z-10 shrink-0" />
                      <span className="relative z-10 leading-none">Pembuat Utas</span>
                    </span>
                  )}

                  <span
                    className="text-[12px] sm:text-[12.5px] font-normal text-slate-500 truncate min-w-0 shrink tabular-nums cursor-default select-none"
                    title={formatSmartTimestamp(activeComment.timestamp).full}
                  >
                    {formatSmartTimestamp(activeComment.timestamp).display}
                  </span>
                </div>

                <button
                  type="button"
                  onClick={() => setIsOptionsModalOpen(true)}
                  className="text-slate-400 hover:text-slate-900 p-1 rounded-full hover:bg-neutral-100 transition-colors shrink-0 cursor-pointer active:scale-[0.96]"
                  aria-label="Opsi komentar"
                >
                  <MoreHorizontal className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          {/* Large Focused Comment Text (UX Reading Flow text-base leading-snug) */}
          <div className="pl-0 pt-1">
            <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere]">
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
              className="flex items-center text-slate-700 font-normal pt-3 -ml-1.5 text-[14px] select-none"
            >
              {/* 1. Like Slot */}
              <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
                <div className="flex items-stretch font-normal cursor-pointer">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.9 }}
                    onClick={handleHeroLikeToggle}
                    className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[30px] cursor-pointer select-none group"
                    aria-label={`Sukai komentar. ${heroLikesCount} suka`}
                  >
                    <motion.div
                      animate={isHeroLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
                      transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
                    >
                      <Heart
                        className={`w-4 h-4 stroke-[1.8] transition-colors duration-200 ${
                          isHeroLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
                        }`}
                      />
                    </motion.div>
                    {heroLikesCount > 0 && (
                      <motion.span
                        key={heroLikesCount}
                        initial={{ opacity: 0.6, y: -2 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.15 }}
                        className={`font-medium text-[13px] tabular-nums tracking-tight transition-colors duration-200 ${
                          isHeroLiked ? 'text-rose-600 font-bold' : 'text-slate-700'
                        }`}
                      >
                        {heroLikesCount}
                      </motion.span>
                    )}
                  </motion.button>
                </div>
              </div>

              {/* 2. Comment Slot */}
              <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
                <div className="flex items-stretch font-normal cursor-pointer">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.9 }}
                    onClick={() => {
                      handleReplyToUser(activeComment.user.username || activeComment.user.name, activeComment.id);
                    }}
                    className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[30px] cursor-pointer transition-colors text-slate-700 group select-none"
                    aria-label="Balas komentar"
                  >
                    <motion.div
                      whileTap={{ scale: [1, 0.85, 1.2, 0.95, 1], y: [0, -2, 0] }}
                      transition={{ duration: 0.25 }}
                    >
                      <SmoothCommentIcon className="w-4 h-4 stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
                    </motion.div>
                    {repliesList.length > 0 && (
                      <span className="font-medium text-[13px] text-slate-700 tabular-nums tracking-tight">{repliesList.length}</span>
                    )}
                  </motion.button>
                </div>
              </div>

              {/* 3. Repost Slot */}
              <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
                <div className="flex items-stretch font-normal cursor-pointer">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.9 }}
                    className="flex items-center justify-center gap-1.5 px-2 py-1 min-h-[30px] cursor-pointer transition-colors select-none group"
                    aria-label="Post ulang komentar"
                  >
                    <motion.div
                      whileTap={{ rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] }}
                      transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
                    >
                      <Repeat2 className="w-4 h-4 stroke-[1.8] text-slate-700 group-hover:text-emerald-500 transition-colors duration-200" />
                    </motion.div>
                  </motion.button>
                </div>
              </div>

              {/* 4. Share Slot */}
              <div className="flex items-center justify-center text-slate-700 font-normal cursor-pointer">
                <div className="flex items-stretch px-0.5 font-normal cursor-pointer">
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.9 }}
                    className="flex items-center justify-center p-1.5 cursor-pointer transition-colors text-slate-700 group select-none"
                    aria-label="Bagikan komentar"
                    title="Bagikan / Kirim"
                  >
                    <motion.div
                      whileTap={{ x: [0, 4, -1, 0], y: [0, -4, 1, 0], scale: [1, 1.2, 1] }}
                      transition={{ duration: 0.35, ease: "easeInOut" }}
                    >
                      <Send className="w-4 h-4 stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
                    </motion.div>
                  </motion.button>
                </div>
              </div>
            </motion.div>
          </div>
        </div>

        {/* 3. Sub-Replies List (P3, P4, etc.) */}
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
                  draftReply={draftReplyObj}
                  comment={reply}
                  onReplyClick={(username, cid) => handleReplyToUser(username, cid)}
                  onOpenCommentDetail={(clickedReply) => {
                    setCommentStack((prev) => [...prev, clickedReply]);
                  }}
                />
              ))}
            </div>
          ) : (
            <div className="py-10 px-6 text-center max-w-[260px] mx-auto space-y-1 select-none">
              <p className="text-slate-700 font-semibold text-[14px] leading-snug">Belum ada balasan</p>
              <p className="text-neutral-400 text-[12.5px] leading-relaxed">Jadilah yang pertama membalas!</p>
            </div>
          )}
        </div>
      </main>

      {/* Floating Pill Comment Input Bar ala Threads */}
      <CommentInputBar
        targetAuthor={activeComment.user.username || activeComment.user.name}
        userAvatar={userAvatar}
        replyToUser={replyToUser}
        autoFocus={Boolean(replyToUser)}
        onDraftChange={(val) => setDraftText(val)}
        onCancelReply={() => {
          setReplyToUser(null);
          setReplyToCommentId(null);
          setDraftText('');
        }}
        onSubmitComment={(text) => handleAddDirectReply(text)}
        isInline={false}
      />

      {/* Focused Comment 3-Dot Options Modal */}
      <PostOptionsModal
        isOpen={isOptionsModalOpen}
        onClose={() => setIsOptionsModalOpen(false)}
        title="Opsi Komentar"
        authorName={activeComment.user.name}
        authorUsername={activeComment.user.username}
        isSaved={false}
      />
    </div>
  );
};
