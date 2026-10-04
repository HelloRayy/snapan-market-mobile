import { Trash2, ExternalLink } from 'lucide-react';
import { SlideOverDrawer } from './SlideOverDrawer';
import { UserAvatar } from './UserAvatar';
import type { MarketPostRow, ProfileRow } from '../services/adminService';

type PostWithSeller = MarketPostRow & { seller?: ProfileRow | null };

interface PostDetailDrawerProps {
  post: PostWithSeller | null;
  isOpen: boolean;
  onClose: () => void;
  onRequestTakedown: (post: PostWithSeller) => void;
}

export function PostDetailDrawer({
  post,
  isOpen,
  onClose,
  onRequestTakedown,
}: PostDetailDrawerProps) {
  if (!post) return null;

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
    <SlideOverDrawer
      isOpen={isOpen}
      onClose={onClose}
      title="Inspeksi Konten Feed"
      subtitle={`ID: ${post.id.slice(0, 8)}... • Diterbitkan ${new Date(post.created_at).toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      })}`}
      footer={
        <button
          onClick={() => onRequestTakedown(post)}
          className="w-full py-2.5 px-4 rounded-xl font-semibold text-xs bg-red-600 hover:bg-red-700 text-white transition-all flex items-center justify-center gap-2 cursor-pointer shadow-xs"
        >
          <Trash2 className="h-4 w-4" />
          <span>Takedown / Hapus Postingan Ini</span>
        </button>
      }
    >
      {/* 1. Media Preview Carousel / Grid */}
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

      {/* 2. Post Title & Full Caption */}
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <span className="px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-[#EEF0FF] text-[#3D38F5] border border-[#D8DBFE]">
            {post.post_type}
          </span>
          <span className="text-sm font-bold text-slate-900 tabular-nums">
            {formatPrice(post.price)}
          </span>
        </div>
        <h3 className="text-base font-bold text-slate-900">
          {post.title || 'Postingan Tanpa Judul'}
        </h3>
        <div className="p-4 rounded-xl border border-slate-200/80 bg-slate-50/50 text-xs text-slate-700 leading-relaxed whitespace-pre-wrap">
          {post.caption || post.description || 'Tidak ada keterangan tambahan.'}
        </div>
      </div>

      {/* 3. Author / Student Profile */}
      <div className="space-y-3">
        <h4 className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">
          Penulis / Siswa Pemilik
        </h4>
        <div className="flex items-center gap-3 p-3.5 rounded-xl border border-slate-200/80 bg-white">
          <UserAvatar
            avatarUrl={post.seller?.avatar_url}
            name={post.seller?.full_name}
            size={40}
            borderRadius="12px"
            role={post.seller?.role}
          />
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

      {/* 4. Metadata Details */}
      <div className="rounded-xl border border-slate-200/80 bg-white p-3.5 space-y-2.5 text-xs">
        <div className="flex items-center justify-between py-1 border-b border-slate-100">
          <span className="text-slate-500">Kategori / Jurusan</span>
          <span className="font-semibold text-slate-900">{post.category || 'Umum'}</span>
        </div>
        {post.location_tag && (
          <div className="flex items-center justify-between py-1 border-b border-slate-100">
            <span className="text-slate-500">Lokasi COD</span>
            <span className="font-semibold text-slate-900">{post.location_tag}</span>
          </div>
        )}
        <div className="flex items-center justify-between py-1">
          <span className="text-slate-500">Waktu Pembuatan</span>
          <span className="font-semibold text-slate-900">
            {new Date(post.created_at).toLocaleString('id-ID')}
          </span>
        </div>
      </div>
    </SlideOverDrawer>
  );
}
