import React, { useState } from 'react';
import { ChevronRight, PartyPopper } from 'lucide-react';
import { ThreadsTopicIcon } from '@/ui/components/icons';
import { TopicOption, PRESET_TOPICS } from './types';

interface CreatePostTopicSelectorProps {
  selectedTopic: TopicOption | null;
  onSelectTopic: (topic: TopicOption | null) => void;
  showDropdown: boolean;
  onToggleDropdown: () => void;
  onCloseDropdown: () => void;
}

export const CreatePostTopicSelector: React.FC<CreatePostTopicSelectorProps> = ({
  selectedTopic,
  onSelectTopic,
  showDropdown,
  onToggleDropdown,
  onCloseDropdown,
}) => {
  const [customTopicInput, setCustomTopicInput] = useState('');

  const handleCustomTopicSubmit = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && customTopicInput.trim().length > 0) {
      e.preventDefault();
      const customTopic: TopicOption = {
        id: `custom-${Date.now()}`,
        name: customTopicInput.trim(),
        isOfficial: false,
      };
      onSelectTopic(customTopic);
      setCustomTopicInput('');
      onCloseDropdown();
    }
  };

  return (
    <div className="relative inline-flex items-center">
      <button
        type="button"
        onClick={onToggleDropdown}
        className="flex items-center gap-x-1 text-base h-[21px] leading-snug transition-all cursor-pointer select-none"
      >
        <span className="h-[21px] leading-snug flex items-center">
          <ChevronRight className="w-3.5 h-3.5 text-slate-400 stroke-[2] shrink-0" />
        </span>
        {selectedTopic ? (
          <span
            className={`flex items-center gap-x-1 font-semibold text-base h-[21px] leading-snug hover:opacity-80 transition-opacity ${
              selectedTopic.isOfficial ? 'text-[#1d64ec]' : 'text-slate-900'
            }`}
          >
            {selectedTopic.isOfficial &&
              (selectedTopic.icon === 'party-popper' ? (
                <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
              ) : (
                <ThreadsTopicIcon className="w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" />
              ))}
            <span className="leading-snug">{selectedTopic.name}</span>
          </span>
        ) : (
          <span className="text-slate-500 hover:text-slate-800 font-normal text-[14px] h-[21px] leading-snug flex items-center transition-colors">
            Komunitas atau topik
          </span>
        )}
      </button>

      {/* Dropdown Popover */}
      {showDropdown && (
        <>
          <div className="fixed inset-0 z-40" onClick={onCloseDropdown} />
          <div className="absolute top-full -right-6 sm:right-auto sm:left-0 mt-1.5 w-64 max-w-[calc(100vw-2rem)] bg-white rounded-2xl shadow-2xl border border-neutral-200/90 z-50 p-2 transform-gpu animate-in fade-in slide-in-from-top-2 duration-150 font-gt-standard">
            <div className="px-3 py-1.5 text-[11px] font-bold text-slate-500 uppercase tracking-wider">
              Topik Populer SMKN 8
            </div>

            <div className="space-y-0.5">
              {PRESET_TOPICS.map((topic) => (
                <button
                  key={topic.id}
                  type="button"
                  onClick={() => {
                    onSelectTopic(topic);
                    onCloseDropdown();
                  }}
                  className="w-full text-left px-3 py-2 rounded-xl hover:bg-neutral-100/90 transition-colors flex items-center justify-between group cursor-pointer"
                >
                  <div className="flex items-center gap-2 min-w-0">
                    {topic.isOfficial &&
                      (topic.icon === 'party-popper' ? (
                        <PartyPopper className="w-4 h-4 text-[#1d64ec] stroke-[2.2] shrink-0" />
                      ) : (
                        <ThreadsTopicIcon className="w-4 h-4 text-[#1d64ec] fill-current shrink-0" />
                      ))}
                    <div>
                      <div
                        className={`text-[14px] font-semibold ${
                          topic.isOfficial ? 'text-[#1d64ec]' : 'text-slate-900'
                        }`}
                      >
                        {topic.name}
                      </div>
                      {topic.subtitle && (
                        <div className="text-[11.5px] text-slate-500 font-normal truncate">
                          {topic.subtitle}
                        </div>
                      )}
                    </div>
                  </div>
                </button>
              ))}
            </div>

            {/* Custom Topic Input */}
            <div className="mt-2 pt-2 border-t border-neutral-100 px-2 space-y-1">
              <div className="relative flex items-center">
                <input
                  type="text"
                  maxLength={20}
                  placeholder="Ketik topik baru..."
                  value={customTopicInput}
                  onChange={(e) => setCustomTopicInput(e.target.value)}
                  onKeyDown={handleCustomTopicSubmit}
                  className="w-full pl-2.5 pr-11 py-1.5 text-[12.5px] rounded-lg border border-neutral-200 focus:outline-none focus:border-[#1d64ec] bg-neutral-50 text-slate-900"
                />
                <span className="absolute right-2 text-[10px] font-semibold text-slate-400 pointer-events-none tabular-nums">
                  {customTopicInput.length}/20
                </span>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
};
