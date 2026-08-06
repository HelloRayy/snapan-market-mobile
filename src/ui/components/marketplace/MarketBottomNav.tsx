import React from 'react';
import { Home, Send, Plus, Heart, User } from 'lucide-react';

interface MarketBottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  onPostClick?: () => void;
}

export const MarketBottomNav: React.FC<MarketBottomNavProps> = ({
  activeTab,
  onTabChange,
  onPostClick,
}) => {
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-[#fafafa]/90 backdrop-blur-xl border-t border-neutral-200/80 font-gt-standard select-none pb-safe">
      <div className="max-w-xl mx-auto flex items-center justify-around h-[56px] px-3">
        {/* 1. Home Icon */}
        <button
          type="button"
          onClick={() => onTabChange('home')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer ${
            activeTab === 'home' ? 'text-slate-900' : 'text-slate-500 hover:text-slate-900'
          }`}
          aria-label="Home Feed"
        >
          <Home className={`w-5.5 h-5.5 ${activeTab === 'home' ? 'stroke-[2.5] fill-slate-900' : 'stroke-[1.75]'}`} />
        </button>

        {/* 2. Direct Messages / Explore (Send icon with badge '1') */}
        <button
          type="button"
          onClick={() => onTabChange('messages')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer relative ${
            activeTab === 'messages' ? 'text-slate-900' : 'text-slate-500 hover:text-slate-900'
          }`}
          aria-label="Pesan & Diskusi"
        >
          <div className="relative">
            <Send className={`w-5.5 h-5.5 ${activeTab === 'messages' ? 'stroke-[2.5]' : 'stroke-[1.75]'}`} />
            <span className="absolute -top-1 -right-2 min-w-[15px] h-[15px] px-1 rounded-full bg-rose-500 text-white text-[9px] font-bold flex items-center justify-center leading-none ring-2 ring-white">
              1
            </span>
          </div>
        </button>

        {/* 3. Center Threads Plus Button (Rounded Rectangle Pill) */}
        <div className="flex-1 flex items-center justify-center h-full">
          <button
            type="button"
            onClick={onPostClick || (() => onTabChange('post'))}
            className="flex items-center justify-center w-12 h-7.5 rounded-xl bg-neutral-200/70 hover:bg-neutral-300/80 active:scale-95 transition-all cursor-pointer"
            aria-label="Jual Produk Baru"
          >
            <Plus className="w-5 h-5 text-slate-800 stroke-[2.25]" />
          </button>
        </div>

        {/* 4. Activity / Notif Icon (Heart with Red Dot below) */}
        <button
          type="button"
          onClick={() => onTabChange('activity')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer ${
            activeTab === 'activity' ? 'text-slate-900' : 'text-slate-500 hover:text-slate-900'
          }`}
          aria-label="Aktivitas Notifikasi"
        >
          <div className="flex flex-col items-center">
            <Heart className={`w-5.5 h-5.5 ${activeTab === 'activity' ? 'stroke-[2.5] fill-rose-500 text-rose-500' : 'stroke-[1.75]'}`} />
            <span className="w-1 h-1 rounded-full bg-rose-500 mt-0.5" />
          </div>
        </button>

        {/* 5. Profile Icon */}
        <button
          type="button"
          onClick={() => onTabChange('profile')}
          className={`flex-1 flex flex-col items-center justify-center h-full active:scale-90 transition-all cursor-pointer ${
            activeTab === 'profile' ? 'text-slate-900' : 'text-slate-500 hover:text-slate-900'
          }`}
          aria-label="Profil Akun"
        >
          <User className={`w-5.5 h-5.5 ${activeTab === 'profile' ? 'stroke-[2.5]' : 'stroke-[1.75]'}`} />
        </button>
      </div>
    </nav>
  );
};
