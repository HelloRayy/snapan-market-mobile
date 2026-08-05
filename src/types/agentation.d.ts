declare module 'agentation' {
  import React from 'react';

  export interface AgentationProps {
    endpoint?: string;
    apiKey?: string;
  }

  export const Agentation: React.FC<AgentationProps>;
  export default Agentation;
}
