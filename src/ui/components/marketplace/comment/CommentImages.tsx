import React from 'react';

interface CommentImagesProps {
  images?: string[];
  onImageClick?: (images: string[], index: number) => void;
}

export const CommentImages: React.FC<CommentImagesProps> = ({
  images,
  onImageClick,
}) => {
  if (!images || images.length === 0) return null;

  if (images.length === 1) {
    return (
      <div className="pt-2">
        <div
          onClick={(e) => {
            e.stopPropagation();
            onImageClick?.(images, 0);
          }}
          className="relative w-full rounded-2xl overflow-hidden border border-black/10 shadow-2xs max-h-[300px] aspect-[16/10] bg-neutral-100 cursor-pointer"
        >
          <img
            src={images[0]}
            alt="Attachment"
            className="w-full h-full object-cover"
            loading="lazy"
            decoding="async"
          />
        </div>
      </div>
    );
  }

  return (
    <div className="pt-2">
      <div className="flex gap-2 overflow-x-auto py-1 scrollbar-none">
        {images.map((img, idx) => (
          <div
            key={idx}
            onClick={(e) => {
              e.stopPropagation();
              onImageClick?.(images, idx);
            }}
            className="relative w-44 h-32 rounded-2xl overflow-hidden border border-black/10 shadow-2xs shrink-0 bg-neutral-100 cursor-pointer"
          >
            <img
              src={img}
              alt={`Attachment ${idx + 1}`}
              className="w-full h-full object-cover"
              loading="lazy"
              decoding="async"
            />
          </div>
        ))}
      </div>
    </div>
  );
};
