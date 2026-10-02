import { useState, useEffect, useRef } from 'react';
import type { AdminTab } from './AdminSidebar';
import {
  adminService,
  type ProfileRow,
  type GlobalSearchResult,
  type MarketPostRow,
  type SchoolMeetingPointRow,
} from '../services/adminService';
import { HeaderSearchPopover } from './HeaderSearchPopover';
import { AdminAccountDropdown } from './AdminAccountDropdown';

interface AdminHeaderProps {
  activeTab: AdminTab;
  adminEmail: string;
  adminRole: string;
  adminProfile?: ProfileRow | null;
  onRefresh?: () => void;
  isRefreshing?: boolean;
  onToggleMobileSidebar?: () => void;
  searchQuery?: string;
  onSearchChange?: (q: string) => void;
  onNavigateTab?: (tab: AdminTab) => void;
  onLogout?: () => void;
}

export function AdminHeader({
  adminEmail,
  adminRole,
  adminProfile,
  onRefresh,
  isRefreshing,
  onToggleMobileSidebar,
  searchQuery = '',
  onSearchChange,
  onNavigateTab,
  onLogout,
}: AdminHeaderProps) {
  const [isPopoverOpen, setIsPopoverOpen] = useState(false);
  const [searchResults, setSearchResults] = useState<GlobalSearchResult | null>(null);
  const [isSearching, setIsSearching] = useState(false);
  const searchContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const q = searchQuery.trim();
    if (q.length < 2) {
      setSearchResults(null);
      setIsSearching(false);
      return;
    }

    setIsSearching(true);
    setIsPopoverOpen(true);
    const timer = setTimeout(async () => {
      try {
        const results = await adminService.searchGlobal(q);
        setSearchResults(results);
      } catch (err) {
        console.error('Failed to execute search:', err);
      } finally {
        setIsSearching(false);
      }
    }, 250);

    return () => clearTimeout(timer);
  }, [searchQuery]);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        searchContainerRef.current &&
        !searchContainerRef.current.contains(event.target as Node)
      ) {
        setIsPopoverOpen(false);
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

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

            {/* Quick Search Bar with Live Popover */}
            <div ref={searchContainerRef} style={{ position: 'relative' }}>
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
                  autoComplete="off"
                  onFocus={() => {
                    if (searchQuery.trim().length >= 2) {
                      setIsPopoverOpen(true);
                    }
                  }}
                  onKeyDown={(e) => {
                    if (e.key === 'Escape') {
                      setIsPopoverOpen(false);
                    }
                  }}
                  onChange={(e) => onSearchChange?.(e.target.value)}
                />
                {searchQuery.length > 0 && (
                  <button
                    type="button"
                    className="form-header__clear-btn"
                    aria-label="Hapus pencarian"
                    title="Hapus pencarian"
                    onClick={() => {
                      onSearchChange?.('');
                      setSearchResults(null);
                      setIsPopoverOpen(false);
                    }}
                  >
                    <i className="fa-solid fa-xmark" aria-hidden="true"></i>
                  </button>
                )}
              </form>

              <HeaderSearchPopover
                isOpen={isPopoverOpen && searchQuery.trim().length >= 2}
                isLoading={isSearching}
                searchQuery={searchQuery}
                results={searchResults}
                onSelectUser={(_user: ProfileRow) => {
                  setIsPopoverOpen(false);
                  onNavigateTab?.('users');
                }}
                onSelectPost={(_post: MarketPostRow) => {
                  setIsPopoverOpen(false);
                  onNavigateTab?.('moderation');
                }}
                onSelectSpot={(_spot: SchoolMeetingPointRow) => {
                  setIsPopoverOpen(false);
                  onNavigateTab?.('meeting-points');
                }}
              />
            </div>

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

              {/* Account pill with connected DB profile & dropdown */}
              <div className="account-wrap" style={{ position: 'relative' }}>
                <div
                  className="account-item clearfix"
                  role="button"
                  tabIndex={0}
                  onClick={() => setIsAccountMenuOpen((prev) => !prev)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '10px',
                    padding: '4px 8px',
                    borderRadius: '6px',
                    cursor: 'pointer',
                    background: isAccountMenuOpen ? '#f1f5f9' : 'transparent',
                    transition: 'background 120ms ease',
                  }}
                >
                  <UserAvatar
                    avatarUrl={adminProfile?.avatar_url}
                    name={displayName}
                    size={36}
                    borderRadius="50%"
                    role={adminRole}
                    style={{
                      border: '1.5px solid #d4e2fa',
                    }}
                  />
                  <div className="content d-none d-sm-block text-start">
                    <span
                      style={{
                        fontSize: '13px',
                        fontWeight: 600,
                        color: '#1f2937',
                        display: 'block',
                        lineHeight: 1.2,
                        maxWidth: '120px',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {displayName}
                    </span>
                    <span
                      style={{
                        fontSize: '10.5px',
                        color: '#4272d7',
                        fontWeight: 600,
                        display: 'block',
                        textTransform: 'uppercase',
                        letterSpacing: '0.04em',
                      }}
                    >
                      {adminRole}
                    </span>
                  </div>
                  <i
                    className="fa-solid fa-chevron-down d-none d-sm-inline-block"
                    style={{ fontSize: '10px', color: '#94a3b8', marginLeft: '4px' }}
                  ></i>
                </div>

                {/* Account dropdown menu */}
                {isAccountMenuOpen && (
                  <div
                    style={{
                      position: 'absolute',
                      right: 0,
                      top: '110%',
                      width: '220px',
                      background: '#ffffff',
                      borderRadius: '8px',
                      border: '1px solid #e4e7ec',
                      boxShadow: '0 10px 25px rgba(0, 0, 0, 0.1)',
                      zIndex: 1000,
                      overflow: 'hidden',
                    }}
                  >
                    <div style={{ padding: '12px 14px', borderBottom: '1px solid #f1f3f5' }}>
                      <div style={{ fontSize: '13px', fontWeight: 700, color: '#1f2937' }}>
                        {displayName}
                      </div>
                      <div style={{ fontSize: '11.5px', color: '#64748b', marginTop: '2px' }}>
                        {displayUsername}
                      </div>
                    </div>
                    <div style={{ padding: '6px' }}>
                      <a
                        href="/@radityarayhannnn"
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '10px',
                          padding: '8px 10px',
                          fontSize: '12.5px',
                          color: '#475569',
                          textDecoration: 'none',
                          borderRadius: '4px',
                        }}
                        onMouseEnter={(e) => (e.currentTarget.style.background = '#f8fafc')}
                        onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
                      >
                        <i className="fa-solid fa-user" style={{ width: '14px', color: '#94a3b8' }}></i>
                        Lihat Profil Publik
                      </a>
                    </div>
                    {onLogout && (
                      <div style={{ padding: '6px', borderTop: '1px solid #f1f3f5' }}>
                        <button
                          type="button"
                          onClick={() => {
                            setIsAccountMenuOpen(false);
                            onLogout();
                          }}
                          style={{
                            width: '100%',
                            display: 'flex',
                            alignItems: 'center',
                            gap: '10px',
                            padding: '8px 10px',
                            fontSize: '12.5px',
                            color: '#dc3545',
                            background: 'transparent',
                            border: 0,
                            borderRadius: '4px',
                            cursor: 'pointer',
                            textAlign: 'left',
                          }}
                          onMouseEnter={(e) => (e.currentTarget.style.background = '#fef2f2')}
                          onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
                        >
                          <i className="fa-solid fa-arrow-right-from-bracket" style={{ width: '14px' }}></i>
                          Keluar dari Akun
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
