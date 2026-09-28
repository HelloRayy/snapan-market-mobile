import React, { useState, useEffect, useCallback } from 'react';
import {
  Search,
  CheckCircle2,
  XCircle,
  RefreshCw,
  AlertCircle,
  X,
  ChevronLeft,
  ChevronRight,
  Eye,
  Copy,
  ShieldCheck,
  ShieldAlert,
  UserCheck,
  Calendar,
} from 'lucide-react';
import { Button, Input, Badge, LayerCard } from '@cloudflare/kumo';
import { adminService, type ProfileRow } from '../services/adminService';

export function UsersManagementTab() {
  const [users, setUsers] = useState<ProfileRow[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [verifFilter, setVerifFilter] = useState<'all' | 'verified' | 'unverified'>('all');
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Selected Student for Quick Detail Modal
  const [selectedStudent, setSelectedStudent] = useState<ProfileRow | null>(null);
  const [copiedId, setCopiedId] = useState(false);

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

  // Reset page when filters change
  const handleFilterChange = (setter: () => void) => {
    setPage(1);
    setter();
  };

  const handleRoleChangePrompt = (user: ProfileRow, newRole: 'buyer' | 'seller' | 'admin') => {
    if (newRole === 'admin' || user.role === 'admin') {
      // Require explicit modal confirmation for admin role elevation or demotion
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
        setSelectedStudent((prev) => prev ? { ...prev, role: newRole } : null);
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

  const handleToggleVerification = async (userId: string, currentStatus: boolean) => {
    setUpdatingId(userId);
    try {
      await adminService.toggleVerification(userId, !currentStatus);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, is_verified: !currentStatus } : u))
      );
      if (selectedStudent?.id === userId) {
        setSelectedStudent((prev) => prev ? { ...prev, is_verified: !currentStatus } : null);
      }
      setFeedbackMsg({
        type: 'success',
        text: !currentStatus ? 'Badge verifikasi resmi aktif di database & mobile app' : 'Badge verifikasi dicabut',
      });
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: e?.message || `Gagal toggle verifikasi: ${e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const handleCopyId = (id: string) => {
    navigator.clipboard.writeText(id);
    setCopiedId(true);
    setTimeout(() => setCopiedId(false), 2000);
  };

  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const startItem = totalCount === 0 ? 0 : (page - 1) * pageSize + 1;
  const endItem = Math.min(totalCount, page * pageSize);

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Toast Feedback */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border flex items-center justify-between text-xs font-medium transition-all ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-red-50 text-red-800 border-red-200'
          }`}
        >
          <div className="flex items-center gap-2">
            {feedbackMsg.type === 'success' ? (
              <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
            ) : (
              <AlertCircle className="h-4 w-4 text-red-600 shrink-0" />
            )}
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="text-xs hover:opacity-75 cursor-pointer ml-3 font-semibold"
          >
            Tutup
          </button>
        </div>
      )}

      {/* Control Bar: Search & Filter Chips */}
      <LayerCard className="p-4 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs space-y-3.5">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
          {/* Search Input with Instant Clear */}
          <div className="w-full sm:w-96 relative">
            <Input
              placeholder="Cari nama, @username, atau kelas..."
              value={search}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                handleFilterChange(() => setSearch(e.target.value))
              }
              className="w-full text-xs pr-8"
            />
            {search ? (
              <button
                onClick={() => handleFilterChange(() => setSearch(''))}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 p-0.5 rounded-full hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default cursor-pointer"
                title="Hapus pencarian"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            ) : (
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-kumo-subtle pointer-events-none" />
            )}
          </div>

          <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end flex-wrap">
            {/* Page Size Selector */}
            <span className="text-xs text-kumo-subtle">Tampilkan:</span>
            <select
              value={pageSize}
              onChange={(e) => {
                setPageSize(Number(e.target.value));
                setPage(1);
              }}
              className="h-8 rounded-lg border border-kumo-hairline bg-kumo-control px-2 text-xs text-kumo-default font-medium focus:ring-1 focus:ring-indigo-500"
            >
              <option value={10}>10 siswa</option>
              <option value={25}>25 siswa</option>
              <option value={50}>50 siswa</option>
            </select>

            <Button
              variant="secondary"
              className="h-8 px-2.5 text-xs flex items-center gap-1.5"
              onClick={fetchUsers}
              disabled={isLoading}
            >
              <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin' : ''}`} />
              <span className="hidden sm:inline">Refresh</span>
            </Button>
          </div>
        </div>

        {/* Filter Chips Bar */}
        <div className="flex items-center gap-2 overflow-x-auto pt-1 pb-0.5 text-xs border-t border-kumo-hairline/60">
          <span className="text-kumo-subtle text-[11px] font-semibold shrink-0">Filter Status:</span>
          
          <button
            onClick={() => handleFilterChange(() => setVerifFilter('all'))}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 ${
              verifFilter === 'all'
                ? 'bg-indigo-600 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            Semua Verifikasi
          </button>
          <button
            onClick={() => handleFilterChange(() => setVerifFilter('verified'))}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 flex items-center gap-1 ${
              verifFilter === 'verified'
                ? 'bg-blue-600 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            <CheckCircle2 className="h-3 w-3" />
            <span>Terverifikasi</span>
          </button>
          <button
            onClick={() => handleFilterChange(() => setVerifFilter('unverified'))}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 ${
              verifFilter === 'unverified'
                ? 'bg-slate-700 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            Belum Verifikasi
          </button>

          <span className="text-kumo-hairline px-1">|</span>

          <span className="text-kumo-subtle text-[11px] font-semibold shrink-0">Role:</span>
          {(['all', 'buyer', 'seller', 'admin'] as const).map((r) => (
            <button
              key={r}
              onClick={() => handleFilterChange(() => setRoleFilter(r))}
              className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 uppercase ${
                roleFilter === r
                  ? 'bg-purple-600 text-white shadow-xs'
                  : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
              }`}
            >
              {r === 'all' ? 'Semua Role' : r}
            </button>
          ))}
        </div>
      </LayerCard>

      {/* Users Table */}
      <LayerCard className="border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs overflow-hidden">
        <div className="px-5 py-3.5 border-b border-kumo-hairline flex items-center justify-between bg-kumo-control/40 flex-wrap gap-2">
          <div className="text-xs font-semibold text-kumo-default flex items-center gap-2">
            <span>Daftar Akun Siswa</span>
            <Badge variant="secondary" className="text-[10px] px-2 py-0.5 font-bold">
              {totalCount} Total
            </Badge>
          </div>
          <div className="text-[11px] text-kumo-subtle">
            Menampilkan {startItem}-{endItem} dari {totalCount} akun
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-kumo-hairline bg-kumo-canvas text-kumo-subtle font-semibold">
                <th className="py-3 px-4">Siswa</th>
                <th className="py-3 px-4">Username</th>
                <th className="py-3 px-4">Kelas & Jurusan</th>
                <th className="py-3 px-4">Role RBAC</th>
                <th className="py-3 px-4 text-center">Verifikasi</th>
                <th className="py-3 px-4 text-right">Opsi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-kumo-hairline">
              {isLoading ? (
                // Shimmer Skeletons
                Array.from({ length: pageSize > 10 ? 10 : pageSize }).map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    <td className="py-3.5 px-4">
                      <div className="flex items-center gap-2.5">
                        <div className="h-8 w-8 rounded-full bg-kumo-control" />
                        <div className="space-y-1.5">
                          <div className="h-3 w-28 rounded bg-kumo-control" />
                          <div className="h-2 w-16 rounded bg-kumo-control" />
                        </div>
                      </div>
                    </td>
                    <td className="py-3.5 px-4"><div className="h-3 w-20 rounded bg-kumo-control" /></td>
                    <td className="py-3.5 px-4"><div className="h-3 w-24 rounded bg-kumo-control" /></td>
                    <td className="py-3.5 px-4"><div className="h-5 w-16 rounded bg-kumo-control" /></td>
                    <td className="py-3.5 px-4 text-center"><div className="h-5 w-5 rounded-full bg-kumo-control mx-auto" /></td>
                    <td className="py-3.5 px-4 text-right"><div className="h-7 w-32 rounded bg-kumo-control ml-auto" /></td>
                  </tr>
                ))
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-14 text-center text-kumo-subtle space-y-2">
                    <UserCheck className="h-8 w-8 mx-auto text-kumo-subtle opacity-40" />
                    <p className="font-medium">Tidak ada siswa yang sesuai dengan filter atau kata kunci.</p>
                    <Button
                      variant="secondary"
                      className="text-xs h-7 px-2.5 mx-auto"
                      onClick={() => {
                        setSearch('');
                        setRoleFilter('all');
                        setVerifFilter('all');
                      }}
                    >
                      Reset Filter
                    </Button>
                  </td>
                </tr>
              ) : (
                users.map((u) => {
                  const isUpdating = updatingId === u.id;
                  return (
                    <tr
                      key={u.id}
                      className="hover:bg-kumo-tint/50 transition-colors group cursor-pointer"
                      onClick={() => setSelectedStudent(u)}
                    >
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2.5">
                          <div className="h-8 w-8 rounded-full bg-indigo-50 border border-indigo-200 flex items-center justify-center font-bold text-xs text-indigo-700 shrink-0">
                            {u.avatar_url ? (
                              <img
                                src={u.avatar_url}
                                alt={u.full_name || 'Avatar'}
                                className="h-full w-full rounded-full object-cover"
                              />
                            ) : u.full_name ? (
                              u.full_name.charAt(0).toUpperCase()
                            ) : (
                              'S'
                            )}
                          </div>
                          <div>
                            <div className="font-semibold text-kumo-default flex items-center gap-1.5">
                              {u.full_name || 'Tanpa Nama'}
                              {u.is_verified && (
                                <CheckCircle2 className="h-3.5 w-3.5 text-blue-600" />
                              )}
                            </div>
                            <div className="text-[10px] text-kumo-subtle font-mono">
                              ID: {u.id.substring(0, 8)}...
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4 font-mono text-kumo-default">
                        @{u.username || '-'}
                      </td>
                      <td className="py-3 px-4 text-kumo-default">
                        {u.class_group || 'SMKN 8'}
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={u.role === 'admin' ? 'primary' : 'secondary'}
                          className={`text-[10px] uppercase font-bold py-0.5 px-2 ${
                            u.role === 'admin'
                              ? 'bg-purple-100 text-purple-700 border-purple-200'
                              : u.role === 'seller'
                              ? 'bg-amber-100 text-amber-800 border-amber-200'
                              : 'bg-slate-100 text-slate-700 border-slate-200'
                          }`}
                        >
                          {u.role || 'buyer'}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 text-center" onClick={(e) => e.stopPropagation()}>
                        <button
                          onClick={() => handleToggleVerification(u.id, u.is_verified)}
                          disabled={isUpdating}
                          className="inline-flex items-center justify-center cursor-pointer transition-transform active:scale-95 disabled:opacity-50 p-1 rounded-md hover:bg-kumo-control"
                          title={u.is_verified ? 'Klik untuk cabut verifikasi' : 'Klik untuk verifikasi'}
                        >
                          {u.is_verified ? (
                            <CheckCircle2 className="h-5 w-5 text-blue-600" />
                          ) : (
                            <XCircle className="h-5 w-5 text-kumo-subtle hover:text-slate-500" />
                          )}
                        </button>
                      </td>
                      <td className="py-3 px-4 text-right" onClick={(e) => e.stopPropagation()}>
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => setSelectedStudent(u)}
                            className="p-1 rounded hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default"
                            title="Detail Siswa"
                          >
                            <Eye className="h-3.5 w-3.5" />
                          </button>
                          <select
                            value={u.role || 'buyer'}
                            disabled={isUpdating}
                            onChange={(e) =>
                              handleRoleChangePrompt(
                                u,
                                e.target.value as 'buyer' | 'seller' | 'admin'
                              )
                            }
                            className="h-7 rounded border border-kumo-hairline bg-kumo-control px-2 text-[11px] font-semibold text-kumo-default focus:ring-1 focus:ring-indigo-500 cursor-pointer disabled:opacity-50"
                          >
                            <option value="buyer">Buyer (Siswa)</option>
                            <option value="seller">Seller (Penjual)</option>
                            <option value="admin">Admin (Otoritas)</option>
                          </select>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Bar */}
        <div className="px-5 py-3 border-t border-kumo-hairline flex items-center justify-between text-xs text-kumo-subtle bg-kumo-canvas">
          <div>
            Halaman <span className="font-semibold text-kumo-default">{page}</span> dari{' '}
            <span className="font-semibold text-kumo-default">{totalPages}</span>
          </div>

          <div className="flex items-center gap-1.5">
            <Button
              variant="secondary"
              className="h-7 px-2 text-xs flex items-center gap-1"
              disabled={page <= 1 || isLoading}
              onClick={() => setPage((p) => Math.max(1, p - 1))}
            >
              <ChevronLeft className="h-3.5 w-3.5" />
              <span>Sebelumnya</span>
            </Button>

            <Button
              variant="secondary"
              className="h-7 px-2 text-xs flex items-center gap-1"
              disabled={page >= totalPages || isLoading}
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            >
              <span>Selanjutnya</span>
              <ChevronRight className="h-3.5 w-3.5" />
            </Button>
          </div>
        </div>
      </LayerCard>

      {/* QUICK STUDENT DETAIL MODAL */}
      {selectedStudent && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/45 backdrop-blur-xs">
          <div className="w-full max-w-md bg-kumo-canvas border border-kumo-hairline rounded-2xl shadow-xl overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            {/* Modal Header */}
            <div className="flex items-center justify-between px-5 py-4 border-b border-kumo-hairline bg-kumo-control/30">
              <div className="flex items-center gap-2">
                <ShieldCheck className="h-4 w-4 text-indigo-600" />
                <h3 className="text-sm font-semibold text-kumo-default">Profil Siswa Snapan</h3>
              </div>
              <button
                onClick={() => setSelectedStudent(null)}
                className="p-1 rounded-lg hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6 space-y-5 text-xs">
              <div className="flex items-center gap-4">
                <div className="h-16 w-16 rounded-full bg-indigo-50 border-2 border-indigo-200 flex items-center justify-center font-bold text-xl text-indigo-700 shrink-0 overflow-hidden shadow-xs">
                  {selectedStudent.avatar_url ? (
                    <img
                      src={selectedStudent.avatar_url}
                      alt={selectedStudent.full_name || ''}
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    selectedStudent.full_name?.charAt(0).toUpperCase() || 'S'
                  )}
                </div>
                <div className="min-w-0">
                  <div className="text-base font-bold text-kumo-default flex items-center gap-1.5">
                    <span className="truncate">{selectedStudent.full_name || 'Tanpa Nama'}</span>
                    {selectedStudent.is_verified && (
                      <CheckCircle2 className="h-4 w-4 text-blue-600 shrink-0" />
                    )}
                  </div>
                  <div className="text-kumo-subtle font-mono text-xs">
                    @{selectedStudent.username || '-'}
                  </div>
                  <div className="mt-1 flex items-center gap-1.5">
                    <Badge
                      variant={selectedStudent.role === 'admin' ? 'primary' : 'secondary'}
                      className="text-[10px] font-bold uppercase py-0.2 px-1.5"
                    >
                      {selectedStudent.role}
                    </Badge>
                    <span className="text-[11px] text-kumo-subtle">
                      • {selectedStudent.class_group || 'Siswa SMKN 8'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Info Grid */}
              <div className="rounded-xl border border-kumo-hairline bg-kumo-control/40 p-3.5 space-y-2.5">
                <div className="flex items-center justify-between">
                  <span className="text-kumo-subtle">UUID Pengguna:</span>
                  <div className="flex items-center gap-1 font-mono text-[11px] text-kumo-default">
                    <span>{selectedStudent.id.substring(0, 14)}...</span>
                    <button
                      onClick={() => handleCopyId(selectedStudent.id)}
                      className="p-1 hover:bg-kumo-hairline rounded cursor-pointer"
                      title="Salin UUID"
                    >
                      <Copy className="h-3 w-3 text-kumo-subtle hover:text-kumo-default" />
                    </button>
                    {copiedId && <span className="text-[10px] text-emerald-600 font-sans">Tersalin!</span>}
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-kumo-subtle">Terdaftar Sejak:</span>
                  <div className="flex items-center gap-1 text-kumo-default">
                    <Calendar className="h-3 w-3 text-kumo-subtle" />
                    <span>
                      {selectedStudent.created_at
                        ? new Date(selectedStudent.created_at).toLocaleDateString('id-ID', {
                            day: 'numeric',
                            month: 'short',
                            year: 'numeric',
                          })
                        : '-'}
                    </span>
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <span className="text-kumo-subtle">Status Verifikasi:</span>
                  <span
                    className={`font-semibold ${
                      selectedStudent.is_verified ? 'text-blue-600' : 'text-slate-500'
                    }`}
                  >
                    {selectedStudent.is_verified ? 'Terverifikasi Resmi (Badge Aktif)' : 'Belum Terverifikasi'}
                  </span>
                </div>
              </div>

              {/* Quick Actions */}
              <div className="space-y-2 pt-1">
                <div className="text-[11px] font-semibold text-kumo-subtle uppercase tracking-wider">
                  Aksi Cepat Admin
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="primary"
                    className={`flex-1 text-xs h-8.5 font-semibold ${
                      selectedStudent.is_verified ? 'bg-slate-700 hover:bg-slate-800' : 'bg-blue-600 hover:bg-blue-700'
                    }`}
                    onClick={() =>
                      handleToggleVerification(selectedStudent.id, selectedStudent.is_verified)
                    }
                  >
                    {selectedStudent.is_verified ? 'Cabut Verifikasi' : 'Verifikasi Siswa Ini'}
                  </Button>

                  <Button
                    variant="secondary"
                    className="text-xs h-8.5 px-3"
                    onClick={() => {
                      const nextRole =
                        selectedStudent.role === 'buyer'
                          ? 'seller'
                          : selectedStudent.role === 'seller'
                          ? 'admin'
                          : 'buyer';
                      handleRoleChangePrompt(selectedStudent, nextRole);
                    }}
                  >
                    Jadikan {selectedStudent.role === 'buyer' ? 'Seller' : selectedStudent.role === 'seller' ? 'Admin' : 'Buyer'}
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* CONFIRMATION MODAL FOR CRITICAL ROLE ELEVATION */}
      {pendingRoleChange && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="w-full max-w-sm bg-kumo-canvas border border-kumo-hairline rounded-2xl shadow-2xl p-5 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-full bg-purple-100 flex items-center justify-center text-purple-700 shrink-0">
                <ShieldAlert className="h-5 w-5" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-kumo-default">Konfirmasi Otorisasi</h4>
                <p className="text-xs text-kumo-subtle">Tindakan ini memerlukan izin khusus</p>
              </div>
            </div>

            <p className="text-xs text-kumo-default leading-relaxed">
              Anda akan mengubah otorisasi akun <strong>{pendingRoleChange.user.full_name}</strong> (@{pendingRoleChange.user.username}) menjadi{' '}
              <span className="font-bold uppercase text-purple-700">{pendingRoleChange.newRole}</span>.
              {pendingRoleChange.newRole === 'admin' && (
                <span className="block mt-1 text-red-600 font-semibold">
                  Peringatan: Akun ini akan memiliki akses penuh ke portal admin dan penghapusan data.
                </span>
              )}
            </p>

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-kumo-hairline">
              <Button
                variant="secondary"
                className="text-xs h-8 px-3"
                onClick={() => setPendingRoleChange(null)}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                className="text-xs h-8 px-3 bg-purple-600 hover:bg-purple-700 text-white font-semibold"
                onClick={() =>
                  executeRoleChange(pendingRoleChange.user.id, pendingRoleChange.newRole)
                }
              >
                Ya, Ubah Otorisasi
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
