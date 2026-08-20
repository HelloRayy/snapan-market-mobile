import { useState, useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { ProfilePage } from '@/ui/pages/ProfilePage';
import { MarketPostItem } from '@/types/marketFeed';
import { useAuth } from '@/ui/hooks/useAuth';

export function App() {
  const { user, profile } = useAuth();
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);
  const [currentRoute, setCurrentRoute] = useState<string>(window.location.pathname);
  const [selectedPost, setSelectedPost] = useState<MarketPostItem | null>(null);

  // Sync route with window location & localStorage/Supabase session check
  useEffect(() => {
    const handlePopState = () => {
      setCurrentRoute(window.location.pathname);
    };

    const isExplicitOnboardingRoute = window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';
    
    if (isExplicitOnboardingRoute) {
      setHasCompletedOnboarding(false);
    } else {
      const savedOnboarded = localStorage.getItem('snapan_has_onboarded');
      if (savedOnboarded === 'true' || user) {
        setHasCompletedOnboarding(true);
      }
    }

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, [user]);

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

  const navigateToWeb = () => {
    window.history.pushState({}, '', '/');
    setCurrentRoute('/');
  };

  const navigateToHome = () => {
    window.history.pushState({}, '', '/');
    setCurrentRoute('/');
  };

  const navigateToProfile = (username: string) => {
    const clean = username.replace(/^@/, '');
    window.history.pushState({}, '', `/@${clean}`);
    setCurrentRoute(`/@${clean}`);
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
              onSelectPost={(post) => setSelectedPost(post)}
              onNavigateToProfile={navigateToProfile}
            />
          </div>

          {/* Profile Page (Dynamic Route /@username) */}
          {isProfileRoute && (
            <ProfilePage
              username={targetProfileUsername}
              onBack={isViewingOtherUserProfile ? () => window.history.back() : undefined}
              onSelectPost={(post) => setSelectedPost(post)}
              onNavigateTab={(tab) => {
                if (tab === 'home') {
                  navigateToHome();
                }
              }}
            />
          )}

          {/* Slide-over Detail Page Layer (Silky 60-120fps GPU Hardware-Accelerated iOS Motion) */}
          <AnimatePresence>
            {selectedPost && (
              <motion.div
                key={selectedPost.id}
                initial={{ transform: 'translate3d(100%, 0, 0)' }}
                animate={{ transform: 'translate3d(0%, 0, 0)' }}
                exit={{ transform: 'translate3d(100%, 0, 0)' }}
                transition={{
                  duration: 0.22,
                  ease: [0.32, 0.72, 0, 1], // Native iOS page push ease curve
                }}
                style={{
                  willChange: 'transform',
                  backfaceVisibility: 'hidden',
                  WebkitBackfaceVisibility: 'hidden',
                }}
                className="fixed inset-0 z-50 bg-white overflow-hidden transform-gpu"
              >
                <PostDetailPage
                  post={selectedPost}
                  onBack={() => setSelectedPost(null)}
                />
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      ) : (
        <OnboardingScreen onComplete={handleOnboardingComplete} />
      )}
    </div>
  );
}

export default App;
