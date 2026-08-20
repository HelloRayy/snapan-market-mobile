import React, { useState } from 'react';
import { Search, X, Menu } from 'lucide-react';

// Custom Snapan Logotype Text Header
export const SnapanLogotype: React.FC<{ className?: string }> = ({
  className = "text-[18px] font-black tracking-[-0.03em] text-slate-900 select-none",
}) => (
  <span className={className}>
    Snapan <span className="text-[#1d64ec]">Market</span>
  </span>
);

// Backward compatible export
export const SnapanBrandMark = SnapanLogotype;

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
      {/* Top Main Bar: [ Left: Menu Icon ] --- [ Center: Logotype Text ] --- [ Right: Search Toggle ] */}
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

        {/* Center: Brand Logotype Text with Micro Hover/Tap Effect */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
          <button
            type="button"
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="flex items-center justify-center hover:opacity-85 active:scale-95 transition-all duration-200 cursor-pointer"
            aria-label="Snapan Market"
          >
            <SnapanLogotype />
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
