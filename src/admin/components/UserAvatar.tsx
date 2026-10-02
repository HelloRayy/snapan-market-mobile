import { useState, useEffect } from 'react';

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
 * Reusable user avatar with graceful image fallback to initials.
 * Automatically handles broken URLs and distinct color schemes based on user role.
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
  const initial = cleanName ? cleanName.charAt(0).toUpperCase() : 'S';

  const isAdmin = role === 'admin';
  const bgColor = isAdmin ? '#fff1e6' : '#eaf0fc';
  const textColor = isAdmin ? '#f97316' : '#4272d7';
  const borderColor = isAdmin ? 'rgba(249, 115, 22, 0.2)' : 'rgba(66, 114, 215, 0.2)';

  const containerStyle: React.CSSProperties = {
    width: `${size}px`,
    height: `${size}px`,
    borderRadius,
    background: bgColor,
    color: textColor,
    border: `1px solid ${borderColor}`,
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 700,
    fontSize: `${Math.max(11, Math.round(size * 0.4))}px`,
    flexShrink: 0,
    overflow: 'hidden',
    userSelect: 'none',
    ...style,
  };

  if (avatarUrl && !hasError) {
    return (
      <div className={`user-avatar ${className}`} style={containerStyle}>
        <img
          src={avatarUrl}
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

  return (
    <div className={`user-avatar ${className}`} style={containerStyle} aria-label={cleanName}>
      {initial}
    </div>
  );
}
