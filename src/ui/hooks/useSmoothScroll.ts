import { useEffect } from 'react';
import Lenis from 'lenis';
import 'lenis/dist/lenis.css';

// Global Lenis singleton reference for imperative scroll control
export let lenisInstance: Lenis | null = null;

export function scrollToTop(immediate = false) {
  if (lenisInstance) {
    lenisInstance.scrollTo(0, { immediate, duration: immediate ? 0 : 0.8 });
  } else {
    window.scrollTo({ top: 0, left: 0, behavior: immediate ? 'instant' : 'smooth' });
  }
}

export function pauseSmoothScroll() {
  lenisInstance?.stop();
}

export function resumeSmoothScroll() {
  lenisInstance?.start();
}

export function useSmoothScroll() {
  useEffect(() => {
    // Mobile & Desktop Optimized Kinetic Physics Configuration
    const lenis = new Lenis({
      duration: 1.1,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)), // Apple-style exponential deceleration curve
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 0.95,
      touchMultiplier: 1.15, // Light and responsive touch momentum
      infinite: false,
      autoRaf: false,
    });

    lenisInstance = lenis;

    // RAF Loop (Zero Jitter 120 FPS Synchronization)
    let rafId: number;
    function raf(time: number) {
      lenis.raf(time);
      rafId = requestAnimationFrame(raf);
    }
    rafId = requestAnimationFrame(raf);

    return () => {
      cancelAnimationFrame(rafId);
      lenis.destroy();
      lenisInstance = null;
    };
  }, []);
}
