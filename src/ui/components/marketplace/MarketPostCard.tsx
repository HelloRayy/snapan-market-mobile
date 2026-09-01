import React, { useState } from 'react';
import { MapPin } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { ToastNotification } from '@/ui/components/ui/ToastNotification';
import { MediaLightboxModal } from './MediaLightboxModal';
import { PostSubmenuDropdown } from './PostSubmenuDropdown';
import { togglePostBookmark } from '@/services/api/bookmarkService';
import { triggerHaptic } from '@/utils/haptics';
import { PostCardHeader } from './post-card/PostCardHeader';
import { PostCardMediaGallery } from './post-card/PostCardMediaGallery';
import { PostCardActionBar } from './post-card/PostCardActionBar';

interface MarketPostCardProps {
  item: MarketPostItem;
  onAddToCart?: (item: MarketPostItem) => void;
  onPostClick?: (item: MarketPostItem) => void;
  onTopicClick?: (topic: string) => void;
  onUserClick?: (username: string) => void;
  variant?: 'feed' | 'detail';
}

export const MarketPostCard: React.FC<MarketPostCardProps> = ({
  item,
  onAddToCart: _onAddToCart,
  onPostClick,
  onTopicClick,
  onUserClick,
  variant = 'feed',
}) => {
  const [isLiked, setIsLiked] = useState(item.isLiked || false);
  const [likesCount, setLikesCount] = useState(item.likesCount);

  const [isReposted, setIsReposted] = useState(item.isReposted || false);
  const [repostsCount, setRepostsCount] = useState(item.repostsCount || 0);

  const [isSaved, setIsSaved] = useState(item.isSaved || false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const [isLightboxOpen, setIsLightboxOpen] = useState(false);
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);

  const showToast = (msg: string) => {
    setToastMessage(msg);
  };

  const handleBookmarkToggle = async (e?: React.MouseEvent) => {
    e?.stopPropagation();
    setIsMenuOpen(false);
    const nextState = !isSaved;
    setIsSaved(nextState);
    showToast(nextState ? 'Postingan disimpan ke markah' : 'Dihapus dari markah');

    try {
      if (item.id && item.seller?.id) {
        await togglePostBookmark(item.id, item.seller.id, !nextState);
      }
    } catch {}
  };

  const handleLikeToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('light');
    if (isLiked) {
      setIsLiked(false);
      setLikesCount((prev) => Math.max(0, prev - 1));
    } else {
      setIsLiked(true);
      setLikesCount((prev) => prev + 1);
    }
  };

  const handleRepostToggle = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('medium');
    if (isReposted) {
      setIsReposted(false);
      setRepostsCount((prev) => Math.max(0, prev - 1));
      showToast('Batal diposting ulang');
    } else {
      setIsReposted(true);
      setRepostsCount((prev) => prev + 1);
      showToast('Postingan berhasil diposting ulang');
    }
  };

  const handleShare = async (e?: React.MouseEvent) => {
    e?.stopPropagation();
    triggerHaptic('light');
    const authorHandle = item.seller.username || item.seller.name.toLowerCase().replace(/\s+/g, '') || 'post';
    const shareUrl = `${window.location.origin}/@${authorHandle.replace(/^@/, '')}/post/${item.id}`;
    const shareText = item.price
      ? `🛍️ ${item.caption}\n💰 Rp ${item.price.toLocaleString('id-ID')}\n👤 Penjual: ${item.seller.name} (@${authorHandle})`
      : `🧵 ${item.caption}\n👤 Oleh: ${item.seller.name} (@${authorHandle})`;

    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({
          title: item.title || 'Snapan Market',
          text: shareText,
          url: shareUrl,
        });
      } catch {}
    } else {
      try {
        await navigator.clipboard.writeText(shareUrl);
        showToast('Tautan postingan berhasil disalin');
      } catch {
        showToast('Tautan disalin ke papan klip');
      }
    }
  };

  const handleImageClick = (idx: number) => {
    setSelectedImageIndex(idx);
    setIsLightboxOpen(true);
  };

  return (
    <article
      onClick={() => onPostClick?.(item)}
      className={`w-full border-b border-neutral-200 bg-pure-white hover:bg-neutral-50/50 transition-colors cursor-pointer font-gt-standard select-none overflow-x-hidden feed-card-perf ${
        variant === 'detail' ? 'px-3.5 pt-3 pb-3.5' : 'px-3.5 py-3'
      }`}
    >
      {variant === 'detail' ? (
        /* DETAIL PAGE VARIANT */
        <div className="space-y-2.5">
          <PostCardHeader
            item={item}
            onUserClick={onUserClick}
            onTopicClick={onTopicClick}
            onToggleMenu={(e) => {
              e.stopPropagation();
              setIsMenuOpen((prev) => !prev);
            }}
            isMenuOpen={isMenuOpen}
            variant="detail"
          />

          <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere]">
            <FormattedText text={item.caption} />
            {item.totalThreadParts && item.totalThreadParts > 1 && (
              <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11px] tabular-nums select-none ml-1.5 align-middle">
                1/{item.totalThreadParts}
              </span>
            )}
          </div>

          <PostCardMediaGallery
            images={item.images}
            caption={item.caption}
            onImageClick={handleImageClick}
            isDetail={true}
          />

          {item.locationTag && (
            <div className="pt-1 flex items-center gap-1.5 text-[12px] sm:text-[12.5px] text-slate-600 font-medium leading-snug">
              <MapPin className="w-3.5 h-3.5 text-slate-500 stroke-[2] shrink-0" />
              <span className="truncate">{item.locationTag}</span>
            </div>
          )}

          <PostCardActionBar
            item={item}
            isLiked={isLiked}
            likesCount={likesCount}
            onToggleLike={handleLikeToggle}
            isReposted={isReposted}
            repostsCount={repostsCount}
            onToggleRepost={handleRepostToggle}
            onCommentClick={(e) => {
              e.stopPropagation();
              onPostClick?.(item);
            }}
            onShare={handleShare}
          />
        </div>
      ) : (
        /* FEED VARIANT */
        <div className="flex gap-3 items-start min-w-0">
          <div className="flex flex-col items-center shrink-0">
            <div
              onClick={(e) => {
                e.stopPropagation();
                onUserClick?.(item.seller.username || item.seller.name);
              }}
              className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 cursor-pointer active:scale-95 transition-transform"
            >
              <img
                src={item.seller.avatar}
                alt={item.seller.name}
                loading="lazy"
                decoding="async"
                className="w-full h-full object-cover"
              />
            </div>
          </div>

          <div className="flex-1 min-w-0 space-y-1 overflow-visible">
            <PostCardHeader
              item={item}
              onUserClick={onUserClick}
              onTopicClick={onTopicClick}
              onToggleMenu={(e) => {
                e.stopPropagation();
                setIsMenuOpen((prev) => !prev);
              }}
              isMenuOpen={isMenuOpen}
              variant="feed"
            />

            <div className="text-base text-slate-900 font-normal leading-snug break-words [overflow-wrap:anywhere]">
              <FormattedText text={item.caption} />
              {item.totalThreadParts && item.totalThreadParts > 1 && (
                <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11px] tabular-nums select-none ml-1.5 align-middle">
                  1/{item.totalThreadParts}
                </span>
              )}
            </div>

            <PostCardMediaGallery
              images={item.images}
              caption={item.caption}
              onImageClick={handleImageClick}
              isDetail={false}
            />

            {item.locationTag && (
              <div className="pt-1 flex items-center gap-1.5 text-[12px] sm:text-[12.5px] text-slate-600 font-medium leading-snug">
                <MapPin className="w-3.5 h-3.5 text-slate-500 stroke-[2] shrink-0" />
                <span className="truncate">{item.locationTag}</span>
              </div>
            )}

            <PostCardActionBar
              item={item}
              isLiked={isLiked}
              likesCount={likesCount}
              onToggleLike={handleLikeToggle}
              isReposted={isReposted}
              repostsCount={repostsCount}
              onToggleRepost={handleRepostToggle}
              onCommentClick={(e) => {
                e.stopPropagation();
                onPostClick?.(item);
              }}
              onShare={handleShare}
            />
          </div>
        </div>
      )}

      {/* Submenu Dropdown */}
      <PostSubmenuDropdown
        isOpen={isMenuOpen}
        onClose={() => setIsMenuOpen(false)}
        authorName={item.seller.name}
        authorUsername={item.seller.username}
        isSaved={isSaved}
        onToggleSave={handleBookmarkToggle}
        onCopyLink={handleShare}
        onReport={() => {
          showToast('Laporan terkirim, terima kasih atas masukan Anda');
        }}
        align="right"
        menuId={`post-options-menu-${item.id}`}
        triggerId={`post-options-btn-${item.id}`}
      />

      {/* Lightbox Modal */}
      <MediaLightboxModal
        isOpen={isLightboxOpen}
        images={item.images || []}
        initialIndex={selectedImageIndex}
        onClose={() => setIsLightboxOpen(false)}
        caption={item.caption}
        likesCount={likesCount}
        repliesCount={item.commentsCount}
        repostsCount={repostsCount}
        isLiked={isLiked}
        isReposted={isReposted}
        onLike={() => {
          if (isLiked) {
            setIsLiked(false);
            setLikesCount((prev) => prev - 1);
          } else {
            setIsLiked(true);
            setLikesCount((prev) => prev + 1);
          }
        }}
        onComment={() => {
          setIsLightboxOpen(false);
          onPostClick?.(item);
        }}
        onRepost={() => {
          if (isReposted) {
            setIsReposted(false);
            setRepostsCount((prev) => Math.max(0, prev - 1));
            showToast('Batal diposting ulang');
          } else {
            setIsReposted(true);
            setRepostsCount((prev) => prev + 1);
            showToast('Postingan berhasil diposting ulang');
          }
        }}
        onShare={() => {
          const shareUrl = window.location.href;
          if (navigator.share) {
            navigator.share({
              title: item.title || 'Snapan Market',
              text: `Cek postingan ${item.seller.name} di Snapan Market!`,
              url: shareUrl,
            }).catch(() => {});
          } else {
            navigator.clipboard.writeText(shareUrl).then(() => {
              showToast('Tautan postingan berhasil disalin');
            }).catch(() => {});
          }
        }}
      />

      {/* Toast */}
      <ToastNotification
        message={toastMessage}
        onClose={() => setToastMessage(null)}
      />
    </article>
  );
};
