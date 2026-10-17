import React, { useState, useEffect, useCallback, useMemo } from 'react';
import {
  GraduationCap,
  UserPlus,
  UploadCloud,
  Search,
  CheckCircle2,
  Clock,
  Trash2,
  Edit2,
  RotateCcw,
  AlertTriangle,
  FileText,
  UserCheck,
  UserX,
  X,
} from 'lucide-react';
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
    <div className="tab-pane active" id="students-tab">
      {/* Alert Banner Feedback */}
      {feedbackMsg && (
        <div
          className={`alert ${feedbackMsg.type === 'success' ? 'alert-success' : 'alert-danger'} alert-dismissible fade show d-flex align-items-center mb-4`}
          role="alert"
        >
          {feedbackMsg.type === 'success' ? (
            <CheckCircle2 className="me-2" size={18} />
          ) : (
            <AlertTriangle className="me-2" size={18} />
          )}
          <span>{feedbackMsg.text}</span>
          <button
            type="button"
            className="btn-close ms-auto"
            onClick={() => setFeedbackMsg(null)}
          />
        </div>
      )}

      {/* Row Overview Stats Cards */}
      <div className="row m-t-25">
        <div className="col-sm-6 col-lg-4">
          <div className="overview-item overview-item--c1">
            <div className="overview__inner">
              <div className="overview-box clearfix">
                <div className="icon">
                  <GraduationCap size={44} />
                </div>
                <div className="text">
                  <h2>{stats.total.toLocaleString()}</h2>
                  <span>Total NIS di Buku Induk</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="col-sm-6 col-lg-4">
          <div className="overview-item overview-item--c2">
            <div className="overview__inner">
              <div className="overview-box clearfix">
                <div className="icon">
                  <UserCheck size={44} />
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
          <div className="overview-item overview-item--c3">
            <div className="overview__inner">
              <div className="overview-box clearfix">
                <div className="icon">
                  <UserX size={44} />
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

      {/* Action Header & Search Bar */}
      <div className="card shadow-sm border-0 mb-4" style={{ borderRadius: '16px' }}>
        <div className="card-body p-4">
          <div className="d-flex flex-wrap align-items-center justify-content-between gap-3">
            {/* Search Input */}
            <div className="d-flex align-items-center gap-2 flex-grow-1" style={{ maxWidth: '420px' }}>
              <div className="input-group">
                <span className="input-group-text bg-light border-0">
                  <Search size={16} className="text-muted" />
                </span>
                <input
                  type="text"
                  className="form-control bg-light border-0"
                  placeholder="Cari NIS atau Nama Siswa..."
                  value={search}
                  onChange={(e) => {
                    setSearch(e.target.value);
                    setPage(1);
                  }}
                />
                {search && (
                  <button
                    className="btn bg-light border-0 text-muted"
                    onClick={() => {
                      setSearch('');
                      setPage(1);
                    }}
                  >
                    <X size={14} />
                  </button>
                )}
              </div>
            </div>

            {/* Filter Controls */}
            <div className="d-flex align-items-center gap-2 flex-wrap">
              {/* Status Filter */}
              <select
                className="form-select bg-light border-0"
                style={{ width: 'auto' }}
                value={statusFilter}
                onChange={(e) => {
                  setStatusFilter(e.target.value as any);
                  setPage(1);
                }}
              >
                <option value="all">Semua Status Klaim</option>
                <option value="unclaimed">Belum Diklaim (Tersedia)</option>
                <option value="claimed">Sudah Diklaim</option>
              </select>

              {/* Class Group Filter */}
              <select
                className="form-select bg-light border-0"
                style={{ width: 'auto' }}
                value={classFilter}
                onChange={(e) => {
                  setClassFilter(e.target.value);
                  setPage(1);
                }}
              >
                <option value="all">Semua Kelas/Jurusan</option>
                {availableClassFilters.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>

              {/* Action Buttons */}
              <button
                className="btn btn-primary d-flex align-items-center gap-2"
                style={{ borderRadius: '10px' }}
                onClick={openAddModal}
              >
                <UserPlus size={16} />
                <span>Tambah Siswa</span>
              </button>

              <button
                className="btn btn-outline-secondary d-flex align-items-center gap-2"
                style={{ borderRadius: '10px' }}
                onClick={() => setIsBulkModalOpen(true)}
              >
                <UploadCloud size={16} />
                <span>Impor Massal</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Table Card */}
      <div className="card shadow-sm border-0" style={{ borderRadius: '16px' }}>
        <div className="card-header bg-white border-0 pt-4 px-4 pb-0 d-flex justify-content-between align-items-center">
          <h5 className="mb-0 fw-bold d-flex align-items-center gap-2">
            <GraduationCap size={20} className="text-primary" />
            <span>Daftar Master Data Siswa SMKN 8 Semarang</span>
          </h5>
          <span className="text-muted small">Total: {totalCount} Siswa</span>
        </div>

        <div className="card-body p-0">
          <div className="table-responsive">
            <table className="table table-hover align-middle mb-0">
              <thead className="table-light">
                <tr>
                  <th className="ps-4">NIS</th>
                  <th>Nama Lengkap Siswa</th>
                  <th>Kelas / Jurusan</th>
                  <th>Status Registrasi</th>
                  <th>Akun Tertaut (@username)</th>
                  <th className="text-end pe-4">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {isLoading ? (
                  <tr>
                    <td colSpan={6} className="text-center py-5 text-muted">
                      <div className="spinner-border spinner-border-sm text-primary me-2" role="status" />
                      <span>Memuat data buku induk...</span>
                    </td>
                  </tr>
                ) : students.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="text-center py-5 text-muted">
                      <FileText size={36} className="text-muted mb-2 d-block mx-auto" />
                      <span>Tidak ada data siswa yang cocok dengan kriteria pencarian.</span>
                    </td>
                  </tr>
                ) : (
                  students.map((student) => {
                    const profile = student.claimed_profile;
                    return (
                      <tr key={student.nis}>
                        {/* NIS */}
                        <td className="ps-4">
                          <span className="badge bg-light text-dark font-monospace px-2 py-1 border">
                            {student.nis}
                          </span>
                        </td>

                        {/* Nama */}
                        <td className="fw-semibold text-dark">{student.full_name}</td>

                        {/* Kelas / Jurusan */}
                        <td>
                          <span className="badge bg-secondary-subtle text-secondary px-2 py-1">
                            {student.class_group}
                          </span>
                        </td>

                        {/* Status Klaim */}
                        <td>
                          {student.is_claimed ? (
                            <span className="badge bg-success-subtle text-success d-inline-flex align-items-center gap-1 px-2 py-1">
                              <CheckCircle2 size={13} />
                              <span>Sudah Diklaim</span>
                            </span>
                          ) : (
                            <span className="badge bg-warning-subtle text-warning d-inline-flex align-items-center gap-1 px-2 py-1">
                              <Clock size={13} />
                              <span>Tersedia untuk Daftar</span>
                            </span>
                          )}
                        </td>

                        {/* Akun Tertaut */}
                        <td>
                          {student.is_claimed ? (
                            profile ? (
                              <div className="d-flex align-items-center gap-2">
                                <span className="fw-semibold text-primary">@{profile.username}</span>
                                {profile.is_verified && (
                                  <span className="badge bg-primary-subtle text-primary" style={{ fontSize: '10px' }}>
                                    Verified
                                  </span>
                                )}
                              </div>
                            ) : (
                              <span className="text-muted small">
                                {student.claimed_by ? `ID: ${student.claimed_by.substring(0, 8)}...` : 'Terdaftar'}
                              </span>
                            )
                          ) : (
                            <span className="text-muted small italic">- Belum ada akun -</span>
                          )}
                        </td>

                        {/* Aksi */}
                        <td className="text-end pe-4">
                          <div className="d-inline-flex align-items-center gap-1">
                            {/* Tombol Edit */}
                            <AdminTooltip content="Ubah Nama/Kelas">
                              <button
                                className="btn btn-sm btn-outline-primary"
                                style={{ borderRadius: '8px' }}
                                onClick={() => openEditModal(student)}
                              >
                                <Edit2 size={14} />
                              </button>
                            </AdminTooltip>

                            {/* Tombol Reset Klaim (hanya jika sudah diklaim) */}
                            {student.is_claimed && (
                              <AdminTooltip content="Reset Status Klaim (Izinkan Siswa Daftar Ulang)">
                                <button
                                  className="btn btn-sm btn-outline-warning"
                                  style={{ borderRadius: '8px' }}
                                  onClick={() => setResetTarget(student)}
                                >
                                  <RotateCcw size={14} />
                                </button>
                              </AdminTooltip>
                            )}

                            {/* Tombol Hapus NIS */}
                            <AdminTooltip content="Hapus NIS dari Buku Induk">
                              <button
                                className="btn btn-sm btn-outline-danger"
                                style={{ borderRadius: '8px' }}
                                onClick={() => setDeleteTarget(student)}
                              >
                                <Trash2 size={14} />
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

          {/* Pagination Controls */}
          {totalCount > pageSize && (
            <div className="card-footer bg-white border-0 py-3 px-4 d-flex justify-content-between align-items-center">
              <span className="small text-muted">
                Menampilkan {(page - 1) * pageSize + 1} -{' '}
                {Math.min(page * pageSize, totalCount)} dari {totalCount} siswa
              </span>
              <div className="btn-group">
                <button
                  className="btn btn-sm btn-outline-secondary"
                  disabled={page <= 1}
                  onClick={() => setPage((p) => Math.max(1, p - 1))}
                >
                  Sebelumnya
                </button>
                <button className="btn btn-sm btn-outline-secondary disabled">
                  Halaman {page} dari {Math.ceil(totalCount / pageSize)}
                </button>
                <button
                  className="btn btn-sm btn-outline-secondary"
                  disabled={page >= Math.ceil(totalCount / pageSize)}
                  onClick={() => setPage((p) => p + 1)}
                >
                  Berikutnya
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* MODAL 1: Form Tambah / Edit Siswa Satuan */}
      {isFormModalOpen && (
        <AdminModalPortal isOpen={isFormModalOpen} onClose={() => setIsFormModalOpen(false)}>
          <div className="modal fade show d-block" tabIndex={-1} style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content border-0 shadow-lg" style={{ borderRadius: '16px' }}>
                <form onSubmit={handleSubmitForm}>
                  <div className="modal-header border-0 pb-0">
                    <h5 className="modal-title fw-bold">
                      {editingStudent ? 'Ubah Data Siswa di Buku Induk' : 'Tambah Siswa ke Buku Induk'}
                    </h5>
                    <button
                      type="button"
                      className="btn-close"
                      onClick={() => setIsFormModalOpen(false)}
                      disabled={isSubmittingForm}
                    />
                  </div>

                  <div className="modal-body p-4">
                    {/* NIS Input */}
                    <div className="mb-3">
                      <label className="form-label small fw-semibold text-muted">Nomor Induk Siswa (NIS)</label>
                      <input
                        type="text"
                        className="form-control font-monospace"
                        placeholder="Contoh: 11816"
                        value={formNis}
                        onChange={(e) => setFormNis(e.target.value)}
                        disabled={!!editingStudent || isSubmittingForm}
                        required
                      />
                      {editingStudent && (
                        <div className="form-text small text-muted">
                          Nomor NIS terkunci saat mode ubah untuk menjaga integritas data akun.
                        </div>
                      )}
                    </div>

                    {/* Nama Lengkap Input */}
                    <div className="mb-3">
                      <label className="form-label small fw-semibold text-muted">Nama Lengkap Siswa</label>
                      <input
                        type="text"
                        className="form-control"
                        placeholder="Contoh: Aida Dwi Riana Putri"
                        value={formName}
                        onChange={(e) => setFormName(e.target.value)}
                        disabled={isSubmittingForm}
                        required
                      />
                    </div>

                    {/* Kelas / Jurusan Selection (Dropdown + Opsi Custom) */}
                    <div className="mb-3">
                      <div className="d-flex justify-content-between align-items-center mb-1">
                        <label className="form-label small fw-semibold text-muted mb-0">Kelas / Jurusan</label>
                        <button
                          type="button"
                          className="btn btn-link btn-sm text-decoration-none p-0"
                          onClick={() => setIsCustomClass(!isCustomClass)}
                        >
                          {isCustomClass ? 'Pilih dari Dropdown' : '+ Tambah Kustom'}
                        </button>
                      </div>

                      {isCustomClass ? (
                        <input
                          type="text"
                          className="form-control"
                          placeholder="Ketik nama kelas kustom (misal: XII Animasi 1)"
                          value={customClassText}
                          onChange={(e) => setCustomClassText(e.target.value)}
                          disabled={isSubmittingForm}
                          required
                        />
                      ) : (
                        <select
                          className="form-select"
                          value={formClass}
                          onChange={(e) => setFormClass(e.target.value)}
                          disabled={isSubmittingForm}
                        >
                          {STANDARD_CLASS_OPTIONS.map((c) => (
                            <option key={c} value={c}>
                              {c}
                            </option>
                          ))}
                        </select>
                      )}
                    </div>
                  </div>

                  <div className="modal-footer border-0 pt-0">
                    <button
                      type="button"
                      className="btn btn-light"
                      onClick={() => setIsFormModalOpen(false)}
                      disabled={isSubmittingForm}
                    >
                      Batal
                    </button>
                    <button type="submit" className="btn btn-primary" disabled={isSubmittingForm}>
                      {isSubmittingForm ? 'Menyimpan...' : editingStudent ? 'Simpan Perubahan' : 'Daftarkan Siswa'}
                    </button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </AdminModalPortal>
      )}

      {/* MODAL 2: Form Impor Massal (CSV / Format Teks Sebaris) */}
      {isBulkModalOpen && (
        <AdminModalPortal isOpen={isBulkModalOpen} onClose={() => setIsBulkModalOpen(false)}>
          <div className="modal fade show d-block" tabIndex={-1} style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
            <div className="modal-dialog modal-dialog-centered modal-lg">
              <div className="modal-content border-0 shadow-lg" style={{ borderRadius: '16px' }}>
                <div className="modal-header border-0 pb-0">
                  <h5 className="modal-title fw-bold d-flex align-items-center gap-2">
                    <UploadCloud size={20} className="text-primary" />
                    <span>Impor Massal Siswa ke Buku Induk</span>
                  </h5>
                  <button
                    type="button"
                    className="btn-close"
                    onClick={() => setIsBulkModalOpen(false)}
                    disabled={isSubmittingBulk}
                  />
                </div>

                <div className="modal-body p-4">
                  <p className="small text-muted mb-2">
                    Tempel daftar siswa sekelas dengan format CSV atau baris per baris:{' '}
                    <code>NIS, Nama Lengkap, Kelas</code> (pisahkan dengan koma atau tab).
                  </p>

                  <div className="mb-3">
                    <textarea
                      className="form-control font-monospace"
                      rows={8}
                      placeholder={`11816, AIDA DWI RIANA PUTRI, XI PPLG 2\n11817, ALAIS LUTFI NAFISAH, XI PPLG 2\n11818, ALFIAN DZAKY RAMADHAN, XI PPLG 2`}
                      value={bulkText}
                      onChange={(e) => setBulkText(e.target.value)}
                      disabled={isSubmittingBulk}
                    />
                  </div>

                  {/* Preview Parsed Count */}
                  {parsedBulkRows.length > 0 && (
                    <div className="alert alert-info py-2 px-3 small d-flex justify-content-between align-items-center mb-0">
                      <span>
                        Terdeteksi <strong>{parsedBulkRows.length}</strong> baris data siswa valid siap diimpor.
                      </span>
                      <span className="badge bg-primary">Siap</span>
                    </div>
                  )}
                </div>

                <div className="modal-footer border-0 pt-0">
                  <button
                    type="button"
                    className="btn btn-light"
                    onClick={() => setIsBulkModalOpen(false)}
                    disabled={isSubmittingBulk}
                  >
                    Batal
                  </button>
                  <button
                    type="button"
                    className="btn btn-primary"
                    disabled={isSubmittingBulk || parsedBulkRows.length === 0}
                    onClick={handleSubmitBulk}
                  >
                    {isSubmittingBulk ? 'Mengimpor...' : `Impor ${parsedBulkRows.length} Siswa`}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </AdminModalPortal>
      )}

      {/* MODAL 3: Konfirmasi Reset Status Klaim */}
      {resetTarget && (
        <AdminModalPortal isOpen={!!resetTarget} onClose={() => setResetTarget(null)}>
          <div className="modal fade show d-block" tabIndex={-1} style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content border-0 shadow-lg" style={{ borderRadius: '16px' }}>
                <div className="modal-header border-0 pb-0">
                  <h5 className="modal-title fw-bold text-warning d-flex align-items-center gap-2">
                    <RotateCcw size={20} />
                    <span>Reset Status Klaim Akun</span>
                  </h5>
                  <button
                    type="button"
                    className="btn-close"
                    onClick={() => setResetTarget(null)}
                    disabled={isResetting}
                  />
                </div>

                <div className="modal-body p-4">
                  <p className="mb-2">
                    Apakah Anda yakin ingin melepas klaim untuk NIS <strong>{resetTarget.nis}</strong> (
                    {resetTarget.full_name})?
                  </p>
                  <div className="alert alert-warning small mb-0">
                    Setelah klaim dilepas, nomor NIS ini akan kembali berstatus <strong>Tersedia</strong> sehingga
                    dapat dipilih kembali oleh siswa pada alur registrasi aplikasi.
                  </div>
                </div>

                <div className="modal-footer border-0 pt-0">
                  <button
                    type="button"
                    className="btn btn-light"
                    onClick={() => setResetTarget(null)}
                    disabled={isResetting}
                  >
                    Batal
                  </button>
                  <button
                    type="button"
                    className="btn btn-warning"
                    disabled={isResetting}
                    onClick={handleConfirmReset}
                  >
                    {isResetting ? 'Memproses...' : 'Ya, Lepas Klaim'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </AdminModalPortal>
      )}

      {/* MODAL 4: Konfirmasi Hapus NIS */}
      {deleteTarget && (
        <AdminModalPortal isOpen={!!deleteTarget} onClose={() => setDeleteTarget(null)}>
          <div className="modal fade show d-block" tabIndex={-1} style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}>
            <div className="modal-dialog modal-dialog-centered">
              <div className="modal-content border-0 shadow-lg" style={{ borderRadius: '16px' }}>
                <div className="modal-header border-0 pb-0">
                  <h5 className="modal-title fw-bold text-danger d-flex align-items-center gap-2">
                    <Trash2 size={20} />
                    <span>Hapus Siswa dari Buku Induk</span>
                  </h5>
                  <button
                    type="button"
                    className="btn-close"
                    onClick={() => setDeleteTarget(null)}
                    disabled={isDeleting}
                  />
                </div>

                <div className="modal-body p-4">
                  <p className="mb-2">
                    Hapus NIS <strong>{deleteTarget.nis}</strong> ({deleteTarget.full_name}) dari master buku induk?
                  </p>
                  {deleteTarget.is_claimed && (
                    <div className="alert alert-danger small mb-0">
                      <strong>Peringatan:</strong> NIS ini saat ini sedang aktif digunakan oleh akun pengguna.
                      Menghapus data ini akan menghilangkan referensi buku induk siswa tersebut.
                    </div>
                  )}
                </div>

                <div className="modal-footer border-0 pt-0">
                  <button
                    type="button"
                    className="btn btn-light"
                    onClick={() => setDeleteTarget(null)}
                    disabled={isDeleting}
                  >
                    Batal
                  </button>
                  <button
                    type="button"
                    className="btn btn-danger"
                    disabled={isDeleting}
                    onClick={handleConfirmDelete}
                  >
                    {isDeleting ? 'Menghapus...' : 'Ya, Hapus'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </AdminModalPortal>
      )}
    </div>
  );
}
