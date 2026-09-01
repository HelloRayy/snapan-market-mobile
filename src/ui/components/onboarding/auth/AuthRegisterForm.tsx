import React, { useState, useRef, useEffect } from 'react';
import { User, Lock, Eye, EyeOff, ChevronDown, Check, AlertCircle, Loader2 } from 'lucide-react';
import { ButtonPrimary } from '@/ui/components/ui/ButtonPrimary';
import { ButtonSecondary } from '@/ui/components/ui/ButtonSecondary';
import { Checkbox } from '@/ui/components/ui/Checkbox';

interface AuthRegisterFormProps {
  fullName: string;
  setFullName: (val: string) => void;
  gradeLevel: string;
  setGradeLevel: (val: string) => void;
  major: string;
  setMajor: (val: string) => void;
  classNumber: string;
  setClassNumber: (val: string) => void;
  phoneNumber: string;
  setPhoneNumber: (val: string) => void;
  password: string;
  setPassword: (val: string) => void;
  showPassword: boolean;
  setShowPassword: (val: boolean) => void;
  agreeTerms: boolean;
  setAgreeTerms: (val: boolean) => void;
  focusedField: string | null;
  setFocusedField: (val: string | null) => void;
  errors: { fullName?: string; classGroup?: string; phoneNumber?: string; password?: string; agreeTerms?: string };
  setErrors: React.Dispatch<React.SetStateAction<any>>;
  shakeKey: number;
  isSubmitting: boolean;
  onGoogleSignUp: () => void;
}

