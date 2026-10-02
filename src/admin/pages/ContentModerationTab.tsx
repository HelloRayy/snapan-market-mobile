import { useState, useEffect, useCallback } from 'react';
import {
  Search,
  Trash2,
  AlertTriangle,
  RefreshCw,
  Eye,
  ChevronLeft,
  ChevronRight,
  ImageIcon,
  Grid,
  List as ListIcon,
  CheckCircle2,
} from 'lucide-react';
import { adminService, type MarketPostRow, type ProfileRow } from '../services/adminService';
import { PostDetailDrawer } from '../components/PostDetailDrawer';
import {
  Card,
  Badge,
  Table,
  TableHead,
  TableHeaderCell,
  TableBody,
  TableRow,
  TableCell,
} from '../components/tremor';

type PostWithSeller = MarketPostRow & { seller?: ProfileRow | null };

export function ContentModerationTab() {
  const [posts, setPosts] = useState<PostWithSeller[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [postTypeFilter, setPostTypeFilter] = useState('all');
  const [page, setPage] = useState(1);
  const pageSize = 12;
  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid');

  // Deletion / Takedown State
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [targetPostForDelete, setTargetPostForDelete] = useState<PostWithSeller | null>(null);
  const [selectedPostPreview, setSelectedPostPreview] = useState<PostWithSeller | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
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
    setIsDrawerOpen(true);
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
        setIsDrawerOpen(false);
        setSelectedPostPreview(null);
      }
      setFeedbackMsg({
        type: 'success',
        text: 'Postingan berhasil di-takedown dari database Supabase.',
      });
      setTargetPostForDelete(null);
    } catch (e: any) {
      setFeedbackMsg({ type: 'error', text: e?.message || `Gagal menghapus postingan: ${e}` });
    } finally {
      setDeletingId(null);
    }
  };

  const formatPrice = (price: number | null) => {
    if (price == null || price === 0) return 'Gratis / Diskusi';
    return `Rp ${price.toLocaleString('id-ID')}`;
  };

  const totalPages = Math.ceil(totalCount / pageSize) || 1;

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* 1. Header Toolbar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-base font-bold text-slate-900 tracking-tight">
            Moderasi Konten & Feed
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Pantau dan tindak postingan threads atau karya marketplace yang melanggar aturan
          </p>
        </div>

        <div className="flex items-center gap-2 self-start sm:self-auto">
          {/* View Mode Switcher */}
          <div className="flex items-center p-1 rounded-xl bg-slate-100 border border-slate-200/60">
            <button
              onClick={() => setViewMode('grid')}
              className={`p-1.5 rounded-lg transition-all cursor-pointer ${
                viewMode === 'grid' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-500 hover:text-slate-900'
              }`}
              title="Tampilan Grid Card"
            >
              <Grid className="h-4 w-4" />
            </button>
            <button
              onClick={() => setViewMode('table')}
              className={`p-1.5 rounded-lg transition-all cursor-pointer ${
                viewMode === 'table' ? 'bg-white text-slate-900 shadow-2xs' : 'text-slate-500 hover:text-slate-900'
              }`}
              title="Tampilan Data Tabel"
            >
              <ListIcon className="h-4 w-4" />
            </button>
          </div>

          <button
            onClick={fetchPosts}
            disabled={isLoading}
            className="flex items-center gap-1.5 h-8.5 px-3 rounded-xl border border-slate-200 bg-white text-xs font-semibold text-slate-700 hover:bg-slate-50 transition-colors shadow-2xs cursor-pointer"
          >
            <RefreshCw className={`h-3.5 w-3.5 text-[#3D38F5] ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
        </div>
      </div>

      {/* 2. Feedback Notification Toast */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border text-xs flex items-center justify-between transition-all ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-rose-50 text-rose-800 border-rose-200'
          }`}
        >
          <div className="flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="text-xs font-semibold hover:underline cursor-pointer"
          >
            Tutup
          </button>
        </div>
      )}

      {/* 3. Search & Category Filter Controls */}
      <Card className="p-4 flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
          <input
            type="text"
            placeholder="Cari judul postingan, caption, atau nama siswa..."
            value={search}
            onChange={(e) => {
              setPage(1);
              setSearch(e.target.value);
            }}
            className="w-full h-9 pl-9 pr-4 rounded-lg border border-slate-200 bg-slate-50/50 text-xs text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-[#3D38F5] focus:ring-2 focus:ring-[#3D38F5]/10 outline-none transition-all"
          />
        </div>

        {/* Post Type Segmented Control */}
        <div className="flex items-center gap-1 p-1 rounded-lg bg-slate-100 border border-slate-200/60 overflow-x-auto">
          {(
            [
              { id: 'all', label: 'Semua Tipe' },
              { id: 'product', label: 'Marketplace' },
              { id: 'thread', label: 'Threads Diskusi' },
            ] as const
          ).map((t) => (
            <button
              key={t.id}
              onClick={() => {
                setPage(1);
                setPostTypeFilter(t.id);
              }}
              className={`px-2.5 py-1 rounded-md text-xs font-medium transition-all cursor-pointer whitespace-nowrap ${
                postTypeFilter === t.id
                  ? 'bg-white text-slate-900 shadow-2xs font-semibold'
                  : 'text-slate-500 hover:text-slate-900'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>
      </Card>

      {/* 4. Content Presentation (Grid or Table) */}
      {isLoading ? (
        <div className="py-20 text-center text-slate-400">
          <RefreshCw className="h-6 w-6 animate-spin text-[#3D38F5] mx-auto mb-2" />
          <span className="text-xs">Memuat katalog konten feed...</span>
        </div>
      ) : posts.length === 0 ? (
        <Card className="p-16 text-center space-y-2">
          <p className="font-semibold text-slate-800 text-sm">Tidak ada postingan ditemukan</p>
          <p className="text-xs text-slate-400">Ubah filter pencarian atau pastikan feed aktif di mobile app.</p>
        </Card>
      ) : viewMode === 'grid' ? (
        /* GRID VIEW */
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4.5">
          {posts.map((p) => {
            const firstImage = Array.isArray(p.images) && p.images.length > 0 ? p.images[0] : null;
            return (
              <Card
                key={p.id}
                onClick={() => handleInspectPost(p)}
                className="p-0 overflow-hidden hover:ring-slate-300 transition-all flex flex-col justify-between cursor-pointer group"
              >
                <div>
                  {/* Thumbnail */}
                  <div className="aspect-video w-full bg-slate-100 border-b border-slate-100 relative overflow-hidden">
                    {firstImage ? (
                      <img
                        src={firstImage}
                        alt={p.title || 'Feed'}
                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-slate-400 bg-slate-50">
                        <ImageIcon className="h-8 w-8 text-slate-300" />
                      </div>
                    )}
                    <div className="absolute top-2.5 left-2.5">
                      <Badge variant={p.post_type === 'product' ? 'indigo' : 'slate'} className="bg-white/95 backdrop-blur-xs">
                        {p.post_type}
                      </Badge>
                    </div>
                  </div>

                  {/* Body Content */}
                  <div className="p-4 space-y-2">
                    <div className="flex items-center justify-between text-xs">
                      <span className="font-bold text-[#3D38F5] tabular-nums">
                        {formatPrice(p.price)}
                      </span>
                      <span className="text-[10.5px] text-slate-400">
                        {new Date(p.created_at).toLocaleDateString('id-ID', {
                          day: 'numeric',
                          month: 'short',
                        })}
                      </span>
                    </div>

                    <h3 className="text-sm font-bold text-slate-900 line-clamp-1 group-hover:text-[#3D38F5] transition-colors">
                      {p.title || p.caption || 'Postingan Tanpa Judul'}
                    </h3>

                    <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">
                      {p.caption || p.description || 'Tidak ada deskripsi.'}
                    </p>
                  </div>
                </div>

                {/* Author Footer & Takedown Action */}
                <div
                  className="p-3 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between gap-2"
                  onClick={(e) => e.stopPropagation()}
                >
                  <div className="flex items-center gap-2 truncate">
                    <div className="h-6 w-6 rounded-full bg-[#EEF0FF] text-[#3D38F5] font-bold text-[10px] flex items-center justify-center shrink-0">
                      {p.seller?.full_name ? p.seller.full_name[0].toUpperCase() : 'S'}
                    </div>
                    <span className="text-xs text-slate-600 font-medium truncate">
                      {p.seller?.full_name || 'Siswa'}
                    </span>
                  </div>

                  <div className="flex items-center gap-1 shrink-0">
                    <button
                      onClick={() => handleInspectPost(p)}
                      className="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-200/60 transition-colors cursor-pointer"
                      title="Lihat Detail"
                    >
                      <Eye className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => setTargetPostForDelete(p)}
                      className="p-1.5 rounded-lg text-rose-500 hover:text-rose-700 hover:bg-rose-50 transition-colors cursor-pointer"
                      title="Takedown Postingan"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      ) : (
        /* TABLE VIEW */
        <Card className="p-0 overflow-hidden">
          <Table>
            <TableHead>
              <TableRow>
                <TableHeaderCell className="pl-6">Konten & Thumbnail</TableHeaderCell>
                <TableHeaderCell>Tipe & Kategori</TableHeaderCell>
                <TableHeaderCell>Penulis / Siswa</TableHeaderCell>
                <TableHeaderCell>Harga</TableHeaderCell>
                <TableHeaderCell>Tanggal</TableHeaderCell>
                <TableHeaderCell className="pr-6 text-right">Moderasi</TableHeaderCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {posts.map((p) => {
                const firstImage = Array.isArray(p.images) && p.images.length > 0 ? p.images[0] : null;
                return (
                  <TableRow
                    key={p.id}
                    onClick={() => handleInspectPost(p)}
                    className="cursor-pointer group"
                  >
                    <TableCell className="pl-6">
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-14 rounded-lg bg-slate-100 border border-slate-200/80 overflow-hidden shrink-0 flex items-center justify-center">
                          {firstImage ? (
                            <img src={firstImage} alt="" className="h-full w-full object-cover" />
                          ) : (
                            <ImageIcon className="h-4 w-4 text-slate-400" />
                          )}
                        </div>
                        <div className="truncate max-w-[220px]">
                          <div className="font-semibold text-slate-900 group-hover:text-[#3D38F5] transition-colors truncate">
                            {p.title || p.caption || 'Tanpa Judul'}
                          </div>
                          <div className="text-[11px] text-slate-400 truncate">
                            ID: {p.id.slice(0, 8)}...
                          </div>
                        </div>
                      </div>
                    </TableCell>

                    <TableCell>
                      <Badge variant={p.post_type === 'product' ? 'indigo' : 'slate'} className="uppercase font-semibold text-[10px]">
                        {p.post_type}
                      </Badge>
                    </TableCell>

                    <TableCell>
                      <div className="font-medium text-slate-800">
                        {p.seller?.full_name || 'Siswa'}
                      </div>
                      <div className="text-[11px] text-slate-400">
                        @{p.seller?.username || 'user'}
                      </div>
                    </TableCell>

                    <TableCell className="font-bold text-slate-900 tabular-nums">
                      {formatPrice(p.price)}
                    </TableCell>

                    <TableCell className="text-[11px] text-slate-500 tabular-nums">
                      {new Date(p.created_at).toLocaleDateString('id-ID')}
                    </TableCell>

                    <TableCell className="pr-6 text-right" onClick={(e) => e.stopPropagation()}>
                      <div className="flex items-center justify-end gap-1.5">
                        <button
                          onClick={() => handleInspectPost(p)}
                          className="h-7.5 px-2.5 rounded-lg border border-slate-200 hover:bg-slate-100 text-slate-600 font-medium flex items-center gap-1 transition-colors cursor-pointer text-xs"
                        >
                          <Eye className="h-3.5 w-3.5" />
                          <span>Detail</span>
                        </button>
                        <button
                          onClick={() => setTargetPostForDelete(p)}
                          className="h-7.5 px-2.5 rounded-lg bg-rose-50 border border-rose-200 text-rose-600 hover:bg-rose-100 font-medium flex items-center gap-1 transition-colors cursor-pointer text-xs"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                          <span>Takedown</span>
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </Card>
      )}

      {/* 5. Pagination Bar */}
      <Card className="p-4 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-500">
        <div>
          Menampilkan <span className="font-semibold text-slate-900">{posts.length}</span> dari{' '}
          <span className="font-semibold text-slate-900">{totalCount}</span> postingan (Halaman {page} dari {totalPages})
        </div>

        <div className="flex items-center gap-1.5">
          <button
            disabled={page <= 1 || isLoading}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            className="h-8 px-3 rounded-lg border border-slate-200 bg-white font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors cursor-pointer shadow-2xs flex items-center gap-1"
          >
            <ChevronLeft className="h-3.5 w-3.5" />
            <span>Sebelumnya</span>
          </button>
          <button
            disabled={page >= totalPages || isLoading}
            onClick={() => setPage((p) => p + 1)}
            className="h-8 px-3 rounded-lg border border-slate-200 bg-white font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors cursor-pointer shadow-2xs flex items-center gap-1"
          >
            <span>Berikutnya</span>
            <ChevronRight className="h-3.5 w-3.5" />
          </button>
        </div>
      </Card>

      {/* 6. Post Detail Flyout Inspector Drawer */}
      <PostDetailDrawer
        post={selectedPostPreview}
        isOpen={isDrawerOpen}
        onClose={() => setIsDrawerOpen(false)}
        onRequestTakedown={(post) => {
          setTargetPostForDelete(post);
        }}
      />

      {/* 7. Modal Confirmation for Post Takedown */}
      {targetPostForDelete && (
        <div className="fixed inset-0 z-60 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs">
          <div className="bg-white rounded-2xl max-w-sm w-full p-6 space-y-4 shadow-2xl border border-slate-200 animate-in fade-in zoom-in-95">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-rose-50 border border-rose-200 flex items-center justify-center text-rose-600 shrink-0">
                <AlertTriangle className="h-5 w-5" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-slate-900">Takedown Postingan</h3>
                <p className="text-xs text-slate-500">Tindakan ini permanen dan menghapus konten dari feed.</p>
              </div>
            </div>

            <p className="text-xs text-slate-600 leading-relaxed">
              Apakah Anda yakin ingin menghapus postingan{' '}
              <strong className="text-slate-900">
                "{targetPostForDelete.title || targetPostForDelete.caption || 'Tanpa Judul'}"
              </strong>{' '}
              karya siswa <strong className="text-slate-900">@{targetPostForDelete.seller?.username || 'user'}</strong>?
            </p>

            <div className="flex items-center justify-end gap-2 pt-2">
              <button
                disabled={deletingId === targetPostForDelete.id}
                onClick={() => setTargetPostForDelete(null)}
                className="px-3.5 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100 transition-colors cursor-pointer"
              >
                Batal
              </button>
              <button
                disabled={deletingId === targetPostForDelete.id}
                onClick={confirmTakedown}
                className="px-4 py-2 rounded-xl text-xs font-semibold bg-rose-600 hover:bg-rose-700 text-white transition-colors cursor-pointer shadow-xs disabled:opacity-50"
              >
                {deletingId === targetPostForDelete.id ? 'Menghapus...' : 'Konfirmasi Takedown'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
