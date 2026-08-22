import React, { useState, useMemo, useRef } from 'react';
import { Search, X, SlidersHorizontal, ArrowLeft, Users, TrendingUp, ChevronRight } from 'lucide-react';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { MarketBottomNav } from '@/ui/components/marketplace/MarketBottomNav';
import { MarketPostCard } from '@/ui/components/marketplace/MarketPostCard';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
import { MarketPostItem } from '@/types/marketFeed';

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

const TRENDING_TAGS = [
  { id: '1', tag: 'snapandev', posts: '1.8 rb utas' },
  { id: '2', tag: 'vibe coding', posts: '3.4 rb utas' },
  { id: '3', tag: 'MarketDay', posts: '1.2 rb utas' },
  { id: '4', tag: 'PPLG1', posts: '856 utas' },
  { id: '5', tag: 'Kantin8', posts: '2.4 rb utas' },
];

type SearchTab = 'top' | 'latest' | 'profiles';

// Semantic Tokenized Relevance Scorer
function calculateTokenScore(query: string, fields: (string | undefined)[], engagementBoost = 0): number {
  if (!query.trim()) return 0;
  const tokens = query
    .toLowerCase()
    .trim()
    .replace(/[^\w\s]/gi, ' ')
    .split(/\s+/)
    .filter((t) => t.length > 1);

  if (tokens.length === 0) return 0;

  let matchedTokens = 0;
  let fieldHits = 0;

  for (const token of tokens) {
    let hasHit = false;
    for (const field of fields) {
      if (field && field.toLowerCase().includes(token)) {
        hasHit = true;
        fieldHits += 1;
      }
    }
    if (hasHit) {
      matchedTokens += 1;
    }
  }

  if (matchedTokens === 0) return 0;

  const coverageRatio = matchedTokens / tokens.length;
  return coverageRatio * 100 + fieldHits * 5 + engagementBoost;
}

interface SearchPageProps {
  onBack?: () => void;
  onNavigateToProfile: (username: string) => void;
  onNavigateHome: () => void;
  onSelectPost?: (post: MarketPostItem) => void;
  onOpenMenu?: () => void;
}

