import React, { useState, useEffect, useMemo } from 'react';
import { adminService, type SchoolMeetingPointRow } from '../services/adminService';
import { AdminModalPortal } from '../components/AdminModalPortal';

export function MeetingPointsTab() {
  const [spots, setSpots] = useState<SchoolMeetingPointRow[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [floorFilter, setFloorFilter] = useState<number | 'all'>('all');
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Add / Edit Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSpot, setEditingSpot] = useState<SchoolMeetingPointRow | null>(null);
  const [deleteConfirmSpot, setDeleteConfirmSpot] = useState<SchoolMeetingPointRow | null>(null);

  // Form State
  const [floor, setFloor] = useState<number>(1);
  const [name, setName] = useState('');
  const [areaCategory, setAreaCategory] = useState('Kantin & Sosialisasi');
  const [description, setDescription] = useState('');
  const [coordX, setCoordX] = useState<number>(50);
  const [coordY, setCoordY] = useState<number>(50);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchSpots = async () => {
    setIsLoading(true);
    try {
      const data = await adminService.getMeetingPoints();
      setSpots(data);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat titik temu: ${e?.message || e}` });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSpots();
  }, []);

  const openAddModal = () => {
    setEditingSpot(null);
    setFloor(1);
    setName('');
    setAreaCategory('Kantin & Sosialisasi');
    setDescription('');
    setCoordX(50);
    setCoordY(50);
    setIsModalOpen(true);
  };

  const openEditModal = (spot: SchoolMeetingPointRow) => {
    setEditingSpot(spot);
    setFloor(spot.floor);
    setName(spot.name);
    setAreaCategory(spot.area_category);
    setDescription(spot.description || '');
    setCoordX(spot.coordinates_x || 50);
    setCoordY(spot.coordinates_y || 50);
    setIsModalOpen(true);
  };

  const handleToggleActive = async (id: string, currentStatus: boolean) => {
    try {
      await adminService.updateMeetingPoint(id, { is_active: !currentStatus });
      setSpots((prev) =>
        prev.map((s) => (s.id === id ? { ...s, is_active: !currentStatus } : s))
      );
      setFeedbackMsg({
        type: 'success',
        text: `Titik temu ${!currentStatus ? 'diaktifkan' : 'dinonaktifkan'}.`,
      });
      setTimeout(() => setFeedbackMsg(null), 3000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal mengubah status: ${e?.message || e}` });
    }
  };

  const handleDeleteSpot = async () => {
    if (!deleteConfirmSpot) return;
    const spotName = deleteConfirmSpot.name;
    try {
      await adminService.deleteMeetingPoint(deleteConfirmSpot.id);
      setSpots((prev) => prev.filter((s) => s.id !== deleteConfirmSpot.id));
      setFeedbackMsg({ type: 'success', text: `Spot "${spotName}" berhasil dihapus.` });
      setDeleteConfirmSpot(null);
      setTimeout(() => setFeedbackMsg(null), 3000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal menghapus: ${e?.message || e}` });
    }
  };

  const handleSubmitForm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;

    setIsSubmitting(true);
    try {
      if (editingSpot) {
        const updated = await adminService.updateMeetingPoint(editingSpot.id, {
          name: name.trim(),
          floor,
          area_category: areaCategory,
          description: description.trim(),
          coordinates_x: coordX,
          coordinates_y: coordY,
        });
        setSpots((prev) => prev.map((s) => (s.id === updated.id ? updated : s)));
        setFeedbackMsg({ type: 'success', text: `Spot "${updated.name}" berhasil diperbarui.` });
      } else {
        const created = await adminService.createMeetingPoint({
          name: name.trim(),
          floor,
          area_category: areaCategory,
          description: description.trim(),
          coordinates_x: coordX,
          coordinates_y: coordY,
          is_active: true,
        });
        setSpots((prev) => [created, ...prev]);
        setFeedbackMsg({ type: 'success', text: `Spot "${created.name}" berhasil ditambahkan.` });
      }
      setIsModalOpen(false);
      setTimeout(() => setFeedbackMsg(null), 3000);
    } catch (err: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal menyimpan spot: ${err?.message || err}` });
    } finally {
      setIsSubmitting(false);
    }
  };

  const filteredSpots = useMemo(() => {
    return spots.filter((spot) => {
      const matchSearch =
        spot.name.toLowerCase().includes(search.toLowerCase()) ||
        spot.area_category.toLowerCase().includes(search.toLowerCase()) ||
        (spot.description && spot.description.toLowerCase().includes(search.toLowerCase()));
      const matchFloor = floorFilter === 'all' || spot.floor === floorFilter;
      return matchSearch && matchFloor;
    });
  }, [spots, search, floorFilter]);

  return (
    <>
      {/* 1. Page Header (CoolAdmin Source of Truth) */}
      <div className="page-header">
        <div>
          <h1>Titik Temu COD Kampus</h1>
          <p className="subtitle">
            Daftar spot resmi yang diakui sekolah untuk serah terima transaksi COD siswa SMKN 8 Semarang.
          </p>
        </div>
        <div className="page-header__actions">
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={fetchSpots}
            disabled={isLoading}
            aria-label="Refresh spot COD"
          >
            <i className={`fa-solid fa-arrows-rotate ${isLoading ? 'fa-spin' : ''}`}></i>
            Segarkan
          </button>
          <button type="button" className="m-btn m-btn--primary" onClick={openAddModal}>
            <i className="fa-solid fa-plus"></i>
            Tambah Spot COD
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

      {/* 2. Main Meeting Points Table Card */}
      <section className="m-card">
        {/* Filter Bar Header */}
        <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            {/* Search Input */}
            <div style={{ position: 'relative', width: '260px' }}>
              <input
                type="text"
                className="au-input"
                placeholder="Cari nama spot, kategori..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
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

            {/* Filter Floor */}
            <select
              value={floorFilter}
              onChange={(e) =>
                setFloorFilter(e.target.value === 'all' ? 'all' : Number(e.target.value))
              }
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
              <option value="all">Semua Lantai Gedung</option>
              <option value="1">Lantai 1</option>
              <option value="2">Lantai 2</option>
              <option value="3">Lantai 3</option>
            </select>
          </div>

          <div style={{ fontSize: '12.5px', color: '#64748b' }}>
            Total: <b>{filteredSpots.length}</b> spot terdaftar
          </div>
        </header>

        {/* Data Table (CoolAdmin m-table) */}
        <div className="table-responsive">
          <table className="m-table">
            <thead>
              <tr>
                <th>Nama Titik Temu</th>
                <th>Kategori Area</th>
                <th>Lantai Gedung</th>
                <th>Status Spot</th>
                <th className="num">Aksi</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                    <i className="fa-solid fa-arrows-rotate fa-spin" style={{ marginRight: '8px' }}></i>
                    Memuat daftar spot COD...
                  </td>
                </tr>
              ) : filteredSpots.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                    Belum ada titik temu COD yang terdaftar.
                  </td>
                </tr>
              ) : (
                filteredSpots.map((spot) => (
                  <tr key={spot.id}>
                    <td>
                      <div className="row-product">
                        <div
                          className="row-product__icon"
                          style={{
                            background: spot.is_active ? '#e0f3f1' : '#f1f5f9',
                            color: spot.is_active ? '#11998e' : '#94a3b8',
                          }}
                        >
                          <i className="fa-solid fa-location-dot"></i>
                        </div>
                        <div>
                          <div style={{ fontWeight: 600, color: '#1f2937' }}>{spot.name}</div>
                          <div style={{ fontSize: '12px', color: '#64748b' }}>
                            {spot.description || 'Zona serah terima COD'}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span
                        style={{
                          display: 'inline-block',
                          padding: '2px 8px',
                          borderRadius: '4px',
                          fontSize: '11px',
                          fontWeight: 600,
                          background: '#eaf0fc',
                          color: '#4272d7',
                        }}
                      >
                        {spot.area_category}
                      </span>
                    </td>
                    <td style={{ fontSize: '13px', color: '#475569', fontWeight: 500 }}>
                      Lantai {spot.floor}
                    </td>
                    <td>
                      <button
                        type="button"
                        onClick={() => handleToggleActive(spot.id, spot.is_active)}
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '5px',
                          padding: '3px 8px',
                          borderRadius: '4px',
                          border: '1px solid',
                          fontSize: '11.5px',
                          fontWeight: 600,
                          cursor: 'pointer',
                          background: spot.is_active ? '#e0f3f1' : '#f8fafc',
                          borderColor: spot.is_active ? '#a7f3d0' : '#e2e8f0',
                          color: spot.is_active ? '#10b981' : '#94a3b8',
                        }}
                      >
                        <i
                          className={`fa-solid ${spot.is_active ? 'fa-circle-check' : 'fa-circle-xmark'}`}
                        ></i>
                        {spot.is_active ? 'Aktif' : 'Nonaktif'}
                      </button>
                    </td>
                    <td className="num">
                      <div className="table-data-feature">
                        {/* Edit Button */}
                        <button
                          type="button"
                          className="item"
                          title="Edit Spot"
                          onClick={() => openEditModal(spot)}
                          style={{ border: 0, cursor: 'pointer' }}
                        >
                          <i className="fa-solid fa-pen-to-square"></i>
                        </button>

                        {/* Delete Button */}
                        <button
                          type="button"
                          className="item"
                          title="Hapus Spot"
                          onClick={() => setDeleteConfirmSpot(spot)}
                          style={{ border: 0, cursor: 'pointer', color: '#dc3545' }}
                        >
                          <i className="fa-solid fa-trash-can"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </section>

      {/* Add / Edit Spot Modal */}
      <AdminModalPortal isOpen={isModalOpen} onClose={() => setIsModalOpen(false)}>
        <div
          style={{
            background: '#ffffff',
            borderRadius: '8px',
            padding: '24px',
            maxWidth: '480px',
            width: '100%',
            boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
          }}
        >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                marginBottom: '16px',
                paddingBottom: '12px',
                borderBottom: '1px solid #f1f3f5',
              }}
            >
              <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1f2937' }}>
                {editingSpot ? 'Edit Titik Temu COD' : 'Tambah Titik Temu COD'}
              </h3>
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                style={{ background: 'transparent', border: 0, color: '#94a3b8', cursor: 'pointer' }}
              >
                <i className="fa-solid fa-xmark"></i>
              </button>
            </div>

            <form onSubmit={handleSubmitForm} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#475569', marginBottom: '6px' }}>
                  Nama Titik Temu
                </label>
                <input
                  type="text"
                  required
                  placeholder="Contoh: Gazebo Depan Bengkel PPLG"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  style={{
                    width: '100%',
                    height: '38px',
                    borderRadius: '6px',
                    border: '1px solid #e4e7ec',
                    padding: '0 12px',
                    fontSize: '13px',
                  }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#475569', marginBottom: '6px' }}>
                    Lantai Gedung
                  </label>
                  <select
                    value={floor}
                    onChange={(e) => setFloor(Number(e.target.value))}
                    style={{
                      width: '100%',
                      height: '38px',
                      borderRadius: '6px',
                      border: '1px solid #e4e7ec',
                      padding: '0 10px',
                      fontSize: '13px',
                      background: '#ffffff',
                    }}
                  >
                    <option value={1}>Lantai 1</option>
                    <option value={2}>Lantai 2</option>
                    <option value={3}>Lantai 3</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#475569', marginBottom: '6px' }}>
                    Kategori Area
                  </label>
                  <select
                    value={areaCategory}
                    onChange={(e) => setAreaCategory(e.target.value)}
                    style={{
                      width: '100%',
                      height: '38px',
                      borderRadius: '6px',
                      border: '1px solid #e4e7ec',
                      padding: '0 10px',
                      fontSize: '13px',
                      background: '#ffffff',
                    }}
                  >
                    <option value="Kantin & Sosialisasi">Kantin & Sosialisasi</option>
                    <option value="Bengkel / Lab">Bengkel / Lab</option>
                    <option value="Lapangan & Selasar">Lapangan & Selasar</option>
                    <option value="Lobby Utama">Lobby Utama</option>
                    <option value="Perpustakaan">Perpustakaan</option>
                  </select>
                </div>
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '12.5px', fontWeight: 600, color: '#475569', marginBottom: '6px' }}>
                  Deskripsi / Petunjuk Arah
                </label>
                <textarea
                  rows={3}
                  placeholder="Petunjuk detail agar siswa mudah menemukan spot..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  style={{
                    width: '100%',
                    borderRadius: '6px',
                    border: '1px solid #e4e7ec',
                    padding: '8px 12px',
                    fontSize: '13px',
                    resize: 'none',
                  }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '10px' }}>
                <button
                  type="button"
                  className="m-btn m-btn--ghost"
                  onClick={() => setIsModalOpen(false)}
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="m-btn m-btn--primary"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Menyimpan...' : editingSpot ? 'Simpan Perubahan' : 'Tambah Spot'}
                </button>
              </div>
            </form>
          </div>
        </AdminModalPortal>

      {/* Confirmation Modal for Delete Spot */}
      <AdminModalPortal
        isOpen={!!deleteConfirmSpot}
        onClose={() => setDeleteConfirmSpot(null)}
      >
        {deleteConfirmSpot && (
          <div
            style={{
              background: '#ffffff',
              borderRadius: '8px',
              padding: '24px',
              maxWidth: '420px',
              width: '100%',
              boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div
                style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '50%',
                  background: '#fee2e2',
                  color: '#dc3545',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                }}
              >
                <i className="fa-solid fa-trash-can"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1f2937' }}>
                  Hapus Titik Temu COD
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Spot tidak akan muncul lagi di pemilih COD.
                </span>
              </div>
            </div>

            <p style={{ fontSize: '13.5px', color: '#475569', lineHeight: 1.5, margin: '0 0 20px' }}>
              Apakah Anda yakin ingin menghapus spot <b>"{deleteConfirmSpot.name}"</b>?
            </p>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setDeleteConfirmSpot(null)}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn m-btn--primary"
                style={{ background: '#dc3545', borderColor: '#dc3545' }}
                onClick={handleDeleteSpot}
              >
                Hapus Spot
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>
    </>
  );
}
