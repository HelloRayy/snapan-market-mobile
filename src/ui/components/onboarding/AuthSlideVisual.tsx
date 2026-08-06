import React, { useState, useRef, useEffect } from 'react';
import { Mail, Lock, Eye, EyeOff, ArrowLeft, User, ChevronDown, Check, AlertCircle, Loader2, Headphones } from 'lucide-react';
import { ButtonPrimary } from '../ui/ButtonPrimary';
import { ButtonSecondary } from '../ui/ButtonSecondary';
import { Checkbox } from '../ui/Checkbox';
import personLoginSvg from '../../../assets/new-market-asset/person-login 1.svg';

interface AuthSlideVisualProps {
  onBack?: () => void;
  onSuccess?: () => void;
}

interface FormErrors {
  fullName?: string;
  classGroup?: string;
  phoneNumber?: string;
  loginIdentifier?: string;
  password?: string;
  agreeTerms?: string;
  otpCode?: string;
}

export const AuthSlideVisual: React.FC<AuthSlideVisualProps> = ({ onBack, onSuccess }) => {
  const [authTab, setAuthTab] = useState<'login' | 'register'>('login');
  const [regStep, setRegStep] = useState<'form' | 'otp'>('form');
  const [showPassword, setShowPassword] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Form State
  const [fullName, setFullName] = useState('');
  const [gradeLevel, setGradeLevel] = useState('');
  const [major, setMajor] = useState('');
  const [classNumber, setClassNumber] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [loginIdentifier, setLoginIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(true);
  const [agreeTerms, setAgreeTerms] = useState(false); // Default unchecked per user feedback

  // 6-Digit WhatsApp OTP State
  const [otpDigits, setOtpDigits] = useState<string[]>(['', '', '', '', '', '']);
  const otpInputsRef = useRef<(HTMLInputElement | null)[]>([]);
  const [countdown, setCountdown] = useState(60);
  const [canResend, setCanResend] = useState(false);

  // Focus States for Floating Label Animations
  const [focusedField, setFocusedField] = useState<string | null>(null);

  // Field-level Error UI State & Shake Trigger Key
  const [errors, setErrors] = useState<FormErrors>({});
  const [shakeKey, setShakeKey] = useState(0);

  // Dropdown open states
  const [openGrade, setOpenGrade] = useState(false);
  const [openMajor, setOpenMajor] = useState(false);
  const [openClassNum, setOpenClassNum] = useState(false);

  const dropdownRef = useRef<HTMLDivElement>(null);

  // SMKN 8 Specific Options
  const gradeOptions = ['X', 'XI', 'XII', 'Guru / Karyawan'];
  const majorOptions = ['DKV', 'LK', 'PPLG', 'PS', 'TJKT'];
  const classNumOptions = ['1', '2', '3'];

  // Format Phone Number as 3 digits - 4 digits - 4 digits e.g. 857-9799-857
  const formatPhoneWithHyphens = (rawDigits: string) => {
    if (!rawDigits) return '';
    if (rawDigits.length <= 3) return rawDigits;
    if (rawDigits.length <= 7) return `${rawDigits.slice(0, 3)}-${rawDigits.slice(3)}`;
    return `${rawDigits.slice(0, 3)}-${rawDigits.slice(3, 7)}-${rawDigits.slice(7, 12)}`;
  };

  // Check if Register form inputs are complete
  const isRegisterIncomplete =
    !fullName.trim() ||
    !gradeLevel ||
    !major ||
    !classNumber ||
    !phoneNumber.trim() ||
    phoneNumber.length < 8 ||
    password.length < 6 ||
    !agreeTerms;

  // Check if Login form inputs are complete
  const isLoginIncomplete = !loginIdentifier.trim() || !password;

  // Close dropdowns on outside click
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setOpenGrade(false);
        setOpenMajor(false);
        setOpenClassNum(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Auto-focus first PIN box when entering Step 2 OTP Screen
  useEffect(() => {
    if (regStep === 'otp') {
      const timer = setTimeout(() => {
        otpInputsRef.current[0]?.focus();
      }, 100);
      return () => clearTimeout(timer);
    }
  }, [regStep]);

  // OTP Countdown Timer Logic (60 seconds)
  useEffect(() => {
    let timer: ReturnType<typeof setInterval>;
    if (regStep === 'otp' && countdown > 0) {
      timer = setInterval(() => {
        setCountdown((prev) => prev - 1);
      }, 1000);
    } else if (countdown === 0) {
      setCanResend(true);
    }
    return () => clearInterval(timer);
  }, [regStep, countdown]);

  // Mask Phone Number Helper e.g. 08512345678 / 8512345678 -> +6285-****-**78
  const maskPhoneNumber = (rawPhone: string) => {
    if (!rawPhone) return '+6285-****-**78';
    let clean = rawPhone.replace(/\D/g, '');
    if (clean.startsWith('0')) {
      clean = clean.slice(1);
    } else if (clean.startsWith('62')) {
      clean = clean.slice(2);
    }
    const formatted = '62' + clean;
    if (formatted.length < 8) return '+' + formatted;
    const prefix = '+' + formatted.slice(0, 4);
    const suffix = formatted.slice(-2);
    return `${prefix}-****-**${suffix}`;
  };

  const handleMockSocialLogin = (_provider: string) => {
    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      onSuccess?.();
    }, 600);
  };

  const handleHeaderBack = () => {
    setErrors({});
    if (regStep === 'otp') {
      setRegStep('form');
    } else if (authTab === 'register') {
      setAuthTab('login');
    } else {
      onBack?.();
    }
  };

  // Handle OTP 6-Digit Box Changes (Strictly Number Only)
  const handleOtpChange = (index: number, value: string) => {
    const numericValue = value.replace(/\D/g, '');
    if (!numericValue && value !== '') return;

    const newDigits = [...otpDigits];
    newDigits[index] = numericValue.slice(-1);
    setOtpDigits(newDigits);
    setErrors((prev) => ({ ...prev, otpCode: undefined }));

    // Auto-advance focus to next input
    if (numericValue && index < 5) {
      otpInputsRef.current[index + 1]?.focus();
    }
  };

  // Enhanced Keyboard Navigation (Backspace, ArrowLeft, ArrowRight)
  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otpDigits[index] && index > 0) {
      otpInputsRef.current[index - 1]?.focus();
    } else if (e.key === 'ArrowLeft' && index > 0) {
      e.preventDefault();
      otpInputsRef.current[index - 1]?.focus();
    } else if (e.key === 'ArrowRight' && index < 5) {
      e.preventDefault();
      otpInputsRef.current[index + 1]?.focus();
    }
  };

  const handleOtpPaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').replace(/\D/g, '').trim();
    if (pastedData.length >= 6) {
      const digits = pastedData.slice(0, 6).split('');
      setOtpDigits(digits);
      otpInputsRef.current[5]?.focus();
    }
  };

  const handleResendOtp = () => {
    if (!canResend) return;
    setCountdown(60);
    setCanResend(false);
    setOtpDigits(['', '', '', '', '', '']);
    otpInputsRef.current[0]?.focus();
  };

  const handleVerifyOtp = (e: React.FormEvent) => {
    e.preventDefault();
    const fullCode = otpDigits.join('');
    if (fullCode.length < 6) {
      setErrors({ otpCode: 'Mohon masukkan 6-digit kode verifikasi OTP' });
      setShakeKey((prev) => prev + 1);
      return;
    }

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      onSuccess?.();
    }, 600);
  };

  // Pure FE Form Validation & Transition to Step 2 OTP
  const handleSubmitForm = (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: FormErrors = {};

    if (authTab === 'register') {
      if (!fullName.trim()) {
        newErrors.fullName = 'Mohon isi Nama Lengkap Anda';
      }
      if (!gradeLevel || !major || !classNumber) {
        newErrors.classGroup = 'Pilih Kelas, Jurusan, dan No. Kelas SMKN 8';
      }
      if (!phoneNumber.trim() || phoneNumber.length < 8) {
        newErrors.phoneNumber = 'Masukkan nomor WhatsApp aktif Anda (min. 8 angka)';
      }
      if (password.length < 6) {
        newErrors.password = 'Kata sandi minimal harus 6 karakter';
      }
      if (!agreeTerms) {
        newErrors.agreeTerms = 'Centang untuk menyetujui Syarat & Ketentuan';
      }
    } else {
      if (!loginIdentifier.trim()) {
        newErrors.loginIdentifier = 'Masukkan Nomor WhatsApp atau Email Anda';
      }
      if (!password) {
        newErrors.password = 'Mohon masukkan kata sandi Anda';
      }
    }

    setErrors(newErrors);

    if (Object.keys(newErrors).length > 0) {
      setShakeKey((prev) => prev + 1);
    } else {
      if (authTab === 'register') {
        // Transition to Step 2: WhatsApp OTP Verification Screen
        setRegStep('otp');
        setCountdown(60);
        setCanResend(false);
        setOtpDigits(['', '', '', '', '', '']);
      } else {
        // Login Submit Transition
        setIsSubmitting(true);
        setTimeout(() => {
          setIsSubmitting(false);
          onSuccess?.();
        }, 500);
      }
    }
  };

  return (
    <div className="w-full max-w-sm mx-auto flex flex-col justify-between h-full font-gt-standard text-slate-ink pb-2">
      {/* Subtle Micro-Shake Style Block */}
      <style>{`
        @keyframes field-micro-shake {
          0%, 100% { transform: translateX(0); }
          20%, 60% { transform: translateX(-4px); }
          40%, 80% { transform: translateX(4px); }
        }
        .do-shake {
          animation: field-micro-shake 0.3s cubic-bezier(0.36, 0.07, 0.19, 0.97) both !important;
        }
      `}</style>

      {/* Uniform Outer Header Section with Generous Bottom Margin */}
      <div className="space-y-2.5 pt-2 pb-2 mb-2 px-1 shrink-0">
        <button
          onClick={handleHeaderBack}
          className="flex h-9 w-9 items-center justify-center rounded-full bg-canvas-mist border border-faint-border text-slate-900 hover:bg-cool-stone/30 focus-visible:ring-2 focus-visible:ring-blue-500 transition-colors active:scale-95 cursor-pointer"
          aria-label="Kembali"
        >
          <ArrowLeft className="h-4.5 w-4.5 text-slate-900" aria-hidden="true" />
        </button>

        {/* Zero-Layout-Shift Snappy Header Container */}
        <div className="grid grid-cols-1 grid-rows-1 min-h-[52px]">
          {regStep === 'otp' ? (
            /* OTP Step 2 Header Title */
            <div className="col-start-1 row-start-1 space-y-1 animate-in fade-in duration-200">
              <h1 className="text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans leading-tight">
                Verifikasi Kode OTP
              </h1>
              <p className="text-xs text-slate-600 font-medium leading-relaxed">
                Kode 6-digit telah dikirim ke WhatsApp <span className="font-bold text-slate-900">{maskPhoneNumber(phoneNumber)}</span>
              </p>
            </div>
          ) : authTab === 'login' ? (
            /* Login Header Title */
            <div className="col-start-1 row-start-1 space-y-1 transition-opacity duration-150 ease-out opacity-100">
              <h1 className="text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans leading-tight">
                Ayo Masuk ke Akun Kamu
              </h1>
              <p className="text-xs text-slate-600 font-medium">
                Masuk atau daftar untuk menikmati pengalaman terbaik
              </p>
            </div>
          ) : (
            /* Register Header Title */
            <div className="col-start-1 row-start-1 space-y-1 transition-opacity duration-150 ease-out opacity-100">
              <h1 className="text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans leading-tight">
                Buat Akun Baru
              </h1>
              <p className="text-xs text-slate-600 font-medium">
                Isi data diri kamu untuk mulai bergabung
              </p>
            </div>
          )}
        </div>
      </div>

      {/* 3D Peeking Student Character gripping directly onto top border of form sheet */}
      <div className="relative w-full flex items-center justify-center -mb-[38px] sm:-mb-[44px] z-20 pointer-events-none select-none overflow-visible animate-in fade-in duration-300">
        <img
          src={personLoginSvg}
          alt="Siswa SMKN 8 Peeking"
          className="w-48 sm:w-56 h-auto object-contain mix-blend-multiply transform translate-y-1 transition-transform duration-300"
        />
      </div>

      {/* Main Form Sheet Card */}
      <div
        className={`-mx-5 -mb-5 bg-pure-white px-6 shadow-2xl space-y-4 overflow-y-auto transition-all duration-300 cubic-bezier(0.16,1,0.3,1) ${
          authTab === 'register' || regStep === 'otp'
            ? 'h-full min-h-[78vh] rounded-t-[36px] rounded-b-none border-t border-faint-border pt-6 pb-12 flex-1'
            : 'rounded-t-[36px] rounded-b-none border-t border-faint-border pt-6 pb-10'
        }`}
      >
        {/* STEP 2: WHATSAPP OTP VERIFICATION SCREEN */}
        {regStep === 'otp' ? (
          <form onSubmit={handleVerifyOtp} className="space-y-6 pt-4 text-center animate-in fade-in slide-in-from-right-4 duration-300 ease-out">
            {/* Centered Main Title & Subtitle */}
            <div className="space-y-2">
              <h2 className="text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans">
                Masukkan Kode Verifikasi
              </h2>
              <p className="text-xs text-slate-600 font-medium leading-relaxed max-w-xs mx-auto">
                Silakan masukkan 6 angka kode OTP yang telah kami kirimkan.
              </p>
            </div>

            {/* 6-Digit PIN Boxes with ARIA Labels, Arrow Key Nav & Active Glow Ring */}
            <div className="space-y-2">
              <div
                key={`otp-box-${shakeKey}`}
                className={`flex items-center justify-center gap-2 my-2 ${errors.otpCode ? 'do-shake' : ''}`}
                role="group"
                aria-label="Kotak Isian Kode Verifikasi OTP 6-Digit"
              >
                {otpDigits.map((digit, idx) => (
                  <input
                    key={idx}
                    ref={(el) => (otpInputsRef.current[idx] = el)}
                    type="tel"
                    inputMode="numeric"
                    pattern="[0-9]*"
                    autoComplete="one-time-code"
                    maxLength={1}
                    value={digit}
                    aria-label={`Digit ${idx + 1} dari 6 untuk kode verifikasi OTP`}
                    aria-invalid={!!errors.otpCode}
                    onChange={(e) => handleOtpChange(idx, e.target.value)}
                    onKeyDown={(e) => handleOtpKeyDown(idx, e)}
                    onPaste={handleOtpPaste}
                    className={`w-12 h-14 text-center text-xl font-extrabold rounded-2xl border transition-all duration-150 shadow-2xs focus:outline-none ${
                      errors.otpCode
                        ? 'border-rose-400 bg-rose-50/30 text-rose-600 focus:border-rose-500 focus:ring-4 focus:ring-rose-500/20'
                        : digit
                        ? 'border-[#1d64ec] bg-blue-50/40 text-[#1d64ec] ring-2 ring-blue-500/20 focus:scale-[1.04] focus:ring-4 focus:ring-blue-500/25'
                        : 'border-neutral-200 bg-neutral-50/50 text-slate-900 focus:border-[#1d64ec] focus:bg-pure-white focus:scale-[1.04] focus:ring-4 focus:ring-blue-500/25'
                    }`}
                  />
                ))}
              </div>

              {errors.otpCode && (
                <p className="text-[11px] text-rose-500 font-semibold flex items-center justify-center gap-1.5 leading-none animate-in fade-in duration-200" role="alert">
                  <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                  <span>{errors.otpCode}</span>
                </p>
              )}
            </div>

            {/* Always Clickable Verify Primary Button (Triggers Error Shake if Code Incomplete) */}
            <ButtonPrimary
              type="submit"
              size="lg"
              disabled={isSubmitting}
              className="w-full justify-center font-bold h-14 text-base rounded-full bg-[#1d64ec] hover:bg-blue-600 shadow-md shadow-blue-500/25 text-white cursor-pointer active:scale-[0.98]"
            >
              {isSubmitting ? (
                <Loader2 className="h-5 w-5 animate-spin text-white" />
              ) : (
                'Verifikasi'
              )}
            </ButtonPrimary>

            {/* Clean, Simple Resend & Timer Text Matching User Reference Screenshot */}
            <div className="space-y-3 text-center text-xs" role="status" aria-live="polite">
              {countdown > 0 ? (
                <p className="text-slate-600 font-medium">
                  Kirim ulang kode dalam <span className="font-bold text-slate-900">{countdown} detik</span>
                </p>
              ) : (
                <button
                  type="button"
                  onClick={handleResendOtp}
                  className="font-bold text-[#1d64ec] hover:underline cursor-pointer focus-visible:ring-2 focus-visible:ring-blue-500 rounded-sm"
                >
                  Kirim Ulang Kode
                </button>
              )}

              {/* Customer Service Icon ("Hubungi Bantuan") */}
              <div className="pt-2 flex items-center justify-center gap-1.5">
                <span className="text-neutral-500">Butuh bantuan?</span>
                <button
                  type="button"
                  className="inline-flex items-center gap-1 font-bold text-[#1d64ec] hover:underline cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 rounded-sm"
                >
                  <Headphones className="h-3.5 w-3.5 text-[#1d64ec]" aria-hidden="true" />
                  <span>Hubungi Bantuan</span>
                </button>
              </div>
            </div>
          </form>
        ) : (
          /* STEP 1: FORM INPUT SHEET */
          <>
            {/* Segmented Control Tab Switcher */}
            <div
              className="relative flex items-center rounded-full bg-[#f1f3f5] p-1 border border-neutral-200/70 shadow-inner h-12 select-none"
              role="tablist"
              aria-label="Metode Otentikasi"
            >
              <div
                className={`absolute top-1 bottom-1 left-1 w-[calc(50%-0.25rem)] rounded-full bg-white shadow-md shadow-black/8 border border-black/5 transition-transform duration-250 cubic-bezier(0.16,1,0.3,1) ${
                  authTab === 'login' ? 'translate-x-0' : 'translate-x-full'
                }`}
              />

              <button
                role="tab"
                aria-selected={authTab === 'login'}
                onClick={() => { setAuthTab('login'); setErrors({}); }}
                className={`flex-1 relative z-10 flex items-center justify-center whitespace-nowrap focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 cursor-pointer text-sm font-bold rounded-full py-2.5 transition-colors duration-200 ${
                  authTab === 'login' ? 'text-slate-900' : 'text-neutral-500 hover:text-slate-900 font-semibold'
                }`}
              >
                Masuk
              </button>
              <button
                role="tab"
                aria-selected={authTab === 'register'}
                onClick={() => { setAuthTab('register'); setErrors({}); }}
                className={`flex-1 relative z-10 flex items-center justify-center whitespace-nowrap focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 cursor-pointer text-sm font-bold rounded-full py-2.5 transition-colors duration-200 ${
                  authTab === 'register' ? 'text-slate-900' : 'text-neutral-500 hover:text-slate-900 font-semibold'
                }`}
              >
                Daftar
              </button>
            </div>

            {/* Dynamic Form Content */}
            <form onSubmit={handleSubmitForm} noValidate className="space-y-4 pt-1">
              {/* REGISTER EXTRA FIELDS */}
              {authTab === 'register' ? (
                <div className="space-y-4 animate-in fade-in slide-in-from-bottom-3 duration-300 ease-out" ref={dropdownRef}>
                  {/* 1. Full Name Floating Label Field */}
                  <div>
                    <div
                      key={`fullname-box-${shakeKey}`}
                      className={`relative flex items-center h-16 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
                        errors.fullName
                          ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
                          : focusedField === 'fullName'
                          ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
                          : 'border-neutral-200 hover:border-neutral-300'
                      }`}
                    >
                      <User className={`h-5 w-5 shrink-0 mr-3 ${errors.fullName ? 'text-rose-500' : focusedField === 'fullName' ? 'text-[#1d64ec]' : 'text-emerald-800'}`} aria-hidden="true" />
                      
                      <label
                        htmlFor="register-name-input"
                        className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
                          focusedField === 'fullName' || fullName
                            ? 'left-8 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                            : 'left-11 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
                        } ${
                          errors.fullName
                            ? 'text-rose-500 font-semibold'
                            : focusedField === 'fullName'
                            ? 'text-[#1d64ec] font-semibold'
                            : fullName
                            ? 'text-slate-900 font-semibold'
                            : 'text-neutral-400 font-normal'
                        }`}
                      >
                        Nama Lengkap
                      </label>

                      <input
                        id="register-name-input"
                        name="fullName"
                        type="text"
                        value={fullName}
                        onFocus={() => setFocusedField('fullName')}
                        onBlur={() => setFocusedField(null)}
                        onChange={(e) => { setFullName(e.target.value); setErrors((prev) => ({ ...prev, fullName: undefined })); }}
                        className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate"
                      />
                    </div>
                    {errors.fullName && (
                      <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
                        <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                        <span>{errors.fullName}</span>
                      </p>
                    )}
                  </div>

                  {/* 2. Dropdown Grid: [ Kelas ] [ Jurusan ] [ No. Kelas ] */}
                  <div>
                    <div key={`classgroup-box-${shakeKey}`} className={`grid grid-cols-3 gap-2.5 ${errors.classGroup ? 'do-shake' : ''}`}>
                      {/* Micro Dropdown 1: Kelas */}
                      <div className="relative">
                        <button
                          type="button"
                          onClick={() => { setOpenGrade(!openGrade); setOpenMajor(false); setOpenClassNum(false); }}
                          className={`w-full flex items-center justify-between h-13 rounded-2xl border bg-pure-white px-3 transition-all shadow-2xs cursor-pointer ${
                            errors.classGroup
                              ? 'border-rose-400 bg-rose-50/20'
                              : openGrade
                              ? 'border-[#1d64ec] ring-2 ring-blue-500/20 bg-blue-50/20'
                              : 'border-neutral-200 hover:border-neutral-300'
                          }`}
                        >
                          <span className={`w-full text-center text-sm font-bold truncate ${gradeLevel ? 'text-slate-900' : 'text-neutral-400 font-medium'}`}>
                            {gradeLevel || 'Kelas'}
                          </span>
                          <ChevronDown className={`h-4 w-4 shrink-0 transition-transform duration-200 ${openGrade ? 'rotate-180 text-[#1d64ec]' : 'text-neutral-400'}`} />
                        </button>

                        {openGrade && (
                          <div className="absolute left-0 top-full mt-1.5 z-50 w-[130%] min-w-full bg-white/98 backdrop-blur-md border border-neutral-200/90 rounded-2xl p-1 shadow-xl shadow-black/10 animate-in fade-in zoom-in-95 duration-150 space-y-0.5">
                            {gradeOptions.map((opt) => (
                              <button
                                key={opt}
                                type="button"
                                onClick={() => { setGradeLevel(opt); setOpenGrade(false); setErrors((prev) => ({ ...prev, classGroup: undefined })); }}
                                className={`w-full flex items-center justify-between py-1.5 px-2.5 rounded-xl text-xs font-bold transition-all active:scale-95 cursor-pointer ${
                                  gradeLevel === opt
                                    ? 'bg-[#1d64ec] text-white shadow-2xs'
                                    : 'text-slate-700 hover:bg-neutral-100 hover:text-slate-900'
                                }`}
                              >
                                <span className="truncate">{opt}</span>
                                {gradeLevel === opt && <Check className="h-3.5 w-3.5 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>

                      {/* Micro Dropdown 2: Jurusan */}
                      <div className="relative">
                        <button
                          type="button"
                          onClick={() => { setOpenMajor(!openMajor); setOpenGrade(false); setOpenClassNum(false); }}
                          className={`w-full flex items-center justify-between h-13 rounded-2xl border bg-pure-white px-3 transition-all shadow-2xs cursor-pointer ${
                            errors.classGroup
                              ? 'border-rose-400 bg-rose-50/20'
                              : openMajor
                              ? 'border-[#1d64ec] ring-2 ring-blue-500/20 bg-blue-50/20'
                              : 'border-neutral-200 hover:border-neutral-300'
                          }`}
                        >
                          <span className={`w-full text-center text-sm font-bold truncate ${major ? 'text-slate-900' : 'text-neutral-400 font-medium'}`}>
                            {major || 'Jurusan'}
                          </span>
                          <ChevronDown className={`h-4 w-4 shrink-0 transition-transform duration-200 ${openMajor ? 'rotate-180 text-[#1d64ec]' : 'text-neutral-400'}`} />
                        </button>

                        {openMajor && (
                          <div className="absolute left-1/2 -translate-x-1/2 top-full mt-1.5 z-50 min-w-[125px] w-[130%] bg-white/98 backdrop-blur-md border border-neutral-200/90 rounded-2xl p-1 shadow-xl shadow-black/10 animate-in fade-in zoom-in-95 duration-150 max-h-48 overflow-y-auto space-y-0.5 no-scrollbar">
                            {majorOptions.map((opt) => (
                              <button
                                key={opt}
                                type="button"
                                onClick={() => { setMajor(opt); setOpenMajor(false); setErrors((prev) => ({ ...prev, classGroup: undefined })); }}
                                className={`w-full flex items-center justify-between py-1.5 px-2.5 rounded-xl text-xs font-bold transition-all active:scale-95 cursor-pointer ${
                                  major === opt
                                    ? 'bg-[#1d64ec] text-white shadow-2xs'
                                    : 'text-slate-700 hover:bg-neutral-100 hover:text-slate-900'
                                }`}
                              >
                                <span>{opt}</span>
                                {major === opt && <Check className="h-3.5 w-3.5 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>

                      {/* Micro Dropdown 3: No. Kelas */}
                      <div className="relative">
                        <button
                          type="button"
                          onClick={() => { setOpenClassNum(!openClassNum); setOpenGrade(false); setOpenMajor(false); }}
                          className={`w-full flex items-center justify-between h-13 rounded-2xl border bg-pure-white px-2.5 transition-all shadow-2xs cursor-pointer ${
                            errors.classGroup
                              ? 'border-rose-400 bg-rose-50/20'
                              : openClassNum
                              ? 'border-[#1d64ec] ring-2 ring-blue-500/20 bg-blue-50/20'
                              : 'border-neutral-200 hover:border-neutral-300'
                          }`}
                        >
                          <span className={`w-full text-center text-xs font-bold truncate ${classNumber ? 'text-[#111827]' : 'text-neutral-400 font-medium'}`}>
                            {classNumber || 'No. Kelas'}
                          </span>
                          <ChevronDown className={`h-3.5 w-3.5 shrink-0 transition-transform duration-200 ${openClassNum ? 'rotate-180 text-[#1d64ec]' : 'text-neutral-400'}`} />
                        </button>

                        {openClassNum && (
                          <div className="absolute right-0 top-full mt-1.5 z-50 w-[130%] min-w-full bg-white/98 backdrop-blur-md border border-neutral-200/90 rounded-2xl p-1 shadow-xl shadow-black/10 animate-in fade-in zoom-in-95 duration-150 space-y-0.5">
                            {classNumOptions.map((opt) => (
                              <button
                                key={opt}
                                type="button"
                                onClick={() => { setClassNumber(opt); setOpenClassNum(false); setErrors((prev) => ({ ...prev, classGroup: undefined })); }}
                                className={`w-full flex items-center justify-between py-1.5 px-2.5 rounded-xl text-xs font-bold transition-all active:scale-95 cursor-pointer ${
                                  classNumber === opt
                                    ? 'bg-[#1d64ec] text-[#ffffff] shadow-2xs'
                                    : 'text-slate-700 hover:bg-neutral-100 hover:text-slate-900'
                                }`}
                              >
                                <span>{opt}</span>
                                {classNumber === opt && <Check className="h-3.5 w-3.5 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                    {errors.classGroup && (
                      <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
                        <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                        <span>{errors.classGroup}</span>
                      </p>
                    )}
                  </div>

                  {/* 3. WhatsApp Phone Number 2-Box Layout with 3-4-4 Auto Hyphen Formatting */}
                  <div>
                    <div key={`phone-box-${shakeKey}`} className={`flex items-center gap-2.5 ${errors.phoneNumber ? 'do-shake' : ''}`}>
                      {/* Left Box: Indonesian Flag +62 Country Badge */}
                      <div className="w-[88px] h-16 rounded-[22px] border border-neutral-200/90 bg-neutral-50/80 flex items-center justify-center gap-1.5 shadow-2xs shrink-0 select-none">
                        <span className="text-lg leading-none">🇮🇩</span>
                        <span className="text-xs font-extrabold text-slate-900 tracking-tight font-mono">+62</span>
                      </div>

                      {/* Right Box: Phone Input with Floating Label & 3-4-4 Auto-Hyphen Formatting */}
                      <div
                        className={`flex-1 relative flex items-center h-16 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
                          errors.phoneNumber
                            ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20'
                            : focusedField === 'phoneNumber'
                            ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
                            : 'border-neutral-200 hover:border-neutral-300'
                        }`}
                      >
                        <label
                          htmlFor="register-phone-input"
                          className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
                            focusedField === 'phoneNumber' || phoneNumber
                              ? 'left-3.5 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                              : 'left-4 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
                          } ${
                            errors.phoneNumber
                              ? 'text-rose-500 font-semibold'
                              : focusedField === 'phoneNumber'
                              ? 'text-[#1d64ec] font-semibold'
                              : phoneNumber
                              ? 'text-slate-900 font-semibold'
                              : 'text-neutral-400 font-normal'
                          }`}
                        >
                          Nomor WhatsApp / HP
                        </label>

                        <input
                          id="register-phone-input"
                          name="phoneNumber"
                          type="tel"
                          inputMode="numeric"
                          pattern="[0-9]*"
                          value={formatPhoneWithHyphens(phoneNumber)}
                          onFocus={() => setFocusedField('phoneNumber')}
                          onBlur={() => setFocusedField(null)}
                          onChange={(e) => {
                            let digitsOnly = e.target.value.replace(/\D/g, '');
                            if (digitsOnly.startsWith('0')) {
                              digitsOnly = digitsOnly.slice(1);
                            } else if (digitsOnly.startsWith('62')) {
                              digitsOnly = digitsOnly.slice(2);
                            }
                            if (digitsOnly.length > 12) {
                              digitsOnly = digitsOnly.slice(0, 12);
                            }
                            setPhoneNumber(digitsOnly);
                            setErrors((prev) => ({ ...prev, phoneNumber: undefined }));
                          }}
                          className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate tracking-wide font-mono"
                          placeholder={focusedField === 'phoneNumber' ? '857-9799-8570' : ''}
                        />
                      </div>
                    </div>

                    {errors.phoneNumber && (
                      <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
                        <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                        <span>{errors.phoneNumber}</span>
                      </p>
                    )}
                  </div>
                </div>
              ) : (
                /* LOGIN TAB FIELD 1: Nomor WhatsApp / Email */
                <div>
                  <div
                    key={`login-id-box-${shakeKey}`}
                    className={`relative flex items-center h-16 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
                      errors.loginIdentifier
                        ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
                        : focusedField === 'loginIdentifier'
                        ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
                        : 'border-neutral-200 hover:border-neutral-300'
                    }`}
                  >
                    <Mail className={`h-5 w-5 shrink-0 mr-3 ${errors.loginIdentifier ? 'text-rose-500' : focusedField === 'loginIdentifier' ? 'text-[#1d64ec]' : 'text-emerald-800'}`} aria-hidden="true" />
                    
                    <label
                      htmlFor="auth-login-identifier-input"
                      className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
                        focusedField === 'loginIdentifier' || loginIdentifier
                          ? 'left-8 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                          : 'left-11 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
                      } ${
                        errors.loginIdentifier
                          ? 'text-rose-500 font-semibold'
                          : focusedField === 'loginIdentifier'
                          ? 'text-[#1d64ec] font-semibold'
                          : loginIdentifier
                          ? 'text-slate-900 font-semibold'
                          : 'text-neutral-400 font-normal'
                      }`}
                    >
                      Nomor WhatsApp / Email
                    </label>

                    <input
                      id="auth-login-identifier-input"
                      name="loginIdentifier"
                      type="text"
                      value={loginIdentifier}
                      onFocus={() => setFocusedField('loginIdentifier')}
                      onBlur={() => setFocusedField(null)}
                      onChange={(e) => { setLoginIdentifier(e.target.value); setErrors((prev) => ({ ...prev, loginIdentifier: undefined })); }}
                      className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate"
                    />
                  </div>
                  {errors.loginIdentifier && (
                    <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
                      <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                      <span>{errors.loginIdentifier}</span>
                    </p>
                  )}
                </div>
              )}

              {/* 4. Password Floating Label Field */}
              <div>
                <div
                  key={`password-box-${shakeKey}`}
                  className={`relative flex items-center h-16 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
                    errors.password
                      ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
                      : focusedField === 'password'
                      ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
                      : 'border-neutral-200 hover:border-neutral-300'
                  }`}
                >
                  <Lock className={`h-5 w-5 shrink-0 mr-3 ${errors.password ? 'text-rose-500' : focusedField === 'password' ? 'text-[#1d64ec]' : 'text-emerald-800'}`} aria-hidden="true" />
                  
                  <label
                    htmlFor="auth-password-input"
                    className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
                      focusedField === 'password' || password
                        ? 'left-8 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                        : 'left-11 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
                    } ${
                      errors.password
                        ? 'text-rose-500 font-semibold'
                        : focusedField === 'password'
                        ? 'text-[#1d64ec] font-semibold'
                        : password
                        ? 'text-slate-900 font-semibold'
                        : 'text-neutral-400 font-normal'
                    }`}
                  >
                    Kata Sandi
                  </label>

                  <input
                    id="auth-password-input"
                    name="password"
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onFocus={() => setFocusedField('password')}
                    onBlur={() => setFocusedField(null)}
                    onChange={(e) => { setPassword(e.target.value); setErrors((prev) => ({ ...prev, password: undefined })); }}
                    className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate"
                  />

                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="text-neutral-400 hover:text-slate-900 p-1.5 cursor-pointer focus-visible:ring-2 focus-visible:ring-blue-500 rounded-lg"
                    aria-label={showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'}
                  >
                    {showPassword ? <EyeOff className="h-5 w-5" aria-hidden="true" /> : <Eye className="h-5 w-5" aria-hidden="true" />}
                  </button>
                </div>
                {errors.password && (
                  <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
                    <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                    <span>{errors.password}</span>
                  </p>
                )}
              </div>

              {/* Options Row */}
              {authTab === 'login' ? (
                <div className="flex items-center justify-between text-xs pt-0.5 px-1">
                  <label htmlFor="remember-me-checkbox" className="flex items-center gap-2 cursor-pointer text-slate-700 select-none font-medium">
                    <input
                      id="remember-me-checkbox"
                      name="rememberMe"
                      type="checkbox"
                      checked={rememberMe}
                      onChange={(e) => setRememberMe(e.target.checked)}
                      className="h-4.5 w-4.5 rounded-md border-neutral-300 text-[#1d64ec] focus:ring-blue-500/20 cursor-pointer"
                    />
                    <span className="text-xs font-semibold text-slate-900">Ingat Saya</span>
                  </label>
                  <button
                    type="button"
                    className="text-xs font-semibold text-[#1d64ec] hover:underline cursor-pointer focus-visible:ring-2 focus-visible:ring-blue-500 rounded-sm"
                  >
                    Lupa Kata Sandi?
                  </button>
                </div>
              ) : (
                <div>
                  <div key={`terms-box-${shakeKey}`} className={`flex items-start pt-1 px-1 animate-in fade-in duration-300 ${errors.agreeTerms ? 'do-shake' : ''}`}>
                    <Checkbox
                      id="agree-terms-checkbox"
                      checked={agreeTerms}
                      onCheckedChange={(checked) => {
                        setAgreeTerms(checked);
                        setErrors((prev) => ({ ...prev, agreeTerms: undefined }));
                      }}
                      label={
                        <>
                          Saya menyetujui <span className="font-bold text-[#1d64ec] hover:underline cursor-pointer">Syarat & Ketentuan</span> serta <span className="font-bold text-[#1d64ec] hover:underline cursor-pointer">Kebijakan Privasi</span> Snapan Market
                        </>
                      }
                    />
                  </div>
                  {errors.agreeTerms && (
                    <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
                      <AlertCircle className="h-3.5 w-3.5 shrink-0" />
                      <span>{errors.agreeTerms}</span>
                    </p>
                  )}
                </div>
              )}

              {/* Submit Primary Button (Disabled until all inputs & terms are completed) */}
              <ButtonPrimary
                type="submit"
                size="lg"
                disabled={isSubmitting || (authTab === 'register' ? isRegisterIncomplete : isLoginIncomplete)}
                className="w-full justify-center font-bold h-14 text-base rounded-full mt-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSubmitting ? (
                  <Loader2 className="h-5 w-5 animate-spin text-white" />
                ) : authTab === 'login' ? (
                  'Masuk'
                ) : (
                  'Lanjut Verifikasi OTP'
                )}
              </ButtonPrimary>
            </form>

            {/* Divider */}
            <div className="relative flex items-center justify-center py-2.5 my-1">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-neutral-200" />
              </div>
              <span className="relative bg-pure-white px-3.5 text-xs font-medium text-neutral-500 select-none">
                Atau {authTab === 'login' ? 'masuk' : 'daftar'} dengan
              </span>
            </div>

            {/* Social Auth Buttons */}
            <div className="grid grid-cols-2 gap-3 pb-1">
              {/* Google Login */}
              <ButtonSecondary
                type="button"
                size="lg"
                onClick={() => handleMockSocialLogin('Google')}
                disabled={isSubmitting}
                className="w-full justify-center font-bold text-sm h-14 rounded-full border border-neutral-200 text-slate-900"
                iconLeft={
                  <svg className="h-5 w-5" viewBox="0 0 24 24" aria-hidden="true">
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
                }
              >
                Google
              </ButtonSecondary>

              {/* Facebook Login */}
              <ButtonSecondary
                type="button"
                size="lg"
                onClick={() => handleMockSocialLogin('Facebook')}
                disabled={isSubmitting}
                className="w-full justify-center font-bold text-sm h-14 rounded-full border border-neutral-200 text-slate-900"
                iconLeft={
                  <svg className="h-5 w-5 fill-[#1877F2]" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
                  </svg>
                }
              >
                Facebook
              </ButtonSecondary>
            </div>
          </>
        )}
      </div>
    </div>
  );
};
