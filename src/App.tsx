import { useEffect } from 'react';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { ProfilePage } from '@/ui/pages/ProfilePage';
import { SearchPage } from '@/ui/pages/SearchPage';
import { DirectMessagesPage } from '@/ui/pages/DirectMessagesPage';
import { ActiveChatOverlay } from '@/ui/components/chat/ActiveChatOverlay';
import { NavigationDrawer } from '@/ui/components/navigation/NavigationDrawer';
import { CreatePostModal } from '@/ui/components/marketplace/CreatePostModal';
import { MarketBottomNav } from '@/ui/components/marketplace/MarketBottomNav';
import { ColorShowcasePage } from '@/ui/pages/ColorShowcasePage';
import { CampusMapPage } from '@/ui/pages/CampusMapPage';
import { useAuth } from '@/ui/hooks/useAuth';
import { useSmoothScroll } from '@/ui/hooks/useSmoothScroll';
import { useAppNavigation, getPostFromLocation } from '@/ui/navigation/useAppNavigation';
import { triggerHaptic } from '@/utils/haptics';

export function App() {
  useSmoothScroll();
  const { profile } = useAuth();

  const {
    hasCompletedOnboarding,
    setHasCompletedOnboarding,
    currentRoute,
    setCurrentRoute,
    selectedPost,
    activeChatThreadId,
    isDrawerOpen,
    setIsDrawerOpen,
    isCreateModalOpen,
    setIsCreateModalOpen,
    postDetailOriginRouteRef,
    navigateToHome,
    navigateToSearch,
    navigateToMessages,
    navigateToProfile,
    navigateToChatThread,
    handleOpenPostDetail,
    handleClosePostDetail,
    handleCloseChatThread,
  } = useAppNavigation();

  // Route Flags
  const isSearchRoute = currentRoute === '/search' || window.location.hash === '#search';
  const isMessagesRoute = currentRoute === '/messages' || currentRoute.startsWith('/direct') || window.location.hash === '#messages';
  const isProfileRoute = currentRoute.startsWith('/@') || currentRoute.startsWith('/profile');
  const isColorsRoute = currentRoute === '/colors' || window.location.hash === '#colors';
  const isMapRoute = currentRoute === '/map' || window.location.hash === '#map';
  const isDownloadLandingRoute = currentRoute === '/download' || currentRoute === '/' || window.location.hash === '#download';
  const isHomeRoute = currentRoute === '/home' || (!isSearchRoute && !isMessagesRoute && !isProfileRoute && !isColorsRoute && !isMapRoute && !isDownloadLandingRoute);

  const targetProfileUsername = isProfileRoute
    ? currentRoute.replace('/@', '').replace('/profile/', '').split('/')[0]
    : 'radityarayhannnn';

  const isViewingOtherUserProfile = isProfileRoute && targetProfileUsername !== 'radityarayhannnn';

  // Global click interception for #post- and /@ links
  useEffect(() => {
    const handleGlobalLinkClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      const anchor = target.closest('a');
      if (!anchor) return;

      const href = anchor.getAttribute('href');
      if (!href) return;

      if (href.startsWith('#post-') || href.startsWith('/post/') || (href.startsWith('/@') && href.includes('/post/'))) {
        e.preventDefault();
        const matchedPost = getPostFromLocation();
        if (matchedPost) {
          handleOpenPostDetail(matchedPost);
        }
      } else if (href.startsWith('/@') && !href.includes('/post/')) {
        e.preventDefault();
        const username = href.replace('/@', '');
        navigateToProfile(username);
      }
    };

    document.addEventListener('click', handleGlobalLinkClick);
    return () => document.removeEventListener('click', handleGlobalLinkClick);
  }, [handleOpenPostDetail, navigateToProfile]);

  return (
    <>
      {/* 1. First-time User Onboarding Screen */}
      {!hasCompletedOnboarding ? (
        <OnboardingScreen
          onComplete={() => {
            try {
              localStorage.setItem('snapan_has_onboarded', 'true');
            } catch {}
            setHasCompletedOnboarding(true);
            navigateToHome();
          }}
        />
      ) : isDownloadLandingRoute ? (
        /* 2. PWA Dedicated Download & Landing Showcase */
        <PwaLandingPage onProceedToWeb={navigateToHome} />
      ) : (
        /* 3. Main Multi-Page App Shell */
        <div className="relative min-h-screen bg-pure-white text-slate-ink flex flex-col font-sans selection:bg-brand-primary selection:text-white">
          {/* Preserved Home Feed */}
          <div className={isHomeRoute && !selectedPost && !activeChatThreadId ? 'block' : 'hidden'}>
            <HomePage
              onNavigateToProfile={navigateToProfile}
              onNavigateSearch={navigateToSearch}
              onNavigateMessages={navigateToMessages}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={() => setIsDrawerOpen(true)}
            />
          </div>

          {/* Preserved Search / Explore Page */}
          <div className={isSearchRoute || (selectedPost && postDetailOriginRouteRef.current === '/search') ? 'block' : 'hidden'}>
            <SearchPage
              onBack={navigateToHome}
              onNavigateToProfile={navigateToProfile}
              onNavigateHome={navigateToHome}
              onNavigateMessages={navigateToMessages}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={() => setIsDrawerOpen(true)}
            />
          </div>

          {/* Profile Page */}
          {isProfileRoute && (
            <ProfilePage
              username={targetProfileUsername}
              onBack={isViewingOtherUserProfile ? () => window.history.back() : undefined}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={() => setIsDrawerOpen(true)}
              onNavigateTab={(tab) => {
                if (tab === 'home') navigateToHome();
                else if (tab === 'messages') navigateToMessages();
              }}
            />
          )}

          {/* Direct Messages Page */}
          {isMessagesRoute && !activeChatThreadId && (
            <DirectMessagesPage
              onBack={navigateToHome}
              onNavigateHome={navigateToHome}
              onNavigateSearch={navigateToSearch}
              onNavigateProfile={navigateToProfile}
              onSelectConversation={navigateToChatThread}
            />
          )}

          {/* Color Laboratory Showcase */}
          {isColorsRoute && (
            <div className="fixed inset-0 z-50 bg-[#f8f9fa] overflow-y-auto">
              <ColorShowcasePage onBack={navigateToHome} />
            </div>
          )}

          {/* Interactive 2D Campus Map Page */}
          {isMapRoute && (
            <div className="fixed inset-0 z-50 bg-[#f8fafc] overflow-y-auto">
              <CampusMapPage onBack={navigateToHome} />
            </div>
          )}

          {/* Navigation Drawer */}
          <NavigationDrawer
            isOpen={isDrawerOpen}
            onClose={() => setIsDrawerOpen(false)}
            onNavigateHome={navigateToHome}
            onNavigateSearch={navigateToSearch}
            onNavigateProfile={navigateToProfile}
            onNavigateMessages={navigateToMessages}
            onOpenCreateModal={() => setIsCreateModalOpen(true)}
            onNavigateDownload={() => {
              setCurrentRoute('/download');
              window.history.pushState({}, '', '/download');
            }}
            onNavigateColors={() => {
              setCurrentRoute('/colors');
              window.history.pushState({}, '', '/colors');
            }}
            onNavigateMap={() => {
              setCurrentRoute('/map');
              window.history.pushState({}, '', '/map');
            }}
          />

          {/* Create Post Modal */}
          <CreatePostModal
            isOpen={isCreateModalOpen}
            onClose={() => setIsCreateModalOpen(false)}
            onSubmitPost={async () => {
              setIsCreateModalOpen(false);
            }}
          />

          {/* Bottom Navigation */}
          {!selectedPost && !activeChatThreadId && !isColorsRoute && !isMapRoute && (
            <MarketBottomNav
              activeTab={
                isMessagesRoute
                  ? 'messages'
                  : isSearchRoute
                  ? 'search'
                  : isProfileRoute && !isViewingOtherUserProfile
                  ? 'profile'
                  : 'home'
              }
              userAvatar={profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'}
              onTabChange={(tab) => {
                triggerHaptic('selection');
                if (tab === 'home') navigateToHome();
                else if (tab === 'search') navigateToSearch();
                else if (tab === 'messages') navigateToMessages();
                else if (tab === 'profile') {
                  navigateToProfile(profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn');
                }
              }}
              onPostClick={() => {
                triggerHaptic('medium');
                setIsCreateModalOpen(true);
              }}
            />
          )}

          {/* Post Detail Modal Layer */}
          {selectedPost && (
            <div
              key={selectedPost.id}
              data-lenis-prevent
              className="fixed inset-0 z-50 bg-white overflow-hidden transform-gpu animate-page-zoom touch-pan-y"
              style={{
                willChange: 'transform, opacity',
                backfaceVisibility: 'hidden',
                WebkitBackfaceVisibility: 'hidden',
              }}
            >
              <PostDetailPage
                post={selectedPost}
                onBack={handleClosePostDetail}
                onUserClick={(uname) => {
                  handleClosePostDetail();
                  navigateToProfile(uname);
                }}
              />
            </div>
          )}

          {/* Active Chat Conversation Layer */}
          {activeChatThreadId && (
            <ActiveChatOverlay
              activeChatThreadId={activeChatThreadId}
              onClose={handleCloseChatThread}
              onNavigateToProfile={navigateToProfile}
            />
          )}
        </div>
      )}
    </>
  );
}

export default App;
