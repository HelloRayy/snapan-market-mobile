import React, { useState, useRef, useEffect } from 'react';
import { signInWithGoogle, signInWithEmail, signUpWithEmail } from '@/services/api/authService';
import { AuthHeader } from './auth/AuthHeader';
import { AuthLoginForm } from './auth/AuthLoginForm';
import { AuthRegisterForm } from './auth/AuthRegisterForm';
import { AuthOtpVerificationSheet } from './auth/AuthOtpVerificationSheet';

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

  const formSheetRef = useRef<HTMLDivElement>(null);

  // Form State
  const [fullName, setFullName] = useState('');
  const [gradeLevel, setGradeLevel] = useState('');
  const [major, setMajor] = useState('');
  const [classNumber, setClassNumber] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [loginIdentifier, setLoginIdentifier] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(true);
  const [agreeTerms, setAgreeTerms] = useState(false);

  // 6-Digit WhatsApp OTP State
  const [otpDigits, setOtpDigits] = useState<string[]>(['', '', '', '', '', '']);
  const [countdown, setCountdown] = useState(60);

  // Focus & Error State
  const [focusedField, setFocusedField] = useState<string | null>(null);
  const [errors, setErrors] = useState<FormErrors>({});
  const [shakeKey, setShakeKey] = useState(0);

  // OTP Countdown Timer Logic (60 seconds)
  useEffect(() => {
    let timer: ReturnType<typeof setInterval>;
    if (regStep === 'otp' && countdown > 0) {
      timer = setInterval(() => {
        setCountdown((prev) => prev - 1);
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [regStep, countdown]);

  const handleOtpChange = (index: number, val: string) => {
    const cleanDigit = val.replace(/\D/g, '').slice(-1);
    const newDigits = [...otpDigits];
    newDigits[index] = cleanDigit;
    setOtpDigits(newDigits);
    setErrors((prev) => ({ ...prev, otpCode: undefined }));

    if (cleanDigit && index < 5) {
      const nextInput = document.querySelectorAll<HTMLInputElement>('input[aria-label*="kode verifikasi OTP"]')[index + 1];
      nextInput?.focus();
    }
  };

  const handleOtpKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !otpDigits[index] && index > 0) {
      const prevInput = document.querySelectorAll<HTMLInputElement>('input[aria-label*="kode verifikasi OTP"]')[index - 1];
      prevInput?.focus();
    } else if (e.key === 'ArrowLeft' && index > 0) {
      const prevInput = document.querySelectorAll<HTMLInputElement>('input[aria-label*="kode verifikasi OTP"]')[index - 1];
      prevInput?.focus();
    } else if (e.key === 'ArrowRight' && index < 5) {
      const nextInput = document.querySelectorAll<HTMLInputElement>('input[aria-label*="kode verifikasi OTP"]')[index + 1];
      nextInput?.focus();
    }
  };

  const handleOtpPaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6);
    if (!pastedData) return;

    const newDigits = [...otpDigits];
    for (let i = 0; i < 6; i++) {
      newDigits[i] = pastedData[i] || '';
    }
    setOtpDigits(newDigits);
    setErrors((prev) => ({ ...prev, otpCode: undefined }));

    const focusIdx = Math.min(pastedData.length, 5);
    const targetInput = document.querySelectorAll<HTMLInputElement>('input[aria-label*="kode verifikasi OTP"]')[focusIdx];
    targetInput?.focus();
  };

  const handleResendOtp = () => {
    setCountdown(60);
    setOtpDigits(['', '', '', '', '', '']);
    setErrors({});
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    const fullCode = otpDigits.join('');

    if (fullCode.length < 6) {
      setErrors({ otpCode: 'Harap masukkan 6 angka kode OTP lengkap' });
      setShakeKey((k) => k + 1);
      return;
    }

    setIsSubmitting(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      if (onSuccess) onSuccess();
    } catch {
      setErrors({ otpCode: 'Kode OTP salah atau telah kedaluwarsa' });
      setShakeKey((k) => k + 1);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleSubmitForm = async (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: FormErrors = {};

    if (authTab === 'login') {
      if (!loginIdentifier.trim()) {
        newErrors.loginIdentifier = 'Email, WhatsApp, atau Username wajib diisi';
      }
      if (!password) {
        newErrors.password = 'Kata sandi wajib diisi';
      }

      if (Object.keys(newErrors).length > 0) {
        setErrors(newErrors);
        setShakeKey((k) => k + 1);
        return;
      }

      setIsSubmitting(true);
      try {
        await signInWithEmail(loginIdentifier, password);
        if (onSuccess) onSuccess();
      } catch (err: any) {
        setErrors({ loginIdentifier: 'Email atau kata sandi tidak sesuai' });
        setShakeKey((k) => k + 1);
      } finally {
        setIsSubmitting(false);
      }
    } else {
      // Register validation
      if (!fullName.trim()) newErrors.fullName = 'Nama lengkap wajib diisi';
      if (!gradeLevel || !major || !classNumber) newErrors.classGroup = 'Pilih Kelas, Jurusan, dan No. Kelas';
      if (!phoneNumber.trim()) newErrors.phoneNumber = 'Nomor WhatsApp wajib diisi';
      else if (phoneNumber.length < 9) newErrors.phoneNumber = 'Nomor WhatsApp minimal 9 digit';
      if (!password) newErrors.password = 'Kata sandi wajib dibuat';
      else if (password.length < 6) newErrors.password = 'Kata sandi minimal 6 karakter';
      if (!agreeTerms) newErrors.agreeTerms = 'Anda harus menyetujui Ketentuan Layanan';

      if (Object.keys(newErrors).length > 0) {
        setErrors(newErrors);
        setShakeKey((k) => k + 1);
        return;
      }

      setIsSubmitting(true);
      try {
        await signUpWithEmail(`${phoneNumber}@snapan.id`, password, fullName);
        setRegStep('otp');
        setCountdown(60);
      } catch {
        setRegStep('otp');
      } finally {
        setIsSubmitting(false);
      }
    }
  };

  const handleGoogleAuth = async () => {
    try {
      await signInWithGoogle();
      if (onSuccess) onSuccess();
    } catch {}
  };

  return (
    <div className="flex h-full flex-col justify-between overflow-y-auto no-scrollbar font-sans px-5 pt-3 pb-0 select-none">
      <AuthHeader
        authTab={authTab}
        regStep={regStep}
        onBack={regStep === 'otp' ? () => setRegStep('form') : onBack}
      />

      <div className="flex-1 flex flex-col justify-end relative overflow-visible">
        <div
          ref={formSheetRef}
          className="relative z-20 -mx-5 -mb-5 bg-pure-white px-6 shadow-2xl space-y-3.5 h-auto rounded-t-[36px] rounded-b-none border-t border-faint-border pt-5 pb-8 transition-all duration-300 cubic-bezier(0.16,1,0.3,1)"
        >
          {regStep === 'otp' ? (
            <AuthOtpVerificationSheet
              otpDigits={otpDigits}
              errors={errors}
              shakeKey={shakeKey}
              isSubmitting={isSubmitting}
              countdown={countdown}
              onOtpChange={handleOtpChange}
              onOtpKeyDown={handleOtpKeyDown}
              onOtpPaste={handleOtpPaste}
              onVerifyOtp={handleVerifyOtp}
              onResendOtp={handleResendOtp}
            />
          ) : (
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

              <form onSubmit={handleSubmitForm} noValidate className="space-y-4 pt-1">
                {authTab === 'login' ? (
                  <AuthLoginForm
                    loginIdentifier={loginIdentifier}
                    setLoginIdentifier={setLoginIdentifier}
                    password={password}
                    setPassword={setPassword}
                    rememberMe={rememberMe}
                    setRememberMe={setRememberMe}
                    showPassword={showPassword}
                    setShowPassword={setShowPassword}
                    focusedField={focusedField}
                    setFocusedField={setFocusedField}
                    errors={errors}
                    setErrors={setErrors}
                    shakeKey={shakeKey}
                    isSubmitting={isSubmitting}
                    onGoogleSignIn={handleGoogleAuth}
                  />
                ) : (
                  <AuthRegisterForm
                    fullName={fullName}
                    setFullName={setFullName}
                    gradeLevel={gradeLevel}
                    setGradeLevel={setGradeLevel}
                    major={major}
                    setMajor={setMajor}
                    classNumber={classNumber}
                    setClassNumber={setClassNumber}
                    phoneNumber={phoneNumber}
                    setPhoneNumber={setPhoneNumber}
                    password={password}
                    setPassword={setPassword}
                    showPassword={showPassword}
                    setShowPassword={setShowPassword}
                    agreeTerms={agreeTerms}
                    setAgreeTerms={setAgreeTerms}
                    focusedField={focusedField}
                    setFocusedField={setFocusedField}
                    errors={errors}
                    setErrors={setErrors}
                    shakeKey={shakeKey}
                    isSubmitting={isSubmitting}
                    onGoogleSignUp={handleGoogleAuth}
                  />
                )}
              </form>
            </>
          )}
        </div>
      </div>
    </div>
  );
};
