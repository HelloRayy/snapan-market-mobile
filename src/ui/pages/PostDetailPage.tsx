import React, { useState, useEffect } from 'react';
import { ArrowLeft } from 'lucide-react';
import { MarketPostItem, PostComment } from '@/types/marketFeed';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { PostCommentItem } from '../components/marketplace/PostCommentItem';
import { CommentInputBar } from '../components/marketplace/CommentInputBar';
import { StickyBuyBar } from '../components/marketplace/StickyBuyBar';
import { BuyBottomSheet } from '../components/marketplace/BuyBottomSheet';
import { AskSellerBottomSheet } from '../components/marketplace/AskSellerBottomSheet';
import { CommentDetailPage } from '../components/marketplace/CommentDetailPage';
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
  const [focusedComment, setFocusedComment] = useState<PostComment | null>(null);
  const [isBuySheetOpen, setIsBuySheetOpen] = useState(false);
  const [isAskSheetOpen, setIsAskSheetOpen] = useState(false);

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
    setFocusedComment(null);
    setIsBuySheetOpen(false);
    setIsAskSheetOpen(false);
  }, [post.id, post.comments]);

  const handleAddComment = (content: string, specificCommentId?: string) => {
    const targetParentId = specificCommentId || replyToCommentId;
    const isPostAuthor =
      (profile?.id || 'current-user') === post.seller.id ||
      post.seller.username === 'radityarayhannnn' ||
      post.seller.username === profile?.full_name?.toLowerCase().replace(/\s+/g, '');

    const newComment: PostComment = {
      id: `comment-${Date.now()}`,
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
      // Nest directly inside the target parent comment!
      setComments((prev) =>
        prev.map((c) => {
          if (c.id === targetParentId) {
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

    setReplyToCommentId(null);
  };

  const handleReplyClick = (_username: string, commentId?: string) => {
    triggerHaptic('light');
    setReplyToCommentId(commentId || null);
  };

  const handleChatClick = () => {
    triggerHaptic('medium');
    setIsAskSheetOpen(true);
  };

  const handleBuyClick = () => {
    triggerHaptic('medium');
    setIsBuySheetOpen(true);
    onAddToCart?.(post);
  };

  const userAvatar =
    profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

  // Find the username we're currently replying to if any
  const targetReplyComment = comments.find((c) => c.id === replyToCommentId);
  const replyingToUsername = targetReplyComment ? targetReplyComment.user.username || targetReplyComment.user.name : null;

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
        <section id="comments-section" className="px-4 pt-2">
          {/* Section Divider Header */}
          <div className="py-2.5 flex items-center justify-between">
            <h2 className="font-semibold text-sm text-slate-900">
              {isProductMode ? 'Tanya Jawab & Diskusi' : 'Komentar'} ({post.threadChain && post.threadChain.length > 0 ? comments.length + post.threadChain.length : comments.length})
            </h2>
            <span className="text-xs text-neutral-400">Urutkan dari Terbaru</span>
          </div>

          {/* Combined Comment List: Author Thread Continuations + General Comments */}
          {(post.threadChain && post.threadChain.length > 0) || comments.length > 0 ? (
            <div className="divide-y divide-neutral-200">
              {/* 1. Author Thread Continuation Comments (Part 2, Part 3, etc.) */}
              {post.threadChain?.map((chain) => (
                <PostCommentItem
                  key={chain.id}
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
                  currentUserAvatar={userAvatar}
                  activeReplyingCommentId={replyToCommentId}
                  onReplyClick={handleReplyClick}
                  onCancelReply={() => setReplyToCommentId(null)}
                  onSubmitReply={(cid, text) => handleAddComment(text, cid)}
                  onOpenCommentDetail={(c) => setFocusedComment(c)}
                />
              ))}

              {/* 2. General Comments from Other Users */}
              {comments.map((comment) => (
                <PostCommentItem
                  key={comment.id}
                  comment={comment}
                  currentUserAvatar={userAvatar}
                  activeReplyingCommentId={replyToCommentId}
                  onReplyClick={handleReplyClick}
                  onCancelReply={() => setReplyToCommentId(null)}
                  onSubmitReply={(cid, text) => handleAddComment(text, cid)}
                  onOpenCommentDetail={(c) => setFocusedComment(c)}
                />
              ))}
            </div>
          ) : (
            <div className="py-12 text-center space-y-1">
              <p className="text-slate-600 font-medium text-sm">
                {isProductMode ? 'Belum ada pertanyaan seputar produk ini' : 'Belum ada komentar'}
              </p>
              <p className="text-neutral-400 text-xs">
                {isProductMode
                  ? 'Gunakan tombol Tanya di bawah untuk menanyakan stok atau detail!'
                  : 'Jadilah yang pertama memberi tanggapan!'}
              </p>
            </div>
          )}
        </section>
      </main>

      {/* MODE 1: Floating Action Dock for Marketplace Product Posts */}
      {isProductMode ? (
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

          <AskSellerBottomSheet
            key={`ask-${post.id}`}
            isOpen={isAskSheetOpen}
            post={post}
            onClose={() => setIsAskSheetOpen(false)}
            onSubmitQuestion={(text) => handleAddComment(text)}
          />
        </>
      ) : (
        /* MODE 2: Docked Bottom Bar ala Threads / X for Discussion / Utas Posts */
        <CommentInputBar
          targetAuthor={post.seller.username || post.seller.name}
          replyToUser={replyingToUsername}
          onCancelReply={() => setReplyToCommentId(null)}
          onSubmitComment={(text) => handleAddComment(text, replyToCommentId || undefined)}
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
