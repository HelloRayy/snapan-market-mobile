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
  const renderSparkline = () => {
    if (!sparklineData || sparklineData.length < 2) return null;
    const min = Math.min(...sparklineData);
    const max = Math.max(...sparklineData);
    const range = max - min || 1;
    const width = 88;
    const height = 28;

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
        className="overflow-visible shrink-0 text-[#3D38F5]/70"
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

  const iconBg = {
    indigo: 'bg-[#EEF0FF] text-[#3D38F5] ring-[#D8DBFE]',
    emerald: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
    amber: 'bg-amber-50 text-amber-700 ring-amber-200',
    blue: 'bg-blue-50 text-blue-700 ring-blue-200',
  }[badgeColor];

  return (
    <Card className="p-6 transition-all hover:ring-slate-300 group">
      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold uppercase tracking-wider text-slate-500">
          {title}
        </span>
        <div
          className={`flex h-9 w-9 items-center justify-center rounded-lg ring-1 ring-inset shadow-2xs transition-transform group-hover:scale-105 ${iconBg}`}
        >
          {icon}
        </div>
      </div>

      <div className="mt-4 flex items-baseline justify-between gap-2">
        <div>
          <div className="text-3xl font-semibold tracking-tight text-slate-900 tabular-nums">
            {value}
          </div>
          {(subtitle || trend) && (
            <div className="mt-2 flex items-center gap-2 text-xs text-slate-500">
              {trend && (
                <Badge variant={trendPositive ? 'emerald' : 'slate'} className="font-semibold">
                  {trendPositive ? (
                    <TrendingUp className="h-3 w-3 inline mr-0.5" />
                  ) : (
                    <TrendingDown className="h-3 w-3 inline mr-0.5" />
                  )}
                  {trend}
                </Badge>
              )}
              {subtitle && <span className="truncate">{subtitle}</span>}
            </div>
          )}
        </div>

        {renderSparkline()}
      </div>
    </Card>
  );
}
