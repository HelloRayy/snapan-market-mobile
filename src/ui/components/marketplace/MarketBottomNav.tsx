import React from 'react';
import { Home, MessageSquare, Heart, User } from 'lucide-react';
import { useVirtualKeyboard } from '@/ui/hooks/useVirtualKeyboard';
import { triggerHaptic } from '@/utils/haptics';

interface MarketBottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
  onPostClick?: () => void;
  userAvatar?: string;
  unreadMessagesCount?: number;
  isVisible?: boolean;
}

export const MarketBottomNav: React.FC<MarketBottomNavProps> = ({
  activeTab,
  onTabChange,
  onPostClick,
  userAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80',
  unreadMessagesCount = 20,
  isVisible = true,
}) => {
  // Auto-detect virtual keyboard and active text inputs to prevent bottom nav from floating over the keyboard
  const { isKeyboardOpen } = useVirtualKeyboard();

  if (isKeyboardOpen) {
    return null;
  }

  const navTabs = [
    { id: 'home', label: 'Home', icon: Home },
    { id: 'messages', label: 'Pesan', icon: MessageSquare, badgeCount: unreadMessagesCount },
    { id: 'activity', label: 'Aktivitas', icon: Heart },
    { id: 'profile', label: 'Profil', icon: User, isProfile: true },
  ];

  return (
    <aside
      aria-label="Navigasi Utama"
      className={`fixed bottom-0 left-0 right-0 z-50 select-none pointer-events-none flex justify-center px-5 pb-4 sm:pb-6 transition-all duration-300 ease-[cubic-bezier(0.2,0,0,1)] ${
        isVisible ? 'translate-y-0 opacity-100' : 'translate-y-[120%] opacity-0 pointer-events-none'
      }`}
      style={{
        paddingBottom: 'max(16px, env(safe-area-inset-bottom, 16px))',
      }}
    >
      {/* Floating Liquid Frosted Glass Pill Dock (pen.dev HaFs1 / HomeBottomNavBar) */}
      <nav className="pointer-events-auto w-full max-w-[360px] h-[62px] rounded-[31px] bg-white/70 backdrop-blur-2xl shadow-[0_8px_35px_rgba(0,0,0,0.12)] p-1 flex items-center justify-around">
        {navTabs.map((tab) => {
          const Icon = tab.icon;
          const isActive =
            activeTab === tab.id ||
            (tab.id === 'activity' && activeTab === 'search') ||
            (tab.id === 'home' && activeTab === 'post');

          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => {
                triggerHaptic('selection');
                onTabChange(tab.id === 'activity' && activeTab === 'search' ? 'search' : tab.id);
              }}
              className="relative flex-1 h-[56px] flex flex-col items-center justify-center rounded-[28px] transition-all duration-150 cursor-pointer active:scale-95"
              aria-label={tab.label}
            >
              {/* Active Selection Capsule (pen.dev Selection #ededed, cornerRadius 100) */}
              {isActive && (
                <div className="absolute inset-0 bg-[#ededed]/75 border border-white/80 rounded-[28px] shadow-xs pointer-events-none -z-0" />
              )}

              <div className="relative z-10 flex flex-col items-center justify-center">
                {/* Glyph / Icon */}
                <div className="relative w-6 h-6 flex items-center justify-center">
                  {tab.isProfile ? (
                    <div
                      className={`w-[23px] h-[23px] rounded-full overflow-hidden border transition-all ${
                        isActive
                          ? 'border-[#008bff] ring-1.5 ring-[#008bff]/40'
                          : 'border-neutral-300'
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
                      className={`w-5 h-5 transition-colors ${
                        isActive
                          ? 'text-[#008bff] fill-[#008bff]'
                          : 'text-[#1a1a1a] fill-transparent stroke-[2]'
                      }`}
                    />
                  )}

                  {/* Azure Blue Unread Count Badge (Pesan Tab) */}
                  {tab.badgeCount !== undefined && tab.badgeCount > 0 && (
                    <span className="absolute -top-1.5 -right-3 min-w-[19px] h-[16px] px-1 rounded-full bg-[#008bff] text-white text-[10px] font-bold flex items-center justify-center leading-none shadow-xs">
                      {tab.badgeCount > 99 ? '99+' : tab.badgeCount}
                    </span>
                  )}
                </div>

                {/* Label */}
                <span
                  className={`text-[10px] mt-0.5 tracking-tight transition-colors ${
                    isActive
                      ? 'text-[#008bff] font-bold'
                      : 'text-[#1a1a1a] font-medium'
                  }`}
                >
                  {tab.label}
                </span>
              </div>
            </button>
          );
        })}
      </nav>

      {/* Floating Action Button (FAB) matching user spec: w-[82px] h-[68px], rounded-2xl, shadow */}
      {onPostClick && (
        <div className="absolute right-5 bottom-[max(16px,env(safe-area-inset-bottom,16px))] pointer-events-auto">
          <button
            type="button"
            onClick={() => {
              triggerHaptic('medium');
              onPostClick();
            }}
            className="flex items-center justify-center bg-[#181818] text-[#f3f5f7] text-base font-semibold rounded-2xl border border-white/15 shadow-[0px_6px_8px_0px_rgba(0,0,0,0.12)] h-[68px] w-[82px] leading-snug transition-all duration-150 hover:bg-[#313134] active:scale-[0.98] cursor-pointer"
            aria-label="Buat"
          >
            Buat
          </button>
        </div>
      )}
    </aside>
  );
};

