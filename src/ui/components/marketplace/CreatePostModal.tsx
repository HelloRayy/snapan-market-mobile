import React, { useState } from 'react';
import {
  X,
  FileText,
  MoreHorizontal,
  Image as ImageIcon,
  MapPin,
  PartyPopper,
  Sparkles,
  ChevronRight,
  Trash2,
  Smile,
  BarChart2,
  Music,
  Play,
  Volume2,
  ArrowLeft,
  Search,
  Navigation,
} from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';

// Custom Threads 3-Dot Topic Icon
const ThreadsTopicIcon: React.FC<{ className?: string }> = ({
  className = 'w-4 h-4 text-slate-700 fill-current shrink-0',
}) => (
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

interface SchoolPlace {
  id: string;
  name: string;
  subtitle: string;
  distance: string;
}

const RICH_SCHOOL_PLACES: SchoolPlace[] = [
  { id: 'p1', name: 'Lab PPLG 1 & 2', subtitle: 'Gedung Kejuruan Lantai 2 · SMKN 8 Semarang', distance: 'Sekitar sini' },
  { id: 'p2', name: 'Kantin Belakang SMKN 8', subtitle: 'Area Pujasera & Kuliner Siswa', distance: '50 m' },
  { id: 'p3', name: 'Lapangan Utama SMKN 8', subtitle: 'Area Olahraga & Lapangan Upacara', distance: '30 m' },
  { id: 'p4', name: 'Perpustakaan Sekolah', subtitle: 'Gedung Utama Lantai 1', distance: '40 m' },
  { id: 'p5', name: 'Lobi Depan & Ruang OSIS', subtitle: 'Gerbang Utama & Pos Keamanan', distance: '80 m' },
  { id: 'p6', name: 'Studio DKV', subtitle: 'Gedung Kreatif Lantai 2', distance: '60 m' },
  { id: 'p7', name: 'Bengkel TJKT / Jaringan', subtitle: 'Gedung Teknologi Barat', distance: '70 m' },
  { id: 'p8', name: 'Musholla As-Salam SMKN 8', subtitle: 'Tempat Ibadah Sekolah', distance: '90 m' },
];

const PRESET_EMOJIS = ['🔥', '😍', '🙌', '✨', '⚡', '💯', '❤️', '👏', '🚀', '💡', '🍱', '💻'];

const PRESET_GIFS = [
  { id: 'g1', title: 'Coding Cat', url: 'https://images.unsplash.com/photo-1534972195531-a756b1146245?w=400&q=80' },
  { id: 'g2', title: 'Let\'s Go', url: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&q=80' },
  { id: 'g3', title: 'Yummy Food', url: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&q=80' },
  { id: 'g4', title: 'Deal Success', url: 'https://images.unsplash.com/photo-1556742049-0a67e55722c6?w=400&q=80' },
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

  // Meta Threads 7-Icon Action States
  const [showEmojiBar, setShowEmojiBar] = useState(false);
  const [showLocationPicker, setShowLocationPicker] = useState(false);
  const [locationSearchQuery, setLocationSearchQuery] = useState('');
  const [selectedLocation, setSelectedLocation] = useState<string | null>(null);
  const [showGifPicker, setShowGifPicker] = useState(false);
  const [selectedGif, setSelectedGif] = useState<string | null>(null);
  const [showPollBuilder, setShowPollBuilder] = useState(false);
  const [pollOptions, setPollOptions] = useState<string[]>(['', '', '']);
  const [showVoiceNote, setShowVoiceNote] = useState(false);

  // Draft Management State
  const [showDiscardAlert, setShowDiscardAlert] = useState(false);
  const [showDraftsSheet, setShowDraftsSheet] = useState(false);
  const [savedDraft, setSavedDraft] = useState<any | null>(null);

  // Sync initialMode when modal opens
  React.useEffect(() => {
    if (isOpen) {
      setPostMode(initialMode);
      refreshSavedDraft();
    }
  }, [isOpen, initialMode]);

  const refreshSavedDraft = () => {
    try {
      const stored = localStorage.getItem('snapan_thread_draft');
      if (stored) {
        setSavedDraft(JSON.parse(stored));
      } else {
        setSavedDraft(null);
      }
    } catch {
      setSavedDraft(null);
    }
  };

  // Filtered places based on locationSearchQuery
  const filteredPlaces = RICH_SCHOOL_PLACES.filter(
    (p) =>
      p.name.toLowerCase().includes(locationSearchQuery.toLowerCase()) ||
      p.subtitle.toLowerCase().includes(locationSearchQuery.toLowerCase())
  );

  // Smart Intent Detection: detect selling keywords when in thread mode
  const isSellingKeywordDetected =
    postMode === 'thread' &&
    /\b(jual|dijual|wts|preloved|harga|rp|slot|ongkir|ready|stok|beli)\b/i.test(caption);

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
      { id: `subthread-${Date.now()}`, caption: '', images: [] },
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

  // Poll Handlers
  const handleUpdatePollOption = (index: number, val: string) => {
    const next = [...pollOptions];
    next[index] = val;
    setPollOptions(next);
  };

  const handleRemovePollOption = (index: number) => {
    if (pollOptions.length > 2) {
      setPollOptions(pollOptions.filter((_, i) => i !== index));
    }
  };

  // Emoji Insert Handler
  const handleInsertEmoji = (emoji: string) => {
    setCaption((prev) => prev + emoji);
  };

  const canPost =
    caption.trim().length > 0 ||
    images.length > 0 ||
    selectedGif !== null ||
    showPollBuilder ||
    productTitle.trim().length > 0 ||
    productDescription.trim().length > 0 ||
    subThreads.some((st) => st.caption.trim().length > 0);

  const handleSubmit = () => {
    if (!canPost) return;

    const isProductMode = postMode === 'product';
    const parsedPrice = isProductMode
      ? priceInput
        ? parseInt(priceInput.replace(/\D/g, ''), 10)
        : 50000
      : undefined;
    const parsedStock = isProductMode
      ? stockInput
        ? parseInt(stockInput, 10)
        : 1
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

    const allImages = [...images];
    if (selectedGif) {
      allImages.push(selectedGif);
    }

    const newPost: Partial<MarketPostItem> = {
      postType: postMode,
      title: isProductMode ? productTitle || caption.slice(0, 30) : undefined,
      description: isProductMode ? productDescription || undefined : undefined,
      caption: caption || productTitle,
      images: allImages,
      price: parsedPrice,
      stock: parsedStock,
      locationTag: isProductMode
        ? locationInput || selectedLocation || 'Kantin Belakang'
        : selectedLocation || undefined,
      topicTag: selectedTopic ? selectedTopic.name : undefined,
      isOfficialTopic: selectedTopic ? selectedTopic.isOfficial : false,
      topicIcon: selectedTopic?.icon || (selectedTopic?.isOfficial ? 'threads' : undefined),
      threadChain: threadChainItems.length > 0 ? threadChainItems : undefined,
      totalThreadParts: totalParts > 1 ? totalParts : undefined,
      seller: {
        id: `seller-${Date.now()}`,
        name: currentUser.name,
        avatar: currentUser.avatar,
        username: currentUser.username,
        classGroup: 'XII PPLG 1',
        isVerified: true,
      },
    };

    if (onSubmitPost) {
      onSubmitPost(newPost);
    }

    // Reset & Close
    setCaption('');
    setImages([]);
    setSelectedGif(null);
    setSelectedLocation(null);
    setShowPollBuilder(false);
    setShowVoiceNote(false);
    setSubThreads([]);
    setProductTitle('');
    setProductDescription('');
    setPriceInput('');
    setStockInput('');
    setLocationInput('');
    setSelectedTopic(null);
    onClose();
  };

  const handleCancelClick = () => {
    const isDirty =
      caption.trim().length > 0 ||
      images.length > 0 ||
      selectedGif !== null ||
      showPollBuilder ||
      selectedLocation !== null ||
      productTitle.trim().length > 0 ||
      productDescription.trim().length > 0 ||
      subThreads.some((st) => st.caption.trim().length > 0);

    if (isDirty) {
      setShowDiscardAlert(true);
    } else {
      onClose();
    }
  };

  const handleConfirmDiscard = () => {
    setCaption('');
    setImages([]);
    setSelectedGif(null);
    setSelectedLocation(null);
    setShowPollBuilder(false);
    setShowVoiceNote(false);
    setSubThreads([]);
    setProductTitle('');
    setProductDescription('');
    setPriceInput('');
    setStockInput('');
    setLocationInput('');
    setSelectedTopic(null);
    setShowDiscardAlert(false);
    onClose();
  };

  const handleSaveDraft = () => {
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
      selectedLocation,
      timestamp: Date.now(),
    };
    try {
      localStorage.setItem('snapan_thread_draft', JSON.stringify(draft));
      refreshSavedDraft();
    } catch {
      // ignore
    }
    setShowDiscardAlert(false);
    onClose();
  };

  const handleInputFocus = (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const target = e.currentTarget;
    setTimeout(() => {
      target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 250);
  };

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 bg-white flex flex-col font-gt-standard overflow-hidden transform-gpu animate-sheet-slide h-[100dvh] max-h-[100dvh]"
      style={{ willChange: 'transform' }}
    >
      {/* ========================================================================= */}
      {/* 🗺️ DEDICATED "PILIH TEMPAT" SCREEN (Matching Meta Threads Reference Layout) */}
      {/* ========================================================================= */}
      {showLocationPicker ? (
        <div className="flex-1 flex flex-col bg-white overflow-hidden animate-in fade-in duration-200">
          {/* Header (Grid layout: [Kembali] --- [Pilih tempat] --- [Spacer]) */}
          <div className="grid grid-cols-[48px_1fr_48px] items-center text-slate-900 border-b border-neutral-100 h-14 px-3 leading-snug shrink-0">
            <button
              type="button"
              onClick={() => setShowLocationPicker(false)}
              className="flex items-center justify-center h-8 w-8 rounded-full hover:bg-neutral-100 text-slate-700 transition-colors cursor-pointer"
              aria-label="Kembali"
            >
              <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
            </button>
            <h1 className="font-bold text-center text-[16px] text-slate-900 leading-snug">
              Pilih tempat
            </h1>
            <div className="w-6" />
          </div>

          {/* Searchbar & "Sekitar Sini" (GPS Navigation Button) */}
          <div className="flex items-center gap-x-2.5 pt-3 px-4 leading-snug">
            <div className="flex-1 flex items-center gap-2 py-2 px-3.5 bg-neutral-100/90 rounded-2xl border border-neutral-200/80 leading-snug focus-within:border-[#1d64ec] focus-within:bg-white transition-all">
              <Search className="w-4 h-4 text-neutral-400 shrink-0" />
              <input
                type="text"
                autoFocus
                placeholder="Cari tempat atau ketik lokasi..."
                value={locationSearchQuery}
                onChange={(e) => setLocationSearchQuery(e.target.value)}
                className="w-full text-[14px] text-slate-900 placeholder:text-neutral-400 bg-transparent focus:outline-none leading-snug"
              />
              {locationSearchQuery && (
                <button
                  type="button"
                  onClick={() => setLocationSearchQuery('')}
                  className="text-neutral-400 hover:text-slate-700"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              )}
            </div>

            <button
              type="button"
              onClick={() => {
                setSelectedLocation('📍 Sekitar SMKN 8 Semarang');
                setShowLocationPicker(false);
                setLocationSearchQuery('');
              }}
              className="flex items-center justify-center h-10 w-10 rounded-2xl bg-neutral-100 hover:bg-neutral-200/80 text-slate-800 transition-colors cursor-pointer shrink-0"
              title="Gunakan lokasi saat ini (Sekitar sini)"
            >
              <Navigation className="w-4.5 h-4.5 stroke-[2] text-[#1d64ec]" />
            </button>
          </div>

          {/* Place Results & Suggestions List */}
          <div className="flex-1 overflow-y-auto px-4 py-3 leading-snug scrollbar-none">
            {/* Custom Input Option if user typed something */}
            {locationSearchQuery.trim() && (
              <button
                type="button"
                onClick={() => {
                  setSelectedLocation(`📍 ${locationSearchQuery.trim()}`);
                  setShowLocationPicker(false);
                  setLocationSearchQuery('');
                }}
                className="w-full flex items-center justify-between py-3 px-3.5 mb-2.5 rounded-2xl bg-blue-50/80 hover:bg-blue-100/70 border border-blue-200/80 text-left transition-colors cursor-pointer shadow-2xs"
              >
                <div className="flex items-center gap-3 min-w-0">
                  <div className="w-8 h-8 rounded-xl bg-[#1d64ec] text-white flex items-center justify-center shrink-0">
                    <MapPin className="w-4 h-4 stroke-[2.2]" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-[14px] font-bold text-[#1d64ec] truncate">
                      Gunakan "{locationSearchQuery.trim()}"
                    </p>
                    <p className="text-[11.5px] text-blue-600/80 truncate">
                      Tambahkan sebagai lokasi baru
                    </p>
                  </div>
                </div>
                <ChevronRight className="w-4 h-4 text-[#1d64ec] shrink-0" />
              </button>
            )}

            <div className="text-[11.5px] font-bold text-neutral-400 uppercase tracking-wider px-1 mb-2">
              Rekomendasi Titik Temu SMKN 8
            </div>

            <ul className="divide-y divide-neutral-100 bg-white rounded-2xl border border-neutral-100 shadow-2xs overflow-hidden">
              {filteredPlaces.map((place) => (
                <li key={place.id}>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedLocation(place.name);
                      setShowLocationPicker(false);
                      setLocationSearchQuery('');
                    }}
                    className="w-full flex items-center justify-between py-3 px-3.5 hover:bg-neutral-50 active:bg-neutral-100/80 text-left transition-colors cursor-pointer group"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-8 h-8 rounded-xl bg-neutral-100 group-hover:bg-neutral-200/80 flex items-center justify-center text-slate-700 shrink-0 transition-colors">
                        <MapPin className="w-4 h-4 stroke-[2]" />
                      </div>
                      <div className="min-w-0">
                        <p className="text-[14px] font-semibold text-slate-900 truncate group-hover:text-[#1d64ec] transition-colors">
                          {place.name}
                        </p>
                        <p className="text-[12px] text-neutral-400 truncate">
                          {place.subtitle}
                        </p>
                      </div>
                    </div>

                    <span className="text-[11.5px] text-neutral-400 font-medium shrink-0 ml-2">
                      {place.distance}
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          </div>
        </div>
      ) : (
        /* ========================================================================= */
        /* 📝 MAIN THREAD / PRODUCT FORM SCREEN                                      */
        /* ========================================================================= */
        <>
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
          <div className="p-4 pb-48 overflow-y-auto flex-1 relative max-w-lg mx-auto w-full overscroll-contain scroll-pb-40 scrollbar-none">
            {/* 1. Top Section: Avatar + Username + Caption + Images + Action Icons */}
            <div className="flex gap-2.5 items-start">
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

              {/* Right Column */}
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
                        className="flex items-center gap-x-1 text-base h-[21px] leading-snug transition-all cursor-pointer select-none"
                      >
                        <span className="h-[21px] leading-snug flex items-center">
                          <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />
                        </span>
                        {selectedTopic ? (
                          <span
                            className={`flex items-center gap-x-1 font-semibold text-base h-[21px] leading-snug hover:opacity-80 transition-opacity ${
                              selectedTopic.isOfficial
                                ? 'text-[#1d64ec]'
                                : 'text-slate-900'
                            }`}
                          >
                            {selectedTopic.isOfficial &&
                              (selectedTopic.icon === 'party-popper' ? (
                                <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                              ) : (
                                <ThreadsTopicIcon className="w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" />
                              ))}
                            <span className="leading-snug">{selectedTopic.name}</span>
                          </span>
                        ) : (
                          <span className="text-neutral-400 hover:text-neutral-600 font-normal text-[14px] h-[21px] leading-snug flex items-center">
                            Pilih topik obrolan
                          </span>
                        )}
                      </button>

                      {/* Dropdown Popover */}
                      {showTopicDropdown && (
                        <>
                          <div
                            className="fixed inset-0 z-40"
                            onClick={() => setShowTopicDropdown(false)}
                          />
                          <div className="absolute top-full -right-6 sm:right-auto sm:left-0 mt-1.5 w-64 max-w-[calc(100vw-2rem)] bg-white rounded-2xl shadow-2xl border border-neutral-200/90 z-50 p-2 transform-gpu animate-in fade-in slide-in-from-top-2 duration-150 font-gt-standard">
                            <div className="px-3 py-1.5 text-[11px] font-bold text-neutral-400 uppercase tracking-wider">
                              Topik Populer SMKN 8
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
                                    {topic.isOfficial &&
                                      (topic.icon === 'party-popper' ? (
                                        <PartyPopper className="w-4 h-4 text-[#1d64ec] stroke-[2.2] shrink-0" />
                                      ) : (
                                        <ThreadsTopicIcon className="w-4 h-4 text-[#1d64ec] fill-current shrink-0" />
                                      ))}
                                    <div>
                                      <div
                                        className={`text-[14px] font-semibold ${
                                          topic.isOfficial ? 'text-[#1d64ec]' : 'text-slate-900'
                                        }`}
                                      >
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
                            </div>
                          </div>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Caption Textarea */}
                  <textarea
                    autoFocus
                    rows={1}
                    placeholder={
                      postMode === 'product'
                        ? 'Tulis deskripsi atau rincian jualan...'
                        : 'Apa yang baru?'
                    }
                    value={caption}
                    onFocus={handleInputFocus}
                    onChange={(e) => {
                      setCaption(e.target.value);
                      e.target.style.height = 'auto';
                      e.target.style.height = `${e.target.scrollHeight}px`;
                    }}
                    className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none bg-transparent leading-snug overflow-hidden"
                  />

                  {/* Location Tag (Matching Post Feed Card View Below Caption) */}
                  {selectedLocation && (
                    <div className="pt-1 pb-0.5 flex items-center gap-1.5 text-[13px] text-neutral-400 font-normal leading-snug animate-toast-pop select-none">
                      <MapPin className="w-3.5 h-3.5 text-neutral-400 stroke-[1.8] shrink-0" />
                      <span className="truncate">{selectedLocation}</span>
                      <button
                        type="button"
                        onClick={() => setSelectedLocation(null)}
                        className="p-0.5 rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-rose-500 transition-colors ml-0.5 cursor-pointer"
                        title="Hapus lokasi"
                      >
                        <X className="w-3 h-3 stroke-[2]" />
                      </button>
                    </div>
                  )}

                  {/* Smart Intent Auto-Detection Banner */}
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

                  {/* 📊 Polling UI (Matching Meta Threads Reference Styling) */}
                  {showPollBuilder && (
                    <div className="my-3 space-y-2 text-slate-900 text-base leading-snug transform-gpu animate-toast-pop select-none">
                      <div className="flex flex-col gap-y-2 leading-snug">
                        {pollOptions.map((opt, idx) => (
                          <div key={idx} className="relative flex items-center">
                            <input
                              type="text"
                              placeholder={`Opsi ${idx + 1}...`}
                              value={opt}
                              onChange={(e) => {
                                handleUpdatePollOption(idx, e.target.value);
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
                                onClick={() => handleRemovePollOption(idx)}
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
                            setShowPollBuilder(false);
                            setPollOptions(['', '', '']);
                          }}
                          className="inline-flex items-center h-[16.8px] text-rose-500 hover:text-rose-600 font-semibold text-xs leading-snug cursor-pointer hover:underline"
                        >
                          Hapus polling
                        </button>
                      </div>
                    </div>
                  )}

                  {/* 🎵 Voice Note Attachment Badge */}
                  {showVoiceNote && (
                    <div className="my-2.5 p-2.5 rounded-2xl bg-neutral-900 text-white flex items-center justify-between gap-3 shadow-md transform-gpu animate-toast-pop">
                      <div className="flex items-center gap-2.5 min-w-0">
                        <button
                          type="button"
                          className="w-7 h-7 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center text-white shrink-0 cursor-pointer"
                        >
                          <Play className="w-3.5 h-3.5 fill-current ml-0.5" />
                        </button>
                        <div className="flex items-center gap-1">
                          <Volume2 className="w-4 h-4 text-[#1d64ec] shrink-0" />
                          <span className="text-[12px] font-semibold">Rekaman Suara (0:14)</span>
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => setShowVoiceNote(false)}
                        className="p-1 text-white/60 hover:text-white transition-colors cursor-pointer"
                      >
                        <X className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  )}

                  {/* Uploaded Images Gallery & GIF Preview */}
                  {(images.length > 0 || selectedGif) && (
                    <div className="flex items-center gap-2 overflow-x-auto py-1.5 scrollbar-none">
                      {selectedGif && (
                        <div className="relative w-28 h-24 rounded-2xl overflow-hidden border-2 border-[#1d64ec] shadow-2xs group shrink-0">
                          <img
                            src={selectedGif}
                            alt="GIF Attachment"
                            className="w-full h-full object-cover"
                          />
                          <span className="absolute bottom-1 left-1 px-1.5 py-0.5 rounded-md bg-black/70 text-white text-[9px] font-bold">
                            GIF
                          </span>
                          <button
                            type="button"
                            onClick={() => setSelectedGif(null)}
                            className="absolute top-1.5 right-1.5 w-5 h-5 rounded-full bg-black/60 hover:bg-black text-white flex items-center justify-center cursor-pointer"
                          >
                            <X className="w-3 h-3 stroke-[2.5]" />
                          </button>
                        </div>
                      )}

                      {images.map((imgUrl, idx) => (
                        <div
                          key={idx}
                          className="relative w-24 h-24 rounded-2xl overflow-hidden border border-neutral-200 shadow-2xs group shrink-0"
                        >
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

                  {/* 😊 Quick Emoji Carousel Bar */}
                  {showEmojiBar && (
                    <div className="flex items-center gap-2 py-1.5 overflow-x-auto scrollbar-none animate-toast-pop select-none">
                      {PRESET_EMOJIS.map((em, idx) => (
                        <button
                          key={idx}
                          type="button"
                          onClick={() => handleInsertEmoji(em)}
                          className="w-8 h-8 rounded-xl bg-neutral-100 hover:bg-neutral-200/80 active:scale-90 flex items-center justify-center text-lg transition-transform cursor-pointer shrink-0"
                        >
                          {em}
                        </button>
                      ))}
                    </div>
                  )}

                  {/* 👾 Quick GIF Selector Carousel */}
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
                            onClick={() => {
                              setSelectedGif(gif.url);
                              setShowGifPicker(false);
                            }}
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

                  {/* 🌟 Pure Meta Threads 7-Icon Action Toolbar */}
                  <div className="flex items-center justify-between flex-wrap gap-2 pt-2.5 select-none">
                    {/* 7 Meta Threads Action Icons */}
                    <div className="flex items-center gap-1">
                      {/* 1. Galeri / Foto */}
                      <button
                        type="button"
                        onClick={handleAddDummyImage}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          images.length > 0
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
                        }`}
                        title="Unggah Foto"
                      >
                        <ImageIcon className="w-4.5 h-4.5 stroke-[2]" />
                      </button>

                      {/* 2. GIF Picker */}
                      <button
                        type="button"
                        onClick={() => {
                          setShowGifPicker(!showGifPicker);
                          setShowEmojiBar(false);
                        }}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          selectedGif || showGifPicker
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
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
                        onClick={() => {
                          setShowEmojiBar(!showEmojiBar);
                          setShowGifPicker(false);
                        }}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          showEmojiBar
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
                        }`}
                        title="Sisipkan Emoji"
                      >
                        <Smile className="w-4.5 h-4.5 stroke-[2]" />
                      </button>

                      {/* 4. Polling / Jajak Pendapat */}
                      <button
                        type="button"
                        onClick={() => setShowPollBuilder(!showPollBuilder)}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          showPollBuilder
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
                        }`}
                        title="Buat Jajak Pendapat / Polling"
                      >
                        <BarChart2 className="w-4.5 h-4.5 stroke-[2]" />
                      </button>

                      {/* 5. Topic Tagging (Threads 3-Dot Topic) */}
                      <button
                        type="button"
                        onClick={() => setShowTopicDropdown(!showTopicDropdown)}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          selectedTopic
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
                        }`}
                        title="Pilih Topik"
                      >
                        <ThreadsTopicIcon className="w-4 h-4 text-current fill-current" />
                      </button>

                      {/* 6. Tag Lokasi Sekolah -> Opens Dedicated "Pilih tempat" Screen */}
                      <button
                        type="button"
                        onClick={() => {
                          setShowLocationPicker(true);
                          setShowEmojiBar(false);
                          setShowGifPicker(false);
                        }}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          selectedLocation
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
                        }`}
                        title="Pilih Tempat / Lokasi COD Sekolah"
                      >
                        <MapPin className="w-4.5 h-4.5 stroke-[2]" />
                      </button>

                      {/* 7. Voice Note / Audio */}
                      <button
                        type="button"
                        onClick={() => setShowVoiceNote(!showVoiceNote)}
                        className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors cursor-pointer ${
                          showVoiceNote
                            ? 'bg-blue-50 text-[#1d64ec]'
                            : 'text-neutral-400 hover:text-slate-800 hover:bg-neutral-100'
                        }`}
                        title="Rekaman Suara / Audio"
                      >
                        <Music className="w-4.5 h-4.5 stroke-[2]" />
                      </button>
                    </div>

                    {/* Mode "Jual Barang" Toggle Switch Pill */}
                    <div
                      onClick={() => setPostMode(postMode === 'product' ? 'thread' : 'product')}
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
                </div>
              </div>
            </div>

            {/* 2. Chained Sub-Threads (Utas Bersambung) */}
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
                      onClick={() => handleRemoveSubThread(st.id)}
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
                    onFocus={handleInputFocus}
                    onChange={(e) => {
                      handleUpdateSubThreadCaption(st.id, e.target.value);
                      e.target.style.height = 'auto';
                      e.target.style.height = `${e.target.scrollHeight}px`;
                    }}
                    className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none bg-transparent leading-snug overflow-hidden"
                  />

                  {st.images.length > 0 && (
                    <div className="flex items-center gap-2 overflow-x-auto py-1.5 scrollbar-none">
                      {st.images.map((img, imgIdx) => (
                        <div
                          key={imgIdx}
                          className="relative w-20 h-20 rounded-2xl overflow-hidden border border-neutral-200 shrink-0"
                        >
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

            {/* 3. Bottom Interactive "Tambahkan ke utas" Chaining Button */}
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

            {/* 4. Product Mode Fields (Original Rich Seller Form) */}
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
                    onFocus={handleInputFocus}
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
                      onFocus={handleInputFocus}
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
                    onFocus={handleInputFocus}
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
                      onFocus={handleInputFocus}
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

          {/* Floating Bottom Sticky Action Footer */}
          <div
            className="fixed bottom-0 inset-x-0 bg-white/95 backdrop-blur-md border-t border-neutral-200/80 px-4 py-3 z-30 flex items-center justify-between max-w-lg mx-auto shadow-lg"
            style={{ paddingBottom: 'max(12px, env(safe-area-inset-bottom, 12px))' }}
          >
            <span className="text-[13px] text-neutral-500 font-normal">
              Siapa pun dapat membalas & mengutip
            </span>

            <button
              type="button"
              onClick={handleSubmit}
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
        </>
      )}

      {/* Discard / Save Draft Alert Dialog */}
      {showDiscardAlert && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs">
          <div className="w-full max-w-xs bg-white rounded-3xl p-5 shadow-2xl border border-neutral-100 text-center space-y-4 font-gt-standard">
            <div className="space-y-1">
              <h3 className="text-[17px] font-bold text-slate-900">Buang Utas?</h3>
              <p className="text-[13.5px] text-neutral-500">
                Anda dapat membuang atau menyimpan utas ini sebagai draf.
              </p>
            </div>

            <div className="space-y-2">
              <button
                type="button"
                onClick={handleConfirmDiscard}
                className="w-full h-11 rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-bold text-[14px] transition-colors cursor-pointer"
              >
                Buang
              </button>
              <button
                type="button"
                onClick={handleSaveDraft}
                className="w-full h-11 rounded-2xl bg-neutral-100 hover:bg-neutral-200 text-slate-800 font-semibold text-[14px] transition-colors cursor-pointer"
              >
                Simpan Draf
              </button>
              <button
                type="button"
                onClick={() => setShowDiscardAlert(false)}
                className="w-full h-10 rounded-2xl text-neutral-500 hover:text-slate-800 font-medium text-[13.5px] transition-colors cursor-pointer"
              >
                Batal
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Saved Drafts Bottom Sheet */}
      {showDraftsSheet && (
        <div className="fixed inset-0 z-[60] flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-xs">
          <div className="w-full max-w-md bg-white rounded-t-3xl sm:rounded-3xl p-5 shadow-2xl border border-neutral-100 space-y-4 font-gt-standard max-h-[80vh] overflow-y-auto">
            <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
              <h3 className="text-[16px] font-bold text-slate-900">Draf Tersimpan</h3>
              <button
                type="button"
                onClick={() => setShowDraftsSheet(false)}
                className="p-1 rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-slate-800 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {savedDraft ? (
              <div className="p-3.5 rounded-2xl bg-neutral-50 border border-neutral-200 flex items-center justify-between gap-3">
                <div
                  className="flex-1 min-w-0 cursor-pointer"
                  onClick={() => {
                    if (savedDraft.caption) setCaption(savedDraft.caption);
                    if (savedDraft.images) setImages(savedDraft.images);
                    if (savedDraft.selectedTopic) setSelectedTopic(savedDraft.selectedTopic);
                    setShowDraftsSheet(false);
                  }}
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
                  onClick={() => {
                    localStorage.removeItem('snapan_thread_draft');
                    setSavedDraft(null);
                  }}
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
      )}
    </div>
  );
};
