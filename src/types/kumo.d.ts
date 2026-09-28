declare module '@cloudflare/kumo' {
  import React from 'react';

  export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'ghost' | 'outline' | 'danger' | 'destructive';
    size?: 'sm' | 'md' | 'lg' | 'default' | 'icon';
    iconRight?: React.ReactNode;
    iconLeft?: React.ReactNode;
    isLoading?: boolean;
    asChild?: boolean;
    className?: string;
    children?: React.ReactNode;
    disabled?: boolean;
    type?: 'button' | 'submit' | 'reset';
    onClick?: React.MouseEventHandler<HTMLButtonElement>;
  }
  export const Button: React.ForwardRefExoticComponent<ButtonProps>;

  export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
    variant?: 'primary' | 'secondary' | 'error' | 'warning' | 'success' | 'destructive' | 'info' | 'outline' | string;
    appearance?: 'filled' | 'dot' | 'outline';
    className?: string;
    children?: React.ReactNode;
  }
  export const Badge: React.FC<BadgeProps>;

  export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
    className?: string;
    error?: string | any;
    passwordManagerIgnore?: boolean;
  }
  export const Input: React.ForwardRefExoticComponent<InputProps>;

  export interface LayerCardProps extends React.HTMLAttributes<HTMLDivElement> {
    className?: string;
    children?: React.ReactNode;
  }
  export interface LayerCardComponent extends React.FC<LayerCardProps> {
    Primary?: React.FC<LayerCardProps>;
    Secondary?: React.FC<LayerCardProps>;
  }
  export const LayerCard: LayerCardComponent;

  export const Banner: React.FC<any>;
  export const Field: React.FC<any>;
  export const Label: React.FC<any>;
  export const Loader: React.FC<any>;
  export const KumoProvider: React.FC<{ children: React.ReactNode }>;
}
