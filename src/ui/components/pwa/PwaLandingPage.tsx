import React, { useEffect, useState } from 'react';
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

  useEffect(() => {
    const handleResize = () => {
      setIsMobile(window.innerWidth < 810);
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  useEffect(() => {
    // Intercept clicks on claim buttons, install actions, or login
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
      className="min-h-screen w-full bg-white font-gt-standard overflow-x-hidden antialiased select-none"
    >
      <div dangerouslySetInnerHTML={{ __html: isMobile ? popSiteMobileHtml : popSiteHtml }} />

      <CustomPwaInstallModal
        isOpen={showCustomInstallModal}
        onClose={() => setShowCustomInstallModal(false)}
        onConfirmInstall={handleConfirmInstall}
      />
    </motion.div>
  );
};
