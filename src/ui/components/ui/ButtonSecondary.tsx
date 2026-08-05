import React from 'react';
import { Button, ButtonProps } from './Button';

export interface ButtonSecondaryProps extends Omit<ButtonProps, 'variant'> {}

export const ButtonSecondary = React.forwardRef<HTMLButtonElement, ButtonSecondaryProps>(
  (props, ref) => {
    return <Button ref={ref} variant="secondary" {...props} />;
  }
);

ButtonSecondary.displayName = 'ButtonSecondary';

export default ButtonSecondary;
