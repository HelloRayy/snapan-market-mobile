import { useState, useMemo, useCallback, useRef, useEffect } from 'react';
import { UptimeServiceRow, type DayBarData } from '../components/UptimeServiceRow';
import { LiveConnectionProbes, type ProbeResult } from '../components/LiveConnectionProbes';

// Generate 90 days of realistic history data matching Image 1
function create90DayBars(pattern: 'compute' | 'analytics' | 'gateway' | 'auth' | 'db' | 'realtime'): DayBarData[] {
  const bars: DayBarData[] = [];
  const now = new Date();

  for (let i = 89; i >= 0; i--) {
    const d = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
    const dateStr = d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short' });
    const dayIndex = 89 - i;

    let status: 'empty' | 'up' | 'degraded' | 'down' = 'up';
    let uptime = 100;

    if (pattern === 'compute') {
      if (dayIndex < 28) {
        status = 'empty';
        uptime = 0;
      } else if (dayIndex === 55) {
        status = 'degraded';
        uptime = 98.4;
      }
    } else if (pattern === 'gateway') {
      if (dayIndex === 88) {
        status = 'degraded';
        uptime = 97.2;
      }
    } else if (pattern === 'auth') {
      if (dayIndex === 28) {
        status = 'degraded';
        uptime = 98.1;
      } else if (dayIndex === 74) {
        status = 'down';
        uptime = 95.0;
      }
    } else if (pattern === 'realtime') {
      if (dayIndex === 40) {
        status = 'degraded';
        uptime = 99.1;
      }
    }

    bars.push({
      dayIndex,
      dateStr,
      status,
      uptimePercent: uptime,
    });
  }

  return bars;
}

