import React, { useState, useRef, useEffect } from 'react';
import { X, Volume2, VolumeX, Heart, MessageCircle, Repeat2, Send, ChevronLeft, ChevronRight } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

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
  const isProgrammaticScrollRef = useRef<boolean>(false);
  const scrollTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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

  // Clean up timers on unmount
  useEffect(() => {
    return () => {
      if (scrollTimeoutRef.current) {
        clearTimeout(scrollTimeoutRef.current);
      }
    };
  }, []);

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
    if (!scrollRef.current || isProgrammaticScrollRef.current) return;
    const slideWidth = scrollRef.current.offsetWidth;
    if (!slideWidth) return;
    const index = Math.round(scrollRef.current.scrollLeft / slideWidth);
    if (index !== currentIndex && index >= 0 && index < images.length) {
      setCurrentIndex(index);
      setZoomLevel(1);
    }
  };

  const scrollToImage = (index: number) => {
    if (!scrollRef.current) return;
    const targetIndex = Math.max(0, Math.min(images.length - 1, index));
    const slideWidth = scrollRef.current.offsetWidth;
    if (!slideWidth) return;

    triggerHaptic('selection');
    isProgrammaticScrollRef.current = true;
    setCurrentIndex(targetIndex);
    setZoomLevel(1);

    scrollRef.current.scrollTo({
      left: targetIndex * slideWidth,
      behavior: 'smooth',
    });

    if (scrollTimeoutRef.current) clearTimeout(scrollTimeoutRef.current);
    scrollTimeoutRef.current = setTimeout(() => {
      isProgrammaticScrollRef.current = false;
    }, 450);
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
    if (isVerticalSwipeRef.current && Math.abs(dragY) > 120) {
      triggerHaptic('light');
      onClose();
    }
    setDragY(0);
    isVerticalSwipeRef.current = false;
  };

  const opacity = Math.max(0.4, 1 - Math.abs(dragY) / 320);

  const handleClose = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('light');
    onClose();
  };

  return (
    <div
      onClick={(e) => e.stopPropagation()}
      onPointerDown={(e) => e.stopPropagation()}
      style={{
        transform: `translateY(${dragY}px)`,
        opacity: opacity,
      }}
      className="fixed inset-0 z-[99999] bg-white flex flex-col justify-between overflow-hidden select-none font-gt-standard text-slate-900"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Top Bar: Clean Light Circular Close Button + Counter Badge (With Notch Safe Area) */}
      <div
        className="relative z-50 flex items-center justify-between px-4 max-w-xl mx-auto w-full"
        style={{
          paddingTop: 'calc(14px + env(safe-area-inset-top, 0px))',
          paddingBottom: '8px',
        }}
      >
        {/* Top-Left: Circular Close Button */}
        <button
          type="button"
          onClick={handleClose}
          className="flex items-center justify-center rounded-full h-10 w-10 bg-white hover:bg-neutral-100 active:scale-90 text-slate-900 border border-neutral-200/90 shadow-2xs transition-transform cursor-pointer select-none"
          aria-label="Tutup Media"
        >
          <X className="w-5 h-5 text-slate-900 stroke-[2.2]" />
        </button>

        {/* Top-Right: Counter Badge for Multi-Image */}
        {images.length > 1 && (
          <div className="h-8 px-3 rounded-full bg-neutral-100/90 border border-neutral-200/80 text-slate-800 text-xs font-semibold flex items-center shadow-2xs tabular-nums">
            {currentIndex + 1} / {images.length}
          </div>
        )}
      </div>

      {/* Main Fullscreen Gallery Slider (Full Frame Object-Contain Zero-Crop) */}
      <div className="relative flex-1 w-full flex items-center justify-center overflow-hidden min-h-0">
        {/* Left Floating Arrow Button (Rendered only if not on first slide: currentIndex > 0) */}
        {images.length > 1 && currentIndex > 0 && (
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              scrollToImage(currentIndex - 1);
            }}
            className="absolute left-3 z-40 flex items-center justify-center bg-white/95 text-slate-800 text-base rounded-full h-10 w-10 leading-snug cursor-pointer border border-neutral-200/90 shadow-md backdrop-blur-md hover:bg-white hover:scale-105 active:scale-90 transition-all select-none"
            aria-label="Kembali"
            title="Kembali"
          >
            <ChevronLeft className="w-5 h-5 stroke-[2.2] text-slate-800" />
          </button>
        )}

        {/* Right Floating Arrow Button (Rendered only if not on last slide: currentIndex < images.length - 1) */}
        {images.length > 1 && currentIndex < images.length - 1 && (
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              scrollToImage(currentIndex + 1);
            }}
            className="absolute right-3 z-40 flex items-center justify-center bg-white/95 text-slate-800 text-base rounded-full h-10 w-10 leading-snug cursor-pointer border border-neutral-200/90 shadow-md backdrop-blur-md hover:bg-white hover:scale-105 active:scale-90 transition-all select-none"
            aria-label="Lanjutkan"
            title="Lanjutkan"
          >
            <ChevronRight className="w-5 h-5 stroke-[2.2] text-slate-800" />
          </button>
        )}

        {/* Scroll Container */}
        <div
          ref={scrollRef}
          onScroll={handleScroll}
          className="w-full h-full flex items-center overflow-x-auto snap-x snap-mandatory scrollbar-none cursor-grab active:cursor-grabbing touch-pan-x touch-pan-y"
        >
          {images.map((imgUrl, idx) => (
            <div
              key={idx}
              className="w-full h-full shrink-0 flex items-center justify-center snap-center p-2 relative overflow-hidden"
              onDoubleClick={() => {
                triggerHaptic('selection');
                setZoomLevel((prev) => (prev === 1 ? 2 : 1));
              }}
            >
              <div className="relative w-full h-full max-h-[80vh] flex items-center justify-center overflow-hidden">
                <img
                  src={imgUrl}
                  alt={caption || `Media Preview ${idx + 1}`}
                  style={{
                    transform: zoomLevel > 1 ? `scale(${zoomLevel})` : undefined,
                  }}
                  className="max-w-full max-h-full w-auto h-auto object-contain select-none pointer-events-none transition-transform duration-300"
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom Floating Glass Capsule Bar (With Home Indicator Safe Area) */}
      <div
        className="relative z-50 flex items-center justify-center px-4 pt-2 max-w-xl mx-auto w-full"
        style={{
          paddingBottom: 'calc(20px + env(safe-area-inset-bottom, 0px))',
        }}
      >
        <div className="flex items-center gap-x-1 sm:gap-x-1.5 bg-white/95 backdrop-blur-xl border border-neutral-200/90 px-3.5 py-1.5 rounded-full shadow-lg text-slate-700 select-none">
          {/* Group 1: Social Engagement Actions (Love, Comment, Repost, Share) */}
          <div className="flex items-center gap-x-0.5 sm:gap-x-1">
            {/* 1. Love / Like */}
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                triggerHaptic(isLiked ? 'light' : 'medium');
                onLike?.();
              }}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-full hover:bg-neutral-100 active:scale-92 transition-all cursor-pointer group"
              title="Sukai foto"
            >
              <Heart
                className={`w-4 h-4 transition-transform group-hover:scale-110 ${
                  isLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'stroke-[2] text-slate-700'
                }`}
              />
              {typeof likesCount === 'number' && (
                <span className="text-[13px] font-semibold text-slate-800 tabular-nums leading-none">
                  {likesCount}
                </span>
              )}
            </button>

            {/* 2. Comment / Reply */}
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                triggerHaptic('light');
                onClose();
                onComment?.();
              }}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-full hover:bg-neutral-100 active:scale-92 transition-all cursor-pointer text-slate-700 hover:text-slate-900 group"
              title="Komentari"
            >
              <MessageCircle className="w-4 h-4 stroke-[2] transition-transform group-hover:scale-110" />
              {typeof repliesCount === 'number' && (
                <span className="text-[13px] font-semibold text-slate-800 tabular-nums leading-none">
                  {repliesCount}
                </span>
              )}
            </button>

            {/* 3. Repost */}
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                triggerHaptic('medium');
                onRepost?.();
              }}
              className="flex items-center gap-1.5 px-2.5 py-1.5 rounded-full hover:bg-neutral-100 active:scale-92 transition-all cursor-pointer group"
              title="Repost"
            >
              <Repeat2
                className={`w-4 h-4 stroke-[2.2] transition-transform group-hover:scale-110 ${
                  isReposted ? 'text-emerald-500' : 'text-slate-700'
                }`}
              />
              {typeof repostsCount === 'number' && (
                <span className="text-[13px] font-semibold text-slate-800 tabular-nums leading-none">
                  {repostsCount}
                </span>
              )}
            </button>

            {/* 4. Share */}
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                triggerHaptic('light');
                onShare?.();
              }}
              className="flex items-center justify-center p-2 rounded-full hover:bg-neutral-100 active:scale-92 transition-all cursor-pointer text-slate-700 hover:text-slate-900 group"
              title="Bagikan"
            >
              <Send className="w-4 h-4 stroke-[2] transition-transform group-hover:scale-110" />
            </button>
          </div>

          {/* Group 2: Photo Viewport Controls (Divider | Pagination Dots | Zoom Scale) */}
          <span className="w-px h-4 bg-neutral-200 mx-1 shrink-0" />

          <div className="flex items-center gap-x-1.5 pl-0.5">
            {/* Multi-image Pagination Dots (Comes BEFORE Zoom for logical navigation order) */}
            {images.length > 1 && (
              <div className="flex items-center gap-1 px-1">
                {images.map((_, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      scrollToImage(idx);
                    }}
                    className={`cursor-pointer transition-all duration-200 ${
                      currentIndex === idx
                        ? 'w-4 h-1.5 rounded-full bg-[#1d64ec] shadow-xs'
                        : 'w-1.5 h-1.5 rounded-full bg-neutral-300 hover:bg-neutral-400'
                    }`}
                    aria-label={`Ke gambar ${idx + 1}`}
                  />
                ))}
              </div>
            )}

            {/* Zoom Scale Pill */}
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                triggerHaptic('selection');
                setZoomLevel((prev) => (prev === 1 ? 1.5 : prev === 1.5 ? 2 : 1));
              }}
              className="px-2 py-0.5 rounded-full bg-neutral-100 hover:bg-neutral-200 active:scale-92 transition-all cursor-pointer text-[12px] font-bold text-slate-800 tabular-nums leading-none"
              title="Ubah perbesaran"
            >
              {zoomLevel}x
            </button>

            {/* Audio Mute Toggle (if Video) */}
            {isVideo && (
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  triggerHaptic('light');
                  setIsMuted(!isMuted);
                }}
                className="p-1.5 rounded-full hover:bg-neutral-100 active:scale-92 transition-all cursor-pointer text-slate-700 hover:text-slate-900"
                title={isMuted ? 'Nyalakan suara' : 'Bisukan'}
              >
                {isMuted ? (
                  <VolumeX className="w-4 h-4 text-neutral-400" />
                ) : (
                  <Volume2 className="w-4 h-4 text-[#1d64ec]" />
                )}
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

