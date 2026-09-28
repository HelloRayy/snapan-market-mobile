import React from 'react';
import { LayerCard } from '@cloudflare/kumo';

interface StatsCardProps {
  title: string;
  value: number | string;
  subtitle?: string;
  icon: React.ReactNode;
  trend?: string;
}

export function StatsCard({ title, value, subtitle, icon, trend }: StatsCardProps) {
  return (
    <LayerCard className="p-5 flex flex-col justify-between border border-kumo-hairline bg-kumo-canvas rounded-xl shadow-xs transition-shadow hover:shadow-sm">
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium uppercase tracking-wider text-kumo-subtle">
          {title}
        </span>
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-kumo-control text-kumo-default border border-kumo-hairline">
          {icon}
        </div>
      </div>
      <div className="mt-3">
        <div className="text-2xl font-bold tracking-tight text-kumo-default">
          {value}
        </div>
        {(subtitle || trend) && (
          <div className="mt-1 flex items-center gap-1.5 text-xs text-kumo-subtle">
            {trend && <span className="font-semibold text-emerald-600">{trend}</span>}
            {subtitle && <span>{subtitle}</span>}
          </div>
        )}
      </div>
    </LayerCard>
  );
}
