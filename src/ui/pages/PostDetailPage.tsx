import React, { useState, useEffect } from 'react';
import { ArrowLeft } from 'lucide-react';
import { MarketPostItem, PostComment } from '@/types/marketFeed';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { PostCommentItem } from '../components/marketplace/PostCommentItem';
import { CommentInputBar } from '../components/marketplace/CommentInputBar';
import { StickyBuyBar } from '../components/marketplace/StickyBuyBar';
import { BuyBottomSheet } from '../components/marketplace/BuyBottomSheet';
import { CommentDetailPage } from '../components/marketplace/CommentDetailPage';
import { useAuth } from '../hooks/useAuth';

interface PostDetailPageProps {
  post: MarketPostItem;
  onBack: () => void;
  onAddToCart?: (item: MarketPostItem) => void;
}

export const PostDetailPage: React.FC<PostDetailPageProps> = ({
  post,
  onBack,
  onAddToCart,
}) => {
  const { profile } = useAuth();
  const [comments, setComments] = useState<PostComment[]>(post.comments || []);
  const [replyToCommentId, setReplyToCommentId] = useState<string | null>(null);
  const [focusedComment, setFocusedComment] = useState<PostComment | null>(null);
  const [isBuySheetOpen, setIsBuySheetOpen] = useState(false);

  const containerRef = React.useRef<HTMLDivElement>(null);

  // Smooth reset & scroll to top when opening post detail
  useEffect(() => {
    if (containerRef.current) {
      containerRef.current.scrollTop = 0;
    }
    setComments(post.comments || []);
    setReplyToCommentId(null);
    setFocusedComment(null);
    setIsBuySheetOpen(false);
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
    setReplyToCommentId(commentId || null);
  };

  const handleChatClick = () => {
    setReplyToCommentId(null);
    const commentsSection = document.getElementById('comments-section');
    if (commentsSection) {
      commentsSection.scrollIntoView({ behavior: 'smooth' });
    }
    setTimeout(() => {
      const inputEl = document.getElementById('comment-input-field');
      if (inputEl) {
        inputEl.focus();
      }
    }, 300);
  };

  const handleBuyClick = () => {
    setIsBuySheetOpen(true);
    onAddToCart?.(post);
  };

  const userAvatar =
    profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';

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
          variant="detail"
        />

        {/* Comments Section (Includes Author Thread Continuations 2/N, 3/N at top) */}
        <section id="comments-section" className="px-4 pt-2">
          {/* Section Divider Header */}
          <div className="py-2.5 flex items-center justify-between">
            <h2 className="font-semibold text-sm text-slate-900">
              Komentar ({post.threadChain && post.threadChain.length > 0 ? comments.length + post.threadChain.length : comments.length})
            </h2>
            <span className="text-xs text-neutral-400">Urutkan dari Terbaru</span>
          </div>

          {/* In-Page Inline Comment Input Field for Root Comments to Post */}
          <CommentInputBar
            targetAuthor={post.seller.username || post.seller.name}
            onSubmitComment={(text) => handleAddComment(text)}
            isInline={true}
          />

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
              <p className="text-slate-600 font-medium text-sm">Belum ada komentar</p>
              <p className="text-neutral-400 text-xs">Jadilah yang pertama bertanya/memberi tanggapan!</p>
            </div>
          )}
        </section>
      </main>

      {/* Floating Pill Buy Bar & Modal (ONLY for Marketplace Product Posts, NEVER for Utas) */}
      {post.postType === 'product' && !!post.price && post.price > 0 && (
        <>
          <StickyBuyBar
            price={post.price || 0}
            stockCount={post.stock || 1}
            onBuyClick={handleBuyClick}
            onChatClick={handleChatClick}
          />

          <BuyBottomSheet
            key={post.id}
            isOpen={isBuySheetOpen}
            post={post}
            onClose={() => setIsBuySheetOpen(false)}
          />
        </>
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
