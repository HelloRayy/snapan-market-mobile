// Pure Native Smooth Scroll Manager (Zero JS Overhead, 100% Native 120 FPS Compositor)

export function scrollToTop(immediate = false) {
  if (typeof window !== 'undefined') {
    window.scrollTo({ top: 0, left: 0, behavior: immediate ? 'instant' : 'smooth' });
  }
}

export function pauseSmoothScroll() {
  // No-op in pure native scroll
}

export function resumeSmoothScroll() {
  // No-op in pure native scroll
}

export function useSmoothScroll() {
  // Pure native scrolling active on GPU compositor thread
}
