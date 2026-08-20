import React, { useState, useEffect } from 'react';
import { ArrowLeft } from 'lucide-react';
import { MarketPostItem, PostComment } from '@/types/marketFeed';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { PostCommentItem } from '../components/marketplace/PostCommentItem';
import { CommentInputBar } from '../components/marketplace/CommentInputBar';
import { StickyBuyBar } from '../components/marketplace/StickyBuyBar';
import { BuyBottomSheet } from '../components/marketplace/BuyBottomSheet';

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
  const [comments, setComments] = useState<PostComment[]>(post.comments || []);
  const [replyToUser, setReplyToUser] = useState<string | null>(null);
  const [isBuySheetOpen, setIsBuySheetOpen] = useState(false);

  const containerRef = React.useRef<HTMLDivElement>(null);

  // Sync comments & reset scroll of detail page container on post prop change
  useEffect(() => {
    if (containerRef.current) {
      containerRef.current.scrollTop = 0;
    }
    setComments(post.comments || []);
    setReplyToUser(null);
    setIsBuySheetOpen(false);
  }, [post.id, post.comments]);

  const handleAddComment = (content: string) => {
    const newComment: PostComment = {
      id: `comment-${Date.now()}`,
      postId: post.id,
      user: {
        id: 'user-current',
        name: 'Rinia Safitri',
        username: 'rinia2812',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: 'XII DKV 2',
        isVerified: false,
      },
      content: replyToUser ? `@${replyToUser} ${content}` : content,
      timestamp: 'Baru saja',
      likesCount: 0,
      isLiked: false,
    };

    setComments((prev) => [newComment, ...prev]);
    setReplyToUser(null);
  };

  const handleReplyClick = (username: string) => {
    setReplyToUser(username);
    const inputEl = document.getElementById('comment-input-field');
    if (inputEl) {
      inputEl.focus();
    }
  };

  const handleChatClick = () => {
    const sellerUsername = post.seller.username || post.seller.name;
    setReplyToUser(sellerUsername);
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

  return (
    <div
      ref={containerRef}
      className="h-full w-full overflow-y-auto overscroll-contain bg-white pb-36 font-gt-standard"
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

        {/* Comments Section */}
        <section id="comments-section" className="px-4 pt-2">
          {/* Section Divider Header */}
          <div className="py-2.5 flex items-center justify-between">
            <h2 className="font-semibold text-sm text-slate-900">
              Komentar ({comments.length})
            </h2>
            <span className="text-xs text-neutral-400">Urutkan dari Terbaru</span>
          </div>

          {/* In-Page Inline Comment Input Field (under Komentar Header) */}
          <CommentInputBar
            replyToUser={replyToUser}
            onSubmitComment={handleAddComment}
            isInline={true}
          />

          {/* Comment List */}
          {comments.length > 0 ? (
            <div className="divide-y divide-neutral-200">
              {comments.map((comment) => (
                <PostCommentItem
                  key={comment.id}
                  comment={comment}
                  onReplyClick={handleReplyClick}
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
    </div>
  );
};
