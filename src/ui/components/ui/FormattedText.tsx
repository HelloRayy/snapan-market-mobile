import React from 'react';

interface FormattedTextProps {
  text: string;
  className?: string;
  onMentionClick?: (username: string) => void;
  onHashtagClick?: (hashtag: string) => void;
}

/**
 * Formats text with:
 * 1. Paragraph chunking on \n\n with 8px space-y-2 vertical rhythm.
 * 2. Soft linebreaks on single \n (<br />).
 * 3. Mentions (@username), hashtags (#topic), and hyperlinks (https://...).
 * 4. Word wrapping [overflow-wrap:anywhere] & break-words for robust UX reading flow.
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

  // Helper to render formatted tokens within a single line
  const renderTokens = (content: string, lineKey: string | number) => {
    const parts = content.split(tokenRegex);

    return parts.map((part, index) => {
      if (!part) return null;
      const key = `${lineKey}-${index}`;

      // 1. @mention Tag (Brand Blue with Medium font-weight like WhatsApp/Threads)
      if (part.startsWith('@')) {
        const username = part.slice(1);
        return (
          <span
            key={key}
            onClick={(e) => {
              if (onMentionClick) {
                e.stopPropagation();
                onMentionClick(username);
              }
            }}
            className="font-medium text-[#1d64ec] hover:underline cursor-pointer select-text"
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
            key={key}
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

      // 3. Hyperlinks
      if (part.startsWith('http://') || part.startsWith('https://')) {
        return (
          <a
            key={key}
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

      // 4. Regular text segment
      return <React.Fragment key={key}>{part}</React.Fragment>;
    });
  };

  // Split by double newlines to form distinct paragraph chunks (\n\n+)
  const paragraphs = text.split(/\n\s*\n/);

  return (
    <div className={`space-y-2 leading-snug break-words [overflow-wrap:anywhere] ${className}`}>
      {paragraphs.map((paragraph, pIdx) => {
        // Within each paragraph, handle single newlines as soft linebreaks
        const lines = paragraph.split('\n');

        return (
          <p key={pIdx} className="leading-snug m-0">
            {lines.map((line, lIdx) => (
              <React.Fragment key={lIdx}>
                {lIdx > 0 && <br />}
                {renderTokens(line, `${pIdx}-${lIdx}`)}
              </React.Fragment>
            ))}
          </p>
        );
      })}
    </div>
  );
};
