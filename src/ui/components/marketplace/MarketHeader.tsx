import React, { useState } from 'react';
import { Search, X, Menu } from 'lucide-react';

// Custom Snapan Brand Mark (Threads-style aesthetic spiral)
export const SnapanBrandMark: React.FC<{ className?: string }> = ({ className = "w-8 h-8 text-slate-900 fill-current" }) => (
  <svg className={className} viewBox="0 0 192 192">
    <path d="M141.537 88.9883C140.71 88.5919 139.87 88.2104 139.019 87.8451C137.537 60.5382 122.616 44.905 97.4619 44.905C71.5646 44.905 52.8877 62.9099 52.8877 91.0772C52.8877 119.245 71.5646 137.25 97.4619 137.25C118.591 137.25 133.513 125.795 137.896 108.577H120.301C117.29 116.945 108.793 122.181 97.4619 122.181C80.2079 122.181 68.966 110.158 68.966 91.0772C68.966 71.9967 80.2079 59.9734 97.4619 59.9734C114.716 59.9734 123.633 72.1797 124.629 91.0772C124.646 91.4116 124.654 91.7483 124.654 92.0872C124.654 104.301 117.818 111.455 107.618 111.455C97.4173 111.455 90.5815 104.301 90.5815 92.0872C90.5815 79.8735 97.4173 72.7196 107.618 72.7196C112.569 72.7196 116.896 74.8875 119.544 78.4354C120.89 74.4534 122.617 70.8354 124.698 67.6669C120.548 62.7766 114.512 59.9734 107.618 59.9734C87.9733 59.9734 75.3188 74.1953 75.3188 92.0872C75.3188 109.979 87.9733 124.201 107.618 124.201C125.795 124.201 139.73 111.455 139.73 92.0872C139.73 91.0379 139.664 89.9995 139.537 88.9883H141.537Z" />
  </svg>
);

interface MarketHeaderProps {
  cartCount?: number;
  cartTotal?: number;
  onSearchChange?: (query: string) => void;
  onMenuClick?: () => void;
  onProfileClick?: () => void;
  userAvatar?: string;
}

export const MarketHeader: React.FC<MarketHeaderProps> = ({
  cartCount: _cartCount = 0,
  cartTotal: _cartTotal = 0,
  onSearchChange,
  onMenuClick,
  onProfileClick,
}) => {
  const [showSearchInput, setShowSearchInput] = useState(false);
  const [searchValue, setSearchValue] = useState('');

  const handleSearchChange = (val: string) => {
    setSearchValue(val);
    onSearchChange?.(val);
  };

  return (
    <header className="relative w-full z-30 transition-all duration-200 font-gt-standard bg-white">
      {/* Top Main Bar: [ Left: Menu Icon ] --- [ Center: Logo Mark ] --- [ Right: Search Toggle ] */}
      <div className="max-w-xl mx-auto px-4 h-14 flex items-center justify-between gap-3 relative select-none">
        {/* Left Side: Hamburger Menu Button (for Drawer) */}
        <div className="flex items-center">
          <button
            type="button"
            onClick={onMenuClick || onProfileClick}
            className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
            aria-label="Buka Menu Drawer"
          >
            <Menu className="w-5 h-5 stroke-[2.25]" />
          </button>
        </div>

        {/* Center: Brand Mark Logo with Micro Hover/Tap Effect */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
          <button
            type="button"
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="flex items-center justify-center hover:scale-105 active:scale-95 transition-all duration-200 cubic-bezier(0.25,1,0.5,1) cursor-pointer"
            aria-label="Snapan Logo"
          >
            <SnapanBrandMark className="w-8 h-8 text-slate-900" />
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
