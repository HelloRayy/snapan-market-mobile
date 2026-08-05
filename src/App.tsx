import { useState } from 'react';
import { Agentation } from 'agentation';
import { SplashScreen } from '@/ui/components/onboarding/SplashScreen';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';

export function App() {
  const [showSplash, setShowSplash] = useState(true);

  return (
    <div className="relative min-h-screen bg-pure-white text-slate-ink overflow-x-hidden font-gt-standard">
      {/* Agentation Page Feedback Overlay */}
      {import.meta.env.DEV && <Agentation />}

      {/* Pure Onboarding Flow */}
      {showSplash ? (
        <SplashScreen onFinish={() => setShowSplash(false)} />
      ) : (
        <OnboardingScreen onComplete={() => setShowSplash(true)} />
      )}
    </div>
  );
}

export default App;
