import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, FileText, MoreHorizontal, Image as ImageIcon, MapPin, Tag, PartyPopper } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';

// Custom Threads 3-Dot Topic Icon
const ThreadsTopicIcon: React.FC<{ className?: string }> = ({ className = "w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" }) => (
  <svg className={className} viewBox="0 0 24 24">
    <circle cx="6" cy="8" r="3" />
    <circle cx="6" cy="16" r="3" />
    <circle cx="15" cy="12" r="3" />
  </svg>
);

interface TopicOption {
  id: string;
  name: string;
  isOfficial: boolean;
  icon?: 'threads' | 'party-popper';
  subtitle?: string;
}

const PRESET_TOPICS: TopicOption[] = [
  { id: 't-1', name: 'frontend', isOfficial: true, icon: 'threads', subtitle: '1.2M anggota · 220 postingan baru' },
  { id: 't-2', name: 'PJBL', isOfficial: true, icon: 'party-popper', subtitle: 'Project Based Learning SMKN 8' },
  { id: 't-3', name: 'JajananKantin', isOfficial: true, icon: 'threads', subtitle: 'Kantin Sekolah & Snack' },
  { id: 't-4', name: 'Github', isOfficial: false, subtitle: '92 postingan baru' },
  { id: 't-5', name: 'PrelovedOutfit', isOfficial: false, subtitle: '136 postingan baru' },
];

interface CreatePostModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmitPost?: (newPost: Partial<MarketPostItem>) => void;
  currentUser?: {
    name: string;
    avatar: string;
    username: string;
  };
}

