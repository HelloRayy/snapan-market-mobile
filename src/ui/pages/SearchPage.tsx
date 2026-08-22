import React, { useState, useMemo } from 'react';
import { Search, X, SlidersHorizontal, ArrowLeft, Users } from 'lucide-react';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { MarketBottomNav } from '@/ui/components/marketplace/MarketBottomNav';

export interface SuggestedAccount {
  id: string;
  username: string;
  fullName: string;
  avatar: string;
  isVerified?: boolean;
  bio: string;
  followersCount: string;
  isFollowing?: boolean;
}

const INITIAL_SUGGESTED_ACCOUNTS: SuggestedAccount[] = [
  {
    id: '1',
    username: 'growthflo',
    fullName: 'Flo',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
    bio: 'designing & running adfects.com',
    followersCount: '8.728 pengikut',
  },
  {
    id: '2',
    username: 'haluandotco',
    fullName: 'Haluan Media',
    avatar: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&q=80',
    isVerified: true,
    bio: 'Berita Politik, Nasional, Internasional, dan Hiburan terkini.',
    followersCount: '245 rb pengikut',
  },
  {
    id: '3',
    username: 'dewakoding',
    fullName: 'Septiawan Aji Pradana',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
    bio: '🚀 | Sharing Tips Programming 💻 | Pengguna Laravel Sejati',
    followersCount: '14,2 rb pengikut',
  },
  {
    id: '4',
    username: 'kementeriankegelapan',
    fullName: 'Kementerian Kegelapan',
    avatar: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&q=80',
    isVerified: true,
    bio: 'Indonesia Emas 2045 Hijriah. Limbah & Inovasi.',
    followersCount: '89,1 rb pengikut',
  },
  {
    id: '5',
    username: 'officialbin_ri',
    fullName: 'Badan Intelijen Negara',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&q=80',
    isVerified: true,
    bio: 'Akun Threads Resmi Badan Intelijen Negara Republik Indonesia.',
    followersCount: '120 rb pengikut',
  },
  {
    id: '6',
    username: 'junaid_jamel',
    fullName: 'Junaid • iOS & Android Developer',
    avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80',
    isVerified: true,
    bio: 'I build Mobile Apps 📩 junaid@developer.com',
    followersCount: '32,4 rb pengikut',
  },
  {
    id: '7',
    username: 'uiuxbagas',
    fullName: 'Bagas Surya A | UI/UX Designer',
    avatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&q=80',
    bio: '💼 UI/UX Designer 📌 Bekasi, IDN — Design By : @bagas',
    followersCount: '18,9 rb pengikut',
  },
  {
    id: '8',
    username: 'indozone.id',
    fullName: 'INDOZONE - #KAMUHARUSTAU',
    avatar: 'https://images.unsplash.com/photo-1586339949916-3e9457bef6d3?w=150&q=80',
    isVerified: true,
    bio: 'Zone of Youth Generation — 📌 INDOZONE Media Group',
    followersCount: '540 rb pengikut',
  },
  {
    id: '9',
    username: 'dytama.studio',
    fullName: 'dytama studio',
    avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80',
    bio: 'Creative digital design & brand architecture.',
    followersCount: '52 pengikut',
  },
  {
    id: '10',
    username: 'zenwiill',
    fullName: 'ZENWILL',
    avatar: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=150&q=80',
    bio: 'At the intersection of culture, creativity, and stories that matter.',
    followersCount: '155 rb pengikut',
  },
  {
    id: '11',
    username: 'inilah_arena',
    fullName: 'Inilah Arena',
    avatar: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150&q=80',
    isVerified: true,
    bio: 'Pusat Berita Olahraga & E-Sports Terdepan Indonesia.',
    followersCount: '19,4 rb pengikut',
  },
  {
    id: '12',
    username: 'm.azhar.alauddin',
    fullName: 'Muhammad Azhar Alauddin',
    avatar: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&q=80',
    bio: '💻 Remote Software Engineer 🌍 Sharing remote work & web dev',
    followersCount: '41,2 rb pengikut',
  },
  {
    id: '13',
    username: 'cyber_ex_3697',
    fullName: '𝑼𝑴𝑨𝑹 𝑹𝑼𝑴𝑨𝑵 | 𝑻𝑯𝑬 𝑪𝒀𝑩𝑬𝑹 𝑯𝑼𝑩 ⚠️',
    avatar: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=150&q=80',
    bio: 'Cybersecurity & Ethical Hacking Research 🛡️',
    followersCount: '12,8 rb pengikut',
  },
  {
    id: '14',
    username: 'urbanfeed.news',
    fullName: 'URBANFEED',
    avatar: 'https://images.unsplash.com/photo-1495020689067-958852a7765e?w=150&q=80',
    isVerified: true,
    bio: 'Berita terkini dalam genggaman, Fakta yang berkembang.',
    followersCount: '76,5 rb pengikut',
  },
  {
    id: '15',
    username: 'cs50',
    fullName: 'CS50',
    avatar: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=150&q=80',
    isVerified: true,
    bio: 'From the team that brought you CS50 at Harvard, this is the official channel.',
    followersCount: '820 rb pengikut',
  },
  {
    id: '16',
    username: 'baliweb.id',
    fullName: 'Baliweb.id',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&q=80',
    bio: 'Support umkm to be outstanding overseas!',
    followersCount: '4 pengikut',
  },
];

