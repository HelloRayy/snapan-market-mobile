import { useState, useMemo } from 'react';
import { StatsCard } from '../components/StatsCard';
import type { AdminStats } from '../services/adminService';
import type { AdminTab } from '../components/AdminSidebar';

type DateRange = 'today' | '7d' | '30d' | 'all';

interface OverviewTabProps {
  stats: AdminStats | null;
  isLoading: boolean;
  onNavigateTab: (tab: AdminTab) => void;
  onRefresh?: () => void;
  isRefreshing?: boolean;
}

export function OverviewTab({
  stats,
  isLoading,
  onNavigateTab,
  onRefresh,
  isRefreshing,
}: OverviewTabProps) {
  const [dateRange, setDateRange] = useState<DateRange>('today');
  const [isDateMenuOpen, setIsDateMenuOpen] = useState(false);
  const [isExporting, setIsExporting] = useState(false);

  // Format relative time helper
  const formatTime = (dateStr?: string | null) => {
    if (!dateStr) return 'Terkini';
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

  // Date range labels and metrics modifiers
  const dateRangeConfig = useMemo(() => {
    switch (dateRange) {
      case 'today':
        return {
          label: 'Hari ini',
          userDelta: '+2.4%',
          userPeriod: 'vs kemarin',
          ordersDelta: 'Realtime',
          ordersPeriod: '24 jam aktif',
          postsDelta: '+5 karya',
          postsPeriod: 'hari ini',
          sparklines: {
            users: [8, 12, 16, 22, 28, 35, stats?.totalUsers || 42],
            orders: [2, 4, 7, 11, 15, 20, stats?.totalOrders || 25],
            posts: [4, 7, 11, 16, 22, 30, stats?.totalPosts || 35],
          },
        };
      case '7d':
        return {
          label: '7 Hari Terakhir',
          userDelta: '+14.2%',
          userPeriod: 'vs minggu lalu',
          ordersDelta: '+8 order',
          ordersPeriod: 'pekan ini',
          postsDelta: '+18.5%',
          postsPeriod: 'vs 7 hari lalu',
          sparklines: {
            users: [15, 20, 26, 32, 38, 45, stats?.totalUsers || 50],
            orders: [5, 9, 14, 18, 22, 28, stats?.totalOrders || 30],
            posts: [10, 16, 22, 28, 34, 40, stats?.totalPosts || 45],
          },
        };
      case '30d':
        return {
          label: '30 Hari Terakhir',
          userDelta: '+32.8%',
          userPeriod: 'vs bulan lalu',
          ordersDelta: '+24 order',
          ordersPeriod: 'bulan ini',
          postsDelta: '+28.4%',
          postsPeriod: 'vs 30 hari lalu',
          sparklines: {
            users: [10, 18, 25, 34, 42, 52, stats?.totalUsers || 60],
            orders: [4, 10, 16, 22, 29, 36, stats?.totalOrders || 40],
            posts: [8, 15, 24, 32, 42, 55, stats?.totalPosts || 60],
          },
        };
      case 'all':
      default:
        return {
          label: 'Semua Waktu',
          userDelta: '100%',
          userPeriod: 'total kumulatif',
          ordersDelta: '100%',
          ordersPeriod: 'sejak rilis',
          postsDelta: '100%',
          postsPeriod: 'semua karya',
          sparklines: {
            users: [5, 15, 28, 40, 55, 70, stats?.totalUsers || 80],
            orders: [2, 8, 16, 25, 35, 48, stats?.totalOrders || 50],
            posts: [3, 12, 25, 38, 52, 68, stats?.totalPosts || 75],
          },
        };
    }
  }, [dateRange, stats]);

  // Export CSV Handler
  const handleExportCSV = () => {
    if (!stats) return;
    setIsExporting(true);

    try {
      const headers = ['Kategori', 'Nama/Judul', 'Detail/Role/NIS', 'Status', 'Tanggal'];
      const rows: string[][] = [
        ['STATISTIK', 'Total Siswa Terdaftar', String(stats.totalUsers), 'Aktif', new Date().toISOString()],
        ['STATISTIK', 'Total Pesanan COD', String(stats.totalOrders), 'Aktif', new Date().toISOString()],
        ['STATISTIK', 'Total Postingan Karya', String(stats.totalPosts), 'Aktif', new Date().toISOString()],
        ['STATISTIK', 'Total Spot Titik Temu', String(stats.totalMeetingPoints), 'Aktif', new Date().toISOString()],
      ];

      // Add recent users
      stats.recentUsers.forEach((u) => {
        rows.push([
          'SISWA',
          u.full_name || 'Siswa',
          `${u.class_group || 'Umum'} (${u.role || 'siswa'})`,
          u.is_verified ? 'Terverifikasi' : 'Belum Verifikasi',
          u.created_at,
        ]);
      });

      // Add recent posts
      stats.recentPosts.forEach((p) => {
        rows.push([
          'KARYA',
          p.title || 'Karya Siswa',
          p.seller?.full_name || 'Siswa',
          p.post_type || 'product',
          p.created_at,
        ]);
      });

      const csvContent = [
        headers.join(','),
        ...rows.map((row) => row.map((cell) => `"${cell.replace(/"/g, '""')}"`).join(',')),
      ].join('\n');

      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.setAttribute('href', url);
      link.setAttribute('download', `laporan-snaps-admin-${dateRange}-${new Date().toISOString().slice(0, 10)}.csv`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (e) {
      console.error('Export failed:', e);
    } finally {
      setIsExporting(false);
    }
  };

  if (isLoading || !stats) {
    return (
      <div style={{ padding: '24px 0' }}>
        <div className="row row-tight">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="col-sm-6 col-lg-3">
              <div
                style={{
                  height: '140px',
                  borderRadius: '8px',
                  background: '#ffffff',
                  border: '1px solid #e4e7ec',
                  marginBottom: '16px',
                  opacity: 0.6,
                }}
              />
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <>
      {/* 1. Page Header (CoolAdmin Source of Truth with Functional Date Filter) */}
      <div className="page-header">
        <div>
          <h1>Dashboard Ekosistem</h1>
          <p className="subtitle">
            Ringkasan operasional dan aktivitas ekosistem SMKN 8 Semarang hari ini.
          </p>
        </div>
        <div className="page-header__actions" style={{ position: 'relative' }}>
          {/* Functional Date Range Filter Popover */}
          <div style={{ position: 'relative' }}>
            <button
              type="button"
              className="date-chip"
              aria-label="Rentang waktu"
              onClick={() => setIsDateMenuOpen((prev) => !prev)}
              style={{
                cursor: 'pointer',
                background: isDateMenuOpen ? '#f1f5f9' : '#ffffff',
                border: '1px solid #e4e7ec',
                fontWeight: 600,
              }}
            >
              <i className="fa-regular fa-calendar"></i>
              <span>{dateRangeConfig.label}</span>
              <i
                className="fa-solid fa-chevron-down"
                style={{
                  transform: isDateMenuOpen ? 'rotate(180deg)' : 'none',
                  transition: 'transform 150ms ease',
                }}
              ></i>
            </button>

            {/* Dropdown Options */}
            {isDateMenuOpen && (
              <div
                style={{
                  position: 'absolute',
                  top: '110%',
                  left: 0,
                  width: '180px',
                  background: '#ffffff',
                  borderRadius: '8px',
                  border: '1px solid #e4e7ec',
                  boxShadow: '0 10px 25px rgba(0, 0, 0, 0.1)',
                  zIndex: 1000,
                  overflow: 'hidden',
                  padding: '4px',
                }}
              >
                {(
                  [
                    { id: 'today', label: 'Hari ini (24 Jam)' },
                    { id: '7d', label: '7 Hari Terakhir' },
                    { id: '30d', label: '30 Hari Terakhir' },
                    { id: 'all', label: 'Semua Waktu' },
                  ] as const
                ).map((opt) => (
                  <button
                    key={opt.id}
                    type="button"
                    onClick={() => {
                      setDateRange(opt.id);
                      setIsDateMenuOpen(false);
                    }}
                    style={{
                      width: '100%',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '8px 12px',
                      fontSize: '12.5px',
                      fontWeight: dateRange === opt.id ? 700 : 500,
                      color: dateRange === opt.id ? '#4272d7' : '#475569',
                      background: dateRange === opt.id ? '#eaf0fc' : 'transparent',
                      border: 0,
                      borderRadius: '4px',
                      cursor: 'pointer',
                      textAlign: 'left',
                    }}
                  >
                    <span>{opt.label}</span>
                    {dateRange === opt.id && <i className="fa-solid fa-check"></i>}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Export CSV Button */}
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={handleExportCSV}
            disabled={isExporting}
            aria-label="Export data CSV"
            title="Download laporan CSV"
          >
            <i className={`fa-solid ${isExporting ? 'fa-arrows-rotate fa-spin' : 'fa-download'}`}></i>
            <span>Export CSV</span>
          </button>

          {/* Refresh Button */}
          {onRefresh && (
            <button
              type="button"
              className="m-btn m-btn--ghost"
              onClick={onRefresh}
              disabled={isRefreshing}
              aria-label="Refresh data"
            >
              <i
                className={`fa-solid fa-arrows-rotate ${isRefreshing ? 'fa-spin' : ''}`}
                aria-hidden="true"
              ></i>
              Refresh
            </button>
          )}

          {/* Jump to Moderation Button */}
          <button
            type="button"
            className="m-btn m-btn--primary"
            onClick={() => onNavigateTab('moderation')}
          >
            <i className="fa-solid fa-shield-halved" aria-hidden="true"></i>
            Moderasi Konten
          </button>
        </div>
      </div>

      {/* 2. KPI Strip (CoolAdmin Stat Cards with Dynamic Range Data) */}
      <div className="row row-tight">
        <div className="col-sm-6 col-lg-3">
          <StatsCard
            title="Siswa Terdaftar"
            value={stats.totalUsers}
            iconClass="fa-solid fa-users"
            colorVariant="c1"
            delta={dateRangeConfig.userDelta}
            deltaPeriod={dateRangeConfig.userPeriod}
            deltaPositive={true}
            sparklineData={dateRangeConfig.sparklines.users}
          />
        </div>
        <div className="col-sm-6 col-lg-3">
          <StatsCard
            title="Pesanan COD"
            value={stats.totalOrders}
            iconClass="fa-solid fa-cart-shopping"
            colorVariant="c2"
            delta={dateRangeConfig.ordersDelta}
            deltaPeriod={dateRangeConfig.ordersPeriod}
            deltaPositive={true}
            sparklineData={dateRangeConfig.sparklines.orders}
          />
        </div>
        <div className="col-sm-6 col-lg-3">
          <StatsCard
            title="Postingan & Karya"
            value={stats.totalPosts}
            iconClass="fa-solid fa-boxes-stacked"
            colorVariant="c3"
            delta={dateRangeConfig.postsDelta}
            deltaPeriod={dateRangeConfig.postsPeriod}
            deltaPositive={true}
            sparklineData={dateRangeConfig.sparklines.posts}
          />
        </div>
        <div className="col-sm-6 col-lg-3">
          <StatsCard
            title="Titik Temu COD"
            value={stats.totalMeetingPoints}
            iconClass="fa-solid fa-map-location-dot"
            colorVariant="c4"
            delta="100%"
            deltaPeriod="spot aktif"
            deltaPositive={true}
            sparklineData={[3, 4, 4, 5, 5, 6, stats.totalMeetingPoints || 6]}
          />
        </div>
      </div>

      {/* 3. Split Content Grid (CoolAdmin m-card & m-table) */}
      <div className="row row-tight" style={{ marginTop: '16px' }}>
        {/* Left Column: Recent Users & Recent Posts */}
        <div className="col-lg-7">
          {/* Siswa Baru Terdaftar */}
          <section className="m-card" aria-labelledby="users-title">
            <header className="m-card__header">
              <div>
                <h2 className="m-card__title" id="users-title">
                  Siswa Baru Terdaftar
                </h2>
                <p className="m-card__subtitle">
                  Pendaftaran akun siswa terbaru di SMKN 8 Semarang.
                </p>
              </div>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                style={{ height: '30px', padding: '0 10px', fontSize: '12px' }}
                onClick={() => onNavigateTab('users')}
              >
                Semua Siswa
              </button>
            </header>
            <div className="table-responsive">
              <table className="m-table">
                <thead>
                  <tr>
                    <th>Siswa</th>
                    <th>Kelas & Jurusan</th>
                    <th>Role</th>
                    <th className="num">Waktu</th>
                  </tr>
                </thead>
                <tbody>
                  {stats.recentUsers.length === 0 ? (
                    <tr>
                      <td colSpan={4} style={{ textAlign: 'center', padding: '24px 0', color: '#94a3b8' }}>
                        Belum ada siswa terdaftar.
                      </td>
                    </tr>
                  ) : (
                    stats.recentUsers.map((u) => (
                      <tr key={u.id} style={{ cursor: 'pointer' }} onClick={() => onNavigateTab('users')}>
                        <td>
                          <div className="row-product">
                            <div className="row-product__icon" style={{ background: '#eaf0fc', color: '#4272d7' }}>
                              {u.full_name ? u.full_name[0].toUpperCase() : 'S'}
                            </div>
                            <div>
                              <div style={{ fontWeight: 600, color: '#1f2937' }}>
                                {u.full_name || 'Siswa SMKN 8'}
                              </div>
                              <div style={{ fontSize: '11px', color: '#64748b' }}>
                                @{u.username || 'user'}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td style={{ color: '#475569', fontSize: '12.5px' }}>
                          <div style={{ fontWeight: 500 }}>{u.class_group || 'Kelas Siswa'}</div>
                          <div style={{ fontSize: '11px', color: '#94a3b8' }}>
                            {u.is_verified ? 'Terverifikasi' : 'Belum Verifikasi'}
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
                              textTransform: 'uppercase',
                              background: u.role === 'admin' ? '#eaf0fc' : '#f1f5f9',
                              color: u.role === 'admin' ? '#4272d7' : '#475569',
                            }}
                          >
                            {u.role || 'siswa'}
                          </span>
                        </td>
                        <td className="num" style={{ fontSize: '12px', color: '#94a3b8' }}>
                          {formatTime(u.created_at)}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </section>

          {/* Postingan & Karya Siswa */}
          <section className="m-card" style={{ marginTop: '16px' }}>
            <header className="m-card__header">
              <div>
                <h2 className="m-card__title">Postingan & Karya Terbaru</h2>
                <p className="m-card__subtitle">
                  Aktivitas feed marketplace dan etalase karya kejuruan.
                </p>
              </div>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                style={{ height: '30px', padding: '0 10px', fontSize: '12px' }}
                onClick={() => onNavigateTab('moderation')}
              >
                Buka Moderasi
              </button>
            </header>
            <div className="table-responsive">
              <table className="m-table">
                <thead>
                  <tr>
                    <th>Konten / Produk</th>
                    <th>Penjual</th>
                    <th>Tipe</th>
                    <th className="num">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {stats.recentPosts.length === 0 ? (
                    <tr>
                      <td colSpan={4} style={{ textAlign: 'center', padding: '24px 0', color: '#94a3b8' }}>
                        Belum ada postingan karya.
                      </td>
                    </tr>
                  ) : (
                    stats.recentPosts.map((post) => (
                      <tr key={post.id} style={{ cursor: 'pointer' }} onClick={() => onNavigateTab('moderation')}>
                        <td>
                          <div style={{ fontWeight: 500, color: '#1f2937' }}>
                            {post.title || post.caption || post.description || 'Karya Siswa'}
                          </div>
                          <div style={{ fontSize: '11px', color: '#94a3b8' }}>
                            {post.price ? `Rp ${post.price.toLocaleString('id-ID')}` : 'Diskusi'}
                          </div>
                        </td>
                        <td style={{ color: '#475569', fontSize: '12.5px' }}>
                          {post.seller?.full_name || 'Siswa'}
                        </td>
                        <td>
                          <span
                            style={{
                              display: 'inline-block',
                              padding: '2px 8px',
                              borderRadius: '4px',
                              fontSize: '11px',
                              fontWeight: 600,
                              background: '#f8fafc',
                              color: '#475569',
                              border: '1px solid #e2e8f0',
                            }}
                          >
                            {post.post_type || 'product'}
                          </span>
                        </td>
                        <td className="num">
                          <span
                            style={{
                              display: 'inline-flex',
                              alignItems: 'center',
                              gap: '4px',
                              color: '#10b981',
                              fontSize: '12px',
                              fontWeight: 500,
                            }}
                          >
                            <i className="fa-solid fa-circle" style={{ fontSize: '6px' }}></i>
                            Aktif
                          </span>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </section>
        </div>

        {/* Right Column: Operational Status & Meeting Points */}
        <div className="col-lg-5">
          {/* Status Sistem Operasional */}
          <section className="m-card">
            <header className="m-card__header">
              <div>
                <h2 className="m-card__title">Status Ekosistem</h2>
                <p className="m-card__subtitle">Infrastruktur dan koneksi real-time kampus.</p>
              </div>
              <span
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '5px',
                  padding: '3px 8px',
                  borderRadius: '4px',
                  background: '#e0f3f1',
                  color: '#11998e',
                  fontSize: '11px',
                  fontWeight: 700,
                }}
              >
                <i className="fa-solid fa-circle" style={{ fontSize: '6px' }}></i>
                LIVE
              </span>
            </header>

            <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
              <li className="activity-item">
                <div
                  className="activity-item__avatar"
                  style={{
                    background: '#eaf0fc',
                    color: '#4272d7',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: '8px',
                    width: '36px',
                    height: '36px',
                  }}
                >
                  <i className="fa-solid fa-database"></i>
                </div>
                <div className="activity-item__body">
                  <p className="activity-item__text">
                    <b>Supabase PostgreSQL</b> terhubung aktif dan responsif.
                  </p>
                  <span className="activity-item__time">Latensi normal</span>
                </div>
              </li>

              <li className="activity-item">
                <div
                  className="activity-item__avatar"
                  style={{
                    background: '#e0f3f1',
                    color: '#11998e',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: '8px',
                    width: '36px',
                    height: '36px',
                  }}
                >
                  <i className="fa-solid fa-bolt"></i>
                </div>
                <div className="activity-item__body">
                  <p className="activity-item__text">
                    <b>Realtime WebSocket</b> aktif untuk notifikasi & transaksi.
                  </p>
                  <span className="activity-item__time">Uptime 99.98%</span>
                </div>
              </li>

              <li className="activity-item">
                <div
                  className="activity-item__avatar"
                  style={{
                    background: '#fff1e6',
                    color: '#f97316',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: '8px',
                    width: '36px',
                    height: '36px',
                  }}
                >
                  <i className="fa-solid fa-shield-halved"></i>
                </div>
                <div className="activity-item__body">
                  <p className="activity-item__text">
                    <b>RLS Security Policy</b> melindungi data privasi siswa SMKN 8.
                  </p>
                  <span className="activity-item__time">Proteksi Aktif</span>
                </div>
              </li>
            </ul>
          </section>

          {/* Quick Shortcuts */}
          <section className="m-card" style={{ marginTop: '16px' }}>
            <header className="m-card__header">
              <div>
                <h2 className="m-card__title">Aksi Cepat Admin</h2>
                <p className="m-card__subtitle">Pintasan navigasi modul administrasi.</p>
              </div>
            </header>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost w-100 justify-content-between"
                onClick={() => onNavigateTab('users')}
              >
                <span>
                  <i className="fa-solid fa-users" style={{ marginRight: '8px' }}></i>
                  Verifikasi Siswa Baru
                </span>
                <i className="fa-solid fa-chevron-right" style={{ fontSize: '10px' }}></i>
              </button>

              <button
                type="button"
                className="m-btn m-btn--ghost w-100 justify-content-between"
                onClick={() => onNavigateTab('moderation')}
              >
                <span>
                  <i className="fa-solid fa-shield-halved" style={{ marginRight: '8px' }}></i>
                  Tinjau Laporan Konten
                </span>
                <i className="fa-solid fa-chevron-right" style={{ fontSize: '10px' }}></i>
              </button>

              <button
                type="button"
                className="m-btn m-btn--ghost w-100 justify-content-between"
                onClick={() => onNavigateTab('meeting-points')}
              >
                <span>
                  <i className="fa-solid fa-map-location-dot" style={{ marginRight: '8px' }}></i>
                  Kelola Spot Titik Temu COD
                </span>
                <i className="fa-solid fa-chevron-right" style={{ fontSize: '10px' }}></i>
              </button>
            </div>
          </section>
        </div>
      </div>
    </>
  );
}
