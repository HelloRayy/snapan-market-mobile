import { useState } from 'react';
import type { ProfileRow } from '../services/adminService';
import { UserAvatar } from './UserAvatar';
import { AdminModalPortal } from './AdminModalPortal';

interface UserDetailModalProps {
  user: ProfileRow | null;
  isOpen: boolean;
  onClose: () => void;
  onToggleVerify: (userId: string, currentStatus: boolean) => Promise<void>;
  onChangeRole: (user: ProfileRow, newRole: 'buyer' | 'seller' | 'admin') => void;
  isUpdating: boolean;
}

export function UserDetailModal({
  user,
  isOpen,
  onClose,
  onToggleVerify,
  onChangeRole,
  isUpdating,
}: UserDetailModalProps) {
  const [copiedId, setCopiedId] = useState(false);

  if (!isOpen || !user) return null;

  const handleCopyId = () => {
    navigator.clipboard.writeText(user.id);
    setCopiedId(true);
    setTimeout(() => setCopiedId(false), 2000);
  };

  return (
    <AdminModalPortal isOpen={isOpen} onClose={onClose}>
      <div
        style={{
          width: '100%',
          maxWidth: '720px',
          background: '#ffffff',
          borderRadius: '10px',
          border: '1px solid #e4e7ec',
          boxShadow: '0 20px 35px rgba(0, 0, 0, 0.15)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '90vh',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header (CoolAdmin Styled) */}
        <div
          style={{
            padding: '18px 24px',
            borderBottom: '1px solid #f1f3f5',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            background: '#ffffff',
          }}
        >
          <div>
            <h3 style={{ margin: 0, fontSize: '16px', fontWeight: 700, color: '#1f2937' }}>
              Inspeksi Profil Siswa
            </h3>
            <p style={{ margin: '2px 0 0', fontSize: '12.5px', color: '#64748b' }}>
              Bergabung sejak{' '}
              {new Date(user.created_at).toLocaleDateString('id-ID', {
                day: 'numeric',
                month: 'long',
                year: 'numeric',
              })}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Tutup modal"
            style={{
              width: '32px',
              height: '32px',
              borderRadius: '6px',
              background: '#f8fafc',
              border: '1px solid #e4e7ec',
              color: '#64748b',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              fontSize: '14px',
            }}
          >
            <i className="fa-solid fa-xmark"></i>
          </button>
        </div>

        {/* Modal Body */}
        <div
          style={{
            padding: '24px',
            overflowY: 'auto',
            display: 'flex',
            flexDirection: 'column',
            gap: '20px',
          }}
        >
          {/* Hero Profile Card */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '16px',
              padding: '16px',
              borderRadius: '8px',
              background: '#f8fafc',
              border: '1px solid #e4e7ec',
            }}
          >
            <UserAvatar
              avatarUrl={user.avatar_url}
              name={user.full_name}
              size={56}
              borderRadius="10px"
              role={user.role}
              style={{
                fontSize: '22px',
                border: '1px solid rgba(66, 114, 215, 0.2)',
              }}
            />

            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap' }}>
                <h4
                  style={{
                    margin: 0,
                    fontSize: '15.5px',
                    fontWeight: 700,
                    color: '#1f2937',
                    letterSpacing: '-0.01em',
                  }}
                >
                  {user.full_name || 'Siswa SMKN 8 Semarang'}
                </h4>
                {user.is_verified && (
                  <span
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '4px',
                      color: '#4272d7',
                      fontSize: '13px',
                    }}
                    title="Akun Siswa Resmi"
                  >
                    <i className="fa-solid fa-circle-check"></i>
                  </span>
                )}
              </div>
              <p style={{ margin: '2px 0 8px', fontSize: '12.5px', color: '#64748b' }}>
                @{user.username || 'username'}
              </p>

              <div style={{ display: 'flex', gap: '8px', alignItems: 'center', flexWrap: 'wrap' }}>
                <span
                  className={`role ${user.role === 'admin' ? 'admin' : 'user'}`}
                  style={{
                    display: 'inline-block',
                    padding: '2px 10px',
                    borderRadius: '4px',
                    fontSize: '11px',
                    fontWeight: 600,
                    textTransform: 'uppercase',
                  }}
                >
                  {user.role}
                </span>

                <span
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '4px',
                    padding: '2px 8px',
                    borderRadius: '4px',
                    fontSize: '11px',
                    fontWeight: 600,
                    background: user.is_verified ? '#e0f3f1' : '#fff1e6',
                    color: user.is_verified ? '#11998e' : '#f97316',
                    border: `1px solid ${user.is_verified ? '#a7f3d0' : '#fed7aa'}`,
                  }}
                >
                  <i
                    className={`fa-solid ${user.is_verified ? 'fa-circle-check' : 'fa-circle-exclamation'}`}
                    style={{ fontSize: '10px' }}
                  ></i>
                  {user.is_verified ? 'Terverifikasi' : 'Belum Verifikasi'}
                </span>
              </div>
            </div>
          </div>

          {/* Academic & Platform Information */}
          <div>
            <div
              style={{
                fontSize: '11px',
                fontWeight: 700,
                textTransform: 'uppercase',
                letterSpacing: '0.06em',
                color: '#64748b',
                marginBottom: '8px',
              }}
            >
              Informasi Akademik & Kejuruan
            </div>

            <div
              style={{
                background: '#ffffff',
                border: '1px solid #e4e7ec',
                borderRadius: '8px',
                overflow: 'hidden',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 16px',
                  borderBottom: '1px solid #f1f3f5',
                  fontSize: '13px',
                }}
              >
                <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <i className="fa-solid fa-graduation-cap" style={{ width: '16px', color: '#94a3b8' }}></i>
                  Kelas & Jurusan
                </span>
                <span style={{ fontWeight: 600, color: '#1f2937' }}>
                  {user.class_group || 'Umum'}
                </span>
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 16px',
                  borderBottom: '1px solid #f1f3f5',
                  fontSize: '13px',
                }}
              >
                <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <i className="fa-solid fa-bag-shopping" style={{ width: '16px', color: '#94a3b8' }}></i>
                  Transaksi Terverifikasi
                </span>
                <span style={{ fontWeight: 600, color: '#1f2937', fontVariantNumeric: 'tabular-nums' }}>
                  {user.verified_sales_count || 0} transaksi
                </span>
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 16px',
                  borderBottom: '1px solid #f1f3f5',
                  fontSize: '13px',
                }}
              >
                <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <i className="fa-solid fa-chart-line" style={{ width: '16px', color: '#94a3b8' }}></i>
                  Total Perputaran COD
                </span>
                <span style={{ fontWeight: 700, color: '#4272d7', fontVariantNumeric: 'tabular-nums' }}>
                  Rp {(user.total_revenue_idr || 0).toLocaleString('id-ID')}
                </span>
              </div>

              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  padding: '12px 16px',
                  fontSize: '13px',
                }}
              >
                <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <i className="fa-solid fa-fingerprint" style={{ width: '16px', color: '#94a3b8' }}></i>
                  User UUID
                </span>
                <button
                  type="button"
                  onClick={handleCopyId}
                  style={{
                    background: '#f8fafc',
                    border: '1px solid #e4e7ec',
                    borderRadius: '4px',
                    padding: '3px 8px',
                    fontFamily: 'monospace',
                    fontSize: '11px',
                    color: '#4272d7',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                  }}
                >
                  <span>{user.id.slice(0, 10)}...</span>
                  <span style={{ fontSize: '10px', color: '#64748b' }}>
                    {copiedId ? 'Disalin!' : 'Salin'}
                  </span>
                </button>
              </div>
            </div>
          </div>

          {/* RBAC Role Selector */}
          <div>
            <div
              style={{
                fontSize: '11px',
                fontWeight: 700,
                textTransform: 'uppercase',
                letterSpacing: '0.06em',
                color: '#64748b',
                marginBottom: '8px',
              }}
            >
              Otorisasi Hak Akses (RBAC)
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '8px' }}>
              {(['buyer', 'seller', 'admin'] as const).map((r) => {
                const isSelected = user.role === r;
                return (
                  <button
                    key={r}
                    type="button"
                    disabled={isUpdating}
                    onClick={() => onChangeRole(user, r)}
                    style={{
                      padding: '10px 8px',
                      borderRadius: '6px',
                      fontSize: '12.5px',
                      fontWeight: isSelected ? 700 : 500,
                      textAlign: 'center',
                      cursor: 'pointer',
                      transition: 'all 120ms ease',
                      border: isSelected ? '1.5px solid #4272d7' : '1px solid #e4e7ec',
                      background: isSelected ? '#eaf0fc' : '#ffffff',
                      color: isSelected ? '#4272d7' : '#475569',
                    }}
                  >
                    {r === 'buyer' ? 'Siswa (Buyer)' : r === 'seller' ? 'Penjual (Seller)' : 'Staff Admin'}
                  </button>
                );
              })}
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div
          style={{
            padding: '16px 24px',
            borderTop: '1px solid #f1f3f5',
            background: '#f8fafc',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
          }}
        >
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={onClose}
            style={{
              height: '38px',
              padding: '0 16px',
              fontSize: '13px',
              fontWeight: 500,
              background: '#ffffff',
              border: '1px solid #e4e7ec',
              color: '#475569',
              borderRadius: '6px',
            }}
          >
            Tutup
          </button>

          <button
            type="button"
            disabled={isUpdating}
            onClick={() => onToggleVerify(user.id, user.is_verified)}
            style={{
              height: '38px',
              padding: '0 18px',
              fontSize: '13px',
              fontWeight: 600,
              borderRadius: '6px',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer',
              border: user.is_verified ? '1px solid #fed7aa' : '1px solid #4272d7',
              background: user.is_verified ? '#fff1e6' : '#4272d7',
              color: user.is_verified ? '#c2410c' : '#ffffff',
              boxShadow: user.is_verified ? 'none' : '0 2px 6px rgba(66, 114, 215, 0.35)',
            }}
          >
            <i
              className={`fa-solid ${
                isUpdating ? 'fa-arrows-rotate fa-spin' : user.is_verified ? 'fa-circle-xmark' : 'fa-circle-check'
              }`}
            ></i>
            <span>
              {isUpdating
                ? 'Memproses...'
                : user.is_verified
                ? 'Cabut Verifikasi'
                : 'Verifikasi Siswa'}
            </span>
          </button>
        </div>
      </div>
    </AdminModalPortal>
  );
}
