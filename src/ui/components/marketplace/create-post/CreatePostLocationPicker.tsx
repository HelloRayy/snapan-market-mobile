import React from 'react';
import { ArrowLeft, Search, X, Navigation, MapPin, ChevronRight } from 'lucide-react';
import { SchoolPlace } from './types';

export interface CreatePostLocationPickerProps {
  onBack: () => void;
  searchQuery: string;
  onSearchChange: (query: string) => void;
  onSelectLocation: (location: string) => void;
  filteredPlaces: SchoolPlace[];
}

export const CreatePostLocationPicker: React.FC<CreatePostLocationPickerProps> = ({
  onBack,
  searchQuery,
  onSearchChange,
  onSelectLocation,
  filteredPlaces,
}) => {
  return (
    <div className="flex-1 flex flex-col bg-white overflow-hidden animate-in fade-in duration-200">
      {/* Header (Grid layout: [Kembali] --- [Pilih tempat] --- [Spacer]) */}
      <div className="grid grid-cols-[48px_1fr_48px] items-center text-slate-900 border-b border-neutral-100 h-14 px-3 leading-snug shrink-0">
        <button
          type="button"
          onClick={onBack}
          className="flex items-center justify-center h-8 w-8 rounded-full hover:bg-neutral-100 text-slate-700 transition-colors cursor-pointer"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
        </button>
        <h1 className="font-bold text-center text-[16px] text-slate-900 leading-snug">
          Pilih tempat
        </h1>
        <div className="w-6" />
      </div>

      {/* Searchbar & "Sekitar Sini" (GPS Navigation Button) */}
      <div className="flex items-center gap-x-2.5 pt-3 px-4 leading-snug">
        <div className="flex-1 flex items-center gap-2 py-2 px-3.5 bg-neutral-100/90 rounded-2xl border border-neutral-200/80 leading-snug focus-within:border-[#1d64ec] focus-within:bg-white transition-all">
          <Search className="w-4 h-4 text-slate-500 shrink-0" />
          <input
            type="text"
            autoFocus
            placeholder="Cari tempat atau ketik lokasi..."
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            className="w-full text-[14px] text-slate-900 placeholder:text-slate-400 bg-transparent focus:outline-none leading-snug"
          />
          {searchQuery && (
            <button
              type="button"
              onClick={() => onSearchChange('')}
              className="text-slate-400 hover:text-slate-700"
            >
              <X className="w-3.5 h-3.5" />
            </button>
          )}
        </div>

        <button
          type="button"
          onClick={() => {
            onSelectLocation('📍 Sekitar SMKN 8 Semarang');
          }}
          className="flex items-center justify-center h-10 w-10 rounded-2xl bg-neutral-100 hover:bg-neutral-200/80 text-slate-800 transition-colors cursor-pointer shrink-0"
          title="Gunakan lokasi saat ini (Sekitar sini)"
        >
          <Navigation className="w-4.5 h-4.5 stroke-[2] text-[#1d64ec]" />
        </button>
      </div>

      {/* Place Results & Suggestions List */}
      <div data-lenis-prevent className="flex-1 overflow-y-auto px-4 py-3 leading-snug scrollbar-none touch-pan-y">
        {/* Custom Input Option if user typed something */}
        {searchQuery.trim() && (
          <button
            type="button"
            onClick={() => {
              onSelectLocation(`📍 ${searchQuery.trim()}`);
            }}
            className="w-full flex items-center justify-between py-3 px-3.5 mb-2.5 rounded-2xl bg-blue-50/80 hover:bg-blue-100/70 border border-blue-200/80 text-left transition-colors cursor-pointer shadow-2xs"
          >
            <div className="flex items-center gap-3 min-w-0">
              <div className="w-8 h-8 rounded-xl bg-[#1d64ec] text-white flex items-center justify-center shrink-0">
                <MapPin className="w-4 h-4 stroke-[2.2]" />
              </div>
              <div className="min-w-0">
                <p className="text-[14px] font-bold text-[#1d64ec] truncate">
                  Gunakan "{searchQuery.trim()}"
                </p>
                <p className="text-[11.5px] text-blue-600/80 truncate">
                  Tambahkan sebagai lokasi baru
                </p>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-[#1d64ec] shrink-0" />
          </button>
        )}

        <div className="text-[11.5px] font-bold text-slate-500 uppercase tracking-wider px-1 mb-2">
          Rekomendasi Titik Temu SMKN 8
        </div>

        <ul className="divide-y divide-neutral-100 bg-white rounded-2xl border border-neutral-100 shadow-2xs overflow-hidden">
          {filteredPlaces.map((place) => (
            <li key={place.id}>
              <button
                type="button"
                onClick={() => {
                  onSelectLocation(place.name);
                }}
                className="w-full flex items-center justify-between py-3 px-3.5 hover:bg-neutral-50 active:bg-neutral-100/80 text-left transition-colors cursor-pointer group"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-8 h-8 rounded-xl bg-neutral-100 group-hover:bg-neutral-200/80 flex items-center justify-center text-slate-700 shrink-0 transition-colors">
                    <MapPin className="w-4 h-4 stroke-[2]" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-[14px] font-semibold text-slate-900 truncate group-hover:text-[#1d64ec] transition-colors">
                      {place.name}
                    </p>
                    <p className="text-[12px] text-slate-500 truncate">
                      {place.subtitle}
                    </p>
                  </div>
                </div>

                <span className="text-[11.5px] text-slate-500 font-semibold shrink-0 ml-2">
                  {place.distance}
                </span>
              </button>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};
