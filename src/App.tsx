import { useState, useEffect } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { MarketPostItem } from '@/types/marketFeed';

import { useAuth } from '@/ui/hooks/useAuth';

export function App() {
  const { user } = useAuth();
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

  const navigateToWeb = () => {
    window.history.pushState({}, '', '/');
    setCurrentRoute('/');
  };

  const handleOnboardingComplete = () => {
    localStorage.setItem('snapan_has_onboarded', 'true');
    setHasCompletedOnboarding(true);
  };

  return (
    <div className="relative min-h-screen bg-pure-white text-slate-ink overflow-x-hidden font-gt-standard">
      {/* Render Dedicated PWA Download Landing Page if route is /download */}
      {isDownloadRoute ? (
        <PwaLandingPage onProceedToWeb={navigateToWeb} />
      ) : hasCompletedOnboarding && !isOnboardingRoute ? (
        <div className="relative min-h-screen">
          {/* Main Feed HomePage (Always kept in DOM so scroll position is NEVER reset) */}
          <HomePage onSelectPost={(post) => setSelectedPost(post)} />

          {/* Slide-over Detail Page Layer (Slides Right-to-Left on Open, Left-to-Right on Close) */}
          <AnimatePresence>
            {selectedPost && (
              <motion.div
                key={selectedPost.id}
                initial={{ x: '100%' }}
                animate={{ x: 0 }}
                exit={{ x: '100%' }}
                transition={{ type: 'tween', duration: 0.20, ease: [0.25, 1, 0.5, 1] }}
                className="fixed inset-0 z-50 bg-white overflow-y-auto"
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
