import { useState, useEffect, useCallback } from 'react';
import { adminSecurityService, type AdminActivityLogRow } from '../services/adminSecurityService';
import { ShieldCheck, RefreshCw, Clock, User, Activity } from 'lucide-react';

export function AdminLoginLogCard() {
  const [logs, setLogs] = useState<AdminActivityLogRow[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  const fetchLogs = useCallback(async () => {
    setIsRefreshing(true);
    try {
      const data = await adminSecurityService.getActivityLogs(15);
      setLogs(data);
    } catch (err) {
      console.error('Failed to load admin logs:', err);
    } finally {
      setIsLoading(false);
      setIsRefreshing(false);
    }
  }, []);

  useEffect(() => {
    fetchLogs();
  }, [fetchLogs]);

  const getActionBadge = (action: string) => {
    const act = action.toUpperCase();
    if (act.includes('LOGIN')) {
      return (
        <span
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '4px',
            padding: '2px 8px',
            borderRadius: '4px',
            fontSize: '11px',
            fontWeight: 600,
            background: '#ecfdf5',
            color: '#059669',
            border: '1px solid #a7f3d0',
          }}
        >
          <ShieldCheck style={{ width: '12px', height: '12px' }} />
          LOGIN
        </span>
      );
    }
    if (act.includes('LOGOUT')) {
      return (
        <span
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '4px',
            padding: '2px 8px',
            borderRadius: '4px',
            fontSize: '11px',
            fontWeight: 600,
            background: '#f1f5f9',
            color: '#475569',
            border: '1px solid #cbd5e1',
          }}
        >
          <Clock style={{ width: '12px', height: '12px' }} />
          LOGOUT
        </span>
      );
    }
    return (
      <span
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '4px',
          padding: '2px 8px',
          borderRadius: '4px',
          fontSize: '11px',
          fontWeight: 600,
          background: '#eff6ff',
          color: '#2563eb',
          border: '1px solid #bfdbfe',
        }}
      >
        <Activity style={{ width: '12px', height: '12px' }} />
        {action}
      </span>
    );
  };

  const formatLogTime = (isoString: string) => {
    try {
      const d = new Date(isoString);
      return d.toLocaleString('id-ID', {
        day: 'numeric',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      });
    } catch {
      return isoString;
    }
  };

  return (
    <section className="m-card" style={{ marginTop: '24px' }}>
      <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
        <div>
          <h2 className="m-card__title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldCheck style={{ width: '18px', height: '18px', color: '#4272d7' }} />
            Log Aktivitas & Audit Login Admin
          </h2>
          <p className="m-card__subtitle">
            Pencatatan real-time riwayat otentikasi login, logout, dan operasi administratif.
          </p>
        </div>

        <button
          type="button"
          onClick={fetchLogs}
          disabled={isRefreshing}
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            height: '30px',
            padding: '0 12px',
            borderRadius: '6px',
            border: '1px solid #e2e8f0',
            background: '#ffffff',
            fontSize: '12px',
            fontWeight: 600,
            color: '#475569',
            cursor: 'pointer',
          }}
        >
          <RefreshCw
            style={{
              width: '13px',
              height: '13px',
              animation: isRefreshing ? 'spin 1s linear infinite' : 'none',
            }}
          />
          Segarkan Log
        </button>
      </header>

      <div style={{ overflowX: 'auto' }}>
        {isLoading ? (
          <div style={{ padding: '32px', textAlign: 'center', color: '#94a3b8', fontSize: '13px' }}>
            Memuat riwayat log audit admin...
          </div>
        ) : logs.length === 0 ? (
          <div style={{ padding: '36px 20px', textAlign: 'center', background: '#f8fafc', borderRadius: '8px' }}>
            <p style={{ margin: 0, fontSize: '13px', fontWeight: 600, color: '#475569' }}>
              Belum ada data log aktivitas admin.
            </p>
            <p style={{ margin: '6px 0 0 0', fontSize: '11.5px', color: '#94a3b8' }}>
              Pastikan script <code>supabase_admin_security_hardening.sql</code> telah dieksekusi di Supabase SQL Editor.
            </p>
          </div>
        ) : (
          <table
            style={{
              width: '100%',
              borderCollapse: 'collapse',
              fontSize: '12.5px',
              textAlign: 'left',
            }}
          >
            <thead>
              <tr style={{ borderBottom: '1px solid #e2e8f0', background: '#f8fafc', color: '#64748b' }}>
                <th style={{ padding: '10px 14px', fontWeight: 600 }}>Waktu</th>
                <th style={{ padding: '10px 14px', fontWeight: 600 }}>Administrator</th>
                <th style={{ padding: '10px 14px', fontWeight: 600 }}>Aksi</th>
                <th style={{ padding: '10px 14px', fontWeight: 600 }}>Keterangan / Target</th>
              </tr>
            </thead>
            <tbody>
              {logs.map((log) => (
                <tr key={log.id} style={{ borderBottom: '1px solid #f1f5f9' }}>
                  <td style={{ padding: '12px 14px', color: '#64748b', whiteSpace: 'nowrap', fontFamily: 'monospace' }}>
                    {formatLogTime(log.created_at)}
                  </td>
                  <td style={{ padding: '12px 14px', fontWeight: 600, color: '#1e293b' }}>
                    <span style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
                      <User style={{ width: '13px', height: '13px', color: '#94a3b8' }} />
                      {log.admin_email}
                    </span>
                  </td>
                  <td style={{ padding: '12px 14px' }}>{getActionBadge(log.action)}</td>
                  <td style={{ padding: '12px 14px', color: '#475569' }}>
                    {log.target_info || '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </section>
  );
}
