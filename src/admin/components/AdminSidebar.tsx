export type AdminTab = 'overview' | 'users' | 'moderation' | 'meeting-points';

interface AdminSidebarProps {
  activeTab: AdminTab;
  onTabChange: (tab: AdminTab) => void;
  onLogout: () => void;
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
}

export function AdminSidebar({
  activeTab,
  onTabChange,
  onLogout,
  onCloseMobile,
}: AdminSidebarProps) {
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
              width: '32px',
              height: '32px',
              borderRadius: '8px',
              background: '#4272d7',
              color: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: 800,
              fontSize: '15px',
              boxShadow: '0 2px 6px rgba(66, 114, 215, 0.4)',
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

      {/* Navigation List */}
      <div className="menu-sidebar__content">
        <nav className="navbar-sidebar">
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
                Overview Ekosistem
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
                Direktori Siswa
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
                Moderasi Konten
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
                Titik Temu COD
              </a>
            </li>
          </ul>
        </nav>

        {/* Footer info & logout in sidebar */}
        <div style={{ padding: '20px 14px', borderTop: '1px solid rgba(255, 255, 255, 0.06)' }}>
          <div
            style={{
              padding: '12px',
              borderRadius: '6px',
              background: 'rgba(255, 255, 255, 0.04)',
              border: '1px solid rgba(255, 255, 255, 0.06)',
              marginBottom: '12px',
            }}
          >
            <div className="d-flex align-items-center justify-content-between">
              <span style={{ fontSize: '11px', color: '#cbd5e1', fontWeight: 600 }}>
                Status Database
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
                <i className="fa-solid fa-circle" style={{ fontSize: '7px' }}></i>
                LIVE
              </span>
            </div>
            <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
              Supabase PostgreSQL
            </div>
          </div>

          <button
            type="button"
            onClick={onLogout}
            className="w-100 text-start"
            style={{
              background: 'rgba(239, 68, 68, 0.1)',
              border: '1px solid rgba(239, 68, 68, 0.2)',
              color: '#f87171',
              borderRadius: '6px',
              padding: '9px 12px',
              fontSize: '13px',
              fontWeight: 600,
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              cursor: 'pointer',
              transition: 'background 120ms ease',
            }}
          >
            <i className="fa-solid fa-arrow-right-from-bracket"></i>
            Keluar dari Admin
          </button>
        </div>
      </div>
    </aside>
  );
}
