import { useState, useEffect } from 'react';
import { User } from 'lucide-react';
import { getOreoAvatarUrl } from '@/utils/oreoAvatar';

export const FORCE_DEFAULT_AVATAR = false;

interface UserAvatarProps {
  avatarUrl?: string | null;
  name?: string | null;
  size?: number;
  borderRadius?: string;
  role?: string | null;
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Reusable user avatar with standard default silhouette fallback.
 * Renders avatarUrl from the database when available; falls back to a consistent default silhouette avatar
 * with neutral gray background (#E2E8F0) and slate icon (#94A3B8) if user has no avatar set or URL is broken.
 */
export function UserAvatar({
  avatarUrl,
  name,
  size = 36,
  borderRadius = '50%',
  role,
  className = '',
  style = {},
}: UserAvatarProps) {
  const [hasError, setHasError] = useState(false);

  // Reset error state if avatarUrl changes
  useEffect(() => {
    setHasError(false);
  }, [avatarUrl]);

  const cleanName = (name || '').trim();
  const iconSize = Math.max(14, Math.round(size * 0.56));

  const containerStyle: React.CSSProperties = {
    width: `${size}px`,
    height: `${size}px`,
    borderRadius,
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
    overflow: 'hidden',
    userSelect: 'none',
    boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
    border: '1px solid rgba(0,0,0,0.08)',
    backgroundColor: '#E2E8F0',
    color: '#94A3B8',
    ...style,
  };

  if (FORCE_DEFAULT_AVATAR || !avatarUrl || hasError) {
    return (
      <div
        className={`user-avatar ${className}`}
        style={containerStyle}
        aria-label={cleanName || 'User Avatar'}
        title={cleanName || undefined}
      >
        <User size={iconSize} strokeWidth={2.2} />
      </div>
    );
  }

  const fallbackOreoUrl = getOreoAvatarUrl(cleanName || 'siswa-snapan', {
    size,
    appearance: role === 'admin' ? 'dark' : 'light',
  });

  const finalSrc = avatarUrl || fallbackOreoUrl;

  return (
    <div className={`user-avatar ${className}`} style={containerStyle} aria-label={cleanName || 'User Avatar'}>
      <img
        src={finalSrc}
        alt={cleanName || 'Avatar'}
        loading="lazy"
        referrerPolicy="no-referrer"
        onError={() => setHasError(true)}
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          borderRadius: 'inherit',
        }}
      />
    </div>
  );
}
