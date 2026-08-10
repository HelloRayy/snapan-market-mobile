import React, { useState, useEffect, useRef } from 'react';
import { Loader2, Sparkles } from 'lucide-react';
import { MarketHeader } from '../components/marketplace/MarketHeader';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { MarketBottomNav } from '../components/marketplace/MarketBottomNav';
import { InstallBanner } from '../components/pwa/InstallBanner';
import { OfflineBanner } from '../components/pwa/OfflineBanner';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
import { MarketPostItem } from '@/types/marketFeed';
import { useCartStore } from '../store/cartStore';

interface HomePageProps {
  onSelectPost?: (post: MarketPostItem) => void;
}

export const HomePage: React.FC<HomePageProps> = ({ onSelectPost }) => {
  const [feedTab, setFeedTab] = useState<'for-you' | 'latest'>('for-you');
  const [bottomNavTab, setBottomNavTab] = useState('home');
  const [searchQuery, setSearchQuery] = useState('');

  // Items State & Infinite Scroll Loading
  const [items, setItems] = useState<MarketPostItem[]>(MOCK_MARKET_POSTS);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [page, setPage] = useState(1);
  const observerTargetRef = useRef<HTMLDivElement>(null);

  // Cart Store Integration
  const addItemToCart = useCartStore((state) => state.addItem);
  const totalCartItems = useCartStore((state) => state.getTotalItems());
  const totalCartPrice = useCartStore((state) => state.getTotalPrice());

  // Handle Add To Cart from Post Card
  const handleAddToCart = (postItem: MarketPostItem) => {
    addItemToCart(
      {
        id: postItem.id,
        name: postItem.caption.slice(0, 40) + '...',
        slug: postItem.id,
        description: postItem.caption,
        price: postItem.price,
        originalPrice: postItem.originalPrice,
        stock: postItem.stock,
        rating: 4.9,
        soldCount: 15,
        category: postItem.category,
        images: postItem.images,
        sellerId: postItem.seller.id,
        sellerName: postItem.seller.name,
        isVerifiedSeller: postItem.seller.isVerified,
        createdAt: new Date().toISOString(),
      },
      1
    );
  };

  // Filtered Items
  const filteredItems = items.filter((item) => {
    return (
      item.caption.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.seller.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.seller.classGroup.toLowerCase().includes(searchQuery.toLowerCase())
    );
  });

  // Simulated Infinite Scroll Loader
  const loadMoreItems = () => {
    if (isLoadingMore) return;
    setIsLoadingMore(true);
    setTimeout(() => {
      // Append duplicated items with new unique IDs to simulate infinite feed
      const newBatch: MarketPostItem[] = MOCK_MARKET_POSTS.map((base, idx) => ({
        ...base,
        id: `post-auto-${page}-${idx}-${Date.now()}`,
        timestamp: `${page * 2}j lalu`,
        likesCount: base.likesCount + Math.floor(Math.random() * 10),
      }));
      setItems((prev) => [...prev, ...newBatch]);
      setPage((prev) => prev + 1);
      setIsLoadingMore(false);
    }, 1000);
  };

  // Intersection Observer for Infinite Scroll
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !isLoadingMore) {
          loadMoreItems();
        }
      },
      { threshold: 0.8 }
    );

    if (observerTargetRef.current) {
      observer.observe(observerTargetRef.current);
    }

    return () => observer.disconnect();
  }, [isLoadingMore, page]);

  return (
    <div className="min-h-screen bg-[#fafafa] text-slate-ink pb-28 font-gt-standard select-none">
      <OfflineBanner />
      <InstallBanner />

      {/* Market Sticky Header */}
      <MarketHeader
        cartCount={totalCartItems}
        cartTotal={totalCartPrice}
        onSearchChange={(query) => setSearchQuery(query)}
      />

      {/* Main Threads Feed Container (0px padding, no purple gap) */}
      <main className="max-w-xl mx-auto divide-y divide-neutral-200 pt-0">
        {/* Scrollable Tab Switcher ("Untuk Anda" & "Terbaru") - Sticky top-14 under header */}
        <div className="sticky top-14 z-30 flex items-center border-b border-neutral-200 select-none bg-[#fafafa]/90 backdrop-blur-md">
          {/* Smooth Sliding Bar (No Kedut/Flicker, Pure Slide) */}
          <div
            className={`absolute bottom-0 left-0 w-1/2 h-[2px] bg-slate-900 transition-transform duration-200 cubic-bezier(0.25,1,0.5,1) ${
              feedTab === 'for-you' ? 'translate-x-0' : 'translate-x-full'
            }`}
          />

          <button
            type="button"
            onClick={() => setFeedTab('for-you')}
            className={`flex-1 py-2.5 text-sm text-center relative cursor-pointer ${
              feedTab === 'for-you' ? 'text-slate-900 font-semibold' : 'text-slate-500 hover:text-slate-900 font-normal'
            }`}
          >
            Untuk Anda
          </button>

          <button
            type="button"
            onClick={() => setFeedTab('latest')}
            className={`flex-1 py-2.5 text-sm text-center relative cursor-pointer ${
              feedTab === 'latest' ? 'text-slate-900 font-semibold' : 'text-slate-500 hover:text-slate-900 font-normal'
            }`}
          >
            Terbaru
          </button>
        </div>



        {/* Feed List Items */}
        {filteredItems.length > 0 ? (
          filteredItems.map((item) => (
            <MarketPostCard
              key={item.id}
              item={item}
              onAddToCart={handleAddToCart}
              onPostClick={onSelectPost}
            />
          ))
        ) : (
          <div className="py-12 px-4 text-center space-y-2">
            <Sparkles className="w-8 h-8 text-neutral-300 mx-auto" />
            <p className="text-sm font-bold text-slate-900">Belum ada postingan produk</p>
            <p className="text-xs text-neutral-500 font-normal">
              Coba ganti kata kunci pencarian atau kategori di atas.
            </p>
          </div>
        )}

        {/* Infinite Scroll Observer Target Element & Loader */}
        <div
          ref={observerTargetRef}
          className="py-6 flex flex-col items-center justify-center gap-2 text-center text-xs text-neutral-400 font-medium"
        >
          {isLoadingMore ? (
            <div className="flex items-center gap-2 text-[#1d64ec] font-bold animate-pulse">
              <Loader2 className="w-4 h-4 animate-spin" />
              <span>Memuat postingan berikutnya...</span>
            </div>
          ) : (
            <span>Scroll ke bawah untuk memuat postingan baru</span>
          )}
        </div>
      </main>

      {/* Market 5-Icon Bottom Navigation */}
      <MarketBottomNav
        activeTab={bottomNavTab}
        onTabChange={(tab) => setBottomNavTab(tab)}
      />
    </div>
  );
};
