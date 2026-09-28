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
} from 'lucide-react';
import { Button, Badge, LayerCard } from '@cloudflare/kumo';
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
      <div className="p-4 md:p-8 space-y-6 animate-pulse">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-28 rounded-xl bg-kumo-control border border-kumo-hairline" />
          ))}
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="h-64 rounded-xl bg-kumo-control border border-kumo-hairline" />
          <div className="h-64 rounded-xl bg-kumo-control border border-kumo-hairline" />
        </div>
      </div>
    );
  }

  // Calculate Verified Student Stats from recent sample or overall
  const verifiedCount = stats.recentUsers.filter((u) => u.is_verified).length;
  const verifiedRatio = stats.recentUsers.length > 0
    ? Math.round((verifiedCount / stats.recentUsers.length) * 100)
    : 0;

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Metrics Row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard
          title="Total Siswa Terdaftar"
          value={stats.totalUsers}
          subtitle={`${verifiedCount} terverifikasi (${verifiedRatio}% sampel)`}
          icon={<Users className="h-4 w-4 text-indigo-600" />}
          trend="SMKN 8"
        />
        <StatsCard
          title="Postingan Feed & Produk"
          value={stats.totalPosts}
          subtitle="Marketplace & threads siswa"
          icon={<FileText className="h-4 w-4 text-blue-600" />}
        />
        <StatsCard
          title="Titik Temu COD Kampus"
          value={stats.totalMeetingPoints}
          subtitle="Spot resmi sekolah"
          icon={<MapPin className="h-4 w-4 text-emerald-600" />}
        />
        <StatsCard
          title="Total Transaksi COD"
          value={stats.totalOrders}
          subtitle="Pesanan sNaps tercatat"
          icon={<ShoppingBag className="h-4 w-4 text-amber-600" />}
        />
      </div>

      {/* System Status & Ecosystem Health Strip */}
      <LayerCard className="p-4.5 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-lg bg-emerald-50 border border-emerald-200 flex items-center justify-center text-emerald-600 shrink-0">
            <Activity className="h-4 w-4 animate-pulse" />
          </div>
          <div>
            <div className="font-semibold text-kumo-default flex items-center gap-1.5">
              <span>Database Supabase</span>
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
            </div>
            <div className="text-[11px] text-kumo-subtle">
              PostgreSQL Cloud Connected • Realtime Active
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-lg bg-indigo-50 border border-indigo-200 flex items-center justify-center text-indigo-600 shrink-0">
            <ShieldCheck className="h-4 w-4" />
          </div>
          <div>
            <div className="font-semibold text-kumo-default flex items-center gap-1.5">
              <span>Keamanan RBAC & RLS</span>
              <Badge variant="primary" className="text-[9px] py-0 px-1 font-bold">AKTIF</Badge>
            </div>
            <div className="text-[11px] text-kumo-subtle">
              Role: Admin, Seller, Buyer Terisolasi
            </div>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="h-9 w-9 rounded-lg bg-amber-50 border border-amber-200 flex items-center justify-center text-amber-600 shrink-0">
            <Zap className="h-4 w-4" />
          </div>
          <div>
            <div className="font-semibold text-kumo-default">
              <span>Sinkronisasi Mobile</span>
            </div>
            <div className="text-[11px] text-kumo-subtle">
              Live WebSocket Sync ke Flutter App
            </div>
          </div>
        </div>
      </LayerCard>

      {/* Grid of Recent Users & Recent Posts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Students */}
        <LayerCard className="p-5 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs">
          <div className="flex items-center justify-between pb-4 border-b border-kumo-hairline">
            <div>
              <h2 className="text-sm font-semibold text-kumo-default">
                Siswa Baru Bergabung
              </h2>
              <p className="text-xs text-kumo-subtle">
                Pendaftaran terbaru dari lingkungan SMKN 8
              </p>
            </div>
            <Button
              variant="secondary"
              className="text-xs h-8 px-2.5 flex items-center gap-1 text-kumo-subtle hover:text-kumo-default"
              onClick={() => onNavigateTab('users')}
            >
              <span>Lihat Semua</span>
              <ArrowUpRight className="h-3.5 w-3.5" />
            </Button>
          </div>

          <div className="divide-y divide-kumo-hairline">
            {stats.recentUsers.length === 0 ? (
              <div className="py-8 text-center text-xs text-kumo-subtle">
                Belum ada siswa terdaftar.
              </div>
            ) : (
              stats.recentUsers.map((u) => (
                <div key={u.id} className="py-3 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="h-8 w-8 rounded-full bg-indigo-50 border border-indigo-200 flex items-center justify-center font-bold text-xs text-indigo-700 shrink-0">
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
                      <div className="text-xs font-semibold text-kumo-default flex items-center gap-1.5">
                        {u.full_name || 'Tanpa Nama'}
                        {u.is_verified && (
                          <CheckCircle2 className="h-3 w-3 text-blue-600" />
                        )}
                      </div>
                      <div className="text-[11px] text-kumo-subtle">
                        @{u.username || 'user'} • {u.class_group || 'SMKN 8'}
                      </div>
                    </div>
                  </div>
                  <Badge variant="primary" className="text-[10px] uppercase font-bold py-0.5 px-2">
                    {u.role || 'buyer'}
                  </Badge>
                </div>
              ))
            )}
          </div>
        </LayerCard>

        {/* Recent Posts Moderation Snapshot */}
        <LayerCard className="p-5 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs">
          <div className="flex items-center justify-between pb-4 border-b border-kumo-hairline">
            <div>
              <h2 className="text-sm font-semibold text-kumo-default">
                Aktivitas Postingan Terkini
              </h2>
              <p className="text-xs text-kumo-subtle">
                Feed threads dan produk terbaru siswa
              </p>
            </div>
            <Button
              variant="secondary"
              className="text-xs h-8 px-2.5 flex items-center gap-1 text-kumo-subtle hover:text-kumo-default"
              onClick={() => onNavigateTab('moderation')}
            >
              <span>Moderasi</span>
              <ArrowUpRight className="h-3.5 w-3.5" />
            </Button>
          </div>

          <div className="divide-y divide-kumo-hairline">
            {stats.recentPosts.length === 0 ? (
              <div className="py-8 text-center text-xs text-kumo-subtle">
                Belum ada postingan feed.
              </div>
            ) : (
              stats.recentPosts.map((p) => (
                <div key={p.id} className="py-3 flex items-center justify-between">
                  <div className="flex items-center gap-3 overflow-hidden">
                    <div className="h-8 w-8 rounded-lg bg-kumo-control border border-kumo-hairline flex items-center justify-center shrink-0">
                      <FileText className="h-4 w-4 text-kumo-subtle" />
                    </div>
                    <div className="truncate max-w-[200px] sm:max-w-[240px]">
                      <div className="text-xs font-semibold text-kumo-default truncate">
                        {p.title || p.caption || 'Tanpa Judul'}
                      </div>
                      <div className="text-[11px] text-kumo-subtle truncate">
                        Oleh: {p.seller?.full_name || 'Siswa'} • {p.post_type}
                      </div>
                    </div>
                  </div>
                  <div className="text-right shrink-0">
                    <div className="text-xs font-semibold text-kumo-default">
                      {p.price > 0 ? `Rp ${p.price.toLocaleString('id-ID')}` : 'Diskusi'}
                    </div>
                    <div className="text-[10px] text-kumo-subtle">
                      {new Date(p.created_at).toLocaleDateString('id-ID')}
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </LayerCard>
      </div>

      {/* Quick Action Banner */}
      <LayerCard className="p-6 border border-kumo-hairline bg-indigo-50/50 rounded-xl flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h3 className="text-sm font-semibold text-indigo-950 flex items-center gap-1.5">
            <Sparkles className="h-4 w-4 text-indigo-600" />
            <span>Akses Cepat Pengelolaan Sekolah</span>
          </h3>
          <p className="text-xs text-indigo-700/80 mt-0.5">
            Kelola titik temu kampus SMKN 8 atau tinjau akun siswa yang memerlukan verifikasi.
          </p>
        </div>
        <div className="flex items-center gap-2.5 shrink-0 flex-wrap">
          <Button
            variant="secondary"
            className="text-xs h-9 px-3 bg-white hover:bg-slate-50 border border-indigo-200 text-indigo-900"
            onClick={() => onNavigateTab('meeting-points')}
          >
            Kelola Titik Temu COD
          </Button>
          <Button
            variant="primary"
            className="text-xs h-9 px-3 bg-indigo-600 hover:bg-indigo-700 text-white"
            onClick={() => onNavigateTab('users')}
          >
            Kelola Otorisasi Akun
          </Button>
        </div>
      </LayerCard>
    </div>
  );
}
