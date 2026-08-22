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
    if (typeof window === 'undefined') return;

    // Detect if device supports physical touch
    const isTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

    // Mobile Touch & Desktop Wheel Kinetic Physics Configuration
    const lenis = new Lenis({
      autoRaf: true, // Fully managed internal RAF loop for 100% reliability
      duration: 1.1,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)), // Apple-style exponential ease
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1.0,
      // Touch-only features (Prevent locking mouse wheel on Desktop / Trackpads)
      syncTouch: isTouch,
      syncTouchLerp: 0.085,
      touchInertiaExponent: 1.6,
      touchMultiplier: 1.25,
      infinite: false,
      autoResize: true,
      prevent: (node) => {
        return !!(node instanceof HTMLElement && node.closest('[data-lenis-prevent]'));
      },
    });

    lenisInstance = lenis;

    return () => {
      lenis.destroy();
      lenisInstance = null;
    };
  }, []);
}
