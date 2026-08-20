import React, { useState } from 'react';
import {
  ArrowLeft,
  Settings,
  Share2,
  Menu,
  Store,
  MessageCircle,
  UserPlus,
  UserCheck,
  Grid,
  Package,
} from 'lucide-react';
import { MarketPostCard } from '../components/marketplace/MarketPostCard';
import { MarketBottomNav } from '../components/marketplace/MarketBottomNav';
import { EditProfileModal } from '../components/profile/EditProfileModal';
import { SettingsBottomSheet } from '../components/profile/SettingsBottomSheet';
import { MediaLightboxModal } from '../components/marketplace/MediaLightboxModal';
import { ClickableVerifiedBadge } from '../components/marketplace/VerifiedBadgeModal';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
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

  // Modals state
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [lightboxImage, setLightboxImage] = useState<string | null>(null);

  // Follow Toggle state (for viewing other users)
  const [isFollowing, setIsFollowing] = useState(false);

  // Current logged in user info
  const currentUsername =
    profile?.full_name?.toLowerCase().replace(/\s+/g, '') ||
    user?.user_metadata?.full_name?.toLowerCase().replace(/\s+/g, '') ||
    'radityarayhannnn';
  const cleanTargetUsername = username.replace(/^@/, '').toLowerCase();
  const isOwnProfile =
    cleanTargetUsername === currentUsername ||
    cleanTargetUsername === 'radityarayhannnn' ||
    cleanTargetUsername === 'me';

  // Profile Data (Customized or Mocked for target user)
  const [profileData, setProfileData] = useState({
    name: isOwnProfile
      ? (profile?.full_name || 'Raditya Rayhan')
      : cleanTargetUsername === 'faizintifada'
      ? 'Faiz Intifada'
      : cleanTargetUsername === 'raymondchin'
      ? 'Raymond Chin'
      : cleanTargetUsername,
    username: cleanTargetUsername,
    avatar: isOwnProfile
      ? (profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80')
      : cleanTargetUsername === 'faizintifada'
      ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80'
      : cleanTargetUsername === 'raymondchin'
      ? 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&q=80'
      : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80',
    classGroup: isOwnProfile ? (profile?.class_group || 'XII PPLG 1') : 'XII PPLG 2 · SMKN 8',
    bio: isOwnProfile
      ? 'Web Developer & UI Enthusiast. Sedia jasa pembuatan landing page PWA & merchandise kelas! 🚀✨'
      : 'Siswa aktif SMKN 8 Jakarta. Suka coding, fotografi & sharing proyek sekolah.',
    followersCount: isOwnProfile ? 142 : 289,
    followingCount: isOwnProfile ? 98 : 140,
    soldCount: isOwnProfile ? 24 : 42,
    activeProductsCount: isOwnProfile ? 6 : 9,
    rating: 4.9,
    ratingCount: 18,
    isVerified: true,
    skills: isOwnProfile
      ? ['💻 Web PWA', '🎨 UI/UX', '👕 Preloved', '⚡ Joki Coding', '🍱 Kuliner']
      : ['📱 Flutter', '🎨 Figma', '📷 Fotografi', '💼 Project PJBL'],
  });

  // Filter posts matching this profile
  const userPosts = MOCK_MARKET_POSTS.filter(
    (p) =>
      p.seller.username?.toLowerCase() === cleanTargetUsername ||
      (isOwnProfile && (p.seller.username === 'radityarayhannnn' || p.seller.id === 'user-1'))
  );

  // Fallback if no specific posts found: show sample posts
  const basePosts = userPosts.length > 0 ? userPosts : MOCK_MARKET_POSTS.slice(0, 2);
  const displayPosts = basePosts;

  // Extract all media images for Media Tab
  const mediaImages = basePosts.flatMap((p) => p.images || []);

  const handleShareProfile = () => {
    if (navigator.share) {
      navigator.share({
        title: `${profileData.name} (@${profileData.username}) di Snapan Market`,
        url: window.location.href,
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(window.location.href);
      alert('Link profil disalin ke clipboard!');
    }
  };

  return (
    <div className="min-h-screen bg-white text-slate-ink pb-28 font-gt-standard select-none">
      {/* 1. Top Bar Header (Identical layout as Homepage) */}
      <header
        className="sticky top-0 z-30 bg-white border-b border-neutral-200/80 font-gt-standard select-none"
        style={{ paddingTop: 'env(safe-area-inset-top, 0px)' }}
      >
        <div className="w-full max-w-[590px] mx-auto px-4 h-14 flex items-center justify-between relative">
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

          {/* Center: Store / App Logo (Exact rounded square store logo as Homepage) */}
          <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center">
            <button
              type="button"
              onClick={() => window.scrollTo({ top: 0, behavior: 'smooth' })}
              className="w-9 h-9 rounded-xl bg-slate-900 flex items-center justify-center text-white shadow-xs hover:scale-105 active:scale-95 transition-all duration-200 cursor-pointer"
              aria-label="Snapan Market Logo"
            >
              <Store className="w-5 h-5 text-white stroke-[2.25]" />
            </button>
          </div>

          {/* Right Side: Quick Share & Settings */}
          <div className="flex items-center gap-1">
            <button
              type="button"
              onClick={handleShareProfile}
              className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
              aria-label="Bagikan Profil"
            >
              <Share2 className="w-5 h-5 stroke-[1.8]" />
            </button>

            {isOwnProfile && (
              <button
                type="button"
                onClick={() => setIsSettingsOpen(true)}
                className="w-10 h-10 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-90"
                aria-label="Pengaturan Akun"
              >
                <Settings className="w-5 h-5 stroke-[1.8]" />
              </button>
            )}
          </div>
        </div>
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

          {/* Row 3: Cohesive Left-Aligned Follower & Market Stats */}
          <div className="flex items-center gap-1.5 text-[13.5px] text-neutral-500 font-normal flex-wrap pt-0.5">
            {/* Mini Avatar Stack */}
            <div className="flex items-center shrink-0 mr-1">
              <div className="w-[18px] h-[18px] rounded-full overflow-hidden border border-white bg-neutral-200 z-30 shadow-2xs">
                <img
                  src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=60&q=80"
                  alt="Follower 1"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="w-[18px] h-[18px] rounded-full overflow-hidden border border-white bg-neutral-200 -ml-1.5 z-20 shadow-2xs">
                <img
                  src="https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=60&q=80"
                  alt="Follower 2"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="w-[18px] h-[18px] rounded-full overflow-hidden border border-white bg-neutral-200 -ml-1.5 z-10 shadow-2xs">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=60&q=80"
                  alt="Follower 3"
                  className="w-full h-full object-cover"
                />
              </div>
            </div>

            <span><strong className="text-slate-900 font-semibold">{profileData.followersCount}</strong> pengikut</span>
            <span>·</span>
            <span><strong className="text-slate-900 font-semibold">{profileData.soldCount}</strong> terjual</span>
            <span>·</span>
            <span className="flex items-center gap-1">
              <span>⭐</span>
              <span><strong className="text-slate-900 font-semibold">{profileData.rating}</strong> (18)</span>
            </span>
          </div>
        </section>

        {/* Action Buttons */}
        <div className="flex items-center gap-2 pt-1">
          {isOwnProfile ? (
            <>
              <button
                type="button"
                onClick={() => setIsEditModalOpen(true)}
                className="flex-1 h-9 rounded-xl border border-neutral-300 font-bold text-[13.5px] text-slate-900 hover:bg-neutral-50 active:scale-[0.98] transition-all cursor-pointer flex items-center justify-center"
              >
                Edit profil
              </button>
              <button
                type="button"
                onClick={handleShareProfile}
                className="flex-1 h-9 rounded-xl border border-neutral-300 font-bold text-[13.5px] text-slate-900 hover:bg-neutral-50 active:scale-[0.98] transition-all cursor-pointer flex items-center justify-center"
              >
                Bagikan ID
              </button>
            </>
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
        <div className="border-b border-neutral-200/80 -mx-4 px-4 bg-white sticky top-14 z-20 select-none">
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

          {/* TAB 2: BALASAN (Replies) */}
          {activeTab === 'replies' && (
            <div className="divide-y divide-neutral-100">
              <div className="p-4 space-y-2">
                <div className="flex items-center gap-2 text-xs text-neutral-400">
                  <span>Membalas ke</span>
                  <span className="font-bold text-[#1d64ec]">@faizintifada</span>
                  <span>· 2j lalu</span>
                </div>
                <p className="text-[14.5px] text-slate-900">
                  Keren banget idenya! Bisa custom warna atau ukuran ga bro?
                </p>
              </div>

              <div className="p-4 space-y-2">
                <div className="flex items-center gap-2 text-xs text-neutral-400">
                  <span>Membalas ke</span>
                  <span className="font-bold text-[#1d64ec]">@kantin_smkn8</span>
                  <span>· 1h lalu</span>
                </div>
                <p className="text-[14.5px] text-slate-900">
                  Siang ini masih ready paket nasi ayam gepreknya?
                </p>
              </div>
            </div>
          )}

          {/* TAB 3: MEDIA (3-Column Grid) */}
          {activeTab === 'media' && (
            <div className="p-1">
              {mediaImages.length > 0 ? (
                <div className="grid grid-cols-3 gap-1">
                  {mediaImages.map((imgUrl, idx) => (
                    <div
                      key={idx}
                      onClick={() => setLightboxImage(imgUrl)}
                      className="aspect-square bg-neutral-100 overflow-hidden relative group cursor-pointer"
                    >
                      <img
                        src={imgUrl}
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
