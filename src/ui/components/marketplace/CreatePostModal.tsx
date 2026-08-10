import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, FileText, MoreHorizontal, Image as ImageIcon, MapPin, PartyPopper, AlignLeft, Music } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';

// Custom Threads 3-Dot Topic Icon
const ThreadsTopicIcon: React.FC<{ className?: string }> = ({ className = "w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" }) => (
  <svg className={className} viewBox="0 0 24 24">
    <circle cx="6" cy="8" r="3" />
    <circle cx="6" cy="16" r="3" />
    <circle cx="15" cy="12" r="3" />
  </svg>
);

// Custom Threads Document Icon with Option Dot
const ThreadsDocOptionIcon: React.FC<{ className?: string }> = ({ className = "w-[19px] h-[19px] text-neutral-400" }) => (
  <div className="relative inline-flex items-center justify-center">
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z" />
      <polyline points="14 2 14 8 20 8" />
      <line x1="8" y1="12" x2="16" y2="12" />
      <line x1="8" y1="16" x2="13" y2="16" />
    </svg>
    <span className="absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full bg-white ring-1 ring-neutral-400" />
  </div>
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
  initialMode?: 'thread' | 'product';
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
  initialMode = 'thread',
  currentUser = {
    name: 'radityarayhannnn',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    username: 'radityarayhannnn',
  },
}) => {
  const [postMode, setPostMode] = useState<'thread' | 'product'>(initialMode);
  const [caption, setCaption] = useState('');
  const [productTitle, setProductTitle] = useState('');
  const [priceInput, setPriceInput] = useState<string>('');
  const [stockInput, setStockInput] = useState<string>('');
  const [locationInput, setLocationInput] = useState<string>('');
  const [images, setImages] = useState<string[]>([]);
  const [selectedTopic, setSelectedTopic] = useState<TopicOption | null>(null);
  const [customTopicInput, setCustomTopicInput] = useState('');
  const [showTopicDropdown, setShowTopicDropdown] = useState(false);

  // Sync initialMode when modal opens
  React.useEffect(() => {
    if (isOpen) {
      setPostMode(initialMode);
    }
  }, [isOpen, initialMode]);

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

  const canPost = caption.trim().length > 0 || images.length > 0 || productTitle.trim().length > 0;

  const handleSubmit = () => {
    if (!canPost) return;

    const parsedPrice = priceInput ? parseInt(priceInput.replace(/\D/g, ''), 10) : (postMode === 'product' ? 50000 : 0);
    const parsedStock = stockInput ? parseInt(stockInput, 10) : (postMode === 'product' ? 1 : 0);

    const newPost: Partial<MarketPostItem> = {
      postType: postMode,
      title: postMode === 'product' ? (productTitle || caption.slice(0, 30)) : undefined,
      caption: caption || productTitle,
      images,
      price: parsedPrice,
      stock: parsedStock,
      locationTag: locationInput || (postMode === 'product' ? 'Lab PPLG' : undefined),
      topicTag: selectedTopic ? selectedTopic.name : undefined,
      isOfficialTopic: selectedTopic ? selectedTopic.isOfficial : false,
      topicIcon: selectedTopic?.icon || (selectedTopic?.isOfficial ? 'threads' : undefined),
    };

    onSubmitPost?.(newPost);
    // Reset form state
    setCaption('');
    setProductTitle('');
    setPriceInput('');
    setStockInput('');
    setLocationInput('');
    setImages([]);
    setSelectedTopic(null);
    setPostMode('thread');
    onClose();
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ y: '100%' }}
        animate={{ y: 0 }}
        exit={{ y: '100%' }}
        transition={{ type: 'tween', duration: 0.22, ease: [0.25, 1, 0.5, 1] }}
        className="fixed inset-0 z-50 bg-white flex flex-col font-gt-standard overflow-hidden"
      >
        {/* Top Bar Header */}
        <div className="px-4 h-14 flex items-center justify-between border-b border-neutral-200/80 bg-white shrink-0">
          <button
            type="button"
            onClick={onClose}
            className="text-[15px] font-normal text-slate-900 hover:opacity-75 active:scale-95 transition-all cursor-pointer"
          >
            Batal
          </button>

          {/* Mode Switcher Pill */}
          <div className="flex items-center bg-neutral-100 p-0.5 rounded-full border border-neutral-200/80">
            <button
              type="button"
              onClick={() => setPostMode('thread')}
              className={`px-3 py-1 rounded-full text-[12.5px] font-semibold transition-all cursor-pointer ${
                postMode === 'thread'
                  ? 'bg-white text-slate-900 shadow-2xs'
                  : 'text-neutral-500 hover:text-slate-900'
              }`}
            >
              💬 Utas
            </button>
            <button
              type="button"
              onClick={() => setPostMode('product')}
              className={`px-3 py-1 rounded-full text-[12.5px] font-semibold transition-all cursor-pointer ${
                postMode === 'product'
                  ? 'bg-[#1d64ec] text-white shadow-2xs'
                  : 'text-neutral-500 hover:text-slate-900'
              }`}
            >
              🛍️ Jual Produk
            </button>
          </div>

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
        <div className="p-4 overflow-y-auto flex-1 relative max-w-lg mx-auto w-full">
          {/* 1. Top Section: Avatar + Username + Caption Textarea (2-Column Aligned) */}
          <div className="flex gap-2.5 items-start">
            {/* Left Column: Avatar */}
            <div className="flex flex-col items-center shrink-0 w-8">
              <div className="w-8 h-8 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs">
                <img
                  src={currentUser.avatar}
                  alt={currentUser.name}
                  className="w-full h-full object-cover"
                />
              </div>

              {postMode === 'thread' && (
                <>
                  <div className="w-[1.5px] bg-neutral-200 flex-1 my-1 min-h-[48px]" />
                  <div className="w-4 h-4 rounded-full overflow-hidden border border-neutral-200/80 opacity-60">
                    <img
                      src={currentUser.avatar}
                      alt={currentUser.name}
                      className="w-full h-full object-cover"
                    />
                  </div>
                </>
              )}
            </div>

            {/* Right Column: ONLY Username + Topic Selector + Caption Textarea (Aligned with Username!) */}
            <div className="flex-1 min-w-0 flex flex-col">
              {/* Username + Inline Topic Selector Header */}
              <div className="flex items-center gap-1.5 flex-wrap relative leading-none">
                <span className="font-bold text-[14.5px] text-slate-900">
                  {currentUser.username}
                </span>

                {/* Topic Selector Button */}
                <div className="relative inline-flex items-center">
                  <button
                    type="button"
                    onClick={() => setShowTopicDropdown(!showTopicDropdown)}
                    className="flex items-center gap-1 text-[13px] font-normal transition-all cursor-pointer"
                  >
                    <span className="text-neutral-400 font-normal">›</span>
                    {selectedTopic ? (
                      <span
                        className={`flex items-center gap-1 px-1.5 py-0.5 rounded-md font-bold text-[13px] ${
                          selectedTopic.isOfficial
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'bg-neutral-100 text-slate-900'
                        }`}
                      >
                        {selectedTopic.isOfficial && (
                          selectedTopic.icon === 'party-popper' ? (
                            <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                          ) : (
                            <ThreadsTopicIcon />
                          )
                        )}
                        <span>{selectedTopic.name}</span>
                      </span>
                    ) : (
                      <span className="bg-neutral-100 hover:bg-neutral-200/80 text-neutral-500 font-medium px-1.5 py-0.5 rounded-md text-[13px] transition-colors">
                        Community or topic
                      </span>
                    )}
                  </button>

                  {/* Dropdown Popover Overlay */}
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

              {/* Caption Textarea (ONLY this is aligned under username!) */}
              <textarea
                autoFocus
                rows={2}
                placeholder={postMode === 'product' ? 'Deskripsi lengkap barang / jasa...' : 'Apa yang baru?'}
                value={caption}
                onChange={(e) => setCaption(e.target.value)}
                className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none bg-transparent leading-snug"
              />
            </div>
          </div>

          {/* 2. Bottom Section: Seller Form Inputs (Centered Screen, 100% Full Width!) */}
          {postMode === 'product' && (
            <div className="mt-3.5 space-y-3.5 w-full">
              {/* Field 1: Judul Produk / Jasa */}
              <div className="space-y-1">
                <label className="block text-[12px] font-bold text-slate-800">
                  Judul Produk / Jasa <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  placeholder="misal: Jasa UI/UX Design & Engineering PWA"
                  value={productTitle}
                  onChange={(e) => setProductTitle(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white font-semibold text-slate-900 placeholder:font-normal placeholder:text-neutral-400 transition-all shadow-2xs"
                />
              </div>

              {/* 2-Column Grid: Harga (Rp) & Stok / Slot */}
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1">
                  <label className="block text-[12px] font-bold text-slate-800">
                    Harga (Rp) <span className="text-rose-500">*</span>
                  </label>
                  <div className="relative">
                    <span className="absolute left-3.5 top-2.5 text-[13.5px] font-bold text-neutral-400">Rp</span>
                    <input
                      type="text"
                      placeholder="250.000"
                      value={priceInput}
                      onChange={(e) => setPriceInput(e.target.value)}
                      className="w-full pl-10 pr-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white font-bold text-slate-900 placeholder:font-normal placeholder:text-neutral-400 transition-all shadow-2xs"
                    />
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="block text-[12px] font-bold text-slate-800">
                    Stok / Slot
                  </label>
                  <input
                    type="text"
                    placeholder="3 Slot Tersisa"
                    value={stockInput}
                    onChange={(e) => setStockInput(e.target.value)}
                    className="w-full px-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white text-slate-900 placeholder:text-neutral-400 transition-all shadow-2xs"
                  />
                </div>
              </div>

              {/* Field 4: Lokasi COD di Sekolah */}
              <div className="space-y-1">
                <label className="block text-[12px] font-bold text-slate-800">
                  Lokasi COD di Sekolah
                </label>
                <input
                  type="text"
                  placeholder="misal: Studio DKV Gedung B / Lab PPLG 1"
                  value={locationInput}
                  onChange={(e) => setLocationInput(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white text-slate-900 placeholder:text-neutral-400 transition-all shadow-2xs"
                />
              </div>

              {/* Field 5: Kategori Barang / Jasa Chips */}
              <div className="space-y-1.5 pt-0.5">
                <label className="block text-[12px] font-bold text-slate-800">
                  Kategori Barang / Jasa
                </label>
                <div className="flex items-center gap-1.5 flex-wrap">
                  {['Jasa DKV/PPLG', 'Preloved / Bekas', 'Baru', 'Kantin'].map((cat) => (
                    <button
                      key={cat}
                      type="button"
                      className="px-3 py-1.5 rounded-xl border border-neutral-200 hover:border-blue-400 bg-neutral-50 hover:bg-blue-50 text-[12px] font-semibold text-slate-700 hover:text-[#1d64ec] transition-colors cursor-pointer"
                    >
                      {cat}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* 3. Uploaded Images Gallery & Action Icons */}
          <div className="mt-3.5 space-y-3">
            {images.length > 0 && (
              <div className="flex items-center gap-2 overflow-x-auto py-1.5 scrollbar-none">
                {images.map((imgUrl, idx) => (
                  <div key={idx} className="relative w-24 h-24 rounded-2xl overflow-hidden border border-neutral-200 shadow-2xs group shrink-0">
                    <img
                      src={imgUrl}
                      alt={`Upload preview ${idx + 1}`}
                      className="w-full h-full object-cover"
                    />
                    <button
                      type="button"
                      onClick={() => handleRemoveImage(idx)}
                      className="absolute top-1.5 right-1.5 w-5.5 h-5.5 rounded-full bg-black/60 hover:bg-black text-white flex items-center justify-center backdrop-blur-xs transition-transform active:scale-90 cursor-pointer"
                    >
                      <X className="w-3 h-3 stroke-[2.5]" />
                    </button>
                  </div>
                ))}

                <button
                  type="button"
                  onClick={handleAddDummyImage}
                  className="w-24 h-24 rounded-2xl border-2 border-dashed border-neutral-300 hover:border-blue-500 bg-neutral-50 hover:bg-blue-50/30 flex flex-col items-center justify-center gap-1 text-neutral-400 hover:text-[#1d64ec] transition-colors shrink-0 cursor-pointer"
                >
                  <ImageIcon className="w-5 h-5 stroke-[1.8]" />
                  <span className="text-[11.5px] font-semibold">+ Tambah</span>
                </button>
              </div>
            )}

            {/* Action Icons Bar */}
            <div className="flex items-center gap-3.5 pt-1 text-neutral-400 select-none">
              <button
                type="button"
                onClick={handleAddDummyImage}
                className="p-0.5 text-neutral-400 hover:text-slate-900 transition-colors cursor-pointer"
                title="Tambah Foto / Media"
              >
                <ImageIcon className="w-[19px] h-[19px] stroke-[1.6]" />
              </button>
              <button
                type="button"
                className="p-0.5 text-neutral-400 hover:text-slate-900 transition-colors cursor-pointer"
                title="Tambah GIF"
              >
                <span className="border border-neutral-400/80 rounded-[5px] px-1 py-[1px] text-[10px] font-extrabold text-neutral-500 leading-none inline-block">
                  GIF
                </span>
              </button>
              <button
                type="button"
                className="p-0.5 text-neutral-400 hover:text-slate-900 transition-colors cursor-pointer"
                title="Buat Polling"
              >
                <AlignLeft className="w-[19px] h-[19px] stroke-[1.8]" />
              </button>
              <button
                type="button"
                className="p-0.5 text-neutral-400 hover:text-slate-900 transition-colors cursor-pointer"
                title="Opsi Postingan"
              >
                <ThreadsDocOptionIcon className="w-[19px] h-[19px]" />
              </button>
              <button
                type="button"
                className="p-0.5 text-neutral-400 hover:text-slate-900 transition-colors cursor-pointer"
                title="Tag Lokasi"
              >
                <MapPin className="w-[19px] h-[19px] stroke-[1.6]" />
              </button>
              <button
                type="button"
                className="p-0.5 text-neutral-400 hover:text-slate-900 transition-colors cursor-pointer"
                title="Tambah Musik / Audio"
              >
                <Music className="w-[19px] h-[19px] stroke-[1.6]" />
              </button>
            </div>

            {postMode === 'thread' && (
              <div className="pt-2 text-[13.5px] text-neutral-400 font-normal select-none">
                Tambahkan ke thread
              </div>
            )}
          </div>
        </div>

        {/* Bottom Footer */}
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
    </AnimatePresence>
  );
};
