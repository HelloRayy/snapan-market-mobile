import { useState, useEffect, useRef } from 'react';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { ProfilePage } from '@/ui/pages/ProfilePage';
import { SearchPage } from '@/ui/pages/SearchPage';
import { NavigationDrawer } from '@/ui/components/navigation/NavigationDrawer';
import { CreatePostModal } from '@/ui/components/marketplace/CreatePostModal';
import { MarketPostItem } from '@/types/marketFeed';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
import { useAuth } from '@/ui/hooks/useAuth';
import { useSmoothScroll } from '@/ui/hooks/useSmoothScroll';

// Dynamic URL Helper: Extracts matching post from /@username/post/:postId or #post-:postId
function getPostFromLocation(): MarketPostItem | null {
  if (typeof window === 'undefined') return null;

  const path = window.location.pathname;
  const hash = window.location.hash;

  // 1. Check pathname: /@username/post/:postId or /post/:postId
  if (path.startsWith('/@') || path.startsWith('/post/')) {
    const parts = path.split('/').filter(Boolean);
    const potentialPostId = parts[parts.length - 1];
    if (potentialPostId && potentialPostId !== parts[0]) {
      const found = MOCK_MARKET_POSTS.find(
        (p) => p.id === potentialPostId || p.id === decodeURIComponent(potentialPostId)
      );
      if (found) return found;
    }
  }

  // 2. Check hash fallback: #post-post-thread-1
  if (hash.startsWith('#post-')) {
    const rawId = hash.replace(/^#post-/, '');
    const found = MOCK_MARKET_POSTS.find((p) => p.id === rawId || `post-${p.id}` === rawId);
    if (found) return found;
  }

  return null;
}

export function App() {
  // Initialize Lenis Kinetic Smooth Scroll Engine (120fps physics)
  useSmoothScroll();

  const { user, profile } = useAuth();
  const [isCreateModalOpen, setIsCreateModalOpen] = useState<boolean>(false);

  // Synchronously compute onboarding completion from localStorage / Supabase session to prevent 1-frame splash flash
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState<boolean>(() => {
    if (typeof window === 'undefined') return false;
    const isExplicitOnboardingRoute =
      window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';
    if (isExplicitOnboardingRoute) return false;

    // 1. Check explicit onboarding completion flag
    const savedOnboarded = localStorage.getItem('snapan_has_onboarded');
    if (savedOnboarded === 'true') return true;

    // 2. Check if user already has an active Supabase auth session saved in localStorage
    try {
      const hasSupabaseAuth = Object.keys(localStorage).some(
        (key) => key.startsWith('sb-') && key.endsWith('-auth-token')
      );
      if (hasSupabaseAuth) return true;
    } catch {
      // Safe fallback
    }

    return false;
  });

  const [currentRoute, setCurrentRoute] = useState<string>(window.location.pathname);
  const [selectedPost, setSelectedPost] = useState<MarketPostItem | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);

  // Double-Back to Exit Toast State
  const [showExitToast, setShowExitToast] = useState(false);
  const lastBackPressTimeRef = useRef<number>(0);

  // Scroll Restoration: Preserve home feed scroll, reset non-home routes to top
  const homeScrollYRef = useRef<number>(0);
  const prevRouteRef = useRef<string>(window.location.pathname);
  const postDetailOriginRouteRef = useRef<string>('/');

  // Dynamic Route Checks
  const isDownloadRoute = currentRoute === '/download' || window.location.hash === '#download';
  const isOnboardingRoute = currentRoute === '/onboarding' || window.location.hash === '#onboarding';
  const isSearchRoute = currentRoute === '/search' || window.location.hash === '#search';
  const isPostDetailRoute = currentRoute.includes('/post/') || currentRoute.includes('/postingan/') || window.location.hash.startsWith('#post-');
  
  // Dynamic Route Check: /@username or #@username or /profile (excluding /@username/post/...)
  const isProfileRoute = !isPostDetailRoute && (currentRoute.startsWith('/@') || currentRoute === '/profile' || (window.location.hash.startsWith('#@') && !isPostDetailRoute));
  
  let targetProfileUsername = 'radityarayhannnn';
  if (currentRoute.startsWith('/@')) {
    targetProfileUsername = decodeURIComponent(currentRoute.slice(2).split('/')[0]);
  } else if (window.location.hash.startsWith('#@')) {
    targetProfileUsername = decodeURIComponent(window.location.hash.slice(2).split('/')[0]);
  } else if (currentRoute === '/profile') {
    targetProfileUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';
  }

  const myUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || user?.user_metadata?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';
  const isViewingOtherUserProfile = isProfileRoute && targetProfileUsername !== myUsername && targetProfileUsername !== 'me';

  // Initialize Root History Guard & Deep Link Post Resolver
  useEffect(() => {
    if (typeof window === 'undefined') return;

    // Resolve post from initial URL if navigated directly or reloaded
    const initialPost = getPostFromLocation();
    if (initialPost) {
      setSelectedPost(initialPost);
      const authorHandle = initialPost.seller.username || initialPost.seller.name.toLowerCase().replace(/\s+/g, '') || 'author';
      const cleanHandle = authorHandle.replace(/^@/, '');
      const canonicalUrl = `/@${cleanHandle}/post/${initialPost.id}`;
      window.history.replaceState({ isSnapanRoot: false, layer: 'post-detail', postId: initialPost.id, username: cleanHandle }, '', canonicalUrl);
      setCurrentRoute(canonicalUrl);
    } else if (!window.history.state || !window.history.state.isSnapanRoot) {
      window.history.replaceState({ isSnapanRoot: true, route: window.location.pathname }, '', window.location.pathname);
    }
  }, []);

  // PopState & PWA System Back Button Listener
  useEffect(() => {
    const handlePopState = () => {
      const hash = window.location.hash;
      const nextRoute = window.location.pathname;

      // 1. If currently Drawer is open, close it cleanly
      if (isDrawerOpen) {
        setIsDrawerOpen(false);
        return;
      }

      // 2. Resolve post detail state from popstate URL
      const postMatch = getPostFromLocation();
      if (postMatch) {
        setSelectedPost(postMatch);
      } else {
        setSelectedPost(null);
      }

      // 3. Update route state
      setCurrentRoute(nextRoute);
      if (nextRoute === '/') {
        window.dispatchEvent(new CustomEvent('snapan:show-nav'));
      }

      // 4. Double-Back to Exit Protection when at Root Home
      const nextIsRoot = nextRoute === '/' && !hash.startsWith('#@') && !postMatch;
      if (nextIsRoot && !postMatch && !isDrawerOpen) {
        const now = Date.now();
        if (now - lastBackPressTimeRef.current < 2000) {
          // Double back within 2s -> Allow OS to exit PWA
          window.history.back();
        } else {
          // First back press -> Push root guard state back and show confirmation toast
          lastBackPressTimeRef.current = now;
          window.history.pushState({ isSnapanRoot: true, route: '/' }, '', '/');
          setShowExitToast(true);
          setTimeout(() => setShowExitToast(false), 2000);
        }
      }
    };

    const isExplicitOnboardingRoute =
      window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';

    if (isExplicitOnboardingRoute) {
      setHasCompletedOnboarding(false);
    } else if (user) {
      localStorage.setItem('snapan_has_onboarded', 'true');
      setHasCompletedOnboarding(true);
    }

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, [user, isDrawerOpen]);

  // Route-based Scroll Management: Reset on new non-home routes, restore when returning to Home
  useEffect(() => {
    const prevRoute = prevRouteRef.current;
    const isCurrentHome = !isProfileRoute && !isDownloadRoute && !isOnboardingRoute && !isPostDetailRoute;
    const wasPrevHome = prevRoute === '/' || (!prevRoute.startsWith('/@') && prevRoute !== '/profile' && !prevRoute.startsWith('#@') && prevRoute !== '/download' && prevRoute !== '/onboarding');

    if (wasPrevHome && !isCurrentHome) {
      // Leaving Home -> Reset scroll to top (0, 0) for new route
      window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
    } else if (!wasPrevHome && isCurrentHome) {
      // Returning to Home -> Restore previously saved home scroll position
      requestAnimationFrame(() => {
        window.scrollTo({ top: homeScrollYRef.current, left: 0, behavior: 'instant' });
      });
    } else if (!isCurrentHome) {
      // Switching between non-home routes -> Reset scroll to top
      window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
    }

    prevRouteRef.current = currentRoute;
  }, [currentRoute, isProfileRoute, isDownloadRoute, isOnboardingRoute, isPostDetailRoute]);

  const navigateToWeb = () => {
    window.history.pushState({ route: '/' }, '', '/');
    setCurrentRoute('/');
  };

  const navigateToHome = () => {
    window.dispatchEvent(new CustomEvent('snapan:show-nav'));
    window.history.pushState({ route: '/' }, '', '/');
    setCurrentRoute('/');
  };

  const navigateToSearch = () => {
    // Record current home scroll position before navigating away
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    window.history.pushState({ route: '/search' }, '', '/search');
    setCurrentRoute('/search');
  };

  const navigateToProfile = (username: string) => {
    // Record current home scroll position before navigating away
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    const clean = username.replace(/^@/, '');
    window.history.pushState({ type: 'profile', username: clean }, '', `/@${clean}`);
    setCurrentRoute(`/@${clean}`);
  };

  const handleOpenDrawer = () => {
    window.history.pushState({ layer: 'drawer' }, '', window.location.pathname + window.location.hash);
    setIsDrawerOpen(true);
  };

  const handleCloseDrawer = () => {
    if (window.history.state?.layer === 'drawer') {
      window.history.back();
    } else {
      setIsDrawerOpen(false);
    }
  };

  const handleOpenPostDetail = (post: MarketPostItem) => {
    // Record origin route and home scroll before opening detail
    postDetailOriginRouteRef.current = currentRoute;
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    const authorHandle = post.seller.username || post.seller.name.toLowerCase().replace(/\s+/g, '') || 'author';
    const cleanHandle = authorHandle.replace(/^@/, '');
    const canonicalUrl = `/@${cleanHandle}/post/${post.id}`;
    window.history.pushState(
      { layer: 'post-detail', postId: post.id, username: cleanHandle },
      '',
      canonicalUrl
    );
    setCurrentRoute(canonicalUrl);
    setSelectedPost(post);
  };

  const handleClosePostDetail = () => {
    window.dispatchEvent(new CustomEvent('snapan:show-nav'));
    setSelectedPost(null);
    if (window.history.state?.layer === 'post-detail') {
      window.history.back();
    } else {
      const returnRoute = postDetailOriginRouteRef.current || (currentRoute.startsWith('/@') && !currentRoute.includes('/post/')
        ? `/@${targetProfileUsername}`
        : '/');
      window.history.pushState({ isSnapanRoot: true, route: returnRoute }, '', returnRoute);
      setCurrentRoute(returnRoute);
    }
  };

  const handleOnboardingComplete = () => {
    localStorage.setItem('snapan_has_onboarded', 'true');
    setHasCompletedOnboarding(true);
  };

  return (
    <div className="relative min-h-screen max-w-full w-full bg-pure-white text-slate-ink overflow-x-hidden font-gt-standard">
      {/* Render Dedicated PWA Download Landing Page if route is /download */}
      {isDownloadRoute ? (
        <PwaLandingPage onProceedToWeb={navigateToWeb} />
      ) : hasCompletedOnboarding && !isOnboardingRoute ? (
        <div className="relative min-h-screen">
          {/* Main Feed HomePage (Always preserved in DOM so scroll position is never lost) */}
          <div className={isProfileRoute || isSearchRoute || (selectedPost && postDetailOriginRouteRef.current === '/search') ? 'hidden' : 'block'}>
            <HomePage
              onSelectPost={handleOpenPostDetail}
              onNavigateToProfile={navigateToProfile}
              onNavigateSearch={navigateToSearch}
              onOpenMenu={handleOpenDrawer}
            />
          </div>

          {/* Dedicated Search / Explore Single Page (Preserved in DOM so query, tabs & scroll are never lost) */}
          <div className={isSearchRoute || (selectedPost && postDetailOriginRouteRef.current === '/search') ? 'block' : 'hidden'}>
            <SearchPage
              onBack={() => {
                navigateToHome();
              }}
              onNavigateToProfile={navigateToProfile}
              onNavigateHome={navigateToHome}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={handleOpenDrawer}
            />
          </div>

          {/* Profile Page (Dynamic Route /@username) */}
          {isProfileRoute && (
            <ProfilePage
              username={targetProfileUsername}
              onBack={isViewingOtherUserProfile ? () => window.history.back() : undefined}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={handleOpenDrawer}
              onNavigateTab={(tab) => {
                if (tab === 'home') {
                  navigateToHome();
                }
              }}
            />
          )}

          {/* Side Navigation Drawer (Sliding from Left with Backdrop Blur) */}
          <NavigationDrawer
            isOpen={isDrawerOpen}
            onClose={handleCloseDrawer}
            onNavigateHome={navigateToHome}
            onNavigateSearch={navigateToSearch}
            onNavigateProfile={navigateToProfile}
            onOpenCreateModal={() => setIsCreateModalOpen(true)}
            onNavigateDownload={() => {
              setCurrentRoute('/download');
              window.history.pushState({}, '', '/download');
            }}
          />

          {/* Create Post / New Thread Modal Triggered Globally from Sidebar */}
          <CreatePostModal
            isOpen={isCreateModalOpen}
            onClose={() => setIsCreateModalOpen(false)}
            onSubmitPost={async () => {
              setIsCreateModalOpen(false);
            }}
          />

          {/* Detail Page Layer (Threads/Instagram Subtle Scale Zoom & Fade In) */}
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

          {/* Native Double-Back to Exit Confirmation Toast */}
          {showExitToast && (
            <div className="fixed bottom-20 inset-x-0 mx-auto w-fit z-50 pointer-events-none px-4 py-2 bg-slate-900/90 backdrop-blur-md text-white text-xs font-medium rounded-full shadow-lg flex items-center gap-1.5 animate-toast-pop">
              <span>Tekan sekali lagi untuk keluar</span>
            </div>
          )}
        </div>
      ) : (
        <OnboardingScreen onComplete={handleOnboardingComplete} />
      )}
    </div>
  );
}

export default App;
