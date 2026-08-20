import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Camera } from 'lucide-react';

interface EditProfileModalProps {
  isOpen: boolean;
  onClose: () => void;
  initialName: string;
  initialBio: string;
  initialClassGroup: string;
  initialAvatar: string;
  onSave: (data: { name: string; bio: string; classGroup: string; avatar: string }) => void;
}

export const EditProfileModal: React.FC<EditProfileModalProps> = ({
  isOpen,
  onClose,
  initialName,
  initialBio,
  initialClassGroup,
  initialAvatar,
  onSave,
}) => {
  const [name, setName] = useState(initialName);
  const [bio, setBio] = useState(initialBio);
  const [classGroup, setClassGroup] = useState(initialClassGroup);
  const [avatar] = useState(initialAvatar);

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      name: name.trim() || initialName,
      bio: bio.trim(),
      classGroup: classGroup.trim() || initialClassGroup,
      avatar,
    });
    onClose();
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm font-gt-standard">
        <motion.div
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          transition={{ duration: 0.2 }}
          className="w-full max-w-md bg-white rounded-3xl shadow-2xl overflow-hidden border border-neutral-200"
        >
          {/* Header */}
          <div className="px-5 py-4 flex items-center justify-between border-b border-neutral-100">
            <button
              type="button"
              onClick={onClose}
              className="p-1 -ml-1 text-slate-500 hover:text-slate-900 rounded-full hover:bg-neutral-100 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
            <h2 className="text-base font-bold text-slate-900">Edit Profil</h2>
            <button
              type="button"
              onClick={handleSubmit}
              className="text-sm font-bold text-[#1d64ec] hover:underline cursor-pointer"
            >
              Selesai
            </button>
          </div>

          {/* Form Content */}
          <form onSubmit={handleSubmit} className="p-5 space-y-4">
            {/* Avatar Picker */}
            <div className="flex flex-col items-center gap-2">
              <div className="relative group cursor-pointer">
                <div className="w-20 h-20 rounded-full overflow-hidden border-2 border-neutral-200 shadow-md">
                  <img src={avatar} alt={name} className="w-full h-full object-cover" />
                </div>
                <div className="absolute inset-0 bg-black/40 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <Camera className="w-6 h-6 text-white" />
                </div>
              </div>
              <span className="text-xs text-neutral-400">Ketuk untuk mengganti foto</span>
            </div>

            {/* Nama Lengkap */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-neutral-500">Nama Lengkap</label>
              <input
                type="text"
                value={name}
                maxLength={40}
                onChange={(e) => setName(e.target.value)}
                placeholder="Nama kamu..."
                className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-200 focus:outline-none focus:border-[#1d64ec] text-sm text-slate-900 bg-neutral-50/50"
              />
            </div>

            {/* Kelas & Jurusan */}
            <div className="space-y-1">
              <label className="text-xs font-semibold text-neutral-500">Kelas / Jurusan</label>
              <input
                type="text"
                value={classGroup}
                maxLength={30}
                onChange={(e) => setClassGroup(e.target.value)}
                placeholder="Contoh: XII PPLG 1"
                className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-200 focus:outline-none focus:border-[#1d64ec] text-sm text-slate-900 bg-neutral-50/50"
              />
            </div>

            {/* Bio */}
            <div className="space-y-1">
              <div className="flex items-center justify-between">
                <label className="text-xs font-semibold text-neutral-500">Bio</label>
                <span className="text-[11px] text-neutral-400">{bio.length}/150</span>
              </div>
              <textarea
                rows={3}
                value={bio}
                maxLength={150}
                onChange={(e) => setBio(e.target.value)}
                placeholder="Tulis bio singkat atau keahlian/jualan kamu..."
                className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-200 focus:outline-none focus:border-[#1d64ec] text-sm text-slate-900 bg-neutral-50/50 resize-none"
              />
            </div>
          </form>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};
