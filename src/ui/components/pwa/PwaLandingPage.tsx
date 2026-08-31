import React, { useEffect, useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { popSiteHtml } from './popSiteHtml';
import { popSiteMobileHtml } from './popSiteMobileHtml';
import { usePWA } from '@/ui/hooks/usePWA';
import { CustomPwaInstallModal } from './CustomPwaInstallModal';
import { triggerHaptic } from '@/utils/haptics';

interface PwaLandingPageProps {
  onProceedToWeb?: () => void;
}

export const PwaLandingPage: React.FC<PwaLandingPageProps> = ({ onProceedToWeb }) => {
  const { promptInstall } = usePWA();
  const [showCustomInstallModal, setShowCustomInstallModal] = useState(false);
  const [isMobile, setIsMobile] = useState(() => (typeof window !== 'undefined' ? window.innerWidth < 810 : false));
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 810);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

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
      // If already in viewport on mount, trigger immediately
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
  }, [isMobile]);

  // 2. Real-time Username Input Validation & Warn Alert
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const inputs = container.querySelectorAll<HTMLInputElement>('input[name="username"]');

    inputs.forEach((input) => {
      // Buat elemen warning alert badge jika belum ada
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

      let warnTimeout: ReturnType<typeof setTimeout> | null = null;

      const updateVisualState = () => {
        const raw = input.value;
        const clean = raw.replace(/^@+/, '');

        if (clean.length >= 3) {
          // Centang Hijau (Valid & Aman)
          if (statusBadge) {
            statusBadge.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
            statusBadge.style.background = '#ecfdf5';
            statusBadge.style.color = '#10b981';
            statusBadge.style.borderRightColor = '#a7f3d0';
          }
          if (capsule) {
            capsule.style.borderColor = '#10b981';
            capsule.style.boxShadow = '0 0 0 3px rgba(16, 185, 129, 0.12)';
          }
        } else if (clean.length > 0) {
          // Sedang Mengetik (< 3 karakter)
          if (statusBadge) {
            statusBadge.innerHTML = `<span style="font-size: 15px; font-weight: 600; color: #1d64ec;">@</span>`;
            statusBadge.style.background = '#eef4ff';
            statusBadge.style.color = '#1d64ec';
            statusBadge.style.borderRightColor = '#dbeafe';
          }
          if (capsule) {
            capsule.style.borderColor = '#1d64ec';
            capsule.style.boxShadow = '0 0 0 3px rgba(29, 100, 236, 0.12)';
          }
        } else {
          // Kosong (Default)
          if (statusBadge) {
            statusBadge.innerHTML = `<span style="font-size: 15px; font-weight: 500; color: #787574;">@</span>`;
            statusBadge.style.background = '#ffffff';
            statusBadge.style.color = '#787574';
            statusBadge.style.borderRightColor = '#d7dde0';
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

      // 1. Block forbidden keys on keydown & Auto-handle backspace at prefix
      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.ctrlKey || e.metaKey || e.altKey) return;

        // Jika hanya sisa "@" dan user tekan Backspace, kosongkan langsung
        if (e.key === 'Backspace' && (input.value === '@' || (input.selectionStart === 1 && input.value.length === 1))) {
          e.preventDefault();
          input.value = '';
          updateVisualState();
          return;
        }

        if (['Backspace', 'Delete', 'ArrowLeft', 'ArrowRight', 'Tab', 'Enter', 'Escape', 'Home', 'End'].includes(e.key)) {
          return;
        }

        // Blokir SPASI
        if (e.key === ' ' || e.code === 'Space') {
          e.preventDefault();
          triggerAlert();
          return;
        }

        // Blokir HURUF BESAR & SIMBOL selain a-z, 0-9, _, .
        if (e.key.length === 1) {
          if (!/^[a-z0-9_.]$/.test(e.key.toLowerCase())) {
            e.preventDefault();
            triggerAlert();
            return;
          }
        }
      };

      // 2. Format with "@" prefix automatically on input
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
    });
  }, [isMobile]);

  // 3. Intercept clicks on claim buttons, install actions, or login
  useEffect(() => {
    const handleGlobalClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (!target) return;

      const btn = target.closest('button, a');
      if (!btn) return;

      const text = (btn.textContent || '').trim().toLowerCase();
      if (text.includes('claim') || text.includes('create account') || text.includes('pasang') || text.includes('install') || text.includes('download')) {
        e.preventDefault();
        e.stopPropagation();

        // Cek apakah ada input username di halaman
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
        setShowCustomInstallModal(true);
      } else if (text.includes('log in') || text.includes('buka web') || text.includes('sign in')) {
        if (onProceedToWeb) {
          e.preventDefault();
          onProceedToWeb();
        }
      }
    };

    document.addEventListener('click', handleGlobalClick);
    return () => document.removeEventListener('click', handleGlobalClick);
  }, [onProceedToWeb]);

  const handleConfirmInstall = async () => {
    setShowCustomInstallModal(false);
    await promptInstall();
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
      className="min-h-screen w-full bg-white font-gt-standard overflow-x-clip antialiased select-none relative"
    >
      {/* Dynamic 120 FPS Motion Physics Stylesheet */}
      <style>{`
        /* Staggered Scroll-Reveal Animation */
        .pop-motion-init {
          opacity: 0;
          transform: translateY(28px) scale(0.985);
          transition: opacity 0.7s cubic-bezier(0.16, 1, 0.3, 1), transform 0.7s cubic-bezier(0.16, 1, 0.3, 1);
          will-change: opacity, transform;
        }
        .pop-motion-visible {
          opacity: 1 !important;
          transform: translateY(0) scale(1) !important;
        }

        /* Hero Stagger Entrance */
        .pop-motion-hero {
          animation: popHeroFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) both;
        }
        @keyframes popHeroFadeIn {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes popBadgeEnter {
          from {
            opacity: 0;
            transform: translate(-50%, 6px) scale(0.95);
          }
          to {
            opacity: 1;
            transform: translate(-50%, 0) scale(1);
          }
        }

        @keyframes capsuleShake {
          0%, 100% { transform: translateX(0); }
          20%, 60% { transform: translateX(-6px); }
          40%, 80% { transform: translateX(6px); }
        }

        /* 🌊 Viewport Entrance Motion System (Gradual & Noticeable) */
        .pop-reveal {
          opacity: 0;
          transform: translateY(48px);
          transition: opacity 0.9s cubic-bezier(0.16, 1, 0.3, 1), transform 0.9s cubic-bezier(0.16, 1, 0.3, 1) !important;
          will-change: opacity, transform;
        }

        .pop-reveal.pop-in-view {
          opacity: 1 !important;
          transform: translateY(0px) !important;
        }

        /* Bento cards cascade stagger delay */
        .framer-1p2c0r4.pop-reveal { transition-delay: 0ms !important; }
        .framer-1jz2pvg.pop-reveal { transition-delay: 120ms !important; }
        .framer-11kd95v.pop-reveal { transition-delay: 240ms !important; }
        .framer-xlz7uj.pop-reveal  { transition-delay: 360ms !important; }

        /* 🔤 2-Line Hero H1 Headline */
        .framer-apv9m0 {
          max-width: 1100px !important;
          margin: 0 auto !important;
        }
        .framer-apv9m0 h1 {
          font-size: 84px !important;
          line-height: 1.05 !important;
          letter-spacing: -2.8px !important;
          text-align: center !important;
          margin: 0 !important;
        }
        @media (max-width: 809.98px) {
          .framer-apv9m0 {
            max-width: 100% !important;
          }
          .framer-apv9m0 h1 {
            font-size: 44px !important;
            line-height: 1.1 !important;
            letter-spacing: -1.2px !important;
          }
        }

        /* 🔤 Semudah Posting Section Headline (Consistent 64px) */
        .framer-1jz7gk6 h1,
        .framer-qdt69g h1,
        .framer-69jfqs h1 {
          font-size: 64px !important;
          line-height: 1.1 !important;
          letter-spacing: -2px !important;
          max-width: 950px !important;
          margin: 0 auto !important;
          text-align: center !important;
        }
        .framer-qdt69g {
          max-width: 950px !important;
          margin: 0 auto !important;
        }
        @media (max-width: 809.98px) {
          .framer-1jz7gk6 h1,
          .framer-qdt69g h1,
          .framer-69jfqs h1 {
            font-size: 38px !important;
            line-height: 1.15 !important;
            letter-spacing: -1.2px !important;
          }
        }

        .framer-dpcl3b {
          display: flex !important;
          flex-direction: row !important;
          align-items: center !important;
          justify-content: center !important;
          gap: 8px !important;
          width: auto !important;
          max-width: 100% !important;
          margin: 0 auto !important;
          overflow: visible !important;
        }
        .framer-dpcl3b h3 {
          text-align: center !important;
        }

        /* Buttons Row Centering */
        [data-framer-name="Buttons"], .framer-12tlorp, .framer-j6nqnh {
          display: flex !important;
          flex-direction: row !important;
          align-items: center !important;
          justify-content: center !important;
          gap: 12px !important;
          margin: 0 auto !important;
        }

        /* Input Capsule Sizing & Centering */
        .framer-1oduyj0, .framer-1wlgcwd, .framer-7j981h {
          width: 280px !important;
          min-width: 250px !important;
          height: 52px !important;
          min-height: 52px !important;
          max-height: 52px !important;
          box-sizing: border-box !important;
          display: flex !important;
          align-items: center !important;
          margin: 0 !important;
        }
        @media (max-width: 809.98px) {
          .framer-1oduyj0, .framer-1wlgcwd, .framer-7j981h {
            width: 240px !important;
            min-width: 210px !important;
            height: 48px !important;
            min-height: 48px !important;
            max-height: 48px !important;
          }
        }

        .framer-1oduyj0 input, .framer-1wlgcwd input, .framer-7j981h input {
          height: 100% !important;
          line-height: 52px !important;
          display: flex !important;
          align-items: center !important;
          margin: 0 !important;
        }
        @media (max-width: 809.98px) {
          .framer-1oduyj0 input, .framer-1wlgcwd input, .framer-7j981h input {
            line-height: 48px !important;
          }
        }

        .framer-g63eua-container, .framer-upoedb-container {
          display: flex !important;
          align-items: center !important;
          justify-content: center !important;
          height: 52px !important;
          margin: 0 !important;
        }
        @media (max-width: 809.98px) {
          .framer-g63eua-container, .framer-upoedb-container {
            height: 48px !important;
          }
        }

        /* 💎 Kumo Biru CTA Button Styling */
        [data-framer-name="Button"], 
        .framer-192wfb0 {
          height: 52px !important;
          min-height: 52px !important;
          max-height: 52px !important;
          display: inline-flex !important;
          align-items: center !important;
          justify-content: center !important;
          box-sizing: border-box !important;
          margin: 0 !important;
          padding: 0 26px !important;
          background: linear-gradient(180deg, #3b82f6 0%, #1d64ec 100%) !important;
          box-shadow: inset 0 1px 0 0 rgba(255, 255, 255, 0.35), 0 4px 14px 0 rgba(29, 100, 236, 0.32) !important;
          border: 1px solid #154ec1 !important;
          color: #ffffff !important;
          transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), filter 0.2s ease !important;
        }
        [data-framer-name="Button"] > div, .framer-192wfb0 > div {
          display: flex !important;
          align-items: center !important;
          justify-content: center !important;
          height: 100% !important;
        }
        [data-framer-name="Button"] p, .framer-192wfb0 p {
          margin: 0 !important;
          line-height: 1 !important;
          display: flex !important;
          align-items: center !important;
          justify-content: center !important;
        }
        @media (max-width: 809.98px) {
          [data-framer-name="Button"], 
          .framer-192wfb0 {
            height: 48px !important;
            min-height: 48px !important;
            max-height: 48px !important;
          }
        }
        [data-framer-name="Button"]:hover, .framer-192wfb0:hover {
          filter: brightness(1.08) !important;
          transform: translateY(-1px) scale(1.01) !important;
        }
        /* 🎠 Infinite Smooth Auto-Scrolling Marquee with Left/Right Edge Opacity Fade */
        .django-marquee-wrapper {
          position: relative !important;
          width: 100% !important;
          max-width: 100vw !important;
          overflow: hidden !important;
          padding: 24px 0 !important;
          box-sizing: border-box !important;
          mask-image: linear-gradient(to right, transparent 0%, black 10%, black 90%, transparent 100%) !important;
          -webkit-mask-image: linear-gradient(to right, transparent 0%, black 10%, black 90%, transparent 100%) !important;
        }

        .django-marquee-track {
          display: flex !important;
          flex-direction: row !important;
          align-items: stretch !important;
          gap: 24px !important;
          width: max-content !important;
          will-change: transform !important;
          animation: djangoMarqueeScroll 40s linear infinite !important;
          box-sizing: border-box !important;
        }

        .django-marquee-track:hover {
          animation-play-state: paused !important;
        }

        .django-marquee-track > .framer-a910ey {
          flex: 0 0 auto !important;
          width: 480px !important;
          max-width: 86vw !important;
          height: auto !important;
          min-height: 185px !important;
          display: flex !important;
          flex-direction: row !important;
          align-items: flex-start !important;
          margin: 0 !important;
          box-sizing: border-box !important;
          transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.35s ease !important;
          cursor: pointer !important;
        }

        .django-marquee-track .framer-49zkyx {
          flex: none !important;
          width: 112px !important;
          height: 112px !important;
          border-radius: 12px !important;
          overflow: hidden !important;
          align-self: flex-start !important;
          margin-top: 2px !important;
        }

        .django-marquee-track .framer-1rvfl3v {
          flex: 1 !important;
          display: flex !important;
          flex-direction: column !important;
          justify-content: space-between !important;
          gap: 12px !important;
        }

        .django-marquee-track > .framer-a910ey:hover {
          transform: none !important;
        }

        /* 🏷️ Feature Tag Pill Spacing */
        .framer-cqd791 {
          gap: 8px !important;
          width: max-content !important;
          padding: 4px 12px !important;
          align-items: center !important;
          display: inline-flex !important;
        }

        /* 📦 Compact Layout for Features Section */
        .framer-sdhxzw {
          padding: 60px 24px 40px !important;
        }
        .framer-sdhxzw .framer-dggxux {
          gap: 16px !important;
        }
        .framer-sdhxzw .framer-12h6gbf {
          max-width: 960px !important;
        }
        .framer-sdhxzw .framer-12h6gbf h1 {
          font-size: 68px !important;
          line-height: 1.05 !important;
          letter-spacing: -2.2px !important;
          margin: 0 !important;
        }
        .framer-sdhxzw .framer-1n10pgs {
          gap: 10px !important;
          margin-top: 4px !important;
          margin-bottom: 8px !important;
        }
        .framer-sdhxzw .framer-cgn049 h3 {
          font-size: 20px !important;
          line-height: 1.3 !important;
          letter-spacing: -0.02em !important;
          margin: 0 !important;
        }
        .framer-sdhxzw .framer-8r7xto {
          margin-top: 8px !important;
          width: 100% !important;
        }
        .framer-sdhxzw .framer-1c5m59g {
          display: flex !important;
          flex-direction: row !important;
          align-items: stretch !important;
          gap: 16px !important;
          width: 100% !important;
        }
        .framer-sdhxzw [data-framer-name="Feature Simple"],
        .framer-sdhxzw .framer-1p2c0r4,
        .framer-sdhxzw .framer-1jz2pvg,
        .framer-sdhxzw .framer-11kd95v,
        .framer-sdhxzw .framer-xlz7uj {
          height: 100% !important;
          min-height: 250px !important;
          display: flex !important;
          flex-direction: column !important;
          justify-content: flex-start !important;
          flex: 1 1 0 !important;
          box-sizing: border-box !important;
        }
        @media (max-width: 809.98px) {
          .framer-sdhxzw {
            padding: 40px 16px 24px !important;
          }
          .framer-sdhxzw .framer-12h6gbf h1 {
            font-size: 38px !important;
            line-height: 1.1 !important;
            letter-spacing: -1.2px !important;
          }
          .framer-sdhxzw .framer-cgn049 h3 {
            font-size: 16px !important;
          }
        }

        @keyframes djangoMarqueeScroll {
          0% {
            transform: translateX(0);
          }
          100% {
            transform: translateX(calc(-50% - 12px));
          }
        }

        @media (max-width: 809.98px) {
          .django-marquee-wrapper {
            padding: 16px 0 !important;
            mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%) !important;
            -webkit-mask-image: linear-gradient(to right, transparent 0%, black 6%, black 94%, transparent 100%) !important;
          }
          .django-marquee-track {
            animation-duration: 28s !important;
            gap: 16px !important;
          }
          .django-marquee-track > .framer-a910ey {
            width: 330px !important;
            max-width: 86vw !important;
          }
          @keyframes djangoMarqueeScroll {
            0% {
              transform: translateX(0);
            }
            100% {
              transform: translateX(calc(-50% - 8px));
            }
          }
        }

        /* Button Tap & Spring Physics */
        button, a, input[type="submit"] {
          transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), filter 0.2s ease !important;
        }
        button:active, a:active {
          transform: scale(0.96) !important;
        }
        button:hover, a:hover {
          filter: brightness(1.05);
        }

        /* Accessibility & Test Mode */
        @media (prefers-reduced-motion: reduce) {
          .pop-motion-init, .pop-motion-hero, .pop-phone-init, .pop-phone-center-active, .pop-phone-inner-active, .pop-phone-outer-active {
            opacity: 1 !important;
            transform: none !important;
            animation: none !important;
            transition: none !important;
          }
        }
      `}</style>

      <div ref={containerRef} dangerouslySetInnerHTML={{ __html: isMobile ? popSiteMobileHtml : popSiteHtml }} />

      <CustomPwaInstallModal
        isOpen={showCustomInstallModal}
        onClose={() => setShowCustomInstallModal(false)}
        onConfirmInstall={handleConfirmInstall}
      />
    </motion.div>
  );
};
