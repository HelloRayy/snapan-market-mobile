import { useState, useEffect, useMemo, useCallback } from 'react';
import {
  adminService,
  type DeviceRecordRow,
  type DeviceSecurityData,
  type DeviceSecurityAlert,
  type NisDeviceDetailsData,
} from '../services/adminService';
import { AdminModalPortal } from '../components/AdminModalPortal';
import { AdminTooltip } from '../components/AdminTooltip';

interface DeviceSecurityTabProps {
  isActive?: boolean;
}

export function DeviceSecurityTab({ isActive = true }: DeviceSecurityTabProps) {
  // Sub-tab: 'registration_limits' | 'nis_investigation'
  const [subTab, setSubTab] = useState<'registration_limits' | 'nis_investigation'>('registration_limits');

  const [data, setData] = useState<DeviceSecurityData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [search, setSearch] = useState('');
  const [filterType, setFilterType] = useState<'all' | 'whitelisted' | 'blocked' | 'exceeded'>('all');
  const [feedbackMsg, setFeedbackMsg] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Settings State (Global Quota per Hardware Device)
  const [isEnabled, setIsEnabled] = useState(true);
  const [maxAccounts, setMaxAccounts] = useState(3);
  const [isSavingSettings, setIsSavingSettings] = useState(false);

  // [SNAPS-63] Security Alerts & NIS Investigation State
  const [securityAlerts, setSecurityAlerts] = useState<DeviceSecurityAlert[]>([]);
  const [alertsPolicy, setAlertsPolicy] = useState<{ max_devices_per_nis: number; failed_threshold: number }>({
    max_devices_per_nis: 3,
    failed_threshold: 3,
  });
  const [searchNisInput, setSearchNisInput] = useState('');
  const [currentNisData, setCurrentNisData] = useState<NisDeviceDetailsData | null>(null);
  const [isSearchingNis, setIsSearchingNis] = useState(false);
  const [activeSearchedNis, setActiveSearchedNis] = useState<string | null>(null);

  // Action Modals State
  const [resetTarget, setResetTarget] = useState<DeviceRecordRow | null>(null);
  const [isResetting, setIsResetting] = useState(false);
  const [unlinkTarget, setUnlinkTarget] = useState<{ nis: string; deviceId: string; model: string } | null>(null);
  const [isUnlinking, setIsUnlinking] = useState(false);
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
      const [res, alertsRes] = await Promise.all([
        adminService.getDeviceSecurityData(),
        adminService.getSecurityAlerts().catch(() => ({
          total_alerts: 0,
          alerts: [],
          policy: { max_devices_per_nis: 3, failed_threshold: 3 },
        })),
      ]);

      setData(res);
      setIsEnabled(res.settings.enabled);
      setMaxAccounts(res.settings.max_accounts);
      setSecurityAlerts(alertsRes.alerts || []);
      if (alertsRes.policy) {
        setAlertsPolicy(alertsRes.policy);
      }
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

  // Handler: Simpan Konfigurasi Global Kuota HP Fisik
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

  // Handler: Konfirmasi Reset Kuota Perangkat Fisik
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

  // [SNAPS-63] Handler: Cari Detail Investigasi Perangkat Siswa berdasarkan NIS
  const handleSearchNis = async (targetNis: string) => {
    const clean = targetNis.trim();
    if (!clean) return;

    setIsSearchingNis(true);
    setActiveSearchedNis(clean);
    try {
      const result = await adminService.getNisDeviceDetails(clean);
      setCurrentNisData(result);
      if (!result.student && result.devices.length === 0 && result.recent_logs.length === 0) {
        showFeedback('error', `Tidak ditemukan data akun atau perangkat untuk NIS ${clean}.`);
      }
    } catch (err: any) {
      showFeedback('error', `Gagal memuat detail NIS ${clean}: ${err?.message || err}`);
    } finally {
      setIsSearchingNis(false);
    }
  };

  // [SNAPS-63] Handler: Konfirmasi Unlink Device dari NIS
  const handleConfirmUnlink = async () => {
    if (!unlinkTarget) return;
    setIsUnlinking(true);
    try {
      await adminService.unlinkNisDevice(unlinkTarget.nis, unlinkTarget.deviceId);
      showFeedback(
        'success',
        `Perangkat "${unlinkTarget.model}" berhasil diputuskan dari NIS ${unlinkTarget.nis}. Siswa kini dapat masuk menggunakan perangkat baru.`
      );
      setUnlinkTarget(null);
      if (activeSearchedNis) {
        await handleSearchNis(activeSearchedNis);
      }
      await loadData(true);
    } catch (e: any) {
      showFeedback('error', e?.message || 'Gagal memutuskan tautan perangkat.');
    } finally {
      setIsUnlinking(false);
    }
  };

  // Salin ID Perangkat
  const handleCopyDeviceId = (deviceId: string) => {
    navigator.clipboard.writeText(deviceId);
    setCopiedId(deviceId);
    setTimeout(() => setCopiedId(null), 2000);
  };

  // Filter Data Perangkat Registrasi
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
              Keamanan Perangkat & Analisis Akun Siswa
            </h2>
            <p style={{ fontSize: '13px', color: '#64748b', margin: '4px 0 0 0' }}>
              Kelola batas registrasi akun per HP fisik, deteksi percobaan pembobolan kata sandi, dan
              investigasi perangkat per NIS siswa (SNAPS-63).
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

      {/* Sub-Navigation Tabs */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          marginBottom: '20px',
          borderBottom: '1px solid #e2e8f0',
          paddingBottom: '8px',
        }}
      >
        <button
          type="button"
          onClick={() => setSubTab('registration_limits')}
          style={{
            padding: '8px 16px',
            fontSize: '13px',
            fontWeight: 600,
            borderRadius: '6px',
            border: 'none',
            background: subTab === 'registration_limits' ? '#eff6ff' : 'transparent',
            color: subTab === 'registration_limits' ? '#1d4ed8' : '#64748b',
            cursor: 'pointer',
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.15s ease',
          }}
        >
          <i className="fa-solid fa-sliders"></i>
          <span>Batas Registrasi HP Fisik</span>
          {data?.devices && (
            <span
              style={{
                fontSize: '11px',
                background: subTab === 'registration_limits' ? '#dbeafe' : '#f1f5f9',
                color: subTab === 'registration_limits' ? '#1e40af' : '#64748b',
                padding: '1px 6px',
                borderRadius: '10px',
              }}
            >
              {data.devices.length}
            </span>
          )}
        </button>

        <button
          type="button"
          onClick={() => setSubTab('nis_investigation')}
          style={{
            padding: '8px 16px',
            fontSize: '13px',
            fontWeight: 600,
            borderRadius: '6px',
            border: 'none',
            background: subTab === 'nis_investigation' ? '#eff6ff' : 'transparent',
            color: subTab === 'nis_investigation' ? '#1d4ed8' : '#64748b',
            cursor: 'pointer',
            display: 'inline-flex',
            alignItems: 'center',
            gap: '8px',
            transition: 'all 0.15s ease',
          }}
        >
          <i className="fa-solid fa-user-shield"></i>
          <span>Investigasi NIS & Alert Perangkat</span>
          {securityAlerts.length > 0 && (
            <span
              style={{
                fontSize: '11px',
                background: '#ef4444',
                color: '#ffffff',
                fontWeight: 700,
                padding: '1px 7px',
                borderRadius: '10px',
                boxShadow: '0 1px 3px rgba(239, 68, 68, 0.4)',
              }}
            >
              {securityAlerts.length} Peringatan
            </span>
          )}
        </button>
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

      {/* TAB 1: REGISTRATION LIMITS & HARDWARE QUOTA */}
      {subTab === 'registration_limits' && (
        <>
          {/* Top Controls & Settings Cards */}
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
                    Ringkasan Perangkat Terdata
                  </span>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '10px' }}>
                  <div
                    style={{
                      background: '#f8fafc',
                      padding: '12px 8px',
                      textAlign: 'center',
                      borderRadius: '8px',
                      border: '1px solid #e2e8f0',
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
                      padding: '12px 8px',
                      textAlign: 'center',
                      borderRadius: '8px',
                      border: '1px solid #bbf7d0',
                    }}
                  >
                    <div style={{ fontSize: '20px', fontWeight: 700, color: '#15803d' }}>
                      {data?.whitelisted_count ?? 0}
                    </div>
                    <div style={{ fontSize: '11px', color: '#15803d', marginTop: '2px' }}>Whitelist</div>
                  </div>

                  <div
                    style={{
                      background: '#fef2f2',
                      padding: '12px 8px',
                      textAlign: 'center',
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

          {/* Table of Registered Devices */}
          <section className="m-card">
            {/* Filter and Search Bar */}
            <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between gap-3">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
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

                          <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                            <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
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
        </>
      )}

      {/* TAB 2: [SNAPS-63] INVESTIGASI NIS & ALERT PERANGKAT */}
      {subTab === 'nis_investigation' && (
        <div>
          {/* Security Alert Overview Cards */}
          <div className="row mb-4">
            <div className="col-12 col-md-6 col-xl-4 mb-3">
              <div
                className="m-card"
                style={{
                  padding: '20px',
                  background: securityAlerts.length > 0 ? '#fef2f2' : '#f0fdf4',
                  borderColor: securityAlerts.length > 0 ? '#fecaca' : '#bbf7d0',
                  height: '100%',
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div
                    style={{
                      width: '44px',
                      height: '44px',
                      borderRadius: '10px',
                      background: securityAlerts.length > 0 ? '#fee2e2' : '#dcfce7',
                      color: securityAlerts.length > 0 ? '#dc2626' : '#15803d',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '18px',
                      flexShrink: 0,
                    }}
                  >
                    <i
                      className={`fa-solid ${
                        securityAlerts.length > 0 ? 'fa-triangle-exclamation' : 'fa-circle-check'
                      }`}
                    ></i>
                  </div>
                  <div>
                    <div
                      style={{
                        fontSize: '18px',
                        fontWeight: 700,
                        color: securityAlerts.length > 0 ? '#991b1b' : '#166534',
                      }}
                    >
                      {securityAlerts.length} Peringatan Aktif
                    </div>
                    <div style={{ fontSize: '12px', color: '#64748b', marginTop: '2px' }}>
                      {securityAlerts.length > 0
                        ? 'Terdapat NIS siswa dengan anomali login atau perangkat berlebih.'
                        : 'Seluruh aktivitas login per NIS siswa dalam batas wajar.'}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="col-12 col-md-6 col-xl-8 mb-3">
              <div className="m-card" style={{ padding: '18px 20px', height: '100%' }}>
                <div style={{ fontSize: '13px', fontWeight: 600, color: '#1e293b', marginBottom: '6px' }}>
                  Kebijakan Batas Keamanan Login Siswa (SNAPS-63)
                </div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '12px', fontSize: '12px', color: '#64748b' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <i className="fa-solid fa-mobile-screen" style={{ color: '#3b82f6' }}></i>
                    <span>Maksimal Perangkat Aktif per NIS: <b>{alertsPolicy.max_devices_per_nis} Perangkat</b></span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <i className="fa-solid fa-shield-halved" style={{ color: '#ef4444' }}></i>
                    <span>Toleransi Percobaan Gagal: <b>Maksimal {alertsPolicy.failed_threshold}x Salah</b> (24 Jam)</span>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <i className="fa-solid fa-user-gear" style={{ color: '#8b5cf6' }}></i>
                    <span>Pelepasan Perangkat: <b>Manual oleh Admin</b> setelah siswa melapor</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Active Security Alerts List (If Any) */}
          {securityAlerts.length > 0 && (
            <div className="m-card mb-4" style={{ borderLeft: '4px solid #ef4444' }}>
              <div
                style={{
                  padding: '14px 20px',
                  background: '#fff1f2',
                  borderBottom: '1px solid #ffe4e6',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                }}
              >
                <div style={{ fontSize: '13px', fontWeight: 700, color: '#9f1239' }}>
                  Daftar Peringatan Keamanan Yang Membutuhkan Tindakan
                </div>
                <span
                  style={{
                    fontSize: '11px',
                    fontWeight: 700,
                    padding: '2px 8px',
                    borderRadius: '12px',
                    background: '#fecdd3',
                    color: '#9f1239',
                  }}
                >
                  LIVE ALERT
                </span>
              </div>

              <div style={{ padding: '12px 20px' }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  {securityAlerts.map((alert) => (
                    <div
                      key={`${alert.nis}-${alert.alert_type}`}
                      style={{
                        padding: '12px 16px',
                        borderRadius: '8px',
                        background: '#ffffff',
                        border: '1px solid #fecaca',
                        display: 'flex',
                        flexWrap: 'wrap',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        gap: '12px',
                      }}
                    >
                      <div style={{ display: 'flex', alignItems: 'flex-start', gap: '12px' }}>
                        <div
                          style={{
                            width: '32px',
                            height: '32px',
                            borderRadius: '6px',
                            background: alert.alert_type === 'excess_devices' ? '#fef3c7' : '#fee2e2',
                            color: alert.alert_type === 'excess_devices' ? '#b45309' : '#dc2626',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '14px',
                            marginTop: '2px',
                          }}
                        >
                          <i
                            className={`fa-solid ${
                              alert.alert_type === 'excess_devices'
                                ? 'fa-mobile-screen-button'
                                : 'fa-triangle-exclamation'
                            }`}
                          ></i>
                        </div>
                        <div>
                          <div style={{ fontSize: '13px', fontWeight: 700, color: '#1e293b' }}>
                            {alert.alert_type === 'excess_devices'
                              ? `NIS ${alert.nis}: Terhubung Lebih dari ${alertsPolicy.max_devices_per_nis} Perangkat (${alert.count} HP)`
                              : `NIS ${alert.nis}: Terdeteksi ${alert.count}x Salah Password dalam 24 Jam`}
                          </div>
                          <div style={{ fontSize: '12px', color: '#64748b', marginTop: '2px' }}>
                            {alert.message}
                          </div>
                          {alert.device_models && alert.device_models.length > 0 && (
                            <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
                              Model perangkat: {alert.device_models.join(', ')}
                            </div>
                          )}
                        </div>
                      </div>

                      <button
                        type="button"
                        onClick={() => {
                          setSearchNisInput(alert.nis);
                          handleSearchNis(alert.nis);
                        }}
                        className="btn btn-outline-danger"
                        style={{
                          height: '32px',
                          padding: '0 12px',
                          fontSize: '12px',
                          fontWeight: 600,
                          borderRadius: '6px',
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '6px',
                        }}
                      >
                        <i className="fa-solid fa-magnifying-glass"></i>
                        <span>Investigasi NIS Ini</span>
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Search Box per NIS Siswa */}
          <div className="m-card mb-4" style={{ padding: '20px' }}>
            <div style={{ fontSize: '14px', fontWeight: 700, color: '#1e293b', marginBottom: '4px' }}>
              Pencarian & Investigasi Perangkat per NIS Siswa
            </div>
            <p style={{ fontSize: '12px', color: '#64748b', marginBottom: '14px' }}>
              Masukkan nomor induk siswa (NIS) untuk melihat daftar HP fisik yang terhubung, riwayat percobaan
              login, atau melakukan pemutusan perangkat (*Unlink Device*) ketika siswa melapor ganti HP / hilang.
            </p>

            <form
              onSubmit={(e) => {
                e.preventDefault();
                handleSearchNis(searchNisInput);
              }}
              style={{ display: 'flex', gap: '10px', maxWidth: '480px' }}
            >
              <div style={{ position: 'relative', flex: 1 }}>
                <input
                  type="text"
                  className="au-input"
                  placeholder="Ketik NIS Siswa (contoh: 22819)..."
                  value={searchNisInput}
                  onChange={(e) => setSearchNisInput(e.target.value)}
                  style={{
                    width: '100%',
                    height: '38px',
                    borderRadius: '6px',
                    border: '1px solid #cbd5e1',
                    padding: '0 12px 0 34px',
                    fontSize: '13px',
                  }}
                />
                <i
                  className="fa-solid fa-id-card"
                  style={{
                    position: 'absolute',
                    left: '12px',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    color: '#94a3b8',
                    fontSize: '13px',
                  }}
                ></i>
              </div>

              <button
                type="submit"
                className="btn btn-primary"
                disabled={isSearchingNis || !searchNisInput.trim()}
                style={{
                  height: '38px',
                  padding: '0 18px',
                  fontSize: '13px',
                  fontWeight: 600,
                  borderRadius: '6px',
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '8px',
                  background: '#2563eb',
                  borderColor: '#2563eb',
                }}
              >
                <i className={`fa-solid ${isSearchingNis ? 'fa-spinner fa-spin' : 'fa-magnifying-glass'}`}></i>
                <span>{isSearchingNis ? 'Mencari...' : 'Cari NIS'}</span>
              </button>
            </form>
          </div>

          {/* Searched NIS Results View */}
          {currentNisData && (
            <div className="row">
              {/* Student Info Card */}
              <div className="col-12 col-lg-4 mb-4">
                <div className="m-card" style={{ padding: '20px', height: '100%' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '16px' }}>
                    <div
                      style={{
                        width: '50px',
                        height: '50px',
                        borderRadius: '12px',
                        background: '#eff6ff',
                        color: '#2563eb',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '20px',
                        fontWeight: 700,
                      }}
                    >
                      <i className="fa-solid fa-graduation-cap"></i>
                    </div>
                    <div>
                      <h4 style={{ fontSize: '15px', fontWeight: 700, color: '#1e293b', margin: 0 }}>
                        {currentNisData.student?.full_name || `Siswa NIS ${activeSearchedNis}`}
                      </h4>
                      <div style={{ fontSize: '12px', color: '#64748b', marginTop: '2px' }}>
                        {currentNisData.student?.username
                          ? `@${currentNisData.student.username}`
                          : 'Belum membuat username'}
                      </div>
                    </div>
                  </div>

                  <div style={{ borderTop: '1px solid #f1f5f9', paddingTop: '14px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', fontSize: '12.5px' }}>
                      <span style={{ color: '#64748b' }}>Nomor Induk (NIS):</span>
                      <b style={{ color: '#1e293b' }}>{activeSearchedNis}</b>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', fontSize: '12.5px' }}>
                      <span style={{ color: '#64748b' }}>Kelas:</span>
                      <b style={{ color: '#1e293b' }}>{currentNisData.student?.class_group || '-'}</b>
                    </div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', fontSize: '12.5px' }}>
                      <span style={{ color: '#64748b' }}>Perangkat Aktif:</span>
                      <b
                        style={{
                          color:
                            currentNisData.devices.filter((d) => !d.is_unlinked).length > alertsPolicy.max_devices_per_nis
                              ? '#dc2626'
                              : '#15803d',
                        }}
                      >
                        {currentNisData.devices.filter((d) => !d.is_unlinked).length} / {alertsPolicy.max_devices_per_nis} HP
                      </b>
                    </div>
                  </div>

                  {/* Security Status Badge */}
                  <div style={{ marginTop: '16px' }}>
                    {currentNisData.devices.filter((d) => !d.is_unlinked).length > alertsPolicy.max_devices_per_nis ? (
                      <div
                        style={{
                          padding: '10px 12px',
                          borderRadius: '6px',
                          background: '#fef2f2',
                          border: '1px solid #fecaca',
                          color: '#b91c1c',
                          fontSize: '12px',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '8px',
                        }}
                      >
                        <i className="fa-solid fa-triangle-exclamation"></i>
                        <span><b>Peringatan:</b> Perangkat terhubung melebihi batas default 3 HP.</span>
                      </div>
                    ) : (
                      <div
                        style={{
                          padding: '10px 12px',
                          borderRadius: '6px',
                          background: '#f0fdf4',
                          border: '1px solid #bbf7d0',
                          color: '#15803d',
                          fontSize: '12px',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '8px',
                        }}
                      >
                        <i className="fa-solid fa-circle-check"></i>
                        <span>Jumlah perangkat aktif terpantau wajar.</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Devices Bound Table & Unlink Actions */}
              <div className="col-12 col-lg-8 mb-4">
                <div className="m-card" style={{ padding: '20px' }}>
                  <div
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      marginBottom: '14px',
                    }}
                  >
                    <div>
                      <div style={{ fontSize: '14px', fontWeight: 700, color: '#1e293b' }}>
                        Daftar Perangkat Terhubung ({currentNisData.devices.length} HP)
                      </div>
                      <div style={{ fontSize: '11.5px', color: '#64748b' }}>
                        Tekan tombol "Putuskan (Unlink)" jika siswa melapor ganti handphone baru atau HP lama hilang.
                      </div>
                    </div>
                  </div>

                  <div className="table-responsive">
                    <table className="table m-table align-middle" style={{ marginBottom: 0 }}>
                      <thead>
                        <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0' }}>
                          <th style={{ padding: '10px 12px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Model HP
                          </th>
                          <th style={{ padding: '10px 12px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Device ID
                          </th>
                          <th style={{ padding: '10px 12px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Terakhir Dipakai
                          </th>
                          <th style={{ padding: '10px 12px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Status
                          </th>
                          <th style={{ padding: '10px 12px', fontSize: '12px', fontWeight: 600, color: '#475569', textAlign: 'right' }}>
                            Aksi
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {currentNisData.devices.length === 0 ? (
                          <tr>
                            <td colSpan={5} style={{ textAlign: 'center', padding: '28px 12px', color: '#94a3b8' }}>
                              <p style={{ margin: 0, fontSize: '13px' }}>Belum ada perangkat yang terikat ke NIS ini.</p>
                            </td>
                          </tr>
                        ) : (
                          currentNisData.devices.map((dev) => (
                            <tr
                              key={dev.device_id}
                              style={{
                                borderBottom: '1px solid #f1f5f9',
                                background: dev.is_unlinked ? '#fafafa' : '#ffffff',
                                opacity: dev.is_unlinked ? 0.7 : 1,
                              }}
                            >
                              <td style={{ padding: '12px' }}>
                                <div style={{ fontWeight: 600, fontSize: '13px', color: '#1e293b' }}>
                                  {dev.device_model || 'Unknown Device'}
                                </div>
                              </td>

                              <td style={{ padding: '12px' }}>
                                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                                  <span
                                    style={{
                                      fontFamily: 'monospace',
                                      fontSize: '11px',
                                      color: '#64748b',
                                      maxWidth: '120px',
                                      overflow: 'hidden',
                                      textOverflow: 'ellipsis',
                                    }}
                                    title={dev.device_id}
                                  >
                                    {dev.device_id}
                                  </span>
                                  <button
                                    type="button"
                                    onClick={() => handleCopyDeviceId(dev.device_id)}
                                    style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer', color: '#94a3b8' }}
                                    title="Salin ID"
                                  >
                                    <i
                                      className={`fa-solid ${
                                        copiedId === dev.device_id ? 'fa-check text-success' : 'fa-copy'
                                      }`}
                                      style={{ fontSize: '10px' }}
                                    ></i>
                                  </button>
                                </div>
                              </td>

                              <td style={{ padding: '12px', fontSize: '11.5px', color: '#64748b' }}>
                                {dev.last_used_at
                                  ? new Date(dev.last_used_at).toLocaleDateString('id-ID', {
                                      day: 'numeric',
                                      month: 'short',
                                      year: 'numeric',
                                      hour: '2-digit',
                                      minute: '2-digit',
                                    })
                                  : '-'}
                              </td>

                              <td style={{ padding: '12px' }}>
                                {dev.is_unlinked ? (
                                  <span
                                    style={{
                                      fontSize: '10.5px',
                                      fontWeight: 600,
                                      padding: '2px 6px',
                                      borderRadius: '4px',
                                      background: '#f1f5f9',
                                      color: '#64748b',
                                    }}
                                  >
                                    Diputuskan
                                  </span>
                                ) : (
                                  <span
                                    style={{
                                      fontSize: '10.5px',
                                      fontWeight: 700,
                                      padding: '2px 6px',
                                      borderRadius: '4px',
                                      background: '#dcfce7',
                                      color: '#15803d',
                                    }}
                                  >
                                    Aktif
                                  </span>
                                )}
                              </td>

                              <td style={{ padding: '12px', textAlign: 'right' }}>
                                {!dev.is_unlinked && (
                                  <button
                                    type="button"
                                    onClick={() =>
                                      setUnlinkTarget({
                                        nis: activeSearchedNis!,
                                        deviceId: dev.device_id,
                                        model: dev.device_model,
                                      })
                                    }
                                    className="btn btn-outline-danger"
                                    style={{
                                      padding: '4px 10px',
                                      fontSize: '11px',
                                      fontWeight: 600,
                                      borderRadius: '6px',
                                      display: 'inline-flex',
                                      alignItems: 'center',
                                      gap: '4px',
                                    }}
                                  >
                                    <i className="fa-solid fa-link-slash"></i>
                                    <span>Putuskan</span>
                                  </button>
                                )}
                              </td>
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              {/* Recent Authentication Logs Trail (20 Entries) */}
              <div className="col-12 mb-4">
                <div className="m-card" style={{ padding: '20px' }}>
                  <div style={{ fontSize: '14px', fontWeight: 700, color: '#1e293b', marginBottom: '4px' }}>
                    Riwayat Percobaan & Aktivitas Autentikasi NIS (20 Terakhir)
                  </div>
                  <p style={{ fontSize: '12px', color: '#64748b', marginBottom: '14px' }}>
                    Mendeteksi riwayat masuk sukses, pendaftaran, dan percobaan salah kata sandi pada NIS ini.
                  </p>

                  <div className="table-responsive">
                    <table className="table m-table align-middle" style={{ marginBottom: 0 }}>
                      <thead>
                        <tr style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0' }}>
                          <th style={{ padding: '10px 14px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Waktu Kejadian
                          </th>
                          <th style={{ padding: '10px 14px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Aktivitas
                          </th>
                          <th style={{ padding: '10px 14px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Model Perangkat
                          </th>
                          <th style={{ padding: '10px 14px', fontSize: '12px', fontWeight: 600, color: '#475569' }}>
                            Device Identifier
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {currentNisData.recent_logs.length === 0 ? (
                          <tr>
                            <td colSpan={4} style={{ textAlign: 'center', padding: '32px 14px', color: '#94a3b8' }}>
                              Belum ada catatan aktivitas login/register untuk NIS ini.
                            </td>
                          </tr>
                        ) : (
                          currentNisData.recent_logs.map((log) => {
                            const isFailed = log.event_type === 'login_failed';
                            const isSuccess = log.event_type === 'login_success';
                            const isRegister = log.event_type === 'register';

                            return (
                              <tr
                                key={log.id}
                                style={{
                                  borderBottom: '1px solid #f1f5f9',
                                  background: isFailed ? '#fff5f5' : undefined,
                                }}
                              >
                                <td style={{ padding: '12px 14px', fontSize: '12px', color: '#475569' }}>
                                  {new Date(log.created_at).toLocaleString('id-ID', {
                                    day: 'numeric',
                                    month: 'short',
                                    year: 'numeric',
                                    hour: '2-digit',
                                    minute: '2-digit',
                                    second: '2-digit',
                                  })}
                                </td>

                                <td style={{ padding: '12px 14px' }}>
                                  {isSuccess && (
                                    <span
                                      style={{
                                        fontSize: '11px',
                                        fontWeight: 700,
                                        padding: '3px 8px',
                                        borderRadius: '4px',
                                        background: '#dcfce7',
                                        color: '#15803d',
                                        display: 'inline-flex',
                                        alignItems: 'center',
                                        gap: '4px',
                                      }}
                                    >
                                      <i className="fa-solid fa-circle-check"></i> Login Sukses
                                    </span>
                                  )}
                                  {isFailed && (
                                    <span
                                      style={{
                                        fontSize: '11px',
                                        fontWeight: 700,
                                        padding: '3px 8px',
                                        borderRadius: '4px',
                                        background: '#fee2e2',
                                        color: '#b91c1c',
                                        display: 'inline-flex',
                                        alignItems: 'center',
                                        gap: '4px',
                                      }}
                                    >
                                      <i className="fa-solid fa-triangle-exclamation"></i> Gagal (Salah Sandi)
                                    </span>
                                  )}
                                  {isRegister && (
                                    <span
                                      style={{
                                        fontSize: '11px',
                                        fontWeight: 700,
                                        padding: '3px 8px',
                                        borderRadius: '4px',
                                        background: '#e0f2fe',
                                        color: '#0369a1',
                                        display: 'inline-flex',
                                        alignItems: 'center',
                                        gap: '4px',
                                      }}
                                    >
                                      <i className="fa-solid fa-user-plus"></i> Pendaftaran Akun
                                    </span>
                                  )}
                                </td>

                                <td style={{ padding: '12px 14px', fontSize: '12.5px', fontWeight: 600, color: '#1e293b' }}>
                                  {log.device_model || '-'}
                                </td>

                                <td style={{ padding: '12px 14px' }}>
                                  <span
                                    style={{
                                      fontFamily: 'monospace',
                                      fontSize: '11px',
                                      color: '#64748b',
                                      maxWidth: '220px',
                                      display: 'inline-block',
                                      overflow: 'hidden',
                                      textOverflow: 'ellipsis',
                                      verticalAlign: 'middle',
                                    }}
                                    title={log.device_id}
                                  >
                                    {log.device_id}
                                  </span>
                                </td>
                              </tr>
                            );
                          })
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Modal 1: Reset Kuota Perangkat Fisik (Hardware Quota) */}
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

      {/* Modal 2: [SNAPS-63] Konfirmasi Unlink Device dari NIS */}
      {unlinkTarget && (
        <AdminModalPortal isOpen={!!unlinkTarget} onClose={() => setUnlinkTarget(null)}>
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
                    background: '#fee2e2',
                    color: '#dc2626',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '20px',
                    marginBottom: '16px',
                  }}
                >
                  <i className="fa-solid fa-link-slash"></i>
                </div>

                <h3 style={{ fontSize: '18px', fontWeight: 700, color: '#1e293b', margin: '0 0 8px 0' }}>
                  Putuskan Tautan Perangkat (Unlink)?
                </h3>
                <p style={{ fontSize: '13px', color: '#64748b', lineHeight: 1.5, margin: 0 }}>
                  Apakah Anda yakin ingin memutuskan tautan perangkat{' '}
                  <b style={{ color: '#1e293b' }}>{unlinkTarget.model}</b> dari NIS{' '}
                  <b style={{ color: '#1e293b' }}>{unlinkTarget.nis}</b>?
                </p>

                <div
                  style={{
                    background: '#f8fafc',
                    padding: '12px 14px',
                    borderRadius: '8px',
                    marginTop: '16px',
                    border: '1px solid #e2e8f0',
                    fontSize: '12px',
                    color: '#475569',
                    lineHeight: 1.5,
                  }}
                >
                  <i className="fa-solid fa-circle-info me-1" style={{ color: '#3b82f6' }}></i>
                  Gunakan tindakan ini jika siswa melapor ganti HP baru atau perangkat lamanya hilang.
                  Setelah diputuskan, kuota perangkat aktif siswa akan berkurang sehingga siswa dapat login
                  di perangkat barunya.
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
                    onClick={() => setUnlinkTarget(null)}
                    disabled={isUnlinking}
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
                    className="btn btn-danger"
                    onClick={handleConfirmUnlink}
                    disabled={isUnlinking}
                    style={{
                      height: '38px',
                      padding: '0 18px',
                      fontSize: '13px',
                      fontWeight: 600,
                      borderRadius: '6px',
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: '8px',
                      background: '#dc2626',
                      borderColor: '#dc2626',
                      color: '#ffffff',
                    }}
                  >
                    <i className={`fa-solid ${isUnlinking ? 'fa-spinner fa-spin' : 'fa-check'}`}></i>
                    <span>{isUnlinking ? 'Memutuskan...' : 'Ya, Putuskan Perangkat'}</span>
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
