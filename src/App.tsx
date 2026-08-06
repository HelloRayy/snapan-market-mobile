import { useState, useEffect } from 'react';
import { Agentation } from 'agentation';
import { SplashScreen } from '@/ui/components/onboarding/SplashScreen';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';

export function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [currentRoute, setCurrentRoute] = useState<string>(window.location.pathname);

  // Sync route with window location
  useEffect(() => {
    const handlePopState = () => {
      setCurrentRoute(window.location.pathname);
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  // Check if URL is /download
  const isDownloadRoute = currentRoute === '/download' || window.location.hash === '#download';

  const navigateToWeb = () => {
    window.history.pushState({}, '', '/');
    setCurrentRoute('/');
  };

  return (
    <div className="relative min-h-screen bg-pure-white text-slate-ink overflow-x-hidden font-gt-standard">
      {/* Agentation Page Feedback Overlay */}
      {import.meta.env.DEV && <Agentation />}

      {/* Render Dedicated PWA Download Landing Page if route is /download */}
      {isDownloadRoute ? (
        <PwaLandingPage onProceedToWeb={navigateToWeb} />
      ) : showSplash ? (
        <SplashScreen onFinish={() => setShowSplash(false)} />
      ) : (
        <OnboardingScreen onComplete={() => setShowSplash(true)} />
      )}
    </div>
  );
}

export default App;
