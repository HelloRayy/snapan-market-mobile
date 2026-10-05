import { useState, useEffect, useMemo, useCallback } from 'react';
import {
  adminService,
  type DeviceRecordRow,
  type DeviceSecurityData,
} from '../services/adminService';
import { AdminModalPortal } from '../components/AdminModalPortal';
import { AdminTooltip } from '../components/AdminTooltip';

interface DeviceSecurityTabProps {
  isActive?: boolean;
}

export function DeviceSecurityTab({ isActive = true }: DeviceSecurityTabProps) {
  const [data, setData] = useState<DeviceSecurityData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [search, setSearch] = useState('');
  const [filterType, setFilterType] = useState<'all' | 'whitelisted' | 'blocked' | 'exceeded'>('all');
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Settings State
  const [isEnabled, setIsEnabled] = useState(true);
  const [maxAccounts, setMaxAccounts] = useState(3);
  const [isSavingSettings, setIsSavingSettings] = useState(false);

  // Action Modals State
  const [resetTarget, setResetTarget] = useState<DeviceRecordRow | null>(null);
  const [isResetting, setIsResetting] = useState(false);
  const [actionLoadingId, setActionLoadingId] = useState<string | null>(null);

  // Copy Feedback
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const showFeedback = (type: 'success' | 'error', text: string) => {
    setFeedbackMsg({ type, text });
    setTimeout(() => setFeedbackMsg(null), 4000);
  };

  const loadData = useCallback(async (isSilent = false) => {
    if (!isSilent) setIsLoading(true);
    else setIsRefreshing(true);

    try {
      const res = await adminService.getDeviceSecurityData();
      setData(res);
      setIsEnabled(res.settings.enabled);
      setMaxAccounts(res.settings.max_accounts);
    } catch (e: any) {
      showFeedback('error', `Gagal memuat data keamanan perangkat: ${e?.message || e}`);
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    if (isActive) {
      loadData();
    }
  }, [isActive, loadData]);

  // Handler: Simpan Konfigurasi Global
  const handleSaveSettings = async () => {
    setIsSavingSettings(true);
    try {
      await adminService.updateDeviceSecuritySettings(isEnabled, maxAccounts);
      showFeedback('success', 'Pengaturan batas pendaftaran perangkat berhasil disimpan.');
      await loadData(true);
    } catch (e: any) {
      showFeedback('error', e?.message || 'Gagal menyimpan pengaturan.');
    } finally {
      setIsSavingSettings(false);
    }
  };

  // Handler: Toggle Whitelist
  const handleToggleWhitelist = async (device: DeviceRecordRow) => {
    setActionLoadingId(device.device_id);
    const newStatus = !device.is_whitelisted;
    try {
      await adminService.toggleDeviceWhitelist(device.device_id, newStatus);
      showFeedback(
        'success',
        newStatus
          ? `Perangkat "${device.device_model}" ditambahkan ke Whitelist (Bebas Kuota).`
          : `Perangkat "${device.device_model}" dihapus dari Whitelist.`
      );
      await loadData(true);
    } catch (e: any) {
      showFeedback('error', e?.message || 'Gagal mengubah status whitelist.');
    } finally {
      setActionLoadingId(null);
    }
  };

  // Handler: Toggle Blokir
  const handleToggleBlock = async (device: DeviceRecordRow) => {
    setActionLoadingId(device.device_id);
    const newStatus = !device.is_blocked;
    try {
      await adminService.toggleDeviceBlock(device.device_id, newStatus);
      showFeedback(
        'success',
        newStatus
          ? `Perangkat "${device.device_model}" berhasil diblokir dari pendaftaran.`
          : `Blokir perangkat "${device.device_model}" telah dibuka.`
      );
      await loadData(true);
    } catch (e: any) {
      showFeedback('error', e?.message || 'Gagal mengubah status blokir.');
    } finally {
      setActionLoadingId(null);
    }
  };

  // Handler: Konfirmasi Reset Kuota
  const handleConfirmReset = async () => {
    if (!resetTarget) return;
    setIsResetting(true);
    try {
      await adminService.resetDeviceQuota(resetTarget.device_id);
      showFeedback(
        'success',
        `Kuota perangkat "${resetTarget.device_model}" berhasil di-reset ke 0.`
      );
      setResetTarget(null);
      await loadData(true);
    } catch (e: any) {
      showFeedback('error', e?.message || 'Gagal mereset kuota perangkat.');
    } finally {
      setIsResetting(false);
    }
  };

  // Salin ID Perangkat
  const handleCopyDeviceId = (deviceId: string) => {
    navigator.clipboard.writeText(deviceId);
    setCopiedId(deviceId);
    setTimeout(() => setCopiedId(null), 2000);
  };

  // Filter Data
  const filteredDevices = useMemo(() => {
    if (!data?.devices) return [];
    return data.devices.filter((item) => {
      const q = search.trim().toLowerCase();
      const matchSearch =
        !q ||
        item.device_model.toLowerCase().includes(q) ||
        item.device_id.toLowerCase().includes(q) ||
        item.accounts.some((acc) => acc.toLowerCase().includes(q));

      if (!matchSearch) return false;

      if (filterType === 'whitelisted') return item.is_whitelisted;
      if (filterType === 'blocked') return item.is_blocked;
      if (filterType === 'exceeded') return item.account_count >= (data.settings.max_accounts || 3);

      return true;
    });
  }, [data, search, filterType]);

  const hasSettingsChanged =
    data &&
    (isEnabled !== data.settings.enabled || maxAccounts !== data.settings.max_accounts);

  return (
    <div className="tab-pane fade show active" style={{ minHeight: '80vh' }}>
      {/* 1. Header Page Title & Refresh */}
      <div className="row mb-4">
        <div className="col-12 d-flex flex-wrap align-items-center justify-content-between gap-3">
          <div>
            <h2
              style={{
                fontSize: '22px',
                fontWeight: 700,
                color: '#1e293b',
                margin: 0,
                letterSpacing: '-0.02em',
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
              }}
            >
              <i className="fa-solid fa-mobile-screen" style={{ color: '#4272d7' }}></i>
              Keamanan Perangkat (Batas Akun per HP)
            </h2>
            <p style={{ fontSize: '13px', color: '#64748b', margin: '4px 0 0 0' }}>
              Cegah pembuatan akun tuyul dengan pembatasan 1 HP fisik maksimal 3 akun, atur kuota,
              whitelist perangkat khusus (OSIS/Lab), atau matikan sementara.
            </p>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <button
              type="button"
              className="btn btn-outline-secondary"
              onClick={() => loadData(true)}
              disabled={isRefreshing}
              style={{
                height: '36px',
                padding: '0 14px',
                fontSize: '13px',
                fontWeight: 500,
                display: 'inline-flex',
                alignItems: 'center',
                gap: '8px',
                borderRadius: '6px',
                borderColor: '#e2e8f0',
                background: '#ffffff',
                color: '#475569',
              }}
            >
              <i className={`fa-solid fa-rotate-right ${isRefreshing ? 'fa-spin' : ''}`}></i>
              <span>{isRefreshing ? 'Memperbarui...' : 'Segarkan Data'}</span>
            </button>
          </div>
        </div>
      </div>

      {/* Feedback Alert Banner */}
      {feedbackMsg && (
        <div
          style={{
            marginBottom: '20px',
            padding: '12px 18px',
            borderRadius: '8px',
            background: feedbackMsg.type === 'success' ? '#e0f3f1' : '#fce7f3',
            color: feedbackMsg.type === 'success' ? '#0f766e' : '#be185d',
            fontSize: '13px',
            fontWeight: 500,
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
          }}
        >
          <i
            className={`fa-solid ${
              feedbackMsg.type === 'success' ? 'fa-circle-check' : 'fa-triangle-exclamation'
            }`}
          ></i>
          <span style={{ flex: 1 }}>{feedbackMsg.text}</span>
          <button
            type="button"
            onClick={() => setFeedbackMsg(null)}
            style={{
              background: 'transparent',
              border: 'none',
              color: 'inherit',
              cursor: 'pointer',
              opacity: 0.7,
            }}
          >
            <i className="fa-solid fa-xmark"></i>
          </button>
        </div>
      )}

      {/* 2. Top Controls & Settings Cards */}
      <div className="row mb-4">
        {/* Card 1: Saklar Global Fitur */}
        <div className="col-12 col-md-6 col-xl-4 mb-3">
          <div
            className="m-card"
            style={{
              padding: '20px',
              height: '100%',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
            }}
          >
            <div>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  marginBottom: '10px',
                }}
              >
                <span style={{ fontSize: '13px', fontWeight: 600, color: '#64748b' }}>
                  Saklar Global Pembatasan
                </span>
                <span
                  style={{
                    fontSize: '11px',
                    fontWeight: 700,
                    padding: '3px 8px',
                    borderRadius: '20px',
                    background: isEnabled ? '#dcfce7' : '#fef9c3',
                    color: isEnabled ? '#15803d' : '#854d0e',
                  }}
                >
                  {isEnabled ? '● AKTIF' : '○ DINONAKTIFKAN'}
                </span>
              </div>
              <p style={{ fontSize: '12px', color: '#64748b', lineHeight: 1.5, margin: 0 }}>
                Jika dimatikan, seluruh siswa dapat mendaftar tanpa batas kuota HP (berguna saat hari
                pertama MPLS/orientasi siswa baru).
              </p>
            </div>

            <div
              style={{
                marginTop: '16px',
                paddingTop: '14px',
                borderTop: '1px solid #f1f5f9',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <label
                style={{
                  fontSize: '13px',
                  fontWeight: 600,
                  color: '#1e293b',
                  margin: 0,
                  cursor: 'pointer',
                }}
                htmlFor="global-limit-switch"
              >
                Proteksi 1 HP Dibatasi
              </label>
              <div className="form-check form-switch" style={{ margin: 0, paddingLeft: '2.8em' }}>
                <input
                  id="global-limit-switch"
                  className="form-check-input"
                  type="checkbox"
                  role="switch"
                  checked={isEnabled}
                  onChange={(e) => setIsEnabled(e.target.checked)}
                  style={{ cursor: 'pointer', width: '2.5em', height: '1.25em' }}
                />
              </div>
            </div>
          </div>
        </div>

        {/* Card 2: Batas Kuota per Perangkat */}
        <div className="col-12 col-md-6 col-xl-4 mb-3">
          <div
            className="m-card"
            style={{
              padding: '20px',
              height: '100%',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
            }}
          >
            <div>
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  marginBottom: '10px',
                }}
              >
                <span style={{ fontSize: '13px', fontWeight: 600, color: '#64748b' }}>
                  Batas Maksimal Akun
                </span>
                <span
                  style={{
                    fontSize: '12px',
                    fontWeight: 700,
                    padding: '2px 9px',
                    borderRadius: '6px',
                    background: '#eff6ff',
                    color: '#2563eb',
                  }}
                >
                  {maxAccounts} Akun / HP
                </span>
              </div>
              <p style={{ fontSize: '12px', color: '#64748b', lineHeight: 1.5, margin: 0 }}>
                Jumlah akun siswa unik yang diizinkan mendaftar dari 1 perangkat HP fisik yang sama.
              </p>
            </div>

            <div
              style={{
                marginTop: '16px',
                paddingTop: '14px',
                borderTop: '1px solid #f1f5f9',
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
              }}
            >
              <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: '8px' }}>
                <input
                  type="number"
                  min={1}
                  max={20}
                  className="au-input"
                  value={maxAccounts}
                  onChange={(e) => setMaxAccounts(Math.max(1, parseInt(e.target.value) || 1))}
                  style={{
                    width: '80px',
                    height: '36px',
                    textAlign: 'center',
                    fontWeight: 700,
                    borderRadius: '6px',
                    border: '1px solid #cbd5e1',
                  }}
                />
                <span style={{ fontSize: '12px', color: '#64748b' }}>akun per HP</span>
              </div>

              {hasSettingsChanged && (
                <button
                  type="button"
                  className="btn btn-primary"
                  onClick={handleSaveSettings}
                  disabled={isSavingSettings}
                  style={{
                    height: '36px',
                    padding: '0 14px',
                    fontSize: '12px',
                    fontWeight: 600,
                    borderRadius: '6px',
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '6px',
                    background: '#2563eb',
                    borderColor: '#2563eb',
                  }}
                >
                  <i className={`fa-solid ${isSavingSettings ? 'fa-spinner fa-spin' : 'fa-check'}`}></i>
                  <span>Simpan</span>
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Card 3: Statistik Total Perangkat */}
        <div className="col-12 col-md-12 col-xl-4 mb-3">
          <div
            className="m-card"
            style={{
              padding: '20px',
              height: '100%',
              display: 'flex',
              flexDirection: 'column',
              justifyContent: 'space-between',
            }}
          >
            <div style={{ marginBottom: '10px' }}>
              <span style={{ fontSize: '13px', fontWeight: 600, color: '#64748b' }}>
                Ringkasan Perangkat Siswa
              </span>
            </div>

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(3, 1fr)',
                gap: '10px',
                textAlign: 'center',
              }}
            >
              <div
                style={{
                  background: '#f8fafc',
                  padding: '10px 8px',
                  borderRadius: '8px',
                  border: '1px solid #f1f5f9',
                }}
              >
                <div style={{ fontSize: '20px', fontWeight: 700, color: '#1e293b' }}>
                  {data?.total_devices ?? 0}
                </div>
                <div style={{ fontSize: '11px', color: '#64748b', marginTop: '2px' }}>Total HP</div>
              </div>

              <div
                style={{
                  background: '#f0fdf4',
                  padding: '10px 8px',
                  borderRadius: '8px',
                  border: '1px solid #dcfce7',
                }}
              >
                <div style={{ fontSize: '20px', fontWeight: 700, color: '#15803d' }}>
                  {data?.whitelisted_count ?? 0}
                </div>
                <div style={{ fontSize: '11px', color: '#15803d', marginTop: '2px' }}>Whitelist (VIP)</div>
              </div>

              <div
                style={{
                  background: '#fef2f2',
                  padding: '10px 8px',
                  borderRadius: '8px',
                  border: '1px solid #fee2e2',
                }}
              >
                <div style={{ fontSize: '20px', fontWeight: 700, color: '#b91c1c' }}>
                  {data?.blocked_count ?? 0}
                </div>
                <div style={{ fontSize: '11px', color: '#b91c1c', marginTop: '2px' }}>Diblokir</div>
              </div>
            </div>

            <div style={{ marginTop: '12px', fontSize: '11px', color: '#94a3b8', textAlign: 'center' }}>
              Sinkronisasi otomatis dengan server Supabase
            </div>
          </div>
        </div>
      </div>

      {/* 3. Main Card: Table of Devices */}
      <section className="m-card">
        {/* Filter and Search Bar */}
        <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between gap-3">
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            {/* Search Input */}
            <div style={{ position: 'relative', width: '300px' }}>
              <input
                type="text"
                className="au-input"
                placeholder="Cari model HP, username, ID device..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                style={{
                  width: '100%',
                  height: '36px',
                  borderRadius: '6px',
                  border: '1px solid #e2e8f0',
                  padding: '0 12px 0 34px',
                  fontSize: '13px',
                }}
              />
              <i
                className="fa-solid fa-magnifying-glass"
                style={{
                  position: 'absolute',
                  left: '12px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  color: '#94a3b8',
                  fontSize: '12px',
                }}
              ></i>
            </div>

            {/* Filter Dropdown */}
            <select
              value={filterType}
              onChange={(e) => setFilterType(e.target.value as any)}
              style={{
                height: '36px',
                borderRadius: '6px',
                border: '1px solid #e2e8f0',
                padding: '0 12px',
                fontSize: '13px',
                color: '#475569',
                background: '#ffffff',
              }}
            >
              <option value="all">Semua Perangkat</option>
              <option value="whitelisted">Hanya Whitelist (VIP)</option>
              <option value="blocked">Hanya Diblokir</option>
              <option value="exceeded">Mencapai / Melebihi Batas</option>
            </select>
          </div>

          <div style={{ fontSize: '13px', color: '#64748b' }}>
            Menampilkan <b>{filteredDevices.length}</b> dari {data?.devices?.length ?? 0} perangkat
          </div>
        </header>

        {/* Table Content */}
        <div className="table-responsive">
          <table className="table m-table align-middle" style={{ marginBottom: 0 }}>
            <thead>
              <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0' }}>
                <th style={{ width: '28%', padding: '12px 16px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                  Model Perangkat & ID
                </th>
                <th style={{ width: '28%', padding: '12px 16px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                  Akun Siswa Terdaftar
                </th>
                <th style={{ width: '14%', padding: '12px 16px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                  Penggunaan Kuota
                </th>
                <th style={{ width: '12%', padding: '12px 16px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                  Status
                </th>
                <th style={{ width: '18%', padding: '12px 16px', fontSize: '12px', fontWeight: 600, color: '#475569', textAlign: 'right' }}>
                  Aksi Admin
                </th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: '48px 16px', color: '#64748b' }}>
                    <i className="fa-solid fa-spinner fa-spin fa-2x mb-3" style={{ color: '#4272d7' }}></i>
                    <p style={{ margin: 0, fontSize: '14px' }}>Memuat data perangkat...</p>
                  </td>
                </tr>
              ) : filteredDevices.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{ textAlign: 'center', padding: '48px 16px', color: '#94a3b8' }}>
                    <i className="fa-solid fa-mobile-screen-button fa-3x mb-3" style={{ opacity: 0.4 }}></i>
                    <p style={{ margin: 0, fontSize: '14px', fontWeight: 500, color: '#64748b' }}>
                      {search || filterType !== 'all'
                        ? 'Tidak ada perangkat yang sesuai dengan filter pencarian.'
                        : 'Belum ada pendaftaran perangkat yang tercatat.'}
                    </p>
                    <p style={{ margin: '4px 0 0 0', fontSize: '12px' }}>
                      Data akan otomatis muncul setiap kali ada siswa yang mendaftar akun baru via HP.
                    </p>
                  </td>
                </tr>
              ) : (
                filteredDevices.map((device) => {
                  const maxLimit = data?.settings?.max_accounts || 3;
                  const isExceeded = device.account_count >= maxLimit;
                  const isActionLoading = actionLoadingId === device.device_id;

                  return (
                    <tr
                      key={device.device_id}
                      style={{
                        borderBottom: '1px solid #f1f5f9',
                        background: device.is_blocked
                          ? '#fff5f5'
                          : device.is_whitelisted
                          ? '#f0fdf4'
                          : undefined,
                      }}
                    >
                      {/* Model & Device ID */}
                      <td style={{ padding: '14px 16px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                          <div
                            style={{
                              width: '36px',
                              height: '36px',
                              borderRadius: '8px',
                              background: device.is_whitelisted
                                ? '#dcfce7'
                                : device.is_blocked
                                ? '#fee2e2'
                                : '#eff6ff',
                              color: device.is_whitelisted
                                ? '#15803d'
                                : device.is_blocked
                                ? '#b91c1c'
                                : '#2563eb',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              fontSize: '15px',
                              flexShrink: 0,
                            }}
                          >
                            <i
                              className={`fa-solid ${
                                device.is_whitelisted
                                  ? 'fa-shield-halved'
                                  : device.is_blocked
                                  ? 'fa-ban'
                                  : 'fa-mobile-screen'
                              }`}
                            ></i>
                          </div>

                          <div style={{ minWidth: 0 }}>
                            <div
                              style={{
                                fontSize: '13px',
                                fontWeight: 600,
                                color: '#1e293b',
                                whiteSpace: 'nowrap',
                                overflow: 'hidden',
                                textOverflow: 'ellipsis',
                              }}
                            >
                              {device.device_model}
                            </div>
                            <div
                              style={{
                                fontSize: '11px',
                                color: '#94a3b8',
                                display: 'flex',
                                alignItems: 'center',
                                gap: '6px',
                                marginTop: '2px',
                              }}
                            >
                              <span
                                style={{
                                  fontFamily: 'monospace',
                                  maxWidth: '150px',
                                  overflow: 'hidden',
                                  textOverflow: 'ellipsis',
                                }}
                                title={device.device_id}
                              >
                                {device.device_id}
                              </span>
                              <button
                                type="button"
                                onClick={() => handleCopyDeviceId(device.device_id)}
                                title="Salin Device ID"
                                style={{
                                  background: 'none',
                                  border: 'none',
                                  padding: 0,
                                  cursor: 'pointer',
                                  color: copiedId === device.device_id ? '#10b981' : '#94a3b8',
                                }}
                              >
                                <i
                                  className={`fa-solid ${
                                    copiedId === device.device_id ? 'fa-check' : 'fa-copy'
                                  }`}
                                  style={{ fontSize: '10px' }}
                                ></i>
                              </button>
                            </div>
                          </div>
                        </div>
                      </td>

                      {/* Akun Siswa */}
                      <td style={{ padding: '14px 16px' }}>
                        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '4px' }}>
                          {device.accounts.map((uname) => (
                            <span
                              key={uname}
                              style={{
                                fontSize: '11px',
                                fontWeight: 600,
                                padding: '2px 8px',
                                borderRadius: '12px',
                                background: '#f1f5f9',
                                color: '#334155',
                                border: '1px solid #e2e8f0',
                              }}
                            >
                              @{uname.replace('@', '')}
                            </span>
                          ))}
                        </div>
                      </td>

                      {/* Penggunaan Kuota */}
                      <td style={{ padding: '14px 16px' }}>
                        {device.is_whitelisted ? (
                          <span
                            style={{
                              fontSize: '11px',
                              fontWeight: 700,
                              color: '#15803d',
                              display: 'inline-flex',
                              alignItems: 'center',
                              gap: '4px',
                            }}
                          >
                            <i className="fa-solid fa-infinity"></i> Bebas Kuota
                          </span>
                        ) : (
                          <div>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                              <span
                                style={{
                                  fontSize: '13px',
                                  fontWeight: 700,
                                  color: isExceeded ? '#dc2626' : '#1e293b',
                                }}
                              >
                                {device.account_count}
                              </span>
                              <span style={{ fontSize: '11px', color: '#94a3b8' }}>/ {maxLimit} Akun</span>
                            </div>
                            {/* Mini progress bar */}
                            <div
                              style={{
                                width: '100%',
                                maxWidth: '100px',
                                height: '5px',
                                borderRadius: '3px',
                                background: '#e2e8f0',
                                marginTop: '4px',
                                overflow: 'hidden',
                              }}
                            >
                              <div
                                style={{
                                  height: '100%',
                                  width: `${Math.min(100, (device.account_count / maxLimit) * 100)}%`,
                                  background: isExceeded ? '#ef4444' : '#3b82f6',
                                  borderRadius: '3px',
                                }}
                              ></div>
                            </div>
                          </div>
                        )}
                      </td>

                      {/* Status */}
                      <td style={{ padding: '14px 16px' }}>
                        {device.is_blocked ? (
                          <span
                            style={{
                              fontSize: '11px',
                              fontWeight: 700,
                              padding: '3px 8px',
                              borderRadius: '4px',
                              background: '#fee2e2',
                              color: '#b91c1c',
                            }}
                          >
                            Diblokir
                          </span>
                        ) : device.is_whitelisted ? (
                          <span
                            style={{
                              fontSize: '11px',
                              fontWeight: 700,
                              padding: '3px 8px',
                              borderRadius: '4px',
                              background: '#dcfce7',
                              color: '#15803d',
                            }}
                          >
                            Whitelist
                          </span>
                        ) : isExceeded ? (
                          <span
                            style={{
                              fontSize: '11px',
                              fontWeight: 700,
                              padding: '3px 8px',
                              borderRadius: '4px',
                              background: '#fef3c7',
                              color: '#b45309',
                            }}
                          >
                            Penuh ({device.account_count})
                          </span>
                        ) : (
                          <span
                            style={{
                              fontSize: '11px',
                              fontWeight: 600,
                              padding: '3px 8px',
                              borderRadius: '4px',
                              background: '#f1f5f9',
                              color: '#475569',
                            }}
                          >
                            Normal
                          </span>
                        )}
                      </td>

                      {/* Action Buttons */}
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
                          {/* Toggle Whitelist */}
                          <AdminTooltip
                            content={
                              device.is_whitelisted
                                ? 'Hapus dari Whitelist (terapkan limit)'
                                : 'Bebaskan perangkat (Whitelist VIP)'
                            }
                          >
                            <button
                              type="button"
                              onClick={() => handleToggleWhitelist(device)}
                              disabled={isActionLoading}
                              style={{
                                width: '32px',
                                height: '32px',
                                borderRadius: '6px',
                                border: '1px solid',
                                borderColor: device.is_whitelisted ? '#86efac' : '#cbd5e1',
                                background: device.is_whitelisted ? '#dcfce7' : '#ffffff',
                                color: device.is_whitelisted ? '#15803d' : '#64748b',
                                cursor: 'pointer',
                                display: 'inline-flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '13px',
                              }}
                            >
                              <i className="fa-solid fa-shield-halved"></i>
                            </button>
                          </AdminTooltip>

                          {/* Reset Quota Button */}
                          <AdminTooltip content="Reset kuota perangkat (hapus riwayat pendaftaran)">
                            <button
                              type="button"
                              onClick={() => setResetTarget(device)}
                              disabled={isActionLoading}
                              style={{
                                width: '32px',
                                height: '32px',
                                borderRadius: '6px',
                                border: '1px solid #e2e8f0',
                                background: '#ffffff',
                                color: '#eab308',
                                cursor: 'pointer',
                                display: 'inline-flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '13px',
                              }}
                            >
                              <i className="fa-solid fa-rotate-left"></i>
                            </button>
                          </AdminTooltip>

                          {/* Toggle Block Button */}
                          <AdminTooltip
                            content={device.is_blocked ? 'Buka blokir perangkat' : 'Blokir pendaftaran dari HP ini'}
                          >
                            <button
                              type="button"
                              onClick={() => handleToggleBlock(device)}
                              disabled={isActionLoading}
                              style={{
                                width: '32px',
                                height: '32px',
                                borderRadius: '6px',
                                border: '1px solid',
                                borderColor: device.is_blocked ? '#fca5a5' : '#e2e8f0',
                                background: device.is_blocked ? '#fee2e2' : '#ffffff',
                                color: device.is_blocked ? '#b91c1c' : '#94a3b8',
                                cursor: 'pointer',
                                display: 'inline-flex',
                                alignItems: 'center',
                                justifyContent: 'center',
                                fontSize: '13px',
                              }}
                            >
                              <i className="fa-solid fa-ban"></i>
                            </button>
                          </AdminTooltip>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </section>

      {/* 4. Modal Konfirmasi Anti-Miss Click: Reset Kuota Perangkat */}
      {resetTarget && (
        <AdminModalPortal isOpen={!!resetTarget} onClose={() => setResetTarget(null)}>
          <div
            style={{
              position: 'fixed',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              backgroundColor: 'rgba(15, 23, 42, 0.65)',
              backdropFilter: 'blur(3px)',
              zIndex: 9999,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: '16px',
            }}
          >
            <div
              style={{
                background: '#ffffff',
                borderRadius: '12px',
                width: '100%',
                maxWidth: '460px',
                boxShadow: '0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04)',
                overflow: 'hidden',
              }}
            >
              <div style={{ padding: '24px' }}>
                <div
                  style={{
                    width: '48px',
                    height: '48px',
                    borderRadius: '12px',
                    background: '#fef9c3',
                    color: '#ca8a04',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '20px',
                    marginBottom: '16px',
                  }}
                >
                  <i className="fa-solid fa-rotate-left"></i>
                </div>

                <h3 style={{ fontSize: '18px', fontWeight: 700, color: '#1e293b', margin: '0 0 8px 0' }}>
                  Reset Kuota Pendaftaran Perangkat?
                </h3>
                <p style={{ fontSize: '13px', color: '#64748b', lineHeight: 1.5, margin: 0 }}>
                  Tindakan ini akan menghapus riwayat pendaftaran dari perangkat{' '}
                  <b style={{ color: '#1e293b' }}>{resetTarget.device_model}</b>. Perangkat ini akan
                  dapat mendaftarkan hingga {data?.settings?.max_accounts || 3} akun baru lagi dari angka 0.
                </p>

                <div
                  style={{
                    background: '#f8fafc',
                    padding: '12px 14px',
                    borderRadius: '8px',
                    marginTop: '16px',
                    border: '1px solid #e2e8f0',
                  }}
                >
                  <div style={{ fontSize: '12px', color: '#475569' }}>
                    <b>Akun yang tercatat sebelumnya:</b>
                  </div>
                  <div style={{ fontSize: '12px', color: '#64748b', marginTop: '4px' }}>
                    {resetTarget.accounts.map((a) => `@${a.replace('@', '')}`).join(', ')}
                  </div>
                </div>

                <div
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'flex-end',
                    gap: '10px',
                    marginTop: '24px',
                  }}
                >
                  <button
                    type="button"
                    className="btn btn-light"
                    onClick={() => setResetTarget(null)}
                    disabled={isResetting}
                    style={{
                      height: '38px',
                      padding: '0 16px',
                      fontSize: '13px',
                      fontWeight: 600,
                      borderRadius: '6px',
                      border: '1px solid #cbd5e1',
                    }}
                  >
                    Batal
                  </button>
                  <button
                    type="button"
                    className="btn btn-warning"
                    onClick={handleConfirmReset}
                    disabled={isResetting}
                    style={{
                      height: '38px',
                      padding: '0 18px',
                      fontSize: '13px',
                      fontWeight: 600,
                      borderRadius: '6px',
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '8px',
                      background: '#eab308',
                      borderColor: '#eab308',
                      color: '#ffffff',
                    }}
                  >
                    <i className={`fa-solid ${isResetting ? 'fa-spinner fa-spin' : 'fa-check'}`}></i>
                    <span>{isResetting ? 'Mereset...' : 'Ya, Reset Kuota'}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </AdminModalPortal>
      )}
    </div>
  );
}
