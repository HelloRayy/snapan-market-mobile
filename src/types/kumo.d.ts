declare module '@cloudflare/kumo' {
  import React from 'react';

  export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'ghost' | 'outline' | 'danger';
    size?: 'sm' | 'md' | 'lg' | 'default';
    iconRight?: React.ReactNode;
    iconLeft?: React.ReactNode;
    isLoading?: boolean;
    asChild?: boolean;
    className?: string;
    children?: React.ReactNode;
  }

  export const Button: React.FC<ButtonProps>;
  export const KumoProvider: React.FC<{ children: React.ReactNode }>;
}
