import React from 'react';
import { Star, MapPin, Tag } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';

interface CheckoutProductHeaderProps {
  post: MarketPostItem;
}

export const CheckoutProductHeader: React.FC<CheckoutProductHeaderProps> = ({ post }) => {
  // Clean title without emoji spam
  const rawCaption = post.caption || '';
  const cleanTitle = (post.title || rawCaption)
    .replace(/[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/gu, '')
    .trim();

  const titleText = post.title || (cleanTitle.length > 60 ? cleanTitle.slice(0, 58) + '...' : cleanTitle);

  // Category Formatter
  const getCategoryLabel = () => {
    if (post.category) return post.category;
    const catLower = (post.title || post.caption || '').toLowerCase();
    if (catLower.includes('jasa') || catLower.includes('coding') || catLower.includes('web') || catLower.includes('desain')) {
      return 'Jasa & Karya Digital';
    }
    if (catLower.includes('buku') || catLower.includes('modul') || catLower.includes('catatan')) {
      return 'Buku & Pelajaran';
    }
    if (catLower.includes('makanan') || catLower.includes('snack') || catLower.includes('minum')) {
      return 'Kuliner Sekolah';
    }
    return 'Marketplace Sekolah';
  };

  return (
    <section className="space-y-2.5 select-none font-gt-standard">
      {/* 1. Category Pill (Left) & Rating Pill (Right) */}
      <div className="flex items-center justify-between gap-2">
        {/* Category Pill */}
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-neutral-100/90 text-slate-700 text-[12px] font-medium tracking-tight border border-neutral-200/80 shadow-2xs">
          <Tag className="w-3.5 h-3.5 text-slate-600 stroke-[2]" />
          <span>{getCategoryLabel()}</span>
        </div>

        {/* Rating Pill */}
        <div className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-neutral-100/90 text-slate-700 text-[12px] font-medium border border-neutral-200/80 shadow-2xs">
          <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400 stroke-none" />
          <span className="font-semibold text-slate-800">4.9</span>
          <span className="text-neutral-400 text-[11px] font-normal">(18)</span>
        </div>
      </div>

      {/* 2. Main Product Title */}
      <h1 className="font-bold text-[19px] sm:text-[20px] text-slate-900 leading-snug tracking-tight pt-0.5">
        {titleText}
      </h1>

      {/* 3. Location & Seller Class Info */}
      <div className="flex items-center gap-1.5 text-[13px] text-neutral-500 font-normal">
        <MapPin className="w-3.5 h-3.5 text-neutral-400 shrink-0 stroke-[2]" />
        <span>
          SMKN 8 Jakarta · <span className="text-slate-700 font-medium">{post.seller.classGroup || 'XII PPLG 1'}</span>
        </span>
      </div>
    </section>
  );
};
