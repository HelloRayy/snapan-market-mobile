import React from 'react';
import { X } from 'lucide-react';

interface CreatePostPollBuilderProps {
  pollOptions: string[];
  setPollOptions: React.Dispatch<React.SetStateAction<string[]>>;
  onClose: () => void;
}

export const CreatePostPollBuilder: React.FC<CreatePostPollBuilderProps> = ({
  pollOptions,
  setPollOptions,
  onClose,
}) => {
  const handleUpdateOption = (index: number, val: string) => {
    const next = [...pollOptions];
    next[index] = val;
    setPollOptions(next);
  };

  const handleRemoveOption = (index: number) => {
    if (pollOptions.length <= 2) return;
    setPollOptions(pollOptions.filter((_, i) => i !== index));
  };

  return (
    <div className="my-3 space-y-2 text-slate-900 text-base leading-snug transform-gpu animate-toast-pop select-none">
      <div className="flex flex-col gap-y-2 leading-snug">
        {pollOptions.map((opt, idx) => (
          <div key={idx} className="relative flex items-center">
            <input
              type="text"
              placeholder={`Opsi ${idx + 1}...`}
              value={opt}
              onChange={(e) => {
                handleUpdateOption(idx, e.target.value);
                if (
                  idx === pollOptions.length - 1 &&
                  e.target.value.trim().length > 0 &&
                  pollOptions.length < 4
                ) {
                  setPollOptions((prev) => [...prev, '']);
                }
              }}
              className="w-full p-3 bg-neutral-100 font-semibold rounded-xl border border-neutral-200/90 h-[46.6px] text-[14.5px] leading-snug text-slate-900 placeholder:text-neutral-400 focus:outline-none focus:border-[#1d64ec] focus:bg-white transition-all"
            />
            {pollOptions.length > 2 && (
              <button
                type="button"
                onClick={() => handleRemoveOption(idx)}
                className="absolute right-3 p-1 text-neutral-400 hover:text-rose-600 transition-colors cursor-pointer"
                title="Hapus opsi"
              >
                <X className="w-4 h-4 stroke-[2]" />
              </button>
            )}
          </div>
        ))}
      </div>

      {/* Footer: [Berakhir dalam 24 jam] --- [Hapus polling] */}
      <div className="flex items-center justify-between h-[21px] px-1 leading-snug select-none">
        <span className="text-neutral-400 text-xs leading-snug font-normal">
          Berakhir dalam 24 jam
        </span>
        <button
          type="button"
          onClick={() => {
            onClose();
            setPollOptions(['', '', '']);
          }}
          className="inline-flex items-center h-[16.8px] text-rose-500 hover:text-rose-600 font-semibold text-xs leading-snug cursor-pointer hover:underline"
        >
          Hapus polling
        </button>
      </div>
    </div>
  );
};
