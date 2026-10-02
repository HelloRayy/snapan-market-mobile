import { useState } from 'react';
import {
  X,
  CheckCircle2,
  XCircle,
  Copy,
  ShieldCheck,
  GraduationCap,
  ShoppingBag,
  TrendingUp,
} from 'lucide-react';
import type { ProfileRow } from '../services/adminService';
import { Badge } from './tremor/Badge';

interface UserDetailModalProps {
  user: ProfileRow | null;
  isOpen: boolean;
  onClose: () => void;
  onToggleVerify: (userId: string, currentStatus: boolean) => Promise<void>;
  onChangeRole: (user: ProfileRow, newRole: 'buyer' | 'seller' | 'admin') => void;
  isUpdating: boolean;
}

export function UserDetailModal({
  user,
  isOpen,
  onClose,
  onToggleVerify,
  onChangeRole,
  isUpdating,
}: UserDetailModalProps) {
  const [copiedId, setCopiedId] = useState(false);

  if (!isOpen || !user) return null;

  const handleCopyId = () => {
    navigator.clipboard.writeText(user.id);
    setCopiedId(true);
    setTimeout(() => setCopiedId(false), 2000);
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 flex flex-col max-h-[90vh]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50/50">
          <div>
            <h3 className="text-base font-bold text-slate-900">
              Inspeksi Profil Siswa
            </h3>
            <p className="text-xs text-slate-500 mt-0.5">
              Bergabung sejak {new Date(user.created_at).toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'long',
                year: 'numeric',
              })}
            </p>
          </div>
          <button
            onClick={onClose}
            className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
            aria-label="Tutup modal"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 overflow-y-auto space-y-5 text-xs">
          {/* Hero Profile Card */}
          <div className="flex items-center gap-4 p-4 rounded-xl bg-slate-50 border border-slate-200/80">
            <div className="h-14 w-14 rounded-xl bg-[#EEF0FF] border-2 border-[#D8DBFE] flex items-center justify-center font-bold text-xl text-[#3D38F5] shrink-0 overflow-hidden shadow-2xs">
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
                <h4 className="text-sm font-bold text-slate-900 truncate">
                  {user.full_name || 'Tanpa Nama Lengkap'}
                </h4>
                {user.is_verified && (
                  <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 fill-blue-50" />
                )}
              </div>
              <p className="text-xs text-slate-500">@{user.username || 'username'}</p>
              <div className="mt-2 flex items-center gap-1.5 flex-wrap">
                <Badge
                  variant={
                    user.role === 'admin'
                      ? 'purple'
                      : user.role === 'seller'
                      ? 'indigo'
                      : 'slate'
                  }
                  className="uppercase text-[10px]"
                >
                  <ShieldCheck className="h-3 w-3 mr-0.5" />
                  {user.role}
                </Badge>
                <Badge variant={user.is_verified ? 'emerald' : 'amber'}>
                  {user.is_verified ? 'Terverifikasi' : 'Belum Verifikasi'}
                </Badge>
              </div>
            </div>
          </div>

          {/* Academic & Stats Table */}
          <div className="space-y-2">
            <h5 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
              Informasi Akademik & Kejuruan
            </h5>
            <div className="rounded-xl border border-slate-200 bg-white divide-y divide-slate-100">
              <div className="flex items-center justify-between p-3">
                <span className="text-slate-500 flex items-center gap-2">
                  <GraduationCap className="h-4 w-4 text-slate-400" /> Kelas & Jurusan
                </span>
                <span className="font-semibold text-slate-900">
                  {user.class_group || 'Umum'}
                </span>
              </div>
              <div className="flex items-center justify-between p-3">
                <span className="text-slate-500 flex items-center gap-2">
                  <ShoppingBag className="h-4 w-4 text-slate-400" /> Transaksi Terverifikasi
                </span>
                <span className="font-semibold text-slate-900 tabular-nums">
                  {user.verified_sales_count || 0} transaksi
                </span>
              </div>
              <div className="flex items-center justify-between p-3">
                <span className="text-slate-500 flex items-center gap-2">
                  <TrendingUp className="h-4 w-4 text-slate-400" /> Total Perputaran COD
                </span>
                <span className="font-semibold text-slate-900 tabular-nums">
                  Rp {(user.total_revenue_idr || 0).toLocaleString('id-ID')}
                </span>
              </div>
              <div className="flex items-center justify-between p-3">
                <span className="text-slate-500 flex items-center gap-2">
                  <Copy className="h-4 w-4 text-slate-400" /> User UUID
                </span>
                <button
                  onClick={handleCopyId}
                  className="font-mono text-[11px] text-[#3D38F5] hover:underline flex items-center gap-1 cursor-pointer"
                >
                  {user.id.slice(0, 10)}...
                  <span className="text-[10px] bg-slate-100 px-1 py-0.5 rounded border border-slate-200">
                    {copiedId ? 'Disalin' : 'Salin'}
                  </span>
                </button>
              </div>
            </div>
          </div>

          {/* RBAC Role Selector */}
          <div className="space-y-2">
            <h5 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
              Otorisasi Hak Akses (RBAC)
            </h5>
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
                        ? 'bg-[#EEF0FF] text-[#3D38F5] border-[#D8DBFE] ring-1 ring-[#3D38F5]/20'
                        : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'
                    }`}
                  >
                    {r === 'buyer' ? 'Siswa (Buyer)' : r === 'seller' ? 'Penjual (Seller)' : 'Staff Admin'}
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-200/60 transition-colors cursor-pointer"
          >
            Tutup
          </button>
          <button
            disabled={isUpdating}
            onClick={() => onToggleVerify(user.id, user.is_verified)}
            className={`px-4 py-2 rounded-xl font-semibold text-xs transition-all flex items-center gap-1.5 cursor-pointer shadow-xs ${
              user.is_verified
                ? 'bg-amber-50 text-amber-800 border border-amber-200 hover:bg-amber-100'
                : 'bg-[#3D38F5] text-white hover:bg-[#312BD9]'
            }`}
          >
            {user.is_verified ? (
              <>
                <XCircle className="h-3.5 w-3.5" />
                <span>Cabut Verifikasi</span>
              </>
            ) : (
              <>
                <CheckCircle2 className="h-3.5 w-3.5" />
                <span>Verifikasi Siswa</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
