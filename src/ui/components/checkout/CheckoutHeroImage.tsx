import React, { useState } from 'react';

interface CheckoutHeroImageProps {
  images?: string[];
  title?: string;
}

export const CheckoutHeroImage: React.FC<CheckoutHeroImageProps> = ({
  images = [],
  title = 'Foto Produk',
}) => {
  const [activeIndex, setActiveIndex] = useState(0);

  const imageList =
    images.length > 0
      ? images
      : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  return (
    <div className="relative w-full p-3.5 select-none font-gt-standard">
      {/* Outer Hero Container with Heavy Rounded Corners */}
      <div className="relative w-full aspect-[4/3.2] sm:h-80 rounded-[28px] overflow-hidden bg-neutral-100 border border-neutral-200/80 shadow-xs group">

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
