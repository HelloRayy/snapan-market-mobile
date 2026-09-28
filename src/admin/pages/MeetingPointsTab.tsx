import { useState, useEffect } from 'react';
import { Plus, MapPin, Trash2, CheckCircle2, AlertCircle, RefreshCw } from 'lucide-react';
import { Button, Input, Badge, LayerCard } from '@cloudflare/kumo';
import { adminService, type SchoolMeetingPointRow } from '../services/adminService';

export function MeetingPointsTab() {
  const [spots, setSpots] = useState<SchoolMeetingPointRow[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

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
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat titik temu: ${e}` });
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSpots();
  }, []);

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
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal mengubah status: ${e}` });
    }
  };

  const handleDeleteSpot = async (id: string, spotName: string) => {
    if (!window.confirm(`Hapus titik temu "${spotName}"?`)) return;
    try {
      await adminService.deleteMeetingPoint(id);
      setSpots((prev) => prev.filter((s) => s.id !== id));
      setFeedbackMsg({ type: 'success', text: `Spot "${spotName}" berhasil dihapus` });
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal menghapus spot: ${e}` });
    }
  };

  const handleCreateSpot = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;
    setIsSubmitting(true);

    try {
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
      setIsAddModalOpen(false);
      setName('');
      setDescription('');
      setFeedbackMsg({ type: 'success', text: 'Titik temu COD berhasil ditambahkan!' });
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal menambahkan spot: ${e}` });
    } finally {
      setIsSubmitting(false);
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

      {/* Control Header */}
      <LayerCard className="p-4 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs flex flex-col sm:flex-row items-center justify-between gap-4">
        <div>
          <h2 className="text-sm font-semibold text-kumo-default">
            Titik Temu Resmi COD SMKN 8 Jakarta
          </h2>
          <p className="text-xs text-kumo-subtle">
            Lokasi aman berstandar sekolah untuk transaksi serah terima barang COD antar siswa
          </p>
        </div>

        <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end">
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
            className="h-8 px-3 text-xs flex items-center gap-1.5 bg-indigo-600 hover:bg-indigo-700 text-white"
            onClick={() => setIsAddModalOpen(true)}
          >
            <Plus className="h-3.5 w-3.5" />
            <span>Tambah Titik Temu</span>
          </Button>
        </div>
      </LayerCard>

      {/* Spots Table */}
      <LayerCard className="border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs overflow-hidden">
        <div className="px-5 py-3.5 border-b border-kumo-hairline flex items-center justify-between bg-kumo-control/40">
          <div className="text-xs font-semibold text-kumo-default">
            Daftar Lokasi Terdaftar ({spots.length})
          </div>
          <div className="text-[11px] text-kumo-subtle">
            Tersinkronisasi langsung dengan dropdown picker COD di Flutter
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-kumo-hairline bg-kumo-canvas text-kumo-subtle font-semibold">
                <th className="py-3 px-4">Lantai</th>
                <th className="py-3 px-4">Nama Spot</th>
                <th className="py-3 px-4">Kategori Area</th>
                <th className="py-3 px-4">Deskripsi Petunjuk</th>
                <th className="py-3 px-4">Koordinat Map</th>
                <th className="py-3 px-4 text-center">Status</th>
                <th className="py-3 px-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-kumo-hairline">
              {isLoading ? (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-kumo-subtle">
                    <RefreshCw className="h-5 w-5 animate-spin mx-auto mb-2 text-indigo-600" />
                    <span>Memuat titik temu COD...</span>
                  </td>
                </tr>
              ) : spots.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-kumo-subtle">
                    Belum ada titik temu COD yang terdaftar.
                  </td>
                </tr>
              ) : (
                spots.map((spot) => (
                  <tr key={spot.id} className="hover:bg-kumo-tint/50 transition-colors">
                    <td className="py-3 px-4 font-bold text-kumo-default">
                      Lantai {spot.floor}
                    </td>
                    <td className="py-3 px-4 font-semibold text-kumo-default flex items-center gap-2">
                      <MapPin className="h-3.5 w-3.5 text-indigo-600 shrink-0" />
                      <span>{spot.name}</span>
                    </td>
                    <td className="py-3 px-4 text-kumo-default">
                      <Badge variant="secondary" className="text-[10px] py-0.5 px-2">
                        {spot.area_category}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 text-kumo-subtle max-w-xs truncate">
                      {spot.description || '-'}
                    </td>
                    <td className="py-3 px-4 font-mono text-[11px] text-kumo-subtle">
                      ({spot.coordinates_x}, {spot.coordinates_y})
                    </td>
                    <td className="py-3 px-4 text-center">
                      <button
                        onClick={() => handleToggleActive(spot.id, spot.is_active)}
                        className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold cursor-pointer transition-colors ${
                          spot.is_active
                            ? 'bg-emerald-100 text-emerald-800 border border-emerald-200'
                            : 'bg-slate-100 text-slate-600 border border-slate-200'
                        }`}
                      >
                        {spot.is_active ? 'Aktif' : 'Nonaktif'}
                      </button>
                    </td>
                    <td className="py-3 px-4 text-right">
                      <Button
                        variant="secondary"
                        className="h-7 px-2 text-xs text-red-600 hover:bg-red-50 hover:text-red-700 border-red-200 cursor-pointer"
                        onClick={() => handleDeleteSpot(spot.id, spot.name)}
                      >
                        <Trash2 className="h-3.5 w-3.5" />
                      </Button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </LayerCard>

      {/* Add Spot Modal */}
      {isAddModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-xs">
          <div className="w-full max-w-lg rounded-2xl bg-kumo-canvas p-6 border border-kumo-hairline shadow-xl space-y-4">
            <div className="flex items-center justify-between border-b border-kumo-hairline pb-3">
              <h3 className="text-sm font-bold text-kumo-default">
                Tambah Titik Temu COD Kampus Baru
              </h3>
              <button
                onClick={() => setIsAddModalOpen(false)}
                className="text-xs text-kumo-subtle hover:text-kumo-default cursor-pointer"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateSpot} className="space-y-3.5 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-medium text-kumo-default mb-1">
                    Lantai Gedung
                  </label>
                  <select
                    value={floor}
                    onChange={(e) => setFloor(Number(e.target.value))}
                    className="w-full h-9 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 text-xs text-kumo-default font-medium focus:ring-1 focus:ring-indigo-500"
                  >
                    <option value={1}>Lantai 1</option>
                    <option value={2}>Lantai 2</option>
                    <option value={3}>Lantai 3</option>
                    <option value={4}>Lantai 4</option>
                  </select>
                </div>

                <div>
                  <label className="block font-medium text-kumo-default mb-1">
                    Kategori Area
                  </label>
                  <select
                    value={areaCategory}
                    onChange={(e) => setAreaCategory(e.target.value)}
                    className="w-full h-9 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 text-xs text-kumo-default font-medium focus:ring-1 focus:ring-indigo-500"
                  >
                    <option value="Kantin & Sosialisasi">Kantin & Sosialisasi</option>
                    <option value="Area Jurusan Vokasi">Area Jurusan Vokasi</option>
                    <option value="Lobby & Gerbang">Lobby & Gerbang</option>
                    <option value="Gazebo & Taman">Gazebo & Taman</option>
                    <option value="Perpustakaan">Perpustakaan</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-medium text-kumo-default mb-1">
                  Nama Titik Temu
                </label>
                <Input
                  placeholder="Misal: Gazebo Depan Bengkel PPLG"
                  value={name}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setName(e.target.value)}
                  required
                  className="w-full text-xs"
                />
              </div>

              <div>
                <label className="block font-medium text-kumo-default mb-1">
                  Petunjuk Lokasi (Deskripsi Tambahan)
                </label>
                <textarea
                  placeholder="Misal: Bangku kayu panjang dekat dispenser air galon"
                  value={description}
                  onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setDescription(e.target.value)}
                  rows={2}
                  className="w-full rounded-lg border border-kumo-hairline bg-kumo-control p-2.5 text-xs text-kumo-default focus:ring-1 focus:ring-indigo-500 focus:outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-medium text-kumo-default mb-1">
                    Koordinat Map X
                  </label>
                  <Input
                    type="number"
                    value={coordX}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setCoordX(Number(e.target.value))}
                    className="w-full text-xs"
                  />
                </div>
                <div>
                  <label className="block font-medium text-kumo-default mb-1">
                    Koordinat Map Y
                  </label>
                  <Input
                    type="number"
                    value={coordY}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setCoordY(Number(e.target.value))}
                    className="w-full text-xs"
                  />
                </div>
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-3 border-t border-kumo-hairline">
                <Button
                  type="button"
                  variant="secondary"
                  className="text-xs h-9 px-3"
                  onClick={() => setIsAddModalOpen(false)}
                >
                  Batal
                </Button>
                <Button
                  type="submit"
                  variant="primary"
                  className="text-xs h-9 px-4 bg-indigo-600 hover:bg-indigo-700 text-white"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? 'Menyimpan...' : 'Simpan Titik Temu'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
