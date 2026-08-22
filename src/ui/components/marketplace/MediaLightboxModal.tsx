import React, { useState, useRef, useEffect } from 'react';
import { X, Volume2, VolumeX, Heart, MessageCircle, Repeat2, Send } from 'lucide-react';

interface MediaLightboxModalProps {
  isOpen: boolean;
  images: string[];
  initialIndex?: number;
  onClose: () => void;
  caption?: string;
  isVideo?: boolean;
  likesCount?: number;
  repliesCount?: number;
  repostsCount?: number;
  isLiked?: boolean;
  isReposted?: boolean;
  onLike?: () => void;
  onComment?: () => void;
  onRepost?: () => void;
  onShare?: () => void;
}

export const MediaLightboxModal: React.FC<MediaLightboxModalProps> = ({
  isOpen,
  images,
  initialIndex = 0,
  onClose,
  caption,
  isVideo = false,
  likesCount,
  repliesCount,
  repostsCount,
  isLiked = false,
  isReposted = false,
  onLike,
  onComment,
  onRepost,
  onShare,
}) => {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [isMuted, setIsMuted] = useState(true);
  const [zoomLevel, setZoomLevel] = useState<number>(1);

  // Drag to dismiss state
  const [dragY, setDragY] = useState(0);

  const scrollRef = useRef<HTMLDivElement>(null);
  const touchStartXRef = useRef<number>(0);
  const touchStartYRef = useRef<number>(0);
  const isVerticalSwipeRef = useRef<boolean>(false);

  // Reset transform state on slide/open change
  useEffect(() => {
    setCurrentIndex(initialIndex);
    setDragY(0);
    setZoomLevel(1);
  }, [initialIndex, isOpen]);

  useEffect(() => {
    if (isOpen && scrollRef.current) {
      const slideWidth = scrollRef.current.offsetWidth;
      scrollRef.current.scrollLeft = initialIndex * slideWidth;
    }
  }, [isOpen, initialIndex]);

  // Lock body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  if (!isOpen || !images || images.length === 0) return null;

  const handleScroll = () => {
    if (!scrollRef.current) return;
    const slideWidth = scrollRef.current.offsetWidth;
    const index = Math.round(scrollRef.current.scrollLeft / slideWidth);
    if (index !== currentIndex && index >= 0 && index < images.length) {
      setCurrentIndex(index);
      setZoomLevel(1);
    }
  };

  const scrollToImage = (index: number) => {
    if (!scrollRef.current) return;
    const slideWidth = scrollRef.current.offsetWidth;
    scrollRef.current.scrollTo({
      left: index * slideWidth,
      behavior: 'smooth',
    });
    setCurrentIndex(index);
    setZoomLevel(1);
  };

  // Touch Handlers for Vertical Swipe to Dismiss (Angle-Locked)
  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      touchStartXRef.current = e.touches[0].clientX;
      touchStartYRef.current = e.touches[0].clientY;
      isVerticalSwipeRef.current = false;
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (e.touches.length === 1 && zoomLevel === 1) {
      const deltaX = Math.abs(e.touches[0].clientX - touchStartXRef.current);
      const deltaY = e.touches[0].clientY - touchStartYRef.current;
      const absY = Math.abs(deltaY);

      // If user is swiping horizontally to next photo (deltaX > absY), lock vertical drag!
      if (!isVerticalSwipeRef.current && deltaX > absY && deltaX > 8) {
        setDragY(0);
        return;
      }

      // Only trigger vertical drag to dismiss if Y movement is distinctly dominant over X
      if (absY > deltaX * 1.3 && absY > 12) {
        isVerticalSwipeRef.current = true;
        setDragY(deltaY);
      }
    }
  };

  const handleTouchEnd = () => {
    if (isVerticalSwipeRef.current && Math.abs(dragY) > 130) {
      onClose();
    }
    setDragY(0);
    isVerticalSwipeRef.current = false;
  };

  const opacity = Math.max(0.3, 1 - Math.abs(dragY) / 350);

  const handleClose = (e: React.MouseEvent) => {
    e.stopPropagation();
    onClose();
  };

  return (
    <div
      onClick={(e) => e.stopPropagation()}
      onPointerDown={(e) => e.stopPropagation()}
      style={{
        backgroundColor: `rgba(255, 255, 255, ${0.98 * opacity})`,
        transform: `translateY(${dragY}px)`,
        opacity: opacity,
      }}
      className="fixed inset-0 z-[100] backdrop-blur-2xl flex flex-col justify-between overflow-hidden select-none font-gt-standard text-slate-900 bg-white/95"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Top Bar: Clean Light Circular Close Button + Counter Badge */}
      <div className="relative z-50 flex items-center justify-between px-5 pt-5 pb-2 max-w-xl mx-auto w-full">
        {/* Top-Left: Circular Button h-11 w-11 */}
        <button
          type="button"
          onClick={handleClose}
          className="flex items-center justify-center rounded-full h-11 w-11 bg-white hover:bg-neutral-100 active:scale-90 text-slate-900 border border-neutral-200/90 shadow-xs transition-transform cursor-pointer select-none"
          aria-label="Tutup Media"
        >
          <X className="w-5 h-5 text-slate-900 stroke-[2.2]" />
        </button>

        {/* Top-Right: Counter Badge for Multi-Image */}
        {images.length > 1 && (
          <div className="h-9 px-3.5 rounded-full bg-white/95 border border-neutral-200/90 backdrop-blur-md text-slate-800 text-xs font-semibold flex items-center shadow-2xs tabular-nums">
            {currentIndex + 1} / {images.length}
          </div>
        )}
      </div>

      {/* Main Fullscreen Gallery Slider */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className="flex-1 w-full max-w-xl mx-auto flex items-center overflow-x-auto snap-x snap-mandatory scrollbar-none cursor-grab active:cursor-grabbing touch-pan-x touch-pan-y"
      >
        {images.map((imgUrl, idx) => (
          <div
            key={idx}
            className="w-full h-full shrink-0 flex items-center justify-center snap-center p-3 relative overflow-hidden"
          >
            <picture className="max-h-[82vh] max-w-full flex items-center justify-center">
              <img
                src={imgUrl}
                alt={caption || `Media Preview ${idx + 1}`}
                style={{
                  transform: zoomLevel > 1 ? `scale(${zoomLevel})` : undefined,
                }}
                className="max-h-[82vh] max-w-full h-auto w-auto object-contain rounded-[18px] border border-black/[0.06] shadow-xl pointer-events-none select-none transition-transform duration-300 bg-white"
              />
            </picture>
          </div>
        ))}
      </div>

      {/* Bottom Floating Glass Capsule Bar (Icon-Only Social & Utility Controls in Light Theme) */}
      <div className="relative z-50 flex items-center justify-center px-4 pb-8 pt-2 max-w-xl mx-auto w-full">
        <div className="flex items-center gap-x-1.5 sm:gap-x-2 bg-white/95 backdrop-blur-xl border border-neutral-200/90 px-3.5 py-1.5 rounded-full shadow-lg text-slate-700 select-none">
          {/* 1. Love / Like Button with Count */}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onLike?.();
            }}
            className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer ${
              isLiked ? 'text-rose-500' : 'text-slate-700 hover:text-slate-900'
            }`}
            title="Sukai foto"
          >
            <Heart className={`w-4 h-4 ${isLiked ? 'fill-current stroke-rose-500' : 'stroke-[2]'}`} />
            {typeof likesCount === 'number' && (
              <span className="text-[13px] font-semibold tabular-nums">{likesCount}</span>
            )}
          </button>

          {/* 2. Comment Button with Count */}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onClose();
              onComment?.();
            }}
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-full hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer text-slate-700 hover:text-slate-900"
            title="Komentari"
          >
            <MessageCircle className="w-4 h-4 stroke-[2]" />
            {typeof repliesCount === 'number' && (
              <span className="text-[13px] font-semibold tabular-nums">{repliesCount}</span>
            )}
          </button>

          {/* 3. Repost Button with Count */}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onRepost?.();
            }}
            className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer ${
              isReposted ? 'text-emerald-500' : 'text-slate-700 hover:text-slate-900'
            }`}
            title="Repost"
          >
            <Repeat2 className="w-4 h-4 stroke-[2.2]" />
            {typeof repostsCount === 'number' && (
              <span className="text-[13px] font-semibold tabular-nums">{repostsCount}</span>
            )}
          </button>

          {/* 4. Share Button */}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              onShare?.();
            }}
            className="flex items-center justify-center p-2 rounded-full hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer text-slate-700 hover:text-slate-900"
            title="Bagikan"
          >
            <Send className="w-4 h-4 stroke-[2]" />
          </button>

          {/* Separator */}
          <span className="w-px h-4 bg-neutral-200 mx-0.5" />

          {/* 5. Zoom Scale Preset (1x / 1.5x / 2x) */}
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              setZoomLevel((prev) => (prev === 1 ? 1.5 : prev === 1.5 ? 2 : 1));
            }}
            className="px-2.5 py-1 rounded-full hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer text-xs font-bold text-slate-800 tabular-nums"
            title="Ubah perbesaran"
          >
            {zoomLevel}x
          </button>

          {/* 6. Multi-image Pagination Dots (if multi images) */}
          {images.length > 1 && (
            <>
              <span className="w-px h-4 bg-neutral-200 mx-0.5" />
              <div className="flex items-center gap-1.5 px-1.5">
                {images.map((_, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      scrollToImage(idx);
                    }}
                    className={`cursor-pointer transition-all ${
                      currentIndex === idx
                        ? 'w-4 h-1.5 rounded-full bg-slate-900'
                        : 'w-1.5 h-1.5 rounded-full bg-neutral-300 hover:bg-neutral-400'
                    }`}
                    aria-label={`Ke gambar ${idx + 1}`}
                  />
                ))}
              </div>
            </>
          )}

          {/* 7. Audio Mute Toggle (if Video) */}
          {isVideo && (
            <>
              <span className="w-px h-4 bg-neutral-200 mx-0.5" />
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  setIsMuted(!isMuted);
                }}
                className="p-2 rounded-full hover:bg-neutral-100 active:scale-90 transition-all cursor-pointer text-slate-700 hover:text-slate-900"
              >
                {isMuted ? (
                  <VolumeX className="w-4 h-4 text-neutral-400" />
                ) : (
                  <Volume2 className="w-4 h-4 text-[#1d64ec]" />
                )}
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};
