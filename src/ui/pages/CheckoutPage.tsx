import React, { useState, useEffect } from 'react';
import { ArrowLeft, Heart } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { CheckoutHeroImage } from '../components/checkout/CheckoutHeroImage';
import { CheckoutProductHeader } from '../components/checkout/CheckoutProductHeader';
import { CheckoutDescription } from '../components/checkout/CheckoutDescription';
import { CheckoutSellerCard } from '../components/checkout/CheckoutSellerCard';
import { triggerHaptic } from '@/utils/haptics';

interface CheckoutPageProps {
  post: MarketPostItem;
  onBack: () => void;
  onUserClick?: (username: string) => void;
}

export const CheckoutPage: React.FC<CheckoutPageProps> = ({ post, onBack, onUserClick }) => {
  const [isLiked, setIsLiked] = useState<boolean>(false);

  // Smooth scroll to top on mount
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'instant' });
  }, [post.id]);

  const handleBackClick = () => {
    triggerHaptic('light');
    onBack();
  };

  const handleToggleLike = () => {
    triggerHaptic('medium');
    setIsLiked((prev) => !prev);
  };

  const images =
    post.images && post.images.length > 0
      ? post.images
      : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80'];

  return (
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-28 max-w-[590px] mx-auto overflow-x-hidden animate-in fade-in duration-200">
      {/* 1. Permanent Sticky Top Navigation Bar (100% Identik & Konsisten dengan PostDetailPage) */}
      <header className="sticky top-0 inset-x-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between">
        {/* Left: Standard Back Button */}
        <button
          type="button"
          onClick={handleBackClick}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 active:scale-90 transition-all cursor-pointer"
          aria-label="Kembali ke postingan"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
        </button>

        {/* Center: Title */}
        <div className="flex-1 min-w-0 text-center px-2">
          <h1 className="font-bold text-[15.5px] text-slate-900 truncate">
            Checkout Pesanan
          </h1>
        </div>

        {/* Right: Like Button */}
        <button
          type="button"
          onClick={handleToggleLike}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 active:scale-90 transition-all cursor-pointer"
          aria-label="Simpan Favorit"
        >
          <Heart
            className={`w-5 h-5 transition-transform duration-200 ${
              isLiked ? 'fill-rose-500 text-rose-500 scale-110' : 'text-slate-800 stroke-[2]'
            }`}
          />
        </button>
      </header>

      {/* 2. TOP HERO SECTION (Clean Photo Carousel Tanpa Tombol Tumpuk) */}
      <CheckoutHeroImage
        images={images}
        title={post.title || post.caption}
      />

      {/* 2. FORM CONTAINER (Tema Terang Bersih & Konsisten) */}
      <div className="px-3.5 pb-8 -mt-1">
        <div className="bg-neutral-50/60 rounded-[28px] border border-neutral-200/80 p-5 shadow-2xs space-y-5">
          {/* A. Product Info Header (Category, Rating, Title, Location) */}
          <CheckoutProductHeader post={post} />

          {/* B. Product Description with Read More */}
          <CheckoutDescription description={post.description || post.caption} />

          {/* C. Seller Contact Card (Avatar, Name, In-App Kumo Profile & Chat) */}
          <CheckoutSellerCard
            seller={post.seller}
            productTitle={post.title || post.caption}
            productPrice={post.price || 0}
            onUserClick={onUserClick}
          />

          {/* Step berikutnya (Denah & Floating Bottom Bar) akan di-slicing di bawah ini */}
        </div>
      </div>
    </div>
  );
};
