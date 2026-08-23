import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export type ActionModalVariant = 'primary' | 'destructive' | 'brand' | 'cancel' | 'default';

export interface ActionModalButton {
  label: string;
  onClick: () => void | Promise<void>;
  variant?: ActionModalVariant;
  disabled?: boolean;
}

export interface ConfirmActionModalProps {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  description?: string;
  actions: ActionModalButton[];
  closeOnBackdropClick?: boolean;
}

export const ConfirmActionModal: React.FC<ConfirmActionModalProps> = ({
  isOpen,
  onClose,
  title,
  description,
  actions,
  closeOnBackdropClick = true,
}) => {
  // Lock body scroll when modal is open and handle ESC key
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose();
      }
    };

    const originalOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    window.addEventListener('keydown', handleKeyDown);

    return () => {
      document.body.style.overflow = originalOverflow;
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose]);

  const getVariantStyles = (variant: ActionModalVariant = 'default') => {
    switch (variant) {
      case 'primary':
        return 'font-bold text-slate-900';
      case 'destructive':
        return 'font-bold text-[#ff3040]';
      case 'brand':
        return 'font-bold text-[#1d64ec]';
      case 'cancel':
      case 'default':
      default:
        return 'font-normal text-slate-700';
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-[70] flex items-center justify-center p-4 select-none font-gt-standard">
          {/* Backdrop with Soft Blur */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.15, ease: 'easeOut' }}
            onClick={closeOnBackdropClick ? onClose : undefined}
            className="fixed inset-0 bg-black/40 backdrop-blur-[2px]"
          />

          {/* Modal Container */}
          <motion.div
            initial={{ opacity: 0, scale: 0.94 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.94 }}
            transition={{ type: 'spring', stiffness: 450, damping: 30 }}
            className="relative w-full max-w-[280px] sm:max-w-[300px] bg-white rounded-[20px] border border-neutral-200/80 shadow-[0_20px_60px_rgba(0,0,0,0.18)] overflow-hidden flex flex-col text-center z-10"
            role="dialog"
            aria-modal="true"
            aria-labelledby="confirm-modal-title"
          >
            {/* Header: Title & Optional Description */}
            <div className={`px-4 ${description ? 'pt-4 pb-3.5 space-y-1' : 'py-5'}`}>
              <h2
                id="confirm-modal-title"
                className="text-[16px] font-bold text-slate-900 text-center leading-snug"
              >
                {title}
              </h2>
              {description && (
                <p className="text-[13px] text-neutral-500 text-center leading-normal px-1">
                  {description}
                </p>
              )}
            </div>

            {/* Stacked Segmented Action Rows */}
            <div className="flex flex-col border-t border-neutral-200/80 divide-y divide-neutral-200/80 w-full">
              {actions.map((action, idx) => {
                const variantClass = getVariantStyles(action.variant);
                return (
                  <button
                    key={`${action.label}-${idx}`}
                    type="button"
                    disabled={action.disabled}
                    onClick={action.onClick}
                    className={`h-[50px] w-full flex items-center justify-center text-center text-[14.5px] cursor-pointer transition-all duration-150 hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] disabled:opacity-40 disabled:cursor-not-allowed ${variantClass}`}
                  >
                    <span>{action.label}</span>
                  </button>
                );
              })}
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
