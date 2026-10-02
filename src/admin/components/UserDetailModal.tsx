import { useState } from 'react';
import type { ProfileRow } from '../services/adminService';
import { UserAvatar } from './UserAvatar';
import { AdminModalPortal } from './AdminModalPortal';
import { RoleSelectDropdown, type UserRole } from './RoleSelectDropdown';

interface UserDetailModalProps {
  user: ProfileRow | null;
  isOpen: boolean;
  onClose: () => void;
  onToggleVerify: (userId: string, currentStatus: boolean) => Promise<void>;
  onChangeRole: (user: ProfileRow, newRole: UserRole) => void;
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
          maxWidth: '820px',
          background: '#ffffff',
          borderRadius: '12px',
          border: '1px solid #e4e7ec',
          boxShadow: '0 25px 45px rgba(0, 0, 0, 0.16)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
          maxHeight: '90vh',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div
          style={{
            padding: '16px 24px',
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
            <p style={{ margin: '2px 0 0', fontSize: '12px', color: '#64748b' }}>
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

        {/* Modal Body - 2 Columns Layout */}
        <div
          style={{
            padding: '22px 24px',
            overflowY: 'auto',
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
            gap: '20px',
            alignItems: 'start',
          }}
        >
          {/* Kolom 1 (Kiri): Profil & Data Akademik */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {/* Hero Profile Card */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '14px',
                padding: '14px 16px',
                borderRadius: '8px',
                background: '#f8fafc',
                border: '1px solid #e4e7ec',
              }}
            >
              <UserAvatar
                avatarUrl={user.avatar_url}
                name={user.full_name}
                size={54}
                borderRadius="10px"
                role={user.role}
                style={{
                  fontSize: '20px',
                  border: '1px solid rgba(66, 114, 215, 0.2)',
                }}
              />

              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', flexWrap: 'wrap' }}>
                  <h4
                    style={{
                      margin: 0,
                      fontSize: '15px',
                      fontWeight: 700,
                      color: '#1f2937',
                    }}
                  >
                    {user.full_name || 'Siswa SMKN 8'}
                  </h4>
                  {user.is_verified && (
                    <span style={{ color: '#4272d7', fontSize: '13px' }} title="Akun Resmi">
                      <i className="fa-solid fa-circle-check"></i>
                    </span>
                  )}
                </div>
                <p style={{ margin: '2px 0 6px', fontSize: '12px', color: '#64748b' }}>
                  @{user.username || 'username'}
                </p>

                <div style={{ display: 'flex', gap: '6px', alignItems: 'center', flexWrap: 'wrap' }}>
                  <span
                    style={{
                      display: 'inline-block',
                      padding: '1px 8px',
                      borderRadius: '4px',
                      fontSize: '10.5px',
                      fontWeight: 700,
                      textTransform: 'uppercase',
                      background: user.role === 'admin' ? '#eff6ff' : '#f1f5f9',
                      color: user.role === 'admin' ? '#2563eb' : '#475569',
                      border: `1px solid ${user.role === 'admin' ? '#bfdbfe' : '#e2e8f0'}`,
                    }}
                  >
                    {user.role}
                  </span>

                  <span
                    style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '4px',
                      padding: '1px 8px',
                      borderRadius: '4px',
                      fontSize: '10.5px',
                      fontWeight: 600,
                      background: user.is_verified ? '#ecfdf5' : '#fff7ed',
                      color: user.is_verified ? '#059669' : '#ea580c',
                      border: `1px solid ${user.is_verified ? '#a7f3d0' : '#fed7aa'}`,
                    }}
                  >
                    <i
                      className={`fa-solid ${user.is_verified ? 'fa-circle-check' : 'fa-circle-exclamation'}`}
                      style={{ fontSize: '9px' }}
                    ></i>
                    {user.is_verified ? 'Terverifikasi' : 'Belum Verifikasi'}
                  </span>
                </div>
              </div>
            </div>

