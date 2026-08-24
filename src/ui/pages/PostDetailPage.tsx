import React, { useState, useEffect } from 'react';
import { ArrowLeft } from 'lucide-react';
import { MarketPostItem, PostComment } from '@/types/marketFeed';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { PostCommentItem } from '../components/marketplace/PostCommentItem';
import { CommentInputBar } from '../components/marketplace/CommentInputBar';
import { StickyBuyBar } from '../components/marketplace/StickyBuyBar';
import { BuyBottomSheet } from '../components/marketplace/BuyBottomSheet';
import { CommentDetailPage } from '../components/marketplace/CommentDetailPage';
import { CheckoutPage } from './CheckoutPage';
import { useAuth } from '../hooks/useAuth';
import { triggerHaptic } from '@/utils/haptics';

interface PostDetailPageProps {
  post: MarketPostItem;
  onBack: () => void;
  onAddToCart?: (item: MarketPostItem) => void;
  onUserClick?: (username: string) => void;
}

export const PostDetailPage: React.FC<PostDetailPageProps> = ({
  post,
  onBack,
  onAddToCart,
  onUserClick,
}) => {
  const { profile } = useAuth();
  const [comments, setComments] = useState<PostComment[]>(post.comments || []);
  const [replyToCommentId, setReplyToCommentId] = useState<string | null>(null);
  const [replyTarget, setReplyTarget] = useState<{ id: string; username: string } | null>(null);
  const [draftText, setDraftText] = useState('');
  const [focusedComment, setFocusedComment] = useState<PostComment | null>(null);
  const [isBuySheetOpen, setIsBuySheetOpen] = useState(false);
  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
  const [isCommentingActive, setIsCommentingActive] = useState(false);

  const containerRef = React.useRef<HTMLDivElement>(null);

  // Determine if this post is a Marketplace Product Post
  const isProductMode = post.postType === 'product' && !!post.price && post.price > 0;

  // Smooth reset & scroll to top when opening post detail
  useEffect(() => {
    if (containerRef.current) {
      containerRef.current.scrollTop = 0;
    }
    setComments(post.comments || []);
    setReplyToCommentId(null);
    setReplyTarget(null);
    setDraftText('');
    setFocusedComment(null);
    setIsBuySheetOpen(false);
    setIsCommentingActive(false);
  }, [post.id, post.comments]);

  const handleAddComment = (content: string, specificCommentId?: string) => {
    const targetParentId = specificCommentId || replyTarget?.id || replyToCommentId;
    const isPostAuthor =
      (profile?.id || 'current-user') === post.seller.id ||
      post.seller.username === 'radityarayhannnn' ||
      post.seller.username === profile?.full_name?.toLowerCase().replace(/\s+/g, '');

    const createdId = `comment-${Date.now()}`;
    const newComment: PostComment = {
      id: createdId,
      postId: post.id,
      user: {
        id: profile?.id || 'user-current',
        name: profile?.full_name || 'Raditya Rayhan',
        username: profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn',
        avatar: profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: profile?.class_group || 'XII PPLG 1',
        isVerified: true,
        isAuthor: isPostAuthor,
      },
      content: content,
      timestamp: 'Baru saja',
      likesCount: 0,
      isLiked: false,
    };

    if (targetParentId) {
      // Nest directly inside the target parent comment or sibling sub-reply's parent!
      setComments((prev) =>
        prev.map((c) => {
          if (c.id === targetParentId || c.replies?.some((r) => r.id === targetParentId)) {
            return {
              ...c,
              replies: [...(c.replies || []), newComment],
            };
          }
          return c;
        })
      );
    } else {
      // Regular root-level comment to post
      setComments((prev) => [newComment, ...prev]);
    }

    setReplyTarget(null);
    setReplyToCommentId(null);
    setDraftText('');
    setIsCommentingActive(false);

    // Smooth auto-scroll to the newly created comment
    setTimeout(() => {
      const el = document.getElementById(`comment-${createdId}`);
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    }, 100);
  };

  const handleReplyClick = (username: string, commentId?: string) => {
    triggerHaptic('light');
    const cleanUsername = username.replace(/^@/, '');
    const targetId = commentId || '';
    setReplyTarget({ id: targetId, username: cleanUsername });
    setReplyToCommentId(targetId);
    setIsCommentingActive(true);

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

  const handleChatClick = () => {
    triggerHaptic('light');
    setIsCommentingActive(true);
  };

  const handleBuyClick = () => {
    triggerHaptic('medium');
    setIsCheckoutOpen(true);
    onAddToCart?.(post);
  };

  const userAvatar =
    profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

  const replyingToUsername = replyTarget?.username || null;

  const draftReplyObj = replyTarget
    ? {
        targetCommentId: replyTarget.id,
        text: draftText,
        userAvatar: userAvatar,
        username: profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn',
        isVerified: true,
        isAuthor: (profile?.id || 'current-user') === post.seller.id,
      }
    : null;

  // Single Page Mode: CheckoutPage
  if (isCheckoutOpen) {
    return <CheckoutPage post={post} onBack={() => setIsCheckoutOpen(false)} />;
  }

  return (
    <div
      ref={containerRef}
      data-lenis-prevent
      className="h-full w-full overflow-y-auto overscroll-contain bg-white pb-36 font-gt-standard touch-pan-y"
      style={{
        WebkitOverflowScrolling: 'touch',
      }}
    >
      {/* Top Header Bar: [Left: ← Back Button] --- [Center: Postingan] --- [Right: Spacer] */}
      <header
        className="sticky top-0 left-0 right-0 z-40 bg-white border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between max-w-xl mx-auto"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
        }}
      >
        <button
          type="button"
          onClick={onBack}
          className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
          aria-label="Kembali ke Feed Utama"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
        </button>

        <h1 className="font-semibold text-base text-slate-900">Postingan</h1>

        {/* Spacer for center title balance */}
        <div className="w-10 h-10 pointer-events-none" />
      </header>

      {/* Main Content Area */}
      <main className="max-w-xl mx-auto pt-0">
        {/* Focused Main Post Card */}
        <MarketPostCard
          item={post}
          onAddToCart={onAddToCart}
          onUserClick={onUserClick}
          variant="detail"
        />

        {/* Comments Section (Includes Author Thread Continuations 2/N, 3/N at top) */}
        <section id="comments-section" className="w-full pt-1">
          {/* Section Divider Header */}
          <div className="px-3.5 py-2.5 flex items-center justify-between border-b border-neutral-100">
            <h2 className="font-semibold text-sm text-slate-900">
              {isProductMode ? 'Tanya Jawab & Diskusi' : 'Komentar'} ({post.threadChain && post.threadChain.length > 0 ? comments.length + post.threadChain.length : comments.length})
            </h2>
            <span className="text-xs text-neutral-400">Urutkan dari Terbaru</span>
          </div>

          {/* Combined Comment List: Author Thread Continuations + General Comments */}
          {(post.threadChain && post.threadChain.length > 0) || comments.length > 0 ? (
            <div className="w-full">
              {/* 1. Author Thread Continuation Comments (Part 2, Part 3, etc.) */}
              {post.threadChain?.map((chain) => (
                <PostCommentItem
                  key={chain.id}
                  draftReply={draftReplyObj}
                  comment={{
                    id: chain.id,
                    postId: post.id,
                    user: {
                      id: post.seller.id,
                      name: post.seller.name,
                      username: post.seller.username || post.seller.name,
                      avatar: post.seller.avatar,
                      classGroup: post.seller.classGroup,
                      isVerified: post.seller.isVerified,
                      isAuthor: true,
                    },
                    content: chain.caption,
                    images: chain.images,
                    threadPart: chain.partNumber,
                    totalParts: chain.totalParts,
                    timestamp: chain.timestamp || 'Baru saja',
                    likesCount: chain.likesCount || 0,
                    isLiked: chain.isLiked || false,
                  }}
                  onReplyClick={handleReplyClick}
                  onOpenCommentDetail={(c) => setFocusedComment(c)}
                />
              ))}

              {/* 2. General Comments from Other Users */}
              {comments.map((comment) => (
                <PostCommentItem
                  key={comment.id}
                  draftReply={draftReplyObj}
                  comment={comment}
                  onReplyClick={handleReplyClick}
                  onOpenCommentDetail={(c) => setFocusedComment(c)}
                />
              ))}
            </div>
          ) : (
            <div className="py-12 px-6 text-center max-w-[280px] mx-auto space-y-1.5 select-none">
              <p className="text-slate-800 font-semibold text-[14.5px] leading-snug">
                {isProductMode ? 'Belum ada pertanyaan' : 'Belum ada komentar'}
              </p>
              <p className="text-neutral-500 text-[12.5px] leading-relaxed">
                {isProductMode
                  ? 'Ingin tahu kondisi atau ketersediaan stok? Tanyakan langsung ke penjual.'
                  : 'Mulai percakapan dan jadilah yang pertama memberi tanggapan.'}
              </p>
            </div>
          )}
        </section>
      </main>

      {/* MODE 1: Marketplace Product Posts (Morphing between StickyBuyBar and CommentInputBar) */}
      {isProductMode ? (
        isCommentingActive ? (
          <CommentInputBar
            targetAuthor={post.seller.username || post.seller.name}
            userAvatar={userAvatar}
            replyToUser={replyingToUsername}
            autoFocus={true}
            onDraftChange={(val) => setDraftText(val)}
            onClose={() => {
              setIsCommentingActive(false);
              setReplyTarget(null);
              setReplyToCommentId(null);
              setDraftText('');
            }}
            onCancelReply={() => {
              setReplyTarget(null);
              setReplyToCommentId(null);
              setDraftText('');
            }}
            onSubmitComment={(text) => handleAddComment(text, replyTarget?.id || replyToCommentId || undefined)}
            isInline={false}
          />
        ) : (
          <>
            <StickyBuyBar
              price={post.price || 0}
              stockCount={post.stock || 1}
              onBuyClick={handleBuyClick}
              onChatClick={handleChatClick}
            />

            <BuyBottomSheet
              key={`buy-${post.id}`}
              isOpen={isBuySheetOpen}
              post={post}
              onClose={() => setIsBuySheetOpen(false)}
            />
          </>
        )
      ) : (
        /* MODE 2: Docked Bottom Bar ala Threads / X for Discussion / Utas Posts */
        <CommentInputBar
          targetAuthor={post.seller.username || post.seller.name}
          userAvatar={userAvatar}
          replyToUser={replyingToUsername}
          onDraftChange={(val) => setDraftText(val)}
          onCancelReply={() => {
            setReplyTarget(null);
            setReplyToCommentId(null);
            setDraftText('');
          }}
          onSubmitComment={(text) => handleAddComment(text, replyTarget?.id || replyToCommentId || undefined)}
          isInline={false}
        />
      )}

      {/* Threads-style Sub-Thread Comment Detail Modal / Fullscreen Sub-Page */}
      {focusedComment && (
        <CommentDetailPage
          parentPost={post}
          focusedComment={focusedComment}
          onBack={() => setFocusedComment(null)}
          onUpdateComment={(updated) => {
            setFocusedComment(updated);
            setComments((prev) =>
              prev.map((c) => (c.id === updated.id ? updated : c))
            );
          }}
        />
      )}
    </div>
  );
};
