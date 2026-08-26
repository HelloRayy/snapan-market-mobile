import React from 'react';
import { FileText, MoreHorizontal } from 'lucide-react';

export interface CreatePostHeaderProps {
  postMode: 'thread' | 'product';
  onCancel: () => void;
  onOpenDrafts: () => void;
  hasSavedDraft: boolean;
}

export const CreatePostHeader: React.FC<CreatePostHeaderProps> = ({
  postMode,
  onCancel,
  onOpenDrafts,
  hasSavedDraft,
}) => {
  return (
    <div className="relative px-4 h-14 flex items-center justify-between border-b border-neutral-200/80 bg-white shrink-0">
      <button
        type="button"
        onClick={onCancel}
        className="text-[15px] font-medium text-slate-900 hover:opacity-75 active:scale-95 transition-all cursor-pointer z-10"
      >
        Batal
      </button>

      {/* Absolute Dead Center to Screen */}
      <div className="absolute left-1/2 -translate-x-1/2 flex items-center justify-center pointer-events-none">
        <h2 className="text-[15.5px] font-bold text-slate-900 tracking-tight flex items-center gap-1.5 pointer-events-auto select-none">
          {postMode === 'product' ? (
            <span className="text-[#1d64ec]">Jual Produk</span>
          ) : (
            <span>Utas Baru</span>
          )}
        </h2>
      </div>

      <div className="flex items-center gap-2 z-10">
        {/* Draft Icon Button with Active Indicator Dot */}
        <button
          type="button"
          onClick={onOpenDrafts}
          className="relative text-slate-600 hover:text-slate-900 transition-colors p-1.5 rounded-full hover:bg-neutral-100 cursor-pointer"
          title="Lihat Draf Tersimpan"
        >
          <FileText className="w-5 h-5 stroke-[1.8]" />
          {hasSavedDraft && (
            <span className="absolute top-1 right-1 w-2.5 h-2.5 rounded-full bg-[#1d64ec] border-2 border-white" />
          )}
        </button>

        <button
          type="button"
          className="text-slate-600 hover:text-slate-900 transition-colors p-1.5 rounded-full hover:bg-neutral-100 cursor-pointer"
          title="Opsi"
        >
          <MoreHorizontal className="w-5 h-5 stroke-[1.8]" />
        </button>
      </div>
    </div>
  );
};
