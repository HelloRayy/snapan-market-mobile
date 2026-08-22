import React from 'react';
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
  // Auto-detect virtual keyboard on mobile devices to prevent bottom nav from floating over the keyboard
  const [isKeyboardOpen, setIsKeyboardOpen] = React.useState(false);

  React.useEffect(() => {
    if (typeof window === 'undefined' || !window.visualViewport) return;

    const handleViewportChange = () => {
      if (window.visualViewport) {
        // Virtual keyboard causes visualViewport height to shrink significantly (> 15% reduction)
        const isKeyboard = window.visualViewport.height < window.innerHeight * 0.82;
        setIsKeyboardOpen(isKeyboard);
      }
    };

    window.visualViewport.addEventListener('resize', handleViewportChange);
    window.visualViewport.addEventListener('scroll', handleViewportChange);

    return () => {
      window.visualViewport?.removeEventListener('resize', handleViewportChange);
      window.visualViewport?.removeEventListener('scroll', handleViewportChange);
    };
  }, []);

  if (isKeyboardOpen) {
    return null;
  }

  const navItems = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'messages', label: 'Pesan', icon: Send, hasBadge: true },
    { id: 'post', label: 'Jual', icon: Plus, isAction: true },
    { id: 'activity', label: 'Aktivitas', icon: Heart },
    { id: 'profile', label: 'Profil', icon: User },
  ];

  return (
    <div
      className="fixed bottom-0 left-0 right-0 z-50 select-none bg-white/95 backdrop-blur-md border-t border-neutral-200/80 shadow-[0_-2px_12px_rgba(0,0,0,0.03)]"
      style={{
        paddingBottom: 'env(safe-area-inset-bottom, 0px)',
      }}
    >
      {/* Edge-to-Edge Safe-Area Compliant 50px Grid Container (Exact Meta Threads Standard) */}
      <nav className="max-w-md mx-auto h-[50px] grid grid-cols-5 items-center px-1">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          const isProfile = item.id === 'profile';
          const isHeart = item.id === 'activity';

          // Solid Icon Filling on Active State
          const iconFillClass = isActive
            ? isHeart
              ? 'fill-rose-500 text-rose-500 stroke-[2]'
              : 'fill-slate-900 text-slate-900 stroke-[2]'
            : 'stroke-[1.8] text-neutral-400 group-hover:text-slate-700 fill-transparent';

          // Center Plus Action Button: Original Elevated Kumo Primary Electric Blue Floating FAB
          if (item.isAction) {
            return (
              <div key={item.id} className="relative flex items-center justify-center shrink-0 h-[50px] w-full">
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

          return (
            <button
              key={item.id}
              type="button"
              onClick={() => onTabChange(item.id)}
              className="h-[50px] w-full flex items-center justify-center relative group cursor-pointer active:scale-90 transition-transform duration-100"
              aria-label={item.label}
            >
              {/* Subtle active indicator pill matching Threads h-[42px] */}
              {isActive && (
                <div className="absolute inset-x-1.5 sm:inset-x-2 inset-y-1 bg-neutral-100/90 rounded-xl pointer-events-none -z-0" />
              )}

              <div className="relative z-10 flex items-center justify-center">
                {isProfile ? (
                  <div
                    className={`w-[25px] h-[25px] rounded-full overflow-hidden border transition-all ${
                      isActive
                        ? 'border-slate-900 ring-1.5 ring-slate-900/30'
                        : 'border-neutral-300 opacity-75 group-hover:opacity-100'
                    }`}
                  >
                    <img
                      src={userAvatar}
                      alt="Profil"
                      className="w-full h-full object-cover"
                    />
                  </div>
                ) : (
                  <Icon className={`w-[24px] h-[24px] transition-all ${iconFillClass}`} />
                )}

                {/* Red Dot Badge (Threads style: mini dot ring-2 ring-white) */}
                {item.hasBadge && (
                  <span className="absolute -top-0.5 -right-1 w-2 h-2 rounded-full bg-[#ff3040] ring-2 ring-white" />
                )}
              </div>
            </button>
          );
        })}
      </nav>
    </div>
  );
};
