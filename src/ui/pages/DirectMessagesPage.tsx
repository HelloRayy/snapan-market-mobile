import React, { useState } from 'react';
import {
  ArrowLeft,
  SquarePen,
  MoreHorizontal,
  CheckCheck,
  Search,
} from 'lucide-react';
import { MobileSearchBar } from '@/ui/components/ui/MobileSearchBar';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
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
  isSender?: boolean;
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
    isSender: true,
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
    isSender: true,
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
  onSelectConversation,
  onOpenNewChatModal,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState<'inbox' | 'requests'>('inbox');
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
        {/* Row 1: Top Bar (HIG 48px Header Height with Balanced Spacing) */}
        <div className="w-full max-w-xl mx-auto px-4 h-12 flex items-center justify-between relative select-none">
          {/* Left Side: Back button or placeholder spacer */}
          <div className="flex items-center">
            {onBack ? (
              <button
                type="button"
                onClick={() => {
                  triggerHaptic('selection');
                  onBack();
                }}
                className="w-9 h-9 -ml-1.5 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-95"
                aria-label="Kembali"
              >
                <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
              </button>
            ) : (
              <div className="w-9 h-9" />
            )}
          </div>

          {/* Center: Title (iOS HIG 17px SemiBold Standard) */}
          <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center pointer-events-none">
            <h1 className="font-semibold text-[17px] text-slate-900 tracking-tight leading-none transition-all duration-150 pointer-events-auto">
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
              className="w-9 h-9 -mr-1.5 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-95"
              aria-label="Pesan baru"
              title="Pesan baru"
            >
              <SquarePen className="w-[19px] h-[19px] stroke-[2]" />
            </button>
          </div>
        </div>

        {/* Row 2: SearchBar Capsule with Fluid Motion */}
        <div className="w-full max-w-xl mx-auto px-4 pt-1 pb-3">
          <MobileSearchBar
            value={searchQuery}
            onChange={setSearchQuery}
            placeholder="Cari pesan..."
            onCancel={() => setSearchQuery('')}
            variant="compact"
          />
        </div>

        {/* Row 3: Sub-Navigation Filter Tab Pills ("Obrolan" & "Pembeli") */}
        <div className="w-full max-w-xl mx-auto flex items-center gap-x-2 px-4 pb-3">
          <button
            type="button"
            onClick={() => {
              triggerHaptic('selection');
              setActiveFilter('inbox');
            }}
            className={`flex items-center justify-center px-3.5 py-1.5 text-[13px] font-semibold rounded-full select-none cursor-pointer transition-colors duration-100 ease-out active:opacity-75 ${
              activeFilter === 'inbox'
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'bg-transparent text-neutral-500 hover:bg-neutral-100/70 hover:text-slate-700'
            }`}
          >
            Obrolan
          </button>

          <button
            type="button"
            onClick={() => {
              triggerHaptic('selection');
              setActiveFilter('requests');
            }}
            className={`flex items-center justify-center px-3.5 py-1.5 text-[13px] font-semibold rounded-full select-none cursor-pointer transition-colors duration-100 ease-out active:opacity-75 ${
              activeFilter === 'requests'
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'bg-transparent text-neutral-500 hover:bg-neutral-100/70 hover:text-slate-700'
            }`}
          >
            Pembeli
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
                  className="min-h-[76px] h-[76px] py-3 pl-4 sm:pl-6 pr-4 flex items-center gap-3.5 rounded-2xl hover:bg-neutral-50 active:bg-neutral-100/70 text-slate-900 cursor-pointer transition-all duration-150 active:scale-[0.98] group"
                >
                  {/* 1. Avatar Column with Multi-Badge Placement */}
                  <div className="relative shrink-0 w-[50px] h-[50px] rounded-full bg-neutral-100 ring-1 ring-neutral-200/80">
                    <img
                      src={conv.user.avatar}
                      alt={conv.user.name}
                      className="w-[50px] h-[50px] rounded-full object-cover"
                    />

                    {/* Online Status Dot at Top-Right (Always Green when user is online) */}
                    {conv.user.isOnline && (
                      <span className="absolute -top-0.5 -right-0.5 w-3.5 h-3.5 rounded-full bg-[#31a24c] ring-2 ring-white" />
                    )}
                  </div>

                  {/* 2. Text Content (2 Balanced Rows) */}
                  <div className="flex-1 min-w-0 flex flex-col justify-center gap-y-1">
                    {/* ROW 1 (Header): Name + Verified on Left, Timestamp on Right */}
                    <div className="flex items-center justify-between min-w-0 w-full gap-2">
                      <div className="flex items-center gap-1.5 min-w-0">
                        <p
                          className={`text-[15px] truncate ${
                            hasUnread ? 'font-bold text-slate-950' : 'font-semibold text-slate-900'
                          }`}
                        >
                          {conv.user.name}
                        </p>
                        {conv.user.isVerified && (
                          <ClickableVerifiedBadge
                            sellerName={conv.user.name}
                            className="w-[15px] h-[15px] shrink-0"
                          />
                        )}
                      </div>

                      {/* Timestamp Aligned to Top-Right */}
                      <span
                        className={`text-[12px] shrink-0 ${
                          hasUnread ? 'font-semibold text-[#1d64ec]' : 'font-normal text-neutral-400'
                        }`}
                      >
                        {conv.timestamp}
                      </span>
                    </div>

                    {/* ROW 2 (Subtitle): Read Receipt Icon + Message Preview on Left, Unread Counter / Actions on Right */}
                    <div className="flex items-center justify-between min-w-0 w-full gap-2">
                      <div className="flex items-center gap-1.5 min-w-0 flex-1">
                        {/* Outgoing Message Read Status Indicator (✓✓ CheckCheck) */}
                        {conv.isSender && (
                          <CheckCheck className="w-3.5 h-3.5 text-[#1d64ec] shrink-0 stroke-[2.5]" />
                        )}
                        <p
                          className={`text-[13.5px] truncate leading-snug ${
                            hasUnread ? 'font-medium text-slate-700' : 'font-normal text-neutral-400'
                          }`}
                        >
                          {conv.lastMessage}
                        </p>
                      </div>

                      {/* Unread Circular Badge or More Button on Right */}
                      {hasUnread ? (
                        <span
                          className={`shrink-0 rounded-full bg-[#1d64ec] text-white font-bold flex items-center justify-center leading-none ${
                            (conv.unreadCount || 0) < 10
                              ? 'w-5 h-5 min-w-5 aspect-square text-[11px]'
                              : 'min-w-[20px] h-5 px-1.5 text-[10.5px]'
                          }`}
                        >
                          {conv.unreadCount}
                        </span>
                      ) : (
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            triggerHaptic('selection');
                          }}
                          aria-label="Opsi lainnya untuk percakapan"
                          className="opacity-0 group-hover:opacity-100 sm:flex hidden items-center justify-center rounded-full w-6 h-6 text-neutral-400 hover:text-slate-700 hover:bg-neutral-100 active:scale-95 transition-all duration-150 cursor-pointer"
                        >
                          <MoreHorizontal className="w-3.5 h-3.5" />
                        </button>
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
              {activeFilter === 'requests' ? 'Tidak ada pesan dari pembeli' : 'Tidak ada obrolan'}
            </p>
            <p className="text-xs text-neutral-400 max-w-xs mx-auto">
              {searchQuery
                ? `Tidak ditemukan pesan dengan kata kunci "${searchQuery}"`
                : activeFilter === 'requests'
                ? 'Pesan dari calon pembeli produk jualan Anda akan muncul di sini.'
                : 'Mulai kirim pesan ke teman atau penjual barang di Snapan Market.'}
            </p>
          </div>
        )}
      </main>

    </div>
  );
};
