import React, { useEffect } from 'react';
import { MarketPostItem } from '@/types/marketFeed';
import { CheckoutHeroImage } from '../components/checkout/CheckoutHeroImage';
import { CheckoutProductHeader } from '../components/checkout/CheckoutProductHeader';
import { CheckoutDescription } from '../components/checkout/CheckoutDescription';
import { CheckoutSellerCard } from '../components/checkout/CheckoutSellerCard';

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
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-28 max-w-[590px] mx-auto overflow-x-hidden animate-in fade-in duration-200">
      {/* 1. TOP HERO SECTION (Foto Produk + Floating Squircle Back & Like) */}
      <CheckoutHeroImage
        images={images}
        title={post.title || post.caption}
        onBack={onBack}
        initialLiked={false}
      />

      {/* 2. FORM CONTAINER (Tema Terang Bersih & Konsisten) */}
      <div className="px-3.5 pb-8 -mt-1">
        <div className="bg-neutral-50/60 rounded-[28px] border border-neutral-200/80 p-5 shadow-2xs space-y-5">
          {/* A. Product Info Header (Category, Rating, Title, Location) */}
          <CheckoutProductHeader post={post} />

          {/* B. Product Description with Read More */}
          <CheckoutDescription description={post.description || post.caption} />

          {/* C. Seller Contact Card (Avatar, Name, Class, Chat & Phone/WA) */}
          <CheckoutSellerCard
            seller={post.seller}
            productTitle={post.title || post.caption}
            productPrice={post.price || 0}
          />

          {/* Step berikutnya (Denah & Floating Bottom Bar) akan di-slicing di bawah ini */}
        </div>
      </div>
    </div>
  );
};
