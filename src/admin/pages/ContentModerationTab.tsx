import React, { useState, useEffect, useCallback } from 'react';
import {
  Search,
  Trash2,
  AlertTriangle,
  RefreshCw,
  CheckCircle2,
  X,
  Eye,
  ChevronLeft,
  ChevronRight,
  ShoppingBag,
  MessageSquare,
  ImageIcon,
  MapPin,
  Grid,
  List as ListIcon,
} from 'lucide-react';
import { Button, Input, Badge, LayerCard } from '@cloudflare/kumo';
import { adminService, type MarketPostRow, type ProfileRow } from '../services/adminService';

type PostWithSeller = MarketPostRow & { seller?: ProfileRow | null };

export function ContentModerationTab() {
  const [posts, setPosts] = useState<PostWithSeller[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [postTypeFilter, setPostTypeFilter] = useState('all');
  const [page, setPage] = useState(1);
  const [pageSize] = useState(12);
  const [viewMode, setViewMode] = useState<'grid' | 'table'>('grid');

  // Deletion / Takedown State
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [targetPostForDelete, setTargetPostForDelete] = useState<PostWithSeller | null>(null);
  const [selectedPostPreview, setSelectedPostPreview] = useState<PostWithSeller | null>(null);
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

  const handleFilterChange = (setter: () => void) => {
    setPage(1);
    setter();
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
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
  const startItem = totalCount === 0 ? 0 : (page - 1) * pageSize + 1;
  const endItem = Math.min(totalCount, page * pageSize);

  return (
    <div className="p-4 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Toast Feedback */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border flex items-center justify-between text-xs font-medium transition-all ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-red-50 text-red-800 border-red-200'
          }`}
        >
          <div className="flex items-center gap-2">
            {feedbackMsg.type === 'success' ? (
              <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
            ) : (
              <AlertTriangle className="h-4 w-4 text-red-600 shrink-0" />
            )}
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="text-xs hover:opacity-75 cursor-pointer ml-3 font-semibold"
          >
            Tutup
          </button>
        </div>
      )}

      {/* Control Bar: Search & Filter Chips */}
      <LayerCard className="p-4 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs space-y-3.5">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-3">
          {/* Search Input with Instant Clear */}
          <div className="w-full sm:w-96 relative">
            <Input
              placeholder="Cari caption, judul barang, atau kategori..."
              value={search}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                handleFilterChange(() => setSearch(e.target.value))
              }
              className="w-full text-xs pr-8"
            />
            {search ? (
              <button
                onClick={() => handleFilterChange(() => setSearch(''))}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 p-0.5 rounded-full hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default cursor-pointer"
                title="Hapus pencarian"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            ) : (
              <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-kumo-subtle pointer-events-none" />
            )}
          </div>

          <div className="flex items-center gap-2 w-full sm:w-auto justify-end">
            {/* View Mode Toggle: Grid vs Table */}
            <div className="flex items-center rounded-lg border border-kumo-hairline bg-kumo-control p-0.5">
              <button
                onClick={() => setViewMode('grid')}
                className={`p-1.5 rounded-md text-xs cursor-pointer ${
                  viewMode === 'grid'
                    ? 'bg-kumo-canvas text-kumo-default shadow-xs font-semibold'
                    : 'text-kumo-subtle hover:text-kumo-default'
                }`}
                title="Tampilan Grid Card"
              >
                <Grid className="h-3.5 w-3.5" />
              </button>
              <button
                onClick={() => setViewMode('table')}
                className={`p-1.5 rounded-md text-xs cursor-pointer ${
                  viewMode === 'table'
                    ? 'bg-kumo-canvas text-kumo-default shadow-xs font-semibold'
                    : 'text-kumo-subtle hover:text-kumo-default'
                }`}
                title="Tampilan List Tabel"
              >
                <ListIcon className="h-3.5 w-3.5" />
              </button>
            </div>

            <Button
              variant="secondary"
              className="h-8 px-2.5 text-xs flex items-center gap-1.5"
              onClick={fetchPosts}
              disabled={isLoading}
            >
              <RefreshCw className={`h-3.5 w-3.5 ${isLoading ? 'animate-spin' : ''}`} />
              <span className="hidden sm:inline">Refresh</span>
            </Button>
          </div>
        </div>

        {/* Filter Chips Bar */}
        <div className="flex items-center gap-2 overflow-x-auto pt-1 pb-0.5 text-xs border-t border-kumo-hairline/60">
          <span className="text-kumo-subtle text-[11px] font-semibold shrink-0">Tipe Feed:</span>
          
          <button
            onClick={() => handleFilterChange(() => setPostTypeFilter('all'))}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 ${
              postTypeFilter === 'all'
                ? 'bg-indigo-600 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            Semua Konten
          </button>
          <button
            onClick={() => handleFilterChange(() => setPostTypeFilter('product'))}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 flex items-center gap-1 ${
              postTypeFilter === 'product'
                ? 'bg-emerald-600 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            <ShoppingBag className="h-3 w-3" />
            <span>Hanya Produk Jualan</span>
          </button>
          <button
            onClick={() => handleFilterChange(() => setPostTypeFilter('thread'))}
            className={`px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors cursor-pointer shrink-0 flex items-center gap-1 ${
              postTypeFilter === 'thread'
                ? 'bg-blue-600 text-white shadow-xs'
                : 'bg-kumo-control text-kumo-subtle hover:text-kumo-default'
            }`}
          >
            <MessageSquare className="h-3 w-3" />
            <span>Hanya Utas / Thread</span>
          </button>
        </div>
      </LayerCard>

      {/* Main Posts View: Grid or Table */}
      {viewMode === 'grid' ? (
        <div className="space-y-4">
          <div className="flex items-center justify-between text-xs text-kumo-subtle px-1">
            <span>Menampilkan {startItem}-{endItem} dari {totalCount} postingan</span>
            <span>Halaman {page} dari {totalPages}</span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {isLoading ? (
              Array.from({ length: 6 }).map((_, i) => (
                <div
                  key={i}
                  className="rounded-xl border border-kumo-hairline bg-kumo-control/30 p-4 space-y-3 animate-pulse"
                >
                  <div className="flex items-center gap-2.5">
                    <div className="h-8 w-8 rounded-full bg-kumo-control" />
                    <div className="space-y-1.5 flex-1">
                      <div className="h-3 w-24 rounded bg-kumo-control" />
                      <div className="h-2 w-16 rounded bg-kumo-control" />
                    </div>
                  </div>
                  <div className="h-36 rounded-lg bg-kumo-control" />
                  <div className="h-3 w-3/4 rounded bg-kumo-control" />
                </div>
              ))
            ) : posts.length === 0 ? (
              <div className="col-span-full py-16 text-center text-xs text-kumo-subtle space-y-2 border border-kumo-hairline rounded-xl bg-kumo-canvas">
                <MessageSquare className="h-8 w-8 mx-auto opacity-40 text-kumo-subtle" />
                <p className="font-medium">Tidak ada postingan yang sesuai kriteria.</p>
              </div>
            ) : (
              posts.map((p) => {
                const isProduct = p.post_type === 'product';
                const hasImages = Array.isArray(p.images) && p.images.length > 0;
                return (
                  <div
                    key={p.id}
                    className="rounded-xl border border-kumo-hairline bg-kumo-canvas p-4 shadow-xs hover:border-kumo-hairline/80 transition-all flex flex-col justify-between group"
                  >
                    <div className="space-y-3">
                      {/* Author Line */}
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2 min-w-0">
                          <div className="h-7 w-7 rounded-full bg-indigo-50 border border-indigo-200 flex items-center justify-center font-bold text-xs text-indigo-700 shrink-0">
                            {p.seller?.full_name ? p.seller.full_name.charAt(0).toUpperCase() : 'S'}
                          </div>
                          <div className="min-w-0">
                            <div className="text-xs font-semibold text-kumo-default truncate flex items-center gap-1">
                              {p.seller?.full_name || 'Siswa Snapan'}
                              {p.seller?.is_verified && (
                                <CheckCircle2 className="h-3 w-3 text-blue-600 shrink-0" />
                              )}
                            </div>
                            <div className="text-[10px] text-kumo-subtle">
                              @{p.seller?.username || 'user'} • {p.seller?.class_group || 'SMKN 8'}
                            </div>
                          </div>
                        </div>

                        <Badge
                          variant={isProduct ? 'primary' : 'secondary'}
                          className={`text-[9px] font-bold uppercase py-0.2 px-1.5 ${
                            isProduct
                              ? 'bg-emerald-100 text-emerald-800 border-emerald-200'
                              : 'bg-blue-100 text-blue-800 border-blue-200'
                          }`}
                        >
                          {isProduct ? 'Produk' : 'Thread'}
                        </Badge>
                      </div>

                      {/* Image Thumbnail */}
                      {hasImages && (
                        <div
                          className="relative h-40 rounded-lg overflow-hidden border border-kumo-hairline bg-slate-900/5 cursor-pointer"
                          onClick={() => setSelectedPostPreview(p)}
                        >
                          <img
                            src={p.images[0]}
                            alt={p.title || 'Feed Media'}
                            className="h-full w-full object-cover group-hover:scale-102 transition-transform duration-200"
                          />
                          {p.images.length > 1 && (
                            <span className="absolute bottom-2 right-2 rounded-md bg-black/60 px-1.5 py-0.5 text-[10px] font-bold text-white backdrop-blur-xs flex items-center gap-1">
                              <ImageIcon className="h-2.5 w-2.5" />
                              +{p.images.length - 1}
                            </span>
                          )}
                        </div>
                      )}

                      {/* Content Preview */}
                      <div className="space-y-1">
                        {p.title && (
                          <h4 className="text-xs font-bold text-kumo-default line-clamp-1">
                            {p.title}
                          </h4>
                        )}
                        <p className="text-xs text-kumo-subtle line-clamp-2 leading-relaxed">
                          {p.caption || 'Tanpa deskripsi'}
                        </p>
                      </div>

                      {/* Price & Location Tag */}
                      {isProduct && (
                        <div className="flex items-center justify-between text-xs pt-1 border-t border-kumo-hairline/60">
                          <span className="font-bold text-indigo-600">
                            {formatPrice(p.price)}
                          </span>
                          <span className="text-[10px] text-kumo-subtle flex items-center gap-1">
                            <MapPin className="h-3 w-3" />
                            {p.location_tag || 'SMKN 8'}
                          </span>
                        </div>
                      )}
                    </div>

                    {/* Card Actions */}
                    <div className="flex items-center justify-between pt-3 mt-3 border-t border-kumo-hairline text-[11px]">
                      <span className="text-kumo-subtle font-mono text-[10px]">
                        {p.created_at
                          ? new Date(p.created_at).toLocaleDateString('id-ID', {
                              day: 'numeric',
                              month: 'short',
                            })
                          : ''}
                      </span>

                      <div className="flex items-center gap-1.5">
                        <Button
                          variant="secondary"
                          className="h-7 px-2 text-xs flex items-center gap-1 text-kumo-subtle hover:text-kumo-default"
                          onClick={() => setSelectedPostPreview(p)}
                        >
                          <Eye className="h-3.5 w-3.5" />
                          <span>Detail</span>
                        </Button>

                        <Button
                          variant="secondary"
                          className="h-7 px-2 text-xs flex items-center gap-1 text-red-600 hover:bg-red-50 hover:text-red-700"
                          onClick={() => setTargetPostForDelete(p)}
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                          <span>Takedown</span>
                        </Button>
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        </div>
      ) : (
        /* Table View */
        <LayerCard className="border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="border-b border-kumo-hairline bg-kumo-canvas text-kumo-subtle font-semibold">
                  <th className="py-3 px-4">Konten & Penulis</th>
                  <th className="py-3 px-4">Tipe</th>
                  <th className="py-3 px-4">Harga</th>
                  <th className="py-3 px-4">Lokasi COD</th>
                  <th className="py-3 px-4">Tanggal</th>
                  <th className="py-3 px-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-kumo-hairline">
                {isLoading ? (
                  Array.from({ length: 6 }).map((_, i) => (
                    <tr key={i} className="animate-pulse">
                      <td className="py-3 px-4"><div className="h-3 w-40 rounded bg-kumo-control" /></td>
                      <td className="py-3 px-4"><div className="h-3 w-16 rounded bg-kumo-control" /></td>
                      <td className="py-3 px-4"><div className="h-3 w-20 rounded bg-kumo-control" /></td>
                      <td className="py-3 px-4"><div className="h-3 w-16 rounded bg-kumo-control" /></td>
                      <td className="py-3 px-4"><div className="h-3 w-16 rounded bg-kumo-control" /></td>
                      <td className="py-3 px-4 text-right"><div className="h-7 w-20 rounded bg-kumo-control ml-auto" /></td>
                    </tr>
                  ))
                ) : posts.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="py-12 text-center text-kumo-subtle">
                      Tidak ada postingan yang sesuai filter.
                    </td>
                  </tr>
                ) : (
                  posts.map((p) => (
                    <tr key={p.id} className="hover:bg-kumo-tint/50 transition-colors">
                      <td className="py-3 px-4 max-w-xs">
                        <div className="font-semibold text-kumo-default truncate">
                          {p.title || p.caption || 'Tanpa Judul'}
                        </div>
                        <div className="text-[11px] text-kumo-subtle">
                          Oleh @{p.seller?.username || 'user'} ({p.seller?.full_name || 'Siswa'})
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <Badge
                          variant={p.post_type === 'product' ? 'primary' : 'secondary'}
                          className="text-[9px] uppercase font-bold"
                        >
                          {p.post_type}
                        </Badge>
                      </td>
                      <td className="py-3 px-4 font-semibold text-indigo-600">
                        {p.post_type === 'product' ? formatPrice(p.price) : '-'}
                      </td>
                      <td className="py-3 px-4 text-kumo-subtle">
                        {p.location_tag || 'SMKN 8'}
                      </td>
                      <td className="py-3 px-4 text-kumo-subtle font-mono text-[11px]">
                        {p.created_at ? new Date(p.created_at).toLocaleDateString('id-ID') : '-'}
                      </td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <Button
                            variant="secondary"
                            className="h-7 px-2 text-xs"
                            onClick={() => setSelectedPostPreview(p)}
                          >
                            <Eye className="h-3.5 w-3.5" />
                          </Button>
                          <Button
                            variant="secondary"
                            className="h-7 px-2 text-xs text-red-600 hover:bg-red-50 hover:text-red-700"
                            onClick={() => setTargetPostForDelete(p)}
                          >
                            <Trash2 className="h-3.5 w-3.5" />
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </LayerCard>
      )}

      {/* Pagination Controls */}
      <div className="flex items-center justify-between text-xs text-kumo-subtle pt-2">
        <div>
          Halaman <span className="font-semibold text-kumo-default">{page}</span> dari{' '}
          <span className="font-semibold text-kumo-default">{totalPages}</span>
        </div>

        <div className="flex items-center gap-1.5">
          <Button
            variant="secondary"
            className="h-7 px-2.5 text-xs flex items-center gap-1"
            disabled={page <= 1 || isLoading}
            onClick={() => setPage((p) => Math.max(1, p - 1))}
          >
            <ChevronLeft className="h-3.5 w-3.5" />
            <span>Sebelumnya</span>
          </Button>

          <Button
            variant="secondary"
            className="h-7 px-2.5 text-xs flex items-center gap-1"
            disabled={page >= totalPages || isLoading}
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
          >
            <span>Selanjutnya</span>
            <ChevronRight className="h-3.5 w-3.5" />
          </Button>
        </div>
      </div>

      {/* FULL POST DETAIL PREVIEW MODAL */}
      {selectedPostPreview && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="w-full max-w-lg bg-kumo-canvas border border-kumo-hairline rounded-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col animate-in fade-in zoom-in-95 duration-150">
            {/* Modal Header */}
            <div className="flex items-center justify-between px-5 py-3.5 border-b border-kumo-hairline bg-kumo-control/30">
              <div className="flex items-center gap-2">
                <Badge
                  variant={selectedPostPreview.post_type === 'product' ? 'primary' : 'secondary'}
                  className="text-[10px] font-bold uppercase py-0.5"
                >
                  {selectedPostPreview.post_type === 'product' ? 'Produk Jualan' : 'Utas Komunitas'}
                </Badge>
                <span className="text-xs text-kumo-subtle">ID: {selectedPostPreview.id.substring(0, 8)}...</span>
              </div>

              <button
                onClick={() => setSelectedPostPreview(null)}
                className="p-1 rounded-lg hover:bg-kumo-control text-kumo-subtle hover:text-kumo-default cursor-pointer"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            {/* Modal Body */}
            <div className="p-5 overflow-y-auto space-y-4 text-xs">
              {/* Author Bar */}
              <div className="flex items-center gap-3 p-3 rounded-xl border border-kumo-hairline bg-kumo-control/30">
                <div className="h-9 w-9 rounded-full bg-indigo-50 border border-indigo-200 flex items-center justify-center font-bold text-sm text-indigo-700 shrink-0">
                  {selectedPostPreview.seller?.full_name?.charAt(0).toUpperCase() || 'S'}
                </div>
                <div>
                  <div className="font-semibold text-kumo-default text-xs flex items-center gap-1.5">
                    {selectedPostPreview.seller?.full_name || 'Penjual Siswa'}
                    {selectedPostPreview.seller?.is_verified && (
                      <CheckCircle2 className="h-3.5 w-3.5 text-blue-600" />
                    )}
                  </div>
                  <div className="text-[11px] text-kumo-subtle">
                    @{selectedPostPreview.seller?.username || 'user'} • {selectedPostPreview.seller?.class_group || 'SMKN 8 Jakarta'}
                  </div>
                </div>
              </div>

              {/* Photos Carousel/Grid */}
              {Array.isArray(selectedPostPreview.images) && selectedPostPreview.images.length > 0 && (
                <div className="space-y-2">
                  <div className="text-[11px] font-semibold text-kumo-subtle">Foto Lampiran ({selectedPostPreview.images.length})</div>
                  <div className="grid grid-cols-2 gap-2">
                    {selectedPostPreview.images.map((img, i) => (
                      <a
                        key={i}
                        href={img}
                        target="_blank"
                        rel="noreferrer"
                        className="block rounded-lg overflow-hidden border border-kumo-hairline bg-slate-900/5 aspect-4/3 group"
                      >
                        <img
                          src={img}
                          alt="Media attachment"
                          className="h-full w-full object-cover group-hover:scale-105 transition-transform"
                        />
                      </a>
                    ))}
                  </div>
                </div>
              )}

              {/* Text content */}
              <div className="space-y-1.5">
                {selectedPostPreview.title && (
                  <h3 className="text-sm font-bold text-kumo-default">
                    {selectedPostPreview.title}
                  </h3>
                )}
                <p className="text-xs text-kumo-default whitespace-pre-wrap leading-relaxed bg-kumo-control/20 p-3 rounded-lg border border-kumo-hairline/60">
                  {selectedPostPreview.caption}
                </p>
              </div>

              {/* Product Meta */}
              {selectedPostPreview.post_type === 'product' && (
                <div className="grid grid-cols-2 gap-2 p-3 rounded-xl border border-kumo-hairline bg-kumo-control/30 text-xs">
                  <div>
                    <span className="text-kumo-subtle text-[11px] block">Harga:</span>
                    <span className="font-bold text-indigo-600 text-sm">
                      {formatPrice(selectedPostPreview.price)}
                    </span>
                  </div>
                  <div>
                    <span className="text-kumo-subtle text-[11px] block">Titik Temu COD:</span>
                    <span className="font-medium text-kumo-default">
                      {selectedPostPreview.location_tag || 'SMKN 8'}
                    </span>
                  </div>
                </div>
              )}
            </div>

            {/* Modal Footer */}
            <div className="p-4 border-t border-kumo-hairline flex items-center justify-between bg-kumo-canvas">
              <Button
                variant="secondary"
                className="text-xs h-8 px-3"
                onClick={() => setSelectedPostPreview(null)}
              >
                Tutup
              </Button>

              <Button
                variant="primary"
                className="text-xs h-8 px-3 bg-red-600 hover:bg-red-700 text-white font-semibold flex items-center gap-1.5"
                onClick={() => {
                  setTargetPostForDelete(selectedPostPreview);
                }}
              >
                <Trash2 className="h-3.5 w-3.5" />
                <span>Takedown Postingan Ini</span>
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* CONFIRM TAKEDOWN MODAL */}
      {targetPostForDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/55 backdrop-blur-xs">
          <div className="w-full max-w-sm bg-kumo-canvas border border-kumo-hairline rounded-2xl shadow-2xl p-5 space-y-4 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center text-red-600 shrink-0">
                <AlertTriangle className="h-5 w-5" />
              </div>
              <div>
                <h4 className="text-sm font-bold text-kumo-default">Takedown Konten</h4>
                <p className="text-xs text-kumo-subtle">Penghapusan permanen dari server</p>
              </div>
            </div>

            <p className="text-xs text-kumo-default leading-relaxed">
              Apakah Anda yakin ingin menghapus postingan ini dari feed sekolah?
              Postingan dan seluruh komentar terkait akan dihapus secara permanen dari Supabase.
            </p>

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-kumo-hairline">
              <Button
                variant="secondary"
                className="text-xs h-8 px-3"
                disabled={deletingId !== null}
                onClick={() => setTargetPostForDelete(null)}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                className="text-xs h-8 px-3 bg-red-600 hover:bg-red-700 text-white font-semibold"
                disabled={deletingId !== null}
                onClick={confirmTakedown}
              >
                {deletingId ? 'Menghapus...' : 'Ya, Hapus Postingan'}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
