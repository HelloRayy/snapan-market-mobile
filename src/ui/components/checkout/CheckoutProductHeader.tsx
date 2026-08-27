import React from 'react';
import { Star, MapPin, Handshake } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { stripEmojis } from '@/utils/formatters';

interface CheckoutProductHeaderProps {
  post: MarketPostItem;
}

export const CheckoutProductHeader: React.FC<CheckoutProductHeaderProps> = ({ post }) => {
  // Clean title without emoji spam
  const rawCaption = post.caption || '';
  const cleanTitle = stripEmojis(post.title || rawCaption);

  const titleText = post.title || (cleanTitle.length > 60 ? cleanTitle.slice(0, 58) + '...' : cleanTitle);

  return (
    <section className="space-y-3 select-none font-gt-standard">
      {/* 1. Availability Pill (Left) & Rating Pill (Right) - Electric Indigo Signature */}
      <div className="flex items-center justify-between gap-2">
        {/* Ready for COD Badge with Electric Indigo Accent */}
        <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[#eef0ff] text-[#3d38f5] text-[12.5px] font-bold tracking-tight">
          <Handshake className="w-3.5 h-3.5 text-[#3d38f5] stroke-[2.2]" />
          <span>Ready for COD</span>
        </div>

        {/* Rating Pill with Warm Amber Accent (Borderless) */}
        <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-amber-50 text-amber-900 text-[12.5px] font-bold">
          <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400 stroke-none" />
          <span>4.5</span>
        </div>
      </div>

      {/* 2. Main Product Title */}
      <h1 className="font-bold text-[20px] sm:text-[21px] text-slate-900 leading-snug tracking-tight pt-0.5">
        {titleText}
      </h1>

      {/* 3. Location & Seller Class Info with Electric Indigo Pin */}
      <div className="flex items-center gap-1.5 text-[13px] text-neutral-500 font-normal">
        <MapPin className="w-3.5 h-3.5 text-[#3d38f5] shrink-0 stroke-[2.2]" />
        <span>
          SMKN 8 Jakarta · <span className="text-slate-800 font-semibold">{post.seller.classGroup || 'XII PPLG 1'}</span>
        </span>
      </div>
    </section>
  );
};
