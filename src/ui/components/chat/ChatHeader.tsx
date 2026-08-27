import React, { useState } from 'react';
import { ArrowLeft, MoreVertical, User, Trash2, ShieldAlert } from 'lucide-react';
import { ChatParticipant } from '@/types/chat';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { SubmenuDropdown, SubmenuDropdownItem } from '@/ui/components/ui/SubmenuDropdown';
import { triggerHaptic } from '@/utils/haptics';

interface ChatHeaderProps {
  participant: ChatParticipant;
  onBack: () => void;
  onViewProfile?: (username: string) => void;
  onClearChat?: () => void;
}

export const ChatHeader: React.FC<ChatHeaderProps> = ({
  participant,
  onBack,
  onViewProfile,
  onClearChat,
}) => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const handleBackClick = () => {
    triggerHaptic('light');
    onBack();
  };

  const handleProfileClick = () => {
    triggerHaptic('selection');
    if (onViewProfile) {
      onViewProfile(participant.username);
    } else {
      window.location.href = `/@${participant.username}`;
    }
  };

  const menuItems: SubmenuDropdownItem[] = [
    {
      id: 'profile',
      label: 'Lihat Profil',
      icon: User,
      onClick: handleProfileClick,
    },
    {
      id: 'report',
      label: 'Laporkan Pengguna',
      icon: ShieldAlert,
      onClick: () => {
        triggerHaptic('warning');
        alert(`Laporan terhadap @${participant.username} telah dikirim ke admin sekolah.`);
      },
    },
    {
      id: 'clear',
      label: 'Bersihkan Obrolan',
      icon: Trash2,
      danger: true,
      onClick: () => {
        triggerHaptic('warning');
        onClearChat?.();
      },
    },
  ];
  return (
    <header className="sticky top-0 inset-x-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-200/80 h-14 px-2 sm:px-4 flex items-center justify-between select-none">
      {/* Left: Back Button & User Info */}
      <div className="flex items-center gap-1.5 sm:gap-2.5 min-w-0 flex-1">
        <button
          type="button"
          onClick={handleBackClick}
          className="w-9 h-9 -ml-1 rounded-full hover:bg-neutral-100 active:bg-neutral-200/70 flex items-center justify-center text-slate-800 active:scale-90 transition-all cursor-pointer shrink-0"
          aria-label="Kembali ke Inbox"
        >
          <ArrowLeft className="w-5 h-5 stroke-[2.2]" />
        </button>

        {/* Clickable Header Profile Identity */}
        <div
          onClick={handleProfileClick}
          className="flex items-center gap-2.5 min-w-0 flex-1 cursor-pointer py-1 group"
        >
          {/* Avatar with live status dot */}
          <div className="relative shrink-0 w-9 h-9 rounded-full bg-neutral-100 ring-1 ring-neutral-200/80">
            <img
              src={participant.avatar}
              alt={participant.name}
              className="w-9 h-9 rounded-full object-cover"
            />
            {participant.isOnline && (
              <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full bg-[#31a24c] ring-2 ring-white" />
            )}
          </div>

          {/* Name & Status */}
          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-1">
              <h2 className="font-bold text-[14.5px] text-slate-900 truncate leading-tight group-hover:text-[#1d64ec] transition-colors">
                {participant.name}
              </h2>
              {participant.isVerified && (
                <ClickableVerifiedBadge
                  sellerName={participant.name}
                  className="w-3.5 h-3.5 shrink-0"
                />
              )}
            </div>
            <p className="text-[11.5px] text-neutral-500 font-normal truncate leading-tight mt-0.5">
              {participant.isOnline
                ? 'Aktif sekarang'
                : participant.lastSeen || participant.classGroup || `@${participant.username}`}
            </p>
          </div>
        </div>
      </div>

      {/* Right: 3-Dot More Actions Menu */}
      <div className="relative shrink-0 ml-1">
        <button
          type="button"
          onClick={() => {
            triggerHaptic('light');
            setIsMenuOpen((prev) => !prev);
          }}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 active:bg-neutral-200/70 flex items-center justify-center text-slate-700 active:scale-90 transition-all cursor-pointer"
          aria-label="Opsi Lainnya"
        >
          <MoreVertical className="w-5 h-5 stroke-[2]" />
        </button>

        <SubmenuDropdown
          isOpen={isMenuOpen}
          onClose={() => setIsMenuOpen(false)}
          items={menuItems}
          align="right"
        />
      </div>
    </header>
  );
};
