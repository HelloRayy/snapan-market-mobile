import React, { useState } from 'react';
import { Search, Store, X, User } from 'lucide-react';

interface MarketHeaderProps {
  cartCount?: number;
  cartTotal?: number;
  onSearchChange?: (query: string) => void;
  onProfileClick?: () => void;
  userAvatar?: string;
}

export const MarketHeader: React.FC<MarketHeaderProps> = ({
  cartCount: _cartCount = 0,
  cartTotal: _cartTotal = 0,
  onSearchChange,
  onProfileClick,
  userAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=256&auto=format&fit=crop',
}) => {
  const [showSearchInput, setShowSearchInput] = useState(false);
  const [searchValue, setSearchValue] = useState('');
  const [isScrolled, setIsScrolled] = useState(false);
  const [avatarError, setAvatarError] = useState(false);

  // Scroll listener for dynamic frosted glass blur & opacity
  React.useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 10) {
        setIsScrolled(true);
      } else {
        setIsScrolled(false);
      }
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleSearchChange = (val: string) => {
    setSearchValue(val);
    onSearchChange?.(val);
  };

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-40 transition-all duration-200 cubic-bezier(0.25,1,0.5,1) font-gt-standard ${
        isScrolled
          ? 'bg-[#fafafa]/85 backdrop-blur-xl border-b border-neutral-200/60 shadow-2xs'
          : 'bg-[#fafafa]/90 backdrop-blur-md border-b border-neutral-200/40'
      }`}
    >
      {/* Top Main Bar: [ Left: Profile Avatar ] --- [ Center: Store Logo ] --- [ Right: Search Toggle ] */}
      <div className="max-w-xl mx-auto px-4 h-14 flex items-center justify-between gap-3 relative select-none">
        {/* Left Side: User Profile Avatar Button */}
        <div className="flex items-center">
          <button
            type="button"
            onClick={onProfileClick}
            className="group relative flex items-center justify-center p-0.5 rounded-full hover:ring-2 hover:ring-blue-500/20 active:scale-95 transition-all duration-200 cursor-pointer"
            aria-label="Buka Profil Pengguna"
          >
            <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-300/80 shadow-2xs bg-neutral-100 flex items-center justify-center group-hover:border-[#1d64ec] transition-colors">
              {!avatarError && userAvatar ? (
                <img
                  src={userAvatar}
                  alt="Foto Profil Pengguna"
                  onError={() => setAvatarError(true)}
                  className="w-full h-full object-cover"
                />
              ) : (
                <User className="w-5 h-5 text-slate-700" />
              )}
            </div>
            {/* Online Green Active Indicator Badge */}
            <span className="absolute bottom-0 right-0 w-2.5 h-2.5 rounded-full bg-emerald-500 ring-2 ring-white" />
          </button>
        </div>

        {/* Center: Store Logo Button with Micro Hover Effect */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
          <button
            type="button"
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="w-9 h-9 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-xs hover:scale-105 active:scale-95 transition-all duration-200 cubic-bezier(0.25,1,0.5,1) cursor-pointer"
            aria-label="Snapan Market Logo"
          >
            <Store className="w-5 h-5 text-white stroke-[2.25]" />
          </button>
        </div>

        {/* Right Side: Search Toggle Button */}
        <div className="flex items-center">
          <button
            type="button"
            onClick={() => {
              setShowSearchInput(!showSearchInput);
              if (showSearchInput) {
                handleSearchChange('');
              }
            }}
            className="w-10 h-10 rounded-full flex items-center justify-center text-slate-800 hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer"
            aria-label="Cari Produk"
          >
            {showSearchInput ? (
              <X className="w-5 h-5 text-slate-900 stroke-[2.25]" />
            ) : (
              <Search className="w-5 h-5 text-slate-900 stroke-[2.25]" />
            )}
          </button>
        </div>
      </div>

      {/* Collapsible Search Input Row */}
      {showSearchInput && (
        <div className="max-w-xl mx-auto px-4 pb-2.5 animate-in fade-in slide-in-from-top-2 duration-200">
          <div className="relative flex items-center">
            <Search className="absolute left-3.5 w-4 h-4 text-neutral-400 pointer-events-none" />
            <input
              type="text"
              autoFocus
              placeholder="Cari jajanan kantin, barang DKV, aksesoris TJKT..."
              value={searchValue}
              onChange={(e) => handleSearchChange(e.target.value)}
              className="w-full pl-10 pr-4 py-2 text-sm rounded-xl border border-neutral-300 bg-neutral-50 text-slate-900 focus:bg-white focus:border-[#1d64ec] focus:outline-none focus:ring-2 focus:ring-blue-500/20 transition-all font-normal"
            />
          </div>
        </div>
      )}
    </header>
  );
};
