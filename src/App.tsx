import { useState, useEffect, useRef } from 'react';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { ProfilePage } from '@/ui/pages/ProfilePage';
import { NavigationDrawer } from '@/ui/components/navigation/NavigationDrawer';
import { MarketPostItem } from '@/types/marketFeed';
import { useAuth } from '@/ui/hooks/useAuth';

export function App() {
  const { user, profile } = useAuth();

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

  // Check routes
  const isDownloadRoute = currentRoute === '/download' || window.location.hash === '#download';
  const isOnboardingRoute = currentRoute === '/onboarding' || window.location.hash === '#onboarding';
  
  // Dynamic Route Check: /@username or #@username or /profile
  const isProfileRoute = currentRoute.startsWith('/@') || currentRoute === '/profile' || window.location.hash.startsWith('#@');
  
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

  // Initialize Root History Guard for Standalone PWA
  useEffect(() => {
    if (typeof window === 'undefined') return;
    if (!window.history.state || !window.history.state.isSnapanRoot) {
      window.history.replaceState({ isSnapanRoot: true, route: window.location.pathname }, '', window.location.pathname);
    }
  }, []);

  // PopState & PWA System Back Button Listener
  useEffect(() => {
    const handlePopState = () => {
      const hash = window.location.hash;

      // 1. If currently Drawer is open, close it cleanly
      if (isDrawerOpen) {
        setIsDrawerOpen(false);
        return;
      }

      // 2. If currently a Post Detail layer is open, close it cleanly
      if (selectedPost && !hash.startsWith('#post-')) {
        setSelectedPost(null);
        return;
      }

      // 3. Update route state
      const nextRoute = window.location.pathname;
      setCurrentRoute(nextRoute);

      // 4. Double-Back to Exit Protection when at Root Home
      const nextIsRoot = nextRoute === '/' && !hash.startsWith('#@') && !hash.startsWith('#post-');
      if (nextIsRoot && !selectedPost && !isDrawerOpen) {
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
  }, [user, selectedPost, isDrawerOpen]);

  // Route-based Scroll Management: Reset on new non-home routes, restore when returning to Home
  useEffect(() => {
    const prevRoute = prevRouteRef.current;
    const isCurrentHome = !isProfileRoute && !isDownloadRoute && !isOnboardingRoute;
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
  }, [currentRoute, isProfileRoute, isDownloadRoute, isOnboardingRoute]);

  const navigateToWeb = () => {
    window.history.pushState({ route: '/' }, '', '/');
    setCurrentRoute('/');
  };

  const navigateToHome = () => {
    window.history.pushState({ route: '/' }, '', '/');
    setCurrentRoute('/');
  };

  const navigateToProfile = (username: string) => {
    // Record current home scroll position before navigating away
    homeScrollYRef.current = window.scrollY;
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
    // Record home scroll before opening detail
    if (!isProfileRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    window.history.pushState(
      { layer: 'post-detail', postId: post.id },
      '',
      `${window.location.pathname}#post-${post.id}`
    );
    setSelectedPost(post);
  };

  const handleClosePostDetail = () => {
    if (window.location.hash.startsWith('#post-')) {
      window.history.back();
    } else {
      setSelectedPost(null);
    }
  };

  const handleOnboardingComplete = () => {
    localStorage.setItem('snapan_has_onboarded', 'true');
    setHasCompletedOnboarding(true);
  };

  return (
    <div className="relative min-h-screen bg-pure-white text-slate-ink overflow-x-clip font-gt-standard">
      {/* Render Dedicated PWA Download Landing Page if route is /download */}
      {isDownloadRoute ? (
        <PwaLandingPage onProceedToWeb={navigateToWeb} />
      ) : hasCompletedOnboarding && !isOnboardingRoute ? (
        <div className="relative min-h-screen">
          {/* Main Feed HomePage (Always preserved in DOM so scroll position is never lost) */}
          <div className={isProfileRoute ? 'hidden' : 'block'}>
            <HomePage
              onSelectPost={handleOpenPostDetail}
              onNavigateToProfile={navigateToProfile}
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
            onNavigateProfile={navigateToProfile}
            onNavigateDownload={() => {
              setCurrentRoute('/download');
              window.history.pushState({}, '', '/download');
            }}
          />

          {/* Detail Page Layer (Threads/Instagram Subtle Scale Zoom & Fade In) */}
          {selectedPost && (
            <div
              key={selectedPost.id}
              className="fixed inset-0 z-50 bg-white overflow-hidden transform-gpu animate-page-zoom"
              style={{
                willChange: 'transform, opacity',
                backfaceVisibility: 'hidden',
                WebkitBackfaceVisibility: 'hidden',
              }}
            >
              <PostDetailPage
                post={selectedPost}
                onBack={handleClosePostDetail}
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
