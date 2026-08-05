import React from 'react';
import { Home, Search, ShoppingBag, ClipboardList, User } from 'lucide-react';
import { useCartStore } from '@/ui/store/cartStore';

interface MobileBottomNavProps {
  activeTab?: string;
  onTabChange?: (tab: string) => void;
}

export const MobileBottomNav: React.FC<MobileBottomNavProps> = ({
  activeTab = 'home',
  onTabChange
}) => {
  const totalItems = useCartStore((state) => state.getTotalItems());

  const navItems = [
    { id: 'home', label: 'Beranda', icon: Home },
    { id: 'search', label: 'Cari', icon: Search },
    { id: 'cart', label: 'Keranjang', icon: ShoppingBag, badge: totalItems },
    { id: 'orders', label: 'Pesanan', icon: ClipboardList },
    { id: 'profile', label: 'Akun', icon: User }
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-neutral-200 bg-white/90 backdrop-blur-xl px-2 py-1.5 md:hidden shadow-lg">
      <div className="flex items-center justify-around">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;

          return (
            <button
              key={item.id}
              onClick={() => onTabChange?.(item.id)}
              className={`relative flex flex-col items-center py-1 px-3 rounded-xl transition-all duration-200 ${
                isActive
                  ? 'text-black font-bold'
                  : 'text-neutral-500 hover:text-neutral-900'
              }`}
            >
              <div className="relative">
                <Icon className={`w-5 h-5 ${isActive ? 'scale-110' : ''} transition-transform`} />
                {item.badge !== undefined && item.badge > 0 && (
                  <span className="absolute -top-1.5 -right-2 flex h-4 w-4 items-center justify-center rounded-full bg-black text-[10px] font-bold text-white shadow-md">
                    {item.badge > 99 ? '99+' : item.badge}
                  </span>
                )}
              </div>
              <span className="text-[10px] mt-1">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
