import React, { useState, useEffect, useRef } from 'react';
import {
  ArrowLeft,
  Menu,
  MessageCircle,
  UserPlus,
  UserCheck,
  Grid,
  Package,
  Search,
  X,
} from 'lucide-react';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { ReplyThreadCard } from '../components/marketplace/ReplyThreadCard';
import { MarketBottomNav } from '../components/marketplace/MarketBottomNav';
import { EditProfileModal } from '../components/profile/EditProfileModal';
import { SettingsBottomSheet } from '../components/profile/SettingsBottomSheet';
import { MediaLightboxModal } from '../components/marketplace/MediaLightboxModal';
import { ClickableVerifiedBadge } from '../components/marketplace/VerifiedBadgeModal';
import { SnapanBrandMark } from '../components/marketplace/MarketHeader';
import { MOCK_MARKET_POSTS, MOCK_USER_REPLIES } from '@/data/mockMarketData';
import { MarketPostItem } from '@/types/marketFeed';
import { useAuth } from '../hooks/useAuth';

interface ProfilePageProps {
  username?: string;
  onBack?: () => void;
  onSelectPost?: (post: MarketPostItem) => void;
  onAddToCart?: (post: MarketPostItem) => void;
  onNavigateTab?: (tab: string) => void;
}

export const ProfilePage: React.FC<ProfilePageProps> = ({
  username = 'radityarayhannnn',
  onBack,
  onSelectPost,
  onAddToCart,
  onNavigateTab,
}) => {
  const { user, profile } = useAuth();

  // Active Tab state: 'threads' | 'replies' | 'media'
  const [activeTab, setActiveTab] = useState<'threads' | 'replies' | 'media'>('threads');

  // Search state for Profile Top Bar
  const [showSearchInput, setShowSearchInput] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Modals state
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [lightboxImage, setLightboxImage] = useState<string | null>(null);

  // Follow Toggle state (for viewing other users)
  const [isFollowing, setIsFollowing] = useState(false);

  // Smart Scroll Header Visibility State (24px threshold as requested)
  const [isHeaderVisible, setIsHeaderVisible] = useState(true);
  const lastScrollY = useRef(0);

  const cleanTargetUsername = username.replace(/^@/, '').toLowerCase();
  const isViewingOtherUserProfile = cleanTargetUsername !== 'radityarayhannnn' && cleanTargetUsername !== 'me';

  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;
      const scrollDiff = currentScrollY - lastScrollY.current;

      // Always show if near the top (< 50px)
      if (currentScrollY < 50) {
        setIsHeaderVisible(true);
      } else if (scrollDiff > 24) {
        // Scrolling DOWN -> hide top bar
        setIsHeaderVisible(false);
      } else if (scrollDiff < -24) {
        // Scrolling UP -> reveal top bar immediately
        setIsHeaderVisible(true);
      }

      lastScrollY.current = currentScrollY;
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Sync follow state
  useEffect(() => {
    if (isViewingOtherUserProfile) {
      setIsFollowing(false);
    }
  }, [isViewingOtherUserProfile, username]);

  // Current logged in user info
  const currentUsername =
    profile?.full_name?.toLowerCase().replace(/\s+/g, '') ||
    user?.user_metadata?.full_name?.toLowerCase().replace(/\s+/g, '') ||
    'radityarayhannnn';
  const isOwnProfile =
    cleanTargetUsername === currentUsername ||
    cleanTargetUsername === 'radityarayhannnn' ||
    cleanTargetUsername === 'me';

  // Profile Data
  const [profileData, setProfileData] = useState({
    name: isOwnProfile
      ? (profile?.full_name || 'Raditya Rayhan')
      : username === 'me'
      ? (profile?.full_name || 'Raditya Rayhan')
      : cleanTargetUsername.charAt(0).toUpperCase() + cleanTargetUsername.slice(1),
    username: cleanTargetUsername,
    avatar: isOwnProfile
      ? (profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80')
      : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
    bio: isOwnProfile
      ? ((profile as { bio?: string } | null)?.bio || 'Building scalable mobile applications & web apps with clean architecture.')
      : 'Siswa SMKN 8 Jakarta · Jurusan PPLG & DKV.',
    classGroup: isOwnProfile
      ? (profile?.class_group || 'XII PPLG 1')
      : 'XII PPLG 2',
    tags: isOwnProfile
      ? ['💻 Web PWA', '🎨 UI/UX', '👕 Preloved', '⚡ Joki Coding', '🍱 Kuliner']
      : ['📱 Flutter', '🎨 Figma', '📷 Fotografi', '💼 Project PJBL'],
    followersCount: isOwnProfile ? 142 : 289,
    soldCount: isOwnProfile ? 24 : 42,
    rating: 4.9,
    isVerified: true,
  });

  // Filter posts matching this profile
  const userPosts = MOCK_MARKET_POSTS.filter(
    (p) =>
      p.seller.username?.toLowerCase() === cleanTargetUsername ||
      (isOwnProfile && (p.seller.username === 'radityarayhannnn' || p.seller.id === 'user-1'))
  );

  // Fallback if no specific posts found: show sample posts
  const basePosts = userPosts.length > 0 ? userPosts : MOCK_MARKET_POSTS.slice(0, 2);
  const displayPosts = basePosts.filter((p) => {
    if (!searchQuery) return true;
    return p.caption.toLowerCase().includes(searchQuery.toLowerCase());
  });

  // Filtered Replies
  const displayReplies = MOCK_USER_REPLIES.filter((t) => {
    if (!searchQuery) return true;
    return (
      t.reply.content.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.parentPost.caption.toLowerCase().includes(searchQuery.toLowerCase())
    );
  });

  // Extract all media items linked to their parent post for Media Tab
  const mediaItems = basePosts.flatMap((post) =>
    (post.images || []).map((imgUrl) => ({
      imgUrl,
      post,
    }))
  ).filter(m => {
    if (!searchQuery) return true;
    return m.post.caption.toLowerCase().includes(searchQuery.toLowerCase());
  });

  return (
    <div className="min-h-screen bg-white text-slate-ink pb-28 font-gt-standard select-none">
      {/* 1. Top Bar Header: [ Left: Menu Icon ] --- [ Center: Logo Mark ] --- [ Right: Search Toggle ] */}
      <header
        className={`sticky top-0 z-30 bg-white font-gt-standard select-none transition-all duration-200 ease-[cubic-bezier(0.25,1,0.5,1)] ${
          isHeaderVisible ? 'opacity-100 border-b border-neutral-200/80' : 'max-h-0 opacity-0 pointer-events-none overflow-hidden'
        }`}
        style={{ paddingTop: 'env(safe-area-inset-top, 0px)' }}
      >
        <div className="w-full max-w-[590px] mx-auto px-4 h-14 flex items-center justify-between relative select-none">
          {/* Left Side: Back button or Hamburger Menu */}
          <div className="flex items-center">
            {onBack ? (
              <button
                type="button"
                onClick={onBack}
                className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
                aria-label="Kembali"
              >
                <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
              </button>
            ) : (
              <button
                type="button"
                onClick={() => setIsSettingsOpen(true)}
                className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
                aria-label="Menu Pengaturan"
              >
                <Menu className="w-5 h-5 stroke-[2.25]" />
              </button>
            )}
          </div>

          {/* Center: Brand Mark Logo with Micro Hover/Tap Effect */}
          <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
            <button
              type="button"
              onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
              className="flex items-center justify-center hover:scale-105 active:scale-95 transition-all duration-200 cubic-bezier(0.25,1,0.5,1) cursor-pointer"
              aria-label="Snapan Logo"
            >
              <SnapanBrandMark className="w-8 h-8 text-slate-900" />
            </button>
          </div>

          {/* Right Side: Search Toggle Button */}
          <div className="flex items-center">
            <button
              type="button"
              onClick={() => {
                setShowSearchInput(!showSearchInput);
                if (showSearchInput) {
                  setSearchQuery('');
                }
              }}
              className="w-10 h-10 rounded-full flex items-center justify-center text-slate-800 hover:bg-neutral-100/90 active:scale-90 transition-all cursor-pointer"
              aria-label="Cari di Profil"
            >
              {showSearchInput ? (
                <X className="w-5 h-5 text-slate-900 stroke-[2.25]" />
              ) : (
                <Search className="w-5 h-5 text-slate-900 stroke-[2.25]" />
              )}
            </button>
          </div>
        </div>

        {/* Collapsible Search Input Row */}
        {showSearchInput && (
          <div className="max-w-[590px] mx-auto px-4 pb-2.5 animate-in fade-in slide-in-from-top-2 duration-200">
            <div className="relative flex items-center">
              <Search className="absolute left-3.5 w-4 h-4 text-neutral-400 pointer-events-none" />
              <input
                type="text"
                autoFocus
                placeholder="Cari utas atau media di profil..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 text-sm rounded-xl border border-neutral-300 bg-neutral-50 text-slate-900 focus:bg-white focus:border-[#1d64ec] focus:outline-none focus:ring-2 focus:ring-blue-500/20 transition-all font-normal"
              />
            </div>
          </div>
        )}
      </header>

      {/* 2. Main Content Area */}
      <main className="w-full max-w-[590px] mx-auto px-4 pt-4 space-y-4">
        {/* PROFILE HEADER */}
        <section className="space-y-3.5 pt-1">
          {/* Row 1: Name + Handle on Left vs Avatar on Right (Vertically Centered with Margin Bottom for Desc) */}
          <div className="flex items-center justify-between gap-4 mb-3.5">
            {/* Name, Handle, and Class on Left */}
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-1.5 min-w-0">
                <h1 className="font-bold text-[22px] sm:text-[24px] text-slate-900 tracking-tight leading-tight truncate">
                  {profileData.name}
                </h1>
                {profileData.isVerified && (
                  <ClickableVerifiedBadge sellerName={profileData.name} className="w-5 h-5 shrink-0" />
                )}
              </div>

              <p className="text-[14.5px] sm:text-[15px] text-neutral-500 font-normal mt-1">
                @{profileData.username} · <span className="font-medium text-slate-700">{profileData.classGroup}</span>
              </p>
            </div>

            {/* Avatar on Far Right (60x60px - Apple HIG Standard) */}
            <div className="relative shrink-0">
              <div className="w-[60px] h-[60px] rounded-full overflow-hidden border border-neutral-200 shadow-2xs bg-neutral-100">
                <img
                  src={profileData.avatar}
                  alt={profileData.name}
                  className="w-full h-full object-cover"
                />
              </div>
            </div>
          </div>

          {/* Row 2: Bio Text */}
          <p className="text-[14.5px] sm:text-[15px] text-slate-900 leading-relaxed font-normal whitespace-pre-line">
            {profileData.bio}
          </p>

          {/* Row 3: Cohesive Left-Aligned Follower & Market Stats (Apple HIG Standard) */}
          <div className="flex items-center gap-2 text-[14.5px] text-neutral-500 font-normal flex-wrap pt-0.5 select-none">
            {/* 3-Avatar Overlapping Stack (20x20px with crisp ring) */}
            <div className="flex items-center -space-x-1.5 shrink-0">
              <div className="w-5 h-5 rounded-full overflow-hidden ring-2 ring-white bg-neutral-200 z-30 shadow-2xs">
                <img
                  src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=60&q=80"
                  alt="Follower 1"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="w-5 h-5 rounded-full overflow-hidden ring-2 ring-white bg-neutral-200 z-20 shadow-2xs">
                <img
                  src="https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=60&q=80"
                  alt="Follower 2"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="w-5 h-5 rounded-full overflow-hidden ring-2 ring-white bg-neutral-200 z-10 shadow-2xs">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=60&q=80"
                  alt="Follower 3"
                  className="w-full h-full object-cover"
                />
              </div>
            </div>

            {/* Follower Stats */}
            <span className="hover:underline cursor-pointer">
              <strong className="text-slate-900 font-semibold">{profileData.followersCount}</strong> pengikut
            </span>

            {/* Conditional Seller Stats (Only when seller has sold items / mode jualan) */}
            {profileData.soldCount > 0 ? (
              <>
                <span className="text-neutral-300">·</span>
                <span>
                  <strong className="text-slate-900 font-semibold">{profileData.soldCount}</strong> terjual
                </span>
                <span className="text-neutral-300">·</span>
                <span className="flex items-center gap-1">
                  <span>⭐</span>
                  <span>
                    <strong className="text-slate-900 font-semibold">{profileData.rating}</strong> (18)
                  </span>
                </span>
              </>
            ) : (
              <>
                <span className="text-neutral-300">·</span>
                <span>22,4 rb tayangan</span>
              </>
            )}
          </div>
        </section>

        {/* Action Buttons */}
        <div className="flex items-center gap-2 pt-1">
          {isOwnProfile ? (
            <button
              type="button"
              onClick={() => setIsEditModalOpen(true)}
              className="w-full h-9 rounded-xl border border-neutral-300 font-bold text-[13.5px] text-slate-900 hover:bg-neutral-50 active:scale-[0.98] transition-all cursor-pointer flex items-center justify-center"
            >
              Edit profil
            </button>
          ) : (
            <>
              <button
                type="button"
                onClick={() => {
                  setIsFollowing(!isFollowing);
                  setProfileData((prev) => ({
                    ...prev,
                    followersCount: isFollowing ? prev.followersCount - 1 : prev.followersCount + 1,
                  }));
                }}
                className={`flex-1 h-9 rounded-xl font-bold text-[13.5px] transition-all cursor-pointer flex items-center justify-center gap-1.5 active:scale-[0.98] ${
                  isFollowing
                    ? 'border border-neutral-300 bg-white text-slate-900 hover:bg-neutral-50'
                    : 'bg-[#18181b] text-white hover:bg-black'
                }`}
              >
                {isFollowing ? (
                  <>
                    <UserCheck className="w-4 h-4" />
                    <span>Mengikuti</span>
                  </>
                ) : (
                  <>
                    <UserPlus className="w-4 h-4" />
                    <span>Ikuti Toko</span>
                  </>
                )}
              </button>
              <button
                type="button"
                onClick={() => {
                  alert(`Fitur chat langsung dengan @${profileData.username} akan segera hadir!`);
                }}
                className="flex-1 h-9 rounded-xl border border-neutral-300 font-bold text-[13.5px] text-slate-900 hover:bg-neutral-50 active:scale-[0.98] transition-all cursor-pointer flex items-center justify-center gap-1.5"
              >
                <MessageCircle className="w-4 h-4 text-slate-700" />
                <span>Pesan</span>
              </button>
            </>
          )}
        </div>

        {/* 3. 3-Tab Sliding Switcher (Utas, Balasan, Media) with Smooth Hardware-Accelerated Motion */}
        <div
          className={`border-b border-neutral-200/80 -mx-4 px-4 bg-white sticky z-20 select-none transition-[top] duration-200 ease-[cubic-bezier(0.25,1,0.5,1)] ${
            isHeaderVisible ? 'top-14' : 'top-0'
          }`}
          style={{
            paddingTop: isHeaderVisible ? 0 : 'env(safe-area-inset-top, 0px)',
          }}
        >
          <div className="max-w-[590px] mx-auto flex items-center relative">
            {/* Smooth Sliding Underline Bar across 3 Tabs (w-1/3) */}
            <div
              className={`absolute bottom-0 left-0 w-1/3 h-[2px] bg-slate-900 transition-transform duration-200 cubic-bezier(0.25,1,0.5,1) ${
                activeTab === 'threads'
                  ? 'translate-x-0'
                  : activeTab === 'replies'
                  ? 'translate-x-full'
                  : 'translate-x-[200%]'
              }`}
            />

            <button
              type="button"
              onClick={() => setActiveTab('threads')}
              className={`flex-1 py-3 text-[14px] text-center relative cursor-pointer transition-colors ${
                activeTab === 'threads' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              Utas
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('replies')}
              className={`flex-1 py-3 text-[14px] text-center relative cursor-pointer transition-colors ${
                activeTab === 'replies' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              Balasan
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('media')}
              className={`flex-1 py-3 text-[14px] text-center relative cursor-pointer transition-colors ${
                activeTab === 'media' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              Media
            </button>
          </div>
        </div>

        {/* 4. Tab Content Area */}
        <div className="-mx-4">
          {/* TAB 1: UTAS & JUALAN (Unified Feed) */}
          {activeTab === 'threads' && (
            <div>
              {displayPosts.length > 0 ? (
                displayPosts.map((post) => (
                  <MarketPostCard
                    key={post.id}
                    item={post}
                    onAddToCart={onAddToCart}
                    onPostClick={onSelectPost}
                  />
                ))
              ) : (
                <div className="py-16 text-center text-neutral-400 space-y-1">
                  <Package className="w-8 h-8 mx-auto text-neutral-300" />
                  <p className="font-semibold text-sm text-slate-800">Belum ada postingan</p>
                  <p className="text-xs">Postingan dan produk jualan akan muncul di sini.</p>
                </div>
              )}
            </div>
          )}

          {/* TAB 2: BALASAN (Connected Thread Chain Replies) */}
          {activeTab === 'replies' && (
            <div className="divide-y divide-neutral-200">
              {displayReplies.length > 0 ? (
                displayReplies.map((thread) => (
                  <ReplyThreadCard
                    key={thread.id}
                    thread={thread}
                    onPostClick={onSelectPost}
                  />
                ))
              ) : (
                <div className="py-16 text-center text-neutral-400 space-y-1">
                  <Package className="w-8 h-8 mx-auto text-neutral-300" />
                  <p className="font-semibold text-sm text-slate-800">Belum ada balasan</p>
                  <p className="text-xs">Balasan kamu pada utas orang lain akan muncul di sini.</p>
                </div>
              )}
            </div>
          )}

          {/* TAB 3: MEDIA (3-Column Vertical 3:4 Aspect Ratio Grid) */}
          {activeTab === 'media' && (
            <div className="p-1">
              {mediaItems.length > 0 ? (
                <div className="grid grid-cols-3 gap-1 sm:gap-1.5">
                  {mediaItems.map((item, idx) => (
                    <div
                      key={idx}
                      onClick={() => onSelectPost?.(item.post)}
                      className="aspect-[3/4] bg-neutral-100 overflow-hidden relative group cursor-pointer active:opacity-80 transition-all rounded-xs sm:rounded-sm shadow-2xs"
                    >
                      <img
                        src={item.imgUrl}
                        alt="Media"
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
                      />
                    </div>
                  ))}
                </div>
              ) : (
                <div className="py-16 text-center text-neutral-400 space-y-1">
                  <Grid className="w-8 h-8 mx-auto text-neutral-300" />
                  <p className="font-semibold text-sm text-slate-800">Belum ada media</p>
                  <p className="text-xs">Foto dari postingan akan tampil dalam galeri ini.</p>
                </div>
              )}
            </div>
          )}
        </div>
      </main>

      {/* Edit Profile Modal */}
      <EditProfileModal
        isOpen={isEditModalOpen}
        onClose={() => setIsEditModalOpen(false)}
        initialName={profileData.name}
        initialBio={profileData.bio}
        initialClassGroup={profileData.classGroup}
        initialAvatar={profileData.avatar}
        onSave={(data) => {
          setProfileData((prev) => ({
            ...prev,
            name: data.name,
            bio: data.bio,
            classGroup: data.classGroup,
            avatar: data.avatar,
          }));
        }}
      />

      {/* Settings Bottom Sheet */}
      <SettingsBottomSheet
        isOpen={isSettingsOpen}
        onClose={() => setIsSettingsOpen(false)}
        onEditProfileClick={() => setIsEditModalOpen(true)}
      />

      {/* Lightbox Modal */}
      {lightboxImage && (
        <MediaLightboxModal
          isOpen={!!lightboxImage}
          images={[lightboxImage]}
          onClose={() => setLightboxImage(null)}
        />
      )}

      {/* Bottom Nav: Only show if root tab view */}
      {!onBack && (
        <MarketBottomNav
          activeTab="profile"
          userAvatar={profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'}
          onTabChange={(tab) => onNavigateTab?.(tab)}
          onPostClick={() => onNavigateTab?.('post')}
        />
      )}
    </div>
  );
};
