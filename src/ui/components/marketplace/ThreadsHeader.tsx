import React, { useState } from 'react';
import { Search, ShoppingCart, Store, X } from 'lucide-react';

interface ThreadsHeaderProps {
  cartCount: number;
  cartTotal?: number;
  onSearchChange?: (query: string) => void;
}

export const ThreadsHeader: React.FC<ThreadsHeaderProps> = ({
  cartCount,
  cartTotal: _cartTotal = 0,
  onSearchChange,
}) => {
  const [showSearchInput, setShowSearchInput] = useState(false);
  const [searchValue, setSearchValue] = useState('');

  const handleSearchChange = (val: string) => {
    setSearchValue(val);
    onSearchChange?.(val);
  };

  return (
    <header className="fixed top-0 left-0 right-0 z-40 bg-pure-white/90 backdrop-blur-xl border-b border-neutral-200/60 shadow-2xs font-gt-standard">
      {/* Top Main Bar: [ Left: Cart ] --- [ Center: Logo Title ] --- [ Right: Search ] */}
      <div className="max-w-xl mx-auto px-4 h-14 flex items-center justify-between gap-3 relative select-none">
        {/* Left Side: Cart Icon Only */}
        <div className="flex items-center">
          <button
            type="button"
            className="w-10 h-10 rounded-full flex items-center justify-center text-slate-800 hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer relative"
            aria-label="Keranjang Belanja"
          >
            <ShoppingCart className="w-5 h-5 text-slate-900 stroke-[2.25]" />
            {cartCount > 0 && (
              <span className="absolute top-2 right-2 w-2.5 h-2.5 rounded-full bg-[#1d64ec] ring-2 ring-white animate-pulse" />
            )}
          </button>
        </div>

        {/* Center: Logo Only (No Text) with Micro Hover Effect */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
          <button
            type="button"
            onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
            className="w-9 h-9 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-xs hover:scale-105 active:scale-95 transition-all duration-200 cubic-bezier(0.16,1,0.3,1) cursor-pointer"
            aria-label="Snapan Market Logo"
          >
            <Store className="w-5 h-5 text-white stroke-[2.25]" />
          </button>
        </div>

        {/* Right Side: Search Toggle Button */}
        <div className="flex items-center">
          <button
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
