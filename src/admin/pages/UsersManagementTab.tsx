import { useState, useEffect, useCallback } from 'react';
import { adminService, type ProfileRow } from '../services/adminService';
import { UserDetailModal } from '../components/UserDetailModal';
import { UserAvatar } from '../components/UserAvatar';

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

  // Inspector Modal
  const [selectedStudent, setSelectedStudent] = useState<ProfileRow | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

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
    setIsModalOpen(true);
  };

  const handleToggleVerify = async (userId: string, currentStatus: boolean) => {
    setUpdatingId(userId);
    try {
      await adminService.toggleVerification(userId, !currentStatus);
      setUsers((prev) =>
        prev.map((u) => (u.id === userId ? { ...u, is_verified: !currentStatus } : u))
      );
      if (selectedStudent?.id === userId) {
        setSelectedStudent((prev) => (prev ? { ...prev, is_verified: !currentStatus } : null));
      }
      setFeedbackMsg({
        type: 'success',
        text: !currentStatus ? 'Siswa berhasil diverifikasi.' : 'Status verifikasi dicabut.',
      });
      setTimeout(() => setFeedbackMsg(null), 3000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal update: ${e?.message || e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const handleRoleChange = async (user: ProfileRow, newRole: 'buyer' | 'seller' | 'admin') => {
    setUpdatingId(user.id);
    try {
      await adminService.updateProfileRole(user.id, newRole);
      setUsers((prev) =>
        prev.map((u) => (u.id === user.id ? { ...u, role: newRole } : u))
      );
      if (selectedStudent?.id === user.id) {
        setSelectedStudent((prev) => (prev ? { ...prev, role: newRole } : null));
      }
      setFeedbackMsg({ type: 'success', text: `Role diubah menjadi ${newRole}.` });
      setTimeout(() => setFeedbackMsg(null), 3000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal ubah role: ${e?.message || e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const totalPages = Math.ceil(totalCount / pageSize) || 1;

  return (
    <>
      {/* 1. Page Header (CoolAdmin Source of Truth) */}
      <div className="page-header">
        <div>
          <h1>Direktori Siswa & Otorisasi</h1>
          <p className="subtitle">
            Kelola data siswa SMKN 8 Semarang, status verifikasi NIS, dan otorisasi hak akses.
          </p>
        </div>
        <div className="page-header__actions">
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={fetchUsers}
            disabled={isLoading}
            aria-label="Refresh data siswa"
          >
            <i className={`fa-solid fa-arrows-rotate ${isLoading ? 'fa-spin' : ''}`}></i>
            Segarkan
          </button>
        </div>
      </div>

      {/* Feedback banner if any */}
      {feedbackMsg && (
        <div
          style={{
            marginBottom: '16px',
            padding: '12px 16px',
            borderRadius: '6px',
            background: feedbackMsg.type === 'success' ? '#e0f3f1' : '#fce7f3',
            color: feedbackMsg.type === 'success' ? '#11998e' : '#ec4899',
            fontSize: '13px',
            fontWeight: 500,
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <i
            className={`fa-solid ${
              feedbackMsg.type === 'success' ? 'fa-circle-check' : 'fa-triangle-exclamation'
            }`}
          ></i>
          <span>{feedbackMsg.text}</span>
        </div>
      )}

      {/* 2. Main Data Card with Filter and Table */}
      <section className="m-card">
        {/* Filter Bar Header */}
        <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            {/* Search Input */}
            <div style={{ position: 'relative', width: '260px' }}>
              <input
                type="text"
                className="au-input"
                placeholder="Cari nama, NIS, username..."
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value);
                  setPage(1);
                }}
                style={{
                  width: '100%',
                  height: '36px',
                  borderRadius: '6px',
                  border: '1px solid #e4e7ec',
                  padding: '0 12px 0 34px',
                  fontSize: '13px',
                }}
              />
              <i
                className="fa-solid fa-magnifying-glass"
                style={{
                  position: 'absolute',
                  left: '12px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  color: '#94a3b8',
                  fontSize: '12px',
                }}
              ></i>
            </div>

            {/* Filter Role */}
            <select
              value={roleFilter}
              onChange={(e) => {
                setRoleFilter(e.target.value);
                setPage(1);
              }}
              style={{
                height: '36px',
                borderRadius: '6px',
                border: '1px solid #e4e7ec',
                padding: '0 10px',
                fontSize: '13px',
                color: '#475569',
                background: '#ffffff',
              }}
            >
              <option value="all">Semua Role</option>
              <option value="admin">Administrator</option>
              <option value="seller">Penjual / Siswa Kreator</option>
              <option value="buyer">Pembeli / Siswa</option>
            </select>

            {/* Filter Verifikasi */}
            <select
              value={verifFilter}
              onChange={(e) => {
                setVerifFilter(e.target.value as any);
                setPage(1);
              }}
              style={{
                height: '36px',
                borderRadius: '6px',
                border: '1px solid #e4e7ec',
                padding: '0 10px',
                fontSize: '13px',
                color: '#475569',
                background: '#ffffff',
              }}
            >
              <option value="all">Semua Status</option>
              <option value="verified">Terverifikasi</option>
              <option value="unverified">Belum Verifikasi</option>
            </select>
          </div>

          <div style={{ fontSize: '12.5px', color: '#64748b' }}>
            Total: <b>{totalCount}</b> siswa terdaftar
          </div>
        </header>

        {/* Data Table (CoolAdmin m-table) */}
        <div className="table-responsive">
          <table className="m-table">
            <thead>
              <tr>
                <th>Siswa</th>
                <th>NIS & Jurusan</th>
                <th>Role</th>
                <th>Status Verifikasi</th>
                <th className="num">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                    <i className="fa-solid fa-arrows-rotate fa-spin" style={{ marginRight: '8px' }}></i>
                    Memuat data siswa...
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                    Tidak ada siswa yang sesuai dengan filter.
                  </td>
                </tr>
              ) : (
                users.map((u) => (
                  <tr key={u.id}>
                    <td>
                      <div className="row-product" style={{ cursor: 'pointer' }} onClick={() => handleRowClick(u)}>
                        <UserAvatar
                          avatarUrl={u.avatar_url}
                          name={u.full_name}
                          size={36}
                          role={u.role}
                          style={{ marginRight: '10px' }}
                        />
                        <div>
                          <div style={{ fontWeight: 600, color: '#1f2937' }}>
                            {u.full_name || 'Siswa SMKN 8'}
                          </div>
                          <div style={{ fontSize: '11px', color: '#64748b' }}>
                            @{u.username || 'user'}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td style={{ color: '#475569', fontSize: '13px' }}>
                      <div style={{ fontWeight: 500 }}>{u.class_group || 'Kelas Siswa'}</div>
                      <div style={{ fontSize: '11.5px', color: '#94a3b8' }}>
                        {u.is_verified ? 'Siswa Terverifikasi' : 'Belum Diverifikasi'}
                      </div>
                    </td>
                    <td>
                      <span
                        className={`role ${u.role === 'admin' ? 'admin' : 'user'}`}
                        style={{
                          display: 'inline-block',
                          padding: '3px 10px',
                          borderRadius: '4px',
                          fontSize: '11px',
                          fontWeight: 600,
                          textTransform: 'uppercase',
                        }}
                      >
                        {u.role || 'siswa'}
                      </span>
                    </td>
                    <td>
                      {u.is_verified ? (
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '5px',
                            color: '#10b981',
                            fontSize: '12.5px',
                            fontWeight: 600,
                          }}
                        >
                          <i className="fa-solid fa-circle-check"></i>
                          Terverifikasi
                        </span>
                      ) : (
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '5px',
                            color: '#94a3b8',
                            fontSize: '12.5px',
                            fontWeight: 500,
                          }}
                        >
                          <i className="fa-regular fa-circle"></i>
                          Belum Verif
                        </span>
                      )}
                    </td>
                    <td className="num">
                      <div className="table-data-feature">
                        {/* Detail Inspector Button */}
                        <button
                          type="button"
                          className="item"
                          title="Lihat Detail Siswa"
                          onClick={() => handleRowClick(u)}
                          style={{ border: 0, cursor: 'pointer' }}
                        >
                          <i className="fa-solid fa-eye"></i>
                        </button>

                        {/* Verify / Unverify Toggle Button */}
                        <button
                          type="button"
                          className="item"
                          title={u.is_verified ? 'Cabut Verifikasi' : 'Verifikasi Siswa'}
                          disabled={updatingId === u.id}
                          onClick={() => handleToggleVerify(u.id, !!u.is_verified)}
                          style={{
                            border: 0,
                            cursor: 'pointer',
                            color: u.is_verified ? '#10b981' : '#94a3b8',
                          }}
                        >
                          <i className={`fa-solid ${u.is_verified ? 'fa-check' : 'fa-user-check'}`}></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Footer */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            paddingTop: '16px',
            marginTop: '8px',
            borderTop: '1px solid #f1f3f5',
          }}
        >
          <div style={{ fontSize: '12.5px', color: '#94a3b8' }}>
            Halaman {page} dari {totalPages}
          </div>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              type="button"
              className="m-btn m-btn--ghost"
              disabled={page <= 1}
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              style={{ height: '32px', padding: '0 12px', fontSize: '12px' }}
            >
              <i className="fa-solid fa-chevron-left"></i>
              Sebelumnya
            </button>
            <button
              type="button"
              className="m-btn m-btn--ghost"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              style={{ height: '32px', padding: '0 12px', fontSize: '12px' }}
            >
              Selanjutnya
              <i className="fa-solid fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </section>

      {/* User Detail Modal */}
      <UserDetailModal
        user={selectedStudent}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onToggleVerify={handleToggleVerify}
        onChangeRole={handleRoleChange}
        isUpdating={updatingId === selectedStudent?.id}
      />
    </>
  );
}
