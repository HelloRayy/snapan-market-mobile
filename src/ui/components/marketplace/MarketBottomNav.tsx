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
    <div className="fixed bottom-0 left-0 right-0 z-50 font-gt-standard select-none bg-white/95 backdrop-blur-xl border-t border-neutral-200/80 shadow-[0_-4px_24px_rgba(0,0,0,0.04)]">
      {/* Edge-to-Edge Safe-Area Compliant Inner Container */}
      <nav className="max-w-md mx-auto px-2 pt-1.5 pb-[max(0.5rem,env(safe-area-inset-bottom))] flex items-center justify-around relative">
        <LayoutGroup id="market-bottom-nav-group">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;

            // Center Plus Action Button: Elevated Kumo Primary Electric Blue Floating FAB
            if (item.isAction) {
              return (
                <div key={item.id} className="relative flex items-center justify-center shrink-0 w-12 h-10">
                  <button
                    type="button"
                    onClick={onPostClick || (() => onTabChange('post'))}
                    className="absolute -top-4.5 w-12 h-12 rounded-full bg-[#1d64ec] hover:bg-[#154ec1] border-2 border-white active:scale-90 text-white flex items-center justify-center shadow-[0_8px_20px_rgba(29,100,236,0.38)] ring-4 ring-white/90 transition-all cursor-pointer z-10 overflow-hidden group"
                    aria-label="Jual Produk Baru"
                    title="Jual Produk Baru"
                  >
                    {/* Kumo Inset Top Rim Highlight Gradient */}
                    <span className="absolute inset-0 rounded-full bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.4)] group-hover:from-[#2563eb] transition-all pointer-events-none" />

                    {/* Plus Icon */}
                    <Plus className="w-6 h-6 stroke-[2.5] text-white relative z-10" />
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
                className={`flex flex-col items-center justify-center px-3.5 py-1 rounded-full transition-colors duration-200 cursor-pointer active:scale-95 relative ${
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
                      type: 'tween',
                      duration: 0.20,
                      ease: [0.25, 1, 0.5, 1],
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
