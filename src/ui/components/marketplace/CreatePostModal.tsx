import React, { useState } from 'react';
import { X, FileText, MoreHorizontal, Image as ImageIcon, MapPin, PartyPopper, Sparkles, ChevronRight, Send, Bookmark, Trash2, Pencil, ArrowLeft } from 'lucide-react';
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
  const [subThreads, setSubThreads] = useState<{ id: string; caption: string; images: string[] }[]>([]);
  const [productTitle, setProductTitle] = useState('');
  const [productDescription, setProductDescription] = useState('');
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

  // Smart Intent Detection: detect selling keywords when in thread mode
  const isSellingKeywordDetected = postMode === 'thread' && /\b(jual|dijual|wts|preloved|harga|rp|slot|ongkir|ready|stok|beli)\b/i.test(caption);

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

  // Sub-Thread Chaining Handlers (Tambahkan ke Utas)
  const handleAddSubThread = () => {
    setSubThreads((prev) => [
      ...prev,
      { id: `subthread-${Date.now()}`, caption: '', images: [] }
    ]);
  };

  const handleUpdateSubThreadCaption = (id: string, text: string) => {
    setSubThreads((prev) =>
      prev.map((st) => (st.id === id ? { ...st, caption: text } : st))
    );
  };

  const handleRemoveSubThread = (id: string) => {
    setSubThreads((prev) => prev.filter((st) => st.id !== id));
  };

  const handleAddSubThreadImage = (id: string) => {
    const dummyPics = [
      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
      'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80',
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    ];
    setSubThreads((prev) =>
      prev.map((st) =>
        st.id === id
          ? { ...st, images: [...st.images, dummyPics[st.images.length % dummyPics.length]] }
          : st
      )
    );
  };

  const handleRemoveSubThreadImage = (id: string, imgIndex: number) => {
    setSubThreads((prev) =>
      prev.map((st) =>
        st.id === id
          ? { ...st, images: st.images.filter((_, i) => i !== imgIndex) }
          : st
      )
    );
  };

  const handleSelectTopic = (topic: TopicOption) => {
    setSelectedTopic(topic);
    setShowTopicDropdown(false);
  };

  const handleCustomTopicSubmit = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && customTopicInput.trim()) {
      const cleanTopic = customTopicInput.trim().slice(0, 20);
      setSelectedTopic({
        id: `custom-${Date.now()}`,
        name: cleanTopic,
        isOfficial: false,
      });
      setCustomTopicInput('');
      setShowTopicDropdown(false);
    }
  };

  const canPost =
    caption.trim().length > 0 ||
    images.length > 0 ||
    productTitle.trim().length > 0 ||
    productDescription.trim().length > 0 ||
    subThreads.some((st) => st.caption.trim().length > 0);

  const handleSubmit = () => {
    if (!canPost) return;

    const isProductMode = postMode === 'product';
    const parsedPrice = isProductMode
      ? (priceInput ? parseInt(priceInput.replace(/\D/g, ''), 10) : 50000)
      : undefined;
    const parsedStock = isProductMode
      ? (stockInput ? parseInt(stockInput, 10) : 1)
      : undefined;

    // Sub-threads as structured continuation items (Part 2, 3, etc.)
    const validSubThreads = subThreads.filter(
      (st) => st.caption.trim().length > 0 || st.images.length > 0
    );
    const totalParts = 1 + validSubThreads.length;

    const threadChainItems = validSubThreads.map((st, idx) => ({
      id: st.id,
      partNumber: idx + 2,
      totalParts,
      caption: st.caption,
      images: st.images,
      timestamp: 'Baru saja',
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
    }));

    const newPost: Partial<MarketPostItem> = {
      postType: postMode,
      title: isProductMode ? (productTitle || caption.slice(0, 30)) : undefined,
      description: isProductMode ? (productDescription || undefined) : undefined,
      caption: caption || productTitle,
      images,
      price: parsedPrice,
      stock: parsedStock,
      locationTag: isProductMode ? (locationInput || 'Kantin') : undefined,
      topicTag: selectedTopic ? selectedTopic.name : undefined,
      isOfficialTopic: selectedTopic ? selectedTopic.isOfficial : false,
      topicIcon: selectedTopic?.icon || (selectedTopic?.isOfficial ? 'threads' : undefined),
      threadChain: threadChainItems.length > 0 ? threadChainItems : undefined,
      totalThreadParts: totalParts > 1 ? totalParts : undefined,
    };

    onSubmitPost?.(newPost);
    try {
      localStorage.removeItem('snapan_thread_draft');
    } catch (e) {
      // ignore
    }

    // Reset form state
    setCaption('');
    setSubThreads([]);
    setProductTitle('');
    setProductDescription('');
    setPriceInput('');
    setStockInput('');
    setLocationInput('');
    setImages([]);
    setSelectedTopic(null);
    setPostMode('thread');
    onClose();
  };

  const [showDiscardAlert, setShowDiscardAlert] = useState(false);

  const handleCancelClick = () => {
    const hasContent =
      caption.trim().length > 0 ||
      images.length > 0 ||
      productTitle.trim().length > 0 ||
      productDescription.trim().length > 0 ||
      subThreads.some((st) => st.caption.trim().length > 0 || st.images.length > 0);

    if (hasContent) {
      setShowDiscardAlert(true);
    } else {
      handleDirectClose();
    }
  };

  const handleDirectClose = () => {
    setShowDiscardAlert(false);
    onClose();
  };

  const handleDiscard = () => {
    setCaption('');
    setSubThreads([]);
    setProductTitle('');
    setProductDescription('');
    setPriceInput('');
    setStockInput('');
    setLocationInput('');
    setImages([]);
    setSelectedTopic(null);
    setShowDiscardAlert(false);
    onClose();
  };

  const [showDraftsSheet, setShowDraftsSheet] = useState(false);
  const [savedDraft, setSavedDraft] = useState<any>(() => {
    try {
      const saved = localStorage.getItem('snapan_thread_draft');
      return saved ? JSON.parse(saved) : null;
    } catch {
      return null;
    }
  });

  const refreshSavedDraft = () => {
    try {
      const saved = localStorage.getItem('snapan_thread_draft');
      setSavedDraft(saved ? JSON.parse(saved) : null);
    } catch {
      setSavedDraft(null);
    }
  };

  React.useEffect(() => {
    if (isOpen) {
      refreshSavedDraft();
    }
  }, [isOpen]);

  const handleSaveDraft = () => {
    try {
      const draft = {
        caption,
        subThreads,
        productTitle,
        productDescription,
        priceInput,
        stockInput,
        locationInput,
        images,
        selectedTopic,
        postMode,
        savedAt: new Date().toISOString(),
      };
      localStorage.setItem('snapan_thread_draft', JSON.stringify(draft));
      refreshSavedDraft();
    } catch (e) {
      // ignore
    }
    setShowDiscardAlert(false);
    onClose();
  };

  const handleContinueEditing = () => {
    setShowDiscardAlert(false);
  };

  const handleApplyDraft = (draft: any) => {
    if (draft) {
      if (draft.caption !== undefined) setCaption(draft.caption);
      if (draft.subThreads !== undefined) setSubThreads(draft.subThreads);
      if (draft.productTitle !== undefined) setProductTitle(draft.productTitle);
      if (draft.productDescription !== undefined) setProductDescription(draft.productDescription);
      if (draft.priceInput !== undefined) setPriceInput(draft.priceInput);
      if (draft.stockInput !== undefined) setStockInput(draft.stockInput);
      if (draft.locationInput !== undefined) setLocationInput(draft.locationInput);
      if (draft.images !== undefined) setImages(draft.images);
      if (draft.selectedTopic !== undefined) setSelectedTopic(draft.selectedTopic);
      if (draft.postMode !== undefined) setPostMode(draft.postMode);
    }
    setShowDraftsSheet(false);
  };

  const handleDeleteDraft = (e: React.MouseEvent) => {
    e.stopPropagation();
    try {
      localStorage.removeItem('snapan_thread_draft');
      setSavedDraft(null);
    } catch {
      // ignore
    }
  };

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 bg-white flex flex-col font-gt-standard overflow-hidden transform-gpu animate-sheet-slide"
      style={{ willChange: 'transform' }}
    >
        {/* Top Bar Header: [ Batal ] --- [ Title (Dead Centered to Screen) ] --- [ Draft & Options ] */}
        <div className="relative px-4 h-14 flex items-center justify-between border-b border-neutral-200/80 bg-white shrink-0">
          <button
            type="button"
            onClick={handleCancelClick}
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
              onClick={() => {
                refreshSavedDraft();
                setShowDraftsSheet(true);
              }}
              className="relative text-slate-600 hover:text-slate-900 transition-colors p-1.5 rounded-full hover:bg-neutral-100 cursor-pointer"
              title="Lihat Draf Tersimpan"
            >
              <FileText className="w-5 h-5 stroke-[1.8]" />
              {savedDraft && (
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

        {/* Form Scrollable Body */}
        <div className="p-4 overflow-y-auto flex-1 relative max-w-lg mx-auto w-full">
          {/* 1. Top Section: Avatar + Username + Caption + Images + Action Icons (Threads 2-Column Aligned) */}
          <div className="flex gap-2.5 items-start">
            {/* Left Column: Avatar (Top) + Vertical Connector Line */}
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

            {/* Right Column: Username + Topic Selector + Caption Textarea + Images Gallery + Action Icons */}
            <div className="flex-1 min-w-0 flex flex-col justify-between">
              <div>
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
                      className="flex items-center gap-1 text-[14.5px] transition-all cursor-pointer"
                    >
                      <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />
                      {selectedTopic ? (
                        <span
                          className={`flex items-center gap-1 font-bold text-[14.5px] hover:opacity-80 transition-opacity ${
                            selectedTopic.isOfficial
                              ? 'text-[#1d64ec]'
                              : 'text-slate-900'
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
                        <span className="text-neutral-400 hover:text-neutral-600 font-normal text-[14.5px] transition-colors">
                          Community or topic
                        </span>
                      )}
                    </button>

                    {/* Dropdown Popover Overlay with Click-Away Backdrop & Safe Screen Positioning */}
                    {showTopicDropdown && (
                      <>
                        <div
                          className="fixed inset-0 z-40"
                          onClick={() => setShowTopicDropdown(false)}
                        />
                        <div className="absolute top-full -right-6 sm:right-auto sm:left-0 mt-1.5 w-64 max-w-[calc(100vw-2rem)] bg-white rounded-2xl shadow-2xl border border-neutral-200/90 z-50 p-2 transform-gpu animate-in fade-in slide-in-from-top-2 duration-150 font-gt-standard">
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

                        {/* Custom Topic Input with Max Length 20 & Character Counter */}
                        <div className="mt-2 pt-2 border-t border-neutral-100 px-2 space-y-1">
                          <div className="relative flex items-center">
                            <input
                              type="text"
                              maxLength={20}
                              placeholder="Ketik topik baru..."
                              value={customTopicInput}
                              onChange={(e) => setCustomTopicInput(e.target.value)}
                              onKeyDown={handleCustomTopicSubmit}
                              className="w-full pl-2.5 pr-11 py-1.5 text-[12.5px] rounded-lg border border-neutral-200 focus:outline-none focus:border-[#1d64ec] bg-neutral-50"
                            />
                            <span className="absolute right-2 text-[10px] font-semibold text-neutral-400 pointer-events-none tabular-nums">
                              {customTopicInput.length}/20
                            </span>
                          </div>
                          <p className="text-[10px] text-neutral-400 px-0.5">
                            Maksimal 20 karakter · Tekan Enter
                          </p>
                        </div>
                      </div>
                    </>
                  )}
                  </div>

                  {/* Thread Page Counter Badge (e.g. 1/2) if multi-thread exists */}
                  {subThreads.length > 0 && (
                    <span className="inline-flex items-center px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-500 font-semibold text-[11.5px] tabular-nums select-none ml-1">
                      1/{1 + subThreads.length}
                    </span>
                  )}
                </div>

                {/* Caption Textarea (Fit height, auto-expanding on Enter!) */}
                <textarea
                  autoFocus
                  rows={1}
                  placeholder={postMode === 'product' ? 'Tulis deskripsi atau rincian jualan...' : 'Apa yang baru?'}
                  value={caption}
                  onChange={(e) => {
                    setCaption(e.target.value);
                    e.target.style.height = 'auto';
                    e.target.style.height = `${e.target.scrollHeight}px`;
                  }}
                  className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none bg-transparent leading-snug overflow-hidden"
                />

                {/* Smart Intent Auto-Detection Banner (Prompt beralih ke Mode Jual jika terdeteksi kata jualan) */}
                {isSellingKeywordDetected && (
                  <div className="my-2 p-2.5 rounded-xl bg-blue-50 border border-blue-200 flex items-center justify-between gap-2 transform-gpu animate-toast-pop">
                    <div className="flex items-center gap-1.5 text-[12px] font-semibold text-[#1d64ec]">
                      <Sparkles className="w-3.5 h-3.5 shrink-0" />
                      <span>Ingin memasang harga jual?</span>
                    </div>
                    <button
                      type="button"
                      onClick={() => setPostMode('product')}
                      className="px-2.5 py-1 rounded-lg bg-[#1d64ec] text-white text-[11px] font-bold hover:bg-[#154ec1] transition-colors cursor-pointer shadow-2xs active:scale-95 shrink-0"
                    >
                      Beralih ke Jual
                    </button>
                  </div>
                )}

                {/* Uploaded Images Gallery */}
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

                {/* Ergonomic & Touch-Friendly Action Toolbar: [ 1. Foto ] -> [ 2. Jual Barang ] */}
                <div className="flex items-center flex-wrap gap-2 pt-2.5 select-none">
                  {/* 1. Add Image Pill */}
                  <button
                    type="button"
                    onClick={handleAddDummyImage}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-neutral-100/90 hover:bg-neutral-200/80 active:scale-95 text-slate-800 text-[12.5px] font-semibold transition-all cursor-pointer"
                  >
                    <ImageIcon className="w-4 h-4 text-slate-700 stroke-[2]" />
                    <span>{images.length > 0 ? `Foto (${images.length})` : 'Foto'}</span>
                  </button>

                  {/* 2. "Jual Barang" Toggle Switch Pill */}
                  <div
                    onClick={() => setPostMode(postMode === 'product' ? 'thread' : 'product')}
                    className={`inline-flex items-center gap-2 px-3 py-1.5 rounded-full border transition-all cursor-pointer select-none active:scale-95 ${
                      postMode === 'product'
                        ? 'bg-blue-50/90 border-blue-200 text-[#1d64ec] font-bold shadow-2xs'
                        : 'bg-neutral-100/90 hover:bg-neutral-200/80 border-neutral-200/80 text-slate-800 font-semibold'
                    }`}
                  >
                    {/* Toggle Switch Track */}
                    <div
                      className={`w-8 h-4.5 rounded-full p-0.5 transition-colors duration-200 flex items-center shrink-0 ${
                        postMode === 'product' ? 'bg-[#1d64ec]' : 'bg-neutral-300'
                      }`}
                    >
                      <div
                        className={`w-3.5 h-3.5 rounded-full bg-white shadow-xs transition-transform duration-200 transform-gpu ${
                          postMode === 'product' ? 'translate-x-3.5' : 'translate-x-0'
                        }`}
                      />
                    </div>

                    {/* Clear & Direct UX Copy */}
                    <span className="text-[12.5px] leading-none">Jual Barang</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* 2. Chained Sub-Threads (Utas Bersambung) */}
          {subThreads.map((st, index) => (
            <div key={st.id} className="flex gap-2.5 items-start mt-2 transform-gpu animate-toast-pop">
              {/* Left Column: Avatar + Connector Line */}
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

              {/* Right Column: Sub-Thread Content */}
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
                    onClick={() => handleRemoveSubThread(st.id)}
                    className="w-6 h-6 rounded-full hover:bg-neutral-100 flex items-center justify-center text-neutral-400 hover:text-slate-800 transition-colors cursor-pointer"
                    title="Hapus sambungan utas"
                  >
                    <X className="w-4 h-4 stroke-[2]" />
                  </button>
                </div>

                <textarea
                  rows={1}
                  placeholder="Say more..."
                  value={st.caption}
                  onChange={(e) => {
                    handleUpdateSubThreadCaption(st.id, e.target.value);
                    e.target.style.height = 'auto';
                    e.target.style.height = `${e.target.scrollHeight}px`;
                  }}
                  className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none bg-transparent leading-snug overflow-hidden"
                />

                {/* Sub-Thread Images */}
                {st.images.length > 0 && (
                  <div className="flex items-center gap-2 overflow-x-auto py-1.5 scrollbar-none">
                    {st.images.map((img, imgIdx) => (
                      <div key={imgIdx} className="relative w-20 h-20 rounded-2xl overflow-hidden border border-neutral-200 shrink-0">
                        <img src={img} alt="Attachment" className="w-full h-full object-cover" />
                        <button
                          type="button"
                          onClick={() => handleRemoveSubThreadImage(st.id, imgIdx)}
                          className="absolute top-1 right-1 w-5 h-5 rounded-full bg-black/60 text-white flex items-center justify-center cursor-pointer"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      </div>
                    ))}
                  </div>
                )}

                {/* Sub-Thread Action Pill */}
                <div className="flex items-center gap-2 pt-1.5 select-none">
                  <button
                    type="button"
                    onClick={() => handleAddSubThreadImage(st.id)}
                    className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-neutral-100/90 hover:bg-neutral-200/80 active:scale-95 text-slate-800 text-[12px] font-semibold transition-all cursor-pointer"
                  >
                    <ImageIcon className="w-3.5 h-3.5 text-slate-700 stroke-[2]" />
                    <span>{st.images.length > 0 ? `Foto (${st.images.length})` : 'Foto'}</span>
                  </button>
                </div>
              </div>
            </div>
          ))}

          {/* 3. Bottom Interactive "Tambahkan ke utas" Chaining Button (Hanya di mode Utas) */}
          {postMode === 'thread' && (
            <div className="flex gap-2.5 items-center mt-2 pt-1 select-none">
              <div className="flex flex-col items-center shrink-0 w-8">
                <div className="w-4 h-4 rounded-full overflow-hidden border border-neutral-200/80 opacity-60 shrink-0">
                  <img
                    src={currentUser.avatar}
                    alt={currentUser.name}
                    className="w-full h-full object-cover"
                  />
                </div>
              </div>
              <button
                type="button"
                onClick={handleAddSubThread}
                className="py-1 text-left text-[14px] text-neutral-400 hover:text-slate-800 active:text-slate-900 active:scale-95 transition-all cursor-pointer select-none font-normal"
              >
                Tambahkan ke utas
              </button>
            </div>
          )}

          {/* 2. Bottom Section (ONLY for Product Mode): Zero-Friction Seller Form Inputs */}
          {postMode === 'product' && (
            <div
              className="mt-4 space-y-4 w-full pt-3 border-t border-neutral-100 transform-gpu animate-sheet-slide"
              style={{ willChange: 'transform' }}
            >
              {/* Field 1: Nama / Judul Barang */}
              <div className="space-y-1">
                <label className="block text-[12.5px] font-bold text-slate-800">
                  Nama Barang / Jasa <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  placeholder="Tulis nama barang atau jasa..."
                  value={productTitle}
                  onChange={(e) => setProductTitle(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white font-semibold text-slate-900 placeholder:font-normal placeholder:text-neutral-400 transition-all shadow-2xs"
                />
              </div>

              {/* Field 2: Harga (Rp) */}
              <div className="space-y-1">
                <label className="block text-[12.5px] font-bold text-slate-800">
                  Harga (Rp) <span className="text-rose-500">*</span>
                </label>
                <div className="relative">
                  {priceInput && (
                    <span className="absolute left-3.5 top-2.5 text-[13.5px] font-bold text-slate-900 pointer-events-none select-none">
                      Rp
                    </span>
                  )}
                  <input
                    type="text"
                    inputMode="numeric"
                    pattern="[0-9]*"
                    placeholder="Masukkan nominal harga..."
                    value={priceInput}
                    onChange={(e) => {
                      const raw = e.target.value.replace(/[^0-9]/g, '');
                      if (!raw) {
                        setPriceInput('');
                        return;
                      }
                      const formatted = new Intl.NumberFormat('id-ID').format(Number(raw));
                      setPriceInput(formatted);
                    }}
                    className={`w-full ${
                      priceInput ? 'pl-10 font-bold text-slate-900' : 'pl-3.5 font-normal text-slate-900'
                    } pr-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white placeholder:font-normal placeholder:text-neutral-400 transition-all shadow-2xs`}
                  />
                </div>
              </div>

              {/* Field 3: Deskripsi Singkat / Rincian Barang */}
              <div className="space-y-1">
                <div className="flex items-center justify-between">
                  <label className="block text-[12.5px] font-bold text-slate-800">
                    Deskripsi Singkat
                  </label>
                  {250 - productDescription.length <= 30 && (
                    <span
                      className={`text-[11.5px] font-semibold transition-colors ${
                        productDescription.length >= 250 ? 'text-rose-600 font-bold' : 'text-rose-500'
                      }`}
                    >
                      {productDescription.length >= 250
                        ? 'Batas maksimal tercapai'
                        : `Sisa ${250 - productDescription.length} karakter`}
                    </span>
                  )}
                </div>
                <textarea
                  rows={4}
                  maxLength={250}
                  placeholder="Tulis kondisi barang, kelengkapan, atau alasan jual..."
                  value={productDescription}
                  onChange={(e) => setProductDescription(e.target.value)}
                  className={`w-full min-h-[96px] px-3.5 py-2.5 text-[14px] leading-relaxed rounded-xl border ${
                    productDescription.length >= 250
                      ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10'
                      : 'border-neutral-300 focus:border-[#1d64ec] focus:ring-blue-500/10'
                  } focus:outline-none focus:ring-4 bg-white text-slate-900 placeholder:text-neutral-400 transition-all shadow-2xs resize-none`}
                />
              </div>

              {/* Field 4: Titik COD di Sekolah (Direct Form Field + 1-Tap Chips) */}
              <div className="space-y-1.5 pt-0.5">
                <div className="flex items-center justify-between">
                  <label className="block text-[12.5px] font-bold text-slate-800">
                    Titik COD di Sekolah
                  </label>
                  {locationInput && (
                    <button
                      type="button"
                      onClick={() => setLocationInput('')}
                      className="text-[11.5px] font-medium text-neutral-400 hover:text-rose-500 transition-colors cursor-pointer"
                    >
                      Hapus
                    </button>
                  )}
                </div>

                <div className="relative">
                  <MapPin className="absolute left-3.5 top-3 w-4 h-4 text-neutral-400 pointer-events-none" />
                  <input
                    type="text"
                    placeholder="Ketik titik temu COD (Kantin, Lab, dll)..."
                    value={locationInput}
                    onChange={(e) => setLocationInput(e.target.value)}
                    className="w-full pl-9.5 pr-8 py-2.5 text-[13.5px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white text-slate-900 placeholder:text-neutral-400 transition-all shadow-2xs font-normal"
                  />
                  {locationInput && (
                    <button
                      type="button"
                      onClick={() => setLocationInput('')}
                      className="absolute right-2.5 top-2.5 w-5 h-5 rounded-full bg-neutral-200/80 hover:bg-neutral-300 text-neutral-600 flex items-center justify-center transition-colors cursor-pointer"
                    >
                      <X className="w-3 h-3 stroke-[2.5]" />
                    </button>
                  )}
                </div>

                {/* 1-Tap Preset Recommendations */}
                <div className="flex items-center gap-1.5 flex-wrap pt-0.5">
                  {[
                    { name: 'Kantin', emoji: '🍜' },
                    { name: 'Lab PPLG', emoji: '💻' },
                    { name: 'Perpustakaan', emoji: '📚' },
                    { name: 'Depan Gerbang', emoji: '🏫' },
                    { name: 'Lapangan', emoji: '⚽' },
                    { name: 'Gazebo DKV', emoji: '☕' },
                  ].map((loc) => {
                    const isSelected = locationInput.toLowerCase() === loc.name.toLowerCase();
                    return (
                      <button
                        key={loc.name}
                        type="button"
                        onClick={() => setLocationInput(isSelected ? '' : loc.name)}
                        className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-[12px] font-semibold transition-all cursor-pointer select-none active:scale-95 border ${
                          isSelected
                            ? 'bg-blue-50 border-blue-400 text-[#1d64ec] shadow-2xs font-bold'
                            : 'bg-neutral-50 hover:bg-neutral-100/90 border-neutral-200 text-slate-700'
                        }`}
                      >
                        <span>{loc.emoji}</span>
                        <span>{loc.name}</span>
                      </button>
                    );
                  })}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Bottom Footer: [ Mode Indicator / Mini Hint ] --- [ Post Button ] */}
        <div className="px-4 py-3 pb-[max(0.85rem,calc(env(safe-area-inset-bottom)+8px))] border-t border-neutral-200/80 bg-white flex items-center justify-between gap-3 shrink-0 select-none">
          {/* Left: Mode Indicator / Mini Hint */}
          <div className="flex items-center gap-2">
            <span className="text-[12px] text-neutral-400 font-medium">
              {postMode === 'product' ? '🛍️ Mode Jualan Aktif' : '💬 Utas Publik'}
            </span>
          </div>

          {/* Post Action Button (Kumo UI Primary Pill Button with Send Icon) */}
          <button
            type="button"
            onClick={handleSubmit}
            disabled={!canPost}
            className={`group relative overflow-hidden px-5 py-2.5 rounded-full font-bold text-[14px] select-none transition-all duration-150 shrink-0 inline-flex items-center gap-1.5 ${
              canPost
                ? 'bg-[#0f141c] text-white border border-black/40 shadow-md shadow-slate-900/20 active:scale-95 cursor-pointer hover:bg-black'
                : 'bg-neutral-100 text-neutral-400 border border-neutral-200 cursor-not-allowed opacity-60'
            }`}
          >
            {/* Kumo Inset Top Rim Highlight Gradient */}
            {canPost && (
              <span className="absolute inset-0 rounded-full bg-gradient-to-b from-neutral-600/50 to-transparent shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-neutral-500/50 transition-all pointer-events-none" />
            )}

            <span className="relative z-10 flex items-center gap-1.5">
              <span>Post</span>
              <Send className="w-3.5 h-3.5 stroke-[2.2]" />
            </span>
          </button>
        </div>

        {/* Discard Confirmation Alert Modal (Save Draft -> Discard -> Continue Editing) */}
        {showDiscardAlert && (
          <div className="fixed inset-0 z-[70] flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs animate-backdrop-fade">
            <div
              className="w-full max-w-[320px] bg-white rounded-3xl p-5 text-center shadow-2xl space-y-4 border border-neutral-100 transform-gpu animate-page-zoom font-gt-standard"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="space-y-1.5 pt-1">
                <h3 className="font-bold text-[17px] text-slate-900 leading-snug">
                  Buang postingan?
                </h3>
                <p className="text-[13px] text-neutral-500 font-normal leading-relaxed">
                  Jika kamu keluar sekarang, editan kamu tidak akan diposting.
                </p>
              </div>

              {/* Action Buttons with Safe UX Order & Informative Icons */}
              <div className="space-y-2 pt-1">
                {/* 1. Simpan Draf (Paling Aman - Safe Default) */}
                <button
                  type="button"
                  onClick={handleSaveDraft}
                  className="w-full py-3 rounded-2xl bg-neutral-100 hover:bg-neutral-200/80 text-slate-900 font-bold text-[14px] transition-colors active:scale-98 cursor-pointer flex items-center justify-center gap-2"
                >
                  <Bookmark className="w-4 h-4 text-slate-700 stroke-[2] shrink-0" />
                  <span>Simpan Draf</span>
                </button>

                {/* 2. Buang (Destructive Action - Sadar) */}
                <button
                  type="button"
                  onClick={handleDiscard}
                  className="w-full py-3 rounded-2xl bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold text-[14px] transition-colors active:scale-98 cursor-pointer flex items-center justify-center gap-2"
                >
                  <Trash2 className="w-4 h-4 text-rose-600 stroke-[2] shrink-0" />
                  <span>Buang Postingan</span>
                </button>

                {/* 3. Lanjutkan Mengedit (Batal Keluar) */}
                <button
                  type="button"
                  onClick={handleContinueEditing}
                  className="w-full py-2.5 rounded-2xl text-slate-500 hover:text-slate-900 font-semibold text-[13.5px] transition-colors active:scale-98 cursor-pointer flex items-center justify-center gap-1.5"
                >
                  <Pencil className="w-3.5 h-3.5 text-slate-400 stroke-[2] shrink-0" />
                  <span>Lanjutkan Mengedit</span>
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Saved Drafts Full Page Screen (Matching Threads Reference Design) */}
        {showDraftsSheet && (
          <div className="fixed inset-0 z-[70] bg-white flex flex-col font-gt-standard overflow-hidden transform-gpu animate-page-zoom">
            {/* Top Bar Header: [ < Back ] --- [ Drafts ] --- [ Spacer ] */}
            <div className="px-4 h-14 flex items-center justify-between border-b border-neutral-200/80 bg-white shrink-0">
              <button
                type="button"
                onClick={() => setShowDraftsSheet(false)}
                className="p-2 -ml-2 text-slate-800 hover:opacity-70 active:scale-95 transition-all cursor-pointer rounded-full"
                title="Kembali"
              >
                <ArrowLeft className="w-5 h-5 stroke-[2]" />
              </button>

              <h2 className="text-[16px] font-bold text-slate-900 tracking-tight">
                Drafts
              </h2>

              <div className="w-8" />
            </div>

            {/* Full-Page Drafts List */}
            <div className="flex-1 overflow-y-auto max-w-lg mx-auto w-full flex flex-col">
              {savedDraft ? (
                <div
                  onClick={() => handleApplyDraft(savedDraft)}
                  className="p-4 hover:bg-neutral-50 active:bg-neutral-100/70 transition-colors cursor-pointer flex gap-3 items-start border-b border-neutral-100"
                >
                  {/* Avatar */}
                  <div className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 mt-0.5">
                    <img
                      src={currentUser.avatar}
                      alt={currentUser.name}
                      className="w-full h-full object-cover"
                    />
                  </div>

                  {/* Content Column */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex items-center gap-1.5 min-w-0">
                        <span className="font-bold text-[14.5px] text-slate-900 truncate">
                          {currentUser.username}
                        </span>
                        <span className="text-[13px] text-neutral-400 font-normal shrink-0">
                          1m
                        </span>
                      </div>

                      <button
                        type="button"
                        onClick={handleDeleteDraft}
                        className="text-neutral-400 hover:text-rose-600 p-1.5 -mr-1 rounded-full hover:bg-neutral-100 transition-colors cursor-pointer"
                        title="Hapus Draf"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>

                    {/* Draft text snippet */}
                    <p className="text-[14px] text-slate-800 font-normal mt-1 leading-relaxed whitespace-pre-wrap line-clamp-3">
                      {savedDraft.caption || savedDraft.productTitle || '(Draf tanpa teks)'}
                    </p>

                    {/* Badges if multi-thread / product / images */}
                    {(savedDraft.subThreads?.length > 0 || savedDraft.images?.length > 0 || savedDraft.postMode === 'product') && (
                      <div className="flex items-center gap-2 mt-2.5">
                        {savedDraft.postMode === 'product' && (
                          <span className="text-[11px] font-semibold text-[#1d64ec] bg-blue-50 px-2 py-0.5 rounded-md">
                            Mode Jualan
                          </span>
                        )}
                        {savedDraft.subThreads?.length > 0 && (
                          <span className="text-[11.5px] font-semibold text-neutral-500 bg-neutral-100 px-1.5 py-0.5 rounded-md tabular-nums">
                            {savedDraft.subThreads.length + 1} Utas
                          </span>
                        )}
                        {savedDraft.images?.length > 0 && (
                          <span className="text-[11.5px] font-semibold text-neutral-500 bg-neutral-100 px-1.5 py-0.5 rounded-md tabular-nums">
                            {savedDraft.images.length} Foto
                          </span>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="flex-1 flex flex-col items-center justify-center text-center space-y-3 px-4 pb-14">
                  <div className="w-14 h-14 rounded-2xl bg-neutral-100 text-neutral-400 flex items-center justify-center mx-auto shadow-2xs">
                    <FileText className="w-7 h-7 stroke-[1.5]" />
                  </div>
                  <h3 className="font-bold text-[17px] text-slate-900">Belum Ada Draf</h3>
                  <p className="text-[13.5px] text-neutral-500 max-w-xs mx-auto leading-relaxed">
                    Saat kamu membuat utas dan memilih "Simpan Draf", postingan draf akan tersimpan di sini.
                  </p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
  );
};
