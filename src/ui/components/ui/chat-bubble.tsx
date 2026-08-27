import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/utils/cn';

export const chatBubbleVariants = cva(
  'relative max-w-[85%] sm:max-w-[75%] px-3.5 py-2 text-[14.5px] leading-relaxed break-words shadow-2xs transition-all',
  {
    variants: {
      variant: {
        sent: 'ml-auto bg-[#1d64ec] text-white',
        received: 'mr-auto bg-[#f1f3f5] text-slate-900',
        system: 'mx-auto bg-neutral-100/90 text-neutral-500 text-[11.5px] font-medium text-center border border-neutral-200/60 rounded-full px-3 py-1 shadow-2xs',
      },
      shape: {
        single: 'rounded-[20px]',
        firstReceived: 'rounded-[20px] rounded-bl-[6px]',
        lastReceived: 'rounded-[20px] rounded-tl-[6px] rounded-bl-[4px]',
        firstSent: 'rounded-[20px] rounded-br-[6px]',
        lastSent: 'rounded-[20px] rounded-tr-[6px] rounded-br-[4px]',
      },
    },
    defaultVariants: {
      variant: 'received',
      shape: 'single',
    },
  }
);

export interface ChatBubbleProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof chatBubbleVariants> {}

export const ChatBubble = React.forwardRef<HTMLDivElement, ChatBubbleProps>(
  ({ className, variant, shape, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(chatBubbleVariants({ variant, shape, className }))}
      {...props}
    />
  )
);
ChatBubble.displayName = 'ChatBubble';

export const ChatBubbleMessage = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn('whitespace-pre-wrap leading-relaxed', className)}
    {...props}
  />
));
ChatBubbleMessage.displayName = 'ChatBubbleMessage';

export const ChatBubbleTimestamp = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement> & { statusIcon?: React.ReactNode }
>(({ className, children, statusIcon, ...props }, ref) => (
  <span
    ref={ref}
    className={cn(
      'flex items-center justify-end gap-1 mt-0.5 text-[10.5px] select-none opacity-85',
      className
    )}
    {...props}
  >
    {children}
    {statusIcon}
  </span>
));
ChatBubbleTimestamp.displayName = 'ChatBubbleTimestamp';

export const ChatBubbleAvatar = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & { src: string; alt?: string; isOnline?: boolean }
>(({ className, src, alt = 'Avatar', isOnline, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('relative shrink-0 w-8 h-8 rounded-full bg-neutral-100 ring-1 ring-neutral-200/80', className)}
    {...props}
  >
    <img src={src} alt={alt} className="w-8 h-8 rounded-full object-cover" />
    {isOnline && (
      <span className="absolute -bottom-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-[#31a24c] ring-2 ring-white" />
    )}
  </div>
));
ChatBubbleAvatar.displayName = 'ChatBubbleAvatar';
