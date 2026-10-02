import React, { useState, useEffect, useMemo } from 'react';
import {
  Plus,
  MapPin,
  Trash2,
  CheckCircle2,
  RefreshCw,
  Edit2,
  X,
  Search,
  Building,
} from 'lucide-react';
import { adminService, type SchoolMeetingPointRow } from '../services/adminService';

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
        text: `Titik temu ${!currentStatus ? 'diaktifkan' : 'dinonaktifkan'}`,
      });
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
      setFeedbackMsg({ type: 'success', text: `Spot "${spotName}" berhasil dihapus` });
      setDeleteConfirmSpot(null);
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
          description: description.trim() || undefined,
          coordinates_x: coordX,
          coordinates_y: coordY,
        });
        setSpots((prev) => prev.map((s) => (s.id === editingSpot.id ? updated : s)));
        setFeedbackMsg({ type: 'success', text: 'Titik temu berhasil diperbarui' });
      } else {
        const created = await adminService.createMeetingPoint({
          name: name.trim(),
          floor,
          area_category: areaCategory,
          description: description.trim() || undefined,
          coordinates_x: coordX,
          coordinates_y: coordY,
          is_active: true,
        });
        setSpots((prev) => [...prev, created]);
        setFeedbackMsg({ type: 'success', text: 'Titik temu baru berhasil ditambahkan' });
      }
      setIsModalOpen(false);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal menyimpan: ${e?.message || e}` });
    } finally {
      setIsSubmitting(false);
    }
  };

  const filteredSpots = useMemo(() => {
    return spots.filter((s) => {
      const matchSearch =
        s.name.toLowerCase().includes(search.toLowerCase()) ||
        s.area_category.toLowerCase().includes(search.toLowerCase()) ||
        (s.description && s.description.toLowerCase().includes(search.toLowerCase()));
      const matchFloor = floorFilter === 'all' || s.floor === floorFilter;
      return matchSearch && matchFloor;
    });
  }, [spots, search, floorFilter]);

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* 1. Header Toolbar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-base font-bold text-slate-900 tracking-tight">
            Titik Temu COD Kampus SMKN 8
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Daftar spot resmi yang diakui sekolah untuk serah terima transaksi COD siswa
          </p>
        </div>

        <div className="flex items-center gap-2.5 self-start sm:self-auto">
          <button
            onClick={fetchSpots}
            disabled={isLoading}
            className="flex items-center gap-1.5 h-8.5 px-3 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-700 hover:bg-slate-50 transition-colors shadow-2xs cursor-pointer"
          >
            <RefreshCw className={`h-3.5 w-3.5 text-[#3D38F5] ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
          <button
            onClick={openAddModal}
            className="flex items-center gap-1.5 h-8.5 px-3.5 rounded-xl bg-[#3D38F5] hover:bg-[#312BD9] text-xs font-semibold text-white transition-all shadow-[0_2px_8px_rgba(61,56,245,0.25)] cursor-pointer"
          >
            <Plus className="h-4 w-4" />
            <span>Tambah Spot COD</span>
          </button>
        </div>
      </div>

      {/* 2. Notification Toast */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border text-xs flex items-center justify-between transition-all ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-rose-50 text-rose-800 border-rose-200'
          }`}
        >
          <div className="flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
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

      {/* 3. Search & Floor Filter */}
      <div className="p-4 border border-slate-200/80 bg-white rounded-2xl shadow-[0_1px_3px_rgba(0,0,0,0.03)] flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <input
            type="text"
            placeholder="Cari nama spot, bengkel, kantin..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full h-9.5 pl-10 pr-4 rounded-xl border border-slate-200 bg-slate-50/60 text-xs text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-[#3D38F5] focus:ring-2 focus:ring-[#3D38F5]/10 outline-none transition-all"
          />
        </div>

        {/* Floor Segmented Control */}
        <div className="flex items-center gap-1.5 p-1 rounded-xl bg-slate-100 border border-slate-200/60 overflow-x-auto">
          {(
            [
              { id: 'all', label: 'Semua Lantai' },
              { id: 1, label: 'Lantai 1' },
              { id: 2, label: 'Lantai 2' },
              { id: 3, label: 'Lantai 3' },
            ] as const
          ).map((f) => (
            <button
              key={f.id}
              onClick={() => setFloorFilter(f.id)}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer whitespace-nowrap ${
                floorFilter === f.id
                  ? 'bg-white text-slate-900 shadow-2xs'
                  : 'text-slate-500 hover:text-slate-900'
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* 4. Spot Card Grid */}
      {isLoading ? (
        <div className="py-20 text-center text-slate-400">
          <RefreshCw className="h-6 w-6 animate-spin text-[#3D38F5] mx-auto mb-2" />
          <span className="text-xs">Memuat titik temu COD...</span>
        </div>
      ) : filteredSpots.length === 0 ? (
        <div className="p-16 border border-slate-200/80 bg-white rounded-2xl text-center space-y-2">
          <p className="font-semibold text-slate-800 text-sm">Tidak ada titik temu ditemukan</p>
          <p className="text-xs text-slate-400">Gunakan tombol "Tambah Spot COD" untuk membuat lokasi baru.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4.5">
          {filteredSpots.map((spot) => (
            <div
              key={spot.id}
              className={`p-5 rounded-2xl border transition-all flex flex-col justify-between ${
                spot.is_active
                  ? 'border-slate-200/80 bg-white shadow-[0_1px_3px_rgba(0,0,0,0.03)] hover:shadow-[0_4px_16px_rgba(0,0,0,0.05)]'
                  : 'border-slate-200 bg-slate-50/60 opacity-60'
              }`}
            >
              <div>
                <div className="flex items-center justify-between pb-3 border-b border-slate-100">
                  <div className="flex items-center gap-2.5">
                    <div
                      className={`h-9 w-9 rounded-xl flex items-center justify-center shrink-0 border ${
                        spot.is_active
                          ? 'bg-[#EEF0FF] text-[#3D38F5] border-[#D8DBFE]'
                          : 'bg-slate-100 text-slate-400 border-slate-200'
                      }`}
                    >
                      <MapPin className="h-4.5 w-4.5" />
                    </div>
                    <div>
                      <h3 className="text-sm font-bold text-slate-900 line-clamp-1">{spot.name}</h3>
                      <p className="text-[11px] text-slate-400 font-medium">Lantai {spot.floor}</p>
                    </div>
                  </div>

                  <span
                    className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider border ${
                      spot.is_active
                        ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                        : 'bg-slate-100 text-slate-500 border-slate-200'
                    }`}
                  >
                    <span className={`h-1.5 w-1.5 rounded-full ${spot.is_active ? 'bg-emerald-500' : 'bg-slate-400'}`} />
                    {spot.is_active ? 'Aktif' : 'Nonaktif'}
                  </span>
                </div>

                <div className="py-3.5 space-y-1.5 text-xs text-slate-600">
                  <div className="flex items-center gap-1.5 text-[11px] text-slate-400 font-semibold uppercase tracking-wider">
                    <Building className="h-3 w-3" />
                    <span>{spot.area_category}</span>
                  </div>
                  <p className="text-xs text-slate-600 line-clamp-2 leading-relaxed">
                    {spot.description || 'Tidak ada deskripsi patokan area.'}
                  </p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="pt-3 border-t border-slate-100 flex items-center justify-between gap-2">
                <button
                  onClick={() => handleToggleActive(spot.id, spot.is_active)}
                  className={`text-xs font-semibold px-2.5 py-1 rounded-lg border transition-colors cursor-pointer ${
                    spot.is_active
                      ? 'border-slate-200 text-slate-600 hover:bg-slate-100'
                      : 'border-emerald-200 text-emerald-700 bg-emerald-50 hover:bg-emerald-100'
                  }`}
                >
                  {spot.is_active ? 'Nonaktifkan' : 'Aktifkan'}
                </button>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => openEditModal(spot)}
                    className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
                    title="Edit Spot"
                  >
                    <Edit2 className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => setDeleteConfirmSpot(spot)}
                    className="p-1.5 rounded-lg text-rose-400 hover:text-rose-700 hover:bg-rose-50 transition-colors cursor-pointer"
                    title="Hapus Spot"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* 5. Add / Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-60 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 space-y-5 shadow-2xl border border-slate-200 animate-in fade-in zoom-in-95">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="text-base font-bold text-slate-900">
                {editingSpot ? 'Edit Titik Temu COD' : 'Tambah Titik Temu COD Baru'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <form onSubmit={handleSubmitForm} className="space-y-4 text-xs">
              <div>
                <label className="block font-semibold text-slate-700 mb-1">Nama Spot / Lokasi</label>
                <input
                  type="text"
                  required
                  placeholder="Contoh: Depan Bengkel PPLG Lt. 2"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full h-9.5 px-3 rounded-xl border border-slate-200 text-xs text-slate-900 outline-none focus:border-[#3D38F5]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-slate-700 mb-1">Lantai</label>
                  <select
                    value={floor}
                    onChange={(e) => setFloor(Number(e.target.value))}
                    className="w-full h-9.5 px-3 rounded-xl border border-slate-200 text-xs text-slate-900 outline-none focus:border-[#3D38F5] bg-white cursor-pointer"
                  >
                    <option value={1}>Lantai 1</option>
                    <option value={2}>Lantai 2</option>
                    <option value={3}>Lantai 3</option>
                  </select>
                </div>

                <div>
                  <label className="block font-semibold text-slate-700 mb-1">Kategori Area</label>
                  <select
                    value={areaCategory}
                    onChange={(e) => setAreaCategory(e.target.value)}
                    className="w-full h-9.5 px-3 rounded-xl border border-slate-200 text-xs text-slate-900 outline-none focus:border-[#3D38F5] bg-white cursor-pointer"
                  >
                    <option value="Kantin & Sosialisasi">Kantin & Sosialisasi</option>
                    <option value="Laboratorium & Bengkel">Lab & Bengkel PPLG/DKV</option>
                    <option value="Ruang Kelas & Koridor">Ruang Kelas & Koridor</option>
                    <option value="Area Terbuka & Lapangan">Lapangan & Gerbang</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">Patokan / Catatan Lokasi</label>
                <textarea
                  rows={2}
                  placeholder="Deskripsi patokan agar siswa mudah bertemu..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full p-3 rounded-xl border border-slate-200 text-xs text-slate-900 outline-none focus:border-[#3D38F5]"
                />
              </div>

              <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-3.5 py-2 rounded-xl font-semibold text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="px-4 py-2 rounded-xl font-semibold bg-[#3D38F5] hover:bg-[#312BD9] text-white transition-colors cursor-pointer shadow-xs disabled:opacity-50"
                >
                  {isSubmitting ? 'Menyimpan...' : editingSpot ? 'Simpan Perubahan' : 'Tambah Spot'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* 6. Delete Confirmation Modal */}
      {deleteConfirmSpot && (
        <div className="fixed inset-0 z-60 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 space-y-4 shadow-2xl border border-slate-200 animate-in fade-in zoom-in-95">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-rose-50 border border-rose-200 flex items-center justify-center text-rose-600 shrink-0">
                <Trash2 className="h-5 w-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-slate-900">Hapus Titik Temu</h3>
                <p className="text-xs text-slate-500">Spot ini tidak akan muncul lagi di pemilih titik COD mobile.</p>
              </div>
            </div>

            <p className="text-xs text-slate-600 leading-relaxed">
              Yakin ingin menghapus titik temu <strong className="text-slate-900">"{deleteConfirmSpot.name}"</strong>?
            </p>

            <div className="flex items-center justify-end gap-2 pt-2">
              <button
                onClick={() => setDeleteConfirmSpot(null)}
                className="px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                Batal
              </button>
              <button
                onClick={handleDeleteSpot}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-rose-600 hover:bg-rose-700 text-white transition-colors cursor-pointer shadow-xs"
              >
                Hapus Spot
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
