import React, { useState, useEffect, useMemo } from 'react';
import {
  Plus,
  MapPin,
  Trash2,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  Edit2,
  X,
  Search,
  Building,
  Compass,
} from 'lucide-react';
import { Button, Input, LayerCard } from '@cloudflare/kumo';
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
      setFeedbackMsg({ type: 'error', text: `Gagal menghapus spot: ${e?.message || e}` });
    }
  };

  const handleSaveSpot = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    setIsSubmitting(true);

    try {
      if (editingSpot) {
        // Edit existing spot
        const updated = await adminService.updateMeetingPoint(editingSpot.id, {
          floor,
          name: name.trim(),
          area_category: areaCategory,
          description: description.trim() || null,
          coordinates_x: coordX,
          coordinates_y: coordY,
        });
        setSpots((prev) => prev.map((s) => (s.id === editingSpot.id ? updated : s)));
        setFeedbackMsg({ type: 'success', text: `Titik temu "${name}" berhasil diperbarui!` });
      } else {
        // Create new spot
        const newSpot = await adminService.createMeetingPoint({
          floor,
          name: name.trim(),
          area_category: areaCategory,
          description: description.trim() || null,
          coordinates_x: coordX,
          coordinates_y: coordY,
          is_active: true,
        });
        setSpots((prev) => [...prev, newSpot]);
        setFeedbackMsg({ type: 'success', text: 'Titik temu COD baru berhasil ditambahkan!' });
      }

      setIsModalOpen(false);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal menyimpan spot: ${e?.message || e}` });
    } finally {
      setIsSubmitting(false);
    }
  };

  // Filtered spots based on floor and search
  const filteredSpots = useMemo(() => {
    return spots.filter((s) => {
      const matchFloor = floorFilter === 'all' || s.floor === floorFilter;
      const matchSearch =
        search.trim() === '' ||
        s.name.toLowerCase().includes(search.toLowerCase()) ||
        s.area_category.toLowerCase().includes(search.toLowerCase()) ||
        (s.description && s.description.toLowerCase().includes(search.toLowerCase()));
      return matchFloor && matchSearch;
    });
  }, [spots, floorFilter, search]);

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

      {/* Control Bar: Search, Floor Chips & Add Button */}
      <LayerCard className="p-4 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs space-y-3.5">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="w-full sm:w-80 relative">
            <Input
              placeholder="Cari spot atau petunjuk arah..."
              value={search}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearch(e.target.value)}
              className="w-full text-xs pr-8"
            />
            {search ? (
              <button
                onClick={() => setSearch('')}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 p-0.5 rounded-full hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default cursor-pointer"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            ) : (
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-kumo-subtle pointer-events-none" />
            )}
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto justify-end">
            <Button
              variant="secondary"
              className="h-8 px-2.5 text-xs flex items-center gap-1.5"
              onClick={fetchSpots}
              disabled={isLoading}
            >
              <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin' : ''}`} />
              <span className="hidden sm:inline">Refresh</span>
            </Button>

            <Button
              variant="primary"
              className="h-8 px-3 text-xs flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold"
              onClick={openAddModal}
            >
              <Plus className="h-3.5 w-3.5" />
              <span>Tambah Titik Temu</span>
            </Button>
          </div>
        </div>

        {/* Floor Filter Chips */}
        <div className="flex items-center gap-1.5 overflow-x-auto pt-1 pb-0.5 text-xs border-t border-kumo-hairline/60">
          <span className="text-kumo-subtle text-[11px] font-semibold shrink-0">Filter Lantai:</span>
          
          <button
            onClick={() => setFloorFilter('all')}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 ${
              floorFilter === 'all'
                ? 'bg-indigo-600 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            Semua Lantai ({spots.length})
          </button>

          {[1, 2, 3, 4].map((fl) => {
            const count = spots.filter((s) => s.floor === fl).length;
            return (
              <button
                key={fl}
                onClick={() => setFloorFilter(fl)}
                className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 flex items-center gap-1 ${
                  floorFilter === fl
                    ? 'bg-indigo-600 text-white shadow-xs'
                    : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
                }`}
              >
                <Building className="h-3 w-3" />
                <span>Lantai {fl} ({count})</span>
              </button>
            );
          })}
        </div>
      </LayerCard>

      {/* Spots Grid / Table */}
      <LayerCard className="border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs overflow-hidden">
        <div className="px-5 py-3.5 border-b border-kumo-hairline flex items-center justify-between bg-kumo-control/40">
          <div className="text-xs font-semibold text-kumo-default flex items-center gap-2">
            <span>Daftar Titik Temu COD ({filteredSpots.length})</span>
          </div>
          <div className="text-[11px] text-kumo-subtle">
            Tersinkronisasi langsung dengan dropdown COD di aplikasi mobile
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-kumo-hairline bg-kumo-canvas text-kumo-subtle font-semibold">
                <th className="py-3 px-4">Lantai</th>
                <th className="py-3 px-4">Nama Titik Temu</th>
                <th className="py-3 px-4">Kategori Area</th>
                <th className="py-3 px-4">Deskripsi Petunjuk</th>
                <th className="py-3 px-4">Koordinat</th>
                <th className="py-3 px-4 text-center">Status</th>
                <th className="py-3 px-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-kumo-hairline">
              {isLoading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <tr key={i} className="animate-pulse">
                    <td className="py-3 px-4"><div className="h-4 w-12 rounded bg-kumo-control" /></td>
                    <td className="py-3 px-4"><div className="h-4 w-32 rounded bg-kumo-control" /></td>
                    <td className="py-3 px-4"><div className="h-4 w-24 rounded bg-kumo-control" /></td>
                    <td className="py-3 px-4"><div className="h-4 w-48 rounded bg-kumo-control" /></td>
                    <td className="py-3 px-4"><div className="h-4 w-16 rounded bg-kumo-control" /></td>
                    <td className="py-3 px-4 text-center"><div className="h-5 w-12 rounded bg-kumo-control mx-auto" /></td>
                    <td className="py-3 px-4 text-right"><div className="h-6 w-16 rounded bg-kumo-control ml-auto" /></td>
                  </tr>
                ))
              ) : filteredSpots.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-kumo-subtle">
                    Tidak ada titik temu pada filter ini.
                  </td>
                </tr>
              ) : (
                filteredSpots.map((spot) => (
                  <tr key={spot.id} className="hover:bg-kumo-tint/50 transition-colors">
                    <td className="py-3 px-4 font-bold text-kumo-default">
                      <span className="rounded bg-indigo-50 px-2 py-0.5 text-indigo-700 border border-indigo-200 text-[10px]">
                        Lt {spot.floor}
                      </span>
                    </td>
                    <td className="py-3 px-4 font-semibold text-kumo-default">
                      <div className="flex items-center gap-1.5">
                        <MapPin className="h-3.5 w-3.5 text-indigo-600 shrink-0" />
                        <span>{spot.name}</span>
                      </div>
                    </td>
                    <td className="py-3 px-4 text-kumo-default">
                      <span className="text-[11px] font-medium text-kumo-subtle">
                        {spot.area_category}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-kumo-subtle max-w-xs truncate">
                      {spot.description || '-'}
                    </td>
                    <td className="py-3 px-4 font-mono text-[11px] text-kumo-subtle">
                      <span className="flex items-center gap-1">
                        <Compass className="h-3 w-3" />
                        X:{spot.coordinates_x}% Y:{spot.coordinates_y}%
                      </span>
                    </td>
                    <td className="py-3 px-4 text-center">
                      <button
                        onClick={() => handleToggleActive(spot.id, spot.is_active)}
                        className={`text-[10px] font-bold px-2 py-0.5 rounded-full cursor-pointer transition-colors ${
                          spot.is_active
                            ? 'bg-emerald-100 text-emerald-800 border border-emerald-200'
                            : 'bg-slate-100 text-slate-600 border border-slate-200'
                        }`}
                        title="Klik untuk ubah status aktif"
                      >
                        {spot.is_active ? 'Aktif' : 'Nonaktif'}
                      </button>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <div className="flex items-center justify-end gap-1.5">
                        <Button
                          variant="secondary"
                          className="h-7 px-2 text-xs flex items-center gap-1"
                          onClick={() => openEditModal(spot)}
                          title="Edit Spot"
                        >
                          <Edit2 className="h-3 w-3" />
                        </Button>
                        <Button
                          variant="secondary"
                          className="h-7 px-2 text-xs text-red-600 hover:bg-red-50 hover:text-red-700"
                          onClick={() => setDeleteConfirmSpot(spot)}
                          title="Hapus Spot"
                        >
                          <Trash2 className="h-3 w-3" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </LayerCard>

      {/* ADD / EDIT MODAL */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/45 backdrop-blur-xs">
          <div className="w-full max-w-md bg-kumo-canvas border border-kumo-hairline rounded-2xl shadow-xl overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            {/* Modal Header */}
            <div className="flex items-center justify-between px-5 py-4 border-b border-kumo-hairline bg-kumo-control/30">
              <div className="flex items-center gap-2">
                <MapPin className="h-4 w-4 text-indigo-600" />
                <h3 className="text-sm font-semibold text-kumo-default">
                  {editingSpot ? 'Edit Titik Temu COD' : 'Tambah Titik Temu COD'}
                </h3>
              </div>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-lg hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default cursor-pointer"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Modal Form */}
            <form onSubmit={handleSaveSpot} className="p-6 space-y-4 text-xs">
              <div className="space-y-1.5">
                <label className="font-semibold text-kumo-default">Nama Lokasi / Spot:</label>
                <Input
                  required
                  placeholder="Contoh: Gazebo Depan Lab RPL"
                  value={name}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setName(e.target.value)}
                  className="w-full text-xs"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <label className="font-semibold text-kumo-default">Lantai Gedung:</label>
                  <select
                    value={floor}
                    onChange={(e) => setFloor(Number(e.target.value))}
                    className="w-full h-8 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 text-xs text-kumo-default font-medium focus:ring-1 focus:ring-indigo-500"
                  >
                    <option value={1}>Lantai 1</option>
                    <option value={2}>Lantai 2</option>
                    <option value={3}>Lantai 3</option>
                    <option value={4}>Lantai 4 & Rooftop</option>
                  </select>
                </div>

                <div className="space-y-1.5">
                  <label className="font-semibold text-kumo-default">Kategori Area:</label>
                  <select
                    value={areaCategory}
                    onChange={(e) => setAreaCategory(e.target.value)}
                    className="w-full h-8 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 text-xs text-kumo-default font-medium focus:ring-1 focus:ring-indigo-500"
                  >
                    <option value="Kantin & Sosialisasi">Kantin & Sosialisasi</option>
                    <option value="Laboratorium Kejuruan">Laboratorium Kejuruan</option>
                    <option value="Ruang Kelas & Koridor">Ruang Kelas & Koridor</option>
                    <option value="Fasilitas Umum">Fasilitas Umum & Perpustakaan</option>
                    <option value="Outdoor / Lapangan">Outdoor / Lapangan</option>
                  </select>
                </div>
              </div>

              <div className="space-y-1.5">
                <label className="font-semibold text-kumo-default">Deskripsi Petunjuk Arah:</label>
                <textarea
                  rows={2}
                  placeholder="Contoh: Di dekat pohon rindang, samping tangga menuju lantai 2"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full rounded-lg border border-kumo-hairline bg-kumo-canvas p-2.5 text-xs text-kumo-default focus:outline-none focus:ring-1 focus:ring-indigo-500 resize-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3 p-3 rounded-xl border border-kumo-hairline bg-kumo-control/30">
                <div className="space-y-1">
                  <label className="text-[11px] font-semibold text-kumo-subtle">Koordinat X (%):</label>
                  <input
                    type="number"
                    min={0}
                    max={100}
                    value={coordX}
                    onChange={(e) => setCoordX(Number(e.target.value))}
                    className="w-full h-7 rounded border border-kumo-hairline bg-kumo-canvas px-2 text-xs text-kumo-default font-mono"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-[11px] font-semibold text-kumo-subtle">Koordinat Y (%):</label>
                  <input
                    type="number"
                    min={0}
                    max={100}
                    value={coordY}
                    onChange={(e) => setCoordY(Number(e.target.value))}
                    className="w-full h-7 rounded border border-kumo-hairline bg-kumo-canvas px-2 text-xs text-kumo-default font-mono"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-kumo-hairline">
                <Button
                  type="button"
                  variant="secondary"
                  className="text-xs h-8 px-3"
                  onClick={() => setIsModalOpen(false)}
                >
                  Batal
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  className="text-xs h-8 px-4 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Menyimpan...' : editingSpot ? 'Simpan Perubahan' : 'Tambahkan Spot'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* CONFIRM DELETE SPOT MODAL */}
      {deleteConfirmSpot && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="w-full max-w-sm bg-kumo-canvas border border-kumo-hairline rounded-2xl shadow-2xl p-5 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center text-red-600 shrink-0">
                <AlertCircle className="h-5 w-5" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-kumo-default">Hapus Titik Temu</h4>
                <p className="text-xs text-kumo-subtle">Konfirmasi penghapusan lokasi</p>
              </div>
            </div>

            <p className="text-xs text-kumo-default leading-relaxed">
              Apakah Anda yakin ingin menghapus spot <strong>"{deleteConfirmSpot.name}"</strong> (Lantai {deleteConfirmSpot.floor})?
              Lokasi ini tidak akan lagi muncul di opsi checkout COD siswa.
            </p>

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-kumo-hairline">
              <Button
                variant="secondary"
                className="text-xs h-8 px-3"
                onClick={() => setDeleteConfirmSpot(null)}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                className="text-xs h-8 px-3 bg-red-600 hover:bg-red-700 text-white font-semibold"
                onClick={handleDeleteSpot}
              >
                Hapus Spot
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
