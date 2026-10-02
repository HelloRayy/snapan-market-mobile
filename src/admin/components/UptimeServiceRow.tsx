import { useState } from 'react';

export type UptimeStatus = 'operational' | 'degraded' | 'outage';

export interface DayBarData {
  dayIndex: number;
  dateStr: string;
  status: 'empty' | 'up' | 'degraded' | 'down';
  uptimePercent: number;
}

interface UptimeServiceRowProps {
  name: string;
  tooltipText?: string;
  currentStatus: UptimeStatus;
  uptimePercentage: number;
  hasExpandIcon?: boolean;
  bars: DayBarData[];
}

export function UptimeServiceRow({
  name,
  tooltipText,
  currentStatus,
  uptimePercentage,
  hasExpandIcon = false,
  bars,
}: UptimeServiceRowProps) {
  const [hoveredBar, setHoveredBar] = useState<DayBarData | null>(null);

  const statusLabel =
    currentStatus === 'operational'
      ? 'Operational'
      : currentStatus === 'degraded'
      ? 'Degraded Performance'
      : 'Major Outage';

  const statusColor =
    currentStatus === 'operational'
      ? '#10b981'
      : currentStatus === 'degraded'
      ? '#f59e0b'
      : '#ef4444';

  const getBarColor = (status: DayBarData['status']) => {
    switch (status) {
      case 'empty':
        return '#cbd5e1';
      case 'degraded':
        return '#f59e0b';
      case 'down':
        return '#ef4444';
      case 'up':
      default:
        return '#10b981';
    }
  };

  return (
    <div
      style={{
        padding: '18px 0',
        borderBottom: '1px solid #f1f5f9',
      }}
    >
      {/* Top Header: Service Name & Current Status */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          marginBottom: '10px',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          {hasExpandIcon && (
            <i
              className="fa-regular fa-square-plus"
              style={{ color: '#94a3b8', fontSize: '13px', cursor: 'pointer' }}
            ></i>
          )}
          <span style={{ fontSize: '14.5px', fontWeight: 600, color: '#1e293b' }}>
            {name}
          </span>
          {tooltipText && (
            <span
              title={tooltipText}
              style={{
                fontSize: '11px',
                color: '#94a3b8',
                cursor: 'help',
                background: '#f1f5f9',
                borderRadius: '50%',
                width: '16px',
                height: '16px',
                display: 'inline-flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 600,
              }}
            >
              ?
            </span>
          )}
        </div>

        <span
          style={{
            fontSize: '13px',
            fontWeight: 600,
            color: statusColor,
          }}
        >
          {statusLabel}
        </span>
      </div>

      {/* 90-Day Bar Chart */}
      <div style={{ position: 'relative' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '2px',
            height: '32px',
            padding: '2px 0',
          }}
        >
          {bars.map((bar) => (
            <div
              key={bar.dayIndex}
              onMouseEnter={() => setHoveredBar(bar)}
              onMouseLeave={() => setHoveredBar(null)}
              style={{
                flex: 1,
                height: '100%',
                maxHeight: '28px',
                background: getBarColor(bar.status),
                borderRadius: '1.5px',
                cursor: 'pointer',
                transition: 'opacity 120ms ease, transform 120ms ease',
                opacity: hoveredBar && hoveredBar.dayIndex !== bar.dayIndex ? 0.6 : 1,
                transform: hoveredBar?.dayIndex === bar.dayIndex ? 'scaleY(1.15)' : 'none',
              }}
            />
          ))}
        </div>

        {/* Hover Tooltip Overlay */}
        {hoveredBar && (
          <div
            style={{
              position: 'absolute',
              top: '-36px',
              left: `${Math.min(85, Math.max(15, (hoveredBar.dayIndex / bars.length) * 100))}%`,
              transform: 'translateX(-50%)',
              background: '#0f172a',
              color: '#ffffff',
              padding: '4px 8px',
              borderRadius: '4px',
              fontSize: '11px',
              whiteSpace: 'nowrap',
              boxShadow: '0 4px 12px rgba(0, 0, 0, 0.25)',
              zIndex: 10,
              pointerEvents: 'none',
            }}
          >
            {hoveredBar.dateStr}: {hoveredBar.uptimePercent}% Uptime (
            {hoveredBar.status === 'up'
              ? 'Normal'
              : hoveredBar.status === 'degraded'
              ? 'Latensi Tinggi'
              : hoveredBar.status === 'down'
              ? 'Insiden'
              : 'Tidak Ada Data'}
            )
          </div>
        )}
      </div>

      {/* Bottom Range and Percentage Legend */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          fontSize: '11.5px',
          color: '#64748b',
          marginTop: '8px',
        }}
      >
        <span style={{ whiteSpace: 'nowrap' }}>90 days ago</span>
        <div
          style={{
            flex: 1,
            height: '1px',
            background: '#e2e8f0',
            margin: '0 12px',
          }}
        />
        <span style={{ fontWeight: 600, color: '#334155', whiteSpace: 'nowrap' }}>
          {uptimePercentage.toFixed(2)} % uptime
        </span>
        <div
          style={{
            flex: 1,
            height: '1px',
            background: '#e2e8f0',
            margin: '0 12px',
          }}
        />
        <span style={{ whiteSpace: 'nowrap' }}>Today</span>
      </div>
    </div>
  );
}
