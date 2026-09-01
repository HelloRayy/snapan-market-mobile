import React from 'react';
import { triggerHaptic } from '@/utils/haptics';

export type ProfileTabType = 'threads' | 'replies' | 'media';

interface ProfileTabNavigationProps {
  activeTab: ProfileTabType;
  onTabChange: (tab: ProfileTabType) => void;
  threadsCount: number;
  repliesCount: number;
}

export const ProfileTabNavigation: React.FC<ProfileTabNavigationProps> = ({
  activeTab,
  onTabChange,
  threadsCount: _threadsCount,
  repliesCount: _repliesCount,
}) => {
  const tabs: { key: ProfileTabType; label: string }[] = [
    { key: 'threads', label: 'Utas' },
    { key: 'replies', label: 'Balasan' },
    { key: 'media', label: 'Media' },
  ];

  return (
    <div className="flex items-center border-b border-neutral-200 bg-white sticky top-[50px] z-20 font-gt-standard select-none">
      {tabs.map((tab) => {
        const isActive = activeTab === tab.key;
        return (
          <button
            key={tab.key}
            type="button"
            onClick={() => {
              triggerHaptic('selection');
              onTabChange(tab.key);
            }}
            className={`flex-1 py-3 text-[14px] font-bold transition-colors relative flex items-center justify-center gap-1.5 cursor-pointer ${
              isActive ? 'text-slate-900' : 'text-neutral-400 hover:text-slate-600'
            }`}
          >
            <span>{tab.label}</span>
            {isActive && (
              <span className="absolute bottom-0 inset-x-0 h-0.5 bg-slate-900 rounded-full" />
            )}
          </button>
        );
      })}
    </div>
  );
};
