import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Mail, Lock, User, ArrowRight, Loader2, Sparkles, CheckCircle2 } from 'lucide-react';
import { SnapsLogoSvg } from '@/ui/components/brand/SnapsLogoSvg';
import { signInWithGoogle, signInWithEmail, signUpWithEmail } from '@/services/api/authService';
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
  title = "Katakan lebih banyak dengan Snapan Market",
  subtitle = "Gabung ke Snapan Market untuk membagikan pemikiran, jual beli karya & preloved, berdiskusi dengan sesama siswa SMKN 8 Jakarta, dan banyak lagi."
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

  const handleGoogleSignIn = async () => {
    triggerHaptic('medium');
    setIsLoading(true);
    setErrorMessage(null);
    try {
      await signInWithGoogle();
      // Browser will redirect to Google OAuth
    } catch (err: any) {
      setIsLoading(false);
      setErrorMessage(err?.message || 'Gagal masuk dengan Google. Silakan coba lagi.');
    }
  };

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
      if (authMode === 'email-signup') {
        await signUpWithEmail(email, password, fullName || 'Siswa Snapan', classGroup);
        setSuccessMessage('Pendaftaran berhasil! Silakan periksa email untuk konfirmasi atau masuk.');
        triggerHaptic('light');
        setTimeout(() => {
          setAuthMode('email-signin');
          setSuccessMessage(null);
        }, 2000);
      } else {
        await signInWithEmail(email, password);
        triggerHaptic('light');
        onSuccess?.();
        onClose();
      }
    } catch (err: any) {
      setErrorMessage(err?.message || 'Autentikasi gagal. Periksa kembali email dan kata sandi.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          {/* Backdrop Blur Overlay */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
            onClick={() => {
              triggerHaptic('light');
              onClose();
            }}
            className="fixed inset-0 bg-black/40 backdrop-blur-[6px] select-none"
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
            className="relative w-full max-w-[420px] bg-white rounded-3xl p-6 md:p-8 shadow-2xl border border-black/[0.08] overflow-hidden z-10 flex flex-col items-center"
          >
            {/* Top Accent Gradient Bar */}
            <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-brand-primary via-[#534eff] to-[#38bdf8]" />

            {/* Close Button */}
            <button
              type="button"
              onClick={() => {
                triggerHaptic('light');
                onClose();
              }}
              className="absolute top-4 right-4 w-9 h-9 rounded-full bg-slate-100 hover:bg-slate-200 active:scale-95 text-slate-500 hover:text-slate-800 flex items-center justify-center transition-all cursor-pointer focus:outline-none focus:ring-2 focus:ring-brand-primary/20"
              aria-label="Tutup dialog"
            >
              <X className="w-5 h-5 stroke-[2.2]" />
            </button>

            {/* Brand Logo & Decorative Badge */}
            <div className="mb-4 flex flex-col items-center">
              <div className="w-14 h-14 rounded-2xl bg-[#eef0ff] border border-brand-primary/20 flex items-center justify-center shadow-sm mb-3">
                <SnapsLogoSvg height={24} />
              </div>
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-slate-100 border border-slate-200/80 text-[11.5px] font-semibold text-slate-700 tracking-wide">
                <Sparkles className="w-3.5 h-3.5 text-brand-primary" />
                SMKN 8 Jakarta Community
              </span>
            </div>

            {/* Title & Subtitle */}
            <h2
              id="auth-modal-title"
              className="text-2xl font-black text-slate-900 text-center tracking-tight leading-snug"
            >
              {title}
            </h2>
            <p className="mt-2 text-[13.5px] text-slate-600 text-center leading-relaxed">
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

            {/* Options View (Default Threads Style) */}
            {authMode === 'options' && (
              <div className="w-full mt-6 space-y-3">
                {/* Primary Google Login Button */}
                <button
                  type="button"
                  onClick={handleGoogleSignIn}
                  disabled={isLoading}
                  className="w-full h-12 px-4 rounded-2xl bg-white border border-slate-200 hover:border-slate-300 hover:bg-slate-50/80 active:scale-[0.98] shadow-sm flex items-center justify-between transition-all cursor-pointer group disabled:opacity-60"
                >
                  <div className="flex items-center gap-3">
                    {/* Official Google Icon */}
                    <svg className="w-5 h-5 shrink-0" viewBox="0 0 24 24">
                      <path
                        fill="#4285F4"
                        d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
                      />
                      <path
                        fill="#34A853"
                        d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
                      />
                      <path
                        fill="#FBBC05"
                        d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
                      />
                      <path
                        fill="#EA4335"
                        d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
                      />
                    </svg>
                    <span className="text-[14.5px] font-bold text-slate-800 tracking-tight">
                      Lanjutkan dengan Google
                    </span>
                  </div>
                  {isLoading ? (
                    <Loader2 className="w-4 h-4 text-slate-400 animate-spin" />
                  ) : (
                    <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-slate-700 group-hover:translate-x-0.5 transition-all" />
                  )}
                </button>

                {/* Secondary Button: Masuk dengan Email */}
                <button
                  type="button"
                  onClick={() => {
                    triggerHaptic('light');
                    setAuthMode('email-signin');
                  }}
                  className="w-full h-12 px-4 rounded-2xl bg-brand-primary hover:bg-[#312bd9] active:scale-[0.98] text-white shadow-md shadow-brand-primary/20 flex items-center justify-center gap-2 font-bold text-[14px] transition-all cursor-pointer"
                >
                  <Mail className="w-4 h-4" />
                  Masuk dengan Email
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
                          className="w-full h-11 pl-10 pr-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary focus:ring-2 focus:ring-brand-primary/15 outline-none text-sm text-slate-900 transition-all"
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
                        className="w-full h-11 px-3.5 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary focus:ring-2 focus:ring-brand-primary/15 outline-none text-sm text-slate-900 transition-all"
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
                      placeholder="email@smkn8jakarta.sch.id"
                      style={{ fontSize: '16px' }}
                      className="w-full h-11 pl-10 pr-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary focus:ring-2 focus:ring-brand-primary/15 outline-none text-sm text-slate-900 transition-all"
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
                      className="w-full h-11 pl-10 pr-3 rounded-xl bg-slate-50 border border-slate-200 focus:bg-white focus:border-brand-primary focus:ring-2 focus:ring-brand-primary/15 outline-none text-sm text-slate-900 transition-all"
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

            {/* Bottom Disclaimer */}
            <p className="mt-5 text-[11px] text-slate-600 text-center leading-relaxed">
              Dengan melanjutkan, Anda menyetujui Ketentuan Komunitas dan Kebijakan Privasi SMKN 8 Jakarta.
            </p>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
};
