import type { AdminTab } from './AdminSidebar';

interface AdminHeaderProps {
  activeTab: AdminTab;
  adminEmail: string;
  adminRole: string;
  onRefresh?: () => void;
  isRefreshing?: boolean;
  onToggleMobileSidebar?: () => void;
  searchQuery?: string;
  onSearchChange?: (q: string) => void;
}

export function AdminHeader({
  adminEmail,
  onRefresh,
  isRefreshing,
  onToggleMobileSidebar,
  searchQuery = '',
  onSearchChange,
}: AdminHeaderProps) {
  const initial = adminEmail ? adminEmail[0].toUpperCase() : 'A';
  const username = adminEmail ? adminEmail.split('@')[0] : 'admin';

  return (
    <header className="header-desktop">
      <div className="section__content section__content--p30">
        <div className="container-fluid">
          <div className="header-wrap">
            {/* Mobile Hamburger Drawer Trigger */}
            <button
              className="sidebar-toggle d-lg-none"
              type="button"
              aria-label="Toggle navigation"
              onClick={onToggleMobileSidebar}
              style={{
                width: '38px',
                height: '38px',
                background: 'transparent',
                border: '1px solid #e4e7ec',
                borderRadius: '6px',
                color: '#475569',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'pointer',
                marginRight: '12px',
              }}
            >
              <i className="fa-solid fa-bars" aria-hidden="true"></i>
            </button>

            {/* Quick Search Bar */}
            <form
              className="form-header"
              role="search"
              onSubmit={(e) => e.preventDefault()}
            >
              <i className="fa-solid fa-magnifying-glass form-header__icon" aria-hidden="true"></i>
              <input
                className="au-input au-input--xl"
                type="search"
                name="search"
                placeholder="Cari transaksi, siswa, spot..."
                aria-label="Search"
                value={searchQuery}
                onChange={(e) => onSearchChange?.(e.target.value)}
              />
              <kbd className="form-header__hint" aria-hidden="true">⌘K</kbd>
            </form>

            {/* Action buttons & account */}
            <div className="header-button">
              <div className="noti-wrap">
                {/* Refresh data button */}
                {onRefresh && (
                  <div
                    className="noti__item"
                    role="button"
                    tabIndex={0}
                    aria-label="Segarkan data"
                    title="Segarkan data live"
                    onClick={onRefresh}
                    style={{ cursor: 'pointer' }}
                  >
                    <i
                      className={`fa-solid fa-arrows-rotate ${
                        isRefreshing ? 'fa-spin text-primary' : ''
                      }`}
                    ></i>
                  </div>
                )}

                {/* Notifications icon */}
                <div
                  className="noti__item"
                  role="button"
                  tabIndex={0}
                  aria-label="Notifikasi"
                  title="Notifikasi sistem"
                  style={{ cursor: 'pointer', position: 'relative' }}
                >
                  <i className="fa-regular fa-bell"></i>
                  <span
                    style={{
                      position: 'absolute',
                      top: '6px',
                      right: '6px',
                      width: '7px',
                      height: '7px',
                      borderRadius: '50%',
                      background: '#4272d7',
                      border: '2px solid #ffffff',
                    }}
                  ></span>
                </div>
              </div>

              {/* Account pill */}
              <div className="account-wrap">
                <div
                  className="account-item clearfix"
                  role="button"
                  tabIndex={0}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '10px',
                    padding: '4px 8px',
                    borderRadius: '6px',
                    cursor: 'default',
                  }}
                >
                  <div
                    style={{
                      width: '34px',
                      height: '34px',
                      borderRadius: '50%',
                      background: '#eaf0fc',
                      color: '#4272d7',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: 700,
                      fontSize: '13px',
                      border: '1px solid #d4e2fa',
                    }}
                  >
                    {initial}
                  </div>
                  <div className="content d-none d-sm-block">
                    <span
                      style={{
                        fontSize: '13.5px',
                        fontWeight: 600,
                        color: '#1f2937',
                        display: 'block',
                        lineHeight: 1.2,
                      }}
                    >
                      {username}
                    </span>
                    <span
                      style={{
                        fontSize: '11px',
                        color: '#475569',
                        fontWeight: 500,
                        display: 'block',
                      }}
                    >
                      Administrator
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
