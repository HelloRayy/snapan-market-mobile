import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/services/api/supabase';

interface LogEntry {
  id: string;
  timestamp: string;
  level: 'info' | 'success' | 'warn';
  service: 'DB' | 'AUTH' | 'REALTIME' | 'STORAGE';
  message: string;
}

interface ServerStatusCardProps {
  onNavigateDetails?: () => void;
}

export function ServerStatusCard({ onNavigateDetails }: ServerStatusCardProps = {}) {
  const [latencyMs, setLatencyMs] = useState<number | null>(null);
  const [isPinging, setIsPinging] = useState(false);
  const [dbStatus, setDbStatus] = useState<'online' | 'degraded' | 'offline'>('online');
  const [wsConnected, setWsConnected] = useState<boolean>(true);
  const [activeLogTab, setActiveLogTab] = useState<'all' | 'DB' | 'AUTH' | 'REALTIME'>('all');
  const [logs, setLogs] = useState<LogEntry[]>([]);

  // Measure real latency and subsystems health directly against Supabase
  const measurePing = useCallback(async () => {
    setIsPinging(true);
    const newLogs: LogEntry[] = [];
    const nowTime = new Date().toLocaleTimeString('id-ID');

    // 1. Database Ping (Exact Head Select)
    const dbStart = performance.now();
    try {
      const { count, error: dbErr } = await supabase
        .from('profiles')
        .select('id', { count: 'exact', head: true });
      const dbDuration = Math.round(performance.now() - dbStart);
      setLatencyMs(dbDuration);

      if (dbErr) {
        setDbStatus('degraded');
        newLogs.push({
          id: `db_${Date.now()}`,
          timestamp: nowTime,
          level: 'warn',
          service: 'DB',
          message: `Query database error: ${dbErr.message}`,
        });
      } else {
        const isDegraded = dbDuration > 350;
        setDbStatus(isDegraded ? 'degraded' : 'online');
        newLogs.push({
          id: `db_${Date.now()}`,
          timestamp: nowTime,
          level: isDegraded ? 'warn' : 'success',
          service: 'DB',
          message: `PostgreSQL query respon ${dbDuration}ms (200 OK, terdata ${count ?? 0} siswa).`,
        });
      }
    } catch (e: any) {
      setDbStatus('offline');
      setLatencyMs(null);
      newLogs.push({
        id: `db_${Date.now()}`,
        timestamp: nowTime,
        level: 'warn',
        service: 'DB',
        message: `Koneksi database offline: ${e?.message || 'Network timeout'}`,
      });
    }

    // 2. Auth Ping (GoTrue Session verification)
    const authStart = performance.now();
    try {
      const { data: sessionData, error: authErr } = await supabase.auth.getSession();
      const authDuration = Math.round(performance.now() - authStart);
      if (authErr) {
        newLogs.push({
          id: `auth_${Date.now()}`,
          timestamp: nowTime,
          level: 'warn',
          service: 'AUTH',
          message: `GoTrue auth ping gagal: ${authErr.message}`,
        });
      } else {
        newLogs.push({
          id: `auth_${Date.now()}`,
          timestamp: nowTime,
          level: 'success',
          service: 'AUTH',
          message: sessionData?.session
            ? `Admin session valid (${sessionData.session.user.email}) verifikasi ${authDuration}ms.`
            : `GoTrue auth service siap (${authDuration}ms).`,
        });
      }
    } catch {
      // ignore
    }

    // 3. Realtime WebSocket Ping
    try {
      const isConnected = supabase.realtime.isConnected();
      setWsConnected(isConnected);
      newLogs.push({
        id: `ws_${Date.now()}`,
        timestamp: nowTime,
        level: isConnected ? 'success' : 'info',
        service: 'REALTIME',
        message: isConnected
          ? 'WebSocket live subscription tersambung aktif (Realtime broadcast siap).'
          : 'WebSocket standby, siap menerima broadcast event.',
      });
    } catch {
      setWsConnected(false);
    }

    setLogs((prev) => [...newLogs, ...prev.slice(0, 15)]);
    setIsPinging(false);
  }, []);

  useEffect(() => {
    measurePing();
    const interval = setInterval(measurePing, 60 * 1000); // Auto ping every 60s
    return () => clearInterval(interval);
  }, [measurePing]);

  const filteredLogs = logs.filter(
    (l) => activeLogTab === 'all' || l.service === activeLogTab
  );

  return (
    <section className="m-card" style={{ marginTop: '16px' }}>
      <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
        <div>
          <h2 className="m-card__title">Status Server & Infrastruktur</h2>
          <p className="m-card__subtitle">
            Koneksi live Supabase cloud, respon latensi riil, dan log sistem.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '5px',
              padding: '3px 8px',
              borderRadius: '4px',
              background: dbStatus === 'online' ? '#e0f3f1' : '#fff1e6',
              color: dbStatus === 'online' ? '#11998e' : '#f97316',
              fontSize: '11px',
              fontWeight: 700,
            }}
          >
            <i className="fa-solid fa-circle" style={{ fontSize: '6px' }}></i>
            {dbStatus === 'online' ? 'LIVE' : dbStatus === 'degraded' ? 'DEGRADED' : 'OFFLINE'}
          </span>

          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={measurePing}
            disabled={isPinging}
            title="Ping ulang server Supabase"
            style={{ height: '30px', padding: '0 10px', fontSize: '11.5px' }}
          >
            <i
              className={`fa-solid fa-arrows-rotate ${isPinging ? 'fa-spin text-primary' : ''}`}
            ></i>
            <span>{isPinging ? 'Pinging...' : 'Ping'}</span>
          </button>
        </div>
      </header>

      {/* Latency and Subsystem Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2, 1fr)',
          gap: '8px',
          marginBottom: '16px',
        }}
      >
        {/* Latency Tile */}
        <div
          style={{
            padding: '10px 12px',
            background: '#f8fafc',
            border: '1px solid #e4e7ec',
            borderRadius: '6px',
          }}
        >
          <div style={{ fontSize: '11px', color: '#64748b', fontWeight: 500 }}>
            Latensi PostgreSQL (Riil)
          </div>
          <div
            style={{
              fontSize: '16px',
              fontWeight: 700,
              color: latencyMs && latencyMs < 250 ? '#10b981' : '#f97316',
              marginTop: '2px',
            }}
          >
            {latencyMs != null ? `${latencyMs} ms` : '-'}
          </div>
        </div>

        {/* Realtime WS Tile */}
        <div
          style={{
            padding: '10px 12px',
            background: '#f8fafc',
            border: '1px solid #e4e7ec',
            borderRadius: '6px',
          }}
        >
          <div style={{ fontSize: '11px', color: '#64748b', fontWeight: 500 }}>
            Realtime WebSocket
          </div>
          <div
            style={{
              fontSize: '14px',
              fontWeight: 700,
              color: wsConnected ? '#10b981' : '#4272d7',
              marginTop: '3px',
            }}
          >
            {wsConnected ? 'Connected (Live)' : 'Standby'}
          </div>
        </div>
      </div>

      {/* Log Header with Filter Pills */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '8px',
          paddingBottom: '6px',
          borderBottom: '1px solid #f1f3f5',
        }}
      >
        <span
          style={{
            fontSize: '11px',
            fontWeight: 700,
            textTransform: 'uppercase',
            letterSpacing: '0.05em',
            color: '#64748b',
          }}
        >
          Log Aktivitas Server (Live Telemetry)
        </span>

        <div style={{ display: 'flex', gap: '4px' }}>
          {(['all', 'DB', 'AUTH', 'REALTIME'] as const).map((tab) => (
            <button
              key={tab}
              type="button"
              onClick={() => setActiveLogTab(tab)}
              style={{
                fontSize: '10px',
                fontWeight: activeLogTab === tab ? 700 : 500,
                padding: '2px 6px',
                borderRadius: '3px',
                background: activeLogTab === tab ? '#4272d7' : '#f1f5f9',
                color: activeLogTab === tab ? '#ffffff' : '#64748b',
                border: 0,
                cursor: 'pointer',
              }}
            >
              {tab === 'all' ? 'Semua' : tab}
            </button>
          ))}
        </div>
      </div>

      {/* Terminal Log Console */}
      <div
        style={{
          background: '#f8fafc',
          border: '1px solid #e2e8f0',
          borderRadius: '6px',
          padding: '10px 12px',
          maxHeight: '180px',
          overflowY: 'auto',
          fontFamily: 'monospace',
          fontSize: '11px',
          color: '#334155',
          lineHeight: 1.6,
        }}
      >
        {filteredLogs.length === 0 ? (
          <div style={{ color: '#94a3b8', textAlign: 'center', padding: '12px 0' }}>
            {isPinging ? 'Sedang melakukan live ping...' : 'Tidak ada log untuk filter ini.'}
          </div>
        ) : (
          filteredLogs.map((log) => (
            <div
              key={log.id}
              style={{
                display: 'flex',
                alignItems: 'flex-start',
                gap: '8px',
                padding: '3px 0',
                borderBottom: '1px solid #f1f5f9',
              }}
            >
              <span style={{ color: '#94a3b8', flexShrink: 0 }}>{log.timestamp}</span>
              <span
                style={{
                  fontWeight: 700,
                  color:
                    log.service === 'DB'
                      ? '#2563eb'
                      : log.service === 'AUTH'
                      ? '#059669'
                      : log.service === 'REALTIME'
                      ? '#ea580c'
                      : '#9333ea',
                  flexShrink: 0,
                }}
              >
                [{log.service}]
              </span>
              <span style={{ color: log.level === 'warn' ? '#d97706' : '#334155', flex: 1 }}>
                {log.message}
              </span>
            </div>
          ))
        )}
      </div>

      {onNavigateDetails && (
        <div style={{ marginTop: '12px', textAlign: 'right' }}>
          <button
            type="button"
            className="m-btn m-btn--ghost"
            onClick={onNavigateDetails}
            style={{ fontSize: '11.5px', height: '30px', padding: '0 10px', gap: '6px' }}
          >
            <span>Monitor Server Penuh & Uptime</span>
            <i className="fa-solid fa-arrow-right"></i>
          </button>
        </div>
      )}
    </section>
  );
}
