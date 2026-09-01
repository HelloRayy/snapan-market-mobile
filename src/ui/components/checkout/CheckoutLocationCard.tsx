import React, { useState } from 'react';
import { MapPin, Maximize2, Sparkles, ChevronRight } from 'lucide-react';
import { RoomZone, SCHOOL_BUILDING_OUTLINES } from '@/data/mockSchoolMapData';
import { Campus2DMap } from '@/ui/components/map/Campus2DMap';
import { triggerHaptic } from '@/utils/haptics';

interface CheckoutLocationCardProps {
  selectedLocation: RoomZone;
  onLocationChange: (room: RoomZone) => void;
}

export const CheckoutLocationCard: React.FC<CheckoutLocationCardProps> = ({
  selectedLocation,
  onLocationChange,
}) => {
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

  const handleOpenModal = () => {
    triggerHaptic('light');
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
  };

  const handleSelectInModal = (room: RoomZone) => {
    triggerHaptic('medium');
    onLocationChange(room);
    setIsModalOpen(false);
  };

  return (
    <>
      <div className="bg-white border border-neutral-200/85 rounded-2xl p-4 shadow-2xs space-y-3 font-gt-standard">
        {/* Card Header: Title & Expand Action */}
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-[#eef0ff] text-[#3d38f5] flex items-center justify-center shrink-0">
              <MapPin className="w-4.5 h-4.5 stroke-[2.4]" />
            </div>
            <div>
              <h3 className="font-bold text-[14.5px] text-slate-900 leading-snug">
                Titik Temu COD di Sekolah
              </h3>
              <p className="text-[11.5px] text-slate-500 font-normal">
                SMK Negeri 8 Semarang
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={handleOpenModal}
            className="flex items-center gap-1 px-2.5 py-1.5 rounded-xl bg-neutral-100 hover:bg-neutral-200/70 text-slate-700 text-[11.5px] font-bold transition-colors cursor-pointer select-none"
          >
            <Maximize2 className="w-3.5 h-3.5" />
            <span>Pilih di Denah</span>
          </button>
        </div>

        {/* Selected Spot Highlight Box */}
        <div className="bg-[#eef0ff] border border-[#d8dbfe] rounded-xl p-3 flex items-start justify-between gap-2">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5 mb-1">
              <span className="text-[10.5px] font-bold px-2 py-0.5 rounded-md bg-[#3d38f5] text-white">
                Lt. {selectedLocation.floor}
              </span>
              <span className="text-[11.5px] font-semibold text-[#3d38f5]">
                {selectedLocation.categoryLabel}
              </span>
            </div>
            <h4 className="font-bold text-[14px] text-slate-900 truncate">
              {selectedLocation.name}
            </h4>
            <p className="text-[11.5px] text-slate-600 font-normal line-clamp-1 mt-0.5">
              {selectedLocation.hint}
            </p>
          </div>

          <button
            type="button"
            onClick={handleOpenModal}
            className="w-8 h-8 rounded-full bg-white text-[#3d38f5] hover:bg-neutral-50 flex items-center justify-center shrink-0 shadow-2xs border border-[#d8dbfe] cursor-pointer"
            aria-label="Ubah Titik Temu"
          >
            <ChevronRight className="w-4.5 h-4.5 stroke-[2.4]" />
          </button>
        </div>

        {/* Embedded 2D Mini-Map Preview Container */}
        <div
          onClick={handleOpenModal}
          className="relative w-full h-[180px] sm:h-[200px] bg-[#f1f5f9] rounded-xl overflow-hidden border border-neutral-200 cursor-pointer group select-none"
        >
          {/* Static Mini SVG Blueprint Preview */}
          <svg
            viewBox="0 0 1150 880"
            className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
          >
            {/* Background Ground */}
            <rect width="1150" height="880" fill="#f1f5f9" />

            {/* Roads */}
            <rect x="0" y="0" width="85" height="880" fill="#e2e8f0" />
            <rect x="0" y="0" width="1150" height="65" fill="#e2e8f0" />

            {/* Courtyard Lawn */}
            <rect x="290" y="240" width="370" height="340" rx="16" fill="#dcfce7" />
            <rect x="330" y="270" width="290" height="180" rx="8" fill="#d1fae5" />

            {/* Buildings */}
            {SCHOOL_BUILDING_OUTLINES.map((bldg) => (
              <path
                key={bldg.id}
                d={bldg.path}
                fill="#ffffff"
                stroke="#cbd5e1"
                strokeWidth="3"
              />
            ))}

            {/* Active Selected Room */}
            <path
              d={selectedLocation.path}
              fill="#eef0ff"
              stroke="#3d38f5"
              strokeWidth="4"
            />

            {/* Active Pin Radar */}
            <g transform={`translate(${selectedLocation.pinPosition.x}, ${selectedLocation.pinPosition.y + 6})`}>
              <circle r="26" fill="none" stroke="#3d38f5" strokeWidth="3" className="animate-ping opacity-75" />
              <circle r="16" fill="#3d38f5" fillOpacity="0.25" />
              <circle r="9" fill="#3d38f5" stroke="#ffffff" strokeWidth="3" className="drop-shadow-md" />
            </g>
          </svg>

          {/* Floating Expand Prompt Overlay */}
          <div className="absolute inset-0 bg-slate-900/10 backdrop-blur-[0.5px] opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
            <span className="bg-slate-900/90 text-white text-[12px] font-bold px-3 py-1.5 rounded-full shadow-md flex items-center gap-1.5">
              <Maximize2 className="w-3.5 h-3.5" />
              <span>Ketuk untuk Buka Denah Interaktif</span>
            </span>
          </div>
        </div>

        {/* Footer Guarantee Hint */}
        <div className="flex items-center gap-1.5 text-[11.5px] text-slate-500 font-normal">
          <Sparkles className="w-3.5 h-3.5 text-[#3d38f5] shrink-0" />
          <span>Bebas ongkir COD! Janjian langsung saat jam istirahat sekolah.</span>
        </div>
      </div>

      {/* Full-Screen Interactive 2D Map Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 bg-[#f1f5f9] animate-in fade-in zoom-in-95 duration-200">
          <Campus2DMap
            onBack={handleCloseModal}
            onSelectSpot={handleSelectInModal}
          />
        </div>
      )}
    </>
  );
};
