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

  // 1. Interactive Motion Physics, Scroll-Triggered Reveal & 5-Phone Fan-Out Observer
  useEffect(() => {
    const root = containerRef.current;
    if (!root) return;

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return;
    }

    // A. 5-Phone Fan-Out Mockup Physics
    const phoneMockups = root.querySelectorAll<HTMLElement>('[data-framer-name="Mockup"]');
    if (phoneMockups.length >= 5) {
      const phoneObserver = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              phoneMockups.forEach((phone, idx) => {
                phone.classList.remove('pop-phone-init');
                if (idx === 2) {
                  phone.classList.add('pop-phone-center-active');
                } else if (idx === 1 || idx === 3) {
                  phone.classList.add('pop-phone-inner-active');
                } else {
                  phone.classList.add('pop-phone-outer-active');
                }
              });
            }
          });
        },
        { threshold: 0.15 }
      );

      phoneMockups.forEach((phone) => {
        phone.classList.add('pop-phone-init');
      });

      if (phoneMockups[0].parentElement) {
        phoneObserver.observe(phoneMockups[0].parentElement);
      }
    }

    // B. General Section Scroll-Reveal Observer
    const elementsToAnimate = root.querySelectorAll(
      '#main > div > div, [data-framer-component-type="Stack"] > div[style*="position"], section, [data-framer-name*="Section"], [data-framer-name*="Bento"], [data-framer-name*="Theme"], [data-framer-name*="FAQ"]'
    );

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('pop-motion-visible');
          }
        });
      },
      {
        rootMargin: '0px 0px -40px 0px',
        threshold: 0.08,
      }
    );

    elementsToAnimate.forEach((el, index) => {
      if (index === 0 || el.getBoundingClientRect().top < 400 || el.closest('[data-framer-name="Mockup"]')) {
        el.classList.add('pop-motion-hero');
        return;
      }
      el.classList.add('pop-motion-init');
      observer.observe(el);
    });

    return () => {
      observer.disconnect();
    };
  }, [isMobile]);

  // 2. Intercept clicks on claim buttons, install actions, or login
  useEffect(() => {
    const handleGlobalClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (!target) return;

      const btn = target.closest('button, a');
      if (!btn) return;

      const text = (btn.textContent || '').trim().toLowerCase();
      if (text.includes('claim') || text.includes('create account') || text.includes('pasang') || text.includes('install')) {
        e.preventDefault();
        e.stopPropagation();
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

        /* 📱 5-Phone Fan-Out Staggered Elevation Physics */
        .pop-phone-init {
          opacity: 0;
          transform: translateY(45px) scale(0.96);
          transition: opacity 0.75s cubic-bezier(0.16, 1, 0.3, 1), transform 0.75s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s ease;
          will-change: opacity, transform;
        }
        .pop-phone-center-active {
          opacity: 1 !important;
          transform: translateY(0) scale(1) !important;
          transition: opacity 0.75s cubic-bezier(0.16, 1, 0.3, 1), transform 0.75s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s ease !important;
        }
        .pop-phone-inner-active {
          opacity: 1 !important;
          transform: translateY(0) scale(1) !important;
          transition: opacity 0.75s 0.12s cubic-bezier(0.16, 1, 0.3, 1), transform 0.75s 0.12s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s ease !important;
        }
        .pop-phone-outer-active {
          opacity: 1 !important;
          transform: translateY(0) scale(1) !important;
          transition: opacity 0.75s 0.24s cubic-bezier(0.16, 1, 0.3, 1), transform 0.75s 0.24s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.4s ease !important;
        }

        /* 🔍 Interactive 3D Hover Depth Focus on Phones */
        [data-framer-name="Mockup"] {
          transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.35s ease, z-index 0.1s !important;
          cursor: pointer;
        }
        [data-framer-name="Mockup"]:hover {
          transform: translateY(-10px) scale(1.03) !important;
          z-index: 20 !important;
          box-shadow: 0 40px 80px -15px rgba(0, 0, 0, 0.22) !important;
        }

        /* Hover Zoom on Interactive Theme Cards & Images */
        a:has(img), [data-framer-component-type="Stack"]:has(img) {
          transition: transform 0.35s cubic-bezier(0.16, 1, 0.3, 1), box-shadow 0.35s ease !important;
        }
        a:has(img):hover, [data-framer-component-type="Stack"]:has(img):hover {
          transform: translateY(-4px) scale(1.015) !important;
        }

        /* 💎 Cloudflare Kumo UI Button Styling (All CTA Action Buttons) */
        [data-framer-name="Button"], 
        [data-framer-name*="CTA"], 
        a[href*="app.pop.site"],
        .framer-192wfb0 {
          background: linear-gradient(180deg, #3b82f6 0%, #1d64ec 100%) !important;
          box-shadow: inset 0 1px 0 0 rgba(255, 255, 255, 0.35), 0 4px 14px 0 rgba(29, 100, 236, 0.35) !important;
          border: 1px solid #154ec1 !important;
          color: #ffffff !important;
          border-radius: 9999px !important;
          transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), filter 0.2s ease !important;
        }
        [data-framer-name="Button"]:hover, 
        [data-framer-name*="CTA"]:hover,
        a[href*="app.pop.site"]:hover {
          filter: brightness(1.08) !important;
          transform: translateY(-1px) scale(1.01) !important;
        }
        [data-framer-name="Button"]:active, 
        [data-framer-name*="CTA"]:active,
        a[href*="app.pop.site"]:active {
          transform: scale(0.96) !important;
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