export const AuthRegisterForm: React.FC<AuthRegisterFormProps> = ({
  fullName,
  setFullName,
  gradeLevel,
  setGradeLevel,
  major,
  setMajor,
  classNumber,
  setClassNumber,
  phoneNumber,
  setPhoneNumber,
  password,
  setPassword,
  showPassword,
  setShowPassword,
  agreeTerms,
  setAgreeTerms,
  focusedField,
  setFocusedField,
  errors,
  setErrors,
  shakeKey,
  isSubmitting,
  onGoogleSignUp,
}) => {
  const [openGrade, setOpenGrade] = useState(false);
  const [openMajor, setOpenMajor] = useState(false);
  const [openClassNum, setOpenClassNum] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

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

  return (
    <div className="space-y-4 animate-in fade-in slide-in-from-bottom-3 duration-300 ease-out" ref={dropdownRef}>
      {/* 1. Full Name Floating Label Field */}
      <div>
        <div
          key={`fullname-box-${shakeKey}`}
          className={`relative flex items-center h-14 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
            errors.fullName
              ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
              : focusedField === 'fullName'
              ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
              : 'border-neutral-200 hover:border-neutral-300'
          }`}
        >
          <User className={`h-5 w-5 shrink-0 mr-3 ${errors.fullName ? 'text-rose-500' : focusedField === 'fullName' ? 'text-[#1d64ec]' : 'text-neutral-400'}`} aria-hidden="true" />
          
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
                ? 'text-[#1d64ec]'
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
            onChange={(e) => { setFullName(e.target.value); setErrors((prev: any) => ({ ...prev, fullName: undefined })); }}
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
                    onClick={() => { setGradeLevel(opt); setOpenGrade(false); setErrors((prev: any) => ({ ...prev, classGroup: undefined })); }}
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
                    onClick={() => { setMajor(opt); setOpenMajor(false); setErrors((prev: any) => ({ ...prev, classGroup: undefined })); }}
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
              <span className={`w-full text-center text-sm font-bold truncate ${classNumber ? `Kelas ${classNumber}` : 'text-neutral-400 font-medium'}`}>
                {classNumber ? `Kls ${classNumber}` : 'No. Kls'}
              </span>
              <ChevronDown className={`h-4 w-4 shrink-0 transition-transform duration-200 ${openClassNum ? 'rotate-180 text-[#1d64ec]' : 'text-neutral-400'}`} />
            </button>

            {openClassNum && (
              <div className="absolute right-0 top-full mt-1.5 z-50 w-full min-w-[100px] bg-white/98 backdrop-blur-md border border-neutral-200/90 rounded-2xl p-1 shadow-xl shadow-black/10 animate-in fade-in zoom-in-95 duration-150 space-y-0.5">
                {classNumOptions.map((opt) => (
                  <button
                    key={opt}
                    type="button"
                    onClick={() => { setClassNumber(opt); setOpenClassNum(false); setErrors((prev: any) => ({ ...prev, classGroup: undefined })); }}
                    className={`w-full flex items-center justify-between py-1.5 px-2.5 rounded-xl text-xs font-bold transition-all active:scale-95 cursor-pointer ${
                      classNumber === opt
                        ? 'bg-[#1d64ec] text-white shadow-2xs'
                        : 'text-slate-700 hover:bg-neutral-100 hover:text-slate-900'
                    }`}
                  >
                    <span>Kelas {opt}</span>
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

      {/* 3. Indonesian WhatsApp Phone Number (+62 Pill + 3-4-4 Hyphens) */}
      <div>
        <div key={`phone-box-${shakeKey}`} className="flex items-center gap-2">
          {/* Left Country Code Pill */}
          <div className="flex items-center justify-center gap-1.5 h-14 px-3.5 rounded-[22px] border border-neutral-200 bg-neutral-50/80 shadow-2xs select-none shrink-0">
            <span className="text-base">🇮🇩</span>
            <span className="text-sm font-extrabold text-slate-800 tracking-tight">+62</span>
          </div>

          {/* Right Phone Input with Floating Label & Auto-Hyphen */}
          <div
            className={`relative flex-1 flex items-center h-14 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
              errors.phoneNumber
                ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
                : focusedField === 'phoneNumber'
                ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
                : 'border-neutral-200 hover:border-neutral-300'
            }`}
          >
            <label
              htmlFor="register-phone-input"
              className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
                focusedField === 'phoneNumber' || phoneNumber
                  ? 'left-4 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                  : 'left-4 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
              } ${
                errors.phoneNumber
                  ? 'text-rose-500 font-semibold'
                  : focusedField === 'phoneNumber'
                  ? 'text-[#1d64ec]'
                  : phoneNumber
                  ? 'text-slate-900 font-semibold'
                  : 'text-neutral-400 font-normal'
              }`}
            >
              Nomor WhatsApp
            </label>

            <input
              id="register-phone-input"
              name="phone"
              type="tel"
              inputMode="numeric"
              value={formatPhoneWithHyphens(phoneNumber)}
              onFocus={() => setFocusedField('phoneNumber')}
              onBlur={() => setFocusedField(null)}
              onChange={(e) => {
                const rawDigits = e.target.value.replace(/\D/g, '').slice(0, 12);
                const cleaned = rawDigits.startsWith('0') ? rawDigits.slice(1) : rawDigits.startsWith('62') ? rawDigits.slice(2) : rawDigits;
                setPhoneNumber(cleaned);
                setErrors((prev: any) => ({ ...prev, phoneNumber: undefined }));
              }}
              className="w-full bg-transparent text-base font-extrabold text-slate-900 focus:outline-none pt-1 tracking-wider"
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

      {/* 4. Password Floating Label Input */}
      <div>
        <div
          key={`register-password-box-${shakeKey}`}
          className={`relative flex items-center h-14 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
            errors.password
              ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
              : focusedField === 'password'
              ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
              : 'border-neutral-200 hover:border-neutral-300'
          }`}
        >
          <Lock className={`h-5 w-5 shrink-0 mr-3 ${errors.password ? 'text-rose-500' : focusedField === 'password' ? 'text-[#1d64ec]' : 'text-neutral-400'}`} aria-hidden="true" />

          <label
            htmlFor="register-password-input"
            className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
              focusedField === 'password' || password
                ? 'left-8 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                : 'left-11 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
            } ${
              errors.password
                ? 'text-rose-500 font-semibold'
                : focusedField === 'password'
                ? 'text-[#1d64ec]'
                : password
                ? 'text-slate-900 font-semibold'
                : 'text-neutral-400 font-normal'
            }`}
          >
            Buat Kata Sandi
          </label>

          <input
            id="register-password-input"
            name="password"
            type={showPassword ? 'text' : 'password'}
            autoComplete="new-password"
            value={password}
            onFocus={() => setFocusedField('password')}
            onBlur={() => setFocusedField(null)}
            onChange={(e) => { setPassword(e.target.value); setErrors((prev: any) => ({ ...prev, password: undefined })); }}
            className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate"
          />

          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="text-neutral-400 hover:text-slate-700 transition-colors p-1.5 cursor-pointer ml-1"
            aria-label={showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'}
          >
            {showPassword ? <EyeOff className="h-4.5 w-4.5" /> : <Eye className="h-4.5 w-4.5" />}
          </button>
        </div>
        {errors.password && (
          <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>{errors.password}</span>
          </p>
        )}
      </div>

      {/* 5. Terms & Policy Checkbox */}
      <div>
        <label key={`terms-box-${shakeKey}`} className="flex items-start gap-2.5 text-xs text-slate-600 cursor-pointer select-none py-1">
          <div className="pt-0.5">
            <Checkbox checked={agreeTerms} onCheckedChange={(checked: boolean) => { setAgreeTerms(checked); setErrors((prev: any) => ({ ...prev, agreeTerms: undefined })); }} />
          </div>
          <span className="leading-snug">
            Saya menyetujui <span className="font-bold text-[#1d64ec] hover:underline">Ketentuan Layanan</span> dan <span className="font-bold text-[#1d64ec] hover:underline">Kebijakan Privasi</span> Snapan Market SMKN 8.
          </span>
        </label>
        {errors.agreeTerms && (
          <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>{errors.agreeTerms}</span>
          </p>
        )}
      </div>

      {/* Submit Button */}
      <ButtonPrimary
        type="submit"
        size="lg"
        disabled={isSubmitting}
        className="w-full justify-center font-bold h-13 text-sm rounded-full bg-[#1d64ec] hover:bg-blue-600 shadow-md shadow-blue-500/25 text-white cursor-pointer active:scale-[0.98]"
      >
        {isSubmitting ? <Loader2 className="h-5 w-5 animate-spin text-white" /> : 'Lanjut ke Verifikasi WA'}
      </ButtonPrimary>

      {/* Divider */}
      <div className="relative flex items-center justify-center py-2">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-neutral-200/80" />
        </div>
        <span className="relative bg-pure-white px-3 text-[11px] font-bold text-neutral-400 uppercase tracking-wider">
          atau
        </span>
      </div>

      {/* Google OAuth Button */}
      <ButtonSecondary
        type="button"
        size="lg"
        onClick={onGoogleSignUp}
        className="w-full justify-center font-bold h-13 text-sm rounded-full border-neutral-200/90 hover:bg-neutral-50 active:scale-[0.98] cursor-pointer flex items-center gap-2.5 text-slate-800"
      >
        <svg className="h-4.5 w-4.5 shrink-0" viewBox="0 0 24 24">
          <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" />
          <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" />
          <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z" />
          <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z" />
        </svg>
        <span>Daftar dengan Google</span>
      </ButtonSecondary>
    </div>
  );
};
