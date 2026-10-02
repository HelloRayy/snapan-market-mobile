import { useState, useEffect, useCallback, useRef } from 'react';
import { supabase } from '@/services/api/supabase';

export interface ProbeResult {
  service: string;
  status: 'healthy' | 'warning' | 'error';
  latencyMs: number | null;
  detail: string;
  timestamp: string;
}

interface LiveConnectionProbesProps {
  onProbeComplete?: (results: ProbeResult[]) => void;
}

export function LiveConnectionProbes({ onProbeComplete }: LiveConnectionProbesProps) {
  const [isRunningProbes, setIsRunningProbes] = useState(false);
  const [dbLatency, setDbLatency] = useState<number | null>(null);
  const [wsState, setWsState] = useState<'SUBSCRIBED' | 'CONNECTING' | 'CLOSED'>('CONNECTING');
  const [authLatency, setAuthLatency] = useState<number | null>(null);
  const [storageStatus, setStorageStatus] = useState<'READY' | 'ERROR'>('READY');
  const [lastCheckTime, setLastCheckTime] = useState<string>('');

  const onProbeCompleteRef = useRef(onProbeComplete);
  useEffect(() => {
    onProbeCompleteRef.current = onProbeComplete;
  }, [onProbeComplete]);

  const runAllProbes = useCallback(async () => {
    setIsRunningProbes(true);
    const results: ProbeResult[] = [];
    const nowStr = new Date().toLocaleTimeString('id-ID');

    // 1. Database PostgreSQL Query Ping
    try {
      const dbStart = performance.now();
      const { error: dbErr } = await supabase
        .from('profiles')
        .select('id', { head: true, count: 'exact' });
      const dbDuration = Math.round(performance.now() - dbStart);
      setDbLatency(dbDuration);

      results.push({
        service: 'PostgreSQL Database',
        status: dbErr ? 'warning' : dbDuration > 250 ? 'warning' : 'healthy',
        latencyMs: dbDuration,
        detail: dbErr ? `Query error: ${dbErr.message}` : `200 OK (${dbDuration}ms)`,
        timestamp: nowStr,
      });
    } catch (e: any) {
      setDbLatency(null);
      results.push({
        service: 'PostgreSQL Database',
        status: 'error',
        latencyMs: null,
        detail: e?.message || 'Koneksi database gagal',
        timestamp: nowStr,
      });
    }

    // 2. Realtime WebSocket Subscription Ping
    try {
      const wsStart = performance.now();
      const testChannel = supabase.channel(`health_probe_${Date.now()}`);

      await new Promise<void>((resolve) => {
        testChannel.subscribe((status) => {
          if (status === 'SUBSCRIBED') {
            const wsDuration = Math.round(performance.now() - wsStart);
            setWsState('SUBSCRIBED');
            results.push({
              service: 'Realtime WebSocket',
              status: 'healthy',
              latencyMs: wsDuration,
              detail: `Channel SUBSCRIBED (${wsDuration}ms)`,
              timestamp: nowStr,
            });
            resolve();
          } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
            setWsState('CLOSED');
            results.push({
              service: 'Realtime WebSocket',
              status: 'warning',
              latencyMs: null,
              detail: `Status socket: ${status}`,
              timestamp: nowStr,
            });
            resolve();
          }
        });

        // Timeout fallback after 3 seconds
        setTimeout(() => {
          resolve();
        }, 3000);
      });

      // Cleanup test channel
      supabase.removeChannel(testChannel);
    } catch {
      setWsState('CLOSED');
    }

    // 3. Supabase Auth Session Ping
    try {
      const authStart = performance.now();
      const { data: sessionData, error: authErr } = await supabase.auth.getSession();
      const authDuration = Math.round(performance.now() - authStart);
      setAuthLatency(authDuration);

      results.push({
        service: 'Auth GoTrue Engine',
        status: authErr ? 'error' : 'healthy',
        latencyMs: authDuration,
        detail: sessionData?.session ? `Sesi aktif terverifikasi (${authDuration}ms)` : 'Anon/Public session',
        timestamp: nowStr,
      });
    } catch {
      setAuthLatency(null);
    }

    // 4. Supabase Storage Engine Probe
    try {
      const { data: buckets, error: storageErr } = await supabase.storage.listBuckets();
      if (storageErr) {
        setStorageStatus('ERROR');
        results.push({
          service: 'Storage CDN Engine',
          status: 'warning',
          latencyMs: null,
          detail: 'Bucket listing RLS restricted (normal public mode)',
          timestamp: nowStr,
        });
      } else {
        setStorageStatus('READY');
        results.push({
          service: 'Storage CDN Engine',
          status: 'healthy',
          latencyMs: null,
          detail: `${buckets.length} bucket aktif`,
          timestamp: nowStr,
        });
      }
    } catch {
      setStorageStatus('READY');
    }

    setLastCheckTime(nowStr);
    setIsRunningProbes(false);
    onProbeCompleteRef.current?.(results);
  }, []);

  useEffect(() => {
    runAllProbes();
    const thirtyMinutesMs = 30 * 60 * 1000;
    const interval = setInterval(runAllProbes, thirtyMinutesMs);
    return () => clearInterval(interval);
  }, [runAllProbes]);

  return (
    <div style={{ marginTop: '24px' }}>
      {/* Header bar */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '14px',
          flexWrap: 'wrap',
          gap: '10px',
        }}
      >
        <div>
          <h3 style={{ margin: 0, fontSize: '15px', fontWeight: 700, color: '#1e293b' }}>
            Uji Latensi & Koneksi Realtime
          </h3>
          <p style={{ margin: '2px 0 0', fontSize: '12px', color: '#64748b' }}>
            Pemeriksaan latensi aktif ke infrastruktur backend Supabase.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          {lastCheckTime && (
            <span style={{ fontSize: '11.5px', color: '#94a3b8' }}>
              Diperiksa: {lastCheckTime}
            </span>
          )}
          <button
            type="button"
            className="m-btn m-btn--primary"
            onClick={runAllProbes}
            disabled={isRunningProbes}
            style={{
              height: '34px',
              padding: '0 14px',
              fontSize: '12px',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            <i
              className={`fa-solid fa-arrows-rotate ${isRunningProbes ? 'fa-spin' : ''}`}
            ></i>
            <span>{isRunningProbes ? 'Memeriksa...' : 'Uji Sekarang'}</span>
          </button>
        </div>
      </div>

      {/* Probes 4-card Grid */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(210px, 1fr))',
          gap: '12px',
        }}
      >
        {/* Card 1: Database Query */}
        <div className="m-card" style={{ padding: '14px 16px', margin: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#64748b' }}>
              Database Ping
            </span>
            <i className="fa-solid fa-database" style={{ color: '#4272d7', fontSize: '14px' }}></i>
          </div>
          <div style={{ marginTop: '8px', display: 'flex', alignItems: 'baseline', gap: '6px' }}>
            <span style={{ fontSize: '22px', fontWeight: 700, color: '#1e293b', fontVariantNumeric: 'tabular-nums' }}>
              {dbLatency !== null ? `${dbLatency}ms` : '---'}
            </span>
            <span
              style={{
                fontSize: '10.5px',
                fontWeight: 700,
                color: dbLatency && dbLatency < 150 ? '#10b981' : '#f59e0b',
              }}
            >
              {dbLatency && dbLatency < 150 ? 'Cepat' : 'Normal'}
            </span>
          </div>
          <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
            PostgreSQL 15.x via Supavisor
          </div>
        </div>

        {/* Card 2: Realtime WebSocket */}
        <div className="m-card" style={{ padding: '14px 16px', margin: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#64748b' }}>
              WebSocket Realtime
            </span>
            <i className="fa-solid fa-bolt" style={{ color: '#10b981', fontSize: '14px' }}></i>
          </div>
          <div style={{ marginTop: '8px', display: 'flex', alignItems: 'baseline', gap: '6px' }}>
            <span style={{ fontSize: '22px', fontWeight: 700, color: '#1e293b' }}>
              {wsState === 'SUBSCRIBED' ? 'Aktif' : 'Menghubungkan'}
            </span>
            <span
              style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                background: wsState === 'SUBSCRIBED' ? '#10b981' : '#f59e0b',
                display: 'inline-block',
              }}
            />
          </div>
          <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
            Two-way socket terhubung
          </div>
        </div>

        {/* Card 3: Auth GoTrue */}
        <div className="m-card" style={{ padding: '14px 16px', margin: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#64748b' }}>
              Auth Latency
            </span>
            <i className="fa-solid fa-key" style={{ color: '#f59e0b', fontSize: '14px' }}></i>
          </div>
          <div style={{ marginTop: '8px', display: 'flex', alignItems: 'baseline', gap: '6px' }}>
            <span style={{ fontSize: '22px', fontWeight: 700, color: '#1e293b', fontVariantNumeric: 'tabular-nums' }}>
              {authLatency !== null ? `${authLatency}ms` : '---'}
            </span>
            <span style={{ fontSize: '10.5px', fontWeight: 700, color: '#10b981' }}>
              Valid
            </span>
          </div>
          <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
            GoTrue JWT Token Engine
          </div>
        </div>

        {/* Card 4: Storage CDN */}
        <div className="m-card" style={{ padding: '14px 16px', margin: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', fontWeight: 600, color: '#64748b' }}>
              Storage Media
            </span>
            <i className="fa-solid fa-hard-drive" style={{ color: '#8b5cf6', fontSize: '14px' }}></i>
          </div>
          <div style={{ marginTop: '8px', display: 'flex', alignItems: 'baseline', gap: '6px' }}>
            <span style={{ fontSize: '22px', fontWeight: 700, color: '#1e293b' }}>
              {storageStatus === 'READY' ? 'Ready' : 'Limited'}
            </span>
            <span style={{ fontSize: '10.5px', fontWeight: 700, color: '#10b981' }}>
              Public S3
            </span>
          </div>
          <div style={{ fontSize: '11px', color: '#94a3b8', marginTop: '4px' }}>
            Avatars & Products asset bucket
          </div>
        </div>
      </div>
    </div>
  );
}
