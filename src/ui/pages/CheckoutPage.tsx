import React, { useEffect } from 'react';
import { MarketPostItem } from '@/types/marketFeed';
import { CheckoutHeroImage } from '../components/checkout/CheckoutHeroImage';
import { CheckoutProductHeader } from '../components/checkout/CheckoutProductHeader';

interface CheckoutPageProps {
  post: MarketPostItem;
  onBack: () => void;
}

export const CheckoutPage: React.FC<CheckoutPageProps> = ({ post, onBack }) => {
  // Smooth scroll to top on mount
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'instant' });
  }, [post.id]);

  const images =
    post.images && post.images.length > 0
      ? post.images
      : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  return (
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-24 max-w-[590px] mx-auto overflow-x-hidden animate-in fade-in duration-200">
      {/* 1. TOP HERO SECTION (Foto Produk + Floating Squircle Back & Like) */}
      <CheckoutHeroImage
        images={images}
        title={post.title || post.caption}
        onBack={onBack}
        initialLiked={false}
      />

      {/* 2. FORM CONTAINER (Dengan gap bersih dan sudut membulat elegan) */}
      <div className="px-3.5 pb-8 -mt-1">
        <div className="bg-[#f8f9fa] rounded-[28px] border border-neutral-200/60 p-5 shadow-xs space-y-5">
          {/* Product Info Header (Category, Rating, Title, Location) */}
          <CheckoutProductHeader post={post} />

          {/* Step-step berikutnya akan di-slicing di bawah ini */}
        </div>
      </div>
    </div>
  );
};
