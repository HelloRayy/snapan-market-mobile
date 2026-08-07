import { useState, useEffect } from 'react';
import { Agentation } from 'agentation';
import { RotateCcw } from 'lucide-react';
import { SplashScreen } from '@/ui/components/onboarding/SplashScreen';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { MarketThreadItem } from '@/types/marketFeed';

export function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);
  const [currentRoute, setCurrentRoute] = useState<string>(window.location.pathname);
  const [selectedPost, setSelectedPost] = useState<MarketThreadItem | null>(null);

  // Sync route with window location & localStorage session check
  useEffect(() => {
    const handlePopState = () => {
      setCurrentRoute(window.location.pathname);
    };

    const isExplicitOnboardingRoute = window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';
    
    if (isExplicitOnboardingRoute) {
      setHasCompletedOnboarding(false);
    } else {
      const savedOnboarded = localStorage.getItem('snapan_has_onboarded');
      if (savedOnboarded === 'true') {
        setHasCompletedOnboarding(true);
      }
    }

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

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

  const handleResetToOnboarding = () => {
    localStorage.removeItem('snapan_has_onboarded');
    window.history.pushState({}, '', '/onboarding');
    setCurrentRoute('/onboarding');
    setHasCompletedOnboarding(false);
    setShowSplash(true);
  };

  return (
    <div className="relative min-h-screen bg-pure-white text-slate-ink overflow-x-hidden font-gt-standard">
      {/* Agentation Page Feedback Overlay */}
      {import.meta.env.DEV && <Agentation />}

      {/* Floating Dev Mode Control Button (Replay Onboarding / Splash) */}
      {import.meta.env.DEV && (
        <button
          onClick={handleResetToOnboarding}
          className="fixed top-3 right-3 z-[9999] flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-slate-900/90 hover:bg-slate-900 text-white text-[11px] font-bold shadow-xl border border-white/20 backdrop-blur-md active:scale-95 transition-all cursor-pointer select-none"
          title="Reset ke Splash & Onboarding (Dev Mode)"
        >
          <RotateCcw className="h-3.5 w-3.5 text-blue-400 animate-spin-slow" />
          <span>Dev: Reset Onboarding</span>
        </button>
      )}

      {/* Render Dedicated PWA Download Landing Page if route is /download */}
      {isDownloadRoute ? (
        <PwaLandingPage onProceedToWeb={navigateToWeb} />
      ) : showSplash ? (
        <SplashScreen onFinish={() => setShowSplash(false)} />
      ) : hasCompletedOnboarding && !isOnboardingRoute ? (
        selectedPost ? (
          <PostDetailPage
            post={selectedPost}
            onBack={() => setSelectedPost(null)}
          />
        ) : (
          <HomePage onSelectPost={(post) => setSelectedPost(post)} />
        )
      ) : (
        <OnboardingScreen onComplete={handleOnboardingComplete} />
      )}
    </div>
  );
}

export default App;
