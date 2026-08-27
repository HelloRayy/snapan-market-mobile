import React, { useState, useEffect, useRef } from 'react';
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
  className?: string;
  containerRef?: React.RefObject<HTMLElement | null>;
}

interface MenuLevel {
  title: string;
  items: SubmenuDropdownItem[];
}

export const SubmenuDropdown: React.FC<SubmenuDropdownProps> = ({
  isOpen,
  onClose,
  items,
  align = 'right',
  className = '',
}) => {
  const dropdownRef = useRef<HTMLDivElement>(null);
  const [menuStack, setMenuStack] = useState<MenuLevel[]>([]);

  // Reset menu stack whenever dropdown opens or closes
  useEffect(() => {
    if (!isOpen) {
      setMenuStack([]);
    }
  }, [isOpen]);

  // Click outside and ESC key detection
  useEffect(() => {
    if (!isOpen) return;

    const handlePointerDown = (e: MouseEvent | TouchEvent | PointerEvent) => {
      const target = e.target as HTMLElement | null;
      if (!target) return;
      // If clicking inside the dropdown container or on the trigger element, let item/button handlers proceed
      if (
        (dropdownRef.current && dropdownRef.current.contains(target)) ||
        Boolean(target.closest?.('[data-submenu-trigger]'))
      ) {
        return;
      }
      onClose();
    };

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        if (menuStack.length > 0) {
          setMenuStack((prev) => prev.slice(0, -1));
        } else {
          onClose();
        }
      }
    };

    document.addEventListener('pointerdown', handlePointerDown, true);
    window.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener('pointerdown', handlePointerDown, true);
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose, menuStack.length]);

  const currentLevel = menuStack.length > 0 ? menuStack[menuStack.length - 1] : null;
  const currentItems = currentLevel ? currentLevel.items : items;

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          ref={dropdownRef}
          initial={{ opacity: 0, scale: 0.92, y: -4 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.92, y: -4 }}
          transition={{ type: 'spring', damping: 24, stiffness: 380 }}
          style={{
            transformOrigin: align === 'left' ? 'top left' : 'top right',
          }}
          onClick={(e) => e.stopPropagation()}
          className={`absolute top-full mt-1.5 ${
            align === 'left' ? 'left-0' : 'right-0'
          } z-[9999] bg-[#18181b]/95 text-white border border-[#27272a] rounded-2xl shadow-2xl backdrop-blur-xl min-w-[210px] max-w-[260px] p-1.5 select-none overflow-hidden ring-1 ring-white/10 ${className}`}
        >
          {/* Submenu Header with Back Button */}
          {currentLevel && (
            <div className="flex items-center gap-1 px-1 py-1 mb-1 border-b border-[#27272a]">
              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  triggerHaptic('light');
                  setMenuStack((prev) => prev.slice(0, -1));
                }}
                className="flex items-center gap-1.5 px-2 py-1 text-xs font-semibold text-neutral-300 hover:text-white rounded-lg hover:bg-white/10 active:bg-white/15 transition-colors w-full cursor-pointer"
              >
                <ChevronLeft className="w-3.5 h-3.5" />
                <span className="truncate">{currentLevel.title}</span>
              </button>
            </div>
          )}

          {/* Menu Items List with smooth animation */}
          <motion.div
            key={menuStack.length}
            initial={{ opacity: 0, x: menuStack.length > 0 ? 8 : -8 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.15, ease: 'easeOut' }}
            className="space-y-0.5"
          >
            {currentItems.map((item) => {
              const Icon = item.icon;
              return (
                <button
                  type="button"
                  key={item.id}
                  disabled={item.disabled}
                  onClick={(e) => {
                    e.stopPropagation();
                    if (item.disabled) return;
                    triggerHaptic('selection');

                    if (item.subItems && item.subItems.length > 0) {
                      setMenuStack((prev) => [
                        ...prev,
                        { title: item.subTitle || item.label, items: item.subItems! },
                      ]);
                    } else {
                      item.onClick?.(e);
                      onClose();
                    }
                  }}
                  className={`group flex items-center justify-between w-full px-3 py-2 text-[13px] font-medium rounded-xl transition-all duration-150 cursor-pointer ${
                    item.disabled
                      ? 'opacity-40 cursor-not-allowed pointer-events-none'
                      : item.danger
                      ? 'text-rose-400 hover:bg-rose-500/15 active:bg-rose-500/25 hover:text-rose-300'
                      : 'text-neutral-200 hover:text-white hover:bg-white/10 active:bg-white/15'
                  }`}
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    {Icon && (
                      <Icon
                        className={`w-4 h-4 shrink-0 transition-colors ${
                          item.danger
                            ? 'text-rose-400 group-hover:text-rose-300'
                            : 'text-neutral-400 group-hover:text-white'
                        }`}
                      />
                    )}
                    <span className="truncate">{item.label}</span>
                  </div>

                  <div className="flex items-center gap-1.5 shrink-0 ml-2">
                    {item.shortcut && (
                      <span className="text-[11px] text-neutral-400 font-mono tracking-wider">
                        {item.shortcut}
                      </span>
                    )}
                    {item.badge && (
                      <span className="text-[11px] px-1.5 py-0.5 rounded-md bg-white/10 text-neutral-300 font-medium">
                        {item.badge}
                      </span>
                    )}
                    {item.subItems && item.subItems.length > 0 && (
                      <ChevronRight className="w-3.5 h-3.5 text-neutral-400 group-hover:text-white transition-colors" />
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
