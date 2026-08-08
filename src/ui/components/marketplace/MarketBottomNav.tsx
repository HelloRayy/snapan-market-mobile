import React from 'react';
import { Home, Send, Plus, Heart, User } from 'lucide-react';
import { motion, LayoutGroup } from 'framer-motion';

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
      <nav className="bg-white/95 backdrop-blur-xl border border-neutral-200/80 p-1.5 rounded-full shadow-[0_12px_40px_rgba(0,0,0,0.12)] flex items-center justify-around relative">
        <LayoutGroup id="market-bottom-nav-group">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;

            // Center Plus Action Button: Elevated Kumo Primary Electric Blue Floating FAB
            if (item.isAction) {
              return (
                <div key={item.id} className="relative flex items-center justify-center shrink-0 w-11 h-9">
                  <button
                    type="button"
                    onClick={onPostClick || (() => onTabChange('post'))}
                    className="absolute -top-5 w-11.5 h-11.5 rounded-full bg-[#1d64ec] hover:bg-[#154ec1] border border-[#154ec1] active:scale-90 text-white flex items-center justify-center shadow-[0_8px_20px_rgba(29,100,236,0.4)] ring-4 ring-white transition-all cursor-pointer z-10 overflow-hidden group"
                    aria-label="Jual Produk Baru"
                    title="Jual Produk Baru"
                  >
                    {/* Kumo Inset Top Rim Highlight Gradient */}
                    <span className="absolute inset-0 rounded-full bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.4)] group-hover:from-[#2563eb] transition-all pointer-events-none" />

                    {/* Plus Icon */}
                    <Plus className="w-5.5 h-5.5 stroke-[2.5] text-white relative z-10" />
                  </button>
                </div>
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
                className={`flex flex-col items-center justify-center px-4 py-1.5 rounded-full transition-colors duration-200 cursor-pointer active:scale-95 relative ${
                  isActive
                    ? 'text-slate-900 font-semibold'
                    : 'bg-transparent text-neutral-400 hover:text-slate-900 font-normal'
                }`}
                aria-label={item.label}
              >
                {/* Animated Sliding Pill Highlight across Active Tabs (Framer Motion layoutId) */}
                {isActive && (
                  <motion.div
                    layoutId="active-nav-pill"
                    transition={{
                      type: 'spring',
                      stiffness: 420,
                      damping: 32,
                    }}
                    className="absolute inset-0 rounded-full bg-gradient-to-b from-neutral-100 to-neutral-200/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.9)] border border-neutral-300/80 pointer-events-none z-0"
                  />
                )}

                <div className="relative z-10 flex items-center justify-center">
                  <Icon
                    className={`w-5 h-5 transition-all ${iconFillClass}`}
                  />
                  {item.hasBadge && (
                    <span className="absolute -top-1 -right-2.5 min-w-[14px] h-[14px] px-1 rounded-full bg-rose-500 text-white text-[9px] font-bold flex items-center justify-center leading-none ring-2 ring-white">
                      1
                    </span>
                  )}
                </div>
                <span className={`text-[10.5px] mt-0.5 leading-none relative z-10 ${isActive ? 'font-semibold text-slate-900' : 'font-normal text-neutral-400'}`}>
                  {item.label}
                </span>
              </button>
            );
          })}
        </LayoutGroup>
      </nav>
    </div>
  );
};
