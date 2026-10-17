import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { BadgeCheck } from 'lucide-react';
import {
  adminService,
  type StudentRegistryRow,
  type StudentRegistryStats,
} from '../services/adminService';
import { AdminModalPortal } from '../components/AdminModalPortal';
import { AdminTooltip } from '../components/AdminTooltip';

// Daftar kelas standar SMKN 8 Semarang
const STANDARD_CLASS_OPTIONS = [
  'X PPLG 1',
  'X PPLG 2',
  'XI PPLG 1',
  'XI PPLG 2',
  'XII PPLG 1',
  'XII PPLG 2',
  'X DKV 1',
  'X DKV 2',
  'XI DKV 1',
  'XI DKV 2',
  'XII DKV 1',
  'XII DKV 2',
  'X Kuliner 1',
  'X Kuliner 2',
  'XI Kuliner 1',
  'XI Kuliner 2',
  'XII Kuliner 1',
  'XII Kuliner 2',
  'X TO 1',
  'X TO 2',
  'XI TO 1',
  'XI TO 2',
  'XII TO 1',
  'XII TO 2',
];

interface StudentRegistryTabProps {
  isActive?: boolean;
}

export function StudentRegistryTab({ isActive = true }: StudentRegistryTabProps) {
  const [students, setStudents] = useState<StudentRegistryRow[]>([]);
  const [stats, setStats] = useState<StudentRegistryStats>({ total: 0, claimed: 0, unclaimed: 0 });
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'claimed' | 'unclaimed'>('all');
  const [classFilter, setClassFilter] = useState('all');
  const [page, setPage] = useState(1);
  const pageSize = 15;
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Single Add / Edit Modal State
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [editingStudent, setEditingStudent] = useState<StudentRegistryRow | null>(null);
  const [formNis, setFormNis] = useState('');
  const [formName, setFormName] = useState('');
  const [formClass, setFormClass] = useState(STANDARD_CLASS_OPTIONS[2]); // Default XI PPLG 1
  const [isCustomClass, setIsCustomClass] = useState(false);
  const [customClassText, setCustomClassText] = useState('');
  const [isSubmittingForm, setIsSubmittingForm] = useState(false);

  // Bulk Import Modal State
  const [isBulkModalOpen, setIsBulkModalOpen] = useState(false);
  const [bulkText, setBulkText] = useState('');
  const [isSubmittingBulk, setIsSubmittingBulk] = useState(false);

  // Confirm Reset Claim Modal
  const [resetTarget, setResetTarget] = useState<StudentRegistryRow | null>(null);
  const [isResetting, setIsResetting] = useState(false);

  // Confirm Delete Modal
  const [deleteTarget, setDeleteTarget] = useState<StudentRegistryRow | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const fetchStats = useCallback(async () => {
    try {
      const s = await adminService.getStudentRegistryStats();
      setStats(s);
    } catch (e) {
      console.error('Error fetching student stats:', e);
    }
  }, []);

  const fetchStudents = useCallback(async () => {
    setIsLoading(true);
    try {
      const offset = (page - 1) * pageSize;
      const res = await adminService.getStudentRegistry({
        search,
        status: statusFilter,
        classGroup: classFilter,
        limit: pageSize,
        offset,
      });
      setStudents(res.data);
      setTotalCount(res.count);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat siswa: ${e?.message || e}` });
    } finally {
      setIsLoading(false);
    }
  }, [search, statusFilter, classFilter, page, pageSize]);

  useEffect(() => {
    if (isActive) {
      fetchStats();
      fetchStudents();
    }
  }, [isActive, fetchStats, fetchStudents]);

  // Distinct classes for filter dropdown
  const availableClassFilters = useMemo(() => {
    const set = new Set<string>();
    STANDARD_CLASS_OPTIONS.forEach((c) => set.add(c));
    students.forEach((s) => {
      if (s.class_group) set.add(s.class_group);
    });
    return Array.from(set).sort();
  }, [students]);

  const openAddModal = () => {
    setEditingStudent(null);
    setFormNis('');
    setFormName('');
    setFormClass(STANDARD_CLASS_OPTIONS[2]);
    setIsCustomClass(false);
    setCustomClassText('');
    setIsFormModalOpen(true);
  };

  const openEditModal = (student: StudentRegistryRow) => {
    setEditingStudent(student);
    setFormNis(student.nis);
    setFormName(student.full_name);
    if (STANDARD_CLASS_OPTIONS.includes(student.class_group)) {
      setFormClass(student.class_group);
      setIsCustomClass(false);
      setCustomClassText('');
    } else {
      setIsCustomClass(true);
      setCustomClassText(student.class_group);
    }
    setIsFormModalOpen(true);
  };

  const handleSubmitForm = async (e: React.FormEvent) => {
    e.preventDefault();
    const finalClass = (isCustomClass ? customClassText : formClass).trim();
    if (!formNis.trim() || !formName.trim() || !finalClass) {
      setFeedbackMsg({ type: 'error', text: 'Semua kolom wajib diisi.' });
      return;
    }

    setIsSubmittingForm(true);
    try {
      if (editingStudent) {
        await adminService.updateStudent(editingStudent.nis, {
          full_name: formName,
          class_group: finalClass,
        });
        setFeedbackMsg({ type: 'success', text: `Data NIS ${editingStudent.nis} berhasil diperbarui.` });
      } else {
        await adminService.addStudent({
          nis: formNis,
          full_name: formName,
          class_group: finalClass,
        });
        setFeedbackMsg({ type: 'success', text: `Siswa NIS ${formNis} berhasil didaftarkan ke buku induk.` });
      }
      setIsFormModalOpen(false);
      fetchStats();
      fetchStudents();
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (err: any) {
      setFeedbackMsg({ type: 'error', text: err?.message || 'Gagal menyimpan data siswa.' });
    } finally {
      setIsSubmittingForm(false);
    }
  };

  // Parse bulk text: accepts CSV or line-by-line format: "NIS, Nama Lengkap, Kelas"
  const parsedBulkRows = useMemo(() => {
    if (!bulkText.trim()) return [];
    const lines = bulkText.split('\n');
    const rows: Array<{ nis: string; full_name: string; class_group: string }> = [];

    for (const rawLine of lines) {
      const line = rawLine.trim();
      if (!line || line.startsWith('#') || line.toLowerCase().startsWith('nis')) continue;

      let parts: string[] = [];
      if (line.includes('\t')) {
        parts = line.split('\t');
      } else if (line.includes(',')) {
        parts = line.split(',');
      } else if (line.includes(';')) {
        parts = line.split(';');
      }

      if (parts.length >= 3) {
        const nis = parts[0].trim();
        const full_name = parts[1].trim();
        const class_group = parts[2].trim();
        if (nis && full_name && class_group) {
          rows.push({ nis, full_name, class_group });
        }
      }
    }
    return rows;
  }, [bulkText]);

  const handleSubmitBulk = async () => {
    if (parsedBulkRows.length === 0) {
      setFeedbackMsg({ type: 'error', text: 'Tidak ada baris data valid yang terdeteksi.' });
      return;
    }

    setIsSubmittingBulk(true);
    try {
      const res = await adminService.batchAddStudents(parsedBulkRows);
      setFeedbackMsg({
        type: 'success',
        text: `Berhasil mengimpor ${res.inserted} siswa ke buku induk.`,
      });
      setIsBulkModalOpen(false);
      setBulkText('');
      fetchStats();
      fetchStudents();
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (err: any) {
      setFeedbackMsg({ type: 'error', text: err?.message || 'Gagal melakukan impor massal.' });
    } finally {
      setIsSubmittingBulk(false);
    }
  };

  const handleConfirmReset = async () => {
    if (!resetTarget) return;
    setIsResetting(true);
    try {
      await adminService.resetStudentClaim(resetTarget.nis);
      setFeedbackMsg({
        type: 'success',
        text: `Status klaim NIS ${resetTarget.nis} (${resetTarget.full_name}) berhasil dilepas. Siswa dapat mendaftar ulang.`,
      });
      setResetTarget(null);
      fetchStats();
      fetchStudents();
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (err: any) {
      setFeedbackMsg({ type: 'error', text: err?.message || 'Gagal melepas status klaim.' });
    } finally {
      setIsResetting(false);
    }
  };

  const handleConfirmDelete = async () => {
    if (!deleteTarget) return;
    setIsDeleting(true);
    try {
      await adminService.deleteStudent(deleteTarget.nis);
      setFeedbackMsg({
        type: 'success',
        text: `NIS ${deleteTarget.nis} (${deleteTarget.full_name}) berhasil dihapus dari buku induk.`,
      });
      setDeleteTarget(null);
      fetchStats();
      fetchStudents();
      setTimeout(() => setFeedbackMsg(null), 4000);
    } catch (err: any) {
      setFeedbackMsg({ type: 'error', text: err?.message || 'Gagal menghapus siswa.' });
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <div>
      {/* 1. Page Header (CoolAdmin Standard) */}
      <div className="page-header d-flex flex-wrap align-items-center justify-content-between mb-4">
        <div>
          <h2 className="title">Buku Induk (NIS)</h2>
          <p className="subtitle">
            Kelola master data nomor induk siswa SMKN 8 Semarang, kuota registrasi, dan akun tertaut.
          </p>
        </div>
        <div className="page-header__actions d-flex align-items-center gap-2">
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={() => {
              fetchStats();
              fetchStudents();
            }}
            disabled={isLoading}
          >
            <i className={`fa-solid fa-arrows-rotate ${isLoading ? 'fa-spin' : ''}`}></i>
            Segarkan
          </button>
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={() => setIsBulkModalOpen(true)}
          >
            <i className="fa-solid fa-file-import"></i>
            Impor Massal
          </button>
          <button
            type="button"
            className="m-btn m-btn--primary"
            onClick={openAddModal}
          >
            <i className="fa-solid fa-user-plus"></i>
            Tambah Siswa
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
          <span style={{ flex: 1 }}>{feedbackMsg.text}</span>
          <button
            type="button"
            onClick={() => setFeedbackMsg(null)}
            style={{ background: 'transparent', border: 0, color: 'inherit', cursor: 'pointer', opacity: 0.7 }}
          >
            <i className="fa-solid fa-xmark"></i>
          </button>
        </div>
      )}

      {/* 2. KPI Strip (CoolAdmin Stat Cards) */}
      <div className="row row-tight mb-4">
        <div className="col-sm-6 col-lg-4 mb-3 mb-lg-0">
          <div className="overview-item overview-item--c1" style={{ marginBottom: 0 }}>
            <div className="overview__inner">
              <div className="overview-box clearfix">
                <div className="icon">
                  <i className="fa-solid fa-id-card"></i>
                </div>
                <div className="text">
                  <h2>{stats.total.toLocaleString()}</h2>
                  <span>Total NIS di Buku Induk</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="col-sm-6 col-lg-4 mb-3 mb-lg-0">
          <div className="overview-item overview-item--c2" style={{ marginBottom: 0 }}>
            <div className="overview__inner">
              <div className="overview-box clearfix">
                <div className="icon">
                  <i className="fa-solid fa-user-check"></i>
                </div>
                <div className="text">
                  <h2>{stats.claimed.toLocaleString()}</h2>
                  <span>Akun Aktif (Sudah Diklaim)</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="col-sm-6 col-lg-4">
          <div className="overview-item overview-item--c3" style={{ marginBottom: 0 }}>
            <div className="overview__inner">
              <div className="overview-box clearfix">
                <div className="icon">
                  <i className="fa-solid fa-clock"></i>
                </div>
                <div className="text">
                  <h2>{stats.unclaimed.toLocaleString()}</h2>
                  <span>Tersedia untuk Registrasi</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* 3. Main Data Card with Filter and Table */}
      <section className="m-card">
        {/* Filter Bar Header */}
        <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            {/* Search Input */}
            <div style={{ position: 'relative', width: '280px' }}>
              <input
                type="text"
                className="au-input"
                placeholder="Cari NIS atau Nama Siswa..."
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

            {/* Filter Status */}
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
              <option value="all">Semua Status Klaim</option>
              <option value="unclaimed">Belum Diklaim (Tersedia)</option>
              <option value="claimed">Sudah Diklaim</option>
            </select>

            {/* Filter Kelas */}
            <select
              value={classFilter}
              onChange={(e) => {
                setClassFilter(e.target.value);
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
              <option value="all">Semua Kelas/Jurusan</option>
              {availableClassFilters.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </div>

          <div style={{ fontSize: '12.5px', color: '#64748b' }}>
            Total: <b>{totalCount}</b> nomor induk
          </div>
        </header>

        {/* Data Table (CoolAdmin m-table) */}
        <div className="table-responsive">
          <table className="m-table">
            <thead>
              <tr>
                <th>NIS</th>
                <th>Nama Lengkap Siswa</th>
                <th>Kelas / Jurusan</th>
                <th>Status Registrasi</th>
                <th>Akun Tertaut (@username)</th>
                <th className="num">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', padding: '36px 0', color: '#94a3b8' }}>
                    <i className="fa-solid fa-arrows-rotate fa-spin" style={{ marginRight: '8px' }}></i>
                    Memuat data master NIS...
                  </td>
                </tr>
              ) : students.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', padding: '36px 0', color: '#94a3b8' }}>
                    <i className="fa-regular fa-folder-open" style={{ fontSize: '24px', display: 'block', marginBottom: '8px' }}></i>
                    Tidak ada data siswa yang cocok dengan filter.
                  </td>
                </tr>
              ) : (
                students.map((student) => {
                  const profile = student.claimed_profile;
                  return (
                    <tr key={student.nis}>
                      {/* NIS */}
                      <td>
                        <span
                          style={{
                            fontFamily: 'SFMono-Regular, Menlo, Monaco, Consolas, monospace',
                            fontSize: '12px',
                            fontWeight: 700,
                            color: '#1e293b',
                            background: '#f1f5f9',
                            padding: '3px 8px',
                            borderRadius: '5px',
                            border: '1px solid #e2e8f0',
                            letterSpacing: '0.5px',
                          }}
                        >
                          {student.nis}
                        </span>
                      </td>

                      {/* Nama Lengkap */}
                      <td>
                        <div style={{ fontWeight: 600, color: '#1f2937' }}>
                          {student.full_name}
                        </div>
                      </td>

                      {/* Kelas / Jurusan */}
                      <td>
                        <span
                          style={{
                            fontSize: '12px',
                            fontWeight: 500,
                            padding: '3px 8px',
                            borderRadius: '4px',
                            background: '#f8fafc',
                            color: '#475569',
                            border: '1px solid #e2e8f0',
                          }}
                        >
                          {student.class_group}
                        </span>
                      </td>

                      {/* Status Registrasi */}
                      <td>
                        {student.is_claimed ? (
                          <span
                            style={{
                              display: 'inline-flex',
                              alignItems: 'center',
                              gap: '6px',
                              padding: '3px 10px',
                              borderRadius: '20px',
                              fontSize: '12px',
                              fontWeight: 600,
                              background: '#ecfdf5',
                              color: '#059669',
                            }}
                          >
                            <i className="fa-solid fa-circle-check" style={{ fontSize: '11px' }}></i>
                            Sudah Diklaim
                          </span>
                        ) : (
                          <span
                            style={{
                              display: 'inline-flex',
                              alignItems: 'center',
                              gap: '6px',
                              padding: '3px 10px',
                              borderRadius: '20px',
                              fontSize: '12px',
                              fontWeight: 600,
                              background: '#fffbeb',
                              color: '#d97706',
                            }}
                          >
                            <i className="fa-solid fa-clock" style={{ fontSize: '11px' }}></i>
                            Tersedia
                          </span>
                        )}
                      </td>

                      {/* Akun Tertaut */}
                      <td>
                        {student.is_claimed ? (
                          profile ? (
                            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                              <span style={{ fontWeight: 600, color: '#4272d7' }}>
                                @{profile.username}
                              </span>
                              {profile.is_verified && (
                                <BadgeCheck size={14} fill="#1d64ec" color="#ffffff" />
                              )}
                            </div>
                          ) : (
                            <span style={{ fontSize: '12px', color: '#64748b' }}>
                              Terdaftar (User Aktif)
                            </span>
                          )
                        ) : (
                          <span style={{ fontSize: '12px', color: '#94a3b8', fontStyle: 'italic' }}>
                            Belum ada akun
                          </span>
                        )}
                      </td>

                      {/* Aksi */}
                      <td className="num">
                        <div className="table-data-feature">
                          {/* Edit Nama/Kelas */}
                          <AdminTooltip content="Ubah Nama/Kelas">
                            <button
                              type="button"
                              className="item"
                              onClick={() => openEditModal(student)}
                              style={{ border: 0, cursor: 'pointer' }}
                            >
                              <i className="fa-solid fa-pen-to-square"></i>
                            </button>
                          </AdminTooltip>

                          {/* Reset Status Klaim */}
                          {student.is_claimed && (
                            <AdminTooltip content="Reset Status Klaim (Izinkan Daftar Ulang)">
                              <button
                                type="button"
                                className="item"
                                onClick={() => setResetTarget(student)}
                                style={{ border: 0, cursor: 'pointer', color: '#d97706' }}
                              >
                                <i className="fa-solid fa-rotate-left"></i>
                              </button>
                            </AdminTooltip>
                          )}

                          {/* Hapus NIS */}
                          <AdminTooltip content="Hapus NIS dari Buku Induk">
                            <button
                              type="button"
                              className="item"
                              onClick={() => setDeleteTarget(student)}
                              style={{ border: 0, cursor: 'pointer', color: '#dc2626' }}
                            >
                              <i className="fa-solid fa-trash-can"></i>
                            </button>
                          </AdminTooltip>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination Footer */}
        {totalCount > pageSize && (
          <footer
            className="m-card__footer d-flex align-items-center justify-content-between"
            style={{ padding: '14px 20px', borderTop: '1px solid #f1f5f9' }}
          >
            <div style={{ fontSize: '12px', color: '#64748b' }}>
              Menampilkan {(page - 1) * pageSize + 1} -{' '}
              {Math.min(page * pageSize, totalCount)} dari {totalCount} nomor induk
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <button
                type="button"
                className="m-btn m-btn--sm m-btn--ghost"
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
              >
                Sebelumnya
              </button>
              <span
                style={{
                  fontSize: '12.5px',
                  fontWeight: 600,
                  color: '#475569',
                  padding: '0 8px',
                }}
              >
                Halaman {page} dari {Math.ceil(totalCount / pageSize)}
              </span>
              <button
                type="button"
                className="m-btn m-btn--sm m-btn--ghost"
                disabled={page >= Math.ceil(totalCount / pageSize)}
                onClick={() => setPage((p) => p + 1)}
              >
                Berikutnya
              </button>
            </div>
          </footer>
        )}
      </section>

      {/* MODAL 1: Form Tambah / Edit Siswa Satuan */}
      <AdminModalPortal
        isOpen={isFormModalOpen}
        onClose={() => {
          if (!isSubmittingForm) setIsFormModalOpen(false);
        }}
      >
        <div
          style={{
            background: '#ffffff',
            borderRadius: '12px',
            padding: '24px',
            maxWidth: '480px',
            width: '100%',
            boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
          }}
        >
          {/* Header Modal */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '18px' }}>
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
              <i className={`fa-solid ${editingStudent ? 'fa-pen-to-square' : 'fa-user-plus'}`}></i>
            </div>
            <div>
              <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1e293b' }}>
                {editingStudent ? 'Ubah Data Siswa di Buku Induk' : 'Tambah Siswa ke Buku Induk'}
              </h3>
              <span style={{ fontSize: '12px', color: '#64748b' }}>
                Master data nomor induk siswa SMKN 8 Semarang
              </span>
            </div>
          </div>

          <form onSubmit={handleSubmitForm}>
            {/* NIS Input */}
            <div style={{ marginBottom: '14px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                Nomor Induk Siswa (NIS)
              </label>
              <input
                type="text"
                className="au-input"
                placeholder="Contoh: 11816"
                value={formNis}
                onChange={(e) => setFormNis(e.target.value)}
                disabled={!!editingStudent || isSubmittingForm}
                required
                style={{
                  width: '100%',
                  height: '38px',
                  borderRadius: '6px',
                  border: '1px solid #e2e8f0',
                  padding: '0 12px',
                  fontSize: '13px',
                  fontFamily: 'SFMono-Regular, Menlo, Monaco, Consolas, monospace',
                  background: editingStudent ? '#f8fafc' : '#ffffff',
                }}
              />
              {editingStudent && (
                <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
                  Nomor NIS terkunci saat mode ubah demi integritas referensi akun.
                </div>
              )}
            </div>

            {/* Nama Lengkap Input */}
            <div style={{ marginBottom: '14px' }}>
              <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#334155', marginBottom: '6px' }}>
                Nama Lengkap Siswa
              </label>
              <input
                type="text"
                className="au-input"
                placeholder="Contoh: Aida Dwi Riana Putri"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                disabled={isSubmittingForm}
                required
                style={{
                  width: '100%',
                  height: '38px',
                  borderRadius: '6px',
                  border: '1px solid #e2e8f0',
                  padding: '0 12px',
                  fontSize: '13px',
                }}
              />
            </div>

            {/* Kelas / Jurusan Selection */}
            <div style={{ marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                <label style={{ fontSize: '12.5px', fontWeight: 600, color: '#334155', margin: 0 }}>
                  Kelas / Jurusan
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
                  {isCustomClass ? 'Pilih Dropdown' : '+ Tambah Kustom'}
                </button>
              </div>

              {isCustomClass ? (
                <input
                  type="text"
                  className="au-input"
                  placeholder="Ketik kelas kustom (misal: XII Animasi 1)"
                  value={customClassText}
                  onChange={(e) => setCustomClassText(e.target.value)}
                  disabled={isSubmittingForm}
                  required
                  style={{
                    width: '100%',
                    height: '38px',
                    borderRadius: '6px',
                    border: '1px solid #e2e8f0',
                    padding: '0 12px',
                    fontSize: '13px',
                  }}
                />
              ) : (
                <select
                  value={formClass}
                  onChange={(e) => setFormClass(e.target.value)}
                  disabled={isSubmittingForm}
                  style={{
                    width: '100%',
                    height: '38px',
                    borderRadius: '6px',
                    border: '1px solid #e2e8f0',
                    padding: '0 10px',
                    fontSize: '13px',
                    color: '#334155',
                    background: '#ffffff',
                  }}
                >
                  {STANDARD_CLASS_OPTIONS.map((c) => (
                    <option key={c} value={c}>
                      {c}
                    </option>
                  ))}
                </select>
              )}
            </div>

            {/* Action Buttons */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setIsFormModalOpen(false)}
                disabled={isSubmittingForm}
              >
                Batal
              </button>
              <button
                type="submit"
                className="m-btn m-btn--primary"
                disabled={isSubmittingForm}
              >
                {isSubmittingForm ? (
                  <>
                    <i className="fa-solid fa-spinner fa-spin"></i> Menyimpan...
                  </>
                ) : editingStudent ? (
                  'Simpan Perubahan'
                ) : (
                  'Daftarkan Siswa'
                )}
              </button>
            </div>
          </form>
        </div>
      </AdminModalPortal>

      {/* MODAL 2: Form Impor Massal (CSV / Format Teks Sebaris) */}
      <AdminModalPortal
        isOpen={isBulkModalOpen}
        onClose={() => {
          if (!isSubmittingBulk) setIsBulkModalOpen(false);
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
                Impor Massal Siswa ke Buku Induk
              </h3>
              <span style={{ fontSize: '12px', color: '#64748b' }}>
                Format CSV atau baris per baris sekelas sekaligus
              </span>
            </div>
          </div>

          <p style={{ fontSize: '12.5px', color: '#64748b', marginBottom: '10px' }}>
            Tempel data siswa dengan format:{' '}
            <code style={{ background: '#f1f5f9', padding: '2px 5px', borderRadius: '4px', color: '#1e293b' }}>
              NIS, Nama Lengkap, Kelas
            </code>
          </p>

          <div style={{ marginBottom: '14px' }}>
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

          {parsedBulkRows.length > 0 && (
            <div
              style={{
                padding: '8px 12px',
                borderRadius: '6px',
                background: '#eff6ff',
                color: '#1d4ed8',
                fontSize: '12.5px',
                fontWeight: 600,
                marginBottom: '18px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <span>
                <i className="fa-solid fa-circle-check" style={{ marginRight: '6px' }}></i>
                Terdeteksi <b>{parsedBulkRows.length}</b> siswa siap diimpor.
              </span>
              <span style={{ fontSize: '11px', background: '#dbeafe', padding: '2px 8px', borderRadius: '10px' }}>
                Format Valid
              </span>
            </div>
          )}

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
            <button
              type="button"
              className="m-btn m-btn--ghost"
              onClick={() => setIsBulkModalOpen(false)}
              disabled={isSubmittingBulk}
            >
              Batal
            </button>
            <button
              type="button"
              className="m-btn m-btn--primary"
              disabled={isSubmittingBulk || parsedBulkRows.length === 0}
              onClick={handleSubmitBulk}
            >
              {isSubmittingBulk ? (
                <>
                  <i className="fa-solid fa-spinner fa-spin"></i> Mengimpor...
                </>
              ) : (
                `Impor ${parsedBulkRows.length} Siswa`
              )}
            </button>
          </div>
        </div>
      </AdminModalPortal>

      {/* MODAL 3: Konfirmasi Reset Status Klaim */}
      <AdminModalPortal
        isOpen={!!resetTarget}
        onClose={() => {
          if (!isResetting) setResetTarget(null);
        }}
      >
        {resetTarget && (
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
                  background: '#fef3c7',
                  color: '#d97706',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                  flexShrink: 0,
                }}
              >
                <i className="fa-solid fa-rotate-left"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#92400e' }}>
                  Reset Status Klaim Akun
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Izinkan siswa mendaftar ulang
                </span>
              </div>
            </div>

            <p style={{ fontSize: '13px', color: '#334155', marginBottom: '12px' }}>
              Lepas status klaim untuk NIS <b>{resetTarget.nis}</b> ({resetTarget.full_name})?
            </p>

            <div
              style={{
                padding: '10px 14px',
                borderRadius: '6px',
                background: '#fffbeb',
                border: '1px solid #fef3c7',
                color: '#92400e',
                fontSize: '12px',
                marginBottom: '20px',
              }}
            >
              Nomor NIS ini akan kembali berstatus <b>Tersedia</b> sehingga dapat dipilih kembali oleh siswa pada
              pendaftaran aplikasi sNaps.
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setResetTarget(null)}
                disabled={isResetting}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn"
                style={{ background: '#d97706', color: '#ffffff', border: 0 }}
                disabled={isResetting}
                onClick={handleConfirmReset}
              >
                {isResetting ? 'Memproses...' : 'Ya, Lepas Klaim'}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>

      {/* MODAL 4: Konfirmasi Hapus NIS */}
      <AdminModalPortal
        isOpen={!!deleteTarget}
        onClose={() => {
          if (!isDeleting) setDeleteTarget(null);
        }}
      >
        {deleteTarget && (
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
                  background: '#fee2e2',
                  color: '#dc2626',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                  flexShrink: 0,
                }}
              >
                <i className="fa-solid fa-trash-can"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#991b1b' }}>
                  Hapus NIS dari Buku Induk
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Tindakan ini tidak dapat dibatalkan
                </span>
              </div>
            </div>

            <p style={{ fontSize: '13px', color: '#334155', marginBottom: '12px' }}>
              Hapus NIS <b>{deleteTarget.nis}</b> ({deleteTarget.full_name}) dari daftar buku induk?
            </p>

            {deleteTarget.is_claimed && (
              <div
                style={{
                  padding: '10px 14px',
                  borderRadius: '6px',
                  background: '#fef2f2',
                  border: '1px solid #fee2e2',
                  color: '#991b1b',
                  fontSize: '12px',
                  marginBottom: '20px',
                }}
              >
                <strong>Peringatan:</strong> NIS ini sedang aktif digunakan oleh akun pengguna. Menghapus data ini
                akan menghilangkan catatan buku induk siswa tersebut.
              </div>
            )}

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setDeleteTarget(null)}
                disabled={isDeleting}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn m-btn--danger"
                disabled={isDeleting}
                onClick={handleConfirmDelete}
              >
                {isDeleting ? 'Menghapus...' : 'Ya, Hapus'}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>
    </div>
  );
}