export const SearchPage: React.FC<SearchPageProps> = ({
  onBack,
  onNavigateToProfile,
  onNavigateHome,
  onSelectPost,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [activeTab, setActiveTab] = useState<SearchTab>('top');
  const [followingMap, setFollowingMap] = useState<Record<string, boolean>>({});
  const inputRef = useRef<HTMLInputElement>(null);

  const toggleFollow = (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    setFollowingMap((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  const handleQueryChange = (val: string) => {
    setSearchQuery(val);
    if (!val.trim()) {
      setIsSubmitted(false);
    }
  };

  const handleCancelSearch = () => {
    setSearchQuery('');
    setIsSubmitted(false);
    inputRef.current?.blur();
  };

  const handleExecuteSearch = () => {
    if (searchQuery.trim()) {
      setIsSubmitted(true);
    }
  };

  // 1. Scored Matching Posts (Tokenized Relevance)
  const scoredPosts = useMemo(() => {
    if (!searchQuery.trim()) return [];

    return MOCK_MARKET_POSTS.map((post) => {
      const fields = [
        post.caption,
        post.topicTag,
        post.category,
        post.seller.name,
        post.seller.username,
        ...(post.threadChain?.map((t) => t.caption) || []),
      ];
      const engagement = ((post.likesCount || 0) * 0.05) + ((post.commentsCount || 0) * 0.1);
      const score = calculateTokenScore(searchQuery, fields, engagement);
      return { post, score };
    }).filter((item) => item.score > 0);
  }, [searchQuery]);

  // Tab 1: Terpopuler
  const popularPosts = useMemo(() => {
    return [...scoredPosts].sort((a, b) => b.score - a.score).map((item) => item.post);
  }, [scoredPosts]);

  // Tab 2: Terbaru
  const latestPosts = useMemo(() => {
    return [...scoredPosts].map((item) => item.post);
  }, [scoredPosts]);

  // Tab 3: Profil
  const scoredAccounts = useMemo(() => {
    if (!searchQuery.trim()) return INITIAL_SUGGESTED_ACCOUNTS;
    return INITIAL_SUGGESTED_ACCOUNTS.map((account) => {
      const fields = [account.username, account.fullName, account.bio];
      const score = calculateTokenScore(searchQuery, fields);
      return { account, score };
    })
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .map((item) => item.account);
  }, [searchQuery]);

  const hasSearchQuery = searchQuery.trim().length > 0;

  return (
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-24 select-none">
      {/* Sticky Header with Searchbar & Tabs */}
      <header
        className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-100 px-4 pt-2.5 pb-0 transition-all"
        style={{ paddingTop: 'max(0.625rem, env(safe-area-inset-top, 0px))' }}
      >
        <div className="max-w-xl mx-auto w-full">
          {/* Top Search Bar Row */}
          <div className="flex items-center gap-2 pb-2.5">
            {/* Capsule Search Bar with Integrated Back Arrow */}
            <div className="flex items-center pl-2.5 pr-3 bg-neutral-100/90 text-slate-900 text-base rounded-[22px] h-11 leading-snug border border-neutral-200/70 flex-1 focus-within:bg-white focus-within:border-slate-400 focus-within:shadow-2xs transition-all">
              {/* Integrated Back Arrow / Search Icon */}
              {onBack ? (
                <button
                  type="button"
                  onClick={onBack}
                  className="w-8 h-8 rounded-full flex items-center justify-center text-slate-700 hover:text-slate-950 hover:bg-neutral-200/70 active:scale-90 transition-all cursor-pointer shrink-0 mr-1"
                  aria-label="Kembali"
                >
                  <ArrowLeft className="w-4.5 h-4.5 stroke-[2.2]" />
                </button>
              ) : (
                <div className="w-8 h-8 flex items-center justify-center text-neutral-400 shrink-0 mr-1">
                  <Search className="w-4.5 h-4.5 stroke-[2.2]" />
                </div>
              )}

              {/* Search Input Field */}
              <input
                ref={inputRef}
                type="text"
                autoFocus
                value={searchQuery}
                onChange={(e) => handleQueryChange(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    handleExecuteSearch();
                  }
                }}
                placeholder="Cari"
                className="bg-transparent text-slate-900 placeholder:text-neutral-400 outline-none flex-1 text-[15px] font-normal leading-snug h-full px-1"
              />

              {/* Right Action: Clear 'X' or Filter Sliders */}
              {searchQuery ? (
                <button
                  type="button"
                  onClick={() => {
                    setSearchQuery('');
                    setIsSubmitted(false);
                  }}
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

            {/* "Batal" Button (Shown when user is actively searching / typing) */}
            {hasSearchQuery && (
              <button
                type="button"
                onClick={handleCancelSearch}
                className="px-2 py-1 text-[15px] font-medium text-slate-900 hover:text-slate-600 active:scale-95 transition-all cursor-pointer shrink-0"
              >
                Batal
              </button>
            )}
          </div>

          {/* 3 Main Meta Threads Tabs: Terpopuler | Terbaru | Profil (ONLY shown after search submission) */}
          {hasSearchQuery && isSubmitted && (
            <div className="w-full border-t border-neutral-100 animate-in fade-in duration-150">
              <div className="flex items-center relative">
                {/* Sliding indicator line */}
                <div
                  className={`absolute bottom-0 h-[2px] bg-slate-900 transition-all duration-200 cubic-bezier(0.25,1,0.5,1) ${
                    activeTab === 'top'
                      ? 'left-0 w-1/3'
                      : activeTab === 'latest'
                      ? 'left-1/3 w-1/3'
                      : 'left-2/3 w-1/3'
                  }`}
                />

                <button
                  type="button"
                  onClick={() => setActiveTab('top')}
                  className={`flex-1 py-3 text-[14.5px] text-center transition-colors cursor-pointer ${
                    activeTab === 'top' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
                  }`}
                >
                  Terpopuler
                </button>

                <button
                  type="button"
                  onClick={() => setActiveTab('latest')}
                  className={`flex-1 py-3 text-[14.5px] text-center transition-colors cursor-pointer ${
                    activeTab === 'latest' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
                  }`}
                >
                  Terbaru
                </button>

                <button
                  type="button"
                  onClick={() => setActiveTab('profiles')}
                  className={`flex-1 py-3 text-[14.5px] text-center transition-colors cursor-pointer ${
                    activeTab === 'profiles' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
                  }`}
                >
                  Profil
                </button>
              </div>
            </div>
          )}
        </div>
      </header>

      {/* Main Content Area */}
      <main className="max-w-xl mx-auto px-4 pt-3 space-y-4">
        {/* STAGE 1: Typing State -> Suggestion Row "Cari [keyword] >" (Exact Competitor UX Reference) */}
        {hasSearchQuery && !isSubmitted && (
          <div className="space-y-3 pt-1 animate-in fade-in duration-150">
            {/* Single Suggestion Row (Reference: h-[64.8px] / Light Mode: rounded-2xl shadow-sm border) */}
            <div
              onClick={handleExecuteSearch}
              className="flex items-center justify-between px-4 py-3.5 bg-white text-slate-900 rounded-2xl border border-neutral-200/80 shadow-[rgba(0,0,0,0.04)_0px_8px_16px_0px] hover:bg-neutral-50 active:scale-98 transition-all cursor-pointer leading-snug group"
            >
              <div className="flex items-center gap-3.5 min-w-0">
                <div className="w-8 h-8 rounded-full bg-neutral-100 flex items-center justify-center text-slate-700 shrink-0 group-hover:bg-neutral-200/80 transition-colors">
                  <Search className="w-4.5 h-4.5 stroke-[2.2]" />
                </div>
                <span className="font-semibold text-[15px] text-slate-900 truncate">
                  {searchQuery}
                </span>
              </div>

              <div className="flex items-center gap-1.5 text-neutral-400 shrink-0">
                <span className="text-[12px] font-medium text-neutral-400 opacity-0 group-hover:opacity-100 transition-opacity">
                  Lanjutkan
                </span>
                <ChevronRight className="w-4.5 h-4.5 stroke-[2] group-hover:translate-x-0.5 transition-transform" />
              </div>
            </div>

            {/* Direct Matched Accounts (If Any) */}
            {scoredAccounts.length > 0 && (
              <div className="divide-y divide-neutral-100 bg-white rounded-2xl border border-neutral-100 shadow-[rgba(0,0,0,0.02)_0px_2px_12px_0px] overflow-hidden">
                {scoredAccounts.slice(0, 3).map((account) => (
                  <div
                    key={account.id}
                    onClick={() => onNavigateToProfile(account.username)}
                    className="flex items-center gap-3 p-3 hover:bg-neutral-50/80 active:bg-neutral-100 transition-colors cursor-pointer leading-snug"
                  >
                    <div className="w-9 h-9 rounded-full overflow-hidden ring-1 ring-neutral-200 shrink-0">
                      <img src={account.avatar} alt={account.fullName} className="w-full h-full object-cover" />
                    </div>
                    <div className="flex-1 min-w-0 leading-snug">
                      <div className="flex items-center gap-1 leading-tight">
                        <span className="font-bold text-[14px] text-slate-900 truncate">{account.username}</span>
                        {account.isVerified && <ClickableVerifiedBadge className="w-3 h-3 shrink-0" />}
                      </div>
                      <p className="text-[12px] text-neutral-500 truncate leading-tight mt-0.5">{account.fullName}</p>
                    </div>
                    <ChevronRight className="w-4 h-4 text-neutral-300 shrink-0" />
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* STAGE 2: Empty Query State -> Trending Tags + Saran Ikuti */}
        {!hasSearchQuery && (
          <>
            {/* Trending Topics / Hastag Populer */}
            <div className="space-y-2">
              <div className="flex items-center gap-1.5 text-[13px] font-bold text-slate-800 uppercase tracking-wide px-1">
                <TrendingUp className="w-4 h-4 text-[#1d64ec]" />
                <span>Tren Topik Hari Ini</span>
              </div>

              <div className="flex flex-wrap gap-2">
                {TRENDING_TAGS.map((t) => (
                  <button
                    key={t.id}
                    type="button"
                    onClick={() => {
                      setSearchQuery(t.tag);
                      setIsSubmitted(true);
                    }}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-neutral-50 hover:bg-neutral-100 border border-neutral-200/70 text-slate-800 text-[13px] font-medium transition-all active:scale-95 cursor-pointer shadow-2xs"
                  >
                    <span className="text-[#1d64ec] font-bold">#</span>
                    <span>{t.tag}</span>
                    <span className="text-[11px] text-neutral-400 font-normal">· {t.posts}</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Section Heading: "Saran ikuti" */}
            <div className="space-y-2 pt-2">
              <div className="flex items-center justify-between px-1">
                <h2 className="text-[15px] font-bold text-slate-900 tracking-tight leading-snug">
                  Saran ikuti
                </h2>
                <span className="text-[12.5px] text-neutral-400 font-medium leading-snug flex items-center gap-1">
                  <Users className="w-3.5 h-3.5" />
                  Rekomendasi
                </span>
              </div>

              {/* Suggested Accounts List */}
              <div className="divide-y divide-neutral-100 bg-white rounded-2xl border border-neutral-100 shadow-[rgba(0,0,0,0.02)_0px_2px_12px_0px] overflow-hidden">
                {INITIAL_SUGGESTED_ACCOUNTS.map((account) => {
                  const isFollowing = !!followingMap[account.id];

                  return (
                    <div
                      key={account.id}
                      onClick={() => onNavigateToProfile(account.username)}
                      className="flex items-start justify-between gap-3 p-3.5 hover:bg-neutral-50/80 active:bg-neutral-100 transition-colors cursor-pointer leading-snug group"
                    >
                      <div className="w-10 h-10 rounded-full overflow-hidden ring-1 ring-neutral-200/80 shrink-0 mt-0.5 shadow-2xs">
                        <img
                          src={account.avatar}
                          alt={account.fullName}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                          loading="lazy"
                        />
                      </div>

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
                })}
              </div>
            </div>
          </>
        )}

        {/* STAGE 3: Submitted Search Results -> Render based on Active Tab */}
        {hasSearchQuery && isSubmitted && (
          <div className="space-y-4 animate-in fade-in duration-200">
            {/* Tab 1: TERPOPULER */}
            {activeTab === 'top' && (
              <div className="space-y-3">
                {popularPosts.length > 0 ? (
                  popularPosts.map((post) => (
                    <MarketPostCard
                      key={post.id}
                      item={post}
                      onPostClick={onSelectPost}
                      onUserClick={(username) => onNavigateToProfile(username || post.seller.username || 'radityarayhannnn')}
                    />
                  ))
                ) : (
                  <div className="py-14 text-center text-neutral-400 space-y-2">
                    <div className="w-12 h-12 rounded-full bg-neutral-100 flex items-center justify-center mx-auto text-neutral-400">
                      <Search className="w-6 h-6 stroke-[1.8]" />
                    </div>
                    <p className="font-semibold text-slate-800 text-[15px]">Tidak ada utas terpopuler ditemukan</p>
                    <p className="text-xs text-neutral-400 max-w-xs mx-auto">
                      Coba cari dengan kata kunci lain atau lihat tab Profil
                    </p>
                  </div>
                )}
              </div>
            )}

            {/* Tab 2: TERBARU */}
            {activeTab === 'latest' && (
              <div className="space-y-3">
                {latestPosts.length > 0 ? (
                  latestPosts.map((post) => (
                    <MarketPostCard
                      key={post.id}
                      item={post}
                      onPostClick={onSelectPost}
                      onUserClick={(username) => onNavigateToProfile(username || post.seller.username || 'radityarayhannnn')}
                    />
                  ))
                ) : (
                  <div className="py-14 text-center text-neutral-400 space-y-2">
                    <div className="w-12 h-12 rounded-full bg-neutral-100 flex items-center justify-center mx-auto text-neutral-400">
                      <Search className="w-6 h-6 stroke-[1.8]" />
                    </div>
                    <p className="font-semibold text-slate-800 text-[15px]">Tidak ada utas terbaru ditemukan</p>
                    <p className="text-xs text-neutral-400 max-w-xs mx-auto">
                      Coba cari dengan kata kunci lain
                    </p>
                  </div>
                )}
              </div>
            )}

            {/* Tab 3: PROFIL */}
            {activeTab === 'profiles' && (
              <div className="space-y-2">
                {scoredAccounts.length > 0 ? (
                  <div className="divide-y divide-neutral-100 bg-white rounded-2xl border border-neutral-100 shadow-[rgba(0,0,0,0.02)_0px_2px_12px_0px] overflow-hidden">
                    {scoredAccounts.map((account) => {
                      const isFollowing = !!followingMap[account.id];
                      return (
                        <div
                          key={account.id}
                          onClick={() => onNavigateToProfile(account.username)}
                          className="flex items-start justify-between gap-3 p-3.5 hover:bg-neutral-50/80 active:bg-neutral-100 transition-colors cursor-pointer leading-snug group"
                        >
                          <div className="w-10 h-10 rounded-full overflow-hidden ring-1 ring-neutral-200/80 shrink-0 mt-0.5 shadow-2xs">
                            <img
                              src={account.avatar}
                              alt={account.fullName}
                              className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                              loading="lazy"
                            />
                          </div>

                          <div className="flex-1 min-w-0 pr-1 leading-snug">
                            <div className="flex items-center gap-1 leading-tight">
                              <span className="font-bold text-[14.5px] text-slate-900 truncate">
                                {account.username}
                              </span>
                              {account.isVerified && <ClickableVerifiedBadge className="w-3.5 h-3.5 shrink-0" />}
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
                    })}
                  </div>
                ) : (
                  <div className="py-12 text-center text-neutral-400 space-y-1">
                    <p className="font-semibold text-slate-700">Tidak ada profil ditemukan</p>
                    <p className="text-xs text-neutral-400">Coba cari dengan username atau nama lain</p>
                  </div>
                )}
              </div>
            )}
          </div>
        )}
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
