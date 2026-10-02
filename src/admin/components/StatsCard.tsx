import React from 'react';

interface StatsCardProps {
  title: string;
  value: number | string;
  subtitle?: string;
  icon: React.ReactNode;
  trend?: string;
  trendPositive?: boolean;
  sparklineData?: number[];
  badgeColor?: 'indigo' | 'emerald' | 'amber' | 'blue';
}

export function StatsCard({
  title,
  value,
  subtitle,
  icon,
  trend,
  trendPositive = true,
  sparklineData,
  badgeColor = 'indigo',
}: StatsCardProps) {
  // Generate simple SVG sparkline path if data provided
  const renderSparkline = () => {
    if (!sparklineData || sparklineData.length < 2) return null;
    const min = Math.min(...sparklineData);
    const max = Math.max(...sparklineData);
    const range = max - min || 1;
    const width = 84;
    const height = 24;

    const points = sparklineData.map((val, idx) => {
      const x = (idx / (sparklineData.length - 1)) * width;
      const y = height - ((val - min) / range) * (height - 6) - 3;
      return `${x.toFixed(1)},${y.toFixed(1)}`;
    });

    const pathD = `M ${points.join(' L ')}`;

    return (
      <svg
        width={width}
        height={height}
        className="overflow-visible shrink-0 text-indigo-500/80"
        aria-hidden="true"
      >
        <path
          d={pathD}
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    );
  };

  const badgeBg = {
    indigo: 'bg-[#EEF0FF] text-[#3D38F5] border-[#D8DBFE]',
    emerald: 'bg-emerald-50 text-emerald-600 border-emerald-200',
    amber: 'bg-amber-50 text-amber-600 border-amber-200',
    blue: 'bg-blue-50 text-blue-600 border-blue-200',
  }[badgeColor];

  return (
    <div className="p-5 flex flex-col justify-between border border-slate-200/80 bg-white rounded-2xl shadow-[0_1px_3px_rgba(0,0,0,0.03)] hover:shadow-[0_4px_12px_rgba(0,0,0,0.05)] transition-all group">
      <div className="flex items-center justify-between">
        <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-500">
          {title}
        </span>
        <div
          className={`flex h-9 w-9 items-center justify-center rounded-xl border shadow-2xs transition-transform group-hover:scale-105 ${badgeBg}`}
        >
          {icon}
        </div>
      </div>

      <div className="mt-4 flex items-end justify-between gap-2">
        <div>
          <div className="text-2xl font-bold tracking-tight text-slate-900 tabular-nums">
            {value}
          </div>
          {(subtitle || trend) && (
            <div className="mt-1 flex items-center gap-1.5 text-xs text-slate-500">
              {trend && (
                <span
                  className={`inline-flex items-center px-1.5 py-0.5 rounded-full text-[10px] font-semibold border ${
                    trendPositive
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                      : 'bg-slate-100 text-slate-700 border-slate-200'
                  }`}
                >
                  {trend}
                </span>
              )}
              {subtitle && <span className="truncate">{subtitle}</span>}
            </div>
          )}
        </div>

        {renderSparkline()}
      </div>
    </div>
  );
}
