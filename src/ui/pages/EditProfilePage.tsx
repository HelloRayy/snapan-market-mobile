import React, { useState, useRef, useEffect } from 'react';
import {
  ArrowLeft,
  Pencil,
  Plus,
  MapPin,
  Sparkles,
  Link2,
  Check,
  AtSign,
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
  const [interests, setInterests] = useState(initialData.interests || 'AI Threads, Design, UI/UX, Web Dev');
  const [link, setLink] = useState(initialData.link || 'https://instagram.com/' + initialData.username.replace(/^@/, ''));
  const [showAvatarPicker, setShowAvatarPicker] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
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

      {/* Main Content Form */}
      <main className="flex-1 max-w-[520px] w-full mx-auto px-5 pt-5 pb-32 space-y-4">
        {/* 1. Center Avatar Circle + Badge */}
        <div className="flex flex-col items-center justify-center py-3">
          <div className="relative group">
            <div className="w-24 h-24 rounded-full overflow-hidden border-2 border-white shadow-lg ring-4 ring-neutral-100/90 bg-neutral-100">
              <img
                src={avatar}
                alt={name}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Black Circle Plus/Edit Badge */}
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-[#101010] hover:bg-black text-white flex items-center justify-center shadow-md border-2 border-white active:scale-95 transition-all cursor-pointer"
              title="Ganti foto profil"
              aria-label="Ganti foto profil"
            >
              <Plus className="w-4 h-4 stroke-[2.5]" />
            </button>

            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={handleFileChange}
            />
          </div>

          {/* Quick Avatar Suggestions Switcher */}
          <div className="flex items-center gap-2 mt-3.5">
            <button
              type="button"
              onClick={() => setShowAvatarPicker(!showAvatarPicker)}
              className="text-[12px] font-semibold text-[#1d64ec] hover:underline cursor-pointer"
            >
              {showAvatarPicker ? 'Tutup Pilihan Avatar' : 'Pilih dari Preset Avatar'}
            </button>
          </div>

          {showAvatarPicker && (
            <motion.div
              initial={{ opacity: 0, y: -6 }}
              animate={{ opacity: 1, y: 0 }}
              className="flex items-center gap-2.5 pt-2.5 overflow-x-auto max-w-full pb-1 scrollbar-none"
            >
              {PRESET_AVATARS.map((pic, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => {
                    setAvatar(pic);
                    showToast('Preset avatar dipilih! ✨');
                  }}
                  className={`relative w-11 h-11 rounded-full overflow-hidden border-2 transition-all cursor-pointer shrink-0 ${
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

        {/* 2. Field Cards (Rounded Containers with Labels & Icons) */}
        <div className="space-y-3 pt-1">
          {/* Card 1: Full Name */}
          <div className="rounded-[18px] bg-neutral-50/90 border border-neutral-200/80 px-4 py-3 focus-within:border-slate-800 focus-within:bg-white transition-all shadow-2xs">
            <div className="flex items-center justify-between">
              <label className="text-[12px] font-semibold text-slate-500 uppercase tracking-wider">
                Full Name
              </label>
              <Pencil className="w-3.5 h-3.5 text-neutral-400 stroke-[1.75]" />
            </div>
            <input
              type="text"
              value={name}
              maxLength={50}
              onChange={(e) => setName(e.target.value)}
              placeholder="Jane Cooper"
              className="w-full mt-0.5 text-[15.5px] font-medium text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
            />
          </div>

          {/* Card 2: Nickname / Username */}
          <div className="rounded-[18px] bg-neutral-50/90 border border-neutral-200/80 px-4 py-3 focus-within:border-slate-800 focus-within:bg-white transition-all shadow-2xs">
            <div className="flex items-center justify-between">
              <label className="text-[12px] font-semibold text-slate-500 uppercase tracking-wider">
                Nickname / Username
              </label>
              <AtSign className="w-3.5 h-3.5 text-neutral-400 stroke-[1.75]" />
            </div>
            <div className="flex items-center mt-0.5">
              <span className="text-[15.5px] font-medium text-slate-400 mr-0.5 select-none">@</span>
              <input
                type="text"
                value={username}
                maxLength={30}
                onChange={(e) => setUsername(e.target.value.toLowerCase().replace(/[^a-z0-9._]/g, ''))}
                placeholder="radityarayhannnn"
                className="w-full text-[15.5px] font-medium text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
              />
            </div>
          </div>

          {/* Card 3: Bio */}
          <div className="rounded-[18px] bg-neutral-50/90 border border-neutral-200/80 px-4 py-3 focus-within:border-slate-800 focus-within:bg-white transition-all shadow-2xs">
            <div className="flex items-center justify-between">
              <label className="text-[12px] font-semibold text-slate-500 uppercase tracking-wider">
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
              placeholder="Tuliskan bio, keahlian, atau jualan kamu..."
              className="w-full mt-0.5 text-[15px] font-normal text-slate-900 bg-transparent focus:outline-none resize-none leading-relaxed placeholder:text-neutral-400"
            />
          </div>

          {/* Card 4: Kelas & Jurusan / Lokasi */}
          <div className="rounded-[18px] bg-neutral-50/90 border border-neutral-200/80 px-4 py-3 focus-within:border-slate-800 focus-within:bg-white transition-all shadow-2xs">
            <div className="flex items-center justify-between">
              <label className="text-[12px] font-semibold text-slate-500 uppercase tracking-wider">
                Kelas & Jurusan
              </label>
              <MapPin className="w-3.5 h-3.5 text-neutral-400 stroke-[1.75]" />
            </div>
            <input
              type="text"
              value={classGroup}
              maxLength={40}
              onChange={(e) => setClassGroup(e.target.value)}
              placeholder="Contoh: XII PPLG 1"
              className="w-full mt-0.5 text-[15.5px] font-medium text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
            />
          </div>

          {/* Card 5: Minat / Keahlian (Threads Topics) */}
          <div className="rounded-[18px] bg-neutral-50/90 border border-neutral-200/80 px-4 py-3 focus-within:border-slate-800 focus-within:bg-white transition-all shadow-2xs">
            <div className="flex items-center justify-between">
              <label className="text-[12px] font-semibold text-slate-500 uppercase tracking-wider">
                Minat & Topik Utas
              </label>
              <Sparkles className="w-3.5 h-3.5 text-neutral-400 stroke-[1.75]" />
            </div>
            <input
              type="text"
              value={interests}
              maxLength={80}
              onChange={(e) => setInterests(e.target.value)}
              placeholder="Contoh: AI Threads, UI/UX, Web Dev, Preloved"
              className="w-full mt-0.5 text-[15.5px] font-medium text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
            />
          </div>

          {/* Card 6: Tautan / Link WhatsApp */}
          <div className="rounded-[18px] bg-neutral-50/90 border border-neutral-200/80 px-4 py-3 focus-within:border-slate-800 focus-within:bg-white transition-all shadow-2xs">
            <div className="flex items-center justify-between">
              <label className="text-[12px] font-semibold text-slate-500 uppercase tracking-wider">
                Tautan / WhatsApp
              </label>
              <Link2 className="w-3.5 h-3.5 text-neutral-400 stroke-[1.75]" />
            </div>
            <input
              type="text"
              value={link}
              maxLength={100}
              onChange={(e) => setLink(e.target.value)}
              placeholder="https://wa.me/628123456789 atau https://instagram.com/..."
              className="w-full mt-0.5 text-[15.5px] font-medium text-slate-900 bg-transparent focus:outline-none placeholder:text-neutral-400"
            />
          </div>
        </div>
      </main>

      {/* Floating Bottom Dual Action CTA (Sticky Bar) */}
      <footer
        className="fixed bottom-0 left-0 right-0 z-40 bg-white/95 backdrop-blur-md border-t border-neutral-100 px-5 py-3.5 shadow-lg"
        style={{ paddingBottom: 'max(14px, env(safe-area-inset-bottom, 14px))' }}
      >
        <div className="max-w-[520px] mx-auto flex items-center gap-3">
          {/* Discard Button (Left) */}
          <button
            type="button"
            onClick={handleDiscard}
            className="flex-1 py-3.5 px-5 rounded-full border border-neutral-300 bg-white hover:bg-neutral-100 active:scale-95 text-slate-800 font-bold text-[15px] transition-all text-center cursor-pointer shadow-2xs"
          >
            Discard
          </button>

          {/* Save Button (Right) */}
          <button
            type="button"
            onClick={handleSave}
            className="flex-1 py-3.5 px-5 rounded-full bg-[#101010] hover:bg-black active:scale-95 text-white font-bold text-[15px] transition-all text-center cursor-pointer shadow-md"
          >
            Save
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
