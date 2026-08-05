import React from 'react';
import { Button, ButtonProps } from './Button';

export interface ButtonPrimaryProps extends Omit<ButtonProps, 'variant'> {}

export const ButtonPrimary = React.forwardRef<HTMLButtonElement, ButtonPrimaryProps>(
  (props, ref) => {
    return <Button ref={ref} variant="primary" {...props} />;
  }
);

ButtonPrimary.displayName = 'ButtonPrimary';

export default ButtonPrimary;
