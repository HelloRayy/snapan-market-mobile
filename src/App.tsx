import { useEffect, useState, Suspense, lazy } from 'react';
import { HomePage } from '@/ui/pages/HomePage';
import { ProfilePage } from '@/ui/pages/ProfilePage';
import { SearchPage } from '@/ui/pages/SearchPage';
import { DirectMessagesPage } from '@/ui/pages/DirectMessagesPage';
import { NavigationDrawer } from '@/ui/components/navigation/NavigationDrawer';
import { MarketBottomNav } from '@/ui/components/marketplace/MarketBottomNav';
import { AppEntranceSplash } from '@/ui/components/splash/AppEntranceSplash';
import { useAuth } from '@/ui/hooks/useAuth';
import { useSmoothScroll } from '@/ui/hooks/useSmoothScroll';
import { useAppNavigation, getPostFromLocation } from '@/ui/navigation/useAppNavigation';
import { triggerHaptic } from '@/utils/haptics';

// Dynamic lazy imports for heavy secondary routes & overlays to reduce initial bundle
const OnboardingScreen = lazy(() =>
  import('@/ui/components/onboarding/OnboardingScreen').then((m) => ({ default: m.OnboardingScreen }))
);
const PwaLandingPage = lazy(() =>
  import('@/ui/components/pwa/PwaLandingPage').then((m) => ({ default: m.PwaLandingPage }))
);
const PostDetailPage = lazy(() =>
  import('@/ui/pages/PostDetailPage').then((m) => ({ default: m.PostDetailPage }))
);
const ActiveChatOverlay = lazy(() =>
  import('@/ui/components/chat/ActiveChatOverlay').then((m) => ({ default: m.ActiveChatOverlay }))
);
const CreatePostModal = lazy(() =>
  import('@/ui/components/marketplace/CreatePostModal').then((m) => ({ default: m.CreatePostModal }))
);
const ColorShowcasePage = lazy(() =>
  import('@/ui/pages/ColorShowcasePage').then((m) => ({ default: m.ColorShowcasePage }))
);
const CampusMapPage = lazy(() =>
  import('@/ui/pages/CampusMapPage').then((m) => ({ default: m.CampusMapPage }))
);
const AdminDashboard = lazy(() =>
  import('@/admin/pages/AdminDashboard').then((m) => ({ default: m.AdminDashboard }))
);
const AdminLoginPage = lazy(() =>
  import('@/admin/pages/AdminLoginPage').then((m) => ({ default: m.AdminLoginPage }))
);

import { AuthPromptPopover } from '@/ui/components/auth/AuthPromptPopover';
import { AccountSuspendedScreen } from '@/ui/components/auth/AccountSuspendedScreen';
import { getOreoAvatarUrl } from '@/utils/oreoAvatar';

