import React from 'react';
import { X, Image as ImageIcon } from 'lucide-react';

interface SubThreadItem {
  id: string;
  caption: string;
  images: string[];
}

interface CreatePostSubThreadsListProps {
  subThreads: SubThreadItem[];
  currentUser: {
    username: string;
    avatar: string;
    name: string;
  };
  onRemoveSubThread: (id: string) => void;
  onUpdateCaption: (id: string, text: string) => void;
  onAddSubThreadImage: (id: string) => void;
  onRemoveSubThreadImage: (subThreadId: string, imgIndex: number) => void;
  onAddSubThread: () => void;
  onFocusInput: (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
}

export const CreatePostSubThreadsList: React.FC<CreatePostSubThreadsListProps> = ({
  subThreads,
  currentUser,
  onRemoveSubThread,
  onUpdateCaption,
  onAddSubThreadImage,
  onRemoveSubThreadImage,
  onAddSubThread,
  onFocusInput,
}) => {
  return (
    <>
      {subThreads.map((st, index) => (
        <div key={st.id} className="flex gap-2.5 items-start mt-2 transform-gpu animate-toast-pop">
          <div className="flex flex-col items-center shrink-0 w-8 self-stretch py-0.5">
            <div className="w-8 h-8 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0">
              <img
                src={currentUser.avatar}
                alt={currentUser.name}
                className="w-full h-full object-cover"
              />
            </div>
            <div className="w-[1.5px] bg-neutral-200 flex-1 my-1 min-h-[14px]" />
          </div>

          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-1.5 leading-none">
                <span className="font-bold text-[14.5px] text-slate-900">
                  {currentUser.username}
                </span>
                <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11.5px] tabular-nums select-none">
                  {index + 2}/{1 + subThreads.length}
                </span>
              </div>

              <button
                type="button"
                onClick={() => onRemoveSubThread(st.id)}
                className="w-6 h-6 rounded-full hover:bg-neutral-100 flex items-center justify-center text-neutral-400 hover:text-slate-800 transition-colors cursor-pointer"
                title="Hapus sambungan utas"
              >
                <X className="w-4 h-4 stroke-[2]" />
              </button>
            </div>

            <textarea
              rows={1}
              placeholder="Lanjutkan utas..."
              value={st.caption}
              onFocus={onFocusInput}
              onChange={(e) => {
                onUpdateCaption(st.id, e.target.value);
                e.target.style.height = 'auto';
                e.target.style.height = `${e.target.scrollHeight}px`;
              }}
              className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-slate-400 focus:outline-none resize-none bg-transparent leading-snug overflow-hidden"
            />

            {/* Sub-Thread Images Preview */}
            {st.images.length > 0 && (
              <div className="flex items-center gap-2 overflow-x-auto py-2 scrollbar-none">
                {st.images.map((imgUrl, imgIdx) => (
                  <div
                    key={imgIdx}
                    className="relative w-20 h-20 rounded-xl overflow-hidden border border-neutral-200 shadow-2xs group shrink-0"
                  >
                    <img
                      src={imgUrl}
                      alt={`Subthread img ${imgIdx + 1}`}
                      className="w-full h-full object-cover"
                    />
                    <button
                      type="button"
                      onClick={() => onRemoveSubThreadImage(st.id, imgIdx)}
                      className="absolute top-1 right-1 w-5 h-5 rounded-full bg-black/60 hover:bg-black text-white flex items-center justify-center cursor-pointer"
                    >
                      <X className="w-3 h-3 stroke-[2]" />
                    </button>
                  </div>
                ))}
              </div>
            )}

            {/* Sub-thread inline image attach button */}
            <div className="mt-1 flex items-center gap-2">
              <button
                type="button"
                onClick={() => onAddSubThreadImage(st.id)}
                className="inline-flex items-center gap-1 text-[12px] font-semibold text-slate-500 hover:text-[#1d64ec] transition-colors py-1 cursor-pointer"
              >
                <ImageIcon className="w-4 h-4 stroke-[1.8]" />
                <span>Tambah Foto</span>
              </button>
            </div>
          </div>
        </div>
      ))}

      {/* "Tambahkan ke utas" Bottom Trigger Button */}
      <div className="flex gap-2.5 items-center mt-3 pt-1">
        <div className="w-8 flex justify-center shrink-0">
          <div className="w-4 h-4 rounded-full overflow-hidden border border-neutral-200/80 opacity-60">
            <img
              src={currentUser.avatar}
              alt={currentUser.name}
              className="w-full h-full object-cover"
            />
          </div>
        </div>

        <button
          type="button"
          onClick={onAddSubThread}
          className="text-left text-[14px] text-slate-400 hover:text-slate-800 font-normal transition-colors cursor-pointer select-none"
        >
          Tambahkan ke utas
        </button>
      </div>
    </>
  );
};
