import React from 'react';
import { cn } from '@/utils/cn';

interface DividerProps extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
}

export function Divider({ children, className, ...props }: DividerProps) {
  if (!children) {
    return (
      <div
        className={cn('w-full border-t border-slate-200/80 my-4', className)}
        {...props}
      />
    );
  }

  return (
    <div
      className={cn('relative my-6 flex items-center justify-center text-xs', className)}
      {...props}
    >
      <div className="absolute inset-0 flex items-center">
        <div className="w-full border-t border-slate-200/80" />
      </div>
      <div className="relative bg-white px-3 text-[11px] font-semibold uppercase tracking-wider text-slate-400">
        {children}
      </div>
    </div>
  );
}
