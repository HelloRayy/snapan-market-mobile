import {
  Users,
  FileText,
  MapPin,
  ShoppingBag,
  ArrowUpRight,
  CheckCircle2,
  Clock,
  Sparkles,
  Server,
  ShieldCheck,
  ChevronRight,
  Database,
  Radio,
} from 'lucide-react';
import { StatsCard } from '../components/StatsCard';
import { Card, Badge, Tracker, type TrackerBlock } from '../components/tremor';
import type { AdminStats } from '../services/adminService';
import type { AdminTab } from '../components/AdminSidebar';

interface OverviewTabProps {
  stats: AdminStats | null;
  isLoading: boolean;
  onNavigateTab: (tab: AdminTab) => void;
}

export function OverviewTab({ stats, isLoading, onNavigateTab }: OverviewTabProps) {
  if (isLoading || !stats) {
    return (
      <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="h-28 rounded-xl bg-slate-100 animate-pulse border border-slate-200" />
          ))}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 h-80 rounded-xl bg-slate-100 animate-pulse border border-slate-200" />
          <div className="lg:col-span-4 h-80 rounded-xl bg-slate-100 animate-pulse border border-slate-200" />
        </div>
      </div>
    );
  }

  // Calculate Verified Student Stats
  const verifiedCount = stats.recentUsers.filter((u) => u.is_verified).length;
  const unverifiedList = stats.recentUsers.filter((u) => !u.is_verified);
  const verifiedRatio = stats.recentUsers.length > 0
    ? Math.round((verifiedCount / stats.recentUsers.length) * 100)
    : 0;

  // Format relative time helper
  const formatTime = (dateStr: string) => {
    try {
      const date = new Date(dateStr);
      const diffMinutes = Math.floor((Date.now() - date.getTime()) / 60000);
      if (diffMinutes < 1) return 'Baru saja';
      if (diffMinutes < 60) return `${diffMinutes}m lalu`;
      const diffHours = Math.floor(diffMinutes / 60);
      if (diffHours < 24) return `${diffHours}j lalu`;
      return date.toLocaleDateString('id-ID', { day: 'numeric', month: 'short' });
    } catch {
      return 'Terkini';
    }
  };

  // 24-hour Operational status tracker
  const trackerData: TrackerBlock[] = [
    { color: 'emerald', tooltip: '00:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '01:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '02:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '03:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '04:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '05:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '06:00 - Pendaftaran Siswa Pagi' },
    { color: 'indigo', tooltip: '07:00 - Jam Masuk Sekolah Aktif' },
    { color: 'indigo', tooltip: '08:00 - Aktivitas Marketplace Kelas' },
    { color: 'indigo', tooltip: '09:00 - Jam Istirahat 1: Transaksi COD' },
    { color: 'emerald', tooltip: '10:00 - Sistem Normal' },
    { color: 'indigo', tooltip: '11:00 - Moderasi Produk Kejuruan' },
    { color: 'indigo', tooltip: '12:00 - Jam Istirahat 2: Puncak COD' },
    { color: 'emerald', tooltip: '13:00 - Transaksi Berhasil Terverifikasi' },
    { color: 'emerald', tooltip: '14:00 - Sistem Normal' },
    { color: 'indigo', tooltip: '15:00 - Postingan Threads Sore' },
    { color: 'emerald', tooltip: '16:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '17:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '18:00 - Realtime WebSocket Sync Aktif' },
    { color: 'emerald', tooltip: '19:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '20:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '21:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '22:00 - Sistem Operasional' },
    { color: 'emerald', tooltip: '23:00 - Uptime 99.98% Hari Ini' },
  ];

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* 1. Stat KPI Row (4 Columns) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard
          title="Total Siswa Terdaftar"
          value={stats.totalUsers}
          subtitle={`${verifiedCount} terverifikasi (${verifiedRatio}%)`}
          icon={<Users className="h-5 w-5" />}
          trend="SMKN 8"
          trendPositive={true}
          sparklineData={[12, 18, 22, 28, 35, 42, stats.totalUsers || 50]}
          badgeColor="indigo"
        />
        <StatsCard
          title="Postingan & Karya"
          value={stats.totalPosts}
          subtitle="PPLG, DKV, Kuliner & Threads"
          icon={<FileText className="h-5 w-5" />}
          trend="+14% w/w"
          trendPositive={true}
          sparklineData={[8, 14, 19, 23, 27, 31, stats.totalPosts || 38]}
          badgeColor="blue"
        />
        <StatsCard
          title="Titik Temu COD"
          value={stats.totalMeetingPoints}
          subtitle="Zona resmi lingkungan sekolah"
          icon={<MapPin className="h-5 w-5" />}
          trend="Aktif"
          trendPositive={true}
          sparklineData={[3, 4, 4, 5, 5, 6, stats.totalMeetingPoints || 6]}
          badgeColor="emerald"
        />
        <StatsCard
          title="Pesanan COD Tercatat"
          value={stats.totalOrders}
          subtitle="Transaksi serah terima kampus"
          icon={<ShoppingBag className="h-5 w-5" />}
          trend="Realtime"
          trendPositive={true}
          sparklineData={[2, 5, 9, 14, 18, 24, stats.totalOrders || 30]}
          badgeColor="amber"
        />
      </div>

      {/* 2. Split 8:4 Main Grid Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column (8 Columns): Timeline & Major Activity Lists */}
        <div className="lg:col-span-8 space-y-6">
          {/* 24-Hour Operational Timeline Card */}
          <Card className="p-5">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-4 border-b border-slate-100">
              <div>
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                  <Server className="h-4 w-4 text-[#3D38F5]" />
                  <span>Pemantauan Operasional Ekosistem Snaps</span>
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Status sinkronisasi realtime cloud Supabase dan aktivitas transaksi harian
                </p>
              </div>
              <div className="flex items-center gap-2">
                <Badge variant="emerald">
                  <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse mr-1" />
                  Uptime 99.98%
                </Badge>
                <Badge variant="indigo">
                  Realtime Active
                </Badge>
              </div>
            </div>

            <div className="mt-4">
              <Tracker data={trackerData} />
            </div>

            <div className="mt-3 flex items-center justify-between text-[11px] text-slate-400">
              <span>24 jam terakhir (00:00 - Sekarang)</span>
              <div className="flex items-center gap-3">
                <span className="flex items-center gap-1">
                  <span className="h-2 w-2 rounded-xs bg-emerald-500 inline-block" /> Normal
                </span>
                <span className="flex items-center gap-1">
                  <span className="h-2 w-2 rounded-xs bg-[#3D38F5] inline-block" /> Transaksi Aktif
                </span>
              </div>
            </div>
          </Card>

          {/* Recent Student Sign-ups Card */}
          <Card className="p-5 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between pb-3.5 border-b border-slate-100">
                <div>
                  <h3 className="text-sm font-bold text-slate-900">
                    Siswa Baru Terdaftar
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Pendaftaran siswa terbaru di lingkungan SMKN 8 Semarang
                  </p>
                </div>
                <button
                  className="text-xs px-2.5 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 font-semibold flex items-center gap-1 text-slate-600 hover:text-slate-900 transition-colors cursor-pointer"
                  onClick={() => onNavigateTab('users')}
                >
                  <span>Buka Direktori</span>
                  <ArrowUpRight className="h-3.5 w-3.5 text-slate-400" />
                </button>
              </div>

              <div className="divide-y divide-slate-100 mt-1">
                {stats.recentUsers.length === 0 ? (
                  <div className="py-10 text-center text-xs text-slate-400">
                    Belum ada siswa terdaftar.
                  </div>
                ) : (
                  stats.recentUsers.slice(0, 5).map((u) => (
                    <div key={u.id} className="py-3 flex items-center justify-between hover:bg-slate-50/70 rounded-lg px-2 transition-colors">
                      <div className="flex items-center gap-3 min-w-0">
                        <div className="h-9 w-9 rounded-lg bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center font-bold text-xs text-[#3D38F5] shrink-0 overflow-hidden">
                          {u.avatar_url ? (
                            <img
                              src={u.avatar_url}
                              alt={u.full_name || ''}
                              className="h-full w-full object-cover"
                            />
                          ) : u.full_name ? (
                            u.full_name.charAt(0).toUpperCase()
                          ) : (
                            'S'
                          )}
                        </div>
                        <div className="min-w-0">
                          <div className="text-xs font-bold text-slate-900 flex items-center gap-1.5 truncate">
                            <span className="truncate">{u.full_name || 'Siswa SMKN 8'}</span>
                            {u.is_verified && (
                              <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 fill-blue-50 shrink-0" />
                            )}
                          </div>
                          <div className="text-[11px] text-slate-400 truncate">
                            @{u.username || 'user'} • {u.class_group || 'Umum'}
                          </div>
                        </div>
                      </div>
                      <Badge variant={u.role === 'admin' ? 'indigo' : 'slate'} className="uppercase text-[10px] shrink-0">
                        {u.role || 'buyer'}
                      </Badge>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="pt-3.5 border-t border-slate-100 text-[11.5px] text-slate-400 flex items-center justify-between">
              <span>Total akun terdaftar: {stats.totalUsers} siswa</span>
              <button
                className="text-[#3D38F5] font-semibold hover:underline cursor-pointer flex items-center gap-0.5"
                onClick={() => onNavigateTab('users')}
              >
                <span>Kelola Siswa</span>
                <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </Card>

          {/* Recent Posts & Threads Card */}
          <Card className="p-5 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between pb-3.5 border-b border-slate-100">
                <div>
                  <h3 className="text-sm font-bold text-slate-900">
                    Karya & Threads Komunitas Terbaru
                  </h3>
                  <p className="text-xs text-slate-500 mt-0.5">
                    Postingan karya kejuruan dan diskusi komunitas sekolah
                  </p>
                </div>
                <button
                  className="text-xs px-2.5 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 font-semibold flex items-center gap-1 text-slate-600 hover:text-slate-900 transition-colors cursor-pointer"
                  onClick={() => onNavigateTab('moderation')}
                >
                  <span>Moderasi</span>
                  <ArrowUpRight className="h-3.5 w-3.5 text-slate-400" />
                </button>
              </div>

              <div className="divide-y divide-slate-100 mt-1">
                {stats.recentPosts.length === 0 ? (
                  <div className="py-10 text-center text-xs text-slate-400">
                    Belum ada postingan feed.
                  </div>
                ) : (
                  stats.recentPosts.slice(0, 5).map((p) => (
                    <div key={p.id} className="py-3 flex items-center justify-between hover:bg-slate-50/70 rounded-lg px-2 transition-colors">
                      <div className="flex items-center gap-3 overflow-hidden min-w-0">
                        <div className="h-9 w-9 rounded-lg bg-slate-100 border border-slate-200 flex items-center justify-center shrink-0 text-slate-500">
                          <FileText className="h-4 w-4" />
                        </div>
                        <div className="truncate max-w-[200px] sm:max-w-[320px]">
                          <div className="text-xs font-bold text-slate-900 truncate">
                            {p.title || p.caption || 'Postingan Diskusi'}
                          </div>
                          <div className="text-[11px] text-slate-400 truncate">
                            @{p.seller?.username || 'user'} • <span className="capitalize">{p.post_type}</span>
                          </div>
                        </div>
                      </div>
                      <div className="text-right shrink-0">
                        <div className="text-xs font-bold text-slate-900 tabular-nums">
                          {p.price > 0 ? `Rp ${p.price.toLocaleString('id-ID')}` : 'Threads'}
                        </div>
                        <div className="text-[10.5px] text-slate-400 flex items-center justify-end gap-1 mt-0.5">
                          <Clock className="h-2.5 w-2.5" />
                          <span>{formatTime(p.created_at)}</span>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="pt-3.5 border-t border-slate-100 text-[11.5px] text-slate-400 flex items-center justify-between">
              <span>Total katalog feed: {stats.totalPosts} item</span>
              <button
                className="text-[#3D38F5] font-semibold hover:underline cursor-pointer flex items-center gap-0.5"
                onClick={() => onNavigateTab('moderation')}
              >
                <span>Lihat Moderasi</span>
                <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </Card>
        </div>

        {/* Right Column (4 Columns): Verification Queue & Quick Controls */}
        <div className="lg:col-span-4 space-y-6">
          {/* Pending Verification Queue Card */}
          <Card className="p-5">
            <div className="flex items-center justify-between pb-3.5 border-b border-slate-100">
              <div>
                <h3 className="text-sm font-bold text-slate-900 flex items-center gap-1.5">
                  <ShieldCheck className="h-4 w-4 text-amber-500" />
                  <span>Antrean Verifikasi</span>
                </h3>
                <p className="text-xs text-slate-500 mt-0.5">
                  Akun siswa menunggu tanda identitas resmi
                </p>
              </div>
              <Badge variant="amber" className="font-bold">
                {unverifiedList.length} Pending
              </Badge>
            </div>

            <div className="divide-y divide-slate-100 mt-2">
              {unverifiedList.length === 0 ? (
                <div className="py-8 text-center text-xs text-slate-400 space-y-1">
                  <CheckCircle2 className="h-6 w-6 text-emerald-500 mx-auto" />
                  <p className="font-semibold text-slate-700">Semua Siswa Terverifikasi</p>
                  <p className="text-[11px] text-slate-400">Tidak ada antrean tertunda saat ini.</p>
                </div>
              ) : (
                unverifiedList.slice(0, 4).map((u) => (
                  <div key={u.id} className="py-2.5 flex items-center justify-between">
                    <div className="min-w-0 pr-2">
                      <div className="text-xs font-bold text-slate-900 truncate">
                        {u.full_name || 'Siswa Tanpa Nama'}
                      </div>
                      <div className="text-[11px] text-slate-400 truncate">
                        @{u.username || 'user'} • {u.class_group || 'Umum'}
                      </div>
                    </div>
                    <button
                      onClick={() => onNavigateTab('users')}
                      className="px-2.5 py-1 rounded-md text-[11px] font-semibold bg-[#EEF0FF] text-[#3D38F5] hover:bg-indigo-100 border border-[#D8DBFE] transition-colors cursor-pointer shrink-0"
                    >
                      Periksa
                    </button>
                  </div>
                ))
              )}
            </div>

            <div className="pt-3.5 border-t border-slate-100 mt-2">
              <button
                onClick={() => onNavigateTab('users')}
                className="w-full py-2 px-3 rounded-lg text-xs font-semibold bg-slate-50 hover:bg-slate-100 text-slate-700 border border-slate-200 transition-colors text-center cursor-pointer block"
              >
                Buka Direktori Lengkap ({stats.totalUsers} Siswa)
              </button>
            </div>
          </Card>

          {/* Quick Action Shortcuts Panel */}
          <Card className="p-5 space-y-3">
            <div>
              <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                <Sparkles className="h-4 w-4 text-[#3D38F5]" />
                <span>Pintasan Operasional</span>
              </h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Aksi administratif yang paling sering digunakan
              </p>
            </div>

            <div className="space-y-2 pt-1">
              <button
                onClick={() => onNavigateTab('meeting-points')}
                className="w-full p-3 rounded-xl border border-slate-200 hover:border-[#3D38F5]/40 hover:bg-[#EEF0FF]/30 transition-all flex items-center justify-between text-left cursor-pointer group"
              >
                <div className="flex items-center gap-3">
                  <div className="h-8 w-8 rounded-lg bg-emerald-50 text-emerald-600 border border-emerald-200 flex items-center justify-center shrink-0">
                    <MapPin className="h-4 w-4" />
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-900 group-hover:text-[#3D38F5] transition-colors">
                      Tambah Titik COD Kampus
                    </div>
                    <div className="text-[11px] text-slate-400">
                      Tentukan spot serah terima baru
                    </div>
                  </div>
                </div>
                <ChevronRight className="h-4 w-4 text-slate-400 group-hover:text-[#3D38F5]" />
              </button>

              <button
                onClick={() => onNavigateTab('users')}
                className="w-full p-3 rounded-xl border border-slate-200 hover:border-[#3D38F5]/40 hover:bg-[#EEF0FF]/30 transition-all flex items-center justify-between text-left cursor-pointer group"
              >
                <div className="flex items-center gap-3">
                  <div className="h-8 w-8 rounded-lg bg-indigo-50 text-[#3D38F5] border border-[#D8DBFE] flex items-center justify-center shrink-0">
                    <Users className="h-4 w-4" />
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-900 group-hover:text-[#3D38F5] transition-colors">
                      Kelola Hak Akses Siswa
                    </div>
                    <div className="text-[11px] text-slate-400">
                      Ubah role Buyer, Seller, atau Admin
                    </div>
                  </div>
                </div>
                <ChevronRight className="h-4 w-4 text-slate-400 group-hover:text-[#3D38F5]" />
              </button>

              <button
                onClick={() => onNavigateTab('moderation')}
                className="w-full p-3 rounded-xl border border-slate-200 hover:border-rose-300 hover:bg-rose-50/30 transition-all flex items-center justify-between text-left cursor-pointer group"
              >
                <div className="flex items-center gap-3">
                  <div className="h-8 w-8 rounded-lg bg-rose-50 text-rose-600 border border-rose-200 flex items-center justify-center shrink-0">
                    <FileText className="h-4 w-4" />
                  </div>
                  <div>
                    <div className="text-xs font-bold text-slate-900 group-hover:text-rose-600 transition-colors">
                      Tinjau Pelaporan Konten
                    </div>
                    <div className="text-[11px] text-slate-400">
                      Takedown postingan melanggar
                    </div>
                  </div>
                </div>
                <ChevronRight className="h-4 w-4 text-slate-400 group-hover:text-rose-600" />
              </button>
            </div>
          </Card>

          {/* Infrastructure Health Status Card */}
          <Card className="p-5 space-y-3.5">
            <div>
              <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
                <Database className="h-4 w-4 text-[#3D38F5]" />
                <span>Konektivitas Infrastruktur</span>
              </h3>
              <p className="text-xs text-slate-500 mt-0.5">
                Diagnostik server dan cloud database
              </p>
            </div>

            <div className="space-y-2 text-xs">
              <div className="flex items-center justify-between p-2.5 rounded-lg bg-slate-50 border border-slate-200/80">
                <div className="flex items-center gap-2">
                  <Radio className="h-3.5 w-3.5 text-emerald-500 animate-pulse" />
                  <span className="font-semibold text-slate-700">WebSocket Realtime</span>
                </div>
                <Badge variant="emerald" className="text-[10px]">Connected</Badge>
              </div>

              <div className="flex items-center justify-between p-2.5 rounded-lg bg-slate-50 border border-slate-200/80">
                <div className="flex items-center gap-2">
                  <Server className="h-3.5 w-3.5 text-blue-500" />
                  <span className="font-semibold text-slate-700">Supabase Auth API</span>
                </div>
                <Badge variant="blue" className="text-[10px]">Optimal</Badge>
              </div>

              <div className="flex items-center justify-between p-2.5 rounded-lg bg-slate-50 border border-slate-200/80">
                <div className="flex items-center gap-2">
                  <Database className="h-3.5 w-3.5 text-purple-500" />
                  <span className="font-semibold text-slate-700">PostgreSQL Latency</span>
                </div>
                <span className="font-mono text-[11px] font-bold text-slate-600">~24 ms</span>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
