import { useState } from 'react';
import type { ProfileRow } from '../services/adminService';
import { UserAvatar } from './UserAvatar';

interface AdminAccountDropdownProps {
  adminEmail: string;
  adminRole: string;
  adminProfile?: ProfileRow | null;
  onLogout?: () => void;
}

export function AdminAccountDropdown({
  adminEmail,
  adminRole,
  adminProfile,
  onLogout,
}: AdminAccountDropdownProps) {
  const [isOpen, setIsOpen] = useState(false);

  const displayName = adminProfile?.full_name || adminEmail.split('@')[0] || 'Administrator';
  const displayUsername = adminProfile?.username ? `@${adminProfile.username}` : adminEmail;

  return (
    <div className="account-wrap" style={{ position: 'relative' }}>
      <div
        className="account-item clearfix"
        role="button"
        tabIndex={0}
        onClick={() => setIsOpen((prev) => !prev)}
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          padding: '4px 8px',
          borderRadius: '6px',
          cursor: 'pointer',
          background: isOpen ? '#f1f5f9' : 'transparent',
          transition: 'background 120ms ease',
        }}
      >
        <UserAvatar
          avatarUrl={adminProfile?.avatar_url}
          name={displayName}
          size={36}
          borderRadius="50%"
          role={adminRole}
          style={{
            border: '1.5px solid #d4e2fa',
          }}
        />
        <div className="content d-none d-sm-block text-start">
          <span
            style={{
              fontSize: '13px',
              fontWeight: 600,
              color: '#1f2937',
              display: 'block',
              lineHeight: 1.2,
              maxWidth: '120px',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {displayName}
          </span>
          <span
            style={{
              fontSize: '10.5px',
              color: '#4272d7',
              fontWeight: 600,
              display: 'block',
              textTransform: 'uppercase',
              letterSpacing: '0.04em',
            }}
          >
            {adminRole}
          </span>
        </div>
        <i
          className="fa-solid fa-chevron-down d-none d-sm-inline-block"
          style={{ fontSize: '10px', color: '#94a3b8', marginLeft: '4px' }}
        ></i>
      </div>

      {isOpen && (
        <div
          style={{
            position: 'absolute',
            right: 0,
            top: '110%',
            width: '220px',
            background: '#ffffff',
            borderRadius: '8px',
            border: '1px solid #e4e7ec',
            boxShadow: '0 10px 25px rgba(0, 0, 0, 0.1)',
            zIndex: 1000,
            overflow: 'hidden',
          }}
        >
          <div style={{ padding: '12px 14px', borderBottom: '1px solid #f1f3f5' }}>
            <div style={{ fontSize: '13px', fontWeight: 700, color: '#1f2937' }}>
              {displayName}
            </div>
            <div style={{ fontSize: '11.5px', color: '#64748b', marginTop: '2px' }}>
              {displayUsername}
            </div>
          </div>
          <div style={{ padding: '6px' }}>
            <a
              href="/@radityarayhannnn"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                padding: '8px 10px',
                fontSize: '12.5px',
                color: '#475569',
                textDecoration: 'none',
                borderRadius: '4px',
              }}
              onMouseEnter={(e) => (e.currentTarget.style.background = '#f8fafc')}
              onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
            >
              <i className="fa-solid fa-user" style={{ width: '14px', color: '#94a3b8' }}></i>
              Lihat Profil Publik
            </a>
          </div>
          {onLogout && (
            <div style={{ padding: '6px', borderTop: '1px solid #f1f3f5' }}>
              <button
                type="button"
                onClick={() => {
                  setIsOpen(false);
                  onLogout();
                }}
                style={{
                  width: '100%',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '10px',
                  padding: '8px 10px',
                  fontSize: '12.5px',
                  color: '#dc3545',
                  background: 'transparent',
                  border: 0,
                  borderRadius: '4px',
                  cursor: 'pointer',
                  textAlign: 'left',
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = '#fef2f2')}
                onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
              >
                <i className="fa-solid fa-arrow-right-from-bracket" style={{ width: '14px' }}></i>
                Keluar dari Akun
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
