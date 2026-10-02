import React from 'react';
import { cn } from '@/utils/cn';

export function Table({
  className,
  children,
  ...props
}: React.TableHTMLAttributes<HTMLTableElement>) {
  return (
    <div className="w-full overflow-auto">
      <table
        className={cn('w-full text-left border-collapse caption-bottom text-xs', className)}
        {...props}
      >
        {children}
      </table>
    </div>
  );
}

export function TableHead({
  className,
  children,
  ...props
}: React.HTMLAttributes<HTMLTableSectionElement>) {
  return (
    <thead
      className={cn('border-b border-slate-200/80 bg-slate-50/75', className)}
      {...props}
    >
      {children}
    </thead>
  );
}

export function TableHeaderCell({
  className,
  children,
  ...props
}: React.ThHTMLAttributes<HTMLTableCellElement>) {
  return (
    <th
      className={cn(
        'px-4 py-3.5 text-left text-[11px] font-semibold uppercase tracking-wider text-slate-500 whitespace-nowrap',
        className
      )}
      {...props}
    >
      {children}
    </th>
  );
}

export function TableBody({
  className,
  children,
  ...props
}: React.HTMLAttributes<HTMLTableSectionElement>) {
  return (
    <tbody
      className={cn('divide-y divide-slate-100 bg-white', className)}
      {...props}
    >
      {children}
    </tbody>
  );
}

export function TableRow({
  className,
  children,
  ...props
}: React.HTMLAttributes<HTMLTableRowElement>) {
  return (
    <tr
      className={cn(
        'transition-colors hover:bg-slate-50/80',
        className
      )}
      {...props}
    >
      {children}
    </tr>
  );
}

export function TableCell({
  className,
  children,
  ...props
}: React.TdHTMLAttributes<HTMLTableCellElement>) {
  return (
    <td
      className={cn('px-4 py-3.5 align-middle text-slate-700 whitespace-nowrap', className)}
      {...props}
    >
      {children}
    </td>
  );
}
