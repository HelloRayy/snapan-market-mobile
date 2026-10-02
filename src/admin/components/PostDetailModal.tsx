import { X, Trash2, ExternalLink } from 'lucide-react';
import type { MarketPostRow, ProfileRow } from '../services/adminService';
import { Badge } from './tremor/Badge';

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
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/40 backdrop-blur-xs"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg bg-white rounded-2xl border border-slate-200 shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 flex flex-col max-h-[90vh]"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-slate-100 bg-slate-50/50">
          <div>
            <h3 className="text-base font-bold text-slate-900">
              Inspeksi Konten Feed
            </h3>
            <p className="text-xs text-slate-500 mt-0.5">
              ID: {post.id.slice(0, 8)}... • Diterbitkan {new Date(post.created_at).toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
              })}
            </p>
          </div>
          <button
            onClick={onClose}
            className="h-8 w-8 rounded-lg flex items-center justify-center text-slate-400 hover:text-slate-700 hover:bg-slate-100 transition-colors cursor-pointer"
            aria-label="Tutup modal"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 overflow-y-auto space-y-5 text-xs">
          {/* Images Grid */}
          {images.length > 0 && (
            <div className="space-y-2">
              <h4 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
                Lampiran Media ({images.length})
              </h4>
              <div className="grid grid-cols-2 gap-2">
                {images.map((imgUrl, i) => (
                  <a
                    key={i}
                    href={imgUrl}
                    target="_blank"
                    rel="noreferrer"
                    className="relative aspect-video rounded-xl overflow-hidden bg-slate-100 border border-slate-200 block group"
                  >
                    <img
                      src={imgUrl}
                      alt={`Preview ${i + 1}`}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
                    />
                    <div className="absolute inset-0 bg-slate-900/20 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center text-white text-xs font-semibold">
                      <ExternalLink className="h-4 w-4" />
                    </div>
                  </a>
                ))}
              </div>
            </div>
          )}

          {/* Title & Price */}
          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <Badge variant={post.post_type === 'product' ? 'indigo' : 'slate'} className="uppercase">
                {post.post_type}
              </Badge>
              <span className="text-sm font-bold text-slate-900 tabular-nums">
                {formatPrice(post.price)}
              </span>
            </div>
            <h4 className="text-base font-bold text-slate-900">
              {post.title || 'Postingan Tanpa Judul'}
            </h4>
            <div className="p-3.5 rounded-xl border border-slate-200 bg-slate-50 text-slate-700 leading-relaxed whitespace-pre-wrap">
              {post.caption || post.description || 'Tidak ada deskripsi tambahan.'}
            </div>
          </div>

          {/* Author Card */}
          <div className="space-y-2">
            <h5 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
              Penulis / Siswa Pemilik
            </h5>
            <div className="flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white">
              <div className="h-10 w-10 rounded-xl bg-[#EEF0FF] border border-[#D8DBFE] flex items-center justify-center font-bold text-xs text-[#3D38F5] shrink-0">
                {post.seller?.avatar_url ? (
                  <img
                    src={post.seller.avatar_url}
                    alt={post.seller.full_name || ''}
                    className="h-full w-full rounded-xl object-cover"
                  />
                ) : post.seller?.full_name ? (
                  post.seller.full_name.charAt(0).toUpperCase()
                ) : (
                  'S'
                )}
              </div>
              <div>
                <div className="text-xs font-bold text-slate-900">
                  {post.seller?.full_name || 'Siswa SMKN 8'}
                </div>
                <div className="text-[11px] text-slate-500">
                  @{post.seller?.username || 'user'} • {post.seller?.class_group || 'Umum'}
                </div>
              </div>
            </div>
          </div>

          {/* Metadata Table */}
          <div className="rounded-xl border border-slate-200 bg-white divide-y divide-slate-100">
            <div className="flex items-center justify-between p-3">
              <span className="text-slate-500">Kategori / Topik</span>
              <span className="font-semibold text-slate-900">{post.category || post.topic_tag || 'Umum'}</span>
            </div>
            {post.location_tag && (
              <div className="flex items-center justify-between p-3">
                <span className="text-slate-500">Lokasi COD</span>
                <span className="font-semibold text-slate-900">{post.location_tag}</span>
              </div>
            )}
            <div className="flex items-center justify-between p-3">
              <span className="text-slate-500">Waktu Dibuat</span>
              <span className="font-semibold text-slate-900">
                {new Date(post.created_at).toLocaleString('id-ID')}
              </span>
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/50 flex items-center justify-between gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-200/60 transition-colors cursor-pointer"
          >
            Tutup
          </button>
          <button
            onClick={() => onRequestTakedown(post)}
            className="px-4 py-2 rounded-xl text-xs font-semibold bg-rose-600 hover:bg-rose-700 text-white transition-all flex items-center gap-1.5 cursor-pointer shadow-xs"
          >
            <Trash2 className="h-3.5 w-3.5" />
            <span>Takedown Postingan</span>
          </button>
        </div>
      </div>
    </div>
  );
}
