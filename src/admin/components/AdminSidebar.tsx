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
                color: '#1f2937',
                lineHeight: 1.2,
                letterSpacing: '-0.01em',
              }}
            >
              Snaps<span style={{ color: '#4272d7' }}>Admin</span>
            </div>
            <div
              style={{
                fontSize: '11px',
                color: '#64748b',
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
            <div className="nav-group-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
              Menu Utama
            </div>
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
                <span style={{ flex: 1, whiteSpace: 'nowrap' }}>Ringkasan</span>
              </a>
            </li>

            <div className="nav-group-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
              Manajemen
            </div>
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
                <span style={{ flex: 1, whiteSpace: 'nowrap' }}>Data Siswa</span>
                {stats?.totalUsers != null && stats.totalUsers > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: '10px',
                      background: activeTab === 'users' ? '#4272d7' : '#f1f5f9',
                      color: activeTab === 'users' ? '#ffffff' : '#64748b',
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
                <span style={{ flex: 1, whiteSpace: 'nowrap' }}>Moderasi</span>
                {stats?.totalPosts != null && stats.totalPosts > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: '10px',
                      background: activeTab === 'moderation' ? '#4272d7' : '#f1f5f9',
                      color: activeTab === 'moderation' ? '#ffffff' : '#64748b',
                      fontVariantNumeric: 'tabular-nums',
                    }}
                  >
                    {stats.totalPosts}
                  </span>
                )}
              </a>
            </li>

            <div className="nav-group-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
              Logistik
            </div>
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
                <span style={{ flex: 1, whiteSpace: 'nowrap' }}>Titik COD</span>
                {stats?.totalMeetingPoints != null && stats.totalMeetingPoints > 0 && (
                  <span
                    style={{
                      fontSize: '10px',
                      fontWeight: 700,
                      padding: '2px 7px',
                      borderRadius: '10px',
                      background: activeTab === 'meeting-points' ? '#4272d7' : '#f1f5f9',
                      color: activeTab === 'meeting-points' ? '#ffffff' : '#64748b',
                      fontVariantNumeric: 'tabular-nums',
                    }}
                  >
                    {stats.totalMeetingPoints}
                  </span>
                )}
              </a>
            </li>

            <div className="nav-group-label" style={{ textTransform: 'none', letterSpacing: 'normal' }}>
              Infrastruktur
            </div>
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
                <span style={{ flex: 1, whiteSpace: 'nowrap' }}>Status Server</span>
                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '4px',
                    fontSize: '10px',
                    fontWeight: 700,
                    padding: '2px 6px',
                    borderRadius: '10px',
                    background: activeTab === 'server' ? '#4272d7' : '#e0f3f1',
                    color: activeTab === 'server' ? '#ffffff' : '#059669',
                  }}
                >
                  <span
                    style={{
                      width: '6px',
                      height: '6px',
                      borderRadius: '50%',
                      background: activeTab === 'server' ? '#ffffff' : '#10b981',
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
        <div style={{ padding: '16px 14px', borderTop: '1px solid #e4e7ec' }}>
          {/* Connected Admin Profile Card */}
          <div
            style={{
              padding: '10px 12px',
              borderRadius: '8px',
              background: '#f8fafc',
              border: '1px solid #e4e7ec',
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
                border: '1px solid #d4e2fa',
              }}
            />

            <div style={{ flex: 1, minWidth: 0 }}>
              <div
                style={{
                  fontSize: '12.5px',
                  fontWeight: 600,
                  color: '#1f2937',
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
                  color: '#64748b',
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
                fontSize: '10px',
                fontWeight: 700,
                padding: '2px 6px',
                borderRadius: '4px',
                background: '#eaf0fc',
                color: '#4272d7',
                border: '1px solid #d4e2fa',
                textTransform: 'none',
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
              background: '#f8fafc',
              border: '1px solid #e4e7ec',
              marginBottom: '10px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <span style={{ fontSize: '11px', color: '#64748b', fontWeight: 500 }}>
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
              background: '#fff1f2',
              border: '1px solid #fecdd3',
              color: '#e11d48',
              borderRadius: '6px',
              padding: '9px 12px',
              fontSize: '12.5px',
              fontWeight: 600,
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              cursor: 'pointer',
              transition: 'background-color 120ms ease',
            }}
            onMouseEnter={(e) => (e.currentTarget.style.background = '#ffe4e6')}
            onMouseLeave={(e) => (e.currentTarget.style.background = '#fff1f2')}
          >
            <i className="fa-solid fa-arrow-right-from-bracket"></i>
            <span>Keluar dari Admin</span>
          </button>
        </div>
      </div>
    </aside>
  );
}
