import { useState, useEffect } from 'react';
import { getOreoAvatarUrl } from '@/utils/oreoAvatar';

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
 * Reusable user avatar with modern @oreo-design/avatar gradient fallback.
 * Automatically handles broken URLs or missing avatars with elegant Figma-method soft gradients.
 */
export function UserAvatar({
  avatarUrl,
  name,
  size = 36,
  borderRadius = '8px',
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
  const fallbackOreoUrl = getOreoAvatarUrl(cleanName || 'siswa-snapan', {
    size,
    appearance: role === 'admin' ? 'dark' : 'light',
  });

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
    border: '1px solid rgba(0,0,0,0.06)',
    ...style,
  };

  const finalSrc = avatarUrl && !hasError ? avatarUrl : fallbackOreoUrl;

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
