import React, { useRef, useImperativeHandle, forwardRef, useState } from 'react';
import { Search, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { triggerHaptic } from '@/utils/haptics';

export interface MobileSearchBarProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  autoFocus?: boolean;
  onFocus?: () => void;
  onBlur?: () => void;
  onCancel?: () => void;
  onClear?: () => void;
  onKeyDown?: (e: React.KeyboardEvent<HTMLInputElement>) => void;
  leftIcon?: React.ReactNode;
  rightAction?: React.ReactNode;
  showCancelButton?: boolean;
  cancelText?: string;
  variant?: 'compact' | 'rounded'; // compact (h-38 DirectMessages) or rounded (h-44 SearchPage)
  className?: string;
}

export interface MobileSearchBarRef {
  focus: () => void;
  blur: () => void;
  input: HTMLInputElement | null;
}

export const MobileSearchBar = forwardRef<MobileSearchBarRef, MobileSearchBarProps>(
  (
    {
      value,
      onChange,
      placeholder = 'Cari...',
      autoFocus = false,
      onFocus,
      onBlur,
      onCancel,
      onClear,
      onKeyDown,
      leftIcon,
      rightAction,
      showCancelButton = true,
      cancelText = 'Batal',
      variant = 'compact',
      className = '',
    },
    ref
  ) => {
    const internalInputRef = useRef<HTMLInputElement>(null);
    const [isInternalFocused, setIsInternalFocused] = useState(false);

    useImperativeHandle(ref, () => ({
      focus: () => internalInputRef.current?.focus(),
      blur: () => internalInputRef.current?.blur(),
      get input() {
        return internalInputRef.current;
      },
    }));

    const hasQuery = value.length > 0;
    const isShowingCancel = showCancelButton && (isInternalFocused || hasQuery);

    const handleFocus = () => {
      setIsInternalFocused(true);
      onFocus?.();
    };

    const handleBlur = () => {
      if (!hasQuery) {
        setIsInternalFocused(false);
      }
      onBlur?.();
    };

    const handleClear = () => {
      triggerHaptic('selection');
      onChange('');
      onClear?.();
      internalInputRef.current?.focus();
    };

    const handleCancel = () => {
      triggerHaptic('selection');
      onChange('');
      setIsInternalFocused(false);
      internalInputRef.current?.blur();
      onCancel?.();
    };

    const isCompact = variant === 'compact';

    return (
      <div className={`flex items-center gap-2 ${className}`}>
        {/* Search Capsule */}
        <div
          className={`flex-1 flex items-center gap-2.5 leading-snug transition-all ${
            isCompact
              ? `h-[38px] px-3.5 rounded-full border backdrop-blur-md ${
                  isInternalFocused
                    ? 'bg-neutral-100 border-neutral-300'
                    : 'bg-neutral-100/90 hover:bg-neutral-200/60 border-neutral-200/70'
                }`
              : `h-11 pl-2.5 pr-3 bg-white rounded-[22px] border border-neutral-200 shadow-2xs focus-within:border-slate-400 focus-within:shadow-xs`
          } text-slate-900`}
        >
          {/* Left Icon (Search or Back Button) */}
          {leftIcon ? (
            leftIcon
          ) : (
            <Search
              className={`w-4 h-4 stroke-[2.2] shrink-0 transition-colors duration-150 ${
                isInternalFocused ? 'text-slate-700' : 'text-neutral-400'
              }`}
            />
          )}

          {/* Search Input Field */}
          <input
            ref={internalInputRef}
            type="text"
            autoFocus={autoFocus}
            value={value}
            onChange={(e) => onChange(e.target.value)}
            onFocus={handleFocus}
            onBlur={handleBlur}
            onKeyDown={onKeyDown}
            placeholder={placeholder}
            className={`w-full bg-transparent text-slate-900 placeholder:text-neutral-400 focus:outline-hidden py-0.5 leading-snug ${
              isCompact ? 'text-[14.5px]' : 'text-[15px] font-normal h-full px-1'
            }`}
          />

          {/* Clear Button ('X') or Right Action */}
          <AnimatePresence>
            {hasQuery ? (
              <motion.button
                key="clear-search-btn"
                type="button"
                initial={{ scale: 0.8, opacity: 0 }}
                animate={{ scale: 1, opacity: 1 }}
                exit={{ scale: 0.8, opacity: 0 }}
                transition={{ duration: 0.15 }}
                onMouseDown={(e) => e.preventDefault()}
                onClick={handleClear}
                className="w-4.5 h-4.5 rounded-full bg-slate-900 hover:bg-black text-white flex items-center justify-center cursor-pointer active:scale-90 shrink-0 transition-colors shadow-2xs"
                aria-label="Hapus pencarian"
              >
                <X className="w-2.5 h-2.5 stroke-[3] text-white" />
              </motion.button>
            ) : (
              rightAction && <div className="shrink-0">{rightAction}</div>
            )}
          </AnimatePresence>
        </div>

        {/* Animated "Batal" Cancel Button with Spring Physics */}
        <AnimatePresence>
          {isShowingCancel && (
            <motion.button
              key="cancel-search-btn"
              type="button"
              initial={{ opacity: 0, width: 0, x: 12 }}
              animate={{ opacity: 1, width: 'auto', x: 0 }}
              exit={{ opacity: 0, width: 0, x: 12 }}
              transition={{ type: 'spring', stiffness: 500, damping: 35 }}
              onMouseDown={(e) => e.preventDefault()}
              onClick={handleCancel}
              className="text-[14px] font-semibold text-[#1d64ec] hover:text-[#154ec1] active:opacity-70 whitespace-nowrap pl-1 pr-0.5 cursor-pointer select-none overflow-hidden shrink-0"
            >
              {cancelText}
            </motion.button>
          )}
        </AnimatePresence>
      </div>
    );
  }
);

MobileSearchBar.displayName = 'MobileSearchBar';
