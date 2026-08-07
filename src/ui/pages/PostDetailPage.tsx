import React, { useState, useEffect } from 'react';
import { ArrowLeft, MoreHorizontal } from 'lucide-react';
import { MarketThreadItem, ThreadComment } from '@/types/marketFeed';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { ThreadCommentItem } from '../components/marketplace/ThreadCommentItem';
import { CommentInputBar } from '../components/marketplace/CommentInputBar';

interface PostDetailPageProps {
  post: MarketThreadItem;
  onBack: () => void;
  onAddToCart?: (item: MarketThreadItem) => void;
}

export const PostDetailPage: React.FC<PostDetailPageProps> = ({
  post,
  onBack,
  onAddToCart,
}) => {
  const [comments, setComments] = useState<ThreadComment[]>(post.comments || []);
  const [replyToUser, setReplyToUser] = useState<string | null>(null);

  // Scroll to top on mount
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  const handleAddComment = (content: string) => {
    const newComment: ThreadComment = {
      id: `comment-${Date.now()}`,
      postId: post.id,
      user: {
        id: 'user-current',
        name: 'Saya (Pembeli)',
        username: 'pembeli_snapan',
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
        classGroup: 'XII PPLG 1',
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
  };

  return (
    <div className="min-h-screen bg-pure-white pb-24 font-gt-standard">
      {/* Top Header Bar: [Left: ← Back Button] --- [Center: Postingan] --- [Right: Options] */}
      <header className="sticky top-0 z-40 bg-white/90 backdrop-blur-md border-b border-neutral-200 px-4 h-14 flex items-center justify-between max-w-xl mx-auto">
        <button
          type="button"
          onClick={onBack}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-95"
          aria-label="Kembali ke Feed Utama"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
        </button>

        <h1 className="font-semibold text-base text-slate-900">Postingan</h1>

        <button
          type="button"
          className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-500 hover:text-slate-900 transition-colors cursor-pointer"
          aria-label="Opsi Postingan"
        >
          <MoreHorizontal className="w-5 h-5" />
        </button>
      </header>

      {/* Main Content Area */}
      <main className="max-w-xl mx-auto pt-2 sm:pt-3">
        {/* Focused Main Post Card */}
        <MarketPostCard
          item={post}
          onAddToCart={onAddToCart}
          variant="detail"
        />

        {/* Threaded Comments Section */}
        <section className="px-4 pt-2">
          {/* Section Divider Header */}
          <div className="py-2.5 border-b border-neutral-100 flex items-center justify-between">
            <h2 className="font-semibold text-sm text-slate-900">
              Komentar ({comments.length})
            </h2>
            <span className="text-xs text-neutral-400">Urutkan dari Terbaru</span>
          </div>

          {/* Comment List with Threads Vertical Lines */}
          {comments.length > 0 ? (
            <div className="divide-y divide-neutral-100">
              {comments.map((comment) => (
                <ThreadCommentItem
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

      {/* Sticky Bottom Reply Input Bar */}
      <CommentInputBar
        replyToUser={replyToUser}
        onSubmitComment={handleAddComment}
      />
    </div>
  );
};
