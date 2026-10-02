import type { MarketPostRow, ProfileRow } from '../services/adminService';
import { UserAvatar } from './UserAvatar';
import { AdminModalPortal } from './AdminModalPortal';

type PostWithSeller = MarketPostRow & { seller?: ProfileRow | null };

interface PostDetailModalProps {
  post: PostWithSeller | null;
  isOpen: boolean;
  onClose: () => void;
  onRequestTakedown: (post: PostWithSeller) => void;
}

export function PostDetailModal({
  post,
  isOpen,
  onClose,
  onRequestTakedown,
}: PostDetailModalProps) {
  if (!isOpen || !post) return null;

  const images: string[] = Array.isArray(post.images)
    ? post.images
    : typeof post.images === 'string'
    ? [post.images]
    : [];

  const formatPrice = (price: number | null) => {
    if (price == null || price === 0) return 'Gratis / Diskusi';
    return `Rp ${price.toLocaleString('id-ID')}`;
  };

  return (
    <AdminModalPortal isOpen={isOpen} onClose={onClose}>
      <div
        style={{
          width: '100%',
          maxWidth: '560px',
          background: '#ffffff',
          borderRadius: '10px',
          border: '1px solid #e4e7ec',
          boxShadow: '0 20px 35px rgba(0, 0, 0, 0.15)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '90vh',
        }}
      >
        {/* Modal Header */}
        <div
          style={{
            padding: '18px 24px',
            borderBottom: '1px solid #f1f3f5',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            background: '#ffffff',
          }}
        >
          <div>
            <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1f2937' }}>
              Inspeksi Konten Feed
            </h3>
            <p style={{ margin: '2px 0 0', fontSize: '12.5px', color: '#64748b' }}>
              ID: {post.id.slice(0, 8)}... • Diterbitkan{' '}
              {new Date(post.created_at).toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
              })}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Tutup modal"
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '6px',
              background: '#f8fafc',
              border: '1px solid #e4e7ec',
              color: '#64748b',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              fontSize: '14px',
            }}
          >
            <i className="fa-solid fa-xmark"></i>
          </button>
        </div>

        {/* Modal Body */}
        <div
          style={{
            padding: '24px',
            overflowY: 'auto',
            display: 'flex',
            flexDirection: 'column',
            gap: '20px',
          }}
        >
          {/* Images Grid */}
          {images.length > 0 && (
            <div>
              <div
                style={{
                  fontSize: '11px',
                  fontWeight: 700,
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  color: '#64748b',
                  marginBottom: '8px',
                }}
              >
                Lampiran Media ({images.length})
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
                {images.map((imgUrl, i) => (
                  <a
                    key={i}
                    href={imgUrl}
                    target="_blank"
                    rel="noreferrer"
                    style={{
                      aspectRatio: '16/9',
                      borderRadius: '8px',
                      overflow: 'hidden',
                      background: '#f1f5f9',
                      border: '1px solid #e4e7ec',
                      display: 'block',
                      position: 'relative',
                    }}
                  >
                    <img
                      src={imgUrl}
                      alt={`Lampiran ${i + 1}`}
                      style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                    />
                  </a>
                ))}
              </div>
            </div>
          )}

          {/* Title, Badge & Price */}
          <div
            style={{
              padding: '16px',
              borderRadius: '8px',
              background: '#f8fafc',
              border: '1px solid #e4e7ec',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
              <span
                style={{
                  padding: '2px 8px',
                  borderRadius: '4px',
                  fontSize: '11px',
                  fontWeight: 700,
                  textTransform: 'uppercase',
                  background: post.post_type === 'product' ? '#eaf0fc' : '#fff1e6',
                  color: post.post_type === 'product' ? '#4272d7' : '#f97316',
                  border: `1px solid ${post.post_type === 'product' ? '#d4e2fa' : '#fed7aa'}`,
                }}
              >
                {post.post_type}
              </span>
              <span style={{ fontSize: '15px', fontWeight: 700, color: '#4272d7', fontVariantNumeric: 'tabular-nums' }}>
                {formatPrice(post.price)}
              </span>
            </div>

            <h4 style={{ margin: '0 0 6px', fontSize: '15px', fontWeight: 700, color: '#1f2937' }}>
              {post.title || 'Postingan Tanpa Judul'}
            </h4>

            <p style={{ margin: 0, fontSize: '13px', color: '#475569', lineHeight: 1.6, whiteSpace: 'pre-wrap' }}>
              {post.caption || post.description || 'Tidak ada deskripsi tambahan.'}
            </p>
          </div>

          {/* Author Card */}
          <div>
            <div
              style={{
                fontSize: '11px',
                fontWeight: 700,
                textTransform: 'uppercase',
                letterSpacing: '0.06em',
                color: '#64748b',
                marginBottom: '8px',
              }}
            >
              Penulis / Siswa Pemilik
            </div>

            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '12px 16px',
                borderRadius: '8px',
                background: '#ffffff',
                border: '1px solid #e4e7ec',
              }}
            >
              <UserAvatar
                avatarUrl={post.seller?.avatar_url}
                name={post.seller?.full_name}
                size={40}
                role={post.seller?.role}
              />
              <div>
                <div style={{ fontWeight: 600, fontSize: '13.5px', color: '#1f2937' }}>
                  {post.seller?.full_name || 'Siswa SMKN 8'}
                </div>
                <div style={{ fontSize: '11.5px', color: '#64748b' }}>
                  @{post.seller?.username || 'user'} • {post.seller?.class_group || 'Umum'}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div
          style={{
            padding: '16px 24px',
            borderTop: '1px solid #f1f3f5',
            background: '#f8fafc',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
          }}
        >
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={onClose}
            style={{
              height: '38px',
              padding: '0 16px',
              fontSize: '13px',
              fontWeight: 500,
              background: '#ffffff',
              border: '1px solid #e4e7ec',
              color: '#475569',
              borderRadius: '6px',
            }}
          >
            Tutup
          </button>

          <button
            type="button"
            onClick={() => onRequestTakedown(post)}
            style={{
              height: '38px',
              padding: '0 18px',
              fontSize: '13px',
              fontWeight: 600,
              borderRadius: '6px',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer',
              border: '1px solid #dc3545',
              background: '#dc3545',
              color: '#ffffff',
              boxShadow: '0 2px 6px rgba(220, 53, 69, 0.35)',
            }}
          >
            <i className="fa-solid fa-trash-can"></i>
            <span>Takedown Postingan</span>
          </button>
        </div>
      </div>
    </AdminModalPortal>
  );
}
