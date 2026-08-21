import React, { useState, useRef, useEffect } from 'react';
import {
  ArrowLeft,
  Plus,
  ChevronRight,
  Check,
  X,
} from 'lucide-react';
import { motion } from 'framer-motion';

export interface EditProfileData {
  name: string;
  username: string;
  bio: string;
  classGroup: string;
  avatar: string;
  interests?: string;
  link?: string;
}

interface EditProfilePageProps {
  initialData: EditProfileData;
  onBack: () => void;
  onSave: (data: EditProfileData) => void;
}

const PRESET_AVATARS = [
  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&q=80',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&q=80',
  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300&q=80',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&q=80',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&q=80',
];

export const EditProfilePage: React.FC<EditProfilePageProps> = ({
  initialData,
  onBack,
  onSave,
}) => {
  const [name, setName] = useState(initialData.name);
  const [username, setUsername] = useState(initialData.username.replace(/^@/, ''));
  const [bio, setBio] = useState(initialData.bio);
  const [classGroup, setClassGroup] = useState(initialData.classGroup);
  const [avatar, setAvatar] = useState(initialData.avatar);
  const [interests, setInterests] = useState(initialData.interests || '💻 Web PWA, 🎨 UI/UX, 👕 Preloved, ⚡ Joki Coding, 🍱 Kuliner');
  const [link, setLink] = useState(initialData.link || 'https://instagram.com/' + initialData.username.replace(/^@/, ''));
  
  // Signature Profile Toggles
  const [showSalesStats, setShowSalesStats] = useState(true);
  const [showAvatarPicker, setShowAvatarPicker] = useState(false);
  const [customTagInput, setCustomTagInput] = useState('');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
  };

  // Convert comma-separated string to tag array
  const activeTags = interests
    .split(',')
    .map((t) => t.trim())
    .filter(Boolean);

  const handleAddTag = (tagToAdd: string) => {
    const cleanTag = tagToAdd.trim();
    if (!cleanTag) return;
    if (activeTags.includes(cleanTag)) {
      showToast('Minat ini sudah ada di profil kamu');
      return;
    }
    const nextTags = [...activeTags, cleanTag];
    setInterests(nextTags.join(', '));
    setCustomTagInput('');
    showToast(`Ditambahkan: ${cleanTag}`);
  };

  const handleRemoveTag = (tagToRemove: string) => {
    const nextTags = activeTags.filter((t) => t !== tagToRemove);
    setInterests(nextTags.join(', '));
  };

  // Handle Local Photo File Selection
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        if (event.target?.result) {
          setAvatar(event.target.result as string);
          showToast('Foto profil diperbarui! 📸');
        }
      };
      reader.readAsDataURL(file);
    }
  };

  const handleSave = () => {
    const cleanName = name.trim() || initialData.name;
    const cleanUsername = username.trim().toLowerCase().replace(/\s+/g, '') || initialData.username;
    const cleanClassGroup = classGroup.trim() || initialData.classGroup;

    onSave({
      name: cleanName,
      username: cleanUsername,
      bio: bio.trim(),
      classGroup: cleanClassGroup,
      avatar,
      interests: interests.trim(),
      link: link.trim(),
    });
  };

  const handleDiscard = () => {
    setName(initialData.name);
    setUsername(initialData.username.replace(/^@/, ''));
    setBio(initialData.bio);
    setClassGroup(initialData.classGroup);
    setAvatar(initialData.avatar);
    setInterests(initialData.interests || '');
    setLink(initialData.link || '');
    onBack();
  };

  // Android / iOS Hardware Back Integration
  useEffect(() => {
    const handlePop = () => {
      onBack();
    };
    window.addEventListener('popstate', handlePop);
    return () => window.removeEventListener('popstate', handlePop);
  }, [onBack]);

  return (
    <div className="fixed inset-0 z-[100] bg-white text-slate-900 overflow-y-auto flex flex-col font-gt-standard">
      {/* Top Header Bar */}
      <header
        className="sticky top-0 z-30 bg-white/95 backdrop-blur-md border-b border-neutral-100 px-4 h-14 flex items-center justify-between"
        style={{ paddingTop: 'env(safe-area-inset-top, 0px)' }}
      >
        <button
          type="button"
          onClick={onBack}
          className="w-10 h-10 -ml-1 rounded-full hover:bg-neutral-100 active:bg-neutral-200 flex items-center justify-center text-slate-800 transition-all cursor-pointer active:scale-90"
          aria-label="Kembali"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.25]" />
        </button>

        <h1 className="text-[17px] font-bold text-slate-900 tracking-tight">
          Edit Profile
        </h1>

        <div className="w-10" />
      </header>

      {/* Main Content Form (Clean Threads Border-Bottom Divider Layout) */}
      <main className="flex-1 max-w-[540px] w-full mx-auto px-5 pt-3 pb-32">
        <div className="space-y-0 text-slate-900">
          {/* Row 1: Nama & Avatar on Right */}
          <div className="flex items-center justify-between py-4 border-b border-neutral-200/80">
            <div className="flex-1 pr-4">
              <label className="block text-[14px] font-semibold text-slate-900">
                Nama
              </label>
              <input
                type="text"
                value={name}
                maxLength={50}
                onChange={(e) => setName(e.target.value)}
                placeholder="Rayyy"
                className="w-full mt-0.5 text-[15.5px] font-normal text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
              />
            </div>

            {/* Avatar on Right with Camera/Plus Badge */}
            <div className="flex flex-col items-center shrink-0">
              <div
                onClick={() => fileInputRef.current?.click()}
                className="relative group cursor-pointer"
              >
                <div className="w-13 h-13 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs bg-neutral-100 active:scale-95 transition-transform">
                  <img
                    src={avatar}
                    alt={name}
                    className="w-full h-full object-cover"
                  />
                </div>

                <div className="absolute -bottom-0.5 -right-0.5 w-5.5 h-5.5 rounded-full bg-[#101010] text-white flex items-center justify-center border-2 border-white shadow-2xs">
                  <Plus className="w-3 h-3 stroke-[2.5]" />
                </div>
              </div>

              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleFileChange}
              />
            </div>
          </div>

          {/* Quick Preset Avatars Picker Dropdown */}
          <div className="py-2 border-b border-neutral-200/80">
            <button
              type="button"
              onClick={() => setShowAvatarPicker(!showAvatarPicker)}
              className="text-[12px] font-semibold text-[#1d64ec] hover:underline cursor-pointer flex items-center justify-between w-full py-1"
            >
              <span>{showAvatarPicker ? 'Tutup Pilihan Avatar' : '⚡ Ganti dengan Preset Avatar'}</span>
              <ChevronRight className={`w-3.5 h-3.5 text-[#1d64ec] transition-transform ${showAvatarPicker ? 'rotate-90' : ''}`} />
            </button>

            {showAvatarPicker && (
              <motion.div
                initial={{ opacity: 0, y: -4 }}
                animate={{ opacity: 1, y: 0 }}
                className="flex items-center gap-2.5 pt-2 pb-2 overflow-x-auto max-w-full scrollbar-none"
              >
                {PRESET_AVATARS.map((pic, idx) => (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => {
                      setAvatar(pic);
                      showToast('Preset avatar dipilih! ✨');
                    }}
                    className={`relative w-10 h-10 rounded-full overflow-hidden border-2 transition-all cursor-pointer shrink-0 ${
                      avatar === pic ? 'border-[#1d64ec] ring-2 ring-[#1d64ec]/30 scale-105' : 'border-neutral-200 hover:opacity-80'
                    }`}
                  >
                    <img src={pic} alt={`Preset ${idx + 1}`} className="w-full h-full object-cover" />
                    {avatar === pic && (
                      <div className="absolute inset-0 bg-[#1d64ec]/30 flex items-center justify-center">
                        <Check className="w-3.5 h-3.5 text-white stroke-[3]" />
                      </div>
                    )}
                  </button>
                ))}
              </motion.div>
            )}
          </div>

          {/* Row 2: Nama pengguna */}
          <div className="py-4 border-b border-neutral-200/80">
            <label className="block text-[14px] font-semibold text-slate-900">
              Nama pengguna
            </label>
            <div className="flex items-center mt-0.5">
              <span className="text-[15.5px] font-normal text-slate-400 mr-0.5 select-none">@</span>
              <input
                type="text"
                value={username}
                maxLength={30}
                onChange={(e) => setUsername(e.target.value.toLowerCase().replace(/[^a-z0-9._]/g, ''))}
                placeholder="radityarayhannnn"
                className="w-full text-[15.5px] font-normal text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
              />
            </div>
          </div>

          {/* Row 3: Bio */}
          <div className="py-4 border-b border-neutral-200/80">
            <div className="flex items-center justify-between">
              <label className="text-[14px] font-semibold text-slate-900">
                Bio
              </label>
              <span className="text-[11px] text-neutral-400 tabular-nums">
                {bio.length}/150
              </span>
            </div>
            <textarea
              rows={3}
              maxLength={150}
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              placeholder="16 y/o.&#10;Frontend Developer & UI/UX Designer.&#10;Passionate about creating intuitive interfaces and exploring AI."
              className="w-full mt-1 text-[15px] font-normal text-slate-900 bg-transparent focus:outline-none resize-none leading-relaxed placeholder:text-neutral-400"
            />
          </div>

          {/* Row 4: Kelas & Jurusan */}
          <div className="py-4 border-b border-neutral-200/80">
            <label className="block text-[14px] font-semibold text-slate-900">
              Kelas & Jurusan
            </label>
            <input
              type="text"
              value={classGroup}
              maxLength={40}
              onChange={(e) => setClassGroup(e.target.value)}
              placeholder="XII PPLG 1"
              className="w-full mt-0.5 text-[15.5px] font-normal text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
            />
          </div>

          {/* Row 5: Minat (Simple & Clean 1-Line Tag Input with Signature UI Colors) */}
          <div className="py-4 border-b border-neutral-200/80">
            <div className="flex items-center justify-between mb-2">
              <label className="text-[14px] font-semibold text-slate-900">
                Minat
              </label>
              <span className="text-[11.5px] text-neutral-400 font-normal">
                Pisahkan dengan koma / enter
              </span>
            </div>

            {/* 1-Line Seamless Badges + Input Flow */}
            <div className="flex items-center flex-wrap gap-1.5 min-h-[36px]">
              {activeTags.map((tag, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => handleRemoveTag(tag)}
                  className="inline-flex items-center gap-1.5 py-1 px-3 bg-neutral-100/90 hover:bg-rose-50 hover:border-rose-200/80 hover:text-rose-600 text-slate-800 text-[13px] font-medium rounded-full border border-neutral-200/80 transition-all select-none cursor-pointer active:scale-95 group shadow-2xs"
                  title={`Ketuk untuk menghapus ${tag}`}
                >
                  <span>{tag}</span>
                  <X className="w-3 h-3 stroke-[2.2] text-neutral-400 group-hover:text-rose-600 transition-colors -mr-0.5" />
                </button>
              ))}

              {/* Clean 1-Line Inline Input */}
              <input
                type="text"
                value={customTagInput}
                onChange={(e) => {
                  const val = e.target.value;
                  if (val.includes(',') || val.includes('\n')) {
                    const parts = val.split(/[,\\n]/);
                    parts.forEach((p) => handleAddTag(p));
                    setCustomTagInput('');
                  } else {
                    setCustomTagInput(val);
                  }
                }}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    e.preventDefault();
                    if (customTagInput.trim()) {
                      handleAddTag(customTagInput);
                      setCustomTagInput('');
                    }
                  } else if (e.key === 'Backspace' && !customTagInput && activeTags.length > 0) {
                    handleRemoveTag(activeTags[activeTags.length - 1]);
                  }
                }}
                placeholder="+ Tambah minat..."
                className="text-[13.5px] text-slate-900 placeholder:text-neutral-400 bg-transparent focus:outline-none min-w-[120px] flex-1 py-1"
              />
            </div>
          </div>

          {/* Row 6: Tautan */}
          <div className="py-4 border-b border-neutral-200/80">
            <div className="flex items-center justify-between">
              <label className="text-[14px] font-semibold text-slate-900">
                Tautan
              </label>
              <ChevronRight className="w-4 h-4 text-neutral-400 shrink-0" />
            </div>
            <input
              type="text"
              value={link}
              maxLength={100}
              onChange={(e) => setLink(e.target.value)}
              placeholder="https://wa.me/628123456789 atau https://instagram.com/..."
              className="w-full mt-0.5 text-[15.5px] font-normal text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
            />
          </div>

          {/* Row 7: Toggle - Tampilkan statistik penjualan */}
          <div className="flex items-center justify-between py-4 border-b border-neutral-200/80 select-none">
            <span className="text-[14.5px] font-semibold text-slate-900">
              Tampilkan statistik penjualan
            </span>
            <div
              onClick={() => setShowSalesStats(!showSalesStats)}
              className={`w-10 h-6 rounded-full p-0.5 transition-colors duration-200 flex items-center shrink-0 cursor-pointer ${
                showSalesStats ? 'bg-[#1d64ec]' : 'bg-neutral-300'
              }`}
            >
              <div
                className={`w-5 h-5 rounded-full bg-white shadow-md transition-transform duration-200 transform-gpu ${
                  showSalesStats ? 'translate-x-4' : 'translate-x-0'
                }`}
              />
            </div>
          </div>

          {/* Row 8: Privasi profil */}
          <div className="flex items-center justify-between py-4 select-none">
            <span className="text-[14.5px] font-semibold text-slate-900">
              Privasi profil
            </span>
            <span className="text-[13.5px] text-neutral-400 flex items-center gap-0.5 font-normal">
              Publik <ChevronRight className="w-3.5 h-3.5" />
            </span>
          </div>
        </div>
      </main>

      {/* Floating Bottom Dual Action CTA (Sticky Bar with Kumo UI Styling) */}
      <footer
        className="fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-neutral-100 px-5 py-3.5 shadow-lg"
        style={{ paddingBottom: 'max(14px, env(safe-area-inset-bottom, 14px))' }}
      >
        <div className="max-w-[540px] mx-auto flex items-center gap-3">
          {/* Discard Button (Left - Kumo UI Secondary Pill) */}
          <button
            type="button"
            onClick={handleDiscard}
            className="relative flex items-center justify-center flex-1 h-12 px-5 rounded-full text-slate-800 font-bold text-[15px] bg-white border border-neutral-200/90 shadow-2xs hover:bg-neutral-50 active:scale-[0.98] transition-all overflow-hidden cursor-pointer select-none"
          >
            <span className="absolute inset-0 rounded-full bg-gradient-to-b from-white/90 to-neutral-50/50 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.9)] pointer-events-none" />
            <span className="relative z-10">Discard</span>
          </button>

          {/* Save Button (Right - Kumo UI Primary Dark Pill) */}
          <button
            type="button"
            onClick={handleSave}
            className="relative flex items-center justify-center flex-1 h-12 px-5 rounded-full text-white font-bold text-[15px] bg-[#101010] hover:bg-black border border-black/90 shadow-md shadow-black/20 active:scale-[0.98] transition-all overflow-hidden cursor-pointer select-none"
          >
            <span className="absolute inset-0 rounded-full bg-gradient-to-b from-white/20 to-transparent shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
            <span className="relative z-10">Save</span>
          </button>
        </div>
      </footer>

      {/* Floating Feedback Toast */}
      {toastMessage && (
        <div className="fixed bottom-24 left-1/2 -translate-x-1/2 z-[99999] px-4 py-2 rounded-full bg-slate-900 text-white text-xs font-semibold shadow-2xl border border-white/20 backdrop-blur-md animate-in fade-in slide-in-from-bottom-3 duration-200 pointer-events-none">
          {toastMessage}
        </div>
      )}
    </div>
  );
};
