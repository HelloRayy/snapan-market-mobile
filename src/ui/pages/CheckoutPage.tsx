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
  const [showStickyHeader, setShowStickyHeader] = useState<boolean>(false);
  const [isLiked, setIsLiked] = useState<boolean>(false);

  // Smooth scroll to top on mount
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: 'instant' });
  }, [post.id]);

  // Dynamic Scroll Listener: Fade in standard header bar when scrolled past hero photo
  useEffect(() => {
    const handleScroll = () => {
      setShowStickyHeader(window.scrollY > 150);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

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
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-28 max-w-[590px] mx-auto overflow-x-hidden animate-in fade-in duration-200 relative">
      {/* Dynamic Sticky Top Navigation Bar (Fades in when scrolled past hero photo) */}
      <header
        className={`fixed top-0 inset-x-0 max-w-[590px] mx-auto z-40 bg-white/95 backdrop-blur-md border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between transition-all duration-200 ${
          showStickyHeader
            ? 'opacity-100 translate-y-0 shadow-xs pointer-events-auto'
            : 'opacity-0 -translate-y-2 pointer-events-none'
        }`}
      >
        {/* Left: Standard Back Button */}
        <button
          type="button"
          onClick={handleBackClick}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 active:scale-90 transition-all cursor-pointer"
          aria-label="Kembali ke postingan"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
        </button>

        {/* Center: Truncated Title & Screen Context */}
        <div className="flex-1 min-w-0 text-center px-2">
          <h1 className="font-bold text-[14px] text-slate-900 truncate">
            {post.title || post.caption}
          </h1>
          <p className="text-[11px] text-slate-500 font-medium">
            Checkout Pesanan COD
          </p>
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

      {/* 1. TOP HERO SECTION (Foto Produk + Floating Squircle Back & Like) */}
      <CheckoutHeroImage
        images={images}
        title={post.title || post.caption}
        onBack={onBack}
        isLiked={isLiked}
        onToggleLike={handleToggleLike}
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
