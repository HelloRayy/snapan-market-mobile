import React, { useState, useEffect } from 'react';
import { X, Image as ImageIcon, MapPin, Sparkles, Play, Volume2 } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { triggerHaptic } from '@/utils/haptics';
import { ConfirmActionModal } from '@/ui/components/ui/ConfirmActionModal';
import { TopicOption, RICH_SCHOOL_PLACES } from './create-post/types';
import { CreatePostLocationPicker } from './create-post/CreatePostLocationPicker';
import { CreatePostProductFields } from './create-post/CreatePostProductFields';
import { CreatePostHeader } from './create-post/CreatePostHeader';
import { CreatePostFooter } from './create-post/CreatePostFooter';
import { CreatePostDraftsSheet } from './create-post/CreatePostDraftsSheet';
import { CreatePostMediaToolbar } from './create-post/CreatePostMediaToolbar';
import { CreatePostTopicSelector } from './create-post/CreatePostTopicSelector';
import { CreatePostPollBuilder } from './create-post/CreatePostPollBuilder';
import { CreatePostSubThreadsList } from './create-post/CreatePostSubThreadsList';
import { usePostDrafts } from './create-post/usePostDrafts';

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
  const [showTopicDropdown, setShowTopicDropdown] = useState(false);

  // Action States
  const [showEmojiBar, setShowEmojiBar] = useState(false);
  const [showLocationPicker, setShowLocationPicker] = useState(false);
  const [locationSearchQuery, setLocationSearchQuery] = useState('');
  const [selectedLocation, setSelectedLocation] = useState<string | null>(null);
  const [showGifPicker, setShowGifPicker] = useState(false);
  const [selectedGif, setSelectedGif] = useState<string | null>(null);
  const [showPollBuilder, setShowPollBuilder] = useState(false);
  const [pollOptions, setPollOptions] = useState<string[]>(['', '', '']);
  const [showVoiceNote, setShowVoiceNote] = useState(false);

  // Drafts Hook
  const {
    savedDraft,
    showDraftsSheet,
    setShowDraftsSheet,
    showDiscardAlert,
    setShowDiscardAlert,
    showDeleteDraftConfirm,
    setShowDeleteDraftConfirm,
    refreshSavedDraft,
    saveCurrentDraft,
    deleteSavedDraft,
  } = usePostDrafts();

  useEffect(() => {
    if (isOpen) {
      setPostMode(initialMode);
      refreshSavedDraft();
    }
  }, [isOpen, initialMode, refreshSavedDraft]);

  const handleRestoreDraft = () => {
    if (!savedDraft) return;
    setCaption(savedDraft.caption || '');
    setImages(savedDraft.images || []);
    setProductTitle(savedDraft.productTitle || '');
    setPriceInput(savedDraft.priceInput || '');
    setPostMode(savedDraft.postMode || 'thread');
    setSubThreads(savedDraft.subThreads || []);
    setSelectedTopic(savedDraft.selectedTopic || null);
    setShowDraftsSheet(false);
    triggerHaptic('selection');
  };

  const handleInsertEmoji = (emoji: string) => {
    setCaption((prev) => prev + emoji);
  };

  const handleAddDummyImage = () => {
    const dummyPool = [
      'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&q=80',
      'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600&q=80',
      'https://images.unsplash.com/photo-1588702547923-7093a6c3ba33?w=600&q=80',
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&q=80',
    ];
    const pick = dummyPool[images.length % dummyPool.length];
    setImages((prev) => [...prev, pick]);
    triggerHaptic('light');
  };

  const handleRemoveImage = (index: number) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
    triggerHaptic('light');
  };

  const handleAddSubThread = () => {
    setSubThreads((prev) => [...prev, { id: `sub-${Date.now()}`, caption: '', images: [] }]);
    triggerHaptic('light');
  };

  const handleRemoveSubThread = (id: string) => {
    setSubThreads((prev) => prev.filter((st) => st.id !== id));
    triggerHaptic('light');
  };

  const handleUpdateSubThreadCaption = (id: string, text: string) => {
    setSubThreads((prev) =>
      prev.map((st) => (st.id === id ? { ...st, caption: text } : st))
    );
  };

  const handleAddSubThreadImage = (id: string) => {
    const sampleImage = 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=600&q=80';
    setSubThreads((prev) =>
      prev.map((st) => (st.id === id ? { ...st, images: [...st.images, sampleImage] } : st))
    );
    triggerHaptic('light');
  };

  const handleRemoveSubThreadImage = (subThreadId: string, imgIndex: number) => {
    setSubThreads((prev) =>
      prev.map((st) =>
        st.id === subThreadId
          ? { ...st, images: st.images.filter((_, idx) => idx !== imgIndex) }
          : st
      )
    );
    triggerHaptic('light');
  };

  const isSellingKeywordDetected =
    postMode === 'thread' &&
    /\b(jual|harga|rp|nego|preloved|titip|ready|cod)\b/i.test(caption);

  const filteredPlaces = RICH_SCHOOL_PLACES.filter(
    (p) =>
      p.name.toLowerCase().includes(locationSearchQuery.toLowerCase()) ||
      p.subtitle.toLowerCase().includes(locationSearchQuery.toLowerCase())
  );

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
      triggerHaptic('success');
      onSubmitPost(newPost);
    }

    resetAndClose();
  };

  const resetAndClose = () => {
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
      {showLocationPicker ? (
        <CreatePostLocationPicker
          onBack={() => setShowLocationPicker(false)}
          searchQuery={locationSearchQuery}
          onSearchChange={setLocationSearchQuery}
          onSelectLocation={(loc) => {
            setSelectedLocation(loc);
            setShowLocationPicker(false);
            setLocationSearchQuery('');
          }}
          filteredPlaces={filteredPlaces}
        />
      ) : (
        <>
          <CreatePostHeader
            postMode={postMode}
            onCancel={handleCancelClick}
            onOpenDrafts={() => {
              refreshSavedDraft();
              setShowDraftsSheet(true);
            }}
            hasSavedDraft={!!savedDraft}
          />

          <div data-lenis-prevent className="p-4 pb-48 overflow-y-auto flex-1 relative max-w-lg mx-auto w-full overscroll-contain scroll-pb-40 scrollbar-none touch-pan-y">
            <div className="flex gap-2.5 items-start">
              <div className="flex flex-col items-center shrink-0 w-8 self-stretch py-0.5">
                <div className="w-8 h-8 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0">
                  <img src={currentUser.avatar} alt={currentUser.name} className="w-full h-full object-cover" />
                </div>
                <div className="w-[1.5px] bg-neutral-200 flex-1 my-1 min-h-[14px]" />
              </div>

              <div className="flex-1 min-w-0 flex flex-col justify-between">
                <div>
                  <div className="flex items-center gap-1.5 flex-wrap relative leading-none">
                    <span className="font-bold text-[14.5px] text-slate-900">{currentUser.username}</span>
                    <CreatePostTopicSelector
                      selectedTopic={selectedTopic}
                      onSelectTopic={setSelectedTopic}
                      showDropdown={showTopicDropdown}
                      onToggleDropdown={() => setShowTopicDropdown(!showTopicDropdown)}
                      onCloseDropdown={() => setShowTopicDropdown(false)}
                    />
                  </div>

                  <textarea
                    autoFocus
                    rows={1}
                    placeholder={postMode === 'product' ? 'Tulis deskripsi atau rincian jualan...' : 'Apa yang baru?'}
                    value={caption}
                    onFocus={handleInputFocus}
                    onChange={(e) => {
                      setCaption(e.target.value);
                      e.target.style.height = 'auto';
                      e.target.style.height = `${e.target.scrollHeight}px`;
                    }}
                    className="w-full mt-1 text-[14.5px] text-slate-900 placeholder:text-slate-400 focus:outline-none resize-none bg-transparent leading-snug overflow-hidden"
                  />

                  {selectedLocation && (
                    <div className="pt-1.5 pb-0.5 flex items-center gap-1.5 text-[13px] text-slate-600 font-medium leading-snug animate-toast-pop select-none">
                      <MapPin className="w-3.5 h-3.5 text-slate-600 stroke-[2] shrink-0" />
                      <span className="truncate">{selectedLocation}</span>
                      <button
                        type="button"
                        onClick={() => setSelectedLocation(null)}
                        className="p-0.5 rounded-full hover:bg-neutral-200/80 text-slate-500 hover:text-rose-600 transition-colors ml-0.5 cursor-pointer"
                        title="Hapus lokasi"
                      >
                        <X className="w-3 h-3 stroke-[2.2]" />
                      </button>
                    </div>
                  )}

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

                  {showPollBuilder && (
                    <CreatePostPollBuilder
                      pollOptions={pollOptions}
                      setPollOptions={setPollOptions}
                      onClose={() => setShowPollBuilder(false)}
                    />
                  )}

                  {showVoiceNote && (
                    <div className="my-2.5 p-2.5 rounded-2xl bg-neutral-900 text-white flex items-center justify-between gap-3 shadow-md transform-gpu animate-toast-pop">
                      <div className="flex items-center gap-2.5 min-w-0">
                        <button type="button" className="w-7 h-7 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center text-white shrink-0 cursor-pointer">
                          <Play className="w-3.5 h-3.5 fill-current ml-0.5" />
                        </button>
                        <div className="flex items-center gap-1">
                          <Volume2 className="w-4 h-4 text-[#1d64ec] shrink-0" />
                          <span className="text-[12px] font-semibold">Rekaman Suara (0:14)</span>
                        </div>
                      </div>
                      <button type="button" onClick={() => setShowVoiceNote(false)} className="p-1 text-white/60 hover:text-white transition-colors cursor-pointer">
                        <X className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  )}

                  {(images.length > 0 || selectedGif) && (
                    <div className="-ml-[52px] pl-[52px] -mr-4 pr-4 w-[calc(100%+68px)] flex items-center gap-2.5 overflow-x-auto py-2 scrollbar-none touch-pan-x select-none">
                      {selectedGif && (
                        <div className="relative w-28 h-24 rounded-2xl overflow-hidden border-2 border-[#1d64ec] shadow-2xs group shrink-0">
                          <img src={selectedGif} alt="GIF Attachment" className="w-full h-full object-cover" />
                          <span className="absolute bottom-1 left-1 px-1.5 py-0.5 rounded-md bg-black/70 text-white text-[9px] font-bold">GIF</span>
                          <button type="button" onClick={() => setSelectedGif(null)} className="absolute top-1.5 right-1.5 w-5 h-5 rounded-full bg-black/60 hover:bg-black text-white flex items-center justify-center cursor-pointer">
                            <X className="w-3 h-3 stroke-[2.5]" />
                          </button>
                        </div>
                      )}

                      {images.map((imgUrl, idx) => (
                        <div key={idx} className="relative w-24 h-24 rounded-2xl overflow-hidden border border-neutral-200 shadow-2xs group shrink-0">
                          <img src={imgUrl} alt={`Upload preview ${idx + 1}`} className="w-full h-full object-cover" />
                          <button type="button" onClick={() => handleRemoveImage(idx)} className="absolute top-1.5 right-1.5 w-5.5 h-5.5 rounded-full bg-black/60 hover:bg-black text-white flex items-center justify-center backdrop-blur-xs transition-transform active:scale-90 cursor-pointer">
                            <X className="w-3 h-3 stroke-[2.5]" />
                          </button>
                        </div>
                      ))}

                      <button
                        type="button"
                        onClick={handleAddDummyImage}
                        className="w-24 h-24 rounded-2xl border-2 border-dashed border-neutral-300 hover:border-blue-500 bg-neutral-50 hover:bg-blue-50/30 flex flex-col items-center justify-center gap-1 text-slate-500 hover:text-[#1d64ec] transition-colors shrink-0 cursor-pointer"
                      >
                        <ImageIcon className="w-5 h-5 stroke-[1.8]" />
                        <span className="text-[11.5px] font-semibold">+ Tambah</span>
                      </button>
                    </div>
                  )}

                  <CreatePostMediaToolbar
                    hasImages={images.length > 0}
                    onAddImage={handleAddDummyImage}
                    showGifPicker={showGifPicker}
                    onToggleGifPicker={() => {
                      setShowGifPicker(!showGifPicker);
                      setShowEmojiBar(false);
                    }}
                    selectedGif={selectedGif}
                    onSelectGif={(url) => {
                      setSelectedGif(url);
                      setShowGifPicker(false);
                    }}
                    showEmojiBar={showEmojiBar}
                    onToggleEmojiBar={() => {
                      setShowEmojiBar(!showEmojiBar);
                      setShowGifPicker(false);
                    }}
                    onInsertEmoji={handleInsertEmoji}
                    showPollBuilder={showPollBuilder}
                    onTogglePollBuilder={() => setShowPollBuilder(!showPollBuilder)}
                    showTopicDropdown={showTopicDropdown}
                    onToggleTopicDropdown={() => setShowTopicDropdown(!showTopicDropdown)}
                    selectedTopic={selectedTopic}
                    onOpenLocationPicker={() => {
                      setShowLocationPicker(true);
                      setShowEmojiBar(false);
                      setShowGifPicker(false);
                    }}
                    selectedLocation={selectedLocation}
                    showVoiceNote={showVoiceNote}
                    onToggleVoiceNote={() => setShowVoiceNote(!showVoiceNote)}
                    postMode={postMode}
                    onTogglePostMode={() => setPostMode(postMode === 'product' ? 'thread' : 'product')}
                  />
                </div>
              </div>
            </div>

            <CreatePostSubThreadsList
              subThreads={subThreads}
              currentUser={currentUser}
              onRemoveSubThread={handleRemoveSubThread}
              onUpdateCaption={handleUpdateSubThreadCaption}
              onAddSubThreadImage={handleAddSubThreadImage}
              onRemoveSubThreadImage={handleRemoveSubThreadImage}
              onAddSubThread={handleAddSubThread}
              onFocusInput={handleInputFocus}
            />

            {postMode === 'product' && (
              <CreatePostProductFields
                productTitle={productTitle}
                onProductTitleChange={setProductTitle}
                productDescription={productDescription}
                onProductDescriptionChange={setProductDescription}
                priceInput={priceInput}
                onPriceInputChange={setPriceInput}
                locationInput={locationInput}
                onLocationInputChange={setLocationInput}
                onInputFocus={handleInputFocus}
              />
            )}
          </div>

          <CreatePostFooter
            canPost={canPost}
            onSubmit={handleSubmit}
          />

          <ConfirmActionModal
            isOpen={showDiscardAlert}
            onClose={() => setShowDiscardAlert(false)}
            title="Simpan atau buang draf?"
            description="Jika dibuang, teks dan media yang kamu masukkan akan hilang."
            actions={[
              {
                label: 'Simpan Draf',
                variant: 'primary',
                onClick: () => {
                  saveCurrentDraft({
                    caption,
                    subThreads,
                    productTitle,
                    priceInput,
                    postMode,
                    images,
                    selectedTopic,
                  });
                  resetAndClose();
                },
              },
              {
                label: 'Buang',
                variant: 'destructive',
                onClick: resetAndClose,
              },
              {
                label: 'Batal',
                variant: 'cancel',
                onClick: () => setShowDiscardAlert(false),
              },
            ]}
          />

          <CreatePostDraftsSheet
            isOpen={showDraftsSheet}
            onClose={() => setShowDraftsSheet(false)}
            savedDraft={savedDraft}
            onSelectDraft={handleRestoreDraft}
            onRequestDeleteDraft={() => setShowDeleteDraftConfirm(true)}
          />

          <ConfirmActionModal
            isOpen={showDeleteDraftConfirm}
            onClose={() => setShowDeleteDraftConfirm(false)}
            title="Hapus draf?"
            description="Draf ini akan dihapus permanen dan tidak dapat dipulihkan."
            actions={[
              {
                label: 'Hapus Draf',
                variant: 'destructive',
                onClick: () => {
                  deleteSavedDraft();
                  setShowDeleteDraftConfirm(false);
                  setShowDraftsSheet(false);
                },
              },
              {
                label: 'Batal',
                variant: 'cancel',
                onClick: () => setShowDeleteDraftConfirm(false),
              },
            ]}
          />
        </>
      )}
    </div>
  );
};
