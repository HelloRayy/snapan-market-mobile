import { useState, useEffect, useCallback } from 'react';
import {
  Search,
  CheckCircle2,
  RefreshCw,
  AlertCircle,
  ChevronLeft,
  ChevronRight,
  Eye,
  ShieldAlert,
  UserCheck,
  GraduationCap,
} from 'lucide-react';
import { adminService, type ProfileRow } from '../services/adminService';
import { UserDetailDrawer } from '../components/UserDetailDrawer';
import {
  Card,
  Badge,
  Table,
  TableHead,
  TableHeaderCell,
  TableBody,
  TableRow,
  TableCell,
} from '../components/tremor';

export function UsersManagementTab() {
  const [users, setUsers] = useState<ProfileRow[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [verifFilter, setVerifFilter] = useState<'all' | 'verified' | 'unverified'>('all');
  const [page, setPage] = useState(1);
  const pageSize = 10;
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Selected Student for SlideOver Inspector Drawer
  const [selectedStudent, setSelectedStudent] = useState<ProfileRow | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  // Confirmation Modal for Role Changes
  const [pendingRoleChange, setPendingRoleChange] = useState<{
    user: ProfileRow;
    newRole: 'buyer' | 'seller' | 'admin';
  } | null>(null);

  const fetchUsers = useCallback(async () => {
    setIsLoading(true);
    try {
      const offset = (page - 1) * pageSize;
      const res = await adminService.getProfiles({
        search,
        role: roleFilter,
        verification: verifFilter,
        limit: pageSize,
        offset,
      });
      setUsers(res.data);
      setTotalCount(res.count);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat siswa: ${e?.message || e}` });
    } finally {
      setIsLoading(false);
    }
  }, [search, roleFilter, verifFilter, page, pageSize]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchUsers();
    }, 250);
    return () => clearTimeout(timer);
  }, [fetchUsers]);

  const handleRowClick = (user: ProfileRow) => {
    setSelectedStudent(user);
    setIsDrawerOpen(true);
  };

  const handleRoleChangePrompt = (user: ProfileRow, newRole: 'buyer' | 'seller' | 'admin') => {
    if (newRole === 'admin' || user.role === 'admin') {
      setPendingRoleChange({ user, newRole });
    } else {
      executeRoleChange(user.id, newRole);
    }
  };

  const executeRoleChange = async (userId: string, newRole: 'buyer' | 'seller' | 'admin') => {
    setUpdatingId(userId);
    try {
      await adminService.updateProfileRole(userId, newRole);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, role: newRole } : u))
      );
      if (selectedStudent?.id === userId) {
        setSelectedStudent((prev) => (prev ? { ...prev, role: newRole } : null));
      }
      setFeedbackMsg({
        type: 'success',
        text: `Otorisasi akun berhasil diperbarui menjadi ${newRole.toUpperCase()}`,
      });
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: e?.message || `Gagal mengubah role: ${e}` });
    } finally {
      setUpdatingId(null);
      setPendingRoleChange(null);
    }
  };

  const handleToggleVerify = async (userId: string, currentStatus: boolean) => {
    setUpdatingId(userId);
    try {
      const newStatus = !currentStatus;
      await adminService.toggleVerification(userId, newStatus);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, is_verified: newStatus } : u))
      );
      if (selectedStudent?.id === userId) {
        setSelectedStudent((prev) => (prev ? { ...prev, is_verified: newStatus } : null));
      }
      setFeedbackMsg({
        type: 'success',
        text: newStatus
          ? 'Akun siswa resmi ditandai terverifikasi'
          : 'Status verifikasi akun siswa dicabut',
      });
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: e?.message || `Gagal mengubah verifikasi: ${e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const totalPages = Math.ceil(totalCount / pageSize) || 1;

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* 1. Header Toolbar & Statistics Pill */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-base font-bold text-slate-900 tracking-tight">
            Direktori Siswa & Otorisasi
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Total {totalCount} akun siswa terdaftar di ekosistem SMKN 8 Semarang
          </p>
        </div>

        <button
          onClick={fetchUsers}
          disabled={isLoading}
          className="flex items-center gap-1.5 h-8.5 px-3 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-700 hover:bg-slate-50 transition-colors shadow-2xs self-start sm:self-auto cursor-pointer"
        >
          <RefreshCw className={`h-3.5 w-3.5 text-[#3D38F5] ${isLoading ? 'animate-spin' : ''}`} />
          <span>Refresh Data</span>
        </button>
      </div>

      {/* 2. Notification Toast Message */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border text-xs flex items-center justify-between transition-all ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-rose-50 text-rose-800 border-rose-200'
          }`}
        >
          <div className="flex items-center gap-2">
            {feedbackMsg.type === 'success' ? (
              <UserCheck className="h-4 w-4 text-emerald-600 shrink-0" />
            ) : (
              <AlertCircle className="h-4 w-4 text-rose-600 shrink-0" />
            )}
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="text-xs font-semibold hover:underline cursor-pointer"
          >
            Tutup
          </button>
        </div>
      )}

      {/* 3. Search & Filter Bar */}
      <Card className="p-4 space-y-3">
        <div className="flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
          {/* Search Box */}
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <input
              type="text"
              placeholder="Cari nama siswa, @username, NIS, atau kelas..."
              value={search}
              onChange={(e) => {
                setPage(1);
                setSearch(e.target.value);
              }}
              className="w-full h-9 pl-9 pr-4 rounded-lg border border-slate-200 bg-slate-50/50 text-xs text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-[#3D38F5] focus:ring-2 focus:ring-[#3D38F5]/10 outline-none transition-all"
            />
          </div>

          {/* Verification Pill Segmented Control */}
          <div className="flex items-center gap-1 p-1 rounded-lg bg-slate-100 border border-slate-200/60 overflow-x-auto">
            {(
              [
                { id: 'all', label: 'Semua Status' },
                { id: 'verified', label: 'Terverifikasi' },
                { id: 'unverified', label: 'Belum Terverifikasi' },
              ] as const
            ).map((f) => (
              <button
                key={f.id}
                onClick={() => {
                  setPage(1);
                  setVerifFilter(f.id);
                }}
                className={`px-2.5 py-1 rounded-md text-xs font-medium transition-all cursor-pointer whitespace-nowrap ${
                  verifFilter === f.id
                    ? 'bg-white text-slate-900 shadow-2xs font-semibold'
                    : 'text-slate-500 hover:text-slate-900'
                }`}
              >
                {f.label}
              </button>
            ))}
          </div>

          {/* Role Dropdown */}
          <div className="flex items-center gap-2">
            <select
              value={roleFilter}
              onChange={(e) => {
                setPage(1);
                setRoleFilter(e.target.value);
              }}
              aria-label="Filter role akun siswa"
              className="h-9 px-3 rounded-lg border border-slate-200 bg-white text-xs font-medium text-slate-700 outline-none cursor-pointer focus:border-[#3D38F5]"
            >
              <option value="all">Semua Role</option>
              <option value="buyer">Buyer (Siswa)</option>
              <option value="seller">Seller (Penjual)</option>
              <option value="admin">Staff Admin</option>
            </select>
          </div>
        </div>
      </Card>

      {/* 4. Tremor Raw Student Data Table */}
      <Card className="p-0 overflow-hidden">
        <Table>
          <TableHead>
            <TableRow>
              <TableHeaderCell className="pl-6">Siswa & Identitas</TableHeaderCell>
              <TableHeaderCell>Kelas & Jurusan</TableHeaderCell>
              <TableHeaderCell>Role Akun</TableHeaderCell>
              <TableHeaderCell>Status Verifikasi</TableHeaderCell>
              <TableHeaderCell>Bergabung</TableHeaderCell>
              <TableHeaderCell className="pr-6 text-right">Aksi Cepat</TableHeaderCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {isLoading ? (
              <TableRow>
                <TableCell colSpan={6} className="py-16 text-center text-slate-400">
                  <div className="flex flex-col items-center justify-center gap-2">
                    <RefreshCw className="h-5 w-5 animate-spin text-[#3D38F5]" />
                    <span>Memuat data siswa dari Supabase...</span>
                  </div>
                </TableCell>
              </TableRow>
            ) : users.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="py-16 text-center text-slate-400">
                  <div className="flex flex-col items-center justify-center gap-1.5">
                    <p className="font-semibold text-slate-700 text-sm">Tidak ada siswa ditemukan</p>
                    <p className="text-xs text-slate-400">Coba ubah kata kunci pencarian atau reset filter.</p>
                  </div>
                </TableCell>
              </TableRow>
            ) : (
              users.map((u) => (
                <TableRow
                  key={u.id}
                  onClick={() => handleRowClick(u)}
                  className="cursor-pointer group"
                >
                  {/* Siswa Hero Column */}
                  <TableCell className="pl-6">
                    <div className="flex items-center gap-3">
                      <div className="h-9 w-9 rounded-lg bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center font-bold text-xs text-[#3D38F5] shrink-0 shadow-2xs overflow-hidden">
                        {u.avatar_url ? (
                          <img
                            src={u.avatar_url}
                            alt={u.full_name || ''}
                            className="h-full w-full object-cover"
                          />
                        ) : u.full_name ? (
                          u.full_name.charAt(0).toUpperCase()
                        ) : (
                          'S'
                        )}
                      </div>
                      <div>
                        <div className="font-semibold text-slate-900 group-hover:text-[#3D38F5] transition-colors flex items-center gap-1.5">
                          <span>{u.full_name || 'Tanpa Nama'}</span>
                          {u.is_verified && (
                            <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 fill-blue-50" />
                          )}
                        </div>
                        <div className="text-[11px] text-slate-400">
                          @{u.username || 'user'}
                        </div>
                      </div>
                    </div>
                  </TableCell>

                  {/* Kelas & Jurusan */}
                  <TableCell>
                    <div className="flex items-center gap-1.5 font-medium text-slate-700">
                      <GraduationCap className="h-3.5 w-3.5 text-slate-400 shrink-0" />
                      <span>{u.class_group || 'Umum'}</span>
                    </div>
                  </TableCell>

                  {/* Role Pill */}
                  <TableCell>
                    <Badge
                      variant={
                        u.role === 'admin'
                          ? 'purple'
                          : u.role === 'seller'
                          ? 'indigo'
                          : 'slate'
                      }
                      className="uppercase font-semibold text-[10px]"
                    >
                      {u.role || 'buyer'}
                    </Badge>
                  </TableCell>

                  {/* Verification Status */}
                  <TableCell>
                    <Badge variant={u.is_verified ? 'emerald' : 'amber'}>
                      <span
                        className={`h-1.5 w-1.5 rounded-full ${
                          u.is_verified ? 'bg-emerald-500' : 'bg-amber-500'
                        }`}
                      />
                      {u.is_verified ? 'Terverifikasi' : 'Pending'}
                    </Badge>
                  </TableCell>

                  {/* Created Date */}
                  <TableCell className="text-[11.5px] text-slate-500 tabular-nums">
                    {new Date(u.created_at).toLocaleDateString('id-ID', {
                      day: 'numeric',
                      month: 'short',
                      year: 'numeric',
                    })}
                  </TableCell>

                  {/* Quick Actions */}
                  <TableCell className="pr-6 text-right" onClick={(e) => e.stopPropagation()}>
                    <div className="flex items-center justify-end gap-1.5">
                      <button
                        onClick={() => handleRowClick(u)}
                        className="h-7.5 px-2.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-slate-600 font-medium flex items-center gap-1 transition-colors cursor-pointer text-xs"
                        title="Inspeksi Detail Siswa"
                      >
                        <Eye className="h-3.5 w-3.5" />
                        <span className="hidden sm:inline">Detail</span>
                      </button>

                      <button
                        disabled={updatingId === u.id}
                        onClick={() => handleToggleVerify(u.id, u.is_verified)}
                        className={`h-7.5 px-2.5 rounded-lg font-medium border flex items-center gap-1 transition-colors cursor-pointer text-xs ${
                          u.is_verified
                            ? 'border-amber-200 bg-amber-50 text-amber-700 hover:bg-amber-100'
                            : 'border-[#D8DBFE] bg-[#EEF0FF] text-[#3D38F5] hover:bg-indigo-100'
                        }`}
                      >
                        {u.is_verified ? 'Cabut' : 'Verifikasi'}
                      </button>
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>

        {/* 5. Pagination Bar */}
        <div className="p-4 border-t border-slate-100 bg-slate-50/50 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
          <div>
            Menampilkan <span className="font-semibold text-slate-900">{users.length}</span> dari{' '}
            <span className="font-semibold text-slate-900">{totalCount}</span> siswa (Halaman {page} dari {totalPages})
          </div>

          <div className="flex items-center gap-1.5">
            <button
              disabled={page <= 1 || isLoading}
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              className="h-8 px-3 rounded-lg border border-slate-200 bg-white font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors cursor-pointer shadow-2xs flex items-center gap-1"
            >
              <ChevronLeft className="h-3.5 w-3.5" />
              <span>Sebelumnya</span>
            </button>
            <button
              disabled={page >= totalPages || isLoading}
              onClick={() => setPage((p) => p + 1)}
              className="h-8 px-3 rounded-lg border border-slate-200 bg-white font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors cursor-pointer shadow-2xs flex items-center gap-1"
            >
              <span>Berikutnya</span>
              <ChevronRight className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>
      </Card>

      {/* 6. Right-Side Slide-Over Inspector Drawer */}
      <UserDetailDrawer
        user={selectedStudent}
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
        onToggleVerify={handleToggleVerify}
        onChangeRole={handleRoleChangePrompt}
        isUpdating={updatingId === selectedStudent?.id}
      />

      {/* 7. Modal Confirmation for Admin Role Change */}
      {pendingRoleChange && (
        <div className="fixed inset-0 z-60 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 space-y-4 shadow-2xl border border-slate-200 animate-in fade-in zoom-in-95">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-purple-50 border border-purple-200 flex items-center justify-center text-purple-600 shrink-0">
                <ShieldAlert className="h-5 w-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-slate-900">Konfirmasi Otorisasi Admin</h3>
                <p className="text-xs text-slate-500">Tindakan ini memberikan hak akses administratif penuh.</p>
              </div>
            </div>

            <p className="text-xs text-slate-600 leading-relaxed">
              Apakah Anda yakin ingin mengubah otorisasi akun{' '}
              <strong className="text-slate-900">@{pendingRoleChange.user.username}</strong> menjadi{' '}
              <span className="font-bold text-purple-700 uppercase">{pendingRoleChange.newRole}</span>?
            </p>

            <div className="flex items-center justify-end gap-2 pt-2">
              <button
                onClick={() => setPendingRoleChange(null)}
                className="px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={() => executeRoleChange(pendingRoleChange.user.id, pendingRoleChange.newRole)}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-purple-600 hover:bg-purple-700 text-white transition-colors cursor-pointer shadow-xs"
              >
                Konfirmasi Ubah
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
