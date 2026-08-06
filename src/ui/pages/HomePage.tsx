import React, { useState, useEffect, useRef } from 'react';
import { Loader2, Plus, Sparkles } from 'lucide-react';
import { ThreadsHeader } from '../components/marketplace/ThreadsHeader';
import { ThreadsPostCard } from '../components/marketplace/ThreadsPostCard';
import { ThreadsBottomNav } from '../components/marketplace/ThreadsBottomNav';
import { InstallBanner } from '../components/pwa/InstallBanner';
import { OfflineBanner } from '../components/pwa/OfflineBanner';
import { MOCK_THREADS_ITEMS } from '@/data/mockThreadsData';
import { MarketThreadItem } from '@/types/threadsFeed';
import { useCartStore } from '../store/cartStore';

export const HomePage: React.FC = () => {
  const [feedTab, setFeedTab] = useState<'for-you' | 'latest'>('for-you');
  const [bottomNavTab, setBottomNavTab] = useState('home');
  const [searchQuery, setSearchQuery] = useState('');

  // Items State & Infinite Scroll Loading
  const [items, setItems] = useState<MarketThreadItem[]>(MOCK_THREADS_ITEMS);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [page, setPage] = useState(1);
  const observerTargetRef = useRef<HTMLDivElement>(null);

  // Cart Store Integration
  const addItemToCart = useCartStore((state) => state.addItem);
  const totalCartItems = useCartStore((state) => state.getTotalItems());
  const totalCartPrice = useCartStore((state) => state.getTotalPrice());

  // Handle Add To Cart from Threads Post Card
  const handleAddToCart = (threadItem: MarketThreadItem) => {
    addItemToCart(
      {
        id: threadItem.id,
        name: threadItem.caption.slice(0, 40) + '...',
        slug: threadItem.id,
        description: threadItem.caption,
        price: threadItem.price,
        originalPrice: threadItem.originalPrice,
        stock: threadItem.stock,
        rating: 4.9,
        soldCount: 15,
        category: threadItem.category,
        images: threadItem.images,
        sellerId: threadItem.seller.id,
        sellerName: threadItem.seller.name,
        isVerifiedSeller: threadItem.seller.isVerified,
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
      const newBatch: MarketThreadItem[] = MOCK_THREADS_ITEMS.map((base, idx) => ({
        ...base,
        id: `thread-auto-${page}-${idx}-${Date.now()}`,
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
    <div className="min-h-screen bg-pure-white text-slate-ink pb-20 font-gt-standard select-none">
      <OfflineBanner />
      <InstallBanner />

      {/* Threads Sticky Header */}
      <ThreadsHeader
        cartCount={totalCartItems}
        cartTotal={totalCartPrice}
        onSearchChange={(query) => setSearchQuery(query)}
      />

      {/* Main Threads Feed Container with pt-14 for Fixed Header Offset */}
      <main className="max-w-xl mx-auto divide-y divide-neutral-100 pt-14">
        {/* Scrollable Tab Switcher ("Untuk Anda" & "Terbaru") - Scrolls away naturally under sticky header */}
        <div className="flex items-center border-b border-neutral-100 select-none bg-pure-white">
          <button
            type="button"
            onClick={() => setFeedTab('for-you')}
            className={`flex-1 py-3 text-sm text-center relative transition-colors cursor-pointer ${
              feedTab === 'for-you' ? 'text-slate-900 font-semibold' : 'text-neutral-400 hover:text-slate-600 font-normal'
            }`}
          >
            Untuk Anda
            {feedTab === 'for-you' && (
              <span className="absolute bottom-0 left-1/4 right-1/4 h-0.5 bg-slate-900 rounded-full animate-in fade-in duration-200" />
            )}
          </button>

          <button
            type="button"
            onClick={() => setFeedTab('latest')}
            className={`flex-1 py-3 text-sm text-center relative transition-colors cursor-pointer ${
              feedTab === 'latest' ? 'text-slate-900 font-semibold' : 'text-neutral-400 hover:text-slate-600 font-normal'
            }`}
          >
            Terbaru
            {feedTab === 'latest' && (
              <span className="absolute bottom-0 left-1/4 right-1/4 h-0.5 bg-slate-900 rounded-full animate-in fade-in duration-200" />
            )}
          </button>
        </div>

        {/* Start Posting Prompt Card (Threads Style Top Composer Bar) */}
        <div className="p-4 flex items-center justify-between gap-3 bg-neutral-50/30 border-b border-neutral-100">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-[#1d64ec] text-white flex items-center justify-center font-extrabold text-xs shadow-2xs">
              S8
            </div>
            <span className="text-xs font-medium text-neutral-400">
              Ada yang mau dijual di SMKN 8 hari ini?
            </span>
          </div>

          <button
            type="button"
            className="flex items-center gap-1 px-3 py-1.5 rounded-full bg-neutral-100 hover:bg-neutral-200 border border-neutral-200 text-xs font-bold text-slate-900 transition-all cursor-pointer"
          >
            <Plus className="w-3.5 h-3.5 text-[#1d64ec]" />
            <span>Posting</span>
          </button>
        </div>

        {/* Feed List Items */}
        {filteredItems.length > 0 ? (
          filteredItems.map((item) => (
            <ThreadsPostCard
              key={item.id}
              item={item}
              onAddToCart={handleAddToCart}
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
              <span>Memuat postingan Threads berikutnya...</span>
            </div>
          ) : (
            <span>Scroll ke bawah untuk memuat postingan baru</span>
          )}
        </div>
      </main>

      {/* Threads 5-Icon Bottom Navigation */}
      <ThreadsBottomNav
        activeTab={bottomNavTab}
        onTabChange={(tab) => setBottomNavTab(tab)}
      />
    </div>
  );
};
