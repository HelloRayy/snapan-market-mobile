import React, { useState } from 'react';
import { ArrowLeft, Compass, Sparkles, Check } from 'lucide-react';
import { InteractiveCampusMap } from '../components/map/InteractiveCampusMap';
import { RoomZone } from '@/data/mockSchoolMapData';
import { triggerHaptic } from '@/utils/haptics';

interface CampusMapPageProps {
  onBack?: () => void;
}

export const CampusMapPage: React.FC<CampusMapPageProps> = ({ onBack }) => {
  const [selectedSpot, setSelectedSpot] = useState<RoomZone | null>(null);

  const handleBack = () => {
    triggerHaptic('light');
    if (onBack) {
      onBack();
    } else {
      window.history.back();
    }
  };

  const handleSelectSpot = (room: RoomZone) => {
    setSelectedSpot(room);
  };

  return (
    <div className="min-h-screen bg-[#f4f8fa] text-slate-900 font-gt-standard pb-12 max-w-[620px] mx-auto overflow-x-hidden animate-in fade-in duration-200">
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
            Denah 2D SMKN 8 Jakarta
          </h1>
          <p className="text-[11px] text-[#3d38f5] font-semibold">
            Interactive Hotspot Blueprint 🗺️
          </p>
        </div>

        {/* Right: Badge Indicator */}
        <div className="w-9 h-9 flex items-center justify-center">
          <Compass className="w-5 h-5 text-[#3d38f5] stroke-[2]" />
        </div>
      </header>

      {/* 2. Main Map Area (Fokus Penuh ke Denah Sesuai Gambar) */}
      <div className="p-3.5 space-y-3">
        {/* Banner Info Ringkas */}
        <div className="bg-[#eef0ff] border border-[#d8dbfe] rounded-2xl p-3 flex items-center gap-2.5 shadow-2xs">
          <Sparkles className="w-4 h-4 text-[#3d38f5] shrink-0" />
          <p className="text-[12px] text-slate-700 font-normal leading-snug">
            Geometri denah disesuaikan dengan tata letak sekolah. Ketuk ruangan atau pilih kategori di atas untuk melihat hotspot.
          </p>
        </div>

        {/* 3. The Interactive Campus Map Component */}
        <InteractiveCampusMap
          onSelectLocation={handleSelectSpot}
          selectedLocationId={selectedSpot?.id || 'kantin-utama'}
        />

        {/* 4. Confirmed Status Alert (If selected) */}
        {selectedSpot && (
          <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-3.5 flex items-center gap-3 animate-in fade-in zoom-in-95 duration-150">
            <div className="w-8 h-8 rounded-full bg-emerald-500 text-white flex items-center justify-center shrink-0">
              <Check className="w-4.5 h-4.5 stroke-[2.5]" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[11px] font-bold text-emerald-800 uppercase tracking-wider">
                Titik COD Terpilih
              </p>
              <p className="text-[13.5px] font-bold text-slate-900 truncate">
                {selectedSpot.name} ({selectedSpot.buildingName} · Lantai {selectedSpot.floor})
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
