import { useState, useEffect, useCallback } from 'react';
import { adminService, type MarketPostRow, type ProfileRow } from '../services/adminService';
import { PostDetailModal } from '../components/PostDetailModal';
import { UserAvatar } from '../components/UserAvatar';
import { AdminModalPortal } from '../components/AdminModalPortal';
import { AdminTooltip } from '../components/AdminTooltip';

type PostWithSeller = MarketPostRow & { seller?: ProfileRow | null };

export function ContentModerationTab() {
  const [posts, setPosts] = useState<PostWithSeller[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [postTypeFilter, setPostTypeFilter] = useState('all');
  const [page, setPage] = useState(1);
  const pageSize = 12;
  const [viewMode, setViewMode] = useState<'table' | 'grid'>('table');

  // Deletion / Takedown State
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [targetPostForDelete, setTargetPostForDelete] = useState<PostWithSeller | null>(null);
  const [selectedPostPreview, setSelectedPostPreview] = useState<PostWithSeller | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const fetchPosts = useCallback(async () => {
    setIsLoading(true);
    try {
      const offset = (page - 1) * pageSize;
      const res = await adminService.getMarketPosts({
        search,
        postType: postTypeFilter,
        limit: pageSize,
        offset,
      });
      setPosts(res.data);
      setTotalCount(res.count);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat feed: ${e?.message || e}` });
    } finally {
      setIsLoading(false);
    }
  }, [search, postTypeFilter, page, pageSize]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchPosts();
    }, 250);
    return () => clearTimeout(timer);
  }, [fetchPosts]);

  const handleInspectPost = (post: PostWithSeller) => {
    setSelectedPostPreview(post);
    setIsModalOpen(true);
  };

  const confirmTakedown = async () => {
    if (!targetPostForDelete) return;
    const postId = targetPostForDelete.id;
    setDeletingId(postId);

    try {
      await adminService.deleteMarketPost(postId);
      setPosts((prev) => prev.filter((p) => p.id !== postId));
      setTotalCount((prev) => Math.max(0, prev - 1));
      if (selectedPostPreview?.id === postId) {
        setIsModalOpen(false);
        setSelectedPostPreview(null);
      }
      setFeedbackMsg({
        type: 'success',
        text: 'Postingan berhasil di-takedown dari database.',
      });
      setTargetPostForDelete(null);
      setTimeout(() => setFeedbackMsg(null), 3000);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: e?.message || `Gagal menghapus postingan: ${e}` });
    } finally {
      setDeletingId(null);
    }
  };

  const totalPages = Math.ceil(totalCount / pageSize) || 1;

  const formatPrice = (price: number | null) => {
    if (price == null || price === 0) return 'Gratis / Diskusi';
    return `Rp ${price.toLocaleString('id-ID')}`;
  };

  return (
    <>
      {/* 1. Page Header (CoolAdmin Source of Truth) */}
      <div className="page-header">
        <div>
          <h1>Moderasi Konten & Feed</h1>
          <p className="subtitle">
            Pantau postingan karya siswa, deteksi pelanggaran norma sekolah, dan lakukan takedown.
          </p>
        </div>
        <div className="page-header__actions">
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={fetchPosts}
            disabled={isLoading}
            aria-label="Refresh data"
          >
            <i className={`fa-solid fa-arrows-rotate ${isLoading ? 'fa-spin' : ''}`}></i>
            Segarkan
          </button>
        </div>
      </div>

      {/* Feedback banner if any */}
      {feedbackMsg && (
        <div
          style={{
            marginBottom: '16px',
            padding: '12px 16px',
            borderRadius: '6px',
            background: feedbackMsg.type === 'success' ? '#e0f3f1' : '#fce7f3',
            color: feedbackMsg.type === 'success' ? '#11998e' : '#ec4899',
            fontSize: '13px',
            fontWeight: 500,
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          <i
            className={`fa-solid ${
              feedbackMsg.type === 'success' ? 'fa-circle-check' : 'fa-triangle-exclamation'
            }`}
          ></i>
          <span>{feedbackMsg.text}</span>
        </div>
      )}

      {/* 2. Main Moderation Card */}
      <section className="m-card">
        {/* Filter Bar Header */}
        <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            {/* Search Input */}
            <div style={{ position: 'relative', width: '260px' }}>
              <input
                type="text"
                className="au-input"
                placeholder="Cari judul, konten, seller..."
                value={search}
                onChange={(e) => {
                  setSearch(e.target.value);
                  setPage(1);
                }}
                style={{
                  width: '100%',
                  height: '36px',
                  borderRadius: '6px',
                  border: '1px solid #e4e7ec',
                  padding: '0 12px 0 34px',
                  fontSize: '13px',
                }}
              />
              <i
                className="fa-solid fa-magnifying-glass"
                style={{
                  position: 'absolute',
                  left: '12px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  color: '#94a3b8',
                  fontSize: '12px',
                }}
              ></i>
            </div>

            {/* Filter Post Type */}
            <select
              value={postTypeFilter}
              onChange={(e) => {
                setPostTypeFilter(e.target.value);
                setPage(1);
              }}
              style={{
                height: '36px',
                borderRadius: '6px',
                border: '1px solid #e4e7ec',
                padding: '0 10px',
                fontSize: '13px',
                color: '#475569',
                background: '#ffffff',
              }}
            >
              <option value="all">Semua Tipe Konten</option>
              <option value="product">Produk & Karya Kejuruan</option>
              <option value="thread">Threads & Diskusi</option>
            </select>

            {/* View Mode Toggle */}
            <div style={{ display: 'flex', border: '1px solid #e4e7ec', borderRadius: '6px', overflow: 'hidden' }}>
              <AdminTooltip content="Tampilan tabel" placement="top">
                <button
                  type="button"
                  onClick={() => setViewMode('table')}
                  style={{
                    height: '34px',
                    padding: '0 12px',
                    border: 0,
                    background: viewMode === 'table' ? '#4272d7' : '#ffffff',
                    color: viewMode === 'table' ? '#ffffff' : '#475569',
                    cursor: 'pointer',
                    fontSize: '12px',
                  }}
                >
                  <i className="fa-solid fa-table-list"></i>
                </button>
              </AdminTooltip>

              <AdminTooltip content="Tampilan kartu" placement="top">
                <button
                  type="button"
                  onClick={() => setViewMode('grid')}
                  style={{
                    height: '34px',
                    padding: '0 12px',
                    border: 0,
                    background: viewMode === 'grid' ? '#4272d7' : '#ffffff',
                    color: viewMode === 'grid' ? '#ffffff' : '#475569',
                    cursor: 'pointer',
                    fontSize: '12px',
                  }}
                >
                  <i className="fa-solid fa-table-cells-large"></i>
                </button>
              </AdminTooltip>
            </div>
          </div>

          <div style={{ fontSize: '12.5px', color: '#64748b' }}>
            Total: <b>{totalCount}</b> postingan aktif
          </div>
        </header>

        {/* View Mode 1: Table */}
        {viewMode === 'table' ? (
          <div className="table-responsive">
            <table className="m-table">
              <thead>
                <tr>
                  <th>Konten / Judul</th>
                  <th>Penulis / Seller</th>
                  <th>Tipe Post</th>
                  <th>Harga</th>
                  <th className="num">Aksi</th>
                </tr>
              </thead>
              <tbody>
                {isLoading ? (
                  <tr>
                    <td colSpan={5} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                      <i className="fa-solid fa-arrows-rotate fa-spin" style={{ marginRight: '8px' }}></i>
                      Memuat postingan feed...
                    </td>
                  </tr>
                ) : posts.length === 0 ? (
                  <tr>
                    <td colSpan={5} style={{ textAlign: 'center', padding: '32px 0', color: '#94a3b8' }}>
                      Tidak ada postingan yang sesuai filter.
                    </td>
                  </tr>
                ) : (
                  posts.map((post) => (
                    <tr key={post.id}>
                      <td>
                        <div style={{ fontWeight: 600, color: '#1f2937' }}>
                          {post.title || post.caption || post.description || 'Karya Siswa'}
                        </div>
                        <div style={{ fontSize: '12px', color: '#64748b', marginTop: '2px' }}>
                          {post.caption || post.description ? `${(post.caption || post.description || '').slice(0, 65)}...` : '-'}
                        </div>
                      </td>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <UserAvatar
                            avatarUrl={post.seller?.avatar_url}
                            name={post.seller?.full_name}
                            size={32}
                            role={post.seller?.role}
                          />
                          <div>
                            <div style={{ fontWeight: 600, color: '#1f2937' }}>
                              {post.seller?.full_name || 'Siswa'}
                            </div>
                            <div style={{ fontSize: '11px', color: '#94a3b8' }}>
                              @{post.seller?.username || 'user'}
                            </div>
                          </div>
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
                            background: post.post_type === 'product' ? '#eaf0fc' : '#fff1e6',
                            color: post.post_type === 'product' ? '#4272d7' : '#f97316',
                          }}
                        >
                          {post.post_type || 'product'}
                        </span>
                      </td>
                      <td style={{ fontSize: '13px', fontWeight: 600, color: '#1f2937' }}>
                        {formatPrice(post.price)}
                      </td>
                      <td className="num">
                        <div className="table-data-feature">
                          {/* Inspect Modal Button */}
                          <AdminTooltip content="Tinjau detail postingan" placement="top">
                            <button
                              type="button"
                              className="item"
                              onClick={() => handleInspectPost(post)}
                              style={{ border: 0, cursor: 'pointer' }}
                            >
                              <i className="fa-solid fa-eye"></i>
                            </button>
                          </AdminTooltip>

                          {/* Takedown Button */}
                          <AdminTooltip content="Takedown postingan" placement="top" variant="danger">
                            <button
                              type="button"
                              className="item"
                              disabled={deletingId === post.id}
                              onClick={() => setTargetPostForDelete(post)}
                              style={{ border: 0, cursor: 'pointer', color: '#dc3545' }}
                            >
                              <i className="fa-solid fa-trash-can"></i>
                            </button>
                          </AdminTooltip>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        ) : (
          /* View Mode 2: Grid */
          <div className="row row-tight" style={{ marginTop: '8px' }}>
            {isLoading ? (
              <div style={{ width: '100%', textAlign: 'center', padding: '40px 0', color: '#94a3b8' }}>
                <i className="fa-solid fa-arrows-rotate fa-spin" style={{ marginRight: '8px' }}></i>
                Memuat galeri feed...
              </div>
            ) : posts.length === 0 ? (
              <div style={{ width: '100%', textAlign: 'center', padding: '40px 0', color: '#94a3b8' }}>
                Tidak ada postingan yang ditemukan.
              </div>
            ) : (
              posts.map((post) => {
                const img = Array.isArray(post.images) && post.images.length > 0 ? post.images[0] : null;
                return (
                  <div key={post.id} className="col-sm-6 col-lg-4" style={{ marginBottom: '16px' }}>
                    <div
                      style={{
                        background: '#ffffff',
                        border: '1px solid #e4e7ec',
                        borderRadius: '8px',
                        overflow: 'hidden',
                        height: '100%',
                        display: 'flex',
                        flexDirection: 'column',
                      }}
                    >
                      <div
                        style={{
                          height: '140px',
                          background: '#f8fafc',
                          position: 'relative',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                        }}
                      >
                        {img ? (
                          <img
                            src={img}
                            alt=""
                            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                          />
                        ) : (
                          <i className="fa-regular fa-image" style={{ fontSize: '32px', color: '#cbd5e1' }}></i>
                        )}
                        <span
                          style={{
                            position: 'absolute',
                            top: '8px',
                            right: '8px',
                            padding: '2px 8px',
                            borderRadius: '4px',
                            fontSize: '10.5px',
                            fontWeight: 700,
                            textTransform: 'uppercase',
                            background: post.post_type === 'product' ? '#4272d7' : '#f97316',
                            color: '#ffffff',
                          }}
                        >
                          {post.post_type || 'product'}
                        </span>
                      </div>
                      <div style={{ padding: '14px', flex: 1, display: 'flex', flexDirection: 'column' }}>
                        <div style={{ fontWeight: 600, fontSize: '14px', color: '#1f2937' }}>
                          {post.title || 'Karya Siswa'}
                        </div>
                        <div style={{ fontSize: '12px', color: '#64748b', marginTop: '4px', flex: 1 }}>
                          {post.caption || post.description ? `${(post.caption || post.description || '').slice(0, 60)}...` : '-'}
                        </div>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            marginTop: '12px',
                            paddingTop: '10px',
                            borderTop: '1px solid #f1f3f5',
                          }}
                        >
                          <span style={{ fontSize: '13px', fontWeight: 700, color: '#4272d7' }}>
                            {formatPrice(post.price)}
                          </span>
                          <div style={{ display: 'flex', gap: '6px' }}>
                            <AdminTooltip content="Tinjau detail" placement="top">
                              <button
                                type="button"
                                className="m-btn m-btn--ghost"
                                onClick={() => handleInspectPost(post)}
                                style={{ height: '28px', padding: '0 8px', fontSize: '11px' }}
                              >
                                <i className="fa-solid fa-eye"></i>
                              </button>
                            </AdminTooltip>

                            <AdminTooltip content="Takedown postingan" placement="top" variant="danger">
                              <button
                                type="button"
                                className="m-btn m-btn--ghost"
                                onClick={() => setTargetPostForDelete(post)}
                                style={{ height: '28px', padding: '0 8px', fontSize: '11px', color: '#dc3545' }}
                              >
                                <i className="fa-solid fa-trash-can"></i>
                              </button>
                            </AdminTooltip>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        )}

        {/* Pagination Footer */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            paddingTop: '16px',
            marginTop: '8px',
            borderTop: '1px solid #f1f3f5',
          }}
        >
          <div style={{ fontSize: '12.5px', color: '#94a3b8' }}>
            Halaman {page} dari {totalPages}
          </div>
          <div style={{ display: 'flex', gap: '8px' }}>
            <button
              type="button"
              className="m-btn m-btn--ghost"
              disabled={page <= 1}
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              style={{ height: '32px', padding: '0 12px', fontSize: '12px' }}
            >
              <i className="fa-solid fa-chevron-left"></i>
              Sebelumnya
            </button>
            <button
              type="button"
              className="m-btn m-btn--ghost"
              disabled={page >= totalPages}
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              style={{ height: '32px', padding: '0 12px', fontSize: '12px' }}
            >
              Selanjutnya
              <i className="fa-solid fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </section>

      {/* Post Detail Inspection Modal */}
      <PostDetailModal
        post={selectedPostPreview}
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onRequestTakedown={(post) => {
          setTargetPostForDelete(post);
          setIsModalOpen(false);
        }}
      />

      {/* Confirmation Modal for Takedown */}
      <AdminModalPortal
        isOpen={!!targetPostForDelete}
        onClose={() => setTargetPostForDelete(null)}
      >
        {targetPostForDelete && (
          <div
            style={{
              background: '#ffffff',
              borderRadius: '8px',
              padding: '24px',
              maxWidth: '500px',
              width: '100%',
              boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div
                style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '50%',
                  background: '#fee2e2',
                  color: '#dc3545',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '18px',
                }}
              >
                <i className="fa-solid fa-triangle-exclamation"></i>
              </div>
              <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1f2937' }}>
                  Konfirmasi Takedown
                </h3>
                <span style={{ fontSize: '12px', color: '#64748b' }}>
                  Tindakan ini permanen dan tidak dapat dibatalkan.
                </span>
              </div>
            </div>

            <p style={{ fontSize: '13.5px', color: '#475569', lineHeight: 1.5, margin: '0 0 20px' }}>
              Apakah Anda yakin ingin menghapus postingan <b>"{targetPostForDelete.title || 'Karya Siswa'}"</b> karya <b>{targetPostForDelete.seller?.full_name || 'Siswa'}</b>?
            </p>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                type="button"
                className="m-btn m-btn--ghost"
                onClick={() => setTargetPostForDelete(null)}
              >
                Batal
              </button>
              <button
                type="button"
                className="m-btn m-btn--primary"
                style={{ background: '#dc3545', borderColor: '#dc3545' }}
                disabled={deletingId != null}
                onClick={confirmTakedown}
              >
                {deletingId ? 'Menghapus...' : 'Ya, Takedown Konten'}
              </button>
            </div>
          </div>
        )}
      </AdminModalPortal>
    </>
  );
}
