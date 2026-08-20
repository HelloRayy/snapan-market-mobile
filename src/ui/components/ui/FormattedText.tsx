import React from 'react';

interface FormattedTextProps {
  text: string;
  className?: string;
  onMentionClick?: (username: string) => void;
  onHashtagClick?: (hashtag: string) => void;
}

/**
 * Formats mentions (@username), hashtags (#topic), and links in text
 * exactly like WhatsApp / Instagram / Threads UI with bold blue styling.
 */
export const FormattedText: React.FC<FormattedTextProps> = ({
  text,
  className = '',
  onMentionClick,
  onHashtagClick,
}) => {
  if (!text) return null;

  // Regex to match @mentions, #hashtags, and URLs
  const tokenRegex = /(@[\w.-]+|#[\w.-]+|https?:\/\/[^\s]+)/g;
  const parts = text.split(tokenRegex);

  return (
    <span className={className}>
      {parts.map((part, index) => {
        if (!part) return null;

        // 1. @mention Tag (Bold and Brand Blue like WhatsApp/Threads)
        if (part.startsWith('@')) {
          const username = part.slice(1);
          return (
            <span
              key={index}
              onClick={(e) => {
                if (onMentionClick) {
                  e.stopPropagation();
                  onMentionClick(username);
                }
              }}
              className="font-bold text-[#1d64ec] hover:underline cursor-pointer select-text"
            >
              {part}
            </span>
          );
        }

        // 2. #hashtag Tag
        if (part.startsWith('#')) {
          const tag = part.slice(1);
          return (
            <span
              key={index}
              onClick={(e) => {
                if (onHashtagClick) {
                  e.stopPropagation();
                  onHashtagClick(tag);
                }
              }}
              className="font-semibold text-[#1d64ec] hover:underline cursor-pointer select-text"
            >
              {part}
            </span>
          );
        }

        // 3. URLs
        if (part.startsWith('http://') || part.startsWith('https://')) {
          return (
            <a
              key={index}
              href={part}
              target="_blank"
              rel="noopener noreferrer"
              onClick={(e) => e.stopPropagation()}
              className="text-[#1d64ec] hover:underline break-all select-text"
            >
              {part}
            </a>
          );
        }

        // 4. Regular Text
        return <React.Fragment key={index}>{part}</React.Fragment>;
      })}
    </span>
  );
};
