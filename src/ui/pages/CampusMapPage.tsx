import React from 'react';
import { ArrowLeft, Compass, Sparkles } from 'lucide-react';
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
    <div className="min-h-screen bg-[#f8fafc] text-slate-900 font-gt-standard pb-12 max-w-[620px] mx-auto overflow-x-hidden animate-in fade-in duration-200">
      {/* 1. Permanent Sticky Top Navigation Bar */}
      <header className="sticky top-0 inset-x-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between">
        {/* Left: Back Button */}
        <button
          type="button"
          onClick={handleBack}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 active:scale-90 transition-all cursor-pointer"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
        </button>

        {/* Center: Title & Subtitle */}
        <div className="flex-1 min-w-0 text-center px-2">
          <h1 className="font-bold text-[15px] text-slate-900 truncate">
            Mappedin WebGL Playground
          </h1>
          <p className="text-[11px] text-[#3d38f5] font-semibold">
            Live Official Interactive 3D/2D Engine
          </p>
        </div>

        {/* Right: Badge Indicator */}
        <div className="w-9 h-9 flex items-center justify-center">
          <Compass className="w-5 h-5 text-[#3d38f5] stroke-[2]" />
        </div>
      </header>

      {/* 2. Main Map Area (Fokus Penuh ke Map) */}
      <div className="p-3.5 space-y-3">
        {/* Banner Info Ringkas */}
        <div className="bg-[#eef0ff] border border-[#d8dbfe] rounded-2xl p-3 flex items-center gap-2.5 shadow-2xs">
          <Sparkles className="w-4 h-4 text-[#3d38f5] shrink-0" />
          <p className="text-[12px] text-slate-700 font-normal leading-snug">
            Engine WebGL Mappedin asli dengan fisika momentum kamera, rotasi, zoom, dan seleksi poligon ruangan.
          </p>
        </div>

        {/* 3. The Live Official Mappedin Map Component */}
        <MappedinView
          onSpaceClick={() => {
            triggerHaptic('light');
          }}
        />
      </div>
    </div>
  );
};