export const CreatePostModal: React.FC<CreatePostModalProps> = ({
  isOpen,
  onClose,
  onSubmitPost,
  currentUser = {
    name: 'radityarayhannnn',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    username: 'radityarayhannnn',
  },
}) => {
  const [caption, setCaption] = useState('');
  const [images, setImages] = useState<string[]>([]);
  const [selectedTopic, setSelectedTopic] = useState<TopicOption | null>(null);
  const [customTopicInput, setCustomTopicInput] = useState('');
  const [showTopicDropdown, setShowTopicDropdown] = useState(false);
  const [price] = useState<number>(50000);
  const [stock] = useState<number>(1);
  const [locationTag] = useState('Gedung PPLG');

  const handleAddDummyImage = () => {
    const dummyPics = [
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
      'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80',
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    ];
    const nextPic = dummyPics[images.length % dummyPics.length];
    setImages([...images, nextPic]);
  };

  const handleRemoveImage = (index: number) => {
    setImages(images.filter((_, i) => i !== index));
  };

  const handleSelectTopic = (topic: TopicOption) => {
    setSelectedTopic(topic);
    setShowTopicDropdown(false);
  };

  const handleCustomTopicSubmit = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && customTopicInput.trim()) {
      setSelectedTopic({
        id: `custom-${Date.now()}`,
        name: customTopicInput.trim(),
        isOfficial: false,
      });
      setCustomTopicInput('');
      setShowTopicDropdown(false);
    }
  };

  const canPost = caption.trim().length > 0 || images.length > 0;

  const handleSubmit = () => {
    if (!canPost) return;

    const newPost: Partial<MarketPostItem> = {
      caption,
      images,
      price: price || 50000,
      stock: stock || 1,
      locationTag: locationTag || 'Lab PPLG',
      topicTag: selectedTopic ? selectedTopic.name : undefined,
      isOfficialTopic: selectedTopic ? selectedTopic.isOfficial : false,
      topicIcon: selectedTopic?.icon || (selectedTopic?.isOfficial ? 'threads' : undefined),
    };

    onSubmitPost?.(newPost);
    // Reset form state
    setCaption('');
    setImages([]);
    setSelectedTopic(null);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-end justify-center sm:items-center bg-black/60 backdrop-blur-xs transition-opacity duration-200">
        <motion.div
          initial={{ y: '100%', opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: '100%', opacity: 0 }}
          transition={{ type: 'spring', stiffness: 320, damping: 30 }}
          className="w-full max-w-xl bg-white rounded-t-3xl sm:rounded-3xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col font-gt-standard border border-neutral-200"
        >
          {/* Top Bar Header: [ Batal ] --- [ Thread Baru ] --- [ Draft & Options ] */}
          <div className="px-4 h-14 flex items-center justify-between border-b border-neutral-200/80 bg-white shrink-0">
            <button
              type="button"
              onClick={onClose}
              className="text-[15px] font-normal text-slate-900 hover:opacity-75 active:scale-95 transition-all cursor-pointer"
            >
              Batal
            </button>

            <h2 className="text-[16px] font-bold text-slate-900 select-none">
              Thread Baru
            </h2>

            <div className="flex items-center gap-3">
              <button
                type="button"
                className="text-slate-600 hover:text-slate-900 transition-colors p-1"
                title="Draft"
              >
                <FileText className="w-5 h-5 stroke-[1.8]" />
              </button>
              <button
                type="button"
                className="text-slate-600 hover:text-slate-900 transition-colors p-1"
                title="Opsi"
              >
                <MoreHorizontal className="w-5 h-5 stroke-[1.8]" />
              </button>
            </div>
          </div>

          {/* Form Scrollable Body */}
          <div className="p-4 overflow-y-auto flex-1 space-y-3 relative">
            {/* Author Row + Dynamic Topic Selector */}
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0">
                <img
                  src={currentUser.avatar}
                  alt={currentUser.name}
                  className="w-full h-full object-cover"
                />
              </div>

              <div className="flex-1 min-w-0 pt-0.5">
                {/* Username + Inline Topic Selector */}
                <div className="flex items-center gap-1.5 flex-wrap relative">
                  <span className="font-semibold text-[15.5px] text-slate-900">
                    {currentUser.username}
                  </span>

                  {/* Topic Selector Button */}
                  <div className="relative inline-block">
                    <button
                      type="button"
                      onClick={() => setShowTopicDropdown(!showTopicDropdown)}
                      className={`flex items-center gap-1 text-[14px] font-normal rounded-lg px-1.5 py-0.5 transition-all cursor-pointer ${
                        selectedTopic
                          ? selectedTopic.isOfficial
                            ? 'bg-blue-50 text-[#1d64ec] font-bold'
                            : 'bg-neutral-100 text-slate-900 font-bold'
                          : 'text-neutral-400 hover:bg-neutral-100 hover:text-slate-600'
                      }`}
                    >
                      <span className="text-neutral-400">›</span>
                      {selectedTopic ? (
                        <>
                          {selectedTopic.isOfficial && (
                            selectedTopic.icon === 'party-popper' ? (
                              <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                            ) : (
                              <ThreadsTopicIcon />
                            )
                          )}
                          <span>{selectedTopic.name}</span>
                        </>
                      ) : (
                        <span>Community or topic</span>
                      )}
                    </button>

                    {/* Dropdown Popover Overlay (Persis Screenshot 2!) */}
                    {showTopicDropdown && (
                      <div className="absolute top-full left-0 mt-1 w-64 bg-white rounded-2xl shadow-xl border border-neutral-200 z-50 p-2 animate-in fade-in slide-in-from-top-2 duration-150">
                        <div className="px-3 py-1.5 text-[11px] font-bold text-neutral-400 uppercase tracking-wider">
                          Recent / Populer
                        </div>

                        <div className="space-y-0.5">
                          {PRESET_TOPICS.map((topic) => (
                            <button
                              key={topic.id}
                              type="button"
                              onClick={() => handleSelectTopic(topic)}
                              className="w-full text-left px-3 py-2 rounded-xl hover:bg-neutral-100/90 transition-colors flex items-center justify-between group cursor-pointer"
                            >
                              <div className="flex items-center gap-2 min-w-0">
                                {topic.isOfficial && (
                                  topic.icon === 'party-popper' ? (
                                    <PartyPopper className="w-4 h-4 text-[#1d64ec] stroke-[2.2] shrink-0" />
                                  ) : (
                                    <ThreadsTopicIcon className="w-4 h-4 text-[#1d64ec] fill-current shrink-0" />
                                  )
                                )}
                                <div>
                                  <div className={`text-[14px] font-semibold ${topic.isOfficial ? 'text-[#1d64ec]' : 'text-slate-900'}`}>
                                    {topic.name}
                                  </div>
                                  {topic.subtitle && (
                                    <div className="text-[11.5px] text-neutral-400 font-normal truncate">
                                      {topic.subtitle}
                                    </div>
                                  )}
                                </div>
                              </div>
                            </button>
                          ))}
                        </div>

                        {/* Custom Topic Input */}
                        <div className="mt-2 pt-2 border-t border-neutral-100 px-2">
                          <input
                            type="text"
                            placeholder="Ketik topik kustom + Enter..."
                            value={customTopicInput}
                            onChange={(e) => setCustomTopicInput(e.target.value)}
                            onKeyDown={handleCustomTopicSubmit}
                            className="w-full px-3 py-1.5 text-[13px] rounded-lg border border-neutral-200 focus:outline-none focus:border-blue-500 bg-neutral-50"
                          />
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                {/* Caption Textarea (Auto-expand feeling) */}
                <textarea
                  autoFocus
                  rows={3}
                  placeholder="Apa yang baru? Apa yang ingin kamu jual?"
                  value={caption}
                  onChange={(e) => setCaption(e.target.value)}
                  className="w-full mt-2 text-[15px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none bg-transparent leading-relaxed"
                />

                {/* Uploaded Images Gallery (Persis Screenshot 3!) */}
                {images.length > 0 && (
                  <div className="flex items-center gap-2.5 overflow-x-auto py-2 scrollbar-none">
                    {images.map((imgUrl, idx) => (
                      <div key={idx} className="relative w-28 h-28 rounded-2xl overflow-hidden border border-neutral-200 shadow-2xs group shrink-0">
                        <img
                          src={imgUrl}
                          alt={`Upload preview ${idx + 1}`}
                          className="w-full h-full object-cover"
                        />
                        {/* Delete Badge '✕' */}
                        <button
                          type="button"
                          onClick={() => handleRemoveImage(idx)}
                          className="absolute top-1.5 right-1.5 w-6 h-6 rounded-full bg-black/60 hover:bg-black text-white flex items-center justify-center backdrop-blur-xs transition-transform active:scale-90 cursor-pointer"
                        >
                          <X className="w-3.5 h-3.5 stroke-[2.5]" />
                        </button>
                      </div>
                    ))}

                    {/* Add Image Card Button */}
                    <button
                      type="button"
                      onClick={handleAddDummyImage}
                      className="w-28 h-28 rounded-2xl border-2 border-dashed border-neutral-300 hover:border-blue-500 bg-neutral-50 hover:bg-blue-50/30 flex flex-col items-center justify-center gap-1 text-neutral-400 hover:text-[#1d64ec] transition-colors shrink-0 cursor-pointer"
                    >
                      <ImageIcon className="w-6 h-6 stroke-[1.8]" />
                      <span className="text-[12px] font-semibold">+ Tambah</span>
                    </button>
                  </div>
                )}

                {/* Action Icons Bar (Image, Price/Stock, Location) */}
                <div className="flex items-center gap-4 pt-2 text-neutral-400">
                  <button
                    type="button"
                    onClick={handleAddDummyImage}
                    className="p-1 hover:text-slate-800 transition-colors cursor-pointer"
                    title="Tambah Foto Produk"
                  >
                    <ImageIcon className="w-5 h-5 stroke-[1.8]" />
                  </button>

                  <div className="flex items-center gap-1.5 text-[12px] text-slate-700 bg-neutral-100 px-2.5 py-1 rounded-full">
                    <Tag className="w-3.5 h-3.5 text-slate-500" />
                    <span>Rp {price ? price.toLocaleString('id-ID') : '50.000'}</span>
                  </div>

                  <div className="flex items-center gap-1.5 text-[12px] text-slate-700 bg-neutral-100 px-2.5 py-1 rounded-full">
                    <MapPin className="w-3.5 h-3.5 text-slate-500" />
                    <span>{locationTag}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Bottom Footer: [ Post Options ] --- [ Post Button ] */}
          <div className="px-4 py-3 border-t border-neutral-200/80 bg-white flex items-center justify-between shrink-0">
            <div className="text-[14px] font-medium text-slate-700 select-none">
              Opsi Postingan
            </div>

            <button
              type="button"
              onClick={handleSubmit}
              disabled={!canPost}
              className={`px-5 py-2 rounded-full font-bold text-[14.5px] transition-all duration-200 cursor-pointer ${
                canPost
                  ? 'bg-slate-900 hover:bg-slate-800 text-white shadow-md active:scale-95'
                  : 'bg-neutral-200 text-neutral-400 cursor-not-allowed'
              }`}
            >
              Post
            </button>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};
