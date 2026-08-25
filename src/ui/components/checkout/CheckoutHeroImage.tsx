import React, { useState } from 'react';
import { ArrowLeft, Heart } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface CheckoutHeroImageProps {
  images?: string[];
  title?: string;
  onBack: () => void;
  isLiked?: boolean;
  onToggleLike?: () => void;
  initialLiked?: boolean;
}

export const CheckoutHeroImage: React.FC<CheckoutHeroImageProps> = ({
  images = [],
  title = 'Foto Produk',
  onBack,
  isLiked: controlledLiked,
  onToggleLike,
  initialLiked = false,
}) => {
  const [activeIndex, setActiveIndex] = useState(0);
  const [internalLiked, setInternalLiked] = useState(initialLiked);

  const isLiked = controlledLiked !== undefined ? controlledLiked : internalLiked;

  const imageList =
    images.length > 0
      ? images
      : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  const handleBackClick = () => {
    triggerHaptic('light');
    onBack();
  };

  const handleToggleLike = () => {
    triggerHaptic('medium');
    if (onToggleLike) {
      onToggleLike();
    } else {
      setInternalLiked((prev) => !prev);
    }
  };

  return (
    <div className="relative w-full p-3.5 select-none font-gt-standard">
      {/* Outer Hero Container with Heavy Rounded Corners */}
      <div className="relative w-full aspect-[4/3.2] sm:h-80 rounded-[28px] overflow-hidden bg-neutral-100 border border-neutral-200/80 shadow-xs group">
        {/* 1. Floating Squircle Back Button (Top Left) */}
        <button
          type="button"
          onClick={handleBackClick}
          className="absolute top-3.5 left-3.5 z-20 w-11 h-11 rounded-[18px] bg-white/95 backdrop-blur-md shadow-[0_8px_20px_rgba(0,0,0,0.08)] border border-white/80 flex items-center justify-center text-slate-800 hover:bg-white active:scale-90 transition-all cursor-pointer"
          aria-label="Kembali ke detail postingan"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.25] text-slate-900" />
        </button>

        {/* 2. Floating Squircle Heart / Like Button (Top Right) */}
        <button
          type="button"
          onClick={handleToggleLike}
          className="absolute top-3.5 right-3.5 z-20 w-11 h-11 rounded-[18px] bg-white/95 backdrop-blur-md shadow-[0_8px_20px_rgba(0,0,0,0.08)] border border-white/80 flex items-center justify-center text-slate-800 hover:bg-white active:scale-90 transition-all cursor-pointer"
          aria-label="Simpan ke favorit"
        >
          <Heart
            className={`w-5 h-5 transition-transform duration-200 ${
              isLiked
                ? 'fill-rose-500 text-rose-500 scale-110'
                : 'text-slate-900 stroke-[2.25]'
            }`}
          />
        </button>

        {/* 3. Image Display / Scrollable Carousel */}
        <div
          className="w-full h-full flex overflow-x-auto snap-x snap-mandatory scrollbar-none"
          onScroll={(e) => {
            const scrollLeft = e.currentTarget.scrollLeft;
            const width = e.currentTarget.clientWidth;
            if (width > 0) {
              setActiveIndex(Math.round(scrollLeft / width));
            }
          }}
        >
          {imageList.map((img, idx) => (
            <img
              key={idx}
              src={img}
              alt={`${title} - Preview ${idx + 1}`}
              className="w-full h-full object-cover shrink-0 snap-center"
            />
          ))}
        </div>

        {/* 4. Subtle Pagination Dots (Only if multiple images) */}
        {imageList.length > 1 && (
          <div className="absolute bottom-3 left-0 right-0 flex justify-center pointer-events-none z-10">
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-black/40 backdrop-blur-md border border-white/20">
              {imageList.map((_, idx) => (
                <div
                  key={idx}
                  className={`h-1.5 rounded-full transition-all duration-300 ${
                    idx === activeIndex ? 'w-4 bg-white' : 'w-1.5 bg-white/50'
                  }`}
                />
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
