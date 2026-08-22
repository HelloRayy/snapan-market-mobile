/**
 * Native Web Haptic Vibration Feedback Manager (Taptic Engine / Android Haptics)
 * Zero dependency, 100% native hardware integration with safe capability fallbacks.
 */

export type HapticType = 'light' | 'medium' | 'heavy' | 'success' | 'warning' | 'error' | 'selection';

export function triggerHaptic(type: HapticType = 'light'): void {
  if (typeof window === 'undefined' || !('navigator' in window) || !('vibrate' in navigator)) {
    return;
  }

  try {
    switch (type) {
      case 'selection':
        navigator.vibrate(6);
        break;
      case 'light':
        navigator.vibrate(10);
        break;
      case 'medium':
        navigator.vibrate(20);
        break;
      case 'heavy':
        navigator.vibrate(35);
        break;
      case 'success':
        navigator.vibrate([12, 40, 20]);
        break;
      case 'warning':
        navigator.vibrate([25, 30, 25]);
        break;
      case 'error':
        navigator.vibrate([40, 50, 40, 50, 40]);
        break;
      default:
        navigator.vibrate(10);
    }
  } catch {
    // Graceful fallback for non-supported browsers
  }
}
