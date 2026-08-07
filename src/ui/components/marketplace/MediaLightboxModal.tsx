import React, { useState, useRef, useEffect } from 'react';
import { X, Volume2, VolumeX, ZoomIn, ZoomOut } from 'lucide-react';

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

  // Transform state for 2D Pan & Instant Pinch Zoom
  const [scale, setScale] = useState(1);
  const [position, setPosition] = useState({ x: 0, y: 0 });

  // Drag to dismiss state
  const [dragY, setDragY] = useState(0);

  const scrollRef = useRef<HTMLDivElement>(null);
  const panStartRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });
  const touchStartYRef = useRef<number>(0);
  const initialPinchDistRef = useRef<number | null>(null);
  const initialPinchScaleRef = useRef<number>(1);

  // Reset transform state on slide/open change
  useEffect(() => {
    setCurrentIndex(initialIndex);
    setScale(1);
    setPosition({ x: 0, y: 0 });
    setDragY(0);
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
      setScale(1);
      setPosition({ x: 0, y: 0 });
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
    setScale(1);
    setPosition({ x: 0, y: 0 });
  };

  // Toggle Zoom Button / Double Tap
  const handleToggleZoom = () => {
    if (scale > 1) {
      setScale(1);
      setPosition({ x: 0, y: 0 });
    } else {
      setScale(2.5);
      setPosition({ x: 0, y: 0 });
    }
  };

  // Touch Handlers for Native 2D Pan & Pinch Zoom
  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      if (scale > 1) {
        // 2D Pan Mode (Zoomed In)
        panStartRef.current = {
          x: e.touches[0].clientX - position.x,
          y: e.touches[0].clientY - position.y,
        };
      } else {
        // Swipe to Dismiss Mode (Unzoomed)
        touchStartYRef.current = e.touches[0].clientY;
      }
    } else if (e.touches.length === 2) {
      // Instant Pinch Zoom Mode
      const dist = Math.hypot(
        e.touches[0].clientX - e.touches[1].clientX,
        e.touches[0].clientY - e.touches[1].clientY
      );
      initialPinchDistRef.current = dist;
      initialPinchScaleRef.current = scale;
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (e.touches.length === 2 && initialPinchDistRef.current !== null) {
      // Native 2-Finger Pinch Zoom (Instant, no delay animation)
      const currentDist = Math.hypot(
        e.touches[0].clientX - e.touches[1].clientX,
        e.touches[0].clientY - e.touches[1].clientY
      );
      const zoomFactor = currentDist / initialPinchDistRef.current;
      const newScale = Math.min(Math.max(initialPinchScaleRef.current * zoomFactor, 1), 4);
      
      setScale(newScale);
      if (newScale === 1) {
        setPosition({ x: 0, y: 0 });
      }
    } else if (e.touches.length === 1) {
      if (scale > 1) {
        // Native 2D Pan (Move image X & Y freely)
        const newX = e.touches[0].clientX - panStartRef.current.x;
        const newY = e.touches[0].clientY - panStartRef.current.y;
        setPosition({ x: newX, y: newY });
      } else {
        // Swipe to Dismiss (Vertical Drag)
        const deltaY = e.touches[0].clientY - touchStartYRef.current;
        setDragY(deltaY);
      }
    }
  };

  const handleTouchEnd = () => {
    initialPinchDistRef.current = null;

    if (scale <= 1) {
      setScale(1);
      setPosition({ x: 0, y: 0 });

      // Check vertical drag threshold for dismiss
      if (Math.abs(dragY) > 110) {
        onClose();
      } else {
        setDragY(0);
      }
    }
  };

  const opacity = Math.max(0.3, 1 - Math.abs(dragY) / 350);

  return (
    <div
      style={{
        backgroundColor: `rgba(255, 255, 255, ${0.98 * opacity})`,
        transform: `translateY(${dragY}px)`,
        opacity: opacity,
      }}
      className="fixed inset-0 z-[100] backdrop-blur-2xl flex flex-col justify-between overflow-hidden select-none font-gt-standard text-slate-900"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Top Bar: Kumo UI Clean Light Floating Header */}
      <div className="relative z-50 flex items-center justify-between px-4 pt-4 pb-2 max-w-xl mx-auto w-full">
        {/* Top-Left: Floating Kumo UI Circular Close X Button */}
        <button
          type="button"
          onClick={onClose}
          className="w-10 h-10 rounded-full bg-white/90 hover:bg-neutral-100 text-slate-800 border border-neutral-200/80 backdrop-blur-md flex items-center justify-center active:scale-90 transition-transform shadow-xs cursor-pointer"
          aria-label="Tutup Media"
        >
          <X className="w-5 h-5 text-slate-800 stroke-[2.25]" />
        </button>

        {/* Top-Center/Right: Zoom & Counter Badges */}
        <div className="flex items-center gap-2">
          {/* Zoom Toggle Button */}
          <button
            type="button"
            onClick={handleToggleZoom}
            className="w-9 h-9 rounded-full bg-white/90 hover:bg-neutral-100 text-slate-700 border border-neutral-200/80 backdrop-blur-md flex items-center justify-center active:scale-90 transition-transform shadow-xs cursor-pointer"
            aria-label="Zoom Gambar"
            title="Zoom In/Out"
          >
            {scale > 1 ? (
              <ZoomOut className="w-4.5 h-4.5 text-slate-800 stroke-[2]" />
            ) : (
              <ZoomIn className="w-4.5 h-4.5 text-slate-800 stroke-[2]" />
            )}
          </button>

          {/* Counter Badge */}
          {images.length > 1 && (
            <div className="px-3 py-1 rounded-full bg-white/90 border border-neutral-200/80 backdrop-blur-md text-slate-800 text-xs font-semibold shadow-xs">
              {currentIndex + 1} / {images.length}
            </div>
          )}
        </div>
      </div>

      {/* Main Fullscreen Gallery Slider */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className={`flex-1 w-full max-w-xl mx-auto flex items-center scrollbar-none cursor-grab active:cursor-grabbing ${
          scale > 1
            ? 'overflow-hidden touch-none'
            : 'overflow-x-auto snap-x snap-mandatory touch-pan-x touch-pan-y'
        }`}
      >
        {images.map((imgUrl, idx) => (
          <div
            key={idx}
            onDoubleClick={handleToggleZoom}
            className="w-full h-full shrink-0 flex items-center justify-center snap-center p-3 relative overflow-hidden"
          >
            <img
              src={imgUrl}
              alt={caption || `Media Preview ${idx + 1}`}
              style={{
                transform: `translate3d(${currentIndex === idx ? position.x : 0}px, ${
                  currentIndex === idx ? position.y : 0
                }px, 0) scale(${currentIndex === idx ? scale : 1})`,
                transition: 'none',
                touchAction: 'none',
              }}
              className="max-h-[86vh] max-w-full h-auto w-auto object-contain rounded-2xl shadow-xl pointer-events-none select-none"
            />
          </div>
        ))}
      </div>

      {/* Bottom Floating Bar: [Center: Indicator Dots] --- [Right: Mute / Sound Button (Only if Video)] */}
      <div className="relative z-50 flex items-center justify-between px-4 pb-6 pt-2 max-w-xl mx-auto w-full">
        {/* Spacer for balance */}
        <div className="w-10 h-10 pointer-events-none" />

        {/* Center: Indicator Dots for Multi-Image (Centered Horizontally) */}
        {images.length > 1 && (
          <div className="absolute left-1/2 -translate-x-1/2 flex items-center gap-2 bg-white/90 border border-neutral-200/80 backdrop-blur-md px-3 py-1.5 rounded-full shadow-xs">
            {images.map((_, idx) => (
              <button
                key={idx}
                type="button"
                onClick={() => scrollToImage(idx)}
                className={`cursor-pointer ${
                  currentIndex === idx
                    ? 'w-7 h-2 rounded-full bg-slate-900 shadow-2xs'
                    : 'w-2 h-2 rounded-full bg-slate-300 hover:bg-slate-500'
                }`}
                aria-label={`Ke gambar ${idx + 1}`}
              />
            ))}
          </div>
        )}

        {/* Right Side: Mute / Sound Button (Only rendered if isVideo is true) */}
        {isVideo ? (
          <button
            type="button"
            onClick={() => setIsMuted(!isMuted)}
            className="w-10 h-10 rounded-full bg-white/90 hover:bg-neutral-100 text-slate-800 border border-neutral-200/80 backdrop-blur-md flex items-center justify-center active:scale-90 transition-all shadow-xs cursor-pointer ml-auto"
            aria-label={isMuted ? 'Nyalakan Suara' : 'Matikan Suara'}
          >
            {isMuted ? (
              <VolumeX className="w-5 h-5 text-slate-800 stroke-[2]" />
            ) : (
              <Volume2 className="w-5 h-5 text-slate-800 stroke-[2]" />
            )}
          </button>
        ) : (
          <div className="w-10 h-10 pointer-events-none ml-auto" />
        )}
      </div>
    </div>
  );
};