export function ServerMonitorTab() {
  const [activeLogCategory, setActiveLogCategory] = useState<'all' | 'db' | 'ws' | 'auth'>('all');
  const [probeLogs, setProbeLogs] = useState<
    Array<{ id: string; time: string; service: string; text: string; level: 'ok' | 'warn' | 'err' }>
  >([
    {
      id: '1',
      time: new Date(Date.now() - 40000).toLocaleTimeString('id-ID'),
      service: 'PostgreSQL',
      text: 'Query health check 200 OK. Respon tabel profiles diterima dalam 46ms.',
      level: 'ok',
    },
    {
      id: '2',
      time: new Date(Date.now() - 25000).toLocaleTimeString('id-ID'),
      service: 'Realtime',
      text: 'WebSocket channel subscription live broadcast aktif (TLS 1.3).',
      level: 'ok',
    },
    {
      id: '3',
      time: new Date(Date.now() - 10000).toLocaleTimeString('id-ID'),
      service: 'Auth',
      text: 'Verifikasi JWT token sesi admin berhasil via GoTrue API.',
      level: 'ok',
    },
  ]);

  const logsContainerRef = useRef<HTMLDivElement>(null);

  const computeBars = useMemo(() => create90DayBars('compute'), []);
  const analyticsBars = useMemo(() => create90DayBars('analytics'), []);
  const gatewayBars = useMemo(() => create90DayBars('gateway'), []);
  const authBars = useMemo(() => create90DayBars('auth'), []);
  const dbBars = useMemo(() => create90DayBars('db'), []);
  const realtimeBars = useMemo(() => create90DayBars('realtime'), []);

  const handleProbeComplete = useCallback((results: ProbeResult[]) => {
    const newLogs = results.map((r, idx) => ({
      id: `${Date.now()}_${idx}`,
      time: r.timestamp,
      service: r.service.split(' ')[0],
      text: `${r.service}: ${r.detail}`,
      level: (r.status === 'healthy' ? 'ok' : r.status === 'warning' ? 'warn' : 'err') as 'ok' | 'warn' | 'err',
    }));
    setProbeLogs((prev) => [...newLogs, ...prev.slice(0, 30)]);
  }, []);

  const filteredLogs = probeLogs.filter((l) => {
    if (activeLogCategory === 'all') return true;
    if (activeLogCategory === 'db') return l.service.toLowerCase().includes('postgre') || l.service.toLowerCase().includes('data');
    if (activeLogCategory === 'ws') return l.service.toLowerCase().includes('realtime');
    if (activeLogCategory === 'auth') return l.service.toLowerCase().includes('auth');
    return true;
  });

  // Automatically scroll to bottom when new logs arrive
  useEffect(() => {
    if (logsContainerRef.current) {
      logsContainerRef.current.scrollTop = logsContainerRef.current.scrollHeight;
    }
  }, [filteredLogs]);

  return (
    <>
      {/* 1. Page Header matching Image 1 */}
      <div className="page-header" style={{ marginBottom: '20px' }}>
        <div>
          <h1>Status Server & Infrastruktur</h1>
          <p className="subtitle">
            Pemantauan koneksi realtime, status komponen, dan catatan uptime SMKN 8 Semarang.
          </p>
        </div>
        <div className="page-header__actions">
          <div style={{ fontSize: '13px', color: '#64748b', textAlign: 'right' }}>
            <span>Uptime over the past 90 days. </span>
            <a
              href="#history"
              onClick={(e) => e.preventDefault()}
              style={{ color: '#10b981', fontWeight: 600, textDecoration: 'none' }}
            >
              View historical uptime.
            </a>
          </div>
        </div>
      </div>

      {/* 2. Overall Status Banner */}
      <div
        style={{
          background: '#f0fdf4',
          border: '1px solid #bbf7d0',
          borderRadius: '8px',
          padding: '16px 20px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '24px',
          flexWrap: 'wrap',
          gap: '12px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div
            style={{
              width: '12px',
              height: '12px',
              borderRadius: '50%',
              background: '#22c55e',
              boxShadow: '0 0 0 4px rgba(34, 197, 94, 0.2)',
            }}
          />
          <div>
            <div style={{ fontSize: '15px', fontWeight: 700, color: '#166534' }}>
              Semua Sistem Beroperasi Normal (All Systems Operational)
            </div>
            <div style={{ fontSize: '12px', color: '#15803d', marginTop: '2px' }}>
              Database PostgreSQL, Realtime WebSocket, dan Auth Engine terhubung tanpa gangguan.
            </div>
          </div>
        </div>

        <div style={{ fontSize: '12px', color: '#166534', fontWeight: 600 }}>
          SLA Uptime: 99.98%
        </div>
      </div>

      {/* 3. 90-Day Status Component Rows (Source of truth: Image 1) */}
      <section className="m-card" style={{ padding: '8px 24px 20px', marginBottom: '24px' }}>
        <UptimeServiceRow
          name="Compute capacity"
          currentStatus="operational"
          uptimePercentage={99.98}
          hasExpandIcon={true}
          bars={computeBars}
        />
        <UptimeServiceRow
          name="Database (PostgreSQL)"
          tooltipText="Supabase PostgreSQL cluster 15.x via Supavisor pooler"
          currentStatus="operational"
          uptimePercentage={99.99}
          bars={dbBars}
        />
        <UptimeServiceRow
          name="Realtime Engine (WebSockets)"
          tooltipText="Elixir Realtime server for instant thread & message syncing"
          currentStatus="operational"
          uptimePercentage={99.98}
          bars={realtimeBars}
        />
        <UptimeServiceRow
          name="Analytics"
          tooltipText="Telemetry and query performance insights"
          currentStatus="operational"
          uptimePercentage={100}
          bars={analyticsBars}
        />
        <UptimeServiceRow
          name="API Gateway"
          tooltipText="PostgREST automated HTTP REST API endpoints"
          currentStatus="degraded"
          uptimePercentage={100}
          bars={gatewayBars}
        />
        <UptimeServiceRow
          name="Auth"
          tooltipText="GoTrue authentication & session token service"
          currentStatus="operational"
          uptimePercentage={99.96}
          bars={authBars}
        />
      </section>

      {/* 4. Active Live Connection Probes Grid */}
      <LiveConnectionProbes onProbeComplete={handleProbeComplete} />

      {/* 5. Live System Activity & Probe Log Terminal */}
      <section className="m-card" style={{ marginTop: '24px' }}>
        <header className="m-card__header d-flex flex-wrap align-items-center justify-content-between">
          <div>
            <h2 className="m-card__title">Terminal Log Sistem Realtime</h2>
            <p className="m-card__subtitle">
              Riwayat inspeksi kesehatan server dan koneksi streaming Supabase.
            </p>
          </div>

          <div style={{ display: 'flex', gap: '6px' }}>
            {(
              [
                { id: 'all', label: 'Semua' },
                { id: 'db', label: 'Database' },
                { id: 'ws', label: 'Realtime' },
                { id: 'auth', label: 'Auth' },
              ] as const
            ).map((c) => (
              <button
                key={c.id}
                type="button"
                onClick={() => setActiveLogCategory(c.id)}
                style={{
                  height: '28px',
                  padding: '0 10px',
                  borderRadius: '4px',
                  border: 0,
                  fontSize: '11.5px',
                  fontWeight: 600,
                  cursor: 'pointer',
                  background: activeLogCategory === c.id ? '#4272d7' : '#f1f5f9',
                  color: activeLogCategory === c.id ? '#ffffff' : '#475569',
                }}
              >
                {c.label}
              </button>
            ))}
          </div>
        </header>

        <div
          ref={logsContainerRef}
          style={{
            background: '#f8fafc',
            border: '1px solid #e2e8f0',
            borderRadius: '8px',
            padding: '16px 18px',
            fontFamily: 'monospace',
            fontSize: '12px',
            color: '#334155',
            height: '360px',
            maxHeight: '420px',
            overflowY: 'auto',
            lineHeight: 1.6,
          }}
        >
          {filteredLogs.map((log) => (
            <div
              key={log.id}
              style={{
                display: 'flex',
                gap: '10px',
                padding: '5px 0',
                borderBottom: '1px solid #f1f5f9',
              }}
            >
              <span style={{ color: '#94a3b8', flexShrink: 0 }}>[{log.time}]</span>
              <span
                style={{
                  fontWeight: 700,
                  flexShrink: 0,
                  color:
                    log.service.toLowerCase().includes('postgre')
                      ? '#2563eb'
                      : log.service.toLowerCase().includes('realtime')
                      ? '#059669'
                      : log.service.toLowerCase().includes('auth')
                      ? '#d97706'
                      : '#7c3aed',
                }}
              >
                [{log.service.toUpperCase()}]
              </span>
              <span
                style={{
                  color: log.level === 'warn' ? '#d97706' : log.level === 'err' ? '#dc2626' : '#334155',
                  flex: 1,
                }}
              >
                {log.text}
              </span>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}
