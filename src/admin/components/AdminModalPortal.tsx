import { useEffect, type ReactNode } from 'react';
import { createPortal } from 'react-dom';

interface AdminModalPortalProps {
  isOpen: boolean;
  onClose?: () => void;
  children: ReactNode;
  zIndex?: number;
}

export function AdminModalPortal({
  isOpen,
  onClose,
  children,
  zIndex = 100000,
}: AdminModalPortalProps) {
  useEffect(() => {
    if (!isOpen) return;

    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    document.body.classList.add('admin-has-overlay');

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && onClose) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);

    return () => {
      document.body.style.overflow = prevOverflow;
      document.body.classList.remove('admin-has-overlay');
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return createPortal(
    <div
      className="admin-modal-backdrop"
      style={{
        position: 'fixed',
        inset: 0,
        zIndex,
        background: 'rgba(15, 23, 42, 0.65)',
        backdropFilter: 'blur(3px)',
        WebkitBackdropFilter: 'blur(3px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '16px',
      }}
      onClick={onClose}
    >
      <div onClick={(e) => e.stopPropagation()}>{children}</div>
    </div>,
    document.body
  );
}
