import React, { useState } from 'react';
import { Search, ShoppingBag, Store, X } from 'lucide-react';

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
    <header className="fixed top-0 left-0 right-0 z-40 bg-pure-white/95 backdrop-blur-md border-b border-neutral-200/80 shadow-2xs font-gt-standard">
      {/* Top Main Bar: [ Left: Cart ] --- [ Center: Logo Title ] --- [ Right: Search ] */}
      <div className="max-w-xl mx-auto px-4 h-14 flex items-center justify-between gap-3 relative select-none">
        {/* Left Side: Cart Icon Only */}
        <div className="flex items-center">
          <button
            type="button"
            className="w-9 h-9 rounded-full flex items-center justify-center text-slate-700 hover:bg-neutral-100 active:scale-95 transition-all cursor-pointer relative"
            aria-label="Keranjang Belanja"
          >
            <ShoppingBag className="w-5 h-5 text-slate-900 stroke-[2]" />
            {cartCount > 0 && (
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-[#1d64ec]" />
            )}
          </button>
        </div>

        {/* Center: Logo Only (No Text) */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
          <div className="w-8 h-8 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-2xs">
            <Store className="w-4.5 h-4.5 text-white" />
          </div>
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
            className="w-9 h-9 rounded-full flex items-center justify-center text-slate-700 hover:bg-neutral-100 active:scale-95 transition-all cursor-pointer"
            aria-label="Cari Produk"
          >
            {showSearchInput ? (
              <X className="w-5 h-5 text-slate-900" />
            ) : (
              <Search className="w-5 h-5 text-slate-900 stroke-[2]" />
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
