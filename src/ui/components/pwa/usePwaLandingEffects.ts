import { useEffect, RefObject } from 'react';
import { triggerHaptic } from '@/utils/haptics';

interface UsePwaLandingEffectsOptions {
  containerRef: RefObject<HTMLDivElement | null>;
  isMobile: boolean;
  onProceedToWeb?: () => void;
  onOpenInstallModal: () => void;
}

export function usePwaLandingEffects({
  containerRef,
  isMobile,
  onProceedToWeb,
  onOpenInstallModal,
}: UsePwaLandingEffectsOptions) {
  // 1. Viewport Entrance Motion System (IntersectionObserver + Scroll Fallback)
  useEffect(() => {
    const root = containerRef.current;
    if (!root) return;

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return;
    }

    const targetElements = root.querySelectorAll<HTMLElement>(
      'section, .framer-1c5m59g > div, .django-marquee-wrapper, .framer-14dz49g, .framer-p5xoen, footer, .framer-1fqlk99, .framer-1yxsbyq'
    );

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('pop-in-view');
            observer.unobserve(entry.target);
          }
        });
      },
      {
        root: null,
        rootMargin: '0px 0px -100px 0px',
        threshold: 0.15,
      }
    );

    const handleScrollCheck = () => {
      const triggerBottom = window.innerHeight * 0.85;
      targetElements.forEach((el) => {
        const rect = el.getBoundingClientRect();
        if (rect.top < triggerBottom) {
          el.classList.add('pop-in-view');
        }
      });
    };

    targetElements.forEach((el) => {
      const rect = el.getBoundingClientRect();
      if (rect.top < window.innerHeight * 0.92) {
        el.classList.add('pop-reveal', 'pop-in-view');
      } else {
        el.classList.add('pop-reveal');
        observer.observe(el);
      }
    });

    window.addEventListener('scroll', handleScrollCheck, { passive: true });
    setTimeout(handleScrollCheck, 120);

    return () => {
      observer.disconnect();
      window.removeEventListener('scroll', handleScrollCheck);
    };
  }, [isMobile, containerRef]);

  // 2. Real-time Username Input Validation & Warn Alert
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const inputs = container.querySelectorAll<HTMLInputElement>('input[name="username"]');

    inputs.forEach((input) => {
      const parentRow = input.closest('[data-framer-name="Buttons"], .framer-12tlorp, .framer-j6nqnh') as HTMLElement | null;
      let warnBadge: HTMLElement | null = null;

      if (parentRow) {
        parentRow.style.position = 'relative';
        warnBadge = parentRow.querySelector('.username-warn-badge') as HTMLElement | null;
        if (!warnBadge) {
          warnBadge = document.createElement('div');
          warnBadge.className = 'username-warn-badge';
          warnBadge.style.cssText = `
            display: none;
            position: absolute;
            top: -42px;
            bottom: auto;
            left: 50%;
            transform: translateX(-50%);
            background: #fff1f2;
            border: 1px solid #fecdd3;
            color: #e11d48;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 9999px;
            box-shadow: 0 6px 18px rgba(225, 29, 72, 0.10);
            white-space: nowrap;
            z-index: 50;
            align-items: center;
            gap: 6px;
            pointer-events: none;
            animation: popBadgeEnterTop 0.2s cubic-bezier(0.16, 1, 0.3, 1) both;
          `;
          warnBadge.innerHTML = `
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <span>Hanya huruf kecil tanpa kapital, spasi, atau simbol</span>
          `;
          parentRow.appendChild(warnBadge);
        }
      }

      const capsule = input.closest('.framer-1oduyj0, .framer-1wlgcwd, .framer-7j981h') as HTMLElement | null;
      const statusBadge = capsule ? (capsule.querySelector('div:first-child') as HTMLElement | null) : null;
      if (statusBadge) {
        statusBadge.style.transition = 'all 0.25s cubic-bezier(0.16, 1, 0.3, 1)';
      }

      const inputWrapper = input.parentElement;
      if (inputWrapper) {
        inputWrapper.style.position = 'relative';
      }
      let availableBadge = inputWrapper ? (inputWrapper.querySelector('.username-available-tag') as HTMLElement | null) : null;
      if (inputWrapper && !availableBadge) {
        availableBadge = document.createElement('span');
        availableBadge.className = 'username-available-tag';
        availableBadge.textContent = 'Available';
        availableBadge.style.setProperty('display', 'none', 'important');
        inputWrapper.appendChild(availableBadge);
      }

      let warnTimeout: ReturnType<typeof setTimeout> | null = null;

      const updateVisualState = () => {
        const raw = input.value;
        const clean = raw.replace(/^@+/, '');

        if (clean.length >= 3) {
          input.style.paddingRight = '78px';
          if (statusBadge) {
            statusBadge.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
            statusBadge.style.background = '#ecfdf5';
            statusBadge.style.color = '#10b981';
            statusBadge.style.borderRightColor = '#a7f3d0';
          }
          if (availableBadge) {
            availableBadge.classList.add('is-available');
            availableBadge.style.setProperty('display', 'inline-flex', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#10b981';
            capsule.style.boxShadow = '0 0 0 3px rgba(16, 185, 129, 0.12)';
          }
        } else if (clean.length > 0) {
          input.style.paddingRight = '12px';
          if (statusBadge) {
            statusBadge.innerHTML = `<span style="font-size: 15px; font-weight: 600; color: #1d64ec;">@</span>`;
            statusBadge.style.background = '#eef4ff';
            statusBadge.style.color = '#1d64ec';
            statusBadge.style.borderRightColor = '#dbeafe';
          }
          if (availableBadge) {
            availableBadge.classList.remove('is-available');
            availableBadge.style.setProperty('display', 'none', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#1d64ec';
            capsule.style.boxShadow = '0 0 0 3px rgba(29, 100, 236, 0.12)';
          }
        } else {
          input.style.paddingRight = '12px';
          if (statusBadge) {
            statusBadge.innerHTML = `<span style="font-size: 15px; font-weight: 500; color: #787574;">@</span>`;
            statusBadge.style.background = '#ffffff';
            statusBadge.style.color = '#787574';
            statusBadge.style.borderRightColor = '#d7dde0';
          }
          if (availableBadge) {
            availableBadge.classList.remove('is-available');
            availableBadge.style.setProperty('display', 'none', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#d7dde0';
            capsule.style.boxShadow = 'none';
          }
        }
      };

      const triggerAlert = () => {
        if (warnBadge) {
          warnBadge.style.display = 'inline-flex';
          warnBadge.style.opacity = '1';
        }
        if (capsule) {
          capsule.style.borderColor = '#e11d48';
          capsule.style.boxShadow = '0 0 0 3px rgba(225, 29, 72, 0.15)';
        }
        triggerHaptic('error');

        if (warnTimeout) clearTimeout(warnTimeout);
        warnTimeout = setTimeout(() => {
          if (warnBadge) warnBadge.style.display = 'none';
          updateVisualState();
        }, 1800);
      };

      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.ctrlKey || e.metaKey || e.altKey) return;

        if (e.key === 'Backspace' && (input.value === '@' || (input.selectionStart === 1 && input.value.length === 1))) {
          e.preventDefault();
          input.value = '';
          updateVisualState();
          return;
        }

        if (['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab', 'Enter', 'Escape', 'Home', 'End'].includes(e.key)) {
          return;
        }

        if (e.key === ' ' || e.code === 'Space') {
          e.preventDefault();
          triggerAlert();
          return;
        }

        if (e.key.length === 1) {
          if (!/^[a-z0-9_.]$/.test(e.key.toLowerCase())) {
            e.preventDefault();
            triggerAlert();
            return;
          }
        }
      };

      const handleInput = () => {
        const raw = input.value;
        const clean = raw.replace(/^@+/, '').toLowerCase().replace(/[^a-z0-9_.]/g, '');

        if (clean.length > 0) {
          input.value = '@' + clean;
        } else {
          input.value = '';
        }

        updateVisualState();
      };

      input.addEventListener('keydown', handleKeyDown);
      input.addEventListener('input', handleInput);
      updateVisualState();
    });
  }, [isMobile, containerRef]);

  // 3. Global Click Interception
  useEffect(() => {
    const handleGlobalClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (!target) return;

      const btn = target.closest('button, a');
      if (!btn) return;

      const text = (btn.textContent || '').trim().toLowerCase();
      if (text.includes('claim') || text.includes('create account') || text.includes('daftar') || text.includes('pasang') || text.includes('install') || text.includes('download')) {
        e.preventDefault();
        e.stopPropagation();

        const input = document.querySelector<HTMLInputElement>('input[name="username"]');
        if (input && input.value) {
          const val = input.value.replace(/^@+/, '').trim();
          const isInvalid = !/^[a-z0-9_.]+$/.test(val);
          if (isInvalid) {
            triggerHaptic('error');
            const capsule = input.closest('.framer-1oduyj0, .framer-1wlgcwd, .framer-7j981h') as HTMLElement | null;
            if (capsule) {
              capsule.style.animation = 'capsuleShake 0.4s ease';
              setTimeout(() => {
                capsule.style.animation = '';
              }, 400);
            }
            return;
          }
          try {
            localStorage.setItem('snapan_reserved_username', val);
          } catch {}
        }

        triggerHaptic('medium');
        onOpenInstallModal();
      } else if (text.includes('log in') || text.includes('masuk web') || text.includes('buka web') || text.includes('sign in')) {
        if (onProceedToWeb) {
          e.preventDefault();
          onProceedToWeb();
        }
      } else if (text.includes('denah') || text.includes('map')) {
        e.preventDefault();
        triggerHaptic('light');
        window.location.hash = '/map';
      } else if (text.includes('fitur')) {
        e.preventDefault();
        triggerHaptic('light');
        const featuresEl = document.querySelector('.framer-sdhxzw');
        if (featuresEl) {
          featuresEl.scrollIntoView({ behavior: 'smooth' });
        }
      } else if (text.includes('forum') || text.includes('cod')) {
        e.preventDefault();
        triggerHaptic('light');
        const forumEl = document.querySelector('.framer-1jz7gk6');
        if (forumEl) {
          forumEl.scrollIntoView({ behavior: 'smooth' });
        }
      } else if (text.includes('support')) {
        e.preventDefault();
        triggerHaptic('light');
        const supportEl = document.querySelector('.framer-rawiv7, .framer-l69iqf');
        if (supportEl) {
          supportEl.scrollIntoView({ behavior: 'smooth' });
        }
      }
    };

    document.addEventListener('click', handleGlobalClick);
    return () => document.removeEventListener('click', handleGlobalClick);
  }, [onProceedToWeb, onOpenInstallModal]);
}
