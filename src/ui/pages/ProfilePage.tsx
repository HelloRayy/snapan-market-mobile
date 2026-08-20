import React, { useState } from 'react';
import {
  ArrowLeft,
  Settings,
  Share2,
  Globe,
  Sparkles,
  MessageCircle,
  UserPlus,
  UserCheck,
  Grid,
  Repeat2,
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

  // Active Tab state: 'threads' | 'replies' | 'media' | 'reposts'
  const [activeTab, setActiveTab] = useState<'threads' | 'replies' | 'media' | 'reposts'>('threads');

  // Modals state
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [lightboxImage, setLightboxImage] = useState<string | null>(null);

  // Follow Toggle state (for viewing other users)
  const [isFollowing, setIsFollowing] = useState(false);

  // Current logged in user info
  const currentUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || user?.user_metadata?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';
  const cleanTargetUsername = username.replace(/^@/, '').toLowerCase();
  const isOwnProfile = cleanTargetUsername === currentUsername || cleanTargetUsername === 'radityarayhannnn' || cleanTargetUsername === 'me';

  // Profile Data (Customized or Mocked for target user)
  const [profileData, setProfileData] = useState({
    name: isOwnProfile ? (profile?.full_name || 'Raditya Rayhan') : (cleanTargetUsername === 'faizintifada' ? 'Faiz Intifada' : cleanTargetUsername === 'raymondchin' ? 'Raymond Chin' : cleanTargetUsername),
    username: cleanTargetUsername,
    avatar: isOwnProfile
      ? (profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80')
      : (cleanTargetUsername === 'faizintifada'
          ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80'
          : cleanTargetUsername === 'raymondchin'
          ? 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&q=80'
          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=80'),
    classGroup: isOwnProfile ? (profile?.class_group || 'XII PPLG 1') : 'XII PPLG 2 · SMKN 8',
    bio: isOwnProfile
      ? 'Web Developer & UI Enthusiast. Sedia jasa pembuatan landing page PWA & merchandise kelas! 🚀✨'
      : 'Siswa aktif SMKN 8 Jakarta. Suka coding, fotografi & sharing proyek sekolah.',
    followersCount: isOwnProfile ? 142 : 289,
    followingCount: isOwnProfile ? 98 : 140,
    isVerified: true,
  });

  // Filter posts matching this profile
  const userPosts = MOCK_MARKET_POSTS.filter(
    (p) =>
      p.seller.username?.toLowerCase() === cleanTargetUsername ||
      (isOwnProfile && (p.seller.username === 'radityarayhannnn' || p.seller.id === 'user-1'))
  );

  // Fallback if no specific posts found: show sample posts
  const displayPosts = userPosts.length > 0 ? userPosts : MOCK_MARKET_POSTS.slice(0, 2);

  // Extract all media images for Media Tab
  const mediaImages = displayPosts.flatMap((p) => p.images || []);

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
      {/* 1. Top Bar Header */}
      <header
        className="sticky top-0 z-30 bg-white border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between max-w-xl mx-auto"
        style={{ paddingTop: 'env(safe-area-inset-top, 0px)' }}
      >
        {onBack ? (
          <button
            type="button"
            onClick={onBack}
            className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 transition-colors cursor-pointer active:scale-95"
            aria-label="Kembali"
          >
            <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
          </button>
        ) : (
          <div className="flex items-center gap-1.5 text-slate-700">
            <Globe className="w-4 h-4 text-neutral-400" />
            <span className="text-xs font-semibold text-neutral-500">snapan-market.id</span>
          </div>
        )}

        <div className="flex items-center gap-2">
          {/* Quick Share */}
          <button
            type="button"
            onClick={handleShareProfile}
            className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-700 transition-colors cursor-pointer"
            aria-label="Bagikan Profil"
          >
            <Share2 className="w-4.5 h-4.5 stroke-[1.8]" />
          </button>

          {/* Settings / Menu */}
          {isOwnProfile && (
            <button
              type="button"
              onClick={() => setIsSettingsOpen(true)}
              className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-700 transition-colors cursor-pointer"
              aria-label="Pengaturan Akun"
            >
              <Settings className="w-4.5 h-4.5 stroke-[1.8]" />
            </button>
          )}
        </div>
      </header>

      {/* 2. Main Profile Info Section */}
      <main className="max-w-xl mx-auto px-4 pt-4 space-y-4">
        {/* Name, Username, and Avatar Row */}
        <div className="flex items-start justify-between gap-4">
          <div className="space-y-1 flex-1 min-w-0">
            <div className="flex items-center gap-1.5">
              <h1 className="font-bold text-2xl text-slate-900 tracking-tight truncate">
                {profileData.name}
              </h1>
              {profileData.isVerified && (
                <ClickableVerifiedBadge sellerName={profileData.name} className="w-5 h-5" />
              )}
            </div>

            <div className="flex items-center gap-2 text-[14px]">
              <span className="font-semibold text-slate-900">@{profileData.username}</span>
              <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-neutral-100 text-neutral-600">
                {profileData.classGroup}
              </span>
            </div>
          </div>

          {/* Large Profile Picture */}
          <div className="w-18 h-18 rounded-full overflow-hidden border-2 border-neutral-200/90 shadow-sm shrink-0 bg-neutral-100">
            <img
              src={profileData.avatar}
              alt={profileData.name}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        {/* Bio Text */}
        <p className="text-[14.5px] text-slate-800 leading-snug font-normal whitespace-pre-line">
          {profileData.bio}
        </p>

        {/* Follower Stats & Badges */}
        <div className="flex items-center gap-4 text-[13.5px] text-neutral-500 font-medium">
          <span>
            <strong className="text-slate-900 font-bold">{profileData.followersCount}</strong> pengikut
          </span>
          <span>·</span>
          <span>
            <strong className="text-slate-900 font-bold">{profileData.followingCount}</strong> mengikuti
          </span>
          <span>·</span>
          <span className="text-[#1d64ec] font-semibold flex items-center gap-1">
            <Sparkles className="w-3.5 h-3.5" />
            <span>SMKN 8 Jakarta</span>
          </span>
        </div>

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
                Bagikan profil
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
                    <span>Ikuti</span>
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

        {/* 3. 4-Tab Sliding Underline Switcher (Utas, Balasan, Media, Diposting Ulang) */}
        <div className="border-b border-neutral-200/80 pt-2 -mx-4 px-4">
          <div className="flex items-center justify-between text-center relative">
            <button
              type="button"
              onClick={() => setActiveTab('threads')}
              className={`flex-1 py-3 text-[14px] transition-colors relative cursor-pointer ${
                activeTab === 'threads' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              <span>Utas</span>
              {activeTab === 'threads' && (
                <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-slate-900" />
              )}
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('replies')}
              className={`flex-1 py-3 text-[14px] transition-colors relative cursor-pointer ${
                activeTab === 'replies' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              <span>Balasan</span>
              {activeTab === 'replies' && (
                <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-slate-900" />
              )}
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('media')}
              className={`flex-1 py-3 text-[14px] transition-colors relative cursor-pointer ${
                activeTab === 'media' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              <span>Media</span>
              {activeTab === 'media' && (
                <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-slate-900" />
              )}
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('reposts')}
              className={`flex-1 py-3 text-[14px] transition-colors relative cursor-pointer ${
                activeTab === 'reposts' ? 'font-bold text-slate-900' : 'font-medium text-neutral-400 hover:text-slate-700'
              }`}
            >
              <span>Diposting ulang</span>
              {activeTab === 'reposts' && (
                <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-slate-900" />
              )}
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
                        alt={`Media ${idx}`}
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

          {/* TAB 4: DIPOSTING ULANG (Reposts) */}
          {activeTab === 'reposts' && (
            <div>
              <div className="px-4 py-2 bg-neutral-50/70 border-b border-neutral-100 flex items-center gap-2 text-xs text-neutral-500">
                <Repeat2 className="w-4 h-4 text-emerald-600" />
                <span>{profileData.name} memposting ulang</span>
              </div>
              <MarketPostCard
                item={MOCK_MARKET_POSTS[1]}
                onAddToCart={onAddToCart}
                onPostClick={onSelectPost}
              />
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
          onTabChange={(tab) => onNavigateTab?.(tab)}
          onPostClick={() => onNavigateTab?.('post')}
        />
      )}
    </div>
  );
};
