import React from 'react';
import { Home, Search, Plus, Heart, User } from 'lucide-react';

interface ThreadsBottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  onPostClick?: () => void;
}

export const ThreadsBottomNav: React.FC<ThreadsBottomNavProps> = ({
  activeTab,
  onTabChange,
  onPostClick,
}) => {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-pure-white/95 backdrop-blur-md border-t border-neutral-200/90 shadow-lg font-gt-standard">
      <div className="max-w-xl mx-auto flex items-center justify-around h-14 px-2">
        {/* 1. Home Icon */}
        <button
          onClick={() => onTabChange('home')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer ${
            activeTab === 'home' ? 'text-slate-900' : 'text-neutral-400 hover:text-slate-600'
          }`}
          aria-label="Home Feed"
        >
          <Home className={`w-6 h-6 ${activeTab === 'home' ? 'stroke-[2.5]' : 'stroke-2'}`} />
        </button>

        {/* 2. Search / Explore Icon */}
        <button
          onClick={() => onTabChange('search')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer ${
            activeTab === 'search' ? 'text-slate-900' : 'text-neutral-400 hover:text-slate-600'
          }`}
          aria-label="Cari Produk"
        >
          <Search className={`w-6 h-6 ${activeTab === 'search' ? 'stroke-[2.5]' : 'stroke-2'}`} />
        </button>

        {/* 3. Center Threads Plus / Post Jualan Button */}
        <button
          onClick={onPostClick || (() => onTabChange('post'))}
          className="flex items-center justify-center w-11 h-10 rounded-2xl bg-neutral-100 border border-neutral-300 text-slate-900 shadow-2xs hover:bg-neutral-200 active:scale-95 transition-all cursor-pointer"
          aria-label="Jual Produk Baru"
        >
          <Plus className="w-6 h-6 text-slate-900 stroke-[2.5]" />
        </button>

        {/* 4. Activity / Notif Icon */}
        <button
          onClick={() => onTabChange('activity')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer relative ${
            activeTab === 'activity' ? 'text-slate-900' : 'text-neutral-400 hover:text-slate-600'
          }`}
          aria-label="Aktivitas Notifikasi"
        >
          <Heart className={`w-6 h-6 ${activeTab === 'activity' ? 'stroke-[2.5]' : 'stroke-2'}`} />
          {/* Red Dot Badge */}
          <span className="absolute top-3 right-5 w-2 h-2 rounded-full bg-rose-500 ring-2 ring-white" />
        </button>

        {/* 5. Profile Icon */}
        <button
          onClick={() => onTabChange('profile')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer ${
            activeTab === 'profile' ? 'text-slate-900' : 'text-neutral-400 hover:text-slate-600'
          }`}
          aria-label="Profil Akun"
        >
          <User className={`w-6 h-6 ${activeTab === 'profile' ? 'stroke-[2.5]' : 'stroke-2'}`} />
        </button>
      </div>
    </nav>
  );
};
