import React from 'react';
import { Star } from 'lucide-react';

interface RatingStarsProps {
  rating: number;
  maxStars?: number;
  size?: number;
}

export const RatingStars: React.FC<RatingStarsProps> = ({
  rating,
  maxStars = 5,
  size = 14
}) => {
  return (
    <div className="flex items-center gap-0.5" title={`Rating ${rating} dari ${maxStars}`}>
      {Array.from({ length: maxStars }).map((_, index) => {
        const isFilled = index < Math.floor(rating);
        const isHalf = index === Math.floor(rating) && rating % 1 >= 0.5;

        return (
          <Star
            key={index}
            size={size}
            className={
              isFilled || isHalf
                ? 'fill-amber-400 text-amber-400'
                : 'fill-slate-800 text-slate-700'
            }
          />
        );
      })}
      <span className="ml-1 text-xs font-medium text-slate-300">
        {rating.toFixed(1)}
      </span>
    </div>
  );
};
