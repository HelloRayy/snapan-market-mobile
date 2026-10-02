import { useState } from 'react';
import {
  CheckCircle2,
  XCircle,
  Copy,
  ShieldCheck,
  GraduationCap,
  ShoppingBag,
  TrendingUp,
} from 'lucide-react';
import { SlideOverDrawer } from './SlideOverDrawer';
import type { ProfileRow } from '../services/adminService';

interface UserDetailDrawerProps {
  user: ProfileRow | null;
  isOpen: boolean;
  onClose: () => void;
  onToggleVerify: (userId: string, currentStatus: boolean) => Promise<void>;
  onChangeRole: (user: ProfileRow, newRole: 'buyer' | 'seller' | 'admin') => void;
  isUpdating: boolean;
}

export function UserDetailDrawer({
  user,
  isOpen,
  onClose,
  onToggleVerify,
  onChangeRole,
  isUpdating,
}: UserDetailDrawerProps) {
  const [copiedId, setCopiedId] = useState(false);

  if (!user) return null;

  const handleCopyId = () => {
    navigator.clipboard.writeText(user.id);
    setCopiedId(true);
    setTimeout(() => setCopiedId(false), 2000);
  };

  return (
    <SlideOverDrawer
      isOpen={isOpen}
      onClose={onClose}
      title="Inspeksi Akun Siswa"
      subtitle={`Terdaftar sejak ${new Date(user.created_at).toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      })}`}
    >
      {/* 1. Student Hero Profile */}
      <div className="flex items-center gap-4 p-4 rounded-2xl bg-slate-50/80 border border-slate-200/80">
        <div className="h-16 w-16 rounded-2xl bg-[#EEF0FF] border-2 border-[#D8DBFE] flex items-center justify-center font-bold text-2xl text-[#3D38F5] shadow-xs shrink-0 overflow-hidden">
          {user.avatar_url ? (
            <img
              src={user.avatar_url}
              alt={user.full_name || ''}
              className="h-full w-full object-cover"
            />
          ) : user.full_name ? (
            user.full_name.charAt(0).toUpperCase()
          ) : (
            'S'
          )}
        </div>
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-1.5 flex-wrap">
            <h3 className="text-base font-bold text-slate-900 truncate">
              {user.full_name || 'Tanpa Nama Lengkap'}
            </h3>
            {user.is_verified && (
              <CheckCircle2 className="h-4 w-4 text-blue-600 fill-blue-50" />
            )}
          </div>
          <p className="text-xs text-slate-500 font-medium">@{user.username || 'username'}</p>
          <div className="mt-2 flex items-center gap-1.5 flex-wrap">
            <span
              className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10.5px] font-bold uppercase tracking-wider border ${
                user.role === 'admin'
                  ? 'bg-purple-50 text-purple-700 border-purple-200'
                  : user.role === 'seller'
                  ? 'bg-indigo-50 text-indigo-700 border-indigo-200'
                  : 'bg-slate-100 text-slate-700 border-slate-200'
              }`}
            >
              <ShieldCheck className="h-3 w-3" />
              {user.role}
            </span>
            <span
              className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10.5px] font-semibold border ${
                user.is_verified
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                  : 'bg-amber-50 text-amber-700 border-amber-200'
              }`}
            >
              {user.is_verified ? 'Siswa Terverifikasi' : 'Menunggu Verifikasi'}
            </span>
          </div>
        </div>
      </div>

      {/* 2. Academic & Identification Information */}
      <div className="space-y-3">
        <h4 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
          Data Akademik & Marketplace
        </h4>
        <div className="rounded-2xl border border-slate-200/80 bg-white p-4 space-y-3 text-xs shadow-2xs">
          <div className="flex items-center justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 flex items-center gap-2">
              <GraduationCap className="h-4 w-4 text-slate-400" /> Kelas & Jurusan
            </span>
            <span className="font-semibold text-slate-900">
              {user.class_group || 'Umum'}
            </span>
          </div>

          <div className="flex items-center justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 flex items-center gap-2">
              <ShoppingBag className="h-4 w-4 text-slate-400" /> Transaksi Terverifikasi
            </span>
            <span className="font-semibold text-slate-900 tabular-nums">
              {user.verified_sales_count || 0} transaksi
            </span>
          </div>

          <div className="flex items-center justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500 flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-slate-400" /> Total Perputaran COD
            </span>
            <span className="font-semibold text-slate-900 tabular-nums">
              Rp {(user.total_revenue_idr || 0).toLocaleString('id-ID')}
            </span>
          </div>

          <div className="flex items-center justify-between py-1">
            <span className="text-slate-500 flex items-center gap-2">
              <Copy className="h-4 w-4 text-slate-400" /> User UUID
            </span>
            <button
              onClick={handleCopyId}
              className="font-mono text-[11px] text-[#3D38F5] hover:underline flex items-center gap-1 cursor-pointer"
            >
              {user.id.slice(0, 12)}...
              <span className="text-[10px] bg-slate-100 px-1 py-0.2 rounded border border-slate-200">
                {copiedId ? 'Disalin!' : 'Salin'}
              </span>
            </button>
          </div>
        </div>
      </div>

      {/* 3. Role & Permissions Action Control */}
      <div className="space-y-3">
        <h4 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
          Ubah Hak Otorisasi (RBAC)
        </h4>
        <div className="grid grid-cols-3 gap-2">
          {(['buyer', 'seller', 'admin'] as const).map((r) => {
            const isSelected = user.role === r;
            return (
              <button
                key={r}
                disabled={isUpdating}
                onClick={() => onChangeRole(user, r)}
                className={`py-2 px-3 rounded-xl border text-xs font-semibold capitalize transition-all cursor-pointer text-center ${
                  isSelected
                    ? 'bg-[#EEF0FF] text-[#3D38F5] border-[#D8DBFE] shadow-2xs ring-1 ring-[#3D38F5]/20'
                    : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50 hover:text-slate-900'
                }`}
              >
                {r === 'buyer' ? 'Siswa (Buyer)' : r === 'seller' ? 'Penjual (Seller)' : 'Staff Admin'}
              </button>
            );
          })}
        </div>
      </div>

      {/* 4. Verification Toggle Action Button */}
      <div className="pt-2">
        <button
          disabled={isUpdating}
          onClick={() => onToggleVerify(user.id, user.is_verified)}
          className={`w-full py-2.5 px-4 rounded-xl font-semibold text-xs transition-all flex items-center justify-center gap-2 cursor-pointer ${
            user.is_verified
              ? 'bg-amber-50 text-amber-800 border border-amber-200 hover:bg-amber-100'
              : 'bg-[#3D38F5] text-white hover:bg-[#312BD9] shadow-[0_2px_8px_rgba(61,56,245,0.25)]'
          }`}
        >
          {user.is_verified ? (
            <>
              <XCircle className="h-4 w-4" />
              <span>Cabut Lencana Verifikasi</span>
            </>
          ) : (
            <>
              <CheckCircle2 className="h-4 w-4" />
              <span>Beri Lencana Terverifikasi Resmi</span>
            </>
          )}
        </button>
      </div>
    </SlideOverDrawer>
  );
}
