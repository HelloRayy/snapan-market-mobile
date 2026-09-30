import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Mail, Lock, User, Loader2, CheckCircle2, ChevronRight } from 'lucide-react';
import { SnapsLogoSvg } from '@/ui/components/brand/SnapsLogoSvg';
import { signInWithEmail, signUpWithEmail } from '@/services/api/authService';
import { triggerHaptic } from '@/utils/haptics';

interface AuthPromptPopoverProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess?: () => void;
  title?: string;
  subtitle?: string;
}

export const AuthPromptPopover: React.FC<AuthPromptPopoverProps> = ({
  isOpen,
  onClose,
  onSuccess,
  subtitle = "Gabung ke komunitas SMKN 8. Temukan obrolan seru, info tongkrongan kampus, dan karya terbaik warga delapan."
}) => {
  const [authMode, setAuthMode] = useState<'options' | 'email-signin' | 'email-signup'>('options');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [classGroup, setClassGroup] = useState('PPLG 1');
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  // Handle ESC key press
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  // Reset internal states on open/close
  useEffect(() => {
    if (isOpen) {
      setErrorMessage(null);
      setSuccessMessage(null);
      setIsLoading(false);
    }
  }, [isOpen]);

  const handleEmailAuthSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setErrorMessage('Harap isi email dan kata sandi.');
      return;
    }
    triggerHaptic('medium');
    setIsLoading(true);
    setErrorMessage(null);
    setSuccessMessage(null);

    try {
      if (authMode === 'email-signin') {
        const { user } = await signInWithEmail(email, password);
        if (user) {
          triggerHaptic('success');
          setSuccessMessage('Berhasil masuk! Mengarahkan...');
          setTimeout(() => {
            onClose();
            if (onSuccess) onSuccess();
          }, 800);
        }
      } else {
        if (!fullName.trim()) {
          setIsLoading(false);
          setErrorMessage('Harap isi nama lengkap Anda.');
          return;
        }
        const { user } = await signUpWithEmail(email, password, fullName, classGroup);

        if (user) {
          triggerHaptic('success');
          setSuccessMessage('Pendaftaran berhasil! Mengarahkan...');
          setTimeout(() => {
            onClose();
            if (onSuccess) onSuccess();
          }, 800);
        }
      }
    } catch (err: any) {
      triggerHaptic('error');
      setErrorMessage(err?.message || 'Autentikasi gagal. Silakan periksa kembali data Anda.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Frosted Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => {
              triggerHaptic('light');
              onClose();
            }}
            className="fixed inset-0 bg-black/40 backdrop-blur-md transition-opacity"
            aria-hidden="true"
          />

          {/* Modal Card */}
          <motion.div
            role="dialog"
            aria-modal="true"
            aria-labelledby="auth-modal-title"
            initial={{ opacity: 0, scale: 0.95, y: 16 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 16 }}
            transition={{ type: 'spring', damping: 25, stiffness: 350 }}
            className="relative w-full max-w-[420px] bg-white text-slate-900 rounded-[28px] p-7 sm:p-9 shadow-2xl border border-slate-200/80 overflow-hidden z-10 flex flex-col items-center"
          >
            {/* Close Button */}
            <button
              type="button"
              onClick={() => {
                triggerHaptic('light');
                onClose();
              }}
              className="absolute top-4 right-4 w-9 h-9 rounded-full bg-slate-100 hover:bg-slate-200 active:scale-95 text-slate-500 hover:text-slate-800 flex items-center justify-center transition-all cursor-pointer focus:outline-none"
              aria-label="Tutup dialog"
            >
              <X className="w-5 h-5 stroke-[2.2]" />
            </button>

            {/* Title & Subtitle */}
            <div className="flex flex-col items-center mt-2">
              <h2
                id="auth-modal-title"
                className="text-2xl sm:text-[25px] font-black text-slate-900 text-center tracking-tight leading-snug"
              >
                Katakan lebih banyak
              </h2>
              <div className="flex items-center justify-center gap-1.5 mt-0.5">
                <span className="text-2xl sm:text-[25px] font-black text-slate-900 tracking-tight">
                  dengan
                </span>
                <SnapsLogoSvg height={38} />
              </div>
            </div>

            <p className="mt-3 text-[14.5px] text-slate-500 text-center leading-relaxed max-w-[360px]">
              {subtitle}
            </p>

            {/* Error / Success Notifications */}
            {errorMessage && (
              <div className="w-full mt-4 p-3 rounded-xl bg-red-50 border border-red-200/80 text-xs text-red-600 font-medium">
                {errorMessage}
              </div>
            )}
            {successMessage && (
              <div className="w-full mt-4 p-3 rounded-xl bg-emerald-50 border border-emerald-200/80 text-xs text-emerald-700 font-medium flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600 shrink-0" />
                {successMessage}
              </div>
            )}

            {/* Options View (Threads Single Action Capsule) */}
            {authMode === 'options' && (
              <div className="w-full mt-7">
                <button
                  type="button"
                  onClick={() => {
                    triggerHaptic('medium');
                    setAuthMode('email-signin');
                  }}
                  className="w-full p-3.5 sm:p-4 rounded-2xl bg-[#f9fafb] hover:bg-[#f3f4f6] active:scale-[0.98] border border-slate-200 flex items-center justify-between transition-all cursor-pointer group shadow-sm"
                >
                  <div className="flex items-center gap-3.5">
                    <div className="w-11 h-11 rounded-xl bg-white border border-slate-200/80 p-1 flex items-center justify-center shadow-sm shrink-0">
                      <img src="/src/assets/brand/smk8.png" alt="SMKN 8" className="w-full h-full object-contain" />
                    </div>
                    <span className="text-[15.5px] font-bold text-slate-900 tracking-tight">
                      Lanjutkan sebagai Snapanians
                    </span>
                  </div>
                  <ChevronRight className="w-5 h-5 text-slate-400 group-hover:text-slate-600 group-hover:translate-x-0.5 transition-all" />
                </button>
              </div>
            )}

            {/* Email Form View */}
            {authMode !== 'options' && (
              <form onSubmit={handleEmailAuthSubmit} className="w-full mt-5 space-y-3">
                {authMode === 'email-signup' && (
                  <>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1 ml-1">
                        Nama Lengkap
                      </label>
                      <div className="relative">
                        <User className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                        <input
                          type="text"
                          required
                          value={fullName}
                          onChange={(e) => setFullName(e.target.value)}
                          placeholder="Nama Panggilan / Lengkap"
                          style={{ fontSize: '16px' }}
                          className="w-full h-11 pl-10 pr-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary outline-none text-sm text-slate-900 transition-all"
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs font-semibold text-slate-700 mb-1 ml-1">
                        Kelas / Jurusan
                      </label>
                      <input
                        type="text"
                        value={classGroup}
                        onChange={(e) => setClassGroup(e.target.value)}
                        placeholder="Contoh: XII PPLG 1"
                        style={{ fontSize: '16px' }}
                        className="w-full h-11 px-3.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary outline-none text-sm text-slate-900 transition-all"
                      />
                    </div>
                  </>
                )}

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1 ml-1">
                    Email
                  </label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="email@smkn8semarang.sch.id"
                      style={{ fontSize: '16px' }}
                      className="w-full h-11 pl-10 pr-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary outline-none text-sm text-slate-900 transition-all"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-slate-700 mb-1 ml-1">
                    Kata Sandi
                  </label>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                    <input
                      type="password"
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Minimal 6 karakter"
                      style={{ fontSize: '16px' }}
                      className="w-full h-11 pl-10 pr-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary outline-none text-sm text-slate-900 transition-all"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full h-11 rounded-xl bg-brand-primary hover:bg-[#312bd9] active:scale-[0.98] text-white font-bold text-sm shadow-md shadow-brand-primary/20 flex items-center justify-center gap-2 transition-all cursor-pointer disabled:opacity-60 mt-2"
                >
                  {isLoading && <Loader2 className="w-4 h-4 animate-spin" />}
                  {authMode === 'email-signup' ? 'Daftar Akun' : 'Masuk Sekarang'}
                </button>

                {/* Switch between Sign In / Sign Up and Back to options */}
                <div className="flex items-center justify-between pt-2 text-xs">
                  <button
                    type="button"
                    onClick={() => {
                      triggerHaptic('light');
                      setErrorMessage(null);
                      setAuthMode(authMode === 'email-signin' ? 'email-signup' : 'email-signin');
                    }}
                    className="font-medium text-brand-primary hover:underline"
                  >
                    {authMode === 'email-signin' ? 'Belum punya akun? Daftar' : 'Sudah punya akun? Masuk'}
                  </button>

                  <button
                    type="button"
                    onClick={() => {
                      triggerHaptic('light');
                      setErrorMessage(null);
                      setAuthMode('options');
                    }}
                    className="text-slate-500 hover:text-slate-800"
                  >
                    Kembali
                  </button>
                </div>
              </form>
            )}
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