interface SearchPageProps {
  onBack?: () => void;
  onNavigateToProfile: (username: string) => void;
  onNavigateHome: () => void;
  onOpenMenu?: () => void;
}

export const SearchPage: React.FC<SearchPageProps> = ({
  onBack,
  onNavigateToProfile,
  onNavigateHome,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [followingMap, setFollowingMap] = useState<Record<string, boolean>>({});

  const toggleFollow = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setFollowingMap((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  const filteredAccounts = useMemo(() => {
    if (!searchQuery.trim()) return INITIAL_SUGGESTED_ACCOUNTS;
    const q = searchQuery.toLowerCase().trim();
    return INITIAL_SUGGESTED_ACCOUNTS.filter(
      (acc) =>
        acc.username.toLowerCase().includes(q) ||
        acc.fullName.toLowerCase().includes(q) ||
        acc.bio.toLowerCase().includes(q)
    );
  }, [searchQuery]);

  return (
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-24 select-none">
      {/* Sticky Header with Searchbar */}
      <header
        className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-100 px-4 py-2.5 transition-all"
        style={{ paddingTop: 'max(0.625rem, env(safe-area-inset-top, 0px))' }}
      >
        <div className="max-w-xl mx-auto flex items-center gap-2.5">
          {/* Back Button if navigated from another page */}
          {onBack && (
            <button
              type="button"
              onClick={onBack}
              className="w-10 h-10 -ml-1 rounded-full flex items-center justify-center text-slate-800 hover:bg-neutral-100 active:scale-90 transition-all cursor-pointer shrink-0"
              aria-label="Kembali"
            >
              <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
            </button>
          )}

          {/* Capsule Search Bar (Reference: bg-[#1e1e1e] / Light Mode: bg-neutral-100/90 rounded-[22px] h-11) */}
          <div className="flex items-center px-4 bg-neutral-100/90 text-slate-900 text-base rounded-[22px] h-11 leading-snug border border-neutral-200/70 flex-1 focus-within:bg-white focus-within:border-slate-400 focus-within:shadow-2xs transition-all">
            <Search className="w-4.5 h-4.5 text-neutral-400 mr-2.5 shrink-0 stroke-[2.2]" />
            <input
              type="text"
              autoFocus
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Cari"
              className="bg-transparent text-slate-900 placeholder:text-neutral-400 outline-none flex-1 text-[15px] font-normal leading-snug h-full"
            />
            {searchQuery ? (
              <button
                type="button"
                onClick={() => setSearchQuery('')}
                className="w-7 h-7 rounded-full flex items-center justify-center text-neutral-400 hover:text-slate-800 hover:bg-neutral-200/60 active:scale-90 transition-all cursor-pointer shrink-0 ml-1"
                aria-label="Hapus Pencarian"
              >
                <X className="w-4 h-4 stroke-[2.5]" />
              </button>
            ) : (
              <button
                type="button"
                className="inline-flex rounded-full h-8 w-8 items-center justify-center text-neutral-400 hover:text-slate-800 hover:bg-neutral-200/60 active:scale-90 transition-all cursor-pointer shrink-0 ml-1"
                aria-label="Filter Pencarian"
              >
                <SlidersHorizontal className="w-4 h-4 stroke-[2]" />
              </button>
            )}
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-xl mx-auto px-4 pt-3">
        {/* Section Heading: "Saran ikuti" */}
        <div className="flex items-center justify-between pt-2 pb-2 px-1">
          <h2 className="text-[15px] font-bold text-slate-900 tracking-tight leading-snug">
            {searchQuery ? `Hasil untuk "${searchQuery}"` : 'Saran ikuti'}
          </h2>
          {!searchQuery && (
            <span className="text-[12.5px] text-neutral-400 font-medium leading-snug flex items-center gap-1">
              <Users className="w-3.5 h-3.5" />
              Rekomendasi
            </span>
          )}
        </div>

        {/* Suggested Accounts List (Reference styling with clean borders, shadows, & light mode) */}
        <div className="divide-y divide-neutral-100 bg-white rounded-2xl border border-neutral-100 shadow-[rgba(0,0,0,0.02)_0px_2px_12px_0px] overflow-hidden mt-1">
          {filteredAccounts.length > 0 ? (
            filteredAccounts.map((account) => {
              const isFollowing = !!followingMap[account.id];

              return (
                <div
                  key={account.id}
                  onClick={() => onNavigateToProfile(account.username)}
                  className="flex items-start justify-between gap-3 p-3.5 hover:bg-neutral-50/80 active:bg-neutral-100 transition-colors cursor-pointer leading-snug group"
                >
                  {/* Left: Avatar */}
                  <div className="w-10 h-10 rounded-full overflow-hidden ring-1 ring-neutral-200/80 shrink-0 mt-0.5 shadow-2xs">
                    <img
                      src={account.avatar}
                      alt={account.fullName}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                      loading="lazy"
                    />
                  </div>

                  {/* Center: Details */}
                  <div className="flex-1 min-w-0 pr-1 leading-snug">
                    <div className="flex items-center gap-1 leading-tight">
                      <span className="font-bold text-[14.5px] text-slate-900 truncate">
                        {account.username}
                      </span>
                      {account.isVerified && (
                        <ClickableVerifiedBadge className="w-3.5 h-3.5 shrink-0" />
                      )}
                    </div>

                    <p className="text-[13px] text-neutral-500 font-normal truncate leading-tight mt-0.5">
                      {account.fullName}
                    </p>

                    <p className="text-[13px] text-slate-700 font-normal line-clamp-2 leading-relaxed mt-1">
                      {account.bio}
                    </p>

                    <p className="text-[11.5px] text-neutral-400 font-medium leading-tight mt-1.5">
                      {account.followersCount}
                    </p>
                  </div>

                  {/* Right: "Ikuti" / "Mengikuti" Button */}
                  <button
                    type="button"
                    onClick={(e) => toggleFollow(account.id, e)}
                    className={`shrink-0 px-4 py-1.5 rounded-xl text-[13.5px] font-semibold transition-all active:scale-95 cursor-pointer leading-tight mt-0.5 ${
                      isFollowing
                        ? 'border border-neutral-200 text-neutral-400 bg-neutral-50 hover:bg-neutral-100'
                        : 'border border-neutral-300 text-slate-900 bg-white hover:bg-neutral-100 shadow-2xs'
                    }`}
                  >
                    {isFollowing ? 'Mengikuti' : 'Ikuti'}
                  </button>
                </div>
              );
            })
          ) : (
            <div className="py-12 text-center text-neutral-400 text-sm space-y-1">
              <p className="font-semibold text-slate-700">Tidak ada akun ditemukan</p>
              <p className="text-xs text-neutral-400">Coba cari dengan kata kunci lain</p>
            </div>
          )}
        </div>
      </main>

      {/* Standard PWA Bottom Navigation Bar */}
      <MarketBottomNav
        activeTab="search"
        onTabChange={(tab) => {
          if (tab === 'home') {
            onNavigateHome();
          } else if (tab === 'profile') {
            onNavigateToProfile('radityarayhannnn');
          }
        }}
      />
    </div>
  );
};
