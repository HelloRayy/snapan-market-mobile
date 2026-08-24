import React, { useEffect } from 'react';
import { MarketPostItem } from '@/types/marketFeed';
import { CheckoutHeroImage } from '../components/checkout/CheckoutHeroImage';

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

      {/* Placeholder container for the next slicing steps */}
      <div className="px-4 py-2 space-y-4">
        {/* Step berikutnya akan di-slicing di sini */}
      </div>
    </div>
  );
};
