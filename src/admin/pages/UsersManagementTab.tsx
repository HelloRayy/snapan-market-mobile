import { useState, useEffect, useCallback } from 'react';
import { BadgeCheck } from 'lucide-react';
import { supabase } from '../../services/api/supabase';
import { adminService, type ProfileRow } from '../services/adminService';
import { UserDetailModal } from '../components/UserDetailModal';
import { UserAvatar } from '../components/UserAvatar';
import { AdminModalPortal } from '../components/AdminModalPortal';
import { AdminTooltip } from '../components/AdminTooltip';

// Daftar pilihan standar SMKN 8 Semarang
const SMKN8_GRADES = ['X', 'XI', 'XII'] as const;
const SMKN8_MAJORS = ['PPLG', 'TJKT', 'DKV', 'PS', 'LK'] as const;
const SMKN8_CLASS_NUMS = ['1', '2', '3'] as const;

interface UsersManagementTabProps {
  isActive?: boolean;
}

export function UsersManagementTab({ isActive = true }: UsersManagementTabProps) {
  const [users, setUsers] = useState<ProfileRow[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('all');
  const [verifFilter, setVerifFilter] = useState<'all' | 'verified' | 'unverified'>('all');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'suspended'>('all');
  const [page, setPage] = useState(1);
  const pageSize = 10;
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Inspector Modal
  const [selectedStudent, setSelectedStudent] = useState<ProfileRow | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Modal Konfirmasi Verifikasi Siswa (Anti-Miss Click)
  const [pendingVerifyTarget, setPendingVerifyTarget] = useState<{
    user: ProfileRow;
    newStatus: boolean;
  } | null>(null);

  // Modal Suspend Akun (Anti-Miss Click & Form Durasi/Alasan)
  const [pendingSuspendTarget, setPendingSuspendTarget] = useState<ProfileRow | null>(null);
  const [suspendReason, setSuspendReason] = useState('');
  const [suspendDurationHours, setSuspendDurationHours] = useState<number | null>(72); // Default 3 hari (72 jam)

  // Modal Unsuspend / Pulihkan Akun
  const [pendingUnsuspendTarget, setPendingUnsuspendTarget] = useState<ProfileRow | null>(null);

  // Modal Hapus Akun Permanen (Anti-Miss Click)
  const [pendingDeleteTarget, setPendingDeleteTarget] = useState<ProfileRow | null>(null);

  // Modal Tambah Siswa Baru (Pre-Register NIS ke Buku Induk)
  const [isAddStudentOpen, setIsAddStudentOpen] = useState(false);
  const [newStudentNis, setNewStudentNis] = useState('');
  const [newStudentName, setNewStudentName] = useState('');
  const [newStudentGrade, setNewStudentGrade] = useState<'X' | 'XI' | 'XII'>('XI');
  const [newStudentMajor, setNewStudentMajor] = useState<string>('PPLG');
  const [newStudentClassNum, setNewStudentClassNum] = useState<string>('2');
  const [isCustomClass, setIsCustomClass] = useState(false);
  const [customClassText, setCustomClassText] = useState('');
  const [isSubmittingStudent, setIsSubmittingStudent] = useState(false);

  // Modal Impor Massal
  const [isBulkImportOpen, setIsBulkImportOpen] = useState(false);
  const [bulkText, setBulkText] = useState('');
  const [isSubmittingBulk, setIsSubmittingBulk] = useState(false);

  const fetchUsers = useCallback(async () => {
    setIsLoading(true);
    try {
      const offset = (page - 1) * pageSize;
      const res = await adminService.getProfiles({
        search,
        role: roleFilter,
        verification: verifFilter,
        status: statusFilter,
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
  }, [search, roleFilter, verifFilter, statusFilter, page, pageSize]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchUsers();
    }, 250);
    return () => clearTimeout(timer);
  }, [fetchUsers]);

  // Re-fetch saat tab pengguna dibuka
  useEffect(() => {
    if (isActive) {
      fetchUsers();
    }
  }, [isActive, fetchUsers]);

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

  const handleConfirmSuspend = async () => {
    if (!pendingSuspendTarget) return;
    const trimmed = suspendReason.trim();
    if (!trimmed) {
      setFeedbackMsg({ type: 'error', text: 'Alasan penangguhan akun wajib diisi.' });
      return;
    }
    const target = pendingSuspendTarget;
    setUpdatingId(target.id);
    try {
      await adminService.suspendUser(target.id, trimmed, suspendDurationHours);
      const untilDate =
        suspendDurationHours && suspendDurationHours > 0
          ? new Date(Date.now() + suspendDurationHours * 3600 * 1000).toISOString()
          : null;

      const updated = {
        is_suspended: true,
        suspended_at: new Date().toISOString(),
        suspended_until: untilDate,
        suspend_reason: trimmed,
      };

      setUsers((prev) =>
        prev.map((u) => (u.id === target.id ? { ...u, ...updated } : u))
      );

      if (selectedStudent?.id === target.id) {
        setSelectedStudent((prev) => (prev ? { ...prev, ...updated } : null));
      }

      setPendingSuspendTarget(null);
      setSuspendReason('');
      setFeedbackMsg({
        type: 'success',
        text: `Akun "${target.full_name || target.username}" berhasil ditangguhkan.`,
      });
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal menangguhkan akun: ${e?.message || e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const handleConfirmUnsuspend = async () => {
    if (!pendingUnsuspendTarget) return;
    const target = pendingUnsuspendTarget;
    setUpdatingId(target.id);
    try {
      await adminService.unsuspendUser(target.id);
      const updated = {
        is_suspended: false,
        suspended_at: null,
        suspended_until: null,
        suspend_reason: null,
      };

      setUsers((prev) =>
        prev.map((u) => (u.id === target.id ? { ...u, ...updated } : u))
      );

      if (selectedStudent?.id === target.id) {
        setSelectedStudent((prev) => (prev ? { ...prev, ...updated } : null));
      }

      setPendingUnsuspendTarget(null);
      setFeedbackMsg({
        type: 'success',
        text: `Akun "${target.full_name || target.username}" telah dipulihkan dan aktif kembali.`,
      });
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal memulihkan akun: ${e?.message || e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const handleConfirmDelete = async () => {
    if (!pendingDeleteTarget) return;
    const target = pendingDeleteTarget;
    setUpdatingId(target.id);
    try {
      await adminService.deleteUser(target.id);
      setUsers((prev) => prev.filter((u) => u.id !== target.id));
      setTotalCount((prev) => Math.max(0, prev - 1));
      if (selectedStudent?.id === target.id) {
        setSelectedStudent(null);
        setIsModalOpen(false);
      }
      setPendingDeleteTarget(null);
      setFeedbackMsg({
        type: 'success',
        text: `Akun "${target.full_name || target.username}" dan seluruh postingannya berhasil dihapus permanen.`,
      });
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal menghapus akun: ${e?.message || e}` });
    } finally {
      setUpdatingId(null);
    }
  };

  const handleRoleChange = async (user: ProfileRow, newRole: 'user' | 'admin' | 'buyer' | 'seller') => {
    // Pencegahan lockout: jika admin mendowngrade akunnya sendiri
    const { data: { user: currentUser } } = await supabase.auth.getUser();
    if (currentUser?.id === user.id && newRole !== 'admin') {
      const confirmSelfDemote = window.confirm(
        'PERINGATAN: Anda sedang mengubah role akun Anda sendiri menjadi Siswa/User. Anda akan kehilangan akses dashboard admin setelah ini. Lanjutkan?'
      );
      if (!confirmSelfDemote) return;
    }

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
        <div className="page-header__actions d-flex align-items-center gap-2">
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
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={() => setIsBulkImportOpen(true)}
          >
            <i className="fa-solid fa-file-import"></i>
            Impor Massal
          </button>
          <button
            type="button"
            className="m-btn m-btn--primary"
            onClick={() => {
              setNewStudentNis('');
              setNewStudentName('');
              setNewStudentGrade('XI');
              setNewStudentMajor('PPLG');
              setNewStudentClassNum('2');
              setIsCustomClass(false);
              setCustomClassText('');
              setIsAddStudentOpen(true);
            }}
          >
            <i className="fa-solid fa-user-plus"></i>
            Tambah Siswa (NIS)
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
              <option value="user">Siswa / Warga Sekolah (C2C)</option>
              <option value="admin">Administrator</option>
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
              <option value="all">Semua Verifikasi</option>
              <option value="verified">Terverifikasi</option>
              <option value="unverified">Belum Verifikasi</option>
            </select>

            {/* Filter Status Akun */}
            <select
              value={statusFilter}
              onChange={(e) => {
                setStatusFilter(e.target.value as any);
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
              <option value="all">Semua Status Akun</option>
              <option value="active">Akun Normal / Aktif</option>
              <option value="suspended">Ditangguhkan (Suspen)</option>
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
                <th>Status Akun</th>
                <th className="num">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                    <i className="fa-solid fa-arrows-rotate fa-spin" style={{ marginRight: '8px' }}></i>
                    Memuat data siswa...
                  </td>
                </tr>
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
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
                          <div style={{ fontWeight: 600, color: '#1f2937', display: 'flex', alignItems: 'center', gap: '5px' }}>
                            <span>{u.full_name || 'Siswa SMKN 8'}</span>
                            {u.is_verified && (
                              <span title="Akun Terverifikasi" style={{ display: 'inline-flex' }}>
                                <BadgeCheck
                                  size={14}
                                  fill="#1d64ec"
                                  color="#ffffff"
                                  className="shrink-0"
                                />
                              </span>
                            )}
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
                        {u.role === 'admin' ? 'admin' : 'siswa'}
                      </span>
                    </td>
                    <td>
                      {u.is_verified ? (
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '5.5px',
                            padding: '3px 9px',
                            borderRadius: '12px',
                            fontSize: '12px',
                            fontWeight: 600,
                            background: '#eff6ff',
                            color: '#1d4ed8',
                            border: '1px solid #bfdbfe',
                          }}
                        >
                          <BadgeCheck
                            size={14}
                            fill="#1d64ec"
                            color="#ffffff"
                            className="shrink-0"
                          />
                          Verified
                        </span>
                      ) : (
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '5px',
                            padding: '3px 8px',
                            borderRadius: '12px',
                            fontSize: '12px',
                            fontWeight: 500,
                            background: '#f8fafc',
                            color: '#94a3b8',
                            border: '1px solid #e2e8f0',
                          }}
                        >
                          <i className="fa-regular fa-circle" style={{ fontSize: '10px' }}></i>
                          Belum Verif
                        </span>
                      )}
                    </td>
                    <td>
                      {u.is_suspended ? (
                        <div
                          style={{
                            display: 'inline-flex',
                            flexDirection: 'column',
                            gap: '2px',
                          }}
                        >
                          <span
                            style={{
                              display: 'inline-flex',
                              alignItems: 'center',
                              gap: '5px',
                              padding: '2px 8px',
                              borderRadius: '12px',
                              fontSize: '11.5px',
                              fontWeight: 600,
                              background: '#fee2e2',
                              color: '#dc2626',
                            }}
                            title={u.suspend_reason || 'Akun ditangguhkan'}
                          >
                            <i className="fa-solid fa-lock" style={{ fontSize: '10px' }}></i>
                            Ditangguhkan
                          </span>
                          <span
                            style={{
                              fontSize: '10.5px',
                              color: '#94a3b8',
                              maxWidth: '120px',
                              overflow: 'hidden',
                              textOverflow: 'ellipsis',
                              whiteSpace: 'nowrap',
                            }}
                          >
                            {u.suspended_until
                              ? new Date(u.suspended_until).toLocaleDateString('id-ID', {
                                  day: 'numeric',
                                  month: 'short',
                                })
                              : 'Permanen'}
                          </span>
                        </div>
                      ) : (
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: '5px',
                            padding: '2px 8px',
                            borderRadius: '12px',
                            fontSize: '11.5px',
                            fontWeight: 500,
                            background: '#ecfdf5',
                            color: '#059669',
                          }}
                        >
                          <i className="fa-solid fa-circle-check" style={{ fontSize: '10px' }}></i>
                          Aktif
                        </span>
                      )}
                    </td>
                    <td className="num">
                      <div className="table-data-feature">
                        {/* Detail Inspector Button */}
                        <AdminTooltip content="Lihat detail siswa" placement="top">
                          <button
                            type="button"
                            className="item"
                            onClick={() => handleRowClick(u)}
                            style={{ border: 0, cursor: 'pointer' }}
                          >
                            <i className="fa-solid fa-eye"></i>
                          </button>
                        </AdminTooltip>

                        {/* Verify / Unverify Toggle Button with Confirmation Popup */}
                        <AdminTooltip
                          content={u.is_verified ? 'Cabut verified' : 'Beri verified'}
                          placement="top"
                        >
                          <button
                            type="button"
                            className="item"
                            disabled={updatingId === u.id}
                            onClick={() =>
                              setPendingVerifyTarget({
                                user: u,
                                newStatus: !u.is_verified,
                              })
                            }
                            style={{
                              border: 0,
                              cursor: 'pointer',
                              color: u.is_verified ? '#1d64ec' : '#94a3b8',
                            }}
                          >
                            {u.is_verified ? (
                              <BadgeCheck size={16} fill="#1d64ec" color="#ffffff" />
                            ) : (
                              <i className="fa-solid fa-user-check"></i>
                            )}
                          </button>
                        </AdminTooltip>

                        {/* Suspend / Restore Toggle Button */}
                        <AdminTooltip
                          content={
                            u.role === 'admin'
                              ? 'Admin tidak dapat disuspend'
                              : u.is_suspended
                              ? 'Pulihkan akun'
                              : 'Suspend akun'
                          }
                          placement="top"
                          variant={u.is_suspended ? 'default' : 'danger'}
                        >
                          <button
                            type="button"
                            className="item"
                            disabled={updatingId === u.id || u.role === 'admin'}
                            onClick={() => {
                              if (u.is_suspended) {
                                setPendingUnsuspendTarget(u);
                              } else {
                                setPendingSuspendTarget(u);
                              }
                            }}
                            style={{
                              border: 0,
                              cursor: u.role === 'admin' ? 'not-allowed' : 'pointer',
                              color: u.is_suspended ? '#10b981' : '#ef4444',
                              opacity: u.role === 'admin' ? 0.35 : 1,
                            }}
                          >
                            <i className={`fa-solid ${u.is_suspended ? 'fa-lock-open' : 'fa-ban'}`}></i>
                          </button>
                        </AdminTooltip>

                        {/* Hapus Akun Permanen Button */}
                        <AdminTooltip
                          content={
                            u.role === 'admin'
                              ? 'Admin tidak dapat dihapus'
                              : 'Hapus akun permanen'
                          }
                          placement="top"
                          variant="danger"
                        >
                          <button
                            type="button"
                            className="item"
                            disabled={updatingId === u.id || u.role === 'admin'}
                            onClick={() => setPendingDeleteTarget(u)}
                            style={{
                              border: 0,
                              cursor: u.role === 'admin' ? 'not-allowed' : 'pointer',
                              color: '#dc2626',
                              opacity: u.role === 'admin' ? 0.35 : 1,
                            }}
                          >
                            <i className="fa-solid fa-trash-can"></i>
                          </button>
                        </AdminTooltip>
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
        onToggleVerify={async (_userId, currentStatus) => {
          if (selectedStudent) {
            setPendingVerifyTarget({
              user: selectedStudent,
              newStatus: !currentStatus,
            });
          }
        }}
        onChangeRole={handleRoleChange}
        onRequestSuspend={(user) => {
          setPendingSuspendTarget(user);
        }}
        onRequestUnsuspend={(user) => {
          setPendingUnsuspendTarget(user);
        }}
        onRequestDelete={(user) => {
          setPendingDeleteTarget(user);
        }}
        isUpdating={updatingId === selectedStudent?.id}
      />

      {/* Modal Popup Konfirmasi Verifikasi Siswa (Mencegah Miss-Click) */}
      <AdminModalPortal
        isOpen={!!pendingVerifyTarget}
        onClose={() => setPendingVerifyTarget(null)}
      >
        {pendingVerifyTarget && (
          <div
            style={{
              background: '#ffffff',
              borderRadius: '10px',
              padding: '24px',
              maxWidth: '460px',
              width: '100%',
              boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '16px' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '50%',
                  background: pendingVerifyTarget.newStatus ? '#e0f2fe' : '#fee2e2',
                  color: pendingVerifyTarget.newStatus ? '#0284c7' : '#dc2626',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                  flexShrink: 0,
                }}
              >
                <i
                  className={`fa-solid ${
                    pendingVerifyTarget.newStatus ? 'fa-user-check' : 'fa-triangle-exclamation'
                  }`}
                ></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1f2937' }}>
                  {pendingVerifyTarget.newStatus
                    ? 'Verifikasi Akun Siswa'
                    : 'Cabut Verifikasi Akun'}
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Konfirmasi aksi otoritas admin
                </span>
              </div>
            </div>

            <p style={{ fontSize: '13.5px', color: '#475569', lineHeight: 1.5, margin: '0 0 16px' }}>
              Apakah Anda yakin ingin{' '}
              <b>
                {pendingVerifyTarget.newStatus
                  ? 'memberikan lencana verified biru ke'
                  : 'mencabut lencana verified biru dari'}
              </b>{' '}
              akun siswa <b>"{pendingVerifyTarget.user.full_name || 'Siswa'}"</b> (
              <i>@{pendingVerifyTarget.user.username || 'username'}</i>)?
            </p>

            <div
              style={{
                background: '#f0f7ff',
                border: '1px solid #bfdbfe',
                borderRadius: '6px',
                padding: '10px 12px',
                fontSize: '12px',
                color: '#1e40af',
                marginBottom: '20px',
              }}
            >
              <i className="fa-solid fa-circle-info" style={{ marginRight: '6px', color: '#2563eb' }}></i>
              {pendingVerifyTarget.newStatus
                ? 'Akun terverifikasi akan mendapatkan lencana verified biru resmi dan diizinkan bertransaksi penuh di marketplace.'
                : 'Pencabutan status akan menurunkan kepercayaan akun dan menghapus lencana verified biru di seluruh aplikasi.'}
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setPendingVerifyTarget(null)}
                disabled={updatingId === pendingVerifyTarget.user.id}
                style={{ height: '36px', padding: '0 16px', fontSize: '13px' }}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn"
                disabled={updatingId === pendingVerifyTarget.user.id}
                onClick={async () => {
                  const target = pendingVerifyTarget;
                  await handleToggleVerify(target.user.id, !target.newStatus);
                  setPendingVerifyTarget(null);
                }}
                style={{
                  height: '36px',
                  padding: '0 16px',
                  fontSize: '13px',
                  background: pendingVerifyTarget.newStatus ? '#4272d7' : '#dc2626',
                  color: '#ffffff',
                  border: 0,
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '6px',
                }}
              >
                {updatingId === pendingVerifyTarget.user.id && (
                  <i className="fa-solid fa-spinner fa-spin"></i>
                )}
                {pendingVerifyTarget.newStatus ? 'Ya, Verifikasi' : 'Ya, Cabut Verifikasi'}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>

      {/* Modal Popup Suspend / Penangguhan Akun Siswa */}
      <AdminModalPortal
        isOpen={!!pendingSuspendTarget}
        onClose={() => {
          if (!updatingId) {
            setPendingSuspendTarget(null);
            setSuspendReason('');
          }
        }}
      >
        {pendingSuspendTarget && (
          <div
            style={{
              background: '#ffffff',
              borderRadius: '12px',
              padding: '24px',
              maxWidth: '500px',
              width: '100%',
              boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
            }}
          >
            {/* Header Modal */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '50%',
                  background: '#fee2e2',
                  color: '#dc2626',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                  flexShrink: 0,
                }}
              >
                <i className="fa-solid fa-user-slash"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#991b1b' }}>
                  Tangguhkan Akun Siswa
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Penegakan aturan komunitas SMKN 8 Semarang
                </span>
              </div>
            </div>

            {/* Target Profile Snippet */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '10px 14px',
                background: '#f8fafc',
                border: '1px solid #e2e8f0',
                borderRadius: '8px',
                marginBottom: '16px',
              }}
            >
              <UserAvatar
                avatarUrl={pendingSuspendTarget.avatar_url}
                name={pendingSuspendTarget.full_name}
                size={38}
                role={pendingSuspendTarget.role}
              />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontWeight: 600, fontSize: '13.5px', color: '#1e293b' }}>
                  {pendingSuspendTarget.full_name || 'Siswa SMKN 8'}
                </div>
                <div style={{ fontSize: '11.5px', color: '#64748b' }}>
                  @{pendingSuspendTarget.username || 'user'} • {pendingSuspendTarget.class_group || 'Umum'}
                </div>
              </div>
            </div>

            {/* Durasi Penangguhan */}
            <div style={{ marginBottom: '14px' }}>
              <label
                style={{
                  display: 'block',
                  fontSize: '12.5px',
                  fontWeight: 600,
                  color: '#334155',
                  marginBottom: '6px',
                }}
              >
                Durasi Penangguhan
              </label>
              <select
                value={suspendDurationHours === null ? 'perm' : suspendDurationHours}
                onChange={(e) => {
                  const val = e.target.value;
                  setSuspendDurationHours(val === 'perm' ? null : Number(val));
                }}
                disabled={!!updatingId}
                style={{
                  width: '100%',
                  height: '38px',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  padding: '0 10px',
                  fontSize: '13px',
                  color: '#1e293b',
                  background: '#ffffff',
                }}
              >
                <option value={24}>1 Hari (24 Jam)</option>
                <option value={72}>3 Hari (72 Jam) — Standar</option>
                <option value={168}>7 Hari (1 Minggu)</option>
                <option value={720}>30 Hari (1 Bulan)</option>
                <option value="perm">Permanen (Selamanya / Tanpa Batas)</option>
              </select>
            </div>

            {/* Input Alasan Suspend */}
            <div style={{ marginBottom: '16px' }}>
              <label
                style={{
                  display: 'block',
                  fontSize: '12.5px',
                  fontWeight: 600,
                  color: '#334155',
                  marginBottom: '6px',
                }}
              >
                Alasan Penangguhan <span style={{ color: '#dc2626' }}>*</span>
              </label>
              <textarea
                rows={3}
                value={suspendReason}
                onChange={(e) => setSuspendReason(e.target.value)}
                placeholder="Contoh: Mengunggah postingan terlarang, transaksi fiktif, atau kata-kata kasar di feed."
                disabled={!!updatingId}
                style={{
                  width: '100%',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  padding: '8px 12px',
                  fontSize: '12.5px',
                  lineHeight: 1.45,
                  resize: 'vertical',
                  boxSizing: 'border-box',
                }}
              />
            </div>

            {/* Warning Box */}
            <div
              style={{
                background: '#fff1f2',
                border: '1px solid #fecdd3',
                borderRadius: '6px',
                padding: '10px 12px',
                fontSize: '11.5px',
                color: '#9f1239',
                lineHeight: 1.4,
                marginBottom: '20px',
                display: 'flex',
                gap: '8px',
              }}
            >
              <i className="fa-solid fa-shield-halved" style={{ marginTop: '2px', flexShrink: 0 }}></i>
              <span>
                Akun yang ditangguhkan akan langsung diblokir secara instan dari aplikasi mobile dan web. Pengguna tidak akan dapat memposting produk, berkomentar, menyukai postingan, atau mengirim pesan.
              </span>
            </div>

            {/* Footer Buttons */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => {
                  setPendingSuspendTarget(null);
                  setSuspendReason('');
                }}
                disabled={!!updatingId}
                style={{ height: '36px', padding: '0 16px', fontSize: '13px' }}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn"
                disabled={!!updatingId || !suspendReason.trim()}
                onClick={handleConfirmSuspend}
                style={{
                  height: '36px',
                  padding: '0 18px',
                  fontSize: '13px',
                  fontWeight: 600,
                  background: '#dc2626',
                  color: '#ffffff',
                  border: 0,
                  borderRadius: '6px',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: updatingId || !suspendReason.trim() ? 'not-allowed' : 'pointer',
                  opacity: updatingId || !suspendReason.trim() ? 0.6 : 1,
                  boxShadow: '0 2px 6px rgba(220, 38, 38, 0.35)',
                }}
              >
                {updatingId === pendingSuspendTarget.id ? (
                  <>
                    <i className="fa-solid fa-spinner fa-spin"></i>
                    Memproses...
                  </>
                ) : (
                  <>
                    <i className="fa-solid fa-ban"></i>
                    Tangguhkan Akun Sekarang
                  </>
                )}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>

      {/* Modal Popup Konfirmasi Pulihkan (Unsuspend) Akun Siswa */}
      <AdminModalPortal
        isOpen={!!pendingUnsuspendTarget}
        onClose={() => {
          if (!updatingId) setPendingUnsuspendTarget(null);
        }}
      >
        {pendingUnsuspendTarget && (
          <div
            style={{
              background: '#ffffff',
              borderRadius: '12px',
              padding: '24px',
              maxWidth: '460px',
              width: '100%',
              boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '50%',
                  background: '#dcfce7',
                  color: '#16a34a',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                  flexShrink: 0,
                }}
              >
                <i className="fa-solid fa-lock-open"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#15803d' }}>
                  Pulihkan Akun Siswa
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Buka blokir dan normalkan kembali hak akses
                </span>
              </div>
            </div>

            <p style={{ fontSize: '13.5px', color: '#475569', lineHeight: 1.5, margin: '0 0 14px' }}>
              Apakah Anda yakin ingin memulihkan dan mengaktifkan kembali akun siswa{' '}
              <b>"{pendingUnsuspendTarget.full_name || 'Siswa'}"</b> (
              <i>@{pendingUnsuspendTarget.username || 'user'}</i>)?
            </p>

            {pendingUnsuspendTarget.suspend_reason && (
              <div
                style={{
                  background: '#fef2f2',
                  border: '1px solid #fee2e2',
                  borderRadius: '6px',
                  padding: '8px 12px',
                  fontSize: '12px',
                  color: '#991b1b',
                  marginBottom: '16px',
                }}
              >
                <b>Alasan penangguhan sebelumnya:</b> {pendingUnsuspendTarget.suspend_reason}
              </div>
            )}

            <div
              style={{
                background: '#f0fdf4',
                border: '1px solid #bbf7d0',
                borderRadius: '6px',
                padding: '10px 12px',
                fontSize: '12px',
                color: '#166534',
                marginBottom: '20px',
              }}
            >
              <i className="fa-solid fa-circle-check" style={{ marginRight: '6px', color: '#16a34a' }}></i>
              Setelah dipulihkan, siswa dapat langsung login dan menggunakan seluruh fitur aplikasi seperti biasa.
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setPendingUnsuspendTarget(null)}
                disabled={!!updatingId}
                style={{ height: '36px', padding: '0 16px', fontSize: '13px' }}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn"
                disabled={!!updatingId}
                onClick={handleConfirmUnsuspend}
                style={{
                  height: '36px',
                  padding: '0 18px',
                  fontSize: '13px',
                  fontWeight: 600,
                  background: '#16a34a',
                  color: '#ffffff',
                  border: 0,
                  borderRadius: '6px',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: updatingId ? 'not-allowed' : 'pointer',
                  boxShadow: '0 2px 6px rgba(22, 163, 74, 0.35)',
                }}
              >
                {updatingId === pendingUnsuspendTarget.id ? (
                  <>
                    <i className="fa-solid fa-spinner fa-spin"></i>
                    Memproses...
                  </>
                ) : (
                  <>
                    <i className="fa-solid fa-check"></i>
                    Ya, Pulihkan Akun
                  </>
                )}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>

      {/* Modal Popup Konfirmasi Hapus Akun Permanen (Anti-Miss Click) */}
      <AdminModalPortal
        isOpen={!!pendingDeleteTarget}
        onClose={() => {
          if (!updatingId) setPendingDeleteTarget(null);
        }}
      >
        {pendingDeleteTarget && (
          <div
            style={{
              background: '#ffffff',
              borderRadius: '12px',
              padding: '24px',
              maxWidth: '490px',
              width: '100%',
              boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
            }}
          >
            {/* Header Modal */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div
                style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '50%',
                  background: '#fee2e2',
                  color: '#dc2626',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '20px',
                  flexShrink: 0,
                }}
              >
                <i className="fa-solid fa-trash-can"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#991b1b' }}>
                  Hapus Akun Pengguna Secara Permanen
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Tindakan destruktif ini tidak dapat dibatalkan
                </span>
              </div>
            </div>

            {/* Target Profile Snippet */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '10px 14px',
                background: '#f8fafc',
                border: '1px solid #e2e8f0',
                borderRadius: '8px',
                marginBottom: '16px',
              }}
            >
              <UserAvatar
                avatarUrl={pendingDeleteTarget.avatar_url}
                name={pendingDeleteTarget.full_name}
                size={40}
                role={pendingDeleteTarget.role}
              />
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontWeight: 600, fontSize: '13.5px', color: '#1e293b' }}>
                  {pendingDeleteTarget.full_name || 'Pengguna'}
                </div>
                <div style={{ fontSize: '11.5px', color: '#64748b' }}>
                  @{pendingDeleteTarget.username || 'user'} • {pendingDeleteTarget.class_group || 'Umum'}
                  {pendingDeleteTarget.nis ? ` • NIS: ${pendingDeleteTarget.nis}` : ''}
                </div>
              </div>
            </div>

            {/* Penjelasan Dampak Penghapusan Akun */}
            <div
              style={{
                background: '#fff1f2',
                border: '1px solid #fecdd3',
                borderRadius: '8px',
                padding: '12px 14px',
                marginBottom: '18px',
              }}
            >
              <div style={{ fontWeight: 600, fontSize: '12.5px', color: '#9f1239', marginBottom: '8px' }}>
                <i className="fa-solid fa-triangle-exclamation" style={{ marginRight: '6px' }}></i>
                Konsekuensi penghapusan akun:
              </div>
              <ul
                style={{
                  margin: 0,
                  paddingLeft: '18px',
                  fontSize: '12px',
                  color: '#881337',
                  lineHeight: 1.55,
                }}
              >
                <li>
                  <b>Semua postingan pasar & utas sosial</b> milik pengguna ini akan dihapus permanen.
                </li>
                <li>
                  <b>Username (@{pendingDeleteTarget.username})</b> dan <b>nomor NIS</b> akan dibebaskan kembali sehingga pengguna lain dapat mendaftar dengan identitas tersebut.
                </li>
                <li>
                  Semua interaksi sosial (pesanan COD, pesan obrolan, suka, dan komentar) akan dibersihkan.
                </li>
              </ul>
            </div>

            {/* Footer Buttons */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setPendingDeleteTarget(null)}
                disabled={!!updatingId}
                style={{ height: '36px', padding: '0 16px', fontSize: '13px' }}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn"
                disabled={!!updatingId}
                onClick={handleConfirmDelete}
                style={{
                  height: '36px',
                  padding: '0 18px',
                  fontSize: '13px',
                  fontWeight: 600,
                  background: '#dc2626',
                  color: '#ffffff',
                  border: 0,
                  borderRadius: '6px',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: updatingId ? 'not-allowed' : 'pointer',
                  boxShadow: '0 2px 6px rgba(220, 38, 38, 0.35)',
                }}
              >
                {updatingId === pendingDeleteTarget.id ? (
                  <>
                    <i className="fa-solid fa-spinner fa-spin"></i>
                    Menghapus Akun...
                  </>
                ) : (
                  <>
                    <i className="fa-solid fa-trash-can"></i>
                    Ya, Hapus Akun Permanen
                  </>
                )}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>

      {/* MODAL TAMBAH SISWA BARU (NIS) */}
      <AdminModalPortal
        isOpen={isAddStudentOpen}
        onClose={() => {
          if (!isSubmittingStudent) setIsAddStudentOpen(false);
        }}
      >
        <div
          style={{
            background: '#ffffff',
            borderRadius: '14px',
            padding: '24px',
            maxWidth: '480px',
            width: '100%',
            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
          }}
        >
          {/* Header Modal */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '20px' }}>
            <div
              style={{
                width: '44px',
                height: '44px',
                borderRadius: '10px',
                background: '#eaf0fc',
                color: '#4272d7',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '19px',
                flexShrink: 0,
              }}
            >
              <i className="fa-solid fa-user-plus"></i>
            </div>
            <div>
              <h3 style={{ margin: 0, fontSize: '17px', fontWeight: 700, color: '#1e293b' }}>
                Tambah Siswa Baru
              </h3>
              <span style={{ fontSize: '12.5px', color: '#64748b' }}>
                Daftarkan NIS agar siswa dapat membuat akun di aplikasi
              </span>
            </div>
          </div>

          <form
            onSubmit={async (e) => {
              e.preventDefault();
              const finalClass = isCustomClass
                ? customClassText.trim()
                : `${newStudentGrade} ${newStudentMajor} ${newStudentClassNum}`.trim();

              if (!newStudentNis.trim() || !newStudentName.trim() || !finalClass) {
                setFeedbackMsg({ type: 'error', text: 'Semua kolom wajib diisi.' });
                return;
              }

              setIsSubmittingStudent(true);
              try {
                await adminService.addStudent({
                  nis: newStudentNis.trim(),
                  full_name: newStudentName.trim(),
                  class_group: finalClass,
                });
                setFeedbackMsg({
                  type: 'success',
                  text: `NIS ${newStudentNis} (${newStudentName} - ${finalClass}) berhasil didaftarkan. Siswa kini bisa mendaftar di aplikasi.`,
                });
                setIsAddStudentOpen(false);
                setNewStudentNis('');
                setNewStudentName('');
                setTimeout(() => setFeedbackMsg(null), 5000);
              } catch (err: any) {
                setFeedbackMsg({ type: 'error', text: err?.message || 'Gagal menambahkan data siswa.' });
              } finally {
                setIsSubmittingStudent(false);
              }
            }}
          >
            {/* NIS Input */}
            <div style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                Nomor Induk Siswa (NIS)
              </label>
              <input
                type="text"
                className="au-input"
                placeholder="Contoh: 11816"
                value={newStudentNis}
                onChange={(e) => setNewStudentNis(e.target.value)}
                disabled={isSubmittingStudent}
                required
                style={{
                  width: '100%',
                  height: '40px',
                  borderRadius: '8px',
                  border: '1px solid #cbd5e1',
                  padding: '0 14px',
                  fontSize: '13.5px',
                  fontFamily: 'inherit',
                  color: '#1e293b',
                  background: '#ffffff',
                }}
              />
            </div>

            {/* Nama Lengkap Input */}
            <div style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', fontSize: '13px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                Nama Lengkap Siswa
              </label>
              <input
                type="text"
                className="au-input"
                placeholder="Contoh: Raditya Rayhan Yogiswara"
                value={newStudentName}
                onChange={(e) => setNewStudentName(e.target.value)}
                disabled={isSubmittingStudent}
                required
                style={{
                  width: '100%',
                  height: '40px',
                  borderRadius: '8px',
                  border: '1px solid #cbd5e1',
                  padding: '0 14px',
                  fontSize: '13.5px',
                  fontFamily: 'inherit',
                  color: '#1e293b',
                  background: '#ffffff',
                }}
              />
            </div>

            {/* Kelas & Jurusan Selection */}
            <div style={{ marginBottom: '22px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                <label style={{ fontSize: '13px', fontWeight: 600, color: '#334155', margin: 0 }}>
                  Kelas & Jurusan
                </label>
                <button
                  type="button"
                  onClick={() => setIsCustomClass(!isCustomClass)}
                  style={{
                    background: 'none',
                    border: 'none',
                    padding: 0,
                    color: '#4272d7',
                    fontSize: '12px',
                    fontWeight: 600,
                    cursor: 'pointer',
                  }}
                >
                  {isCustomClass ? 'Gunakan Pilihan Jurusan' : '+ Ketik Kustom'}
                </button>
              </div>

              {isCustomClass ? (
                <input
                  type="text"
                  className="au-input"
                  placeholder="Ketik kelas kustom (misal: XII Animasi 1)"
                  value={customClassText}
                  onChange={(e) => setCustomClassText(e.target.value)}
                  disabled={isSubmittingStudent}
                  required
                  style={{
                    width: '100%',
                    height: '40px',
                    borderRadius: '8px',
                    border: '1px solid #cbd5e1',
                    padding: '0 14px',
                    fontSize: '13.5px',
                    fontFamily: 'inherit',
                  }}
                />
              ) : (
                <div>
                  <div style={{ display: 'grid', gridTemplateColumns: '85px 1fr 75px', gap: '8px' }}>
                    {/* Tingkat */}
                    <select
                      value={newStudentGrade}
                      onChange={(e) => setNewStudentGrade(e.target.value as any)}
                      disabled={isSubmittingStudent}
                      style={{
                        height: '40px',
                        borderRadius: '8px',
                        border: '1px solid #cbd5e1',
                        padding: '0 10px',
                        fontSize: '13px',
                        fontWeight: 600,
                        color: '#1e293b',
                        background: '#ffffff',
                      }}
                    >
                      {SMKN8_GRADES.map((g) => (
                        <option key={g} value={g}>
                          {g}
                        </option>
                      ))}
                    </select>

                    {/* Jurusan Combobox: PPLG, TJKT, DKV, PS, LK */}
                    <select
                      value={newStudentMajor}
                      onChange={(e) => setNewStudentMajor(e.target.value)}
                      disabled={isSubmittingStudent}
                      style={{
                        height: '40px',
                        borderRadius: '8px',
                        border: '1px solid #cbd5e1',
                        padding: '0 12px',
                        fontSize: '13px',
                        fontWeight: 600,
                        color: '#4272d7',
                        background: '#f8fafc',
                      }}
                    >
                      {SMKN8_MAJORS.map((m) => (
                        <option key={m} value={m}>
                          {m}
                        </option>
                      ))}
                    </select>

                    {/* Nomor Rombel */}
                    <select
                      value={newStudentClassNum}
                      onChange={(e) => setNewStudentClassNum(e.target.value)}
                      disabled={isSubmittingStudent}
                      style={{
                        height: '40px',
                        borderRadius: '8px',
                        border: '1px solid #cbd5e1',
                        padding: '0 10px',
                        fontSize: '13px',
                        fontWeight: 600,
                        color: '#1e293b',
                        background: '#ffffff',
                      }}
                    >
                      {SMKN8_CLASS_NUMS.map((n) => (
                        <option key={n} value={n}>
                          {n}
                        </option>
                      ))}
                    </select>
                  </div>

                  <div style={{ marginTop: '8px', display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12px', color: '#64748b' }}>
                    <span>Format kelas:</span>
                    <span
                      style={{
                        padding: '2px 8px',
                        borderRadius: '5px',
                        background: '#eff6ff',
                        color: '#1d4ed8',
                        fontWeight: 700,
                        fontSize: '12px',
                        border: '1px solid #dbeafe',
                      }}
                    >
                      {newStudentGrade} {newStudentMajor} {newStudentClassNum}
                    </span>
                  </div>
                </div>
              )}
            </div>

            {/* Action Buttons */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setIsAddStudentOpen(false)}
                disabled={isSubmittingStudent}
                style={{ height: '38px', padding: '0 16px', borderRadius: '8px' }}
              >
                Batal
              </button>
              <button
                type="submit"
                className="m-btn m-btn--primary"
                disabled={isSubmittingStudent}
                style={{ height: '38px', padding: '0 18px', borderRadius: '8px' }}
              >
                {isSubmittingStudent ? (
                  <>
                    <i className="fa-solid fa-spinner fa-spin"></i> Mendaftarkan...
                  </>
                ) : (
                  'Daftarkan Siswa'
                )}
              </button>
            </div>
          </form>
        </div>
      </AdminModalPortal>

      {/* MODAL IMPOR MASSAL SISWA */}
      <AdminModalPortal
        isOpen={isBulkImportOpen}
        onClose={() => {
          if (!isSubmittingBulk) setIsBulkImportOpen(false);
        }}
      >
        <div
          style={{
            background: '#ffffff',
            borderRadius: '12px',
            padding: '24px',
            maxWidth: '560px',
            width: '100%',
            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
          }}
        >
          {/* Header Modal */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <div
              style={{
                width: '42px',
                height: '42px',
                borderRadius: '50%',
                background: '#eaf0fc',
                color: '#4272d7',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '18px',
                flexShrink: 0,
              }}
            >
              <i className="fa-solid fa-file-import"></i>
            </div>
            <div>
              <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1e293b' }}>
                Impor Massal NIS Siswa ke Buku Induk
              </h3>
              <span style={{ fontSize: '12px', color: '#64748b' }}>
                Masukkan data siswa sekelas sekaligus (format CSV / baris teks)
              </span>
            </div>
          </div>

          <p style={{ fontSize: '12.5px', color: '#64748b', marginBottom: '10px' }}>
            Tempel data siswa dengan format:{' '}
            <code style={{ background: '#f1f5f9', padding: '2px 5px', borderRadius: '4px', color: '#1e293b' }}>
              NIS, Nama Lengkap, Kelas
            </code>
          </p>

          <div style={{ marginBottom: '16px' }}>
            <textarea
              rows={7}
              placeholder={`11816, AIDA DWI RIANA PUTRI, XI PPLG 2\n11817, ALAIS LUTFI NAFISAH, XI PPLG 2\n11818, ALFIAN DZAKY RAMADHAN, XI PPLG 2`}
              value={bulkText}
              onChange={(e) => setBulkText(e.target.value)}
              disabled={isSubmittingBulk}
              style={{
                width: '100%',
                borderRadius: '6px',
                border: '1px solid #e2e8f0',
                padding: '10px 12px',
                fontSize: '12.5px',
                fontFamily: 'SFMono-Regular, Menlo, Monaco, Consolas, monospace',
                resize: 'vertical',
              }}
            />
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
            <button
              type="button"
              className="m-btn m-btn--ghost"
              onClick={() => setIsBulkImportOpen(false)}
              disabled={isSubmittingBulk}
            >
              Batal
            </button>
            <button
              type="button"
              className="m-btn m-btn--primary"
              disabled={isSubmittingBulk || !bulkText.trim()}
              onClick={async () => {
                if (!bulkText.trim()) return;
                const lines = bulkText.split('\n');
                const rows: Array<{ nis: string; full_name: string; class_group: string }> = [];

                for (const rawLine of lines) {
                  const line = rawLine.trim();
                  if (!line || line.startsWith('#') || line.toLowerCase().startsWith('nis')) continue;
                  let parts: string[] = [];
                  if (line.includes('\t')) parts = line.split('\t');
                  else if (line.includes(',')) parts = line.split(',');
                  else if (line.includes(';')) parts = line.split(';');

                  if (parts.length >= 3) {
                    const nis = parts[0].trim();
                    const full_name = parts[1].trim();
                    const class_group = parts[2].trim();
                    if (nis && full_name && class_group) {
                      rows.push({ nis, full_name, class_group });
                    }
                  }
                }

                if (rows.length === 0) {
                  setFeedbackMsg({
                    type: 'error',
                    text: 'Tidak ada baris data valid yang terdeteksi. Pastikan format: NIS, Nama Lengkap, Kelas',
                  });
                  return;
                }

                setIsSubmittingBulk(true);
                try {
                  const res = await adminService.batchAddStudents(rows);
                  setFeedbackMsg({
                    type: 'success',
                    text: `Berhasil mengimpor ${res.inserted} siswa ke buku induk.`,
                  });
                  setIsBulkImportOpen(false);
                  setBulkText('');
                  setTimeout(() => setFeedbackMsg(null), 5000);
                } catch (err: any) {
                  setFeedbackMsg({ type: 'error', text: err?.message || 'Gagal mengimpor siswa.' });
                } finally {
                  setIsSubmittingBulk(false);
                }
              }}
            >
              {isSubmittingBulk ? (
                <>
                  <i className="fa-solid fa-spinner fa-spin"></i> Mengimpor...
                </>
              ) : (
                'Mulai Impor Siswa'
              )}
            </button>
          </div>
        </div>
      </AdminModalPortal>
    </>
  );
}
