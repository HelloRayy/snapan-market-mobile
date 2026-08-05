import React from 'react';
import { Image as ImageIcon } from 'lucide-react';

export const Slide2Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] rounded-3xl bg-violet-wash/15 border-2 border-dashed border-shop-violet/40 p-6 flex flex-col items-center justify-center text-shop-violet shadow-xs">
      <div className="w-14 h-14 rounded-2xl bg-shop-violet/10 border border-shop-violet/20 flex items-center justify-center mb-3">
        <ImageIcon className="w-7 h-7 text-shop-violet opacity-80" />
      </div>
      <span className="text-xs font-bold text-shop-violet uppercase tracking-wider font-shopify-sans">
        Placeholder Visual 2
      </span>
    </div>
  );
};
