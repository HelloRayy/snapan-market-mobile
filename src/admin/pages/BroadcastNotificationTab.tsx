import React, { useState, useEffect } from 'react';
import { adminService, type ProfileRow } from '../services/adminService';
import { supabase } from '@/services/api/supabase';

interface BroadcastNotificationTabProps {
  adminProfile?: ProfileRow | null;
}

export function BroadcastNotificationTab({ adminProfile }: BroadcastNotificationTabProps) {
  // Form State
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [targetType, setTargetType] = useState<'all' | 'specific_role' | 'single_user'>('all');
  const [targetRole, setTargetRole] = useState<'buyer' | 'seller' | 'admin'>('buyer');
  const [targetUsername, setTargetUsername] = useState('');
  const [selectedUser, setSelectedUser] = useState<ProfileRow | null>(null);
  
  // Custom Sound Mock Field
  const [soundChoice, setSoundChoice] = useState<string>('default_snaps');
  const [customSoundUrl, setCustomSoundUrl] = useState<string>('');
  const [isPlayingAudio, setIsPlayingAudio] = useState<boolean>(false);

  // Status & History State
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [isLoadingHistory, setIsLoadingHistory] = useState(false);

  // Search User Dropdown for Single User target
  const [userSuggestions, setUserSuggestions] = useState<ProfileRow[]>([]);
  const [isSearchingUser, setIsSearchingUser] = useState(false);

  const fetchHistory = async () => {
    setIsLoadingHistory(true);
    try {
      const data = await adminService.getBroadcastHistory(10);
      setHistory(data);
    } catch (e: any) {
      console.warn('Gagal memuat riwayat broadcast:', e);
    } finally {
      setIsLoadingHistory(false);
    }
  };

  useEffect(() => {
    fetchHistory();
  }, []);

  // Search single user debounced
  useEffect(() => {
    if (targetType !== 'single_user') return;
    const q = targetUsername.trim();
    if (q.length < 2) {
      setUserSuggestions([]);
      return;
    }

    const timer = setTimeout(async () => {
      setIsSearchingUser(true);
      try {
        const { data } = await supabase
          .from('profiles')
          .select('*')
          .or(`username.ilike.%${q}%,full_name.ilike.%${q}%`)
          .limit(5);
        setUserSuggestions(data || []);
      } catch (err) {
        console.error('Search user error:', err);
      } finally {
        setIsSearchingUser(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [targetUsername, targetType]);

  // Audio preview simulation (synthesizer chime using Web Audio API)
  const handleTestSound = () => {
    if (isPlayingAudio) return;
    setIsPlayingAudio(true);
    try {
      const ctx = new (window.AudioContext || (window as any).webkitAudioContext)();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();

      if (soundChoice === 'chime_bell') {
        osc.frequency.setValueAtTime(880, ctx.currentTime); // A5
        osc.frequency.exponentialRampToValueAtTime(440, ctx.currentTime + 0.3);
      } else if (soundChoice === 'water_drop') {
        osc.frequency.setValueAtTime(1200, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(300, ctx.currentTime + 0.15);
      } else {
        // default_snaps
        osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
        osc.frequency.setValueAtTime(880, ctx.currentTime + 0.1); // A5
      }

      gain.gain.setValueAtTime(0.2, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);

      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start();
      osc.stop(ctx.currentTime + 0.35);

      setTimeout(() => {
        setIsPlayingAudio(false);
      }, 400);
    } catch {
      setIsPlayingAudio(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !message.trim()) {
      setFeedbackMsg({ type: 'error', text: 'Judul dan isi pesan notifikasi wajib diisi.' });
      return;
    }

    if (targetType === 'single_user' && !selectedUser) {
      setFeedbackMsg({ type: 'error', text: 'Pilih pengguna target terlebih dahulu dari saran pencarian.' });
      return;
    }

    setIsSubmitting(true);
    setFeedbackMsg(null);

    try {
      const res = await adminService.sendBroadcastNotification({
        title: title.trim(),
        message: message.trim(),
        targetType,
        targetRole: targetType === 'specific_role' ? targetRole : undefined,
        targetUserId: targetType === 'single_user' ? selectedUser?.id : undefined,
        soundUrl: soundChoice === 'custom' ? customSoundUrl : soundChoice,
        adminId: adminProfile?.id,
      });

      setFeedbackMsg({
        type: 'success',
        text: `Berhasil mengirim notifikasi broadcast ke ${res.successCount} pengguna! Notifikasi langsung muncul di aplikasi secara realtime.`,
      });

      // Reset Form
      setTitle('');
      setMessage('');
      setSelectedUser(null);
      setTargetUsername('');

      fetchHistory();
    } catch (err: any) {
      setFeedbackMsg({
        type: 'error',
        text: err?.message || 'Gagal mengirim broadcast notifikasi. Periksa koneksi atau izin database.',
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="broadcast-tab-wrapper">
      {/* Feedback Alert */}
      {feedbackMsg && (
        <div
          className={`alert ${feedbackMsg.type === 'success' ? 'alert-success' : 'alert-danger'} d-flex align-items-center justify-content-between mb-4`}
          style={{
            padding: '12px 18px',
            borderRadius: '10px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.04)',
            fontSize: '13.5px',
          }}
        >
          <div className="d-flex align-items-center gap-2">
            <i
              className={`fa-solid ${
                feedbackMsg.type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation'
              }`}
            ></i>
            <span>{feedbackMsg.text}</span>
          </div>
          <button
            type="button"
            className="btn-close"
            onClick={() => setFeedbackMsg(null)}
            style={{ fontSize: '11px' }}
          ></button>
        </div>
      )}

      {/* Main Grid: Form Kirim (Left) & Riwayat Log (Right) */}
      <div className="row">
        <div className="col-lg-7">
          <div
            className="au-card shadow-sm mb-4"
            style={{
              borderRadius: '12px',
              padding: '24px',
              background: '#ffffff',
              border: '1px solid #e2e8f0',
            }}
          >
            <div className="d-flex align-items-center justify-content-between mb-4 border-bottom pb-3">
              <div>
                <h4 className="title-2 mb-1" style={{ fontSize: '18px', fontWeight: 700, color: '#0f172a' }}>
                  <i className="fa-solid fa-bullhorn me-2" style={{ color: '#3d38f5' }}></i>
                  Form Broadcast Notifikasi
                </h4>
                <p className="text-muted mb-0" style={{ fontSize: '13px' }}>
                  Kirim pengumuman atau notifikasi instan langsung ke HP seluruh siswa atau target tertentu.
                </p>
              </div>
            </div>

            <form onSubmit={handleSubmit}>
              {/* 1. Target Audiens */}
              <div className="mb-3">
                <label className="form-label fw-bold" style={{ fontSize: '13px', color: '#334155' }}>
                  Target Penerima Notifikasi
                </label>
                <div className="d-flex gap-2">
                  <button
                    type="button"
                    onClick={() => {
                      setTargetType('all');
                      setSelectedUser(null);
                    }}
                    className={`btn btn-sm ${
                      targetType === 'all' ? 'btn-primary' : 'btn-outline-secondary'
                    }`}
                    style={{
                      borderRadius: '8px',
                      padding: '6px 14px',
                      fontSize: '12.5px',
                      fontWeight: 600,
                      backgroundColor: targetType === 'all' ? '#3d38f5' : 'transparent',
                      borderColor: targetType === 'all' ? '#3d38f5' : '#cbd5e1',
                    }}
                  >
                    <i className="fa-solid fa-users me-1.5"></i> Semua Siswa
                  </button>

                  <button
                    type="button"
                    onClick={() => {
                      setTargetType('specific_role');
                      setSelectedUser(null);
                    }}
                    className={`btn btn-sm ${
                      targetType === 'specific_role' ? 'btn-primary' : 'btn-outline-secondary'
                    }`}
                    style={{
                      borderRadius: '8px',
                      padding: '6px 14px',
                      fontSize: '12.5px',
                      fontWeight: 600,
                      backgroundColor: targetType === 'specific_role' ? '#3d38f5' : 'transparent',
                      borderColor: targetType === 'specific_role' ? '#3d38f5' : '#cbd5e1',
                    }}
                  >
                    <i className="fa-solid fa-filter me-1.5"></i> Peran Spesifik
                  </button>

                  <button
                    type="button"
                    onClick={() => setTargetType('single_user')}
                    className={`btn btn-sm ${
                      targetType === 'single_user' ? 'btn-primary' : 'btn-outline-secondary'
                    }`}
                    style={{
                      borderRadius: '8px',
                      padding: '6px 14px',
                      fontSize: '12.5px',
                      fontWeight: 600,
                      backgroundColor: targetType === 'single_user' ? '#3d38f5' : 'transparent',
                      borderColor: targetType === 'single_user' ? '#3d38f5' : '#cbd5e1',
                    }}
                  >
                    <i className="fa-solid fa-user me-1.5"></i> 1 Pengguna
                  </button>
                </div>

                {/* Sub-pilihan jika targetType === 'specific_role' */}
                {targetType === 'specific_role' && (
                  <div className="mt-2 p-2.5 bg-light rounded-3 border" style={{ borderColor: '#e2e8f0' }}>
                    <label className="form-label mb-1" style={{ fontSize: '12px', color: '#64748b' }}>
                      Pilih Role Siswa:
                    </label>
                    <select
                      className="form-select form-select-sm"
                      value={targetRole}
                      onChange={(e) => setTargetRole(e.target.value as any)}
                      style={{ borderRadius: '6px', fontSize: '13px' }}
                    >
                      <option value="buyer">Hanya Pembeli (Buyer / Siswa Reguler)</option>
                      <option value="seller">Hanya Penjual (Seller / Pengusaha Siswa)</option>
                      <option value="admin">Hanya Administrator</option>
                    </select>
                  </div>
                )}

                {/* Sub-pilihan jika targetType === 'single_user' */}
                {targetType === 'single_user' && (
                  <div className="mt-2 p-2.5 bg-light rounded-3 border" style={{ borderColor: '#e2e8f0' }}>
                    <label className="form-label mb-1" style={{ fontSize: '12px', color: '#64748b' }}>
                      Cari Username / Nama Siswa:
                    </label>
                    <input
                      type="text"
                      className="form-control form-control-sm mb-1"
                      placeholder="Ketik min 2 huruf..."
                      value={targetUsername}
                      onChange={(e) => {
                        setTargetUsername(e.target.value);
                        setSelectedUser(null);
                      }}
                      style={{ borderRadius: '6px', fontSize: '13px' }}
                    />
                    {isSearchingUser && (
                      <div className="text-muted small mt-1">Mencari siswa...</div>
                    )}
                    {userSuggestions.length > 0 && !selectedUser && (
                      <div
                        className="list-group shadow-sm mt-1"
                        style={{ maxHeight: '140px', overflowY: 'auto' }}
                      >
                        {userSuggestions.map((u) => (
                          <button
                            key={u.id}
                            type="button"
                            className="list-group-item list-group-item-action py-1.5 px-2 text-start"
                            style={{ fontSize: '12.5px' }}
                            onClick={() => {
                              setSelectedUser(u);
                              setTargetUsername(`@${u.username || u.full_name}`);
                              setUserSuggestions([]);
                            }}
                          >
                            <strong>{u.full_name}</strong> (@{u.username}) - {u.class_group || 'Umum'}
                          </button>
                        ))}
                      </div>
                    )}
                    {selectedUser && (
                      <div className="badge bg-success mt-1 p-1.5 text-wrap">
                        Target terpilih: {selectedUser.full_name} (@{selectedUser.username})
                      </div>
                    )}
                  </div>
                )}
              </div>

              {/* 2. Judul Notifikasi */}
              <div className="mb-3">
                <label className="form-label fw-bold" style={{ fontSize: '13px', color: '#334155' }}>
                  Judul Notifikasi <span className="text-danger">*</span>
                </label>
                <input
                  type="text"
                  className="form-control"
                  placeholder="Contoh: Pemeliharaan Sistem / Promo Kantin Sekolah"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  maxLength={75}
                  required
                  style={{ borderRadius: '8px', fontSize: '13.5px' }}
                />
                <div className="text-end text-muted mt-0.5" style={{ fontSize: '11px' }}>
                  {title.length}/75 karakter
                </div>
              </div>

              {/* 3. Pesan Notifikasi */}
              <div className="mb-3">
                <label className="form-label fw-bold" style={{ fontSize: '13px', color: '#334155' }}>
                  Isi Pesan Notifikasi <span className="text-danger">*</span>
                </label>
                <textarea
                  className="form-control"
                  rows={3}
                  placeholder="Tuliskan pengumuman yang ingin disampaikan ke siswa..."
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  maxLength={280}
                  required
                  style={{ borderRadius: '8px', fontSize: '13.5px', resize: 'vertical' }}
                ></textarea>
                <div className="text-end text-muted mt-0.5" style={{ fontSize: '11px' }}>
                  {message.length}/280 karakter
                </div>
              </div>

              {/* 4. Custom Sound Notif Selection (Mock / Ready for Real App) */}
              <div
                className="mb-4 p-3 rounded-3"
                style={{ background: '#f8fafc', border: '1px dashed #cbd5e1' }}
              >
                <div className="d-flex align-items-center justify-content-between mb-2">
                  <label className="form-label fw-bold mb-0" style={{ fontSize: '13px', color: '#1e293b' }}>
                    <i className="fa-solid fa-volume-high me-1.5 text-primary"></i>
                    Kustomisasi Nada Suara (Custom Sound)
                  </label>
                  <button
                    type="button"
                    onClick={handleTestSound}
                    className="btn btn-sm btn-outline-primary"
                    style={{ borderRadius: '6px', fontSize: '11.5px', padding: '3px 8px' }}
                  >
                    <i className="fa-solid fa-play me-1"></i> Tes Suara
                  </button>
                </div>
                <p className="text-muted mb-2" style={{ fontSize: '12px' }}>
                  Pilih efek nada audio yang akan berdering di smartphone siswa saat pesan ini diterima.
                </p>

                <div className="row g-2">
                  <div className="col-sm-6">
                    <select
                      className="form-select form-select-sm"
                      value={soundChoice}
                      onChange={(e) => setSoundChoice(e.target.value)}
                      style={{ borderRadius: '6px', fontSize: '12.5px' }}
                    >
                      <option value="default_snaps">Snaps Pop (Default Bawaan)</option>
                      <option value="chime_bell">Chime Bell (Resmi / Lembut)</option>
                      <option value="water_drop">Water Drop (Modern Minimalis)</option>
                      <option value="custom">URL Audio Mandiri (Kustom)</option>
                    </select>
                  </div>

                  {soundChoice === 'custom' && (
                    <div className="col-sm-6">
                      <input
                        type="url"
                        className="form-control form-control-sm"
                        placeholder="https://domain.com/sound.mp3"
                        value={customSoundUrl}
                        onChange={(e) => setCustomSoundUrl(e.target.value)}
                        style={{ borderRadius: '6px', fontSize: '12px' }}
                      />
                    </div>
                  )}
                </div>
              </div>

              {/* Submit Button */}
              <div className="d-flex justify-content-end gap-2">
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className="btn btn-primary px-4 py-2"
                  style={{
                    backgroundColor: '#3d38f5',
                    borderColor: '#3d38f5',
                    borderRadius: '8px',
                    fontWeight: 600,
                    fontSize: '13.5px',
                  }}
                >
                  {isSubmitting ? (
                    <>
                      <span className="spinner-border spinner-border-sm me-1.5" role="status"></span>
                      Mengirimkan Broadcast...
                    </>
                  ) : (
                    <>
                      <i className="fa-solid fa-paper-plane me-1.5"></i>
                      Kirim Broadcast Sekarang
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>

        {/* Right Column: Riwayat & Live Preview Simulation */}
        <div className="col-lg-5">
          {/* Live Mobile In-App Notification Preview */}
          <div
            className="au-card shadow-sm mb-4"
            style={{
              borderRadius: '12px',
              padding: '20px',
              background: '#ffffff',
              border: '1px solid #e2e8f0',
            }}
          >
            <h5 className="mb-3" style={{ fontSize: '14.5px', fontWeight: 700, color: '#1e293b' }}>
              <i className="fa-solid fa-mobile-screen-button me-2 text-primary"></i>
              Simulasi Tampilan di Layar Pengguna
            </h5>

            <div
              style={{
                borderRadius: '12px',
                background: '#f8fafc',
                border: '1px solid #e2e8f0',
                padding: '14px',
              }}
            >
              <div
                style={{
                  background: '#ffffff',
                  borderRadius: '10px',
                  padding: '12px 14px',
                  boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
                  border: '1px solid #e2e8f0',
                  display: 'flex',
                  gap: '12px',
                  alignItems: 'flex-start',
                }}
              >
                <div
                  style={{
                    width: '36px',
                    height: '36px',
                    borderRadius: '50%',
                    background: '#eef0ff',
                    color: '#3d38f5',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '15px',
                    flexShrink: 0,
                  }}
                >
                  <i className="fa-solid fa-award"></i>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div className="d-flex justify-content-between align-items-center mb-0.5">
                    <span style={{ fontSize: '13px', fontWeight: 700, color: '#0f172a' }}>
                      {title.trim() || 'Judul Notifikasi Pengumuman'}
                    </span>
                    <span style={{ fontSize: '10.5px', color: '#94a3b8' }}>Baru saja</span>
                  </div>
                  <p
                    style={{
                      fontSize: '12px',
                      color: '#475569',
                      margin: 0,
                      lineHeight: 1.4,
                      wordBreak: 'break-word',
                    }}
                  >
                    {message.trim() || 'Isi teks pesan pengumuman sistem akan ditampilkan dengan jelas di sini.'}
                  </p>
                  <div className="mt-1 d-flex align-items-center gap-1.5" style={{ fontSize: '10px', color: '#64748b' }}>
                    <i className="fa-solid fa-volume-low text-muted"></i>
                    <span>Nada: {soundChoice === 'custom' ? 'Kustom Audio' : soundChoice}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Riwayat Broadcast Terakhir */}
          <div
            className="au-card shadow-sm"
            style={{
              borderRadius: '12px',
              padding: '20px',
              background: '#ffffff',
              border: '1px solid #e2e8f0',
            }}
          >
            <div className="d-flex align-items-center justify-content-between mb-3 border-bottom pb-2">
              <h5 className="mb-0" style={{ fontSize: '14.5px', fontWeight: 700, color: '#1e293b' }}>
                <i className="fa-solid fa-clock-rotate-left me-2 text-secondary"></i>
                Riwayat Pengiriman Sistem
              </h5>
              <button
                type="button"
                onClick={fetchHistory}
                disabled={isLoadingHistory}
                className="btn btn-sm btn-light"
                style={{ fontSize: '11.5px', borderRadius: '6px' }}
              >
                <i className={`fa-solid fa-arrows-rotate ${isLoadingHistory ? 'fa-spin' : ''}`}></i>
              </button>
            </div>

            {isLoadingHistory ? (
              <div className="text-center py-4 text-muted small">Memuat riwayat...</div>
            ) : history.length === 0 ? (
              <div className="text-center py-4 text-muted small">
                Belum ada riwayat broadcast pengumuman.
              </div>
            ) : (
              <div className="broadcast-history-list" style={{ maxHeight: '320px', overflowY: 'auto' }}>
                {history.map((item) => (
                  <div
                    key={item.id}
                    className="p-2.5 mb-2 rounded-2 border"
                    style={{ background: '#fdfdfe', borderColor: '#f1f5f9', fontSize: '12px' }}
                  >
                    <div className="d-flex justify-content-between align-items-center mb-1">
                      <strong style={{ color: '#0f172a' }}>{item.title}</strong>
                      <span className="text-muted" style={{ fontSize: '10.5px' }}>
                        {new Date(item.created_at).toLocaleDateString('id-ID', {
                          day: 'numeric',
                          month: 'short',
                          hour: '2-digit',
                          minute: '2-digit',
                        })}
                      </span>
                    </div>
                    <div className="text-muted text-truncate" style={{ fontSize: '11.5px' }}>
                      {item.message}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
