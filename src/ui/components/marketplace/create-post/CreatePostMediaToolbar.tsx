import React from 'react';
import {
  Image as ImageIcon,
  Smile,
  BarChart2,
  MapPin,
  Music,
} from 'lucide-react';
import { ThreadsTopicIcon } from '@/ui/components/icons';
import { TopicOption, PRESET_EMOJIS, PRESET_GIFS } from './types';

export interface CreatePostMediaToolbarProps {
  hasImages: boolean;
  onAddImage: () => void;
  showGifPicker: boolean;
  onToggleGifPicker: () => void;
  selectedGif: string | null;
  onSelectGif: (url: string) => void;
  showEmojiBar: boolean;
  onToggleEmojiBar: () => void;
  onInsertEmoji: (emoji: string) => void;
  showPollBuilder: boolean;
  onTogglePollBuilder: () => void;
  showTopicDropdown: boolean;
  onToggleTopicDropdown: () => void;
  selectedTopic: TopicOption | null;
  onOpenLocationPicker: () => void;
  selectedLocation: string | null;
  showVoiceNote: boolean;
  onToggleVoiceNote: () => void;
  postMode: 'thread' | 'product';
  onTogglePostMode: () => void;
}

export const CreatePostMediaToolbar: React.FC<CreatePostMediaToolbarProps> = ({
  hasImages,
  onAddImage,
  showGifPicker,
  onToggleGifPicker,
  selectedGif,
  onSelectGif,
  showEmojiBar,
  onToggleEmojiBar,
  onInsertEmoji,
  showPollBuilder,
  onTogglePollBuilder,
  showTopicDropdown,
  onToggleTopicDropdown,
  selectedTopic,
  onOpenLocationPicker,
  selectedLocation,
  showVoiceNote,
  onToggleVoiceNote,
  postMode,
  onTogglePostMode,
}) => {
  return (
    <>
      {/* Quick Emoji Carousel Bar */}
      {showEmojiBar && (
        <div className="flex items-center gap-2 py-1.5 overflow-x-auto scrollbar-none animate-toast-pop select-none">
          {PRESET_EMOJIS.map((em, idx) => (
            <button
              key={idx}
              type="button"
              onClick={() => onInsertEmoji(em)}
              className="w-8 h-8 rounded-xl bg-neutral-100 hover:bg-neutral-200/80 active:scale-90 flex items-center justify-center text-lg transition-transform cursor-pointer shrink-0"
            >
              {em}
            </button>
          ))}
        </div>
      )}

      {/* Quick GIF Selector Carousel */}
      {showGifPicker && (
        <div className="py-2 space-y-1.5 animate-toast-pop select-none">
          <div className="text-[11px] font-bold text-neutral-400 uppercase tracking-wider px-1">
            Pilih GIF Reaksi
          </div>
          <div className="flex items-center gap-2 overflow-x-auto scrollbar-none py-0.5">
            {PRESET_GIFS.map((gif) => (
              <button
                key={gif.id}
                type="button"
                onClick={() => onSelectGif(gif.url)}
                className="relative w-20 h-16 rounded-xl overflow-hidden border border-neutral-200 hover:border-[#1d64ec] shrink-0 group cursor-pointer transition-all"
              >
                <img src={gif.url} alt={gif.title} className="w-full h-full object-cover" />
                <span className="absolute inset-x-0 bottom-0 bg-black/60 text-white text-[9px] font-semibold truncate px-1 py-0.5 text-center">
                  {gif.title}
                </span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Pure Meta Threads 7-Icon Action Toolbar */}
      <div className="flex items-center justify-between flex-wrap gap-2 pt-2.5 select-none">
        {/* 7 Meta Threads Action Icons */}
        <div className="flex items-center gap-1">
          {/* 1. Galeri / Foto */}
          <button
            type="button"
            onClick={onAddImage}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              hasImages
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Unggah Foto"
          >
            <ImageIcon className="w-4.5 h-4.5 stroke-[2]" />
          </button>

          {/* 2. GIF Picker */}
          <button
            type="button"
            onClick={onToggleGifPicker}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              selectedGif || showGifPicker
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Sisipkan GIF"
          >
            <span className="text-[11px] font-bold px-1 py-0.5 rounded border border-current leading-none">
              GIF
            </span>
          </button>

          {/* 3. Emoji Picker */}
          <button
            type="button"
            onClick={onToggleEmojiBar}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              showEmojiBar
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Sisipkan Emoji"
          >
            <Smile className="w-4.5 h-4.5 stroke-[2]" />
          </button>

          {/* 4. Polling / Jajak Pendapat */}
          <button
            type="button"
            onClick={onTogglePollBuilder}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              showPollBuilder
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Buat Jajak Pendapat / Polling"
          >
            <BarChart2 className="w-4.5 h-4.5 stroke-[2]" />
          </button>

          {/* 5. Topic Tagging (Threads 3-Dot Topic) */}
          <button
            type="button"
            onClick={onToggleTopicDropdown}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              selectedTopic || showTopicDropdown
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Pilih Topik"
          >
            <ThreadsTopicIcon className="w-4 h-4 text-current fill-current" />
          </button>

          {/* 6. Tag Lokasi Sekolah -> Opens Dedicated "Pilih tempat" Screen */}
          <button
            type="button"
            onClick={onOpenLocationPicker}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              selectedLocation
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Pilih Tempat / Lokasi COD Sekolah"
          >
            <MapPin className="w-4.5 h-4.5 stroke-[2]" />
          </button>

          {/* 7. Voice Note / Audio */}
          <button
            type="button"
            onClick={onToggleVoiceNote}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
              showVoiceNote
                ? 'bg-blue-50 text-[#1d64ec]'
                : 'text-slate-600 hover:text-slate-900 hover:bg-neutral-100'
            }`}
            title="Rekaman Suara / Audio"
          >
            <Music className="w-4.5 h-4.5 stroke-[2]" />
          </button>
        </div>

        {/* Mode "Jual Barang" Toggle Switch Pill */}
        <div
          onClick={onTogglePostMode}
          className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border transition-all cursor-pointer select-none active:scale-95 ${
            postMode === 'product'
              ? 'bg-blue-50/90 border-blue-200 text-[#1d64ec] font-bold shadow-2xs'
              : 'bg-neutral-100/90 hover:bg-neutral-200/80 border-neutral-200/80 text-slate-800 font-semibold'
          }`}
        >
          <div
            className={`w-7.5 h-4 rounded-full p-0.5 transition-colors duration-200 flex items-center shrink-0 ${
              postMode === 'product' ? 'bg-[#1d64ec]' : 'bg-neutral-300'
            }`}
          >
            <div
              className={`w-3 h-3 rounded-full bg-white shadow-xs transition-transform duration-200 transform-gpu ${
                postMode === 'product' ? 'translate-x-3.5' : 'translate-x-0'
              }`}
            />
          </div>
          <span className="text-[12px] leading-none">Jual Barang</span>
        </div>
      </div>
    </>
  );
};
