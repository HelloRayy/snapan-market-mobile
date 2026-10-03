import { useState } from 'react';
import type { ProfileRow } from '@/admin/services/adminService';
import { signOut } from '@/services/api/authService';

interface AccountSuspendedScreenProps {
  profile: ProfileRow;
  onLoggedOut?: () => void;
}

export function AccountSuspendedScreen({ profile, onLoggedOut }: AccountSuspendedScreenProps) {
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  const handleSignOut = async () => {
    setIsLoggingOut(true);
    try {
      await signOut();
      if (onLoggedOut) {
        onLoggedOut();
      } else {
        window.location.reload();
      }
    } catch (e) {
      console.error('Gagal sign out:', e);
      window.location.reload();
    }
  };

  const isPermanent = !profile.suspended_until;
  const untilDate = profile.suspended_until ? new Date(profile.suspended_until) : null;
  const formattedUntil = untilDate
    ? untilDate.toLocaleDateString('id-ID', {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      })
    : null;

  return (
    <div
      style={{
        minHeight: '100vh',
        width: '100%',
        background: '#f8fafc',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px 16px',
        boxSizing: 'border-box',
        fontFamily: 'inherit',
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: '480px',
          background: '#ffffff',
          borderRadius: '16px',
          border: '1px solid #fee2e2',
          boxShadow: '0 20px 35px -10px rgba(220, 38, 38, 0.12)',
          overflow: 'hidden',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        {/* Top Banner Graphic */}
        <div
          style={{
            background: 'linear-gradient(135deg, #ef4444 0%, #b91c1c 100%)',
            padding: '32px 24px 28px',
            textAlign: 'center',
            color: '#ffffff',
            position: 'relative',
          }}
        >
          <div
            style={{
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              background: 'rgba(255, 255, 255, 0.2)',
              backdropFilter: 'blur(8px)',
              margin: '0 auto 16px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '26px',
              border: '2px solid rgba(255, 255, 255, 0.35)',
            }}
          >
            <i className="fa-solid fa-lock"></i>
          </div>
          <h1 style={{ margin: 0, fontSize: '20px', fontWeight: 800, letterSpacing: '-0.02em' }}>
            Akses Akun Ditangguhkan
          </h1>
          <p style={{ margin: '6px 0 0', fontSize: '13px', opacity: 0.9 }}>
            Akun Anda sementara dinonaktifkan oleh administrator sekolah
          </p>
        </div>

        {/* Content Body */}
        <div style={{ padding: '24px' }}>
          {/* User Identifier Card */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
              padding: '12px 14px',
              background: '#f8fafc',
              border: '1px solid #e2e8f0',
              borderRadius: '10px',
              marginBottom: '20px',
            }}
          >
            {profile.avatar_url ? (
              <img
                src={profile.avatar_url}
                alt={profile.full_name || 'Profil Siswa'}
                style={{ width: '42px', height: '42px', borderRadius: '50%', objectFit: 'cover' }}
              />
            ) : (
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '50%',
                  background: '#e2e8f0',
                  color: '#64748b',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '16px',
                  fontWeight: 700,
                }}
              >
                {(profile.full_name || 'U').charAt(0).toUpperCase()}
              </div>
            )}
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontWeight: 700, fontSize: '14px', color: '#1e293b' }}>
                {profile.full_name || 'Siswa SMKN 8'}
              </div>
              <div style={{ fontSize: '12px', color: '#64748b' }}>
                @{profile.username || 'user'} • {profile.class_group || 'SMKN 8 Semarang'}
              </div>
            </div>
            <span
              style={{
                fontSize: '11px',
                fontWeight: 700,
                padding: '3px 8px',
                borderRadius: '6px',
                background: '#fee2e2',
                color: '#dc2626',
              }}
            >
              SUSPENDED
            </span>
          </div>

          {/* Alasan Penangguhan */}
          <div
            style={{
              background: '#fef2f2',
              border: '1px solid #fecdd3',
              borderRadius: '10px',
              padding: '14px 16px',
              marginBottom: '16px',
            }}
          >
            <div
              style={{
                fontSize: '11.5px',
                fontWeight: 700,
                textTransform: 'uppercase',
                letterSpacing: '0.05em',
                color: '#991b1b',
                marginBottom: '6px',
                display: 'flex',
                alignItems: 'center',
                gap: '6px',
              }}
            >
              <i className="fa-solid fa-triangle-exclamation"></i>
              Alasan Pelanggaran
            </div>
            <p
              style={{
                margin: 0,
                fontSize: '13.5px',
                color: '#7f1d1d',
                lineHeight: 1.5,
                fontWeight: 500,
              }}
            >
              {profile.suspend_reason || 'Pelanggaran terhadap panduan etika dan tata tertib transaksi SMKN 8 Semarang.'}
            </p>
          </div>

          {/* Masa Penangguhan */}
          <div
            style={{
              background: '#ffffff',
              border: '1px solid #e2e8f0',
              borderRadius: '10px',
              padding: '14px 16px',
              marginBottom: '20px',
              display: 'flex',
              alignItems: 'flex-start',
              gap: '12px',
            }}
          >
            <div
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '8px',
                background: '#f1f5f9',
                color: '#475569',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '15px',
                flexShrink: 0,
              }}
            >
              <i className="fa-regular fa-clock"></i>
            </div>
            <div>
              <div style={{ fontSize: '12px', fontWeight: 600, color: '#64748b' }}>
                Masa Berlaku Penangguhan
              </div>
              <div style={{ fontSize: '13.5px', fontWeight: 700, color: '#1e293b', marginTop: '2px' }}>
                {isPermanent ? (
                  <span style={{ color: '#dc2626' }}>Permanen (Tanpa Batas Waktu)</span>
                ) : (
                  <span>Sampai dengan {formattedUntil} WIB</span>
                )}
              </div>
              <p style={{ margin: '4px 0 0', fontSize: '11.5px', color: '#94a3b8' }}>
                {isPermanent
                  ? 'Silakan temui guru pembimbing atau administrator IT sekolah untuk proses banding.'
                  : 'Akses akun Anda akan dibuka kembali secara otomatis setelah masa penangguhan berakhir.'}
              </p>
            </div>
          </div>

          {/* Action Buttons */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <a
              href="https://wa.me/6281234567890?text=Halo%20Admin%20Snapan%20Market,%20saya%20ingin%20mengajukan%20pertanyaan%20mengenai%20status%20penangguhan%20akun%20saya"
              target="_blank"
              rel="noopener noreferrer"
              style={{
                width: '100%',
                height: '42px',
                borderRadius: '8px',
                background: '#25d366',
                color: '#ffffff',
                textDecoration: 'none',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                fontSize: '13.5px',
                fontWeight: 600,
                boxShadow: '0 2px 8px rgba(37, 211, 102, 0.3)',
                boxSizing: 'border-box',
              }}
            >
              <i className="fa-brands fa-whatsapp" style={{ fontSize: '17px' }}></i>
              <span>Hubungi Pengurus / Admin Sekolah</span>
            </a>

            <button
              type="button"
              onClick={handleSignOut}
              disabled={isLoggingOut}
              style={{
                width: '100%',
                height: '40px',
                borderRadius: '8px',
                background: '#ffffff',
                border: '1px solid #cbd5e1',
                color: '#475569',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: '8px',
                fontSize: '13px',
                fontWeight: 600,
                cursor: isLoggingOut ? 'not-allowed' : 'pointer',
              }}
            >
              {isLoggingOut ? (
                <>
                  <i className="fa-solid fa-spinner fa-spin"></i>
                  <span>Keluar...</span>
                </>
              ) : (
                <>
                  <i className="fa-solid fa-arrow-right-from-bracket"></i>
                  <span>Keluar dari Akun (Sign Out)</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
