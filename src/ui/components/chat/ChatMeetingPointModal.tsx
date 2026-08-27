import React, { useState } from 'react';
import { MapPin, X, Check, Clock } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface ChatMeetingPointModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmitMeetingPoint: (spotName: string, timeLabel: string, zoneId?: string) => void;
}

const POPULAR_SPOTS = [
  { id: 'kantin-utama', name: 'Kantin Utama (Gazebo Barat)', hint: 'Paling ramai saat istirahat' },
  { id: 'lobi-utama', name: 'Lobi Depan Gedung A', hint: 'Dekat pintu gerbang utama' },
  { id: 'gazebo-tengah', name: 'Gazebo Lapangan Tengah', hint: 'Area santai luar ruangan' },
  { id: 'lab-pplg-1', name: 'Depan Lab PPLG / Komputer 1', hint: 'Lantai 2 Gedung Vokasi' },
];

const TIME_SLOTS = [
  'Istirahat ke-1 (09.45 - 10.15)',
  'Istirahat ke-2 (12.00 - 12.30)',
  'Setelah Pulang Sekolah (15.30)',
];

export const ChatMeetingPointModal: React.FC<ChatMeetingPointModalProps> = ({
  isOpen,
  onClose,
  onSubmitMeetingPoint,
}) => {
  const [selectedSpot, setSelectedSpot] = useState(POPULAR_SPOTS[0]);
  const [selectedTime, setSelectedTime] = useState(TIME_SLOTS[1]);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    triggerHaptic('success');
    onSubmitMeetingPoint(selectedSpot.name, selectedTime, selectedSpot.id);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-md bg-white rounded-t-[28px] sm:rounded-3xl p-5 shadow-2xl border border-neutral-200 animate-in slide-in-from-bottom-4 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-3 border-b border-neutral-100">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-blue-100 text-[#1d64ec] flex items-center justify-center">
              <MapPin className="w-4 h-4" />
            </div>
            <div>
              <h3 className="font-bold text-[15px] text-slate-900 leading-tight">
                Pilih Titik Temu COD
              </h3>
              <p className="text-[11.5px] text-neutral-500">SMK Negeri 8 Semarang</p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-neutral-100 flex items-center justify-center text-neutral-400 hover:text-slate-700 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="pt-4 space-y-4">
          {/* Location Picker */}
          <div>
            <label className="block text-[12px] font-bold text-slate-900 mb-2">
              Lokasi Titik Temu Sekolah
            </label>
            <div className="space-y-1.5">
              {POPULAR_SPOTS.map((spot) => {
                const isSelected = selectedSpot.id === spot.id;
                return (
                  <div
                    key={spot.id}
                    onClick={() => {
                      triggerHaptic('selection');
                      setSelectedSpot(spot);
                    }}
                    className={`p-3 rounded-2xl border transition-all cursor-pointer flex items-center justify-between gap-2 ${
                      isSelected
                        ? 'border-[#1d64ec] bg-blue-50/70 ring-1 ring-[#1d64ec]'
                        : 'border-neutral-200 bg-neutral-50 hover:bg-neutral-100/70'
                    }`}
                  >
                    <div>
                      <p
                        className={`text-[13.5px] font-bold ${
                          isSelected ? 'text-[#1d64ec]' : 'text-slate-900'
                        }`}
                      >
                        {spot.name}
                      </p>
                      <p className="text-[11px] text-neutral-500 mt-0.5">{spot.hint}</p>
                    </div>
                    {isSelected && (
                      <div className="w-5 h-5 rounded-full bg-[#1d64ec] text-white flex items-center justify-center shrink-0">
                        <Check className="w-3.5 h-3.5 stroke-[3]" />
                      </div>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Time Picker */}
          <div>
            <label className="block text-[12px] font-bold text-slate-900 mb-2">
              Waktu Janji COD
            </label>
            <div className="space-y-1.5">
              {TIME_SLOTS.map((slot) => {
                const isSelected = selectedTime === slot;
                return (
                  <button
                    key={slot}
                    type="button"
                    onClick={() => {
                      triggerHaptic('selection');
                      setSelectedTime(slot);
                    }}
                    className={`w-full text-left p-2.5 rounded-xl border text-[12.5px] font-semibold transition-all flex items-center justify-between ${
                      isSelected
                        ? 'border-[#1d64ec] bg-blue-50/70 text-[#1d64ec]'
                        : 'border-neutral-200 text-slate-700 hover:bg-neutral-50'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <Clock className="w-3.5 h-3.5" />
                      <span>{slot}</span>
                    </div>
                    {isSelected && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full py-3.5 rounded-2xl bg-[#1d64ec] hover:bg-[#154ec1] active:scale-[0.98] text-white font-bold text-[14.5px] shadow-md shadow-blue-500/25 flex items-center justify-center gap-2 transition-all cursor-pointer"
          >
            <MapPin className="w-4 h-4 stroke-[2.5]" />
            <span>Kirim Jadwal Titik Temu</span>
          </button>
        </form>
      </div>
    </div>
  );
};
