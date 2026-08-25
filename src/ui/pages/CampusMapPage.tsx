import React, { useState } from 'react';
import { ArrowLeft, Compass, Sparkles, Handshake, Check } from 'lucide-react';
import { InteractiveCampusMap } from '../components/map/InteractiveCampusMap';
import { RoomZone, SCHOOL_FLOORS } from '@/data/mockSchoolMapData';
import { triggerHaptic } from '@/utils/haptics';

interface CampusMapPageProps {
  onBack?: () => void;
}

export const CampusMapPage: React.FC<CampusMapPageProps> = ({ onBack }) => {
  const [selectedSpot, setSelectedSpot] = useState<RoomZone | null>(
    SCHOOL_FLOORS[0].rooms[0]
  );
  const [confirmedSpot, setConfirmedSpot] = useState<RoomZone | null>(null);

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
    setConfirmedSpot(room);
  };

  return (
    <div className="min-h-screen bg-white text-slate-900 font-gt-standard pb-24 max-w-[590px] mx-auto overflow-x-hidden animate-in fade-in duration-200">
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
            Interactive Campus Map 🗺️
          </p>
        </div>

        {/* Right: Badge Indicator */}
        <div className="w-9 h-9 flex items-center justify-center">
          <Compass className="w-5 h-5 text-[#3d38f5] stroke-[2]" />
        </div>
      </header>

      {/* 2. Main Content Container */}
      <div className="p-3.5 space-y-4">
        {/* Helper Hint Banner */}
        <div className="bg-[#eef0ff] border border-[#d8dbfe] rounded-2xl p-3.5 flex items-start gap-3 shadow-2xs">
          <div className="w-8 h-8 rounded-xl bg-[#3d38f5] text-white flex items-center justify-center shrink-0 shadow-2xs mt-0.5">
            <Sparkles className="w-4 h-4" />
          </div>
          <div className="flex-1 min-w-0">
            <h4 className="font-bold text-[13.5px] text-[#3d38f5] leading-snug">
              Petunjuk Interaksi Denah
            </h4>
            <p className="text-[12px] text-slate-600 font-normal leading-relaxed mt-0.5">
              Geser untuk menjelajah, ketuk ruangan untuk melihat info, dan ubah lantai via tombol <strong>Lt 1 / Lt 2 / Lt 3</strong> di kanan atas.
            </p>
          </div>
        </div>

        {/* 3. The Core Interactive 2D Campus Map Engine */}
        <InteractiveCampusMap
          onSelectLocation={handleSelectSpot}
          selectedLocationId={selectedSpot?.id}
        />

        {/* 4. Confirmed Status Alert (If selected) */}
        {confirmedSpot && (
          <div className="bg-emerald-50 border border-emerald-200 rounded-2xl p-3.5 flex items-center gap-3 animate-in fade-in zoom-in-95 duration-150">
            <div className="w-8 h-8 rounded-full bg-emerald-500 text-white flex items-center justify-center shrink-0">
              <Check className="w-4.5 h-4.5 stroke-[2.5]" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[11.5px] font-bold text-emerald-800 uppercase tracking-wider">
                Titik COD Terkunci
              </p>
              <p className="text-[13.5px] font-bold text-slate-900 truncate">
                {confirmedSpot.name} (Lantai {confirmedSpot.floor})
              </p>
            </div>
          </div>
        )}

        {/* 5. Daftar Titik COD Terpopuler (Quick Jump List) */}
        <div className="bg-neutral-50/70 border border-neutral-200/80 rounded-2xl p-4 space-y-3 shadow-2xs">
          <div className="flex items-center gap-2">
            <Handshake className="w-4 h-4 text-[#3d38f5] stroke-[2.2]" />
            <h3 className="font-bold text-[14px] text-slate-900">
              Titik Temu COD Paling Populer
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
            {SCHOOL_FLOORS.flatMap((f) => f.rooms)
              .filter((r) => r.isPopularCodSpot)
              .map((spot) => (
                <button
                  key={spot.id}
                  type="button"
                  onClick={() => handleSelectSpot(spot)}
                  className={`p-3 rounded-xl border text-left transition-all cursor-pointer ${
                    selectedSpot?.id === spot.id
                      ? 'bg-[#eef0ff] border-[#3d38f5] shadow-2xs'
                      : 'bg-white border-neutral-200/80 hover:bg-neutral-50 active:scale-98'
                  }`}
                >
                  <div className="flex items-center justify-between gap-1 mb-1">
                    <span className="text-[10.5px] font-bold px-2 py-0.5 rounded-md bg-neutral-100 text-neutral-600">
                      Lt. {spot.floor}
                    </span>
                    <span className="text-[11px] font-semibold text-[#3d38f5]">
                      {spot.categoryLabel}
                    </span>
                  </div>
                  <h4 className="font-bold text-[13px] text-slate-900 truncate">
                    {spot.name}
                  </h4>
                  <p className="text-[11.5px] text-slate-500 font-normal line-clamp-1 mt-0.5">
                    {spot.hint}
                  </p>
                </button>
              ))}
          </div>
        </div>
      </div>
    </div>
  );
};
