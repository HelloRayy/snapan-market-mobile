import React from 'react';

export interface CreatePostFooterProps {
  onSubmit: () => void;
  canPost: boolean;
}

export const CreatePostFooter: React.FC<CreatePostFooterProps> = ({ onSubmit, canPost }) => {
  return (
    <div
      className="fixed bottom-0 inset-x-0 bg-white/95 backdrop-blur-md border-t border-neutral-200/80 px-4 py-3 z-30 flex items-center justify-between max-w-lg mx-auto shadow-lg"
      style={{ paddingBottom: 'max(12px, env(safe-area-inset-bottom, 12px))' }}
    >
      <span className="text-[13px] text-neutral-500 font-normal">
        Siapa pun dapat membalas & mengutip
      </span>

      <button
        type="button"
        onClick={onSubmit}
        disabled={!canPost}
        className={`h-9 px-5 rounded-full font-bold text-[14px] transition-all cursor-pointer shadow-md ${
          canPost
            ? 'bg-[#101010] hover:bg-black text-white active:scale-95 shadow-black/10'
            : 'bg-neutral-100 text-neutral-400 cursor-not-allowed shadow-none'
        }`}
      >
        Posting
      </button>
    </div>
  );
};
