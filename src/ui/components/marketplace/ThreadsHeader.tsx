import React, { useState } from 'react';
import { Search, ShoppingBag, Store, X } from 'lucide-react';
import { formatRupiah } from '@/utils/formatters';

interface ThreadsHeaderProps {
  activeTab: 'for-you' | 'latest';
  onTabChange: (tab: 'for-you' | 'latest') => void;
  cartCount: number;
  cartTotal?: number;
  onSearchChange?: (query: string) => void;
}

export const ThreadsHeader: React.FC<ThreadsHeaderProps> = ({
  activeTab,
  onTabChange,
  cartCount,
  cartTotal = 0,
  onSearchChange,
}) => {
  const [showSearchInput, setShowSearchInput] = useState(false);
  const [searchValue, setSearchValue] = useState('');

  const handleSearchChange = (val: string) => {
    setSearchValue(val);
    onSearchChange?.(val);
  };

  return (
    <header className="sticky top-0 z-40 bg-pure-white/95 backdrop-blur-md border-b border-neutral-200/80 shadow-2xs font-gt-standard">
      {/* Top Main Bar: [ Left: Cart ] --- [ Center: Logo Title ] --- [ Right: Search ] */}
      <div className="max-w-xl mx-auto px-4 h-14 flex items-center justify-between gap-3 relative select-none">
        {/* Left Side: Cart Icon Badge */}
        <div className="flex items-center">
          <div className="relative flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-neutral-100/80 border border-neutral-200/80 text-xs font-semibold text-slate-800 shadow-2xs cursor-pointer hover:bg-neutral-200/60 active:scale-95 transition-all">
            <ShoppingBag className="w-4 h-4 text-[#1d64ec]" />
            <span className="font-semibold text-slate-900">{cartCount}</span>
            {cartCount > 0 && cartTotal > 0 && (
              <span className="hidden sm:inline text-neutral-500 font-normal ml-0.5">
                ({formatRupiah(cartTotal)})
              </span>
            )}
          </div>
        </div>

        {/* Center: Title / Logo with reduced font-weight (font-semibold / medium) */}
        <div className="absolute left-1/2 -translate-x-1/2 flex items-center gap-2">
          <div className="w-7 h-7 rounded-lg bg-slate-900 flex items-center justify-center text-white shadow-2xs">
            <Store className="w-3.5 h-3.5 text-white" />
          </div>
          <span className="font-semibold text-base text-slate-900 tracking-tight font-shopify-sans">
            Snapan<span className="text-[#1d64ec] font-normal">Market</span>
          </span>
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

      {/* Threads 2-Tab Navigation ("Untuk Anda" & "Terbaru") with reduced font-weight */}
      <div className="max-w-xl mx-auto flex items-center border-t border-neutral-100 select-none">
        <button
          onClick={() => onTabChange('for-you')}
          className={`flex-1 py-3 text-sm text-center relative transition-colors cursor-pointer ${
            activeTab === 'for-you' ? 'text-slate-900 font-semibold' : 'text-neutral-400 hover:text-slate-600 font-normal'
          }`}
        >
          Untuk Anda
          {activeTab === 'for-you' && (
            <span className="absolute bottom-0 left-1/4 right-1/4 h-0.5 bg-slate-900 rounded-full animate-in fade-in duration-200" />
          )}
        </button>

        <button
          onClick={() => onTabChange('latest')}
          className={`flex-1 py-3 text-sm text-center relative transition-colors cursor-pointer ${
            activeTab === 'latest' ? 'text-slate-900 font-semibold' : 'text-neutral-400 hover:text-slate-600 font-normal'
          }`}
        >
          Terbaru
          {activeTab === 'latest' && (
            <span className="absolute bottom-0 left-1/4 right-1/4 h-0.5 bg-slate-900 rounded-full animate-in fade-in duration-200" />
          )}
        </button>
      </div>
    </header>
  );
};
