import { useState, useEffect, useCallback } from 'react';
import { Search, Trash2, AlertTriangle, RefreshCw, CheckCircle2 } from 'lucide-react';
import { Button, Input, Badge, LayerCard } from '@cloudflare/kumo';
import { adminService, type MarketPostRow, type ProfileRow } from '../services/adminService';

type PostWithSeller = MarketPostRow & { seller?: ProfileRow | null };

export function ContentModerationTab() {
  const [posts, setPosts] = useState<PostWithSeller[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [postTypeFilter, setPostTypeFilter] = useState('all');
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [targetPostForDelete, setTargetPostForDelete] = useState<PostWithSeller | null>(null);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const fetchPosts = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await adminService.getMarketPosts({
        search,
        postType: postTypeFilter,
        limit: 40,
      });
      setPosts(res.data);
      setTotalCount(res.count);
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal memuat feed: ${e}` });
    } finally {
      setIsLoading(false);
    }
  }, [search, postTypeFilter]);

  useEffect(() => {
    const timer = setTimeout(() => {
      fetchPosts();
    }, 250);
    return () => clearTimeout(timer);
  }, [fetchPosts]);

  const confirmTakedown = async () => {
    if (!targetPostForDelete) return;
    const postId = targetPostForDelete.id;
    setDeletingId(postId);

    try {
      await adminService.deleteMarketPost(postId);
      setPosts((prev) => prev.filter((p) => p.id !== postId));
      setTotalCount((prev) => Math.max(0, prev - 1));
      setFeedbackMsg({
        type: 'success',
        text: 'Postingan berhasil di-takedown dari database Supabase.',
      });
      setTargetPostForDelete(null);
    } catch (e) {
      setFeedbackMsg({ type: 'error', text: `Gagal menghapus postingan: ${e}` });
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <div className="p-6 md:p-8 space-y-6 max-w-7xl mx-auto">
      {/* Toast Feedback */}
      {feedbackMsg && (
        <div
          className={`p-3.5 rounded-xl border flex items-center justify-between text-xs font-medium ${
            feedbackMsg.type === 'success'
              ? 'bg-emerald-50 text-emerald-800 border-emerald-200'
              : 'bg-red-50 text-red-800 border-red-200'
          }`}
        >
          <div className="flex items-center gap-2">
            <CheckCircle2 className="h-4 w-4 text-emerald-600" />
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            onClick={() => setFeedbackMsg(null)}
            className="text-xs hover:opacity-75 cursor-pointer"
          >
            Tutup
          </button>
        </div>
      )}

      {/* Control Bar: Search & Type Filter */}
      <LayerCard className="p-4 border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs flex flex-col sm:flex-row items-center justify-between gap-4">
        <div className="w-full sm:w-96 relative">
          <Input
            placeholder="Cari konten caption, judul, atau kategori..."
            value={search}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => setSearch(e.target.value)}
            className="w-full text-xs"
          />
          <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-kumo-subtle pointer-events-none" />
        </div>

        <div className="flex items-center gap-2.5 w-full sm:w-auto justify-end">
          <span className="text-xs text-kumo-subtle hidden sm:inline">Tipe Feed:</span>
          <select
            value={postTypeFilter}
            onChange={(e: React.ChangeEvent<HTMLSelectElement>) => setPostTypeFilter(e.target.value)}
            className="h-8 rounded-lg border border-kumo-hairline bg-kumo-control px-2.5 text-xs text-kumo-default font-medium focus:outline-none focus:ring-1 focus:ring-indigo-500"
          >
            <option value="all">Semua Postingan</option>
            <option value="product">Produk Vokasi</option>
            <option value="thread">Threads Diskusi</option>
          </select>

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
      </LayerCard>

      {/* Feed Moderation Table */}
      <LayerCard className="border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs overflow-hidden">
        <div className="px-5 py-3.5 border-b border-kumo-hairline flex items-center justify-between bg-kumo-control/40">
          <div className="text-xs font-semibold text-kumo-default">
            Antrean Postingan Feed ({totalCount})
          </div>
          <div className="text-[11px] text-kumo-subtle">
            Moderasi takedown langsung mencerminkan perubahan ke aplikasi Flutter siswa
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b border-kumo-hairline bg-kumo-canvas text-kumo-subtle font-semibold">
                <th className="py-3 px-4">Konten & Media</th>
                <th className="py-3 px-4">Penulis / Siswa</th>
                <th className="py-3 px-4">Tipe & Kategori</th>
                <th className="py-3 px-4">Harga / Nilai</th>
                <th className="py-3 px-4">Interaksi</th>
                <th className="py-3 px-4 text-right">Aksi Moderasi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-kumo-hairline">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-kumo-subtle">
                    <RefreshCw className="h-5 w-5 animate-spin mx-auto mb-2 text-indigo-600" />
                    <span>Memuat antrean postingan...</span>
                  </td>
                </tr>
              ) : posts.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-12 text-center text-kumo-subtle">
                    Tidak ada postingan yang sesuai filter.
                  </td>
                </tr>
              ) : (
                posts.map((post) => {
                  const hasImage = post.images && post.images.length > 0;
                  return (
                    <tr key={post.id} className="hover:bg-kumo-tint/50 transition-colors">
                      <td className="py-3 px-4 max-w-xs">
                        <div className="flex items-start gap-2.5">
                          {hasImage ? (
                            <img
                              src={post.images[0]}
                              alt="media"
                              className="h-10 w-10 rounded-lg object-cover border border-kumo-hairline shrink-0"
                            />
                          ) : (
                            <div className="h-10 w-10 rounded-lg bg-kumo-control border border-kumo-hairline flex items-center justify-center text-[10px] text-kumo-subtle shrink-0">
                              Teks
                            </div>
                          )}
                          <div className="overflow-hidden">
                            {post.title && (
                              <div className="font-semibold text-kumo-default truncate">
                                {post.title}
                              </div>
                            )}
                            <div className="text-kumo-subtle text-[11px] line-clamp-2">
                              {post.caption || 'Tanpa teks caption'}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="font-medium text-kumo-default">
                          {post.seller?.full_name || 'Siswa'}
                        </div>
                        <div className="text-[11px] text-kumo-subtle">
                          @{post.seller?.username || 'user'} • {post.seller?.class_group || 'SMKN 8'}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-1.5">
                          <Badge variant={post.post_type === 'product' ? 'primary' : 'secondary'} className="text-[10px] uppercase font-bold py-0.5 px-2">
                            {post.post_type}
                          </Badge>
                          <span className="text-[11px] text-kumo-subtle font-medium">
                            {post.category}
                          </span>
                        </div>
                      </td>
                      <td className="py-3 px-4 font-semibold text-kumo-default">
                        {post.price > 0 ? `Rp ${post.price.toLocaleString('id-ID')}` : 'Gratis / Diskusi'}
                      </td>
                      <td className="py-3 px-4 text-kumo-subtle text-[11px]">
                        ❤️ {post.likes_count} • 💬 {post.comments_count}
                      </td>
                      <td className="py-3 px-4 text-right">
                        <Button
                          variant="secondary"
                          className="h-7 px-2.5 text-xs text-red-600 hover:bg-red-50 hover:text-red-700 border-red-200 inline-flex items-center gap-1 cursor-pointer"
                          onClick={() => setTargetPostForDelete(post)}
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                          <span>Takedown</span>
                        </Button>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </LayerCard>

      {/* Confirmation Modal for Takedown */}
      {targetPostForDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-xs">
          <div className="w-full max-w-md rounded-2xl bg-kumo-canvas p-6 border border-kumo-hairline shadow-xl space-y-4">
            <div className="flex items-center gap-3 text-red-600">
              <div className="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center shrink-0">
                <AlertTriangle className="h-5 w-5 text-red-600" />
              </div>
              <div>
                <h3 className="text-sm font-bold text-kumo-default">
                  Konfirmasi Takedown Konten
                </h3>
                <p className="text-xs text-kumo-subtle">
                  Tindakan ini akan menghapus postingan secara permanen.
                </p>
              </div>
            </div>

            <div className="rounded-xl bg-kumo-control p-3 border border-kumo-hairline text-xs space-y-1">
              <div className="font-semibold text-kumo-default">
                {targetPostForDelete.title || targetPostForDelete.caption}
              </div>
              <div className="text-kumo-subtle text-[11px]">
                Penulis: {targetPostForDelete.seller?.full_name} (@{targetPostForDelete.seller?.username})
              </div>
            </div>

            <div className="flex items-center justify-end gap-2.5 pt-2">
              <Button
                variant="secondary"
                className="text-xs h-9 px-3"
                onClick={() => setTargetPostForDelete(null)}
                disabled={deletingId !== null}
              >
                Batal
              </Button>
              <Button
                variant="primary"
                className="text-xs h-9 px-3 bg-red-600 hover:bg-red-700 text-white"
                onClick={confirmTakedown}
                disabled={deletingId !== null}
              >
                {deletingId ? 'Menghapus...' : 'Ya, Hapus Post'}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
