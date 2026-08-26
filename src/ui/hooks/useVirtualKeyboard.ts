import { useState, useEffect, useRef } from 'react';

/**
 * Checks whether an element is an active text input or editable field.
 */
export const isEditableElement = (el: Element | null): boolean => {
  if (!el) return false;
  const tag = el.tagName.toLowerCase();
  if (tag === 'input') {
    const type = (el as HTMLInputElement).type?.toLowerCase();
    return !['button', 'checkbox', 'color', 'file', 'hidden', 'image', 'radio', 'reset', 'submit'].includes(type);
  }
  return tag === 'textarea' || (el as HTMLElement).isContentEditable;
};

export interface VirtualKeyboardState {
  isKeyboardOpen: boolean;
  isInputActive: boolean;
  isViewportResized: boolean;
}

/**
 * Universal hook for detecting virtual keyboard and active text inputs on mobile & desktop.
 */
export function useVirtualKeyboard(): VirtualKeyboardState {
  const [isInputActive, setIsInputActive] = useState<boolean>(() => {
    if (typeof document === 'undefined') return false;
    return isEditableElement(document.activeElement);
  });
  const [isViewportResized, setIsViewportResized] = useState<boolean>(false);
  const baselineHeightRef = useRef<number>(
    typeof window !== 'undefined' ? Math.max(window.innerHeight, window.screen?.height || 0) : 0
  );

  useEffect(() => {
    if (typeof window === 'undefined') return;

    // 1. Focus-based input detection
    const handleFocusIn = (e: FocusEvent) => {
      if (isEditableElement(e.target as Element)) {
        setIsInputActive(true);
      }
    };

    const handleFocusOut = () => {
      // Delay check so document.activeElement has transitioned to the next focused target
      setTimeout(() => {
        if (!isEditableElement(document.activeElement)) {
          setIsInputActive(false);
        }
      }, 50);
    };

    document.addEventListener('focusin', handleFocusIn);
    document.addEventListener('focusout', handleFocusOut);

    // 2. Viewport resize detection
    const handleViewportChange = () => {
      const currentHeight = window.visualViewport?.height ?? window.innerHeight;
      const baseline = baselineHeightRef.current;
      const isShrunk = baseline > 0 && currentHeight < baseline * 0.78;
      setIsViewportResized(isShrunk);
    };

    if (window.visualViewport) {
      window.visualViewport.addEventListener('resize', handleViewportChange);
      window.visualViewport.addEventListener('scroll', handleViewportChange);
    }
    window.addEventListener('resize', handleViewportChange);

    return () => {
      document.removeEventListener('focusin', handleFocusIn);
      document.removeEventListener('focusout', handleFocusOut);
      if (window.visualViewport) {
        window.visualViewport.removeEventListener('resize', handleViewportChange);
        window.visualViewport.removeEventListener('scroll', handleViewportChange);
      }
      window.removeEventListener('resize', handleViewportChange);
    };
  }, []);

  const isKeyboardOpen = isInputActive || isViewportResized;

  return {
    isKeyboardOpen,
    isInputActive,
    isViewportResized,
  };
}
