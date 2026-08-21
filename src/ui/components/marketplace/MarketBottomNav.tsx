import React, { useState, useEffect, useRef } from 'react';
import { Home, Send, Plus, Heart, User } from 'lucide-react';

interface MarketBottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  onPostClick?: () => void;
  userAvatar?: string;
}

export const MarketBottomNav: React.FC<MarketBottomNavProps> = ({
  activeTab,
  onTabChange,
  onPostClick,
  userAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
}) => {
  const [isVisible, setIsVisible] = useState(true);
  const lastScrollY = useRef(0);
  const scrollTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Auto-Hide / Show on Scroll Behavior
  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;
      const scrollDiff = currentScrollY - lastScrollY.current;

      // Always show if near the top of the feed (< 50px)
      if (currentScrollY < 50) {
        setIsVisible(true);
      } else if (scrollDiff > 8) {
        // Scrolling DOWN -> hide bottom nav (motion goes down)
        setIsVisible(false);
      } else if (scrollDiff > -8) {
        // Scrolling UP -> show bottom nav (motion comes up)
        setIsVisible(true);
      }

      lastScrollY.current = currentScrollY;

      // When user STOPS scrolling -> show bottom nav smoothly
      if (scrollTimeout.current) {
        clearTimeout(scrollTimeout.current);
      }
      scrollTimeout.current = setTimeout(() => {
        setIsVisible(true);
      }, 700);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => {
      window.removeEventListener('scroll', handleScroll);
      if (scrollTimeout.current) clearTimeout(scrollTimeout.current);
    };
  }, []);

  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'messages', label: 'Pesan', icon: Send, hasBadge: true },
    { id: 'post', label: 'Jual', icon: Plus, isAction: true },
    { id: 'activity', label: 'Aktivitas', icon: Heart },
    { id: 'profile', label: 'Profil', icon: User },
  ];

  return (
    <div
      className={`fixed bottom-0 left-0 right-0 z-50 font-gt-standard select-none bg-white/95 backdrop-blur-xl border-t border-neutral-200/80 shadow-[0_-4px_24px_rgba(0,0,0,0.04)] transition-transform duration-200 ease-[cubic-bezier(0.32,0.72,0,1)] transform-gpu ${
        isVisible ? 'translate-y-0' : 'translate-y-[120%]'
      }`}
      style={{
        paddingBottom: 'max(0.75rem, calc(env(safe-area-inset-bottom, 0px) + 8px))',
        willChange: 'transform',
      }}
    >
      {/* Edge-to-Edge Safe-Area Compliant Inner Container (Strict Apple HIG & Android Navigation Guidelines) */}
      <nav className="max-w-md mx-auto px-2 pt-2 flex items-center justify-around relative">
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
                  className="absolute -top-5 w-12 h-12 rounded-full bg-[#1d64ec] hover:bg-[#154ec1] border-2 border-white active:scale-90 text-white flex items-center justify-center shadow-[0_8px_20px_rgba(29,100,236,0.38)] ring-4 ring-white/90 transition-all cursor-pointer z-10 overflow-hidden group"
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
          const isProfile = item.id === 'profile';
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
              {/* Highlight Pill across Active Tabs */}
              {isActive && (
                <div className="absolute inset-0 rounded-full bg-gradient-to-b from-neutral-100 to-neutral-200/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.9)] border border-neutral-300/80 pointer-events-none z-0 transition-opacity duration-200 animate-backdrop-fade" />
              )}

              <div className="relative z-10 flex items-center justify-center">
                {isProfile ? (
                  <div
                    className={`w-[23px] h-[23px] rounded-full overflow-hidden transition-all ${
                      isActive
                        ? 'scale-105 shadow-2xs'
                        : 'opacity-70 group-hover:opacity-100'
                    }`}
                  >
                    <img
                      src={userAvatar}
                      alt="Profil"
                      className="w-full h-full object-cover"
                    />
                  </div>
                ) : (
                  <Icon
                    className={`w-5 h-5 transition-all ${iconFillClass}`}
                  />
                )}
                {item.hasBadge && (
                  <span className="absolute -top-1 -right-2.5 min-w-[14px] h-[14px] px-1 rounded-full bg-rose-500 text-white text-[9px] font-bold flex items-center justify-center leading-none ring-2 ring-white">
                    1
                  </span>
                )}
              </div>
              <span className={`text-[11px] mt-0.5 leading-none relative z-10 ${isActive ? 'font-semibold text-slate-900' : 'font-normal text-neutral-400'}`}>
                {item.label}
              </span>
            </button>
          );
        })}
      </nav>
    </div>
  );
};
