import React, { useState } from 'react';
import {
  ArrowLeft,
  Search,
  SquarePen,
  X,
  CheckCheck,
  ShoppingBag,
} from 'lucide-react';
import { MarketBottomNav } from '@/ui/components/marketplace/MarketBottomNav';
import { useAuth } from '@/ui/hooks/useAuth';
import { triggerHaptic } from '@/utils/haptics';

interface DirectMessagesPageProps {
  onBack?: () => void;
  onNavigateHome?: () => void;
  onNavigateSearch?: () => void;
  onNavigateProfile?: (username: string) => void;
  onSelectConversation?: (conversationId: string) => void;
  onOpenNewChatModal?: () => void;
}

interface MockConversation {
  id: string;
  user: {
    name: string;
    username: string;
    avatar: string;
    isVerified?: boolean;
    isOnline?: boolean;
  };
  lastMessage: string;
  timestamp: string;
  unreadCount?: number;
  isSeller?: boolean;
  isRequest?: boolean;
  productContext?: {
    title: string;
    price: string;
  };
}

const MOCK_CONVERSATIONS: MockConversation[] = [
  {
    id: 'conv-1',
    user: {
      name: 'Sarah Anastasya',
      username: 'sarahanas',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
      isVerified: true,
      isOnline: true,
    },
    lastMessage: 'Kalkulator Casio FX-991EX nya masih ada kak? Bisa COD di kantin?',
    timestamp: 'Baru saja',
    unreadCount: 2,
    productContext: {
      title: 'Kalkulator Casio FX-991EX',
      price: 'Rp 185.000',
    },
  },
  {
    id: 'conv-2',
    user: {
      name: 'Dimas Wicaksono',
      username: 'dimas_wicak',
      avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80',
      isOnline: true,
    },
    lastMessage: 'Siap bro, nanti jam istirahat kedua gua tunggu di depan lab komputer yaa.',
    timestamp: '12m',
    isSeller: true,
    productContext: {
      title: 'Buku Paket Fisika Kelas 12',
      price: 'Rp 45.000',
    },
  },
  {
    id: 'conv-3',
    user: {
      name: 'Nadia Putri',
      username: 'nadiaputri',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80',
      isOnline: false,
    },
    lastMessage: 'Makasih ya kak, barangnya masih mulus banget!',
    timestamp: '2j',
  },
  {
    id: 'conv-4',
    user: {
      name: 'Rian Pratama',
      username: 'rian_pratama',
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
      isOnline: false,
    },
    lastMessage: 'Bisa nego tipis gak bro untuk jas almamaternya?',
    timestamp: '1h',
  },
  {
    id: 'conv-5',
    user: {
      name: 'Bagus Prakoso',
      username: 'bagus_prakoso',
      avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80',
      isOnline: false,
    },
    lastMessage: 'Halo kak, akun Canva Pro edukasi nya ready gak ya?',
    timestamp: '3h',
    isRequest: true,
  },
];

