import { useState, useEffect, useCallback } from 'react';
import { Search, CheckCircle2, XCircle, RefreshCw, AlertCircle } from 'lucide-react';
import { Button, Input, Badge, LayerCard } from '@cloudflare/kumo';
import { adminService, type ProfileRow } from '../services/adminService';

export function UsersManagementTab() {
  const [users, setUsers] = useState<ProfileRow[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const fetchUsers = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await adminService.getProfiles({
        search,
        role: roleFilter,
        limit: 50,
      });
      setUsers(res.data);
      setTotalCount(res.count);
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat siswa: ${e}` });
    } finally {
      setIsLoading(false);
    }
  }, [search, roleFilter]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchUsers();
    }, 250);
    return () => clearTimeout(timer);
  }, [fetchUsers]);

  const handleRoleChange = async (userId: string, newRole: 'buyer' | 'seller' | 'admin') => {
    setUpdatingId(userId);
    try {
      await adminService.updateProfileRole(userId, newRole);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, role: newRole } : u))
      );
      setFeedbackMsg({
        type: 'success',
        text: `Role berhasil diperbarui menjadi ${newRole.toUpperCase()}`,
      });
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal mengubah role: ${e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const handleToggleVerification = async (userId: string, currentStatus: boolean) => {
    setUpdatingId(userId);
    try {
      await adminService.toggleVerification(userId, !currentStatus);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, is_verified: !currentStatus } : u))
      );
      setFeedbackMsg({
        type: 'success',
        text: !currentStatus ? 'Badge verifikasi resmi aktif' : 'Badge verifikasi dicabut',
      });
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal toggle verifikasi: ${e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Toast Feedback */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border flex items-center justify-between text-xs font-medium ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-red-50 text-red-800 border-red-200'
          }`}
        >
          <div className="flex items-center gap-2">
            {feedbackMsg.type === 'success' ? (
              <CheckCircle2 className="h-4 w-4 text-emerald-600" />
            ) : (
              <AlertCircle className="h-4 w-4 text-red-600" />
            )}
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="text-xs hover:opacity-75 cursor-pointer"
          >
            Tutup
          </button>
        </div>
      )}

      {/* Control Bar: Search & Role Filter */}
      <LayerCard className="p-4 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="w-full sm:w-96 relative">
          <Input
            placeholder="Cari nama, @username, atau kelas..."
            value={search}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearch(e.target.value)}
            className="w-full text-xs"
          />
          <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-kumo-subtle pointer-events-none" />
        </div>

        <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end">
          <span className="text-xs text-kumo-subtle hidden sm:inline">Role:</span>
          <select
            value={roleFilter}
            onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setRoleFilter(e.target.value)}
            className="h-8 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 text-xs text-kumo-default font-medium focus:outline-none focus:ring-1 focus:ring-indigo-500"
          >
            <option value="all">Semua Role</option>
            <option value="buyer">Buyer (Siswa)</option>
            <option value="seller">Seller (Penjual)</option>
            <option value="admin">Admin (Otoritas)</option>
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
      </LayerCard>

      {/* Users Table */}
      <LayerCard className="border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs overflow-hidden">
        <div className="px-5 py-3.5 border-b border-kumo-hairline flex items-center justify-between bg-kumo-control/40">
          <div className="text-xs font-semibold text-kumo-default">
            Daftar Akun Siswa ({totalCount})
          </div>
          <div className="text-[11px] text-kumo-subtle">
            Menampilkan data langsung dari Supabase Auth & Profiles
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
                <th className="py-3 px-4 text-right">Ubah Otorisasi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-kumo-hairline">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-kumo-subtle">
                    <RefreshCw className="h-5 w-5 animate-spin mx-auto mb-2 text-indigo-600" />
                    <span>Memuat data siswa dari Supabase...</span>
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-kumo-subtle">
                    Tidak ditemukan siswa dengan kriteria pencarian ini.
                  </td>
                </tr>
              ) : (
                users.map((u) => {
                  const isUpdating = updatingId === u.id;
                  return (
                    <tr key={u.id} className="hover:bg-kumo-tint/50 transition-colors">
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2.5">
                          <div className="h-8 w-8 rounded-full bg-indigo-50 border border-indigo-200 flex items-center justify-center font-bold text-xs text-indigo-700 shrink-0">
                            {u.full_name ? u.full_name.charAt(0).toUpperCase() : 'S'}
                          </div>
                          <div>
                            <div className="font-semibold text-kumo-default">
                              {u.full_name || 'Tanpa Nama'}
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
                      <td className="py-3 px-4 text-center">
                        <button
                          onClick={() => handleToggleVerification(u.id, u.is_verified)}
                          disabled={isUpdating}
                          className="inline-flex items-center justify-center cursor-pointer transition-transform active:scale-95 disabled:opacity-50"
                          title={u.is_verified ? 'Klik untuk cabut verifikasi' : 'Klik untuk verifikasi'}
                        >
                          {u.is_verified ? (
                            <CheckCircle2 className="h-5 w-5 text-blue-600" />
                          ) : (
                            <XCircle className="h-5 w-5 text-kumo-subtle hover:text-slate-500" />
                          )}
                        </button>
                      </td>
                      <td className="py-3 px-4 text-right">
                        <select
                          value={u.role || 'buyer'}
                          disabled={isUpdating}
                          onChange={(e) =>
                            handleRoleChange(
                              u.id,
                              e.target.value as 'buyer' | 'seller' | 'admin'
                            )
                          }
                          className="h-7 rounded border border-kumo-hairline bg-kumo-control px-2 text-[11px] font-semibold text-kumo-default focus:ring-1 focus:ring-indigo-500 cursor-pointer disabled:opacity-50"
                        >
                          <option value="buyer">Set as Siswa (Buyer)</option>
                          <option value="seller">Set as Penjual (Seller)</option>
                          <option value="admin">Set as Admin (Otoritas)</option>
                        </select>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </LayerCard>
    </div>
  );
}
