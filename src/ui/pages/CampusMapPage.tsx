import React from 'react';
import { ArrowLeft } from 'lucide-react';
import { MappedinView } from '../components/map/MappedinView';
import { triggerHaptic } from '@/utils/haptics';

interface CampusMapPageProps {
  onBack?: () => void;
}

export const CampusMapPage: React.FC<CampusMapPageProps> = ({ onBack }) => {
  const handleBack = () => {
    triggerHaptic('light');
    if (onBack) {
      onBack();
    } else {
      window.history.back();
    }
  };

  return (
    <div className="fixed inset-0 z-50 w-screen h-screen bg-slate-950 overflow-hidden font-gt-standard">
      {/* 1. Minimalist Floating Back Button in Top-Left */}
      <div className="absolute top-4 left-4 z-40">
        <button
          type="button"
          onClick={handleBack}
          className="w-10 h-10 rounded-2xl bg-slate-900/80 backdrop-blur-xl border border-white/15 text-white hover:bg-slate-800 active:scale-90 flex items-center justify-center transition-all shadow-xl cursor-pointer"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.4]" />
        </button>
      </div>

      {/* 2. Pure Edge-to-Edge WebGL 2.5D/3D Interactive Map Canvas */}
      <MappedinView />
    </div>
  );
};
