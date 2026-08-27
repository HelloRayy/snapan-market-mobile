import React, { useEffect, useRef, useState } from 'react';
import { createPortal } from 'react-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Check, X, AlertTriangle, Info } from 'lucide-react';
import { cn } from '@/utils/cn';
import { triggerHaptic } from '@/utils/haptics';

export type ToastType = 'success' | 'error' | 'failed' | 'warning' | 'info' | 'default';

export interface ToastNotificationProps {
  /** Text message to display inside the toast */
  message: string | null;
  /** Toast visual/status type (success, error, failed, warning, info) */
  type?: ToastType;
  /** Explicit open state if controlled externally (defaults to true if message is truthy) */
  isOpen?: boolean;
  /** Callback fired when toast is closed (either automatically or via user interaction) */
  onClose: () => void;
  /** Auto-dismiss duration in milliseconds. Set to 0 to disable auto-dismiss. Default: 2500ms */
  duration?: number;
  /** Optional custom styling classes */
  className?: string;
  /** Vertical placement */
  position?: 'bottom' | 'top';
  /** Optional custom icon override */
  icon?: React.ReactNode;
}

/**
 * Helper to auto-infer toast type if not explicitly provided
 */
function inferToastType(message: string, explicitType?: ToastType): 'success' | 'error' | 'warning' | 'info' {
  if (explicitType && explicitType !== 'default') {
    if (explicitType === 'failed') return 'error';
    return explicitType;
  }
  const lower = message.toLowerCase();
  if (
    lower.includes('berhasil') ||
    lower.includes('disimpan') ||
    lower.includes('diposting') ||
    lower.includes('ditambahkan') ||
    lower.includes('dipilih') ||
    lower.includes('diperbarui') ||
    lower.includes('terkirim') ||
    lower.includes('disalin') ||
    lower.includes('sukses')
  ) {
    return 'success';
  }
  if (
    lower.includes('gagal') ||
    lower.includes('error') ||
    lower.includes('dihapus') ||
    lower.includes('batal') ||
    lower.includes('ditolak') ||
    lower.includes('disenyapkan') ||
    lower.includes('disembunyikan')
  ) {
    return 'error';
  }
  if (
    lower.includes('peringatan') ||
    lower.includes('warning') ||
    lower.includes('perhatian') ||
    lower.includes('sudah ada')
  ) {
    return 'warning';
  }
  return 'info';
}

export const ToastNotification: React.FC<ToastNotificationProps> = ({
  message,
  type,
  isOpen = true,
  onClose,
  duration = 2500,
  className,
  position = 'bottom',
  icon,
}) => {
  const [mounted, setMounted] = useState(false);
  const isVisible = Boolean(message && isOpen);
  const onCloseRef = useRef(onClose);
  onCloseRef.current = onClose;

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (!isVisible || duration <= 0) return;

    const timer = setTimeout(() => {
      onCloseRef.current();
    }, duration);

    return () => clearTimeout(timer);
  }, [isVisible, message, duration]);
  useEffect(() => {
    if (!isVisible) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onCloseRef.current();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isVisible]);

  const handleDismiss = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('light');
    onClose();
  };

  const resolvedType = message ? inferToastType(message, type) : 'info';

  const positionClasses =
    position === 'top'
      ? 'fixed top-6 left-1/2 z-[99999]'
      : 'fixed bottom-20 sm:bottom-24 left-1/2 z-[99999]';

  const renderIcon = () => {
    if (icon) return icon;

    switch (resolvedType) {
      case 'success':
        return (
          <div className="w-5 h-5 rounded-full bg-emerald-500/12 text-emerald-600 flex items-center justify-center shrink-0">
            <Check className="w-3.5 h-3.5 stroke-[2.8]" />
          </div>
        );
      case 'error':
        return (
          <div className="w-5 h-5 rounded-full bg-rose-500/12 text-rose-600 flex items-center justify-center shrink-0">
            <X className="w-3.5 h-3.5 stroke-[2.8]" />
          </div>
        );
      case 'warning':
        return (
          <div className="w-5 h-5 rounded-full bg-amber-500/12 text-amber-600 flex items-center justify-center shrink-0">
            <AlertTriangle className="w-3.5 h-3.5 stroke-[2.4]" />
          </div>
        );
      case 'info':
      default:
        return (
          <div className="w-5 h-5 rounded-full bg-blue-500/12 text-blue-600 flex items-center justify-center shrink-0">
            <Info className="w-3.5 h-3.5 stroke-[2.4]" />
          </div>
        );
    }
  };

  if (!mounted || typeof document === 'undefined') return null;

  return createPortal(
    <AnimatePresence>
      {isVisible && message && (
        <motion.div
          role="status"
          aria-live="polite"
          aria-atomic="true"
          onClick={handleDismiss}
          style={{ willChange: 'transform, opacity' }}
          initial={{
            opacity: 0,
            y: position === 'top' ? -14 : 14,
            x: '-50%',
            scale: 0.94,
          }}
          animate={{
            opacity: 1,
            y: 0,
            x: '-50%',
            scale: 1,
            transition: {
              type: 'spring',
              damping: 25,
              stiffness: 420,
              mass: 0.4,
            },
          }}
          exit={{
            opacity: 0,
            y: position === 'top' ? -8 : 8,
            x: '-50%',
            scale: 0.95,
            transition: {
              duration: 0.1,
              ease: 'easeOut',
            },
          }}
          whileTap={{ scale: 0.96 }}
          className={cn(
            positionClasses,
            'flex items-center gap-2.5 px-3.5 py-2.5',
            'min-w-[240px] max-w-[calc(100vw-32px)] sm:max-w-[420px] w-auto',
            'bg-white/98 text-slate-800 border border-neutral-200/90 rounded-2xl',
            'shadow-[0_14px_34px_rgba(0,0,0,0.12),0_2px_8px_rgba(0,0,0,0.04)] ring-1 ring-black/[0.04]',
            'backdrop-blur-xl select-none pointer-events-auto cursor-pointer',
            className
          )}
        >
          {/* Action Status Icon (Success / Failed / Warning / Info) */}
          {renderIcon()}

          {/* Label Teks di Sisi Kanan (Single-line, high contrast, clean typography) */}
          <span className="text-[13px] sm:text-[13.5px] font-semibold text-slate-800 truncate pr-1 leading-tight tracking-tight">
            {message}
          </span>
        </motion.div>
      )}
    </AnimatePresence>,
    document.body
  );
};

export default ToastNotification;
