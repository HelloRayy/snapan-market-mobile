import React, { useState } from 'react';
import { Search, Menu, X } from 'lucide-react';

// Custom Snapan Logotype Text Header
export const SnapanLogotype: React.FC<{ className?: string }> = ({
  className = "text-[17px] font-black tracking-[-0.03em] text-slate-900 select-none",
}) => (
  <span className={className}>
    Snapan <span className="text-[#008bff]">Market</span>
  </span>
);

// Backward compatible export
export const SnapanBrandMark = SnapanLogotype;

interface MarketHeaderProps {
  cartCount?: number;
  cartTotal?: number;
  onSearchChange?: (query: string) => void;
  onSearchClick?: () => void;
  onMenuClick?: () => void;
  onProfileClick?: () => void;
  userAvatar?: string;
}

export const MarketHeader: React.FC<MarketHeaderProps> = ({
  cartCount: _cartCount = 0,
  cartTotal: _cartTotal = 0,
  onSearchChange,
  onSearchClick,
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
    <header className="w-full z-30 font-gt-standard bg-white/70 backdrop-blur-xl select-none max-h-[60px]">
      {/* Top Main Bar: Max Height 60px, Compact Sleek 52px */}
      <div className="max-w-xl mx-auto px-3.5 h-[52px] max-h-[60px] flex items-center justify-between relative select-none">
        {/* Leading Button (Clean Lucide Menu Icon) */}
        <div className="flex items-center">
          <button
            type="button"
            onClick={onMenuClick || onProfileClick}
            className="w-10 h-10 flex items-center justify-center text-[#1a1a1a] hover:opacity-70 active:scale-90 transition-all cursor-pointer"
            aria-label="Menu"
          >
            <Menu className="w-5 h-5 stroke-[2.2]" />
          </button>
        </div>

        {/* Center Title (Snaps.) */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
          <button
            type="button"
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="flex items-center justify-center hover:opacity-85 active:scale-[0.98] transition-transform duration-100 cursor-pointer"
            aria-label="Snaps."
          >
            <span className="text-[16.5px] font-bold tracking-tight text-[#1a1a1a] select-none">
              Snaps.
            </span>
          </button>
        </div>

        {/* Trailing Button (Clean Lucide Search Icon) */}
        <div className="flex items-center">
          <button
            type="button"
            onClick={() => {
              if (onSearchClick) {
                onSearchClick();
              } else {
                setShowSearchInput(!showSearchInput);
                if (showSearchInput) {
                  handleSearchChange('');
                }
              }
            }}
            className="w-10 h-10 flex items-center justify-center text-[#1a1a1a] hover:opacity-70 active:scale-90 transition-all cursor-pointer"
            aria-label="Cari"
          >
            {showSearchInput ? (
              <X className="w-5 h-5 stroke-[2.2]" />
            ) : (
              <Search className="w-5 h-5 stroke-[2.2]" />
            )}
          </button>
        </div>
      </div>

      {/* Collapsible Threads-Style Capsule Search Input Row */}
      {showSearchInput && (
        <div className="max-w-xl mx-auto px-3.5 pb-2.5 animate-in fade-in slide-in-from-top-2 duration-200">
          <div className="flex items-center pl-2.5 pr-2 bg-neutral-100/90 text-slate-900 rounded-[22px] h-11 leading-snug border border-neutral-200/70 focus-within:bg-white focus-within:border-slate-400 focus-within:shadow-2xs transition-all">
            <div className="w-8 h-8 flex items-center justify-center text-neutral-400 shrink-0 mr-1">
              <Search className="w-4.5 h-4.5 stroke-[2.2]" />
            </div>
            <input
              type="text"
              autoFocus
              placeholder="Cari postingan, produk, jajanan, atau akun..."
              value={searchValue}
              onChange={(e) => handleSearchChange(e.target.value)}
              className="bg-transparent text-slate-900 placeholder:text-neutral-400 outline-none flex-1 text-[16px] sm:text-[15px] font-normal leading-snug h-full px-1"
            />
            {searchValue && (
              <button
                type="button"
                onClick={() => handleSearchChange('')}
                className="w-7 h-7 rounded-full flex items-center justify-center text-neutral-400 hover:text-slate-800 hover:bg-neutral-200/60 active:scale-90 transition-all cursor-pointer shrink-0 ml-1"
                aria-label="Hapus Pencarian"
              >
                <X className="w-4 h-4 stroke-[2.5]" />
              </button>
            )}
          </div>
        </div>
      )}
    </header>
  );
};
