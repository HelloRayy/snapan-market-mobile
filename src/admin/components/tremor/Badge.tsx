import React from 'react';
import { cn } from '@/utils/cn';

interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: 'emerald' | 'indigo' | 'amber' | 'rose' | 'slate' | 'blue' | 'purple';
}

const badgeVariants = {
  emerald: 'bg-emerald-50 text-emerald-700 ring-emerald-600/20',
  indigo: 'bg-[#EEF0FF] text-[#3D38F5] ring-[#D8DBFE]',
  amber: 'bg-amber-50 text-amber-700 ring-amber-600/20',
  rose: 'bg-rose-50 text-rose-700 ring-rose-600/20',
  slate: 'bg-slate-50 text-slate-700 ring-slate-500/20',
  blue: 'bg-blue-50 text-blue-700 ring-blue-600/20',
  purple: 'bg-purple-50 text-purple-700 ring-purple-600/20',
};

export function Badge({ variant = 'slate', className, children, ...props }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-x-1.5 rounded-md px-2 py-0.5 text-[11px] font-medium ring-1 ring-inset tracking-wide',
        badgeVariants[variant],
        className
      )}
      {...props}
    >
      {children}
    </span>
  );
}
