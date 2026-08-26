import React from 'react';
import { X, Trash2 } from 'lucide-react';
import { TopicOption } from './types';

export interface SavedDraftData {
  caption?: string;
  images?: string[];
  selectedTopic?: TopicOption | null;
  timestamp?: number;
}
export interface CreatePostDraftsSheetProps {
  isOpen: boolean;
  onClose: () => void;
  savedDraft: SavedDraftData | null;
  onSelectDraft: (draft: SavedDraftData) => void;
  onRequestDeleteDraft: () => void;
}

export const CreatePostDraftsSheet: React.FC<CreatePostDraftsSheetProps> = ({
  isOpen,
  onClose,
  savedDraft,
  onSelectDraft,
  onRequestDeleteDraft,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-xs">
      <div className="w-full max-w-md bg-white rounded-t-3xl sm:rounded-3xl p-5 shadow-2xl border border-neutral-100 space-y-4 font-gt-standard max-h-[80vh] overflow-y-auto">
        <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
          <h3 className="text-[16px] font-bold text-slate-900">Draf Tersimpan</h3>
          <button
            type="button"
            onClick={onClose}
            className="p-1 rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-slate-800 cursor-pointer"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {savedDraft ? (
          <div className="p-3.5 rounded-2xl bg-neutral-50 border border-neutral-200 flex items-center justify-between gap-3">
            <div
              className="flex-1 min-w-0 cursor-pointer"
              onClick={() => onSelectDraft(savedDraft)}
            >
              <p className="text-[13.5px] font-semibold text-slate-900 truncate">
                {savedDraft.caption || 'Draf tanpa judul'}
              </p>
              <p className="text-[11.5px] text-neutral-400">
                Disimpan {new Date(savedDraft.timestamp || Date.now()).toLocaleTimeString()}
              </p>
            </div>

            <button
              type="button"
              onClick={onRequestDeleteDraft}
              className="p-2 text-rose-500 hover:bg-rose-50 rounded-xl transition-colors cursor-pointer"
              title="Hapus Draf"
            >
              <Trash2 className="w-4 h-4" />
            </button>
          </div>
        ) : (
          <div className="py-8 text-center text-neutral-400 text-sm">
            Belum ada draf yang disimpan.
          </div>
        )}
      </div>
    </div>
  );
};
