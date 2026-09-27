import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { SnapsLogoSvg } from '@/ui/components/brand/SnapsLogoSvg';
import { triggerHaptic } from '@/utils/haptics';

interface AppEntranceSplashProps {
  onComplete: () => void;
}

export const AppEntranceSplash: React.FC<AppEntranceSplashProps> = ({ onComplete }) => {
  const [phase, setPhase] = useState<'letters' | 'morph' | 'done'>('letters');

  const handleLettersComplete = () => {
    // Subtle tactile tick when full logo is formed
    triggerHaptic('light');

    // Hold for 220ms then start the morph glide to header
    setTimeout(() => {
      setPhase('morph');
    }, 220);
  };

  const handleMorphComplete = () => {
    setPhase('done');
    onComplete();
  };

  if (phase === 'done') return null;

  return (
    <AnimatePresence>
      <motion.div
        key="snaps-splash-backdrop"
        initial={{ opacity: 1 }}
        animate={{ opacity: phase === 'morph' ? 0 : 1 }}
        transition={{ duration: 0.38, ease: [0.16, 1, 0.3, 1], delay: 0.12 }}
        className={`fixed inset-0 z-[100] flex items-center justify-center bg-white select-none ${
          phase === 'morph' ? 'pointer-events-none' : 'pointer-events-auto'
        }`}
      >
        <motion.div
          className="flex flex-col items-center justify-center"
          initial={{ y: 0, scale: 1 }}
          animate={
            phase === 'morph'
              ? {
                  // Morph glide to the exact center of the top 52px header bar
                  y: typeof window !== 'undefined' ? -(window.innerHeight / 2 - 26) : -300,
                  scale: 0.36,
                  opacity: 0,
                }
              : { y: 0, scale: 1, opacity: 1 }
          }
          transition={{
            duration: 0.46,
            ease: [0.16, 1, 0.3, 1],
          }}
          onAnimationComplete={() => {
            if (phase === 'morph') {
              handleMorphComplete();
            }
          }}
        >
          {/* Logo with sequential staggered letter reveal */}
          <SnapsLogoSvg
            height={72}
            width="auto"
            animated={true}
            onAnimationComplete={handleLettersComplete}
          />

          {/* Subtle subtext tag beneath logo */}
          <motion.span
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.45, duration: 0.35 }}
            className="text-[12px] font-semibold text-slate-400 tracking-wider uppercase mt-3.5"
          >
            Snapanians 2026
          </motion.span>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};
