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
              <AdminAccountDropdown
                adminEmail={adminEmail}
                adminRole={adminRole}
                adminProfile={adminProfile}
                onLogout={onLogout}
              />
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}
