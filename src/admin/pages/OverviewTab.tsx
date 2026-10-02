import {
  Users,
  FileText,
  MapPin,
  ShoppingBag,
  ArrowUpRight,
  CheckCircle2,
  Activity,
  ShieldCheck,
  Sparkles,
  Zap,
  Clock,
} from 'lucide-react';
import { StatsCard } from '../components/StatsCard';
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
      <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto animate-pulse">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-32 rounded-2xl bg-slate-100 border border-slate-200/60" />
          ))}
        </div>
        <div className="h-20 rounded-2xl bg-slate-100 border border-slate-200/60" />
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="h-72 rounded-2xl bg-slate-100 border border-slate-200/60" />
          <div className="h-72 rounded-2xl bg-slate-100 border border-slate-200/60" />
        </div>
      </div>
    );
  }

  // Calculate Verified Student Stats
  const verifiedCount = stats.recentUsers.filter((u) => u.is_verified).length;
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

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* 1. Metrics KPI Row with SVG Sparklines */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard
          title="Total Siswa Terdaftar"
          value={stats.totalUsers}
          subtitle={`${verifiedCount} siswa terverifikasi (${verifiedRatio}%)`}
          icon={<Users className="h-4.5 w-4.5 text-[#3D38F5]" />}
          trend="SMKN 8"
          trendPositive={true}
          sparklineData={[12, 18, 22, 28, 35, 42, stats.totalUsers || 50]}
          badgeColor="indigo"
        />
        <StatsCard
          title="Postingan Feed & Produk"
          value={stats.totalPosts}
          subtitle="Karya PPLG, DKV, & Threads"
          icon={<FileText className="h-4.5 w-4.5 text-blue-600" />}
          trend="+14% w/w"
          trendPositive={true}
          sparklineData={[8, 14, 19, 23, 27, 31, stats.totalPosts || 38]}
          badgeColor="blue"
        />
        <StatsCard
          title="Titik Temu COD Kampus"
          value={stats.totalMeetingPoints}
          subtitle="Zona serah terima resmi"
          icon={<MapPin className="h-4.5 w-4.5 text-emerald-600" />}
          trend="Aktif"
          trendPositive={true}
          sparklineData={[3, 4, 4, 5, 5, 6, stats.totalMeetingPoints || 6]}
          badgeColor="emerald"
        />
        <StatsCard
          title="Total Transaksi COD"
          value={stats.totalOrders}
          subtitle="Pesanan tercatat di platform"
          icon={<ShoppingBag className="h-4.5 w-4.5 text-amber-600" />}
          trend="Realtime"
          trendPositive={true}
          sparklineData={[2, 5, 9, 14, 18, 24, stats.totalOrders || 30]}
          badgeColor="amber"
        />
      </div>

      {/* 2. System Status & Realtime Sync Strip */}
      <div className="p-4.5 border border-slate-200/80 bg-white rounded-2xl shadow-[0_1px_3px_rgba(0,0,0,0.03)] grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-xl bg-emerald-50 border border-emerald-200/80 flex items-center justify-center text-emerald-600 shrink-0">
            <Activity className="h-4 w-4 animate-pulse" />
          </div>
          <div>
            <div className="font-semibold text-slate-900 flex items-center gap-1.5">
              <span>Database Supabase Cloud</span>
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
            </div>
            <div className="text-[11px] text-slate-500 mt-0.5">
              PostgreSQL Connected • Realtime Engine Active
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-xl bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center text-[#3D38F5] shrink-0">
            <ShieldCheck className="h-4 w-4" />
          </div>
          <div>
            <div className="font-semibold text-slate-900 flex items-center gap-1.5">
              <span>Keamanan RBAC & RLS</span>
              <span className="px-1.5 py-0.2 rounded-full bg-[#EEF0FF] text-[9px] font-bold text-[#3D38F5] border border-[#D8DBFE]">
                Terproteksi
              </span>
            </div>
            <div className="text-[11px] text-slate-500 mt-0.5">
              Role Siswa, Seller, Admin Terisolasi RLS
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-xl bg-amber-50 border border-amber-200/80 flex items-center justify-center text-amber-600 shrink-0">
            <Zap className="h-4 w-4" />
          </div>
          <div>
            <div className="font-semibold text-slate-900 flex items-center gap-1.5">
              <span>Mobile Client App</span>
              <span className="text-[11px] font-medium text-slate-400">v1.0.4</span>
            </div>
            <div className="text-[11px] text-slate-500 mt-0.5">
              Sinkronisasi 1:1 Flutter Android & iOS
            </div>
          </div>
        </div>
      </div>

      {/* 3. Live Activity Stream & Recent Users Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Students */}
        <div className="p-6 border border-slate-200/80 bg-white rounded-2xl shadow-[0_1px_3px_rgba(0,0,0,0.03)] flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div>
                <h2 className="text-sm font-semibold text-slate-900">
                  Siswa Baru Bergabung
                </h2>
                <p className="text-xs text-slate-500 mt-0.5">
                  Registrasi akun dari lingkungan SMKN 8 Semarang
                </p>
              </div>
              <button
                className="text-xs h-8 px-3 rounded-xl border border-slate-200 hover:bg-slate-50 font-medium flex items-center gap-1 text-slate-600 hover:text-slate-900 transition-colors cursor-pointer"
                onClick={() => onNavigateTab('users')}
              >
                <span>Lihat Semua</span>
                <ArrowUpRight className="h-3.5 w-3.5 text-slate-400" />
              </button>
            </div>

            <div className="divide-y divide-slate-100">
              {stats.recentUsers.length === 0 ? (
                <div className="py-12 text-center text-xs text-slate-400">
                  Belum ada siswa terdaftar.
                </div>
              ) : (
                stats.recentUsers.slice(0, 5).map((u) => (
                  <div key={u.id} className="py-3 flex items-center justify-between hover:bg-slate-50/60 rounded-xl px-2 transition-colors">
                    <div className="flex items-center gap-3">
                      <div className="h-9 w-9 rounded-full bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center font-bold text-xs text-[#3D38F5] shrink-0">
                        {u.avatar_url ? (
                          <img
                            src={u.avatar_url}
                            alt={u.full_name || ''}
                            className="h-full w-full rounded-full object-cover"
                          />
                        ) : u.full_name ? (
                          u.full_name.charAt(0).toUpperCase()
                        ) : (
                          'S'
                        )}
                      </div>
                      <div>
                        <div className="text-xs font-semibold text-slate-900 flex items-center gap-1.5">
                          {u.full_name || 'Siswa SMKN 8'}
                          {u.is_verified && (
                            <CheckCircle2 className="h-3.5 w-3.5 text-blue-600 fill-blue-50" />
                          )}
                        </div>
                        <div className="text-[11px] text-slate-500">
                          @{u.username || 'user'} • {u.class_group || 'Siswa'}
                        </div>
                      </div>
                    </div>
                    <span className="text-[10px] uppercase font-bold py-0.5 px-2 rounded-full bg-slate-100 text-slate-600 border border-slate-200/80">
                      {u.role || 'buyer'}
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>

          <div className="pt-3 border-t border-slate-100 text-[11.5px] text-slate-400 flex items-center justify-between">
            <span>Total sampel terbaru: {stats.recentUsers.length} siswa</span>
            <span className="text-[#3D38F5] font-medium cursor-pointer hover:underline" onClick={() => onNavigateTab('users')}>
              Kelola verifikasi →
            </span>
          </div>
        </div>

        {/* Live Activity Stream (Recent Posts & Items) */}
        <div className="p-6 border border-slate-200/80 bg-white rounded-2xl shadow-[0_1px_3px_rgba(0,0,0,0.03)] flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between pb-4 border-b border-slate-100">
              <div>
                <h2 className="text-sm font-semibold text-slate-900">
                  Live Feed & Moderasi Terkini
                </h2>
                <p className="text-xs text-slate-500 mt-0.5">
                  Aktivitas karya, produk, dan threads komunitas
                </p>
              </div>
              <button
                className="text-xs h-8 px-3 rounded-xl border border-slate-200 hover:bg-slate-50 font-medium flex items-center gap-1 text-slate-600 hover:text-slate-900 transition-colors cursor-pointer"
                onClick={() => onNavigateTab('moderation')}
              >
                <span>Moderasi</span>
                <ArrowUpRight className="h-3.5 w-3.5 text-slate-400" />
              </button>
            </div>

            <div className="divide-y divide-slate-100">
              {stats.recentPosts.length === 0 ? (
                <div className="py-12 text-center text-xs text-slate-400">
                  Belum ada postingan feed atau produk.
                </div>
              ) : (
                stats.recentPosts.slice(0, 5).map((p) => (
                  <div key={p.id} className="py-3 flex items-center justify-between hover:bg-slate-50/60 rounded-xl px-2 transition-colors">
                    <div className="flex items-center gap-3 overflow-hidden">
                      <div className="h-9 w-9 rounded-xl bg-slate-100 border border-slate-200 flex items-center justify-center shrink-0 text-slate-500">
                        <FileText className="h-4 w-4" />
                      </div>
                      <div className="truncate max-w-[200px] sm:max-w-[240px]">
                        <div className="text-xs font-semibold text-slate-900 truncate">
                          {p.title || p.caption || 'Postingan Diskusi'}
                        </div>
                        <div className="text-[11px] text-slate-500 truncate">
                          {p.seller?.full_name || 'Siswa'} •{' '}
                          <span className="capitalize">{p.post_type || 'post'}</span>
                        </div>
                      </div>
                    </div>
                    <div className="text-right shrink-0">
                      <div className="text-xs font-semibold text-slate-900 tabular-nums">
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

          <div className="pt-3 border-t border-slate-100 text-[11.5px] text-slate-400 flex items-center justify-between">
            <span>Total postingan live: {stats.totalPosts} item</span>
            <span className="text-[#3D38F5] font-medium cursor-pointer hover:underline" onClick={() => onNavigateTab('moderation')}>
              Tinjau pelaporan →
            </span>
          </div>
        </div>
      </div>

      {/* 4. Quick Action Shortcuts Bar */}
      <div className="p-6 border border-slate-200/80 bg-gradient-to-r from-[#EEF0FF]/60 via-white to-slate-50/80 rounded-2xl flex flex-col sm:flex-row sm:items-center justify-between gap-4 shadow-[0_1px_3px_rgba(0,0,0,0.03)]">
        <div>
          <h3 className="text-sm font-bold text-slate-900 flex items-center gap-2">
            <Sparkles className="h-4 w-4 text-[#3D38F5]" />
            <span>Pusat Kendali Cepat Sekolah</span>
          </h3>
          <p className="text-xs text-slate-600 mt-0.5">
            Kelola titik temu COD di area sekolah SMKN 8 atau tinjau akun siswa untuk verifikasi identitas resmi.
          </p>
        </div>
        <div className="flex items-center gap-2.5 shrink-0 flex-wrap">
          <button
            className="text-xs h-9 px-3.5 rounded-xl bg-white hover:bg-slate-50 border border-slate-200 font-semibold text-slate-800 transition-all cursor-pointer shadow-2xs"
            onClick={() => onNavigateTab('meeting-points')}
          >
            Titik Temu COD Kampus
          </button>
          <button
            className="text-xs h-9 px-4 rounded-xl bg-[#3D38F5] hover:bg-[#312BD9] font-semibold text-white transition-all cursor-pointer shadow-[0_2px_8px_rgba(61,56,245,0.25)]"
            onClick={() => onNavigateTab('users')}
          >
            Verifikasi Siswa
          </button>
        </div>
      </div>
    </div>
  );
}
