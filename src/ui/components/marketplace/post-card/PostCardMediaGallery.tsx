import React, { useRef } from 'react';
import { ProgressiveImage } from '@/ui/components/ui/ProgressiveImage';

interface PostCardMediaGalleryProps {
  images?: string[];
  caption: string;
  onImageClick: (index: number) => void;
  isDetail?: boolean;
}

export const PostCardMediaGallery: React.FC<PostCardMediaGalleryProps> = ({
  images,
  caption,
  onImageClick,
  isDetail = false,
}) => {
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const isMouseDownRef = useRef(false);
  const startXRef = useRef(0);
  const scrollLeftRef = useRef(0);
  const hasDraggedRef = useRef(false);

  if (!images || images.length === 0) return null;

  const handlePointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    if (e.button !== 0 && e.pointerType === 'mouse') return;
    if (!scrollContainerRef.current) return;
    isMouseDownRef.current = true;
    hasDraggedRef.current = false;
    startXRef.current = e.clientX;
    scrollLeftRef.current = scrollContainerRef.current.scrollLeft;

    if (e.pointerType === 'mouse') {
      try {
        e.currentTarget.setPointerCapture(e.pointerId);
      } catch {}
    }
  };

  const handlePointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    if (!isMouseDownRef.current || !scrollContainerRef.current) return;
    const dx = e.clientX - startXRef.current;
    if (Math.abs(dx) > 3) {
      hasDraggedRef.current = true;
      scrollContainerRef.current.scrollLeft = scrollLeftRef.current - dx * 1.3;
    }
  };

  const handlePointerUp = () => {
    isMouseDownRef.current = false;
  };

  return (
    <>
      {images.length === 1 && (
        <div
          onClick={(e) => {
            e.stopPropagation();
            onImageClick(0);
          }}
          className="relative w-full rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[420px] aspect-[4/5] sm:aspect-[16/10] mt-2.5 cursor-pointer touch-pan-y"
        >
          <ProgressiveImage
            src={images[0]}
            alt={caption}
            className="w-full h-full object-cover hover:scale-[1.01] transition-transform duration-300 pointer-events-none select-none"
          />
          <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
        </div>
      )}

      {images.length > 1 && (
        <div
          ref={scrollContainerRef}
          data-lenis-prevent
          onPointerDown={handlePointerDown}
          onPointerMove={handlePointerMove}
          onPointerUp={handlePointerUp}
          onPointerCancel={handlePointerUp}
          onClick={(e) => e.stopPropagation()}
          className={`flex gap-2.5 overflow-x-auto scrollbar-none mt-2.5 cursor-grab active:cursor-grabbing select-none overscroll-x-contain touch-auto ${
            isDetail
              ? '-mx-3.5 pl-3.5 pr-3.5 w-[calc(100%+28px)] max-w-[calc(100%+28px)]'
              : '-ml-[62px] -mr-3.5 pl-[62px] pr-3.5 w-[calc(100%+76px)] max-w-[calc(100%+76px)]'
          }`}
          style={{ WebkitOverflowScrolling: 'touch', touchAction: 'auto' }}
        >
          {images.map((imgUrl, idx) => (
            <div
              key={idx}
              onClick={(e) => {
                e.stopPropagation();
                if (!hasDraggedRef.current) {
                  onImageClick(idx);
                }
              }}
              className="relative shrink-0 w-[84%] sm:w-[76%] rounded-[18px] overflow-hidden border border-black/[0.08] shadow-2xs bg-neutral-100 max-h-[420px] aspect-[4/5] sm:aspect-[16/10] cursor-pointer touch-pan-y"
            >
              <ProgressiveImage
                src={imgUrl}
                alt={`${caption} - ${idx + 1}`}
                className="w-full h-full object-cover pointer-events-none select-none"
              />
              <div className="absolute inset-0 rounded-[18px] ring-1 ring-inset ring-black/10 pointer-events-none z-10" />
            </div>
          ))}
        </div>
      )}
    </>
  );
};