export const DirectMessagesPage: React.FC<DirectMessagesPageProps> = ({
  onBack,
  onNavigateHome,
  onNavigateSearch,
  onNavigateProfile,
  onSelectConversation,
  onOpenNewChatModal,
}) => {
  const { user, profile } = useAuth();
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState<'inbox' | 'requests'>('inbox');

  const myUsername =
    profile?.full_name?.toLowerCase().replace(/\s+/g, '') ||
    user?.user_metadata?.full_name?.toLowerCase().replace(/\s+/g, '') ||
    'radityarayhannnn';

  const filteredConversations = MOCK_CONVERSATIONS.filter((conv) => {
    // 1. Search Query Filter
    const matchesSearch =
      conv.user.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      conv.user.username.toLowerCase().includes(searchQuery.toLowerCase()) ||
      conv.lastMessage.toLowerCase().includes(searchQuery.toLowerCase()) ||
      conv.productContext?.title.toLowerCase().includes(searchQuery.toLowerCase());

    if (!matchesSearch) return false;

    // 2. Tab Filter
    if (activeFilter === 'requests') {
      return conv.isRequest === true;
    }
    return !conv.isRequest;
  });

  return (
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-24 select-none">
      {/* Top Sticky App Header */}
      <header
        className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-100 font-gt-standard select-none transition-colors"
        style={{ paddingTop: 'env(safe-area-inset-top, 0px)' }}
      >
        {/* Row 1: Top Bar (h-14 Standard Height) */}
        <div className="w-full max-w-xl mx-auto px-4 h-14 flex items-center justify-between relative select-none">
          {/* Left Side: Back button or placeholder spacer */}
          <div className="flex items-center">
            {onBack ? (
              <button
                type="button"
                onClick={() => {
                  triggerHaptic('selection');
                  onBack();
                }}
                className="w-10 h-10 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
                aria-label="Kembali"
              >
                <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
              </button>
            ) : (
              <div className="w-10 h-10 pointer-events-none" />
            )}
          </div>

          {/* Center: Title */}
          <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center pointer-events-none">
            <h1 className="font-semibold text-base text-slate-900 tracking-tight transition-all duration-150 pointer-events-auto">
              Pesan
            </h1>
          </div>

          {/* Right Side: New Message Action Button */}
          <div className="flex items-center">
            <button
              type="button"
              onClick={() => {
                triggerHaptic('medium');
                onOpenNewChatModal?.();
              }}
              className="w-10 h-10 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
              aria-label="Pesan baru"
              title="Pesan baru"
            >
              <SquarePen className="w-5 h-5 stroke-[2]" />
            </button>
          </div>
        </div>

        {/* Row 2: SearchBar Capsule */}
        <div className="w-full max-w-xl mx-auto px-4 pb-2.5">
          <div className="flex items-center gap-2 py-2 px-4 bg-neutral-100 hover:bg-neutral-200/60 focus-within:bg-white focus-within:border-slate-300 focus-within:ring-2 focus-within:ring-slate-900/10 text-slate-900 text-base rounded-[22px] border border-neutral-200/70 backdrop-blur-md leading-snug transition-all duration-150">
            <div className="h-[15.9896px] w-[15.9896px] leading-snug flex items-center justify-center shrink-0">
              <Search className="w-4 h-4 text-neutral-400 stroke-[2.2]" />
            </div>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Cari pesan..."
              className="py-px px-0.5 w-full bg-transparent text-sm text-slate-900 placeholder:text-neutral-400 focus:outline-hidden leading-snug transition-all duration-150 disabled:opacity-50 disabled:cursor-not-allowed"
            />
            {searchQuery && (
              <button
                type="button"
                onClick={() => setSearchQuery('')}
                className="w-4 h-4 rounded-full bg-neutral-300 hover:bg-neutral-400 text-white flex items-center justify-center cursor-pointer transition-colors shrink-0"
                aria-label="Hapus pencarian"
              >
                <X className="w-2.5 h-2.5 stroke-[3]" />
              </button>
            )}
          </div>
        </div>

        {/* Row 3: Sub-Navigation Filter Tab Pills ("Kotak Masuk" & "Permintaan") */}
        <div className="w-full max-w-xl mx-auto flex items-center gap-x-2 pb-3 px-4 leading-snug">
          <button
            type="button"
            onClick={() => {
              triggerHaptic('selection');
              setActiveFilter('inbox');
            }}
            className={`flex items-center justify-center gap-x-1.5 py-1.5 px-4 rounded-[20px] text-sm font-semibold transition-all duration-150 cursor-pointer active:scale-[0.98] ${
              activeFilter === 'inbox'
                ? 'bg-slate-900 text-white border border-slate-900 shadow-2xs'
                : 'bg-white text-neutral-600 hover:bg-neutral-100 hover:text-slate-900 border border-neutral-200/80'
            }`}
          >
            <span>Kotak Masuk</span>
          </button>

          <button
            type="button"
            onClick={() => {
              triggerHaptic('selection');
              setActiveFilter('requests');
            }}
            className={`flex items-center justify-center gap-x-1.5 py-1.5 px-4 rounded-[20px] text-sm font-semibold transition-all duration-150 cursor-pointer active:scale-[0.98] ${
              activeFilter === 'requests'
                ? 'bg-slate-900 text-white border border-slate-900 shadow-2xs'
                : 'bg-white text-neutral-600 hover:bg-neutral-100 hover:text-slate-900 border border-neutral-200/80'
            }`}
          >
            <span>Permintaan</span>
          </button>
        </div>
      </header>

      {/* Main Conversation Stream */}
      <main className="max-w-xl mx-auto px-2 pt-1">
        {filteredConversations.length > 0 ? (
          <div className="divide-y divide-neutral-100">
            {filteredConversations.map((conv) => {
              const hasUnread = (conv.unreadCount || 0) > 0;
              return (
                <div
                  key={conv.id}
                  onClick={() => {
                    triggerHaptic('selection');
                    onSelectConversation?.(conv.id);
                  }}
                  className="flex items-start gap-3 p-3 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100/80 transition-colors cursor-pointer group"
                >
                  {/* User Avatar with Online Dot */}
                  <div className="relative shrink-0 mt-0.5">
                    <img
                      src={conv.user.avatar}
                      alt={conv.user.name}
                      className="w-12 h-12 rounded-full object-cover ring-1 ring-neutral-200/80"
                    />
                    {conv.user.isOnline && (
                      <span className="absolute bottom-0 right-0 w-3.5 h-3.5 rounded-full bg-emerald-500 ring-2 ring-white" />
                    )}
                  </div>

                  {/* Conversation Meta */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-1">
                      <div className="flex items-center gap-1.5 min-w-0">
                        <span
                          className={`text-[14.5px] truncate ${
                            hasUnread ? 'font-bold text-slate-950' : 'font-semibold text-slate-800'
                          }`}
                        >
                          {conv.user.name}
                        </span>
                        {conv.user.isVerified && (
                          <span className="inline-flex items-center justify-center w-3.5 h-3.5 rounded-full bg-[#1d64ec] text-white shrink-0">
                            <CheckCheck className="w-2.5 h-2.5 stroke-[3]" />
                          </span>
                        )}
                      </div>

                      <span
                        className={`text-[11.5px] whitespace-nowrap shrink-0 ${
                          hasUnread ? 'font-bold text-[#1d64ec]' : 'text-neutral-400 font-medium'
                        }`}
                      >
                        {conv.timestamp}
                      </span>
                    </div>

                    {/* Product Context Tag if Marketplace related */}
                    {conv.productContext && (
                      <div className="mt-0.5 inline-flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-blue-50/80 border border-blue-100 text-[#1d64ec] text-[11px] font-medium max-w-full truncate">
                        <ShoppingBag className="w-2.5 h-2.5 shrink-0 stroke-[2.2]" />
                        <span className="truncate">{conv.productContext.title}</span>
                        <span className="text-blue-400 shrink-0">•</span>
                        <span className="font-semibold shrink-0">{conv.productContext.price}</span>
                      </div>
                    )}

                    {/* Last message preview */}
                    <div className="flex items-center justify-between gap-2 mt-0.5">
                      <p
                        className={`text-[13px] line-clamp-1 leading-snug ${
                          hasUnread ? 'font-semibold text-slate-900' : 'text-neutral-500'
                        }`}
                      >
                        {conv.lastMessage}
                      </p>

                      {hasUnread && (
                        <span className="shrink-0 min-w-[18px] h-[18px] px-1 rounded-full bg-[#1d64ec] text-white text-[10px] font-bold flex items-center justify-center leading-none shadow-2xs">
                          {conv.unreadCount}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
          <div className="py-16 px-4 text-center space-y-2">
            <div className="w-12 h-12 mx-auto rounded-2xl bg-neutral-100 flex items-center justify-center text-neutral-400">
              <Search className="w-6 h-6 stroke-[1.8]" />
            </div>
            <p className="font-semibold text-slate-800 text-[15px]">
              {activeFilter === 'requests' ? 'Tidak ada permintaan pesan' : 'Tidak ada percakapan'}
            </p>
            <p className="text-xs text-neutral-400 max-w-xs mx-auto">
              {searchQuery
                ? `Tidak ditemukan pesan dengan kata kunci "${searchQuery}"`
                : activeFilter === 'requests'
                ? 'Permintaan pesan dari pengguna lain yang belum terhubung akan muncul di sini.'
                : 'Mulai kirim pesan ke teman atau penjual barang di Snapan Market.'}
            </p>
          </div>
        )}
      </main>

      {/* 5-Icon Standard Bottom Navigation */}
      <MarketBottomNav
        activeTab="messages"
        userAvatar={
          profile?.avatar_url ||
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'
        }
        onTabChange={(tab: string) => {
          triggerHaptic('selection');
          if (tab === 'home') {
            onNavigateHome?.();
          } else if (tab === 'profile') {
            onNavigateProfile?.(myUsername);
          } else if (tab === 'search') {
            onNavigateSearch?.();
          }
        }}
      />
    </div>
  );
};
