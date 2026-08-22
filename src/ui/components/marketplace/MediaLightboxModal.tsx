import React, { useState, useRef, useEffect } from 'react';
import { X, Volume2, VolumeX, Play, Pause } from 'lucide-react';

interface MediaLightboxModalProps {
  isOpen: boolean;
  images: string[];
  initialIndex?: number;
  onClose: () => void;
  caption?: string;
  isVideo?: boolean;
}

export const MediaLightboxModal: React.FC<MediaLightboxModalProps> = ({
  isOpen,
  images,
  initialIndex = 0,
  onClose,
  caption,
  isVideo = false,
}) => {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [isMuted, setIsMuted] = useState(true);
  const [isPlaying, setIsPlaying] = useState(true);
  const [playbackSpeed, setPlaybackSpeed] = useState<'1x' | '1.5x' | '2x'>('1x');
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
    setIsPlaying(true);
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
        backgroundColor: `rgba(0, 0, 0, ${0.98 * opacity})`,
        transform: `translateY(${dragY}px)`,
        opacity: opacity,
      }}
      className="fixed inset-0 z-[100] backdrop-blur-2xl flex flex-col justify-between overflow-hidden select-none font-gt-standard text-[#f3f5f7] bg-black"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Top Bar: Deep Black Circular Close Button + Counter Badge */}
      <div className="relative z-50 flex items-center justify-between px-5 pt-5 pb-2 max-w-xl mx-auto w-full">
        {/* Top-Left: Circular Dark Button h-11 w-11 */}
        <button
          type="button"
          onClick={handleClose}
          className="flex items-center justify-center rounded-full h-11 w-11 bg-[#0a0a0a] hover:bg-[#181818] active:scale-90 text-[#f3f5f7] border border-white/10 shadow-lg transition-transform cursor-pointer select-none"
          aria-label="Tutup Media"
        >
          <X className="w-5 h-5 text-[#f3f5f7] stroke-[2.2]" />
        </button>

        {/* Top-Right: Counter Badge for Multi-Image */}
        {images.length > 1 && (
          <div className="h-9 px-3.5 rounded-full bg-[#0a0a0a]/90 border border-white/10 backdrop-blur-md text-[#f3f5f7] text-xs font-semibold flex items-center shadow-md tabular-nums">
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
                className="max-h-[82vh] max-w-full h-auto w-auto object-contain rounded-[18px] shadow-2xl pointer-events-none select-none transition-transform duration-300"
              />
            </picture>
          </div>
        ))}
      </div>

      {/* Bottom Floating Glass Capsule Bar (Option 1 Threads Control Bar) */}
      <div className="relative z-50 flex items-center justify-center px-4 pb-8 pt-2 max-w-xl mx-auto w-full">
        <div className="flex items-center gap-x-3 sm:gap-x-4 bg-[#0a0a0a]/90 backdrop-blur-xl border border-white/15 px-5 py-2.5 rounded-full shadow-2xl text-[#f3f5f7] text-[13.5px] sm:text-[14px] font-medium leading-snug select-none">
          {isVideo ? (
            <>
              {/* 1. Jeda / Putar (Only when isVideo is true) */}
              <button
                type="button"
                onClick={() => setIsPlaying(!isPlaying)}
                className="flex items-center gap-1.5 hover:text-white active:scale-95 transition-all cursor-pointer"
              >
                {isPlaying ? (
                  <>
                    <Pause className="w-3.5 h-3.5 fill-current" />
                    <span>Jeda</span>
                  </>
                ) : (
                  <>
                    <Play className="w-3.5 h-3.5 fill-current" />
                    <span>Putar</span>
                  </>
                )}
              </button>

              <span className="w-px h-3.5 bg-white/20" />

              {/* 2. Audio Disenyapkan / Bunyi */}
              <button
                type="button"
                onClick={() => setIsMuted(!isMuted)}
                className="flex items-center gap-1.5 hover:text-white active:scale-95 transition-all cursor-pointer"
              >
                {isMuted ? (
                  <>
                    <VolumeX className="w-4 h-4 text-neutral-400" />
                    <span className="text-neutral-300">Audio disenyapkan</span>
                  </>
                ) : (
                  <>
                    <Volume2 className="w-4 h-4 text-[#1d64ec]" />
                    <span className="text-white font-semibold">Audio aktif</span>
                  </>
                )}
              </button>

              <span className="w-px h-3.5 bg-white/20" />

              {/* 3. Playback Speed */}
              <button
                type="button"
                onClick={() =>
                  setPlaybackSpeed((prev) => (prev === '1x' ? '1.5x' : prev === '1.5x' ? '2x' : '1x'))
                }
                className="font-bold hover:text-white active:scale-95 transition-all cursor-pointer px-1 tabular-nums"
              >
                {playbackSpeed}
              </button>

              <span className="w-px h-3.5 bg-white/20" />

              {/* 4. Kembali */}
              <button
                type="button"
                onClick={() => {
                  if (currentIndex > 0) scrollToImage(currentIndex - 1);
                }}
                disabled={currentIndex === 0}
                className="hover:text-white disabled:opacity-30 disabled:pointer-events-none active:scale-95 transition-all cursor-pointer"
              >
                Kembali
              </button>

              {/* 5. Lanjutkan */}
              <button
                type="button"
                onClick={() => {
                  if (currentIndex < images.length - 1) scrollToImage(currentIndex + 1);
                }}
                disabled={currentIndex === images.length - 1}
                className="hover:text-white disabled:opacity-30 disabled:pointer-events-none active:scale-95 transition-all cursor-pointer"
              >
                Lanjutkan
              </button>
            </>
          ) : (
            /* Foto Biasa: TIDAK ADA tombol Jeda (Sesuai directive: "jika tidak video maka tidak ada jeda") */
            <>
              {/* 1. Kembali (Prev Photo) if Multi-Image */}
              {images.length > 1 && (
                <>
                  <button
                    type="button"
                    onClick={() => {
                      if (currentIndex > 0) scrollToImage(currentIndex - 1);
                    }}
                    disabled={currentIndex === 0}
                    className="hover:text-white disabled:opacity-30 disabled:pointer-events-none active:scale-95 transition-all cursor-pointer"
                  >
                    Kembali
                  </button>
                  <span className="w-px h-3.5 bg-white/20" />
                </>
              )}

              {/* 2. Zoom / Skala Preset */}
              <button
                type="button"
                onClick={() => setZoomLevel((prev) => (prev === 1 ? 1.5 : prev === 1.5 ? 2 : 1))}
                className="font-bold hover:text-white active:scale-95 transition-all cursor-pointer px-1.5 tabular-nums"
              >
                {zoomLevel}x
              </button>

              {/* 3. Pagination Dots & Lanjutkan if Multi-Image */}
              {images.length > 1 && (
                <>
                  <span className="w-px h-3.5 bg-white/20" />
                  <div className="flex items-center gap-1.5 px-1">
                    {images.map((_, idx) => (
                      <button
                        key={idx}
                        type="button"
                        onClick={() => scrollToImage(idx)}
                        className={`cursor-pointer transition-all ${
                          currentIndex === idx
                            ? 'w-5 h-1.5 rounded-full bg-white shadow-xs'
                            : 'w-1.5 h-1.5 rounded-full bg-white/40 hover:bg-white/70'
                        }`}
                        aria-label={`Ke gambar ${idx + 1}`}
                      />
                    ))}
                  </div>
                  <span className="w-px h-3.5 bg-white/20" />
                  <button
                    type="button"
                    onClick={() => {
                      if (currentIndex < images.length - 1) scrollToImage(currentIndex + 1);
                    }}
                    disabled={currentIndex === images.length - 1}
                    className="hover:text-white disabled:opacity-30 disabled:pointer-events-none active:scale-95 transition-all cursor-pointer"
                  >
                    Lanjutkan
                  </button>
                </>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
};
