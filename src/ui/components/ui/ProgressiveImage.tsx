import React, { useState } from 'react';

interface ProgressiveImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  src: string;
  alt: string;
  className?: string;
  containerClassName?: string;
}

export const ProgressiveImage: React.FC<ProgressiveImageProps> = ({
  src,
  alt,
  className = '',
  containerClassName = '',
  ...props
}) => {
  const [isLoaded, setIsLoaded] = useState(false);

  return (
    <div className={`relative overflow-hidden bg-neutral-100/90 ${containerClassName}`}>
      {/* Shimmer Gradient Placeholder (Anti-Layout Shift) */}
      <div
        className={`absolute inset-0 bg-gradient-to-r from-neutral-100 via-neutral-200/50 to-neutral-100 transition-opacity duration-300 ${
          isLoaded ? 'opacity-0 pointer-events-none' : 'opacity-100 animate-pulse'
        }`}
      />

      <img
        src={src}
        alt={alt}
        loading="lazy"
        decoding="async"
        onLoad={() => setIsLoaded(true)}
        className={`w-full h-full object-cover transition-all duration-300 ${
          isLoaded ? 'opacity-100 scale-100 blur-0' : 'opacity-0 scale-[1.02] blur-xs'
        } ${className}`}
        {...props}
      />
    </div>
  );
};
