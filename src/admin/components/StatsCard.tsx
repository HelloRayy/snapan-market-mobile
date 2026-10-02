import { useId } from 'react';

export type StatTileColor = 'c1' | 'c2' | 'c3' | 'c4';

interface StatsCardProps {
  title: string;
  value: number | string;
  subtitle?: string;
  iconClass: string;
  colorVariant?: StatTileColor;
  delta?: string;
  deltaPeriod?: string;
  deltaPositive?: boolean;
  sparklineData?: number[];
}

const colorMap: Record<StatTileColor, { accent: string; fillStart: string }> = {
  c1: { accent: '#4272d7', fillStart: 'rgba(66, 114, 215, 0.22)' },
  c2: { accent: '#11998e', fillStart: 'rgba(17, 153, 142, 0.22)' },
  c3: { accent: '#f97316', fillStart: 'rgba(249, 115, 22, 0.22)' },
  c4: { accent: '#ec4899', fillStart: 'rgba(236, 72, 153, 0.22)' },
};

const defaultSparklines: Record<StatTileColor, number[]> = {
  c1: [32, 36, 31, 40, 44, 41, 48, 46, 52, 49, 56, 60, 58, 64, 62, 68, 70, 65, 72, 75, 71, 78, 76, 82, 80, 86, 84, 90, 88, 95],
  c2: [55, 58, 62, 60, 65, 63, 68, 64, 70, 67, 71, 68, 73, 70, 76, 72, 78, 74, 79, 76, 81, 77, 80, 78, 76, 73, 70, 68, 66, 64],
  c3: [20, 22, 25, 24, 28, 30, 32, 31, 35, 38, 42, 40, 45, 48, 47, 52, 55, 54, 58, 62, 60, 65, 68, 72, 70, 75, 78, 82, 85, 88],
  c4: [40, 42, 39, 45, 48, 46, 50, 49, 55, 53, 58, 62, 60, 65, 63, 67, 69, 66, 70, 72, 71, 75, 74, 78, 77, 81, 80, 84, 83, 89],
};

export function StatsCard({
  title,
  value,
  iconClass,
  colorVariant = 'c1',
  delta = '12.5%',
  deltaPeriod = 'vs bulan lalu',
  deltaPositive = true,
  sparklineData,
}: StatsCardProps) {
  const gradientId = useId();
  const { accent, fillStart } = colorMap[colorVariant];
  const points = sparklineData && sparklineData.length >= 2 ? sparklineData : defaultSparklines[colorVariant];

  const min = Math.min(...points);
  const max = Math.max(...points);
  const range = max - min || 1;
  const width = 280;
  const height = 56;

  // Build SVG path
  const coords = points.map((val, idx) => {
    const x = (idx / (points.length - 1)) * width;
    const y = height - ((val - min) / range) * (height - 12) - 6;
    return { x, y };
  });

  const pathD = coords.reduce((acc, pt, i) => {
    return i === 0 ? `M ${pt.x},${pt.y}` : `${acc} L ${pt.x},${pt.y}`;
  }, '');

  const areaD = `${pathD} L ${width},${height} L 0,${height} Z`;

  return (
    <article className="stat-card">
      <div className="stat-card__head">
        <p className="stat-card__label">{title}</p>
        <span className={`stat-card__icon stat-card__icon--${colorVariant}`}>
          <i className={iconClass} aria-hidden="true"></i>
        </span>
      </div>
      <p className="stat-card__value">{value}</p>
      <p className={`stat-card__delta stat-card__delta--${deltaPositive ? 'up' : 'down'}`}>
        <i
          className={`fa-solid fa-arrow-${deltaPositive ? 'up' : 'down'}`}
          aria-hidden="true"
        ></i>
        {delta}
        <span className="stat-card__delta-period">{deltaPeriod}</span>
      </p>
      <div className="stat-card__sparkline">
        <svg
          viewBox={`0 0 ${width} ${height}`}
          preserveAspectRatio="none"
          style={{ width: '100%', height: '56px', display: 'block' }}
          aria-hidden="true"
        >
          <defs>
            <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={fillStart} />
              <stop offset="100%" stopColor="rgba(0, 0, 0, 0)" />
            </linearGradient>
          </defs>
          <path d={areaD} fill={`url(#${gradientId})`} />
          <path
            d={pathD}
            fill="none"
            stroke={accent}
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </div>
    </article>
  );
}
