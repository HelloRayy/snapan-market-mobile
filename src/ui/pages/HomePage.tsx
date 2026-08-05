import React, { useState } from 'react';
import { Search, ShoppingBag, LogIn, LogOut, Store } from 'lucide-react';
import { ProductCard } from '../components/marketplace/ProductCard';
import { MobileBottomNav } from '../components/marketplace/MobileBottomNav';
import { InstallBanner } from '../components/pwa/InstallBanner';
import { OfflineBanner } from '../components/pwa/OfflineBanner';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { Product } from '@/types/product';
import { useAuth } from '../hooks/useAuth';
import { useCartStore } from '../store/cartStore';
import { formatRupiah } from '@/utils/formatters';

// Sample Starter Products
const STARTER_PRODUCTS: Product[] = [
  {
    id: 'prod-1',
    name: 'Kemeja Oversized Premium Cotton Streetwear',
    slug: 'kemeja-oversized-premium',
    description: 'Kemeja casual berbahan katun impor yang nyaman dan adem.',
    price: 149000,
    originalPrice: 220000,
    stock: 25,
    rating: 4.8,
    soldCount: 340,
    category: 'Fashion',
    images: ['https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&q=80'],
    sellerId: 'sel-1',
    sellerName: 'Snapan Apparel Store',
    isVerifiedSeller: true,
    createdAt: new Date().toISOString()
  },
  {
    id: 'prod-2',
    name: 'Wireless Earbuds Active Noise Cancelling TWS',
    slug: 'wireless-earbuds-anc',
    description: 'Earbuds nirkabel dengan audio bass jernih & daya tahan baterai 24 jam.',
    price: 329000,
    originalPrice: 499000,
    stock: 12,
    rating: 4.9,
    soldCount: 890,
    category: 'Elektronik',
    images: ['https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&q=80'],
    sellerId: 'sel-2',
    sellerName: 'GadgetZone Indonesia',
    isVerifiedSeller: true,
    createdAt: new Date().toISOString()
  },
  {
    id: 'prod-3',
    name: 'Sepatu Sneakers Running Lightweight Unisex',
    slug: 'sepatu-sneakers-running',
    description: 'Sepatu olahraga ringan dengan bantalan empuk untuk lari harian.',
    price: 289000,
    originalPrice: 350000,
    stock: 18,
    rating: 4.7,
    soldCount: 520,
    category: 'Olahraga',
    images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80'],
    sellerId: 'sel-1',
    sellerName: 'Snapan Apparel Store',
    isVerifiedSeller: true,
    createdAt: new Date().toISOString()
  },
  {
    id: 'prod-4',
    name: 'Smart Watch Display AMOLED Health Monitor',
    slug: 'smart-watch-display-amoled',
    description: 'Jam tangan pintar dengan pemantau detak jantung, tidur & 100+ mode olahraga.',
    price: 450000,
    originalPrice: 699000,
    stock: 8,
    rating: 4.9,
    soldCount: 1200,
    category: 'Elektronik',
    images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80'],
    sellerId: 'sel-2',
    sellerName: 'GadgetZone Indonesia',
    isVerifiedSeller: true,
    createdAt: new Date().toISOString()
  }
];

export const HomePage: React.FC = () => {
  const [activeTab, setActiveTab] = useState('home');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const { user, isAuthenticated, signInWithGoogle, signOut } = useAuth();
  const totalCartItems = useCartStore((state) => state.getTotalItems());
  const totalCartPrice = useCartStore((state) => state.getTotalPrice());

  const categories = ['Semua', 'Fashion', 'Elektronik', 'Olahraga', 'Kecantikan'];

  const filteredProducts = STARTER_PRODUCTS.filter((prod) => {
    const matchesSearch = prod.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory =
      !selectedCategory || selectedCategory === 'Semua' || prod.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="min-h-screen pb-20 md:pb-8 bg-neutral-50 text-neutral-900">
      <OfflineBanner />
      <InstallBanner />

      {/* Header Bar */}
      <header className="sticky top-0 z-40 border-b border-neutral-200 bg-white/90 backdrop-blur-xl px-4 py-3 shadow-xs">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-black text-white font-bold shadow-md">
              <Store className="h-5 w-5" />
            </div>
            <div>
              <h1 className="text-base font-bold tracking-tight text-black">
                Snapan<span className="text-neutral-500">Market</span>
              </h1>
              <p className="text-[10px] text-neutral-500 font-medium">Marketplace PWA Mobile</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            {/* Cart Counter */}
            <div className="relative flex items-center gap-2 rounded-xl border border-neutral-200 bg-neutral-100 px-3 py-1.5 text-xs text-neutral-800 font-semibold">
              <ShoppingBag className="h-4 w-4 text-black" />
              <span>{totalCartItems}</span>
              {totalCartItems > 0 && (
                <span className="hidden sm:inline text-neutral-600 font-medium">
                  ({formatRupiah(totalCartPrice)})
                </span>
              )}
            </div>

            {/* Auth Action */}
            {isAuthenticated ? (
              <div className="flex items-center gap-2">
                <span className="hidden sm:inline text-xs font-medium text-neutral-700">
                  {user?.email?.split('@')[0]}
                </span>
                <Button size="sm" variant="ghost" onClick={signOut} title="Logout" className="text-neutral-700 hover:bg-neutral-100">
                  <LogOut className="h-4 w-4" />
                </Button>
              </div>
            ) : (
              <Button size="sm" variant="outline" onClick={signInWithGoogle} className="gap-1.5 border-black text-black hover:bg-neutral-100">
                <LogIn className="h-4 w-4" />
                <span className="hidden sm:inline">Login</span>
              </Button>
            )}
          </div>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="mx-auto max-w-6xl px-4 pt-4 space-y-6">
        {/* Search Bar */}
        <div className="relative">
          <Search className="absolute left-3.5 top-3 h-4 w-4 text-neutral-400" />
          <input
            type="text"
            placeholder="Cari produk impian di Snapan Market..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full rounded-2xl border border-neutral-200 bg-white pl-10 pr-4 py-2.5 text-sm text-neutral-900 placeholder:text-neutral-400 focus:border-black focus:outline-none focus:ring-2 focus:ring-black/10 transition-all shadow-xs"
          />
        </div>

        {/* Categories Bar */}
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-1">
          {categories.map((cat) => {
            const isActive =
              (cat === 'Semua' && !selectedCategory) || selectedCategory === cat;
            return (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat === 'Semua' ? null : cat)}
                className="shrink-0"
              >
                <Badge
                  variant={isActive ? 'slate' : 'slate'}
                  className={`px-3.5 py-1.5 text-xs font-bold cursor-pointer transition-all ${
                    isActive
                      ? 'bg-black text-white border-black shadow-md'
                      : 'bg-white text-neutral-700 border-neutral-200 hover:bg-neutral-100'
                  }`}
                >
                  {cat}
                </Badge>
              </button>
            );
          })}
        </div>

        {/* Product Grid */}
        <section className="space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="text-base font-bold text-neutral-900">Rekomendasi Produk</h2>
            <span className="text-xs text-neutral-500 font-medium">{filteredProducts.length} Produk</span>
          </div>

          <div className="grid grid-cols-2 gap-3.5 sm:grid-cols-3 md:grid-cols-4">
            {filteredProducts.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        </section>
      </main>

      {/* Mobile Bottom Navigation */}
      <MobileBottomNav activeTab={activeTab} onTabChange={(tab) => setActiveTab(tab)} />
    </div>
  );
};
