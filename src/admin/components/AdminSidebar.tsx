import type { ProfileRow, AdminStats } from '../services/adminService';
import { UserAvatar } from './UserAvatar';

export type AdminTab = 'overview' | 'users' | 'moderation' | 'meeting-points' | 'server';

interface AdminSidebarProps {
  activeTab: AdminTab;
  onTabChange: (tab: AdminTab) => void;
  onLogout: () => void;
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
  adminProfile?: ProfileRow | null;
  adminEmail?: string;
  stats?: AdminStats | null;
}

export function AdminSidebar({
  activeTab,
  onTabChange,
  onLogout,
  onCloseMobile,
  adminProfile,
  adminEmail = 'admin@snapan.id',
  stats,
}: AdminSidebarProps) {
  const displayName = adminProfile?.full_name || adminEmail.split('@')[0] || 'Administrator';
  const displayUsername = adminProfile?.username ? `@${adminProfile.username}` : adminEmail;

  return (
    <aside className="menu-sidebar" id="main-sidebar">
      {/* Brand Header */}
      <div className="logo d-flex align-items-center justify-content-between">
        <a
          href="#/admin"
          onClick={(e) => {
            e.preventDefault();
            onTabChange('overview');
          }}
          className="d-flex align-items-center text-decoration-none"
          style={{ gap: '10px' }}
        >
          <div
            style={{
              width: '34px',
              height: '34px',
              borderRadius: '8px',
              background: '#4272d7',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 800,
              fontSize: '16px',
              boxShadow: '0 2px 8px rgba(66, 114, 215, 0.45)',
            }}
          >
            8
          </div>
          <div>
            <div
              style={{
                fontSize: '15px',
                fontWeight: 700,
                color: '#ffffff',
                lineHeight: 1.2,
                letterSpacing: '-0.01em',
              }}
            >
              Snaps<span style={{ color: '#93b4ec' }}>Admin</span>
            </div>
            <div
              style={{
                fontSize: '11px',
                color: '#94a3b8',
                fontWeight: 500,
              }}
            >
              SMKN 8 Semarang
            </div>
          </div>
        </a>

        {/* Mobile close button */}
        {onCloseMobile && (
          <button
            type="button"
            className="sidebar-close d-lg-none"
            onClick={onCloseMobile}
            aria-label="Tutup navigasi"
            style={{
              background: 'transparent',
              border: 0,
              color: '#94a3b8',
              fontSize: '18px',
              padding: '6px',
              cursor: 'pointer',
            }}
          >
            <i className="fa-solid fa-xmark"></i>
          </button>
        )}
      </div>

      {/* Navigation List & Admin Profile */}
      <div
        className="menu-sidebar__content"
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          minHeight: 'calc(100vh - 64px)',
        }}
      >
        <nav className="navbar-sidebar" style={{ flex: 1 }}>
          <ul className="list-unstyled navbar__list">
            <div className="nav-group-label">Main Dashboard</div>
            <li className={activeTab === 'overview' ? 'active' : ''}>
              <a
                href="#overview"
                onClick={(e) => {
                  e.preventDefault();
                  onTabChange('overview');
                  onCloseMobile?.();
                }}
              >
                <i className="fa-solid fa-gauge-high"></i>
                <span style={{ flex: 1 }}>Overview Ekosistem</span>
              </a>
            </li>

            <div className="nav-group-label">Manajemen & Keamanan</div>
            <li className={activeTab === 'users' ? 'active' : ''}>
              <a
                href="#users"
                onClick={(e) => {
                  e.preventDefault();
                  onTabChange('users');
                  onCloseMobile?.();
                }}
              >
                <i className="fa-solid fa-users"></i>
                <span style={{ flex: 1 }}>Direktori Siswa</span>
                {stats?.totalUsers != null && stats.totalUsers > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: '10px',
                      background: activeTab === 'users' ? '#ffffff' : 'rgba(255, 255, 255, 0.12)',
                      color: activeTab === 'users' ? '#4272d7' : '#94a3b8',
                      fontVariantNumeric: 'tabular-nums',
                    }}
                  >
                    {stats.totalUsers}
                  </span>
                )}
              </a>
            </li>

            <li className={activeTab === 'moderation' ? 'active' : ''}>
              <a
                href="#moderation"
                onClick={(e) => {
                  e.preventDefault();
                  onTabChange('moderation');
                  onCloseMobile?.();
                }}
              >
                <i className="fa-solid fa-shield-halved"></i>
                <span style={{ flex: 1 }}>Moderasi Konten</span>
                {stats?.totalPosts != null && stats.totalPosts > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: '10px',
                      background: activeTab === 'moderation' ? '#ffffff' : 'rgba(255, 255, 255, 0.12)',
                      color: activeTab === 'moderation' ? '#4272d7' : '#94a3b8',
                      fontVariantNumeric: 'tabular-nums',
                    }}
                  >
                    {stats.totalPosts}
                  </span>
                )}
              </a>
            </li>

            <div className="nav-group-label">Logistik Kampus</div>
            <li className={activeTab === 'meeting-points' ? 'active' : ''}>
              <a
                href="#meeting-points"
                onClick={(e) => {
                  e.preventDefault();
                  onTabChange('meeting-points');
                  onCloseMobile?.();
                }}
              >
                <i className="fa-solid fa-map-location-dot"></i>
                <span style={{ flex: 1 }}>Titik Temu COD</span>
                {stats?.totalMeetingPoints != null && stats.totalMeetingPoints > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: '10px',
                      background: activeTab === 'meeting-points' ? '#ffffff' : 'rgba(255, 255, 255, 0.12)',
                      color: activeTab === 'meeting-points' ? '#4272d7' : '#94a3b8',
                      fontVariantNumeric: 'tabular-nums',
                    }}
                  >
                    {stats.totalMeetingPoints}
                  </span>
                )}
              </a>
            </li>

            <div className="nav-group-label">Infrastruktur & Sistem</div>
            <li className={activeTab === 'server' ? 'active' : ''}>
              <a
                href="#server"
                onClick={(e) => {
                  e.preventDefault();
                  onTabChange('server');
                  onCloseMobile?.();
                }}
              >
                <i className="fa-solid fa-server"></i>
                <span style={{ flex: 1 }}>Status Server & DB</span>
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '5px',
                    fontSize: '10px',
                    fontWeight: 700,
                    padding: '2px 7px',
                    borderRadius: '10px',
                    background: activeTab === 'server' ? '#ffffff' : 'rgba(16, 185, 129, 0.18)',
                    color: activeTab === 'server' ? '#059669' : '#34d399',
                  }}
                >
                  <span
                    style={{
                      width: '6px',
                      height: '6px',
                      borderRadius: '50%',
                      background: '#10b981',
                      display: 'inline-block',
                    }}
                  />
                  LIVE
                </span>
              </a>
            </li>
          </ul>
        </nav>

        {/* Bottom Section: Connected Profile Card, Live DB, Logout */}
        <div style={{ padding: '16px 14px', borderTop: '1px solid rgba(255, 255, 255, 0.08)' }}>
          {/* Connected Admin Profile Card */}
          <div
            style={{
              padding: '10px 12px',
              borderRadius: '8px',
              background: 'rgba(255, 255, 255, 0.05)',
              border: '1px solid rgba(255, 255, 255, 0.08)',
              marginBottom: '10px',
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
            }}
          >
            <UserAvatar
              avatarUrl={adminProfile?.avatar_url}
              name={displayName}
              size={36}
              role={adminProfile?.role || 'admin'}
              style={{
                border: '1px solid rgba(255, 255, 255, 0.2)',
              }}
            />

            <div style={{ flex: 1, minWidth: 0 }}>
              <div
                style={{
                  fontSize: '12.5px',
                  fontWeight: 600,
                  color: '#ffffff',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  lineHeight: 1.2,
                }}
              >
                {displayName}
              </div>
              <div
                style={{
                  fontSize: '10.5px',
                  color: '#94a3b8',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {displayUsername}
              </div>
            </div>

            <span
              style={{
                fontSize: '9.5px',
                fontWeight: 700,
                padding: '2px 6px',
                borderRadius: '4px',
                background: 'rgba(66, 114, 215, 0.3)',
                color: '#93b4ec',
                border: '1px solid rgba(66, 114, 215, 0.4)',
                textTransform: 'uppercase',
              }}
            >
              Admin
            </span>
          </div>

          {/* Database Live Ping */}
          <div
            style={{
              padding: '8px 12px',
              borderRadius: '6px',
              background: 'rgba(255, 255, 255, 0.03)',
              border: '1px solid rgba(255, 255, 255, 0.05)',
              marginBottom: '10px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <span style={{ fontSize: '11px', color: '#94a3b8' }}>
              Database PostgreSQL
            </span>
            <span
              style={{
                fontSize: '10px',
                color: '#10b981',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                gap: '5px',
              }}
            >
              <i className="fa-solid fa-circle" style={{ fontSize: '6px' }}></i>
              LIVE
            </span>
          </div>

          {/* Logout Button */}
          <button
            type="button"
            onClick={onLogout}
            className="w-100 text-start"
            style={{
              background: 'rgba(239, 68, 68, 0.12)',
              border: '1px solid rgba(239, 68, 68, 0.25)',
              color: '#f87171',
              borderRadius: '6px',
              padding: '9px 12px',
              fontSize: '12.5px',
              fontWeight: 600,
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              cursor: 'pointer',
              transition: 'all 120ms ease',
            }}
          >
            <i className="fa-solid fa-arrow-right-from-bracket"></i>
            <span>Keluar dari Admin</span>
          </button>
        </div>
      </div>
    </aside>
  );
}
