import React from 'react';
import { cn } from '@/utils/cn';

export interface TrackerBlock {
  key?: string | number;
  color?: 'emerald' | 'amber' | 'rose' | 'slate' | 'indigo';
  tooltip?: string;
}

interface TrackerProps extends React.HTMLAttributes<HTMLDivElement> {
  data: TrackerBlock[];
}

const colorMap = {
  emerald: 'bg-emerald-500 hover:bg-emerald-600',
  amber: 'bg-amber-500 hover:bg-amber-600',
  rose: 'bg-rose-500 hover:bg-rose-600',
  slate: 'bg-slate-200 hover:bg-slate-300',
  indigo: 'bg-[#3D38F5] hover:bg-[#312BD9]',
};

export function Tracker({ data, className, ...props }: TrackerProps) {
  return (
    <div
      className={cn('flex items-center gap-x-0.5 sm:gap-x-1 h-8 w-full', className)}
      {...props}
    >
      {data.map((item, idx) => (
        <div
          key={item.key ?? idx}
          title={item.tooltip}
          className={cn(
            'h-full flex-1 first:rounded-l-md last:rounded-r-md transition-colors cursor-default',
            colorMap[item.color || 'slate']
          )}
        />
      ))}
    </div>
  );
}
