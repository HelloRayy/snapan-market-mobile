import React, { useState, useEffect, useRef } from 'react';
import { Loader2, Sparkles } from 'lucide-react';
import { MarketHeader } from '../components/marketplace/MarketHeader';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { MarketBottomNav } from '../components/marketplace/MarketBottomNav';
import { CreatePostModal } from '../components/marketplace/CreatePostModal';
import { InstallBanner } from '../components/pwa/InstallBanner';
import { OfflineBanner } from '../components/pwa/OfflineBanner';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
import { MarketPostItem } from '@/types/marketFeed';
import { useCartStore } from '../store/cartStore';
import { useAuth } from '../hooks/useAuth';
import { getMarketPosts, createMarketPost } from '@/services/api/marketPostsService';
import type { MarketPostWithSeller } from '@/types/supabase';

interface HomePageProps {
  onSelectPost?: (post: MarketPostItem) => void;
  onNavigateToProfile?: (username: string) => void;
  onNavigateSearch?: () => void;
  onOpenMenu?: () => void;
}

export const HomePage: React.FC<HomePageProps> = ({
  onSelectPost,
  onNavigateToProfile,
  onNavigateSearch,
  onOpenMenu,
}) => {
  const [feedTab, setFeedTab] = useState<'for-you' | 'latest'>('for-you');
  const [bottomNavTab, setBottomNavTab] = useState('home');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Create Post Modal State (1-Tap Zero Friction Trigger)
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [selectedPostMode, setSelectedPostMode] = useState<'thread' | 'product'>('thread');

  // Items State & Infinite Scroll Loading
  const [items, setItems] = useState<MarketPostItem[]>(MOCK_MARKET_POSTS);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [page, setPage] = useState(1);
  const observerTargetRef = useRef<HTMLDivElement>(null);

  // Fetch Supabase Backend Posts on Mount
  useEffect(() => {
    async function loadSupabasePosts() {
      try {
        const supabasePosts = await getMarketPosts();
        if (supabasePosts && supabasePosts.length > 0) {
          const mappedPosts: MarketPostItem[] = supabasePosts.map((p: MarketPostWithSeller) => ({
            id: p.id,
            caption: p.caption,
            price: p.price ?? 0,
            originalPrice: p.original_price ?? undefined,
            category: (p.category as MarketPostItem['category']) || 'Lainnya',
            images: p.images || [],
            stock: p.stock ?? 1,
            locationTag: p.location_tag || undefined,
            likesCount: p.likes_count || 0,
            commentsCount: p.comments_count || 0,
            repostsCount: 0,
            timestamp: new Date(p.created_at).toLocaleDateString('id-ID', {
              hour: '2-digit',
              minute: '2-digit'
            }),
            isLiked: p.is_liked_by_user,
            seller: {
              id: p.seller?.id || p.seller_id,
              name: p.seller?.full_name || 'Penjual Snapan',
              avatar:
                p.seller?.avatar_url ||
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
              classGroup: p.seller?.class_group || 'Siswa Snapan',
              isVerified: p.seller?.is_verified ?? false,
              username: p.seller?.full_name
                ? p.seller.full_name.toLowerCase().replace(/\s+/g, '')
                : 'seller'
            }
          }));

          // Merge Supabase posts with mock posts (Supabase posts at the top)
          setItems((prev) => {
            const existingIds = new Set(mappedPosts.map((mp) => mp.id));
            const filteredMock = prev.filter((item) => !existingIds.has(item.id));
            return [...mappedPosts, ...filteredMock];
          });
        }
      } catch (err) {
        console.warn('Supabase fetch bypassed, using mock data:', err);
      }
    }

    loadSupabasePosts();
  }, []);

  // Auth Hook Integration
  const { user, profile } = useAuth();

  // Cart Store Integration
  const addItemToCart = useCartStore((state) => state.addItem);
  const totalCartItems = useCartStore((state) => state.getTotalItems());
  const totalCartPrice = useCartStore((state) => state.getTotalPrice());

  // Handle Create New Post
  const handleCreatePost = async (newPostData: Partial<MarketPostItem>) => {
    const activeSellerId = profile?.id || user?.id || 'current-user-id';
    const activeSellerName = profile?.full_name || user?.user_metadata?.full_name || 'radityarayhannnn';
    const activeSellerAvatar = profile?.avatar_url || user?.user_metadata?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80';
    const activeSellerClass = profile?.class_group || 'XII PPLG 1';

    const isProduct = newPostData.postType === 'product';

    const createdPost: MarketPostItem = {
      id: `post-user-${Date.now()}`,
      postType: isProduct ? 'product' : 'thread',
      seller: {
        id: activeSellerId,
        name: activeSellerName,
        avatar: activeSellerAvatar,
        classGroup: activeSellerClass,
        isVerified: true,
        username: activeSellerName.toLowerCase().replace(/\s+/g, ''),
      },
      caption: newPostData.caption || '',
      title: newPostData.title,
      description: newPostData.description,
      price: isProduct ? (newPostData.price ?? 50000) : undefined,
      originalPrice: isProduct ? newPostData.originalPrice : undefined,
      category: isProduct ? (newPostData.category || 'Jasa DKV/PPLG') : undefined,
      images: newPostData.images || [],
      stock: isProduct ? (newPostData.stock ?? 1) : undefined,
      locationTag: newPostData.locationTag || undefined,
      topicTag: newPostData.topicTag,
      isOfficialTopic: newPostData.isOfficialTopic,
      topicIcon: newPostData.topicIcon,
      threadChain: newPostData.threadChain,
      totalThreadParts: newPostData.totalThreadParts,
      likesCount: 0,
      commentsCount: 0,
      repostsCount: 0,
      timestamp: 'Baru saja',
      isLiked: false,
    };

    // Update UI immediately (Optimistic UI)
    setItems((prev) => [createdPost, ...prev]);

    // Reset search query and switch to for-you tab so new post is immediately shown
    setSearchQuery('');
    setFeedTab('for-you');
    setIsNavVisible(true);

    // Smoothly scroll to the very top so the user immediately sees their own post
    setTimeout(() => {
      window.scrollTo({ top: 0, left: 0, behavior: 'smooth' });
    }, 50);

    // Send to Supabase Backend
    try {
      if (user?.id) {
        await createMarketPost({
          seller_id: user.id,
          caption: newPostData.caption || '',
          images: newPostData.images || [],
          stock: newPostData.stock || 1,
          price: newPostData.price || 0,
          category: newPostData.category || 'Umum',
          location_tag: newPostData.locationTag || undefined,
        });
      }
    } catch (err) {
      console.warn('Supabase post creation error:', err);
    }
  };

  // Handle Add To Cart from Post Card
  const handleAddToCart = (postItem: MarketPostItem) => {
    addItemToCart(
      {
        id: postItem.id,
        name: postItem.caption.slice(0, 40) + '...',
        slug: postItem.id,
        description: postItem.caption,
        price: postItem.price ?? 0,
        originalPrice: postItem.originalPrice,
        stock: postItem.stock ?? 1,
        rating: 4.9,
        soldCount: 15,
        category: postItem.category ?? 'Lainnya',
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

  // Smart Scroll Header & Bottom Nav Visibility State (rAF Throttled, Zero-Glitch Deadband & Overscroll Safe)
  const [isNavVisible, setIsNavVisible] = useState(true);
  const lastScrollY = useRef(0);
  const isTicking = useRef(false);

  useEffect(() => {
    const handleScroll = () => {
      if (isTicking.current) return;
      isTicking.current = true;

      requestAnimationFrame(() => {
        isTicking.current = false;
        const currentScrollY = Math.max(0, window.scrollY);
        const scrollDiff = currentScrollY - lastScrollY.current;
        const maxScrollY = document.documentElement.scrollHeight - window.innerHeight;

        // 1. Always keep visible when near the top (< 60px) or on top overscroll bounce
        if (currentScrollY <= 60) {
          setIsNavVisible(true);
        }
        // 2. Ignore bottom elastic overscroll bounce (iOS Safari / Android Chrome)
        else if (currentScrollY >= maxScrollY - 20) {
          // Keep current state, ignore bottom bounce jitter
        }
        // 3. Scrolling DOWN with positive intention (> 12px) -> hide smoothly
        else if (scrollDiff > 12) {
          setIsNavVisible(false);
        }
        // 4. Scrolling UP with micro-intention (< -4px) -> reveal instantly
        else if (scrollDiff < -4) {
          setIsNavVisible(true);
        }

        lastScrollY.current = currentScrollY;
      });
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  return (
    <div
      className="min-h-screen bg-white text-slate-ink pb-28 font-gt-standard select-none"
      style={{
        paddingTop: 'calc(50px + env(safe-area-inset-top, 0px))',
      }}
    >
      <OfflineBanner />
      <InstallBanner />

      {/* Fixed Top Header (Zero-Layout-Shift 100% GPU Slide) */}
      <div
        className={`fixed top-0 left-0 right-0 z-30 bg-white/95 backdrop-blur-md border-b border-neutral-200/40 select-none transition-transform duration-300 ease-[cubic-bezier(0.25,1,0.5,1)] transform-gpu ${
          isNavVisible ? 'translate-y-0' : '-translate-y-full pointer-events-none'
        }`}
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
        }}
      >
        <MarketHeader
          cartCount={totalCartItems}
          cartTotal={totalCartPrice}
          onMenuClick={onOpenMenu}
          onSearchClick={onNavigateSearch}
          onSearchChange={(query) => setSearchQuery(query)}
        />
      </div>

      {/* Non-Sticky Scrollable Tab Switcher ("Untuk Anda" & "Terbaru" - Scrolls naturally with feed) */}
      <div className="w-full border-b border-neutral-200/80 bg-white select-none">
        <div className="max-w-xl mx-auto flex items-center relative">
          {/* Smooth Sliding Underline Bar */}
          <div
            className={`absolute bottom-0 left-0 w-1/2 h-[2px] bg-slate-900 transition-transform duration-200 cubic-bezier(0.25,1,0.5,1) ${
              feedTab === 'for-you' ? 'translate-x-0' : 'translate-x-full'
            }`}
          />

          <button
            type="button"
            onClick={() => setFeedTab('for-you')}
            className={`flex-1 py-3 text-[14.5px] text-center relative cursor-pointer transition-colors ${
              feedTab === 'for-you' ? 'text-slate-900 font-bold' : 'text-neutral-400 hover:text-slate-700 font-medium'
            }`}
          >
            Untuk Anda
          </button>

          <button
            type="button"
            onClick={() => setFeedTab('latest')}
            className={`flex-1 py-3 text-[14.5px] text-center relative cursor-pointer transition-colors ${
              feedTab === 'latest' ? 'text-slate-900 font-bold' : 'text-neutral-400 hover:text-slate-700 font-medium'
            }`}
          >
            Terbaru
          </button>
        </div>
      </div>

      {/* Main Threads Feed Container (0px padding, no purple gap) */}
      <main className="max-w-xl mx-auto divide-y divide-neutral-200 pt-0">



        {/* Feed List Items */}
        {filteredItems.length > 0 ? (
          filteredItems.map((item) => (
            <MarketPostCard
              key={item.id}
              item={item}
              onAddToCart={handleAddToCart}
              onPostClick={onSelectPost}
              onUserClick={(username) => onNavigateToProfile?.(username)}
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

      {/* Market 5-Icon Bottom Navigation (1-Tap Direct Trigger with Smart Scroll Auto-Hide) */}
      <MarketBottomNav
        activeTab={bottomNavTab}
        isVisible={isNavVisible}
        userAvatar={profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'}
        onTabChange={(tab) => {
          if (tab === 'profile') {
            onNavigateToProfile?.(profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn');
          } else {
            setBottomNavTab(tab);
          }
        }}
        onPostClick={() => {
          setSelectedPostMode('thread');
          setIsCreateModalOpen(true);
        }}
      />

      {/* Create New Post Full-Screen Modal (with Bottom Segmented Slider) */}
      <CreatePostModal
        isOpen={isCreateModalOpen}
        initialMode={selectedPostMode}
        onClose={() => setIsCreateModalOpen(false)}
        onSubmitPost={handleCreatePost}
      />
    </div>
  );
};