            {/* Informasi Akademik Card */}
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
                    padding: '10px 14px',
                    borderBottom: '1px solid #f1f3f5',
                    fontSize: '12.5px',
                  }}
                >
                  <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <i className="fa-solid fa-graduation-cap" style={{ width: '14px', color: '#94a3b8' }}></i>
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
                    padding: '10px 14px',
                    borderBottom: '1px solid #f1f3f5',
                    fontSize: '12.5px',
                  }}
                >
                  <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <i className="fa-solid fa-bag-shopping" style={{ width: '14px', color: '#94a3b8' }}></i>
                    Transaksi COD
                  </span>
                  <span style={{ fontWeight: 600, color: '#1f2937', fontVariantNumeric: 'tabular-nums' }}>
                    {user.verified_sales_count || 0} order
                  </span>
                </div>

                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '10px 14px',
                    borderBottom: '1px solid #f1f3f5',
                    fontSize: '12.5px',
                  }}
                >
                  <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <i className="fa-solid fa-chart-line" style={{ width: '14px', color: '#94a3b8' }}></i>
                    Total Perputaran
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
                    padding: '10px 14px',
                    fontSize: '12.5px',
                  }}
                >
                  <span style={{ color: '#64748b', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <i className="fa-solid fa-fingerprint" style={{ width: '14px', color: '#94a3b8' }}></i>
                    User UUID
                  </span>
                  <button
                    type="button"
                    onClick={handleCopyId}
                    style={{
                      background: '#f8fafc',
                      border: '1px solid #e4e7ec',
                      borderRadius: '4px',
                      padding: '2px 8px',
                      fontFamily: 'monospace',
                      fontSize: '11px',
                      color: '#4272d7',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '5px',
                    }}
                  >
                    <span>{user.id.slice(0, 8)}...</span>
                    <span style={{ fontSize: '10px', color: '#64748b' }}>
                      {copiedId ? 'Disalin' : 'Salin'}
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Kolom 2 (Kanan): Otorisasi & Kontrol Akses */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {/* Otorisasi Hak Akses (Dropdown Input) */}
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

              <RoleSelectDropdown
                currentRole={user.role as UserRole}
                onChangeRole={(newRole) => onChangeRole(user, newRole)}
                disabled={isUpdating}
              />

              <p style={{ margin: '6px 0 0', fontSize: '11px', color: '#94a3b8' }}>
                Perubahan hak akses diterapkan langsung ke baris database akun.
              </p>
            </div>

            {/* Status Verifikasi Resmi Card */}
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
                Tindakan Status Verifikasi
              </div>

              <div
                style={{
                  padding: '14px 16px',
                  background: user.is_verified ? '#f0fdf4' : '#fafaf9',
                  border: user.is_verified ? '1px solid #bbf7d0' : '1px solid #e7e5e4',
                  borderRadius: '8px',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '10px',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <i
                    className={`fa-solid ${
                      user.is_verified ? 'fa-circle-check' : 'fa-circle-question'
                    }`}
                    style={{
                      color: user.is_verified ? '#16a34a' : '#78716c',
                      fontSize: '15px',
                    }}
                  ></i>
                  <span
                    style={{
                      fontSize: '13px',
                      fontWeight: 700,
                      color: user.is_verified ? '#15803d' : '#44403c',
                    }}
                  >
                    {user.is_verified ? 'Lencana Resmi Aktif' : 'Status Belum Terverifikasi'}
                  </span>
                </div>

                <p
                  style={{
                    margin: 0,
                    fontSize: '11.5px',
                    lineHeight: 1.45,
                    color: user.is_verified ? '#166534' : '#78716c',
                  }}
                >
                  {user.is_verified
                    ? 'Akun telah divalidasi sebagai siswa/staff resmi SMKN 8 Semarang dengan reputasi terpercaya.'
                    : 'Berikan lencana centang verifikasi setelah memeriksa identitas dan NIS/NISN siswa.'}
                </p>

                <button
                  type="button"
                  disabled={isUpdating}
                  onClick={() => onToggleVerify(user.id, user.is_verified)}
                  style={{
                    width: '100%',
                    height: '36px',
                    marginTop: '4px',
                    padding: '0 14px',
                    borderRadius: '6px',
                    fontSize: '12.5px',
                    fontWeight: 600,
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    gap: '7px',
                    cursor: isUpdating ? 'not-allowed' : 'pointer',
                    border: user.is_verified ? '1px solid #fca5a5' : '1px solid #4272d7',
                    background: user.is_verified ? '#fef2f2' : '#4272d7',
                    color: user.is_verified ? '#dc2626' : '#ffffff',
                    boxShadow: user.is_verified ? 'none' : '0 2px 6px rgba(66, 114, 215, 0.28)',
                    transition: 'all 120ms ease',
                  }}
                >
                  <i
                    className={`fa-solid ${
                      isUpdating
                        ? 'fa-arrows-rotate fa-spin'
                        : user.is_verified
                        ? 'fa-ban'
                        : 'fa-check'
                    }`}
                  ></i>
                  <span>
                    {isUpdating
                      ? 'Memproses...'
                      : user.is_verified
                      ? 'Cabut Verifikasi Akun'
                      : 'Verifikasi Akun Sekarang'}
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Modal Footer */}
        <div
          style={{
            padding: '12px 24px',
            borderTop: '1px solid #f1f3f5',
            background: '#f8fafc',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-end',
          }}
        >
          <button
            type="button"
            onClick={onClose}
            style={{
              height: '36px',
              padding: '0 18px',
              fontSize: '13px',
              fontWeight: 600,
              background: '#ffffff',
              border: '1px solid #e4e7ec',
              color: '#475569',
              borderRadius: '6px',
              cursor: 'pointer',
            }}
          >
            Selesai
          </button>
        </div>
      </div>
    </AdminModalPortal>
  );
}
