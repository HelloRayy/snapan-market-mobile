import React, { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight, ChevronLeft } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

export interface SubmenuDropdownItem {
  id: string;
  label: string;
  icon?: React.ComponentType<{ className?: string }>;
  shortcut?: string;
  badge?: string | number;
  danger?: boolean;
  disabled?: boolean;
  onClick?: (e: React.MouseEvent) => void;
  subItems?: SubmenuDropdownItem[];
  subTitle?: string;
}

export interface SubmenuDropdownProps {
  isOpen: boolean;
  onClose: () => void;
  items: SubmenuDropdownItem[];
  align?: 'left' | 'right';
  placement?: 'auto' | 'top' | 'bottom';
  className?: string;
  triggerRef?: React.RefObject<HTMLElement | null>;
  menuId?: string;
  triggerId?: string;
}

interface MenuLevel {
  title: string;
  items: SubmenuDropdownItem[];
}

export const SubmenuDropdownComponent: React.FC<SubmenuDropdownProps> = ({
  isOpen,
  onClose,
  items,
  align = 'right',
  placement = 'auto',
  className = '',
  triggerRef,
  menuId,
  triggerId,
}) => {
  const dropdownRef = useRef<HTMLDivElement>(null);
  const itemsContainerRef = useRef<HTMLDivElement>(null);
  const [menuStack, setMenuStack] = useState<MenuLevel[]>([]);
  const [focusedIndex, setFocusedIndex] = useState<number>(-1);
  const [isFlippedTop, setIsFlippedTop] = useState<boolean>(placement === 'top');

  // Check prefers-reduced-motion
  const prefersReducedMotion = useMemo(() => {
    if (typeof window === 'undefined') return false;
    return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }, []);

  // Active items for current navigation depth
  const currentLevel = menuStack.length > 0 ? menuStack[menuStack.length - 1] : null;
  const currentItems = useMemo(
    () => (currentLevel ? currentLevel.items : items),
    [currentLevel, items]
  );

  // Enabled items for keyboard focus management
  const enabledIndices = useMemo(() => {
    return currentItems
      .map((item, idx) => (item.disabled ? -1 : idx))
      .filter((idx) => idx !== -1);
  }, [currentItems]);

  // Reset menu stack and focus whenever dropdown opens or closes
  useEffect(() => {
    if (!isOpen) {
      setMenuStack([]);
      setFocusedIndex(-1);
    } else {
      setFocusedIndex(enabledIndices.length > 0 ? enabledIndices[0] : -1);

      // Smart viewport boundary detection
      if (placement === 'auto' && dropdownRef.current) {
        const rect = dropdownRef.current.getBoundingClientRect();
        const viewportHeight = window.innerHeight || document.documentElement.clientHeight;
        // If bottom extends below viewport with a 16px safety margin, flip to top
        if (rect.bottom > viewportHeight - 16 && rect.top > rect.height + 16) {
          setIsFlippedTop(true);
        } else {
          setIsFlippedTop(false);
        }
      } else {
        setIsFlippedTop(placement === 'top');
      }
    }
  }, [isOpen, placement, enabledIndices]);

  // Focus the item when focusedIndex changes
  useEffect(() => {
    if (!isOpen || focusedIndex === -1 || !itemsContainerRef.current) return;
    const buttons = itemsContainerRef.current.querySelectorAll<HTMLButtonElement>('button[role="menuitem"]');
    if (buttons[focusedIndex]) {
      buttons[focusedIndex].focus();
    }
  }, [focusedIndex, isOpen, menuStack.length]);

  // Go back one level in submenu stack
  const handleGoBack = useCallback(() => {
    triggerHaptic('light');
    setMenuStack((prev) => prev.slice(0, -1));
    setFocusedIndex(0);
  }, []);

  // Click outside and ESC key detection
  useEffect(() => {
    if (!isOpen) return;

    const handlePointerDown = (e: MouseEvent | TouchEvent | PointerEvent) => {
      const target = e.target as HTMLElement | null;
      if (!target) return;

      // Ignore if clicking inside dropdown or on trigger element
      if (
        (dropdownRef.current && dropdownRef.current.contains(target)) ||
        (triggerRef?.current && triggerRef.current.contains(target)) ||
        Boolean(target.closest?.('[data-submenu-trigger]'))
      ) {
        return;
      }
      onClose();
    };

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        if (menuStack.length > 0) {
          handleGoBack();
        } else {
          onClose();
        }
        return;
      }

      // Keyboard navigation within menu
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        setFocusedIndex((prev) => {
          if (enabledIndices.length === 0) return -1;
          const currentPos = enabledIndices.indexOf(prev);
          const nextPos = (currentPos + 1) % enabledIndices.length;
          return enabledIndices[nextPos];
        });
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        setFocusedIndex((prev) => {
          if (enabledIndices.length === 0) return -1;
          const currentPos = enabledIndices.indexOf(prev);
          const prevPos = currentPos <= 0 ? enabledIndices.length - 1 : currentPos - 1;
          return enabledIndices[prevPos];
        });
      } else if (e.key === 'Home') {
        e.preventDefault();
        if (enabledIndices.length > 0) setFocusedIndex(enabledIndices[0]);
      } else if (e.key === 'End') {
        e.preventDefault();
        if (enabledIndices.length > 0) setFocusedIndex(enabledIndices[enabledIndices.length - 1]);
      } else if (e.key === 'ArrowRight') {
        // Enter submenu if current item has subItems
        if (focusedIndex >= 0 && currentItems[focusedIndex]?.subItems?.length) {
          e.preventDefault();
          const targetItem = currentItems[focusedIndex];
          setMenuStack((prev) => [
            ...prev,
            { title: targetItem.subTitle || targetItem.label, items: targetItem.subItems! },
          ]);
          setFocusedIndex(0);
        }
      } else if (e.key === 'ArrowLeft') {
        // Go back if in nested submenu
        if (menuStack.length > 0) {
          e.preventDefault();
          handleGoBack();
        }
      }
    };

    document.addEventListener('pointerdown', handlePointerDown, true);
    window.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener('pointerdown', handlePointerDown, true);
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose, menuStack.length, focusedIndex, currentItems, enabledIndices, handleGoBack, triggerRef]);

  // Motion animation presets
  const motionProps = useMemo(() => {
    if (prefersReducedMotion) {
      return {
        initial: { opacity: 0 },
        animate: { opacity: 1 },
        exit: { opacity: 0 },
        transition: { duration: 0.1 },
      };
    }
    const originY = isFlippedTop ? 'bottom' : 'top';
    const originX = align === 'left' ? 'left' : 'right';
    return {
      initial: { opacity: 0, scale: 0.94, y: isFlippedTop ? 4 : -4 },
      animate: { opacity: 1, scale: 1, y: 0 },
      exit: { opacity: 0, scale: 0.94, y: isFlippedTop ? 4 : -4 },
      transition: { type: 'spring' as const, damping: 26, stiffness: 420 },
      style: { transformOrigin: `${originY} ${originX}` },
    };
  }, [prefersReducedMotion, isFlippedTop, align]);

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          ref={dropdownRef}
          id={menuId}
          role="menu"
          aria-orientation="vertical"
          aria-labelledby={triggerId}
          tabIndex={-1}
          {...motionProps}
          onClick={(e) => e.stopPropagation()}
          className={`absolute ${
            isFlippedTop ? 'bottom-full mb-1.5' : 'top-full mt-1.5'
          } ${
            align === 'left' ? 'left-0' : 'right-0'
          } z-[9999] bg-white/98 text-slate-900 border border-neutral-200/90 rounded-2xl shadow-[0_14px_36px_rgba(0,0,0,0.12),0_2px_8px_rgba(0,0,0,0.04)] backdrop-blur-xl min-w-[210px] max-w-[260px] w-max p-1.5 select-none overflow-hidden ring-1 ring-black/[0.04] transform-gpu will-change-transform ${className}`}
        >
          {/* Submenu Header with Back Button */}
          {currentLevel && (
            <div className="flex items-center gap-1 px-1 py-1 mb-1 border-b border-neutral-100">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  handleGoBack();
                }}
                className="flex items-center gap-1.5 px-2.5 py-2 text-xs font-semibold text-slate-700 hover:text-slate-900 rounded-xl hover:bg-neutral-100 active:bg-neutral-200/70 transition-colors w-full cursor-pointer focus-visible:outline-none"
                aria-label={`Kembali dari ${currentLevel.title}`}
              >
                <ChevronLeft className="w-3.5 h-3.5 text-slate-600 shrink-0" />
                <span className="truncate">{currentLevel.title}</span>
              </button>
            </div>
          )}

          {/* Menu Items List with smooth hardware-accelerated animation */}
          <motion.div
            ref={itemsContainerRef}
            key={menuStack.length}
            initial={prefersReducedMotion ? undefined : { opacity: 0, x: menuStack.length > 0 ? 8 : -8 }}
            animate={prefersReducedMotion ? undefined : { opacity: 1, x: 0 }}
            transition={{ duration: 0.14, ease: 'easeOut' }}
            className="space-y-0.5"
          >
            {currentItems.map((item, idx) => {
              const Icon = item.icon;
              const isFocused = focusedIndex === idx;

              return (
                <button
                  type="button"
                  key={item.id}
                  role="menuitem"
                  disabled={item.disabled}
                  aria-disabled={item.disabled}
                  tabIndex={isFocused ? 0 : -1}
                  onMouseEnter={() => {
                    if (!item.disabled) setFocusedIndex(idx);
                  }}
                  onClick={(e) => {
                    e.stopPropagation();
                    if (item.disabled) return;
                    triggerHaptic('selection');

                    if (item.subItems && item.subItems.length > 0) {
                      setMenuStack((prev) => [
                        ...prev,
                        { title: item.subTitle || item.label, items: item.subItems! },
                      ]);
                      setFocusedIndex(0);
                    } else {
                      item.onClick?.(e);
                      onClose();
                    }
                  }}
                  className={`group flex items-center justify-between w-full px-3 py-2 min-h-[40px] text-[13.5px] font-medium rounded-xl transition-all duration-150 cursor-pointer active:scale-[0.98] ${
                    item.disabled
                      ? 'opacity-40 cursor-not-allowed pointer-events-none text-slate-400'
                      : item.danger
                      ? `text-rose-600 hover:bg-rose-50 active:bg-rose-100 hover:text-rose-700 ${
                          isFocused ? 'bg-rose-50 text-rose-700' : ''
                        }`
                      : `text-slate-800 hover:text-slate-900 hover:bg-neutral-100 active:bg-neutral-200/80 ${
                          isFocused ? 'bg-neutral-100 text-slate-900' : ''
                        }`
                  } focus-visible:outline-none`}
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    {Icon && (
                      <Icon
                        className={`w-4 h-4 shrink-0 transition-colors ${
                          item.danger
                            ? 'text-rose-600 group-hover:text-rose-700'
                            : 'text-slate-500 group-hover:text-slate-800'
                        }`}
                      />
                    )}
                    <span className="truncate">{item.label}</span>
                  </div>

                  <div className="flex items-center gap-1.5 shrink-0 ml-2">
                    {item.shortcut && (
                      <span className="text-[11px] text-slate-500 font-mono tracking-wider">
                        {item.shortcut}
                      </span>
                    )}
                    {item.badge && (
                      <span className="text-[11px] px-1.5 py-0.5 rounded-md bg-neutral-100 text-slate-600 font-medium">
                        {item.badge}
                      </span>
                    )}
                    {item.subItems && item.subItems.length > 0 && (
                      <ChevronRight className="w-3.5 h-3.5 text-slate-400 group-hover:text-slate-700 transition-colors" />
                    )}
                  </div>
                </button>
              );
            })}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export const SubmenuDropdown = React.memo(SubmenuDropdownComponent);
SubmenuDropdown.displayName = 'SubmenuDropdown';
