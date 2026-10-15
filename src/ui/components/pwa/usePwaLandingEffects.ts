import { useEffect, RefObject } from 'react';
import { triggerHaptic } from '@/utils/haptics';
import { checkUsernameAvailability } from '@/services/api/profileService';

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

  // 2. Real-time Username Input Validation & Backend Check via Supabase
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
            <svg width=\"13\" height=\"13\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\" style=\"flex-shrink:0;\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><line x1=\"12\" y1=\"8\" x2=\"12\" y2=\"12\"/><line x1=\"12\" y1=\"16\" x2=\"12.01\" y2=\"16\"/></svg>
            <span class=\"warn-badge-text\">Hanya huruf kecil tanpa kapital, spasi, atau simbol</span>
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
      let checkDebounceTimer: ReturnType<typeof setTimeout> | null = null;
      let checkRequestId = 0;

      const triggerAlert = (customMessage?: string) => {
        if (warnBadge) {
          const textSpan = warnBadge.querySelector('.warn-badge-text');
          if (textSpan) {
            textSpan.textContent = customMessage || 'Hanya huruf kecil tanpa kapital, spasi, atau simbol';
          }
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
          const currentState = (input.dataset.availabilityState as any) || 'empty';
          updateVisualState(currentState);
        }, 2200);
      };

      const updateVisualState = (
        state: 'empty' | 'short' | 'checking' | 'available' | 'taken' | 'reserved',
        customText?: string
      ) => {
        input.dataset.availabilityState = state;

        if (state === 'available') {
          input.style.paddingRight = '78px';
          if (statusBadge) {
            statusBadge.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
            statusBadge.style.background = '#ecfdf5';
            statusBadge.style.color = '#10b981';
            statusBadge.style.borderRightColor = '#a7f3d0';
          }
          if (availableBadge) {
            availableBadge.textContent = 'Available';
            availableBadge.className = 'username-available-tag is-available';
            availableBadge.style.setProperty('display', 'inline-flex', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#10b981';
            capsule.style.boxShadow = '0 0 0 3px rgba(16, 185, 129, 0.12)';
          }
        } else if (state === 'taken') {
          input.style.paddingRight = '96px';
          if (statusBadge) {
            statusBadge.innerHTML = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#e11d48" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>`;
            statusBadge.style.background = '#fff1f2';
            statusBadge.style.color = '#e11d48';
            statusBadge.style.borderRightColor = '#fecdd3';
          }
          if (availableBadge) {
            availableBadge.textContent = customText || 'Sudah Dipakai';
            availableBadge.className = 'username-available-tag is-taken';
            availableBadge.style.setProperty('display', 'inline-flex', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#e11d48';
            capsule.style.boxShadow = '0 0 0 3px rgba(225, 29, 72, 0.15)';
          }
        } else if (state === 'reserved') {
          input.style.paddingRight = '98px';
          if (statusBadge) {
            statusBadge.innerHTML = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>`;
            statusBadge.style.background = '#fffbeb';
            statusBadge.style.color = '#d97706';
            statusBadge.style.borderRightColor = '#fde68a';
          }
          if (availableBadge) {
            availableBadge.textContent = 'Dipesan Sistem';
            availableBadge.className = 'username-available-tag is-taken';
            availableBadge.style.setProperty('display', 'inline-flex', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#d97706';
            capsule.style.boxShadow = '0 0 0 3px rgba(217, 119, 6, 0.15)';
          }
        } else if (state === 'checking') {
          input.style.paddingRight = '88px';
          if (statusBadge) {
            statusBadge.innerHTML = `<svg class="badge-spinner" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 1 1-6.219-8.56"/></svg>`;
            statusBadge.style.background = '#eff6ff';
            statusBadge.style.color = '#2563eb';
            statusBadge.style.borderRightColor = '#bfdbfe';
          }
          if (availableBadge) {
            availableBadge.textContent = 'Checking...';
            availableBadge.className = 'username-available-tag is-checking';
            availableBadge.style.setProperty('display', 'inline-flex', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#3b82f6';
            capsule.style.boxShadow = '0 0 0 3px rgba(59, 130, 246, 0.12)';
          }
        } else if (state === 'short') {
          input.style.paddingRight = '12px';
          if (statusBadge) {
            statusBadge.innerHTML = `<span style="font-size: 15px; font-weight: 600; color: #1d64ec;">@</span>`;
            statusBadge.style.background = '#eef4ff';
            statusBadge.style.color = '#1d64ec';
            statusBadge.style.borderRightColor = '#dbeafe';
          }
          if (availableBadge) {
            availableBadge.className = 'username-available-tag';
            availableBadge.style.setProperty('display', 'none', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#1d64ec';
            capsule.style.boxShadow = '0 0 0 3px rgba(29, 100, 236, 0.12)';
          }
        } else {
          // empty
          input.style.paddingRight = '12px';
          if (statusBadge) {
            statusBadge.innerHTML = `<span style="font-size: 15px; font-weight: 500; color: #787574;">@</span>`;
            statusBadge.style.background = '#ffffff';
            statusBadge.style.color = '#787574';
            statusBadge.style.borderRightColor = '#d7dde0';
          }
          if (availableBadge) {
            availableBadge.className = 'username-available-tag';
            availableBadge.style.setProperty('display', 'none', 'important');
          }
          if (capsule) {
            capsule.style.borderColor = '#d7dde0';
            capsule.style.boxShadow = 'none';
          }
        }
      };

      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.ctrlKey || e.metaKey || e.altKey) return;

        if (e.key === 'Backspace' && (input.value === '@' || (input.selectionStart === 1 && input.value.length === 1))) {
          e.preventDefault();
          input.value = '';
          updateVisualState('empty');
          return;
        }

        if (['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab', 'Enter', 'Escape', 'Home', 'End'].includes(e.key)) {
          return;
        }

        if (e.key === ' ' || e.code === 'Space') {
          e.preventDefault();
          triggerAlert('Username tidak boleh mengandung spasi');
          return;
        }

        if (e.key.length === 1) {
          if (!/^[a-z0-9_.]$/.test(e.key.toLowerCase())) {
            e.preventDefault();
            triggerAlert('Hanya huruf kecil tanpa kapital, spasi, atau simbol');
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

        if (checkDebounceTimer) {
          clearTimeout(checkDebounceTimer);
        }

        if (clean.length === 0) {
          updateVisualState('empty');
          return;
        }

        if (clean.length < 3) {
          updateVisualState('short');
          return;
        }

        // Segera tampilkan status checking
        updateVisualState('checking');
        const currentReq = ++checkRequestId;

        // Debounce 350ms ke Supabase backend
        checkDebounceTimer = setTimeout(async () => {
          try {
            const result = await checkUsernameAvailability(clean);
            if (currentReq !== checkRequestId) return; // query sudah kedaluwarsa

            if (result.available) {
              updateVisualState('available');
            } else if (result.reason === 'reserved') {
              updateVisualState('reserved', 'Dipesan Sistem');
            } else {
              updateVisualState('taken', 'Sudah Dipakai');
            }
          } catch {
            if (currentReq !== checkRequestId) return;
            updateVisualState('short');
          }
        }, 350);
      };

      input.addEventListener('keydown', handleKeyDown);
      input.addEventListener('input', handleInput);
      updateVisualState('empty');
    });
  }, [isMobile, containerRef]);

  // 3. Support by Partner Logo Infinite Smooth Marquee System
  useEffect(() => {
    const root = containerRef.current;
    if (!root) return;

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return;
    }

    const tickers = root.querySelectorAll<HTMLElement>(
      '.framer-rawiv7 ul, .framer-l69iqf ul, .framer-1ef5tr8-container ul, .framer-1qfu0rf-container ul, .framer-hxu555-container ul, .framer-axvdsa ul'
    );

    tickers.forEach((ul) => {
      if (ul.dataset.marqueeInitialized) return;
      ul.dataset.marqueeInitialized = 'true';

      // Duplicate children for seamless infinite wrap
      const originalItems = Array.from(ul.children);
      originalItems.forEach((item) => {
        const clone = item.cloneNode(true) as HTMLElement;
        clone.setAttribute('aria-hidden', 'true');
        ul.appendChild(clone);
      });

      ul.classList.add('support-marquee-track');
    });
  }, [containerRef, isMobile]);

  // 4. Global Click Interception
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
          const val = input.value.replace(/^@+/, '').trim().toLowerCase();
          const state = input.dataset.availabilityState;

          const shakeCapsule = () => {
            const capsule = input.closest('.framer-1oduyj0, .framer-1wlgcwd, .framer-7j981h') as HTMLElement | null;
            if (capsule) {
              capsule.style.animation = 'capsuleShake 0.4s ease';
              setTimeout(() => {
                capsule.style.animation = '';
              }, 400);
            }
          };

          const showCustomAlert = (msg: string) => {
            const parentRow = input.closest('[data-framer-name="Buttons"], .framer-12tlorp, .framer-j6nqnh') as HTMLElement | null;
            const warnBadge = parentRow?.querySelector('.username-warn-badge') as HTMLElement | null;
            if (warnBadge) {
              const textSpan = warnBadge.querySelector('.warn-badge-text');
              if (textSpan) {
                textSpan.textContent = msg;
              }
              warnBadge.style.display = 'inline-flex';
              warnBadge.style.opacity = '1';
              setTimeout(() => {
                if (warnBadge) warnBadge.style.display = 'none';
              }, 2500);
            }
          };

          if (state === 'taken') {
            triggerHaptic('error');
            shakeCapsule();
            showCustomAlert('Username sudah digunakan oleh akun lain!');
            return;
          }

          if (state === 'reserved') {
            triggerHaptic('error');
            shakeCapsule();
            showCustomAlert('Username ini dilindungi oleh sistem!');
            return;
          }

          if (state === 'checking') {
            triggerHaptic('warning');
            return;
          }

          if (val.length < 3) {
            triggerHaptic('error');
            shakeCapsule();
            showCustomAlert('Minimal 3 karakter untuk username');
            return;
          }

          if (!/^[a-z0-9_.]+$/.test(val)) {
            triggerHaptic('error');
            shakeCapsule();
            showCustomAlert('Hanya huruf kecil tanpa kapital, spasi, atau simbol');
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
      } else if (text.includes('fitur') || text === 'fitur') {
        e.preventDefault();
        triggerHaptic('light');
        const featuresEl = document.querySelector('.framer-sdhxzw, [data-framer-name="Collection Section"]');
        if (featuresEl) {
          featuresEl.scrollIntoView({ behavior: 'smooth' });
        }
      } else if (text.includes('klaim') || text.includes('claim')) {
        e.preventDefault();
        triggerHaptic('light');
        const claimEl = document.querySelector('.framer-1fqlk99, .framer-rawiv7, .framer-l69iqf');
        if (claimEl) {
          claimEl.scrollIntoView({ behavior: 'smooth' });
        }
      } else if (text.includes('support')) {
        e.preventDefault();
        triggerHaptic('light');
        const supportEl = document.querySelector('.framer-axvdsa, .framer-9agg0o');
        if (supportEl) {
          supportEl.scrollIntoView({ behavior: 'smooth' });
        }
      }
    };

    document.addEventListener('click', handleGlobalClick);
    return () => document.removeEventListener('click', handleGlobalClick);
  }, [onProceedToWeb, onOpenInstallModal]);
}
