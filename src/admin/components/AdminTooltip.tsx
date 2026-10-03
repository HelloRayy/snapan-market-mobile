import React, { useState, useRef, useEffect, useCallback } from 'react';
import { createPortal } from 'react-dom';

export type TooltipPlacement = 'top' | 'bottom' | 'left' | 'right';
export type TooltipVariant = 'default' | 'danger' | 'warning' | 'success';

interface AdminTooltipProps {
  content: string;
  children: React.ReactElement;
  placement?: TooltipPlacement;
  variant?: TooltipVariant;
  delay?: number;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * AdminTooltip
 * Tooltip mikro interaktif berkinerja tinggi:
 * - Menggunakan React Portal (document.body) agar TIDAK PERNAH terpotong overflow table / tertutup stacking context z-index.
 * - TIDAK MENGUBAH layout parent DOM (tidak ada wrapping div baru jika children sudah berupa elemen, atau wrapping div dengan display natural).
 * - UI Background Putih bersih (#ffffff) dengan border tipis elegan (#e2e8f0), shadow lembut, dan teks gelap (#1e293b).
 * - Animasi scale & fade in cepat, micro-delay yang nyaman.
 */
export function AdminTooltip({
  content,
  children,
  placement = 'top',
  delay = 100,
}: AdminTooltipProps) {
  const [isVisible, setIsVisible] = useState(false);
  const [coords, setCoords] = useState<{ top: number; left: number } | null>(null);
  const triggerRef = useRef<HTMLElement | null>(null);
  const timerRef = useRef<any>(null);

  const updatePosition = useCallback(() => {
    if (!triggerRef.current) return;
    const rect = triggerRef.current.getBoundingClientRect();

    let top = 0;
    let left = 0;
    const offset = 7; // Jarak tooltip dari trigger

    if (placement === 'top') {
      top = rect.top - offset;
      left = rect.left + rect.width / 2;
    } else if (placement === 'bottom') {
      top = rect.bottom + offset;
      left = rect.left + rect.width / 2;
    } else if (placement === 'left') {
      top = rect.top + rect.height / 2;
      left = rect.left - offset;
    } else if (placement === 'right') {
      top = rect.top + rect.height / 2;
      left = rect.right + offset;
    }

    setCoords({ top, left });
  }, [placement]);

  const showTooltip = useCallback(() => {
    if (!content) return;
    clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => {
      updatePosition();
      setIsVisible(true);
    }, delay);
  }, [content, delay, updatePosition]);

  const hideTooltip = useCallback(() => {
    clearTimeout(timerRef.current);
    setIsVisible(false);
  }, []);

  // Update posisi jika window scroll atau resize ketika tooltip aktif
  useEffect(() => {
    if (!isVisible) return;
    const handleScrollOrResize = () => {
      updatePosition();
    };
    window.addEventListener('scroll', handleScrollOrResize, true);
    window.addEventListener('resize', handleScrollOrResize);
    return () => {
      window.removeEventListener('scroll', handleScrollOrResize, true);
      window.removeEventListener('resize', handleScrollOrResize);
    };
  }, [isVisible, updatePosition]);

  useEffect(() => {
    return () => clearTimeout(timerRef.current);
  }, []);

  // Styling tooltip: UI White dengan border tipis dan subtle elevation shadow
  const bgColor = '#ffffff';
  const textColor = '#1e293b';
  const borderColor = '#e2e8f0';

  // Posisi transform berdasarkan placement
  let transformValue = '';
  let arrowStyles: React.CSSProperties = {};
  let arrowBorderStyles: React.CSSProperties = {};

  if (placement === 'top') {
    transformValue = `translate(-50%, -100%) scale(${isVisible ? 1 : 0.96})`;
    arrowStyles = {
      top: '100%',
      left: '50%',
      marginLeft: '-4px',
      borderWidth: '4px 4px 0 4px',
      borderColor: `${bgColor} transparent transparent transparent`,
    };
    arrowBorderStyles = {
      top: '100%',
      left: '50%',
      marginLeft: '-5px',
      borderWidth: '5px 5px 0 5px',
      borderColor: `${borderColor} transparent transparent transparent`,
    };
  } else if (placement === 'bottom') {
    transformValue = `translate(-50%, 0) scale(${isVisible ? 1 : 0.96})`;
    arrowStyles = {
      bottom: '100%',
      left: '50%',
      marginLeft: '-4px',
      borderWidth: '0 4px 4px 4px',
      borderColor: `transparent transparent ${bgColor} transparent`,
    };
    arrowBorderStyles = {
      bottom: '100%',
      left: '50%',
      marginLeft: '-5px',
      borderWidth: '0 5px 5px 5px',
      borderColor: `transparent transparent ${borderColor} transparent`,
    };
  } else if (placement === 'left') {
    transformValue = `translate(-100%, -50%) scale(${isVisible ? 1 : 0.96})`;
    arrowStyles = {
      left: '100%',
      top: '50%',
      marginTop: '-4px',
      borderWidth: '4px 0 4px 4px',
      borderColor: `transparent transparent transparent ${bgColor}`,
    };
    arrowBorderStyles = {
      left: '100%',
      top: '50%',
      marginTop: '-5px',
      borderWidth: '5px 0 5px 5px',
      borderColor: `transparent transparent transparent ${borderColor}`,
    };
  } else if (placement === 'right') {
    transformValue = `translate(0, -50%) scale(${isVisible ? 1 : 0.96})`;
    arrowStyles = {
      right: '100%',
      top: '50%',
      marginTop: '-4px',
      borderWidth: '4px 4px 4px 0',
      borderColor: `transparent ${bgColor} transparent transparent`,
    };
    arrowBorderStyles = {
      right: '100%',
      top: '50%',
      marginTop: '-5px',
      borderWidth: '5px 5px 5px 0',
      borderColor: `transparent ${borderColor} transparent transparent`,
    };
  }

  // Clone single child to attach event handlers and ref
  const triggerElement = React.cloneElement(children, {
    ref: (node: HTMLElement | null) => {
      triggerRef.current = node;
      // Handle ref forwarding jika child sudah memiliki ref
      const { ref } = children as any;
      if (typeof ref === 'function') {
        ref(node);
      } else if (ref && typeof ref === 'object') {
        ref.current = node;
      }
    },
    onMouseEnter: (e: React.MouseEvent) => {
      children.props.onMouseEnter?.(e);
      showTooltip();
    },
    onMouseLeave: (e: React.MouseEvent) => {
      children.props.onMouseLeave?.(e);
      hideTooltip();
    },
    onFocus: (e: React.FocusEvent) => {
      children.props.onFocus?.(e);
      showTooltip();
    },
    onBlur: (e: React.FocusEvent) => {
      children.props.onBlur?.(e);
      hideTooltip();
    },
  });

  return (
    <>
      {triggerElement}

      {isVisible &&
        coords &&
        typeof document !== 'undefined' &&
        createPortal(
          <div
            role="tooltip"
            style={{
              position: 'fixed',
              top: coords.top,
              left: coords.left,
              transform: transformValue,
              transformOrigin:
                placement === 'top'
                  ? 'bottom center'
                  : placement === 'bottom'
                  ? 'top center'
                  : placement === 'left'
                  ? 'center right'
                  : 'center left',
              zIndex: 999999, // Sangat tinggi agar selalu di atas tabel & modal
              pointerEvents: 'none',
              whiteSpace: 'nowrap',
              backgroundColor: bgColor,
              color: textColor,
              fontSize: '11.5px',
              fontWeight: 500,
              lineHeight: '1.2',
              letterSpacing: '0.01em',
              padding: '5px 9px',
              borderRadius: '6px',
              boxShadow: '0 4px 14px rgba(15, 23, 42, 0.08), 0 1px 3px rgba(15, 23, 42, 0.06)',
              border: `1px solid ${borderColor}`,
              opacity: isVisible ? 1 : 0,
              transition:
                'opacity 120ms cubic-bezier(0.16, 1, 0.3, 1), transform 120ms cubic-bezier(0.16, 1, 0.3, 1)',
            }}
          >
            {content}
            {/* Arrow Border (outer) */}
            <div
              style={{
                position: 'absolute',
                width: 0,
                height: 0,
                borderStyle: 'solid',
                zIndex: 1,
                ...arrowBorderStyles,
              }}
            />
            {/* Arrow Face (inner) */}
            <div
              style={{
                position: 'absolute',
                width: 0,
                height: 0,
                borderStyle: 'solid',
                zIndex: 2,
                ...arrowStyles,
              }}
            />
          </div>,
          document.body
        )}
    </>
  );
}
