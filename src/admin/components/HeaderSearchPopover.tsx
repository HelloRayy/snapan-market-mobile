import type { ProfileRow, MarketPostRow, SchoolMeetingPointRow, GlobalSearchResult } from '../services/adminService';
import { UserAvatar } from './UserAvatar';

interface HeaderSearchPopoverProps {
  isOpen: boolean;
  isLoading: boolean;
  searchQuery: string;
  results: GlobalSearchResult | null;
  onSelectUser: (user: ProfileRow) => void;
  onSelectPost: (post: MarketPostRow) => void;
  onSelectSpot: (spot: SchoolMeetingPointRow) => void;
}

export function HeaderSearchPopover({
  isOpen,
  isLoading,
  searchQuery,
  results,
  onSelectUser,
  onSelectPost,
  onSelectSpot,
}: HeaderSearchPopoverProps) {
  if (!isOpen) return null;

  const totalCount =
    (results?.users.length || 0) +
    (results?.posts.length || 0) +
    (results?.spots.length || 0);

  return (
    <div className="header-search-popover" role="dialog" aria-label="Hasil Pencarian">
      {isLoading ? (
        <div style={{ padding: '24px 16px', textAlign: 'center', color: '#64748b', fontSize: '13px' }}>
          <i className="fa-solid fa-circle-notch fa-spin text-primary me-2"></i>
          Mencari data sistem...
        </div>
      ) : totalCount === 0 ? (
        <div style={{ padding: '24px 16px', textAlign: 'center', color: '#64748b', fontSize: '13px' }}>
          <i className="fa-regular fa-folder-open mb-2 d-block" style={{ fontSize: '22px', color: '#94a3b8' }}></i>
          Tidak ditemukan hasil untuk "<strong>{searchQuery}</strong>"
        </div>
      ) : (
        <div className="header-search-popover__scroll">
          {/* Siswa & Pengguna */}
          {results && results.users.length > 0 && (
            <div className="header-search-popover__group">
              <div className="header-search-popover__group-title">
                <span>Siswa & Pengguna</span>
                <span className="badge bg-light text-muted" style={{ fontSize: '10px' }}>
                  {results.users.length}
                </span>
              </div>
              {results.users.map((user) => (
                <button
                  key={user.id}
                  type="button"
                  className="header-search-popover__item"
                  onClick={() => onSelectUser(user)}
                >
                  <UserAvatar
                    avatarUrl={user.avatar_url}
                    name={user.full_name}
                    size={30}
                    borderRadius="50%"
                    role={user.role}
                  />
                  <div style={{ flex: 1, minWidth: 0, overflow: 'hidden' }}>
                    <div
                      style={{
                        fontSize: '12.5px',
                        fontWeight: 600,
                        color: '#1e293b',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {user.full_name || 'Tanpa Nama'}
                    </div>
                    <div
                      style={{
                        fontSize: '11px',
                        color: '#64748b',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      @{user.username || 'user'} • {user.class_group || 'Siswa SMKN 8'}
                    </div>
                  </div>
                  <span
                    className="badge"
                    style={{
                      fontSize: '10px',
                      background: user.role === 'admin' ? '#fee2e2' : '#e0e7ff',
                      color: user.role === 'admin' ? '#dc2626' : '#4338ca',
                    }}
                  >
                    {user.role}
                  </span>
                </button>
              ))}
            </div>
          )}

          {/* Postingan & Karya */}
          {results && results.posts.length > 0 && (
            <div className="header-search-popover__group">
              <div className="header-search-popover__group-title">
                <span>Postingan & Karya</span>
                <span className="badge bg-light text-muted" style={{ fontSize: '10px' }}>
                  {results.posts.length}
                </span>
              </div>
              {results.posts.map((post) => (
                <button
                  key={post.id}
                  type="button"
                  className="header-search-popover__item"
                  onClick={() => onSelectPost(post)}
                >
                  <div
                    style={{
                      width: '30px',
                      height: '30px',
                      borderRadius: '6px',
                      background: post.post_type === 'product' ? '#f0fdf4' : '#eff6ff',
                      color: post.post_type === 'product' ? '#16a34a' : '#2563eb',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '13px',
                      flexShrink: 0,
                    }}
                  >
                    <i className={post.post_type === 'product' ? 'fa-solid fa-store' : 'fa-regular fa-message'}></i>
                  </div>
                  <div style={{ flex: 1, minWidth: 0, overflow: 'hidden' }}>
                    <div
                      style={{
                        fontSize: '12.5px',
                        fontWeight: 600,
                        color: '#1e293b',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {post.title || post.caption?.slice(0, 35) || 'Postingan tanpa judul'}
                    </div>
                    <div
                      style={{
                        fontSize: '11px',
                        color: '#64748b',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      Oleh: {post.seller?.full_name || 'Penjual'} • {post.category || 'Umum'}
                    </div>
                  </div>
                  {post.price ? (
                    <span style={{ fontSize: '11px', fontWeight: 600, color: '#16a34a' }}>
                      Rp {post.price.toLocaleString('id-ID')}
                    </span>
                  ) : (
                    <span className="badge bg-light text-muted" style={{ fontSize: '10px' }}>
                      {post.post_type}
                    </span>
                  )}
                </button>
              ))}
            </div>
          )}

          {/* Titik Temu COD */}
          {results && results.spots.length > 0 && (
            <div className="header-search-popover__group">
              <div className="header-search-popover__group-title">
                <span>Titik Temu COD</span>
                <span className="badge bg-light text-muted" style={{ fontSize: '10px' }}>
                  {results.spots.length}
                </span>
              </div>
              {results.spots.map((spot) => (
                <button
                  key={spot.id}
                  type="button"
                  className="header-search-popover__item"
                  onClick={() => onSelectSpot(spot)}
                >
                  <div
                    style={{
                      width: '30px',
                      height: '30px',
                      borderRadius: '6px',
                      background: '#fef3c7',
                      color: '#d97706',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '13px',
                      flexShrink: 0,
                    }}
                  >
                    <i className="fa-solid fa-location-dot"></i>
                  </div>
                  <div style={{ flex: 1, minWidth: 0, overflow: 'hidden' }}>
                    <div
                      style={{
                        fontSize: '12.5px',
                        fontWeight: 600,
                        color: '#1e293b',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      {spot.name}
                    </div>
                    <div
                      style={{
                        fontSize: '11px',
                        color: '#64748b',
                        whiteSpace: 'nowrap',
                        overflow: 'hidden',
                        textOverflow: 'ellipsis',
                      }}
                    >
                      Lantai {spot.floor} • {spot.area_category}
                    </div>
                  </div>
                  <span
                    className="badge"
                    style={{
                      fontSize: '10px',
                      background: spot.is_active ? '#dcfce7' : '#fee2e2',
                      color: spot.is_active ? '#15803d' : '#b91c1c',
                    }}
                  >
                    {spot.is_active ? 'Aktif' : 'Nonaktif'}
                  </span>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Popover Footer */}
      <div className="header-search-popover__footer">
        <span>{totalCount} item ditemukan</span>
        <span>Esc untuk tutup</span>
      </div>
    </div>
  );
}
