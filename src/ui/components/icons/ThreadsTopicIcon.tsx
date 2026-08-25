import React from 'react';

/**
 * Custom Threads 3-Dot Topic Icon
 * Used across thread cards, create modals, and topic tags.
 */
export const ThreadsTopicIcon: React.FC<{ className?: string }> = ({
  className = "w-3.5 h-3.5 text-[#3d38f5] fill-current shrink-0",
}) => (
  <svg className={className} viewBox="0 0 24 24">
    <circle cx="6" cy="8" r="3" />
    <circle cx="6" cy="16" r="3" />
    <circle cx="15" cy="12" r="3" />
  </svg>
);
