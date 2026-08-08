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
  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'messages', label: 'Pesan', icon: Send, hasBadge: true },
    { id: 'post', label: 'Jual', icon: Plus, isAction: true },
    { id: 'activity', label: 'Aktivitas', icon: Heart },
    { id: 'profile', label: 'Profil', icon: User },
  ];

  return (
    <div className="fixed bottom-4 left-4 right-4 max-w-md mx-auto z-50 font-gt-standard select-none">
      {/* Floating White Pill Dock Container */}
      <nav className="bg-white/95 backdrop-blur-xl border border-neutral-200/80 p-1.5 rounded-full shadow-[0_12px_40px_rgba(0,0,0,0.12)] flex items-center justify-around">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;

          // Center Plus Action Button: Floating / Elevated with NO Label
          if (item.isAction) {
            return (
              <button
                key={item.id}
                type="button"
                onClick={onPostClick || (() => onTabChange('post'))}
                className="w-10 h-10 rounded-full bg-[#18181b] hover:bg-black active:scale-90 text-white flex items-center justify-center shadow-md border border-black/20 transition-all cursor-pointer shrink-0 -my-1"
                aria-label="Jual Produk Baru"
                title="Jual Produk Baru"
              >
                <Plus className="w-5 h-5 stroke-[2.5]" />
              </button>
            );
          }

          // Solid Icon Filling on Active State
          const isHeart = item.id === 'activity';
          const iconFillClass = isActive
            ? isHeart
              ? 'fill-rose-500 text-rose-500 stroke-[2]'
              : 'fill-slate-900 text-slate-900 stroke-[2]'
            : 'stroke-[1.75] text-neutral-400 fill-transparent';

          return (
            <button
              key={item.id}
              type="button"
              onClick={() => onTabChange(item.id)}
              className={`flex flex-col items-center justify-center px-4 py-1.5 rounded-full transition-all duration-200 cursor-pointer active:scale-95 relative ${
                isActive
                  ? 'bg-neutral-200/70 text-slate-900 font-semibold'
                  : 'bg-transparent text-neutral-400 hover:text-slate-900 font-normal'
              }`}
              aria-label={item.label}
            >
              <div className="relative flex items-center justify-center">
                <Icon
                  className={`w-5 h-5 transition-all ${iconFillClass}`}
                />
                {item.hasBadge && (
                  <span className="absolute -top-1 -right-2.5 min-w-[14px] h-[14px] px-1 rounded-full bg-rose-500 text-white text-[9px] font-bold flex items-center justify-center leading-none ring-2 ring-white">
                    1
                  </span>
                )}
              </div>
              <span className={`text-[10.5px] mt-0.5 leading-none ${isActive ? 'font-semibold text-slate-900' : 'font-normal text-neutral-400'}`}>
                {item.label}
              </span>
            </button>
          );
        })}
      </nav>
    </div>
  );
};
