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
}

export const HomePage: React.FC<HomePageProps> = ({ onSelectPost, onNavigateToProfile }) => {
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

    const createdPost: MarketPostItem = {
      id: `post-user-${Date.now()}`,
      seller: {
        id: activeSellerId,
        name: activeSellerName,
        avatar: activeSellerAvatar,
        classGroup: activeSellerClass,
        isVerified: true,
        username: activeSellerName.toLowerCase().replace(/\s+/g, ''),
      },
      caption: newPostData.caption || '',
      price: newPostData.price || 50000,
      category: newPostData.category || 'Jasa DKV/PPLG',
      images: newPostData.images && newPostData.images.length > 0 ? newPostData.images : ['https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80'],
      stock: newPostData.stock || 1,
      locationTag: newPostData.locationTag || 'Lab PPLG',
      topicTag: newPostData.topicTag,
      isOfficialTopic: newPostData.isOfficialTopic,
      topicIcon: newPostData.topicIcon,
      likesCount: 0,
      commentsCount: 0,
      repostsCount: 0,
      timestamp: 'Baru saja',
      isLiked: false,
    };

    // Update UI immediately (Optimistic UI)
    setItems((prev) => [createdPost, ...prev]);

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
          location_tag: newPostData.locationTag || 'SMKN 8',
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

  return (
    <div className="min-h-screen bg-white text-slate-ink pb-28 font-gt-standard select-none">
      <OfflineBanner />
      <InstallBanner />

      {/* Market Sticky Header */}
      <MarketHeader
        cartCount={totalCartItems}
        cartTotal={totalCartPrice}
        onSearchChange={(query) => setSearchQuery(query)}
      />

      {/* Scrollable Tab Switcher ("Untuk Anda" & "Terbaru") - Sticky top-0 under safe-area */}
      <div
        className="sticky top-0 z-30 w-full border-b border-neutral-200/80 select-none bg-white"
        style={{
          paddingTop: 'env(safe-area-inset-top, 0px)',
        }}
      >
        <div className="max-w-xl mx-auto flex items-center relative">
          {/* Smooth Sliding Bar (Pure Slide without flicker) */}
          <div
            className={`absolute bottom-0 left-0 w-1/2 h-[2px] bg-slate-900 transition-transform duration-200 cubic-bezier(0.25,1,0.5,1) ${
              feedTab === 'for-you' ? 'translate-x-0' : 'translate-x-full'
            }`}
          />

          <button
            type="button"
            onClick={() => setFeedTab('for-you')}
            className={`flex-1 py-3 text-[14px] text-center relative cursor-pointer transition-colors ${
              feedTab === 'for-you' ? 'text-slate-900 font-bold' : 'text-neutral-400 hover:text-slate-700 font-medium'
            }`}
          >
            Untuk Anda
          </button>

          <button
            type="button"
            onClick={() => setFeedTab('latest')}
            className={`flex-1 py-3 text-[14px] text-center relative cursor-pointer transition-colors ${
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

      {/* Market 5-Icon Bottom Navigation (1-Tap Direct Trigger) */}
      <MarketBottomNav
        activeTab={bottomNavTab}
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