export function App() {
  useSmoothScroll();
  const { user, profile } = useAuth();
  const [isAuthPromptOpen, setIsAuthPromptOpen] = useState(false);

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

  // Admin Route Flags with path normalization (strips trailing slashes & supports hash routes)
  const windowPath = typeof window !== 'undefined' ? window.location.pathname.replace(/\/+$/, '').toLowerCase() : '';
  const windowHash = typeof window !== 'undefined' ? window.location.hash.toLowerCase() : '';
  const currentPath = currentRoute.replace(/\/+$/, '').toLowerCase();

  const isAdminLoginRoute =
    currentPath === '/admin/login' ||
    windowPath === '/admin/login' ||
    windowHash === '#/admin/login' ||
    windowHash === '#admin/login';

  const isAdminDashboardRoute =
    ((currentPath === '/admin' || currentPath.startsWith('/admin/')) ||
      (windowPath === '/admin' || windowPath.startsWith('/admin/')) ||
      (windowHash === '#/admin' || windowHash === '#admin' || windowHash.startsWith('#/admin/'))) &&
    !isAdminLoginRoute;

  const isAdminRoute = isAdminLoginRoute || isAdminDashboardRoute;

  // Route Flags
  const isSearchRoute = currentRoute === '/search' || (typeof window !== 'undefined' && window.location.hash === '#search');
  const isMessagesRoute = currentRoute === '/messages' || currentRoute.startsWith('/direct') || (typeof window !== 'undefined' && window.location.hash === '#messages');
  const isProfileRoute = currentRoute.startsWith('/@') || currentRoute.startsWith('/profile');
  const isColorsRoute = currentRoute === '/colors' || (typeof window !== 'undefined' && window.location.hash === '#colors');
  const isMapRoute = currentRoute === '/map' || (typeof window !== 'undefined' && window.location.hash === '#map');
  const isLandingRoute =
    !isAdminRoute &&
    (currentRoute === '/' ||
      currentRoute === '/download' ||
      (typeof window !== 'undefined' &&
        (window.location.pathname === '/' ||
          window.location.pathname === '/home' ||
          window.location.hash === '#download')));
  const isHomeRoute =
    !isLandingRoute &&
    !isSearchRoute &&
    !isMessagesRoute &&
    !isProfileRoute &&
    !isColorsRoute &&
    !isMapRoute &&
    !isAdminRoute;

  const targetProfileUsername = isProfileRoute
    ? currentRoute.replace('/@', '').replace('/profile/', '').split('/')[0]
    : 'radityarayhannnn';

  const isViewingOtherUserProfile = isProfileRoute && targetProfileUsername !== 'radityarayhannnn';

  // Check Account Suspension Status (SNAPS-16)
  const isAccountSuspended = Boolean(
    user &&
    profile?.is_suspended &&
    (!profile.suspended_until || new Date(profile.suspended_until).getTime() > Date.now()) &&
    profile.role !== 'admin'
  );

  const [showSplash, setShowSplash] = useState<boolean>(() => {
    if (typeof window !== 'undefined') {
      return !sessionStorage.getItem('snaps_splash_seen');
    }
    return false;
  });

  // Prompt Threads-style login popover on arrival for unauthenticated users
  useEffect(() => {
    if (!user && isHomeRoute) {
      const dismissed = sessionStorage.getItem('snapan_auth_prompt_dismissed');
      if (!dismissed) {
        const timer = setTimeout(() => {
          setIsAuthPromptOpen(true);
        }, 600);
        return () => clearTimeout(timer);
      }
    }
  }, [user, isHomeRoute]);

  // Fallback to login prompt on account suspension (SNAPS-16)
  useEffect(() => {
    const handleAccountSuspended = () => {
      setIsAuthPromptOpen(true);
      navigateToHome();
    };
    window.addEventListener('snapan_account_suspended', handleAccountSuspended);
    return () => window.removeEventListener('snapan_account_suspended', handleAccountSuspended);
  }, [navigateToHome]);

  // Auto-redirect /home to root landing page /
  useEffect(() => {
    if (typeof window !== 'undefined' && window.location.pathname === '/home') {
      window.history.replaceState({}, '', '/');
      setCurrentRoute('/');
    }
  }, [currentRoute, setCurrentRoute]);

  const handleCloseAuthPrompt = () => {
    setIsAuthPromptOpen(false);
    try {
      sessionStorage.setItem('snapan_auth_prompt_dismissed', 'true');
    } catch {}
  };

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
    <Suspense fallback={<div className="min-h-screen bg-white" />}>
      {/* Admin Portal Dedicated Routes (Kumo UI) */}
      {isAdminLoginRoute ? (
        <AdminLoginPage
          onSuccess={() => {
            setCurrentRoute('/admin');
            window.history.pushState({}, '', '/admin');
          }}
          onBackToApp={() => {
            navigateToHome();
          }}
        />
      ) : isAdminDashboardRoute ? (
        <AdminDashboard
          onLogout={() => {
            setCurrentRoute('/admin/login');
            window.history.pushState({}, '', '/admin/login');
          }}
          onNavigateLogin={() => {
            setCurrentRoute('/admin/login');
            window.history.pushState({}, '', '/admin/login');
          }}
        />
      ) : isAccountSuspended ? (
        <AccountSuspendedScreen
          profile={profile as any}
          onLoggedOut={() => {
            window.location.reload();
          }}
        />
      ) : (
        <>
          {/* 0. Staggered Entrance Splash Animation */}
          {showSplash && hasCompletedOnboarding && !isLandingRoute && (
            <AppEntranceSplash
              onComplete={() => {
                try {
                  sessionStorage.setItem('snaps_splash_seen', 'true');
                } catch {}
                setShowSplash(false);
              }}
            />
          )}

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
          ) : isLandingRoute ? (
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
            onNavigateAdmin={() => {
              setCurrentRoute('/admin');
              window.history.pushState({}, '', '/admin');
            }}
            onOpenAuthModal={() => setIsAuthPromptOpen(true)}
          />

          {/* Create Post Modal */}
          <CreatePostModal
            isOpen={isCreateModalOpen}
            onClose={() => setIsCreateModalOpen(false)}
            onSubmitPost={async () => {
              setIsCreateModalOpen(false);
            }}
          />

          {/* Auth Prompt Modal */}
          <AuthPromptPopover
            isOpen={isAuthPromptOpen}
            onClose={handleCloseAuthPrompt}
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
              userAvatar={profile?.avatar_url || getOreoAvatarUrl(profile?.username || 'snapan-user', { size: 100 })}
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

          {/* Threads-Style Auth Prompt Popover */}
          <AuthPromptPopover
            isOpen={isAuthPromptOpen}
            onClose={handleCloseAuthPrompt}
            onSuccess={() => setIsAuthPromptOpen(false)}
          />
        </div>
      )}
      </>
    )}
  </Suspense>
  );
}

export default App;
