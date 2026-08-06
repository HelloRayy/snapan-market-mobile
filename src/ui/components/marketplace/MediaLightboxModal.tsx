import React, { useState, useRef, useEffect } from 'react';
import { X, Volume2, VolumeX } from 'lucide-react';

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
  isVideo: _isVideo = false,
}) => {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [isMuted, setIsMuted] = useState(true);
  const scrollRef = useRef<HTMLDivElement>(null);

  // Drag state
  const [isMouseDown, setIsMouseDown] = useState(false);
  const [startX, setStartX] = useState(0);
  const [scrollLeft, setScrollLeft] = useState(0);

  useEffect(() => {
    setCurrentIndex(initialIndex);
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
    }
  };

  const handleMouseDown = (e: React.MouseEvent) => {
    if (!scrollRef.current) return;
    setIsMouseDown(true);
    setStartX(e.pageX - scrollRef.current.offsetLeft);
    setScrollLeft(scrollRef.current.scrollLeft);
  };

  const handleMouseLeaveOrUp = () => {
    setIsMouseDown(false);
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isMouseDown || !scrollRef.current) return;
    e.preventDefault();
    const x = e.pageX - scrollRef.current.offsetLeft;
    const walk = (x - startX) * 1.5;
    scrollRef.current.scrollLeft = scrollLeft - walk;
  };

  const scrollToImage = (index: number) => {
    if (!scrollRef.current) return;
    const slideWidth = scrollRef.current.offsetWidth;
    scrollRef.current.scrollTo({
      left: index * slideWidth,
      behavior: 'smooth',
    });
    setCurrentIndex(index);
  };

  return (
    <div className="fixed inset-0 z-[100] bg-black/95 backdrop-blur-2xl flex flex-col justify-between overflow-hidden select-none animate-in fade-in duration-200 font-gt-standard">
      {/* Top Bar: Floating Kumo UI Close Button & Counter Badge */}
      <div className="relative z-50 flex items-center justify-between px-4 pt-4 pb-2 max-w-xl mx-auto w-full">
        {/* Top-Left: Floating Kumo UI Circular Close X Button */}
        <button
          type="button"
          onClick={onClose}
          className="w-10 h-10 rounded-full bg-neutral-900/80 hover:bg-neutral-800 text-white border border-neutral-700/60 backdrop-blur-md flex items-center justify-center active:scale-90 transition-all shadow-md cursor-pointer"
          aria-label="Tutup Media"
        >
          <X className="w-5 h-5 text-white stroke-[2.25]" />
        </button>

        {/* Top-Right: Counter Badge for Multi-Image */}
        {images.length > 1 && (
          <div className="px-3 py-1 rounded-full bg-neutral-900/80 border border-neutral-700/60 backdrop-blur-md text-white text-xs font-semibold shadow-md">
            {currentIndex + 1} / {images.length}
          </div>
        )}
      </div>

      {/* Main Fullscreen Gallery Slider */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        onMouseDown={handleMouseDown}
        onMouseLeave={handleMouseLeaveOrUp}
        onMouseUp={handleMouseLeaveOrUp}
        onMouseMove={handleMouseMove}
        className="flex-1 w-full max-w-xl mx-auto flex items-center overflow-x-auto snap-x snap-mandatory scrollbar-none cursor-grab active:cursor-grabbing touch-pan-x"
      >
        {images.map((imgUrl, idx) => (
          <div
            key={idx}
            className="w-full h-full shrink-0 flex items-center justify-center snap-center p-3 relative"
          >
            <img
              src={imgUrl}
              alt={caption || `Media Preview ${idx + 1}`}
              className="max-h-[82vh] max-w-full object-contain rounded-xl shadow-2xl pointer-events-none"
            />
          </div>
        ))}
      </div>

      {/* Bottom Floating Bar: [Center: Indicator Dots] --- [Right: Mute / Sound Button] */}
      <div className="relative z-50 flex items-center justify-between px-4 pb-6 pt-2 max-w-xl mx-auto w-full">
        {/* Spacer for balance */}
        <div className="w-10 h-10 pointer-events-none" />

        {/* Center: Indicator Dots for Multi-Image (Centered Horizontally) */}
        {images.length > 1 && (
          <div className="absolute left-1/2 -translate-x-1/2 flex items-center gap-2 bg-neutral-900/70 border border-neutral-700/50 backdrop-blur-md px-3 py-1.5 rounded-full shadow-md">
            {images.map((_, idx) => (
              <button
                key={idx}
                type="button"
                onClick={() => scrollToImage(idx)}
                className={`transition-all duration-200 cursor-pointer ${
                  currentIndex === idx
                    ? 'w-7 h-2 rounded-full bg-white shadow-xs'
                    : 'w-2 h-2 rounded-full bg-white/40 hover:bg-white/70'
                }`}
                aria-label={`Ke gambar ${idx + 1}`}
              />
            ))}
          </div>
        )}

        {/* Right Side: Mute / Sound Button for Video / Audio */}
        <button
          type="button"
          onClick={() => setIsMuted(!isMuted)}
          className="w-10 h-10 rounded-full bg-neutral-900/80 hover:bg-neutral-800 text-white border border-neutral-700/60 backdrop-blur-md flex items-center justify-center active:scale-90 transition-all shadow-md cursor-pointer ml-auto"
          aria-label={isMuted ? 'Nyalakan Suara' : 'Matikan Suara'}
        >
          {isMuted ? (
            <VolumeX className="w-5 h-5 text-white stroke-[2]" />
          ) : (
            <Volume2 className="w-5 h-5 text-white stroke-[2]" />
          )}
        </button>
      </div>
    </div>
  );
};
