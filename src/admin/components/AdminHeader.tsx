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
import { AdminTooltip } from './AdminTooltip';

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

  const [isNotiOpen, setIsNotiOpen] = useState(false);
  const notiContainerRef = useRef<HTMLDivElement>(null);

  // Key untuk menyimpan ID notifikasi yang sudah pernah dibuka/dibaca
  const READ_NOTIFS_STORAGE_KEY = 'snapan_admin_read_notifs';

  // Daftar notifikasi laporan konten/teks dari pengguna (Real DB)
  const [reportNotifications, setReportNotifications] = useState<
    {
      id: string;
      title: string;
      desc: string;
      time: string;
      type: 'post' | 'text' | 'verification';
      unread: boolean;
    }[]
  >([]);

  useEffect(() => {
    let isSubscribed = true;
    const loadRealReportsNoti = async () => {
      try {
        const { notifications } = await adminService.getPendingReportNotifications(5);
        if (!isSubscribed) return;

        let readIds: string[] = [];
        try {
          readIds = JSON.parse(localStorage.getItem(READ_NOTIFS_STORAGE_KEY) || '[]');
        } catch {
          readIds = [];
        }

        const formatted = notifications.map((r) => ({
          id: r.id,
          title: `Laporan: ${r.reason}`,
          desc: r.details || `Dilaporkan oleh @${r.reporterUsername || 'siswa'}`,
          time: new Date(r.created_at).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }),
          type: 'post' as const,
          unread: !readIds.includes(r.id),
        }));
        setReportNotifications(formatted);
      } catch (err) {
        console.error('Failed to load notifications:', err);
      }
    };

    loadRealReportsNoti();
    return () => {
      isSubscribed = false;
    };
  }, [isRefreshing]);

  // Handler saat popover notifikasi dibuka: hilangkan badge dan tandai semua sebagai terbaca
  const handleToggleNoti = () => {
    setIsNotiOpen((prev) => {
      const next = !prev;
      if (next && reportNotifications.length > 0) {
        // Tandai semua item saat ini sebagai terbaca
        setReportNotifications((list) =>
          list.map((item) => ({ ...item, unread: false }))
        );
        try {
          const currentRead: string[] = JSON.parse(
            localStorage.getItem(READ_NOTIFS_STORAGE_KEY) || '[]'
          );
          const allIds = Array.from(
            new Set([...currentRead, ...reportNotifications.map((n) => n.id)])
          );
          localStorage.setItem(READ_NOTIFS_STORAGE_KEY, JSON.stringify(allIds));
        } catch (e) {
          console.error('Failed to persist read notification ids:', e);
        }
      }
      return next;
    });
  };

  const unreadCount = reportNotifications.filter((r) => r.unread).length;

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        searchContainerRef.current &&
        !searchContainerRef.current.contains(event.target as Node)
      ) {
        setIsPopoverOpen(false);
      }
      if (
        notiContainerRef.current &&
        !notiContainerRef.current.contains(event.target as Node)
      ) {
        setIsNotiOpen(false);
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
                  <AdminTooltip content="Segarkan data live" placement="bottom">
                    <div
                      className="noti__item"
                      role="button"
                      tabIndex={0}
                      aria-label="Segarkan data"
                      onClick={onRefresh}
                      style={{ cursor: 'pointer' }}
                    >
                      <i
                        className={`fa-solid fa-arrows-rotate ${
                          isRefreshing ? 'fa-spin text-primary' : ''
                        }`}
                      ></i>
                    </div>
                  </AdminTooltip>
                )}

                {/* Notifications icon & dropdown laporan konten */}
                <div
                  ref={notiContainerRef}
                  style={{ position: 'relative' }}
                >
                  <AdminTooltip content={unreadCount > 0 ? `${unreadCount} laporan baru` : 'Notifikasi laporan'} placement="bottom">
                    <div
                      className="noti__item"
                      role="button"
                      tabIndex={0}
                      aria-label="Notifikasi Laporan"
                      onClick={handleToggleNoti}
                      style={{
                        cursor: 'pointer',
                        position: 'relative',
                        background: isNotiOpen ? '#f1f5f9' : 'transparent',
                        borderRadius: '6px',
                      }}
                    >
                      <i className="fa-regular fa-bell"></i>
                      {unreadCount > 0 && (
                        <span
                          style={{
                            position: 'absolute',
                            top: '2px',
                            right: '2px',
                            minWidth: '16px',
                            height: '16px',
                            borderRadius: '8px',
                            background: '#dc2626',
                            color: '#ffffff',
                            fontSize: '9.5px',
                            fontWeight: 700,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            padding: '0 4px',
                            border: '2px solid #ffffff',
                            boxShadow: '0 1px 3px rgba(220, 38, 38, 0.4)',
                          }}
                        >
                          {unreadCount}
                        </span>
                      )}
                    </div>
                  </AdminTooltip>

                  {/* Popover Laporan Pengguna */}
                  {isNotiOpen && (
                    <div
                      style={{
                        position: 'absolute',
                        right: 0,
                        top: 'calc(100% + 8px)',
                        width: '320px',
                        background: '#ffffff',
                        borderRadius: '8px',
                        border: '1px solid #e4e7ec',
                        boxShadow: '0 10px 25px rgba(0, 0, 0, 0.1)',
                        zIndex: 1050,
                        overflow: 'hidden',
                      }}
                    >
                      <div
                        style={{
                          padding: '12px 16px',
                          borderBottom: '1px solid #f1f3f5',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'space-between',
                          background: '#f8fafc',
                        }}
                      >
                        <div>
                          <div style={{ fontSize: '13px', fontWeight: 700, color: '#1f2937' }}>
                            Laporan & Pengawasan
                          </div>
                          <div style={{ fontSize: '11px', color: '#64748b' }}>
                            {unreadCount} laporan butuh tindakan
                          </div>
                        </div>
                        <span
                          style={{
                            fontSize: '10px',
                            fontWeight: 700,
                            padding: '2px 6px',
                            borderRadius: '4px',
                            background: '#fee2e2',
                            color: '#b91c1c',
                          }}
                        >
                          LIVE
                        </span>
                      </div>

                      <div style={{ maxHeight: '280px', overflowY: 'auto' }}>
                        {reportNotifications.length === 0 ? (
                          <div style={{ padding: '24px 16px', textAlign: 'center', color: '#64748b' }}>
                            <i className="fa-solid fa-bell-slash" style={{ fontSize: '20px', marginBottom: '8px', display: 'block', color: '#94a3b8' }}></i>
                            <div style={{ fontSize: '12.5px', fontWeight: 600, color: '#1f2937' }}>
                              Tidak Ada Laporan Baru
                            </div>
                            <div style={{ fontSize: '11px', marginTop: '2px', color: '#64748b' }}>
                              Semua postingan dan teks terpantau aman.
                            </div>
                          </div>
                        ) : (
                          reportNotifications.map((noti) => (
                            <div
                              key={noti.id}
                              onClick={() => {
                                setIsNotiOpen(false);
                                if (noti.type === 'verification') {
                                  onNavigateTab?.('users');
                                } else {
                                  onNavigateTab?.('reports');
                                }
                              }}
                              style={{
                                padding: '12px 16px',
                                borderBottom: '1px solid #f1f3f5',
                                cursor: 'pointer',
                                background: noti.unread ? '#fafcff' : '#ffffff',
                                transition: 'background 120ms ease',
                              }}
                              onMouseEnter={(e) => (e.currentTarget.style.background = '#f1f5f9')}
                              onMouseLeave={(e) =>
                                (e.currentTarget.style.background = noti.unread ? '#fafcff' : '#ffffff')
                              }
                            >
                              <div style={{ display: 'flex', alignItems: 'flex-start', gap: '10px' }}>
                                <div
                                  style={{
                                    width: '28px',
                                    height: '28px',
                                    borderRadius: '6px',
                                    background:
                                      noti.type === 'verification' ? '#e0f2fe' : '#fee2e2',
                                    color: noti.type === 'verification' ? '#0369a1' : '#b91c1c',
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    fontSize: '12px',
                                    flexShrink: 0,
                                    marginTop: '2px',
                                  }}
                                >
                                  <i
                                    className={`fa-solid ${
                                      noti.type === 'verification' ? 'fa-user-check' : 'fa-triangle-exclamation'
                                    }`}
                                  ></i>
                                </div>
                                <div style={{ flex: 1, minWidth: 0 }}>
                                  <div
                                    style={{
                                      fontSize: '12px',
                                      fontWeight: 600,
                                      color: '#1f2937',
                                      lineHeight: 1.3,
                                    }}
                                  >
                                    {noti.title}
                                  </div>
                                  <div
                                    style={{
                                      fontSize: '11.5px',
                                      color: '#64748b',
                                      marginTop: '3px',
                                      lineHeight: 1.4,
                                    }}
                                  >
                                    {noti.desc}
                                  </div>
                                  <div
                                    style={{
                                      fontSize: '10px',
                                      color: '#64748b',
                                      marginTop: '4px',
                                    }}
                                  >
                                    {noti.time}
                                  </div>
                                </div>
                              </div>
                            </div>
                          ))
                        )}
                      </div>

                      <div
                        style={{
                          padding: '8px 12px',
                          background: '#f8fafc',
                          borderTop: '1px solid #f1f3f5',
                          textAlign: 'center',
                        }}
                      >
                        <button
                          type="button"
                          onClick={() => {
                            setIsNotiOpen(false);
                            onNavigateTab?.('reports');
                          }}
                          style={{
                            background: 'transparent',
                            border: 0,
                            color: '#1d4ed8',
                            fontSize: '11.5px',
                            fontWeight: 600,
                            cursor: 'pointer',
                            padding: '4px 8px',
                          }}
                        >
                          Buka Semua di Laporan Konten &rarr;
                        </button>
                      </div>
                    </div>
                  )}
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
