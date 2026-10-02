import React from 'react';
import { Card } from './tremor/Card';
import { Badge } from './tremor/Badge';
import { TrendingUp, TrendingDown } from 'lucide-react';

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
  const iconBg = {
    indigo: 'bg-[#EEF0FF] text-[#3D38F5] ring-[#D8DBFE]',
    emerald: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
    amber: 'bg-amber-50 text-amber-700 ring-amber-200',
    blue: 'bg-blue-50 text-blue-700 ring-blue-200',
  }[badgeColor];

  const renderSparkline = () => {
    if (!sparklineData || sparklineData.length < 2) return null;
    const min = Math.min(...sparklineData);
    const max = Math.max(...sparklineData);
    const range = max - min || 1;
    const width = 64;
    const height = 24;

    const points = sparklineData.map((val, idx) => {
      const x = (idx / (sparklineData.length - 1)) * width;
      const y = height - ((val - min) / range) * (height - 4) - 2;
      return `${x.toFixed(1)},${y.toFixed(1)}`;
    });

    const pathD = `M ${points.join(' L ')}`;

    return (
      <svg
        width={width}
        height={height}
        className="overflow-visible shrink-0 text-[#3D38F5]/60"
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

  return (
    <Card className="p-5 transition-all hover:ring-slate-300">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3.5 min-w-0">
          <div
            className={`flex h-12 w-12 items-center justify-center rounded-xl ring-1 ring-inset shrink-0 shadow-2xs ${iconBg}`}
          >
            {icon}
          </div>
          <div className="min-w-0">
            <span className="text-[10.5px] font-bold uppercase tracking-wider text-slate-400 truncate block">
              {title}
            </span>
            <div className="text-2xl font-bold tracking-tight text-slate-900 tabular-nums">
              {value}
            </div>
          </div>
        </div>

        {renderSparkline()}
      </div>

      {(subtitle || trend) && (
        <div className="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between text-xs text-slate-500">
          <span className="truncate text-[11.5px]">{subtitle}</span>
          {trend && (
            <Badge variant={trendPositive ? 'emerald' : 'slate'} className="font-semibold shrink-0 text-[10px]">
              {trendPositive ? (
                <TrendingUp className="h-3 w-3 inline mr-0.5" />
              ) : (
                <TrendingDown className="h-3 w-3 inline mr-0.5" />
              )}
              {trend}
            </Badge>
          )}
        </div>
      )}
    </Card>
  );
}
