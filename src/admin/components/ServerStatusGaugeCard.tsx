interface ServerStatusGaugeCardProps {
  uptimePercentage?: number;
  statusText?: 'Live' | 'Success' | 'Degraded' | 'Offline';
  statusLabel?: string;
  latencyMs?: number | null;
  isChecking?: boolean;
  lastCheckedTime?: string;
  onClick?: () => void;
}

export function ServerStatusGaugeCard({
  uptimePercentage = 100,
  statusText = 'Live',
  statusLabel,
  latencyMs,
  isChecking = false,
  lastCheckedTime,
  onClick,
}: ServerStatusGaugeCardProps) {
  const radius = 32;
  const strokeWidth = 5;
  const circumference = 2 * Math.PI * radius;
  const clampedPercent = Math.min(100, Math.max(0, uptimePercentage));
  const strokeDashoffset = circumference - (clampedPercent / 100) * circumference;

  const isLive = statusText === 'Live' || statusText === 'Success';
  const isDegraded = statusText === 'Degraded';
  const statusColor = isChecking
    ? '#3b82f6'
    : isLive
    ? '#10b981'
    : isDegraded
    ? '#f59e0b'
    : '#ef4444';

  const headline =
    statusLabel ||
    (isChecking
      ? 'Mengukur Ping...'
      : isLive
      ? 'Sistem Normal'
      : isDegraded
      ? 'Latensi Tinggi'
      : 'Koneksi Terputus');

  return (
    <article
      className="stat-card"
      onClick={onClick}
      style={{
        cursor: onClick ? 'pointer' : 'default',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'space-between',
        height: '100%',
        transition: 'transform 120ms ease, box-shadow 120ms ease',
      }}
      title="Klik untuk melihat status monitor server lengkap"
    >
      {/* Head */}
      <div className="stat-card__head" style={{ marginBottom: '8px' }}>
        <p className="stat-card__label">Status Server</p>
        <span className="stat-card__icon stat-card__icon--c2">
          <i
            className={`fa-solid ${isChecking ? 'fa-arrows-rotate fa-spin' : 'fa-server'}`}
            aria-hidden="true"
          ></i>
        </span>
      </div>

      {/* Center Body with Circular Ring Gauge */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          flex: 1,
          padding: '2px 0 6px',
        }}
      >
        {/* Circular Progress Gauge (Stroke Only, Hollow Center) */}
        <div
          style={{
            position: 'relative',
            width: '74px',
            height: '74px',
            flexShrink: 0,
          }}
        >
          <svg
            width="74"
            height="74"
            viewBox="0 0 74 74"
            style={{ transform: 'rotate(-90deg)', display: 'block' }}
            aria-hidden="true"
          >
            {/* Background Track Circle */}
            <circle
              cx="37"
              cy="37"
              r={radius}
              fill="none"
              stroke="#e2e8f0"
              strokeWidth={strokeWidth}
            />
            {/* Progress Stroke Ring */}
            <circle
              cx="37"
              cy="37"
              r={radius}
              fill="none"
              stroke={statusColor}
              strokeWidth={strokeWidth}
              strokeDasharray={circumference}
              strokeDashoffset={strokeDashoffset}
              strokeLinecap="round"
            />
          </svg>

          {/* Center Content Inside Ring */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              textAlign: 'center',
              lineHeight: 1.15,
            }}
          >
            <span
              style={{
                fontSize: isChecking ? '11px' : '13.5px',
                fontWeight: 700,
                color: '#1e293b',
                fontVariantNumeric: 'tabular-nums',
                letterSpacing: '-0.02em',
              }}
            >
              {isChecking ? 'Ping...' : `${clampedPercent.toFixed(0)}%`}
            </span>
            <span
              style={{
                fontSize: '9.5px',
                fontWeight: 700,
                color: statusColor,
                display: 'inline-flex',
                alignItems: 'center',
                gap: '3px',
                marginTop: '1px',
              }}
            >
              <span
                style={{
                  width: '5px',
                  height: '5px',
                  borderRadius: '50%',
                  background: statusColor,
                  display: 'inline-block',
                }}
              />
              {isChecking ? 'Wait' : statusText}
            </span>
          </div>
        </div>

        {/* Right Info Details */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              fontSize: '13px',
              fontWeight: 700,
              color: '#1e293b',
              lineHeight: 1.2,
            }}
          >
            {headline}
          </div>
          <div
            style={{
              fontSize: '11px',
              color: '#64748b',
              marginTop: '3px',
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {isChecking
              ? 'Mengukur latensi...'
              : latencyMs != null
              ? `Latensi ~${latencyMs}ms`
              : 'Gagal terhubung'}
          </div>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '4px',
              fontSize: '11px',
              color: statusColor,
              fontWeight: 600,
              marginTop: '4px',
            }}
          >
            <i
              className={`fa-solid ${
                isChecking
                  ? 'fa-arrows-rotate fa-spin'
                  : isLive
                  ? 'fa-circle-check'
                  : isDegraded
                  ? 'fa-triangle-exclamation'
                  : 'fa-circle-xmark'
              }`}
              style={{ fontSize: '9.5px' }}
            ></i>
            <span>
              {isChecking
                ? 'Pinging DB'
                : isLive
                ? 'Database Online'
                : isDegraded
                ? 'Degraded'
                : 'Offline'}
            </span>
          </div>
        </div>
      </div>

      {/* Card Footer Subtext */}
      <div
        style={{
          borderTop: '1px solid #f1f5f9',
          paddingTop: '6px',
          marginTop: '4px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          fontSize: '10.5px',
        }}
      >
        <span style={{ color: '#94a3b8' }}>
          {lastCheckedTime ? `Cek: ${lastCheckedTime}` : 'Supabase Cloud'}
        </span>
        <span style={{ color: '#4272d7', fontWeight: 600 }}>Detail &rarr;</span>
      </div>
    </article>
  );
}
