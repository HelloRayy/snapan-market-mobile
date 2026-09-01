import React from 'react';
import { UserPlus, UserCheck, MessageCircle } from 'lucide-react';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { triggerHaptic } from '@/utils/haptics';

export interface ProfileHeaderData {
  name: string;
  username: string;
  avatar: string;
  bio: string;
  classGroup: string;
  tags: string[];
  followersCount: number;
  soldCount: number;
  rating: number;
  isVerified: boolean;
}

interface ProfileHeaderCardProps {
  profileData: ProfileHeaderData;
  isOwnProfile: boolean;
  isFollowing: boolean;
  onToggleFollow: () => void;
  onOpenEdit: () => void;
  onOpenSettings: () => void;
  onDirectMessage: () => void;
}

export const ProfileHeaderCard: React.FC<ProfileHeaderCardProps> = ({
  profileData,
  isOwnProfile,
  isFollowing,
  onToggleFollow,
  onOpenEdit,
  onOpenSettings: _onOpenSettings,
  onDirectMessage,
}) => {
  const handleShareProfile = async () => {
    triggerHaptic('light');
    const shareUrl = `${window.location.origin}/@${profileData.username}`;
    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({
          title: `Profil ${profileData.name} di Snapan Market`,
          text: `Cek profil @${profileData.username} di Snapan Market!`,
          url: shareUrl,
        });
      } catch {}
    } else {
      try {
        await navigator.clipboard.writeText(shareUrl);
        alert('Tautan profil berhasil disalin ke papan klip!');
      } catch {}
    }
  };

  return (
    <div className="px-4 pt-3 pb-2 space-y-3 font-gt-standard select-none">
      {/* 1. Profile Top Section: Full Name + Username + Avatar */}
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-1.5 flex-wrap">
            <h1 className="text-xl font-bold text-slate-900 tracking-tight leading-tight">
              {profileData.name}
            </h1>
            {profileData.isVerified && (
              <ClickableVerifiedBadge
                sellerName={profileData.name}
                className="w-4 h-4 shrink-0"
              />
            )}
          </div>
          <p className="text-[13.5px] text-slate-500 font-medium tracking-tight mt-0.5">
            @{profileData.username}
          </p>
        </div>

        {/* Avatar */}
        <div className="w-16 h-16 rounded-full overflow-hidden border-2 border-white shadow-xs shrink-0 bg-neutral-100">
          <img
            src={profileData.avatar}
            alt={profileData.name}
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      {/* 2. Bio & Class Badge */}
      <div className="space-y-1.5">
        <p className="text-[14px] text-slate-700 leading-relaxed font-normal">
          {profileData.bio}
        </p>

        <div className="flex items-center gap-2 flex-wrap pt-0.5">
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[11.5px] font-semibold bg-neutral-100 text-slate-700 border border-neutral-200/80">
            {profileData.classGroup}
          </span>
          <span className="text-[12.5px] text-slate-500 font-normal tabular-nums">
            <strong className="font-semibold text-slate-900">{profileData.followersCount}</strong> pengikut
          </span>
          <span className="text-slate-300">•</span>
          <span className="text-[12.5px] text-slate-500 font-normal tabular-nums">
            <strong className="font-semibold text-slate-900">{profileData.soldCount}</strong> terjual
          </span>
        </div>
      </div>

      {/* 3. Action Buttons */}
      <div className="flex items-center gap-2 pt-1">
        {isOwnProfile ? (
          <>
            <button
              type="button"
              onClick={onOpenEdit}
              className="flex-1 h-9 px-4 rounded-xl text-[13.5px] font-bold text-slate-900 bg-white border border-neutral-200/90 shadow-2xs hover:bg-neutral-50 active:scale-[0.98] transition-transform flex items-center justify-center cursor-pointer"
            >
              Edit Profil
            </button>
            <button
              type="button"
              onClick={handleShareProfile}
              className="flex-1 h-9 px-4 rounded-xl text-[13.5px] font-bold text-slate-900 bg-white border border-neutral-200/90 shadow-2xs hover:bg-neutral-50 active:scale-[0.98] transition-transform flex items-center justify-center cursor-pointer"
            >
              Bagikan Profil
            </button>
          </>
        ) : (
          <>
            <button
              type="button"
              onClick={onToggleFollow}
              className={`flex-1 h-9 px-4 rounded-xl text-[13.5px] font-bold flex items-center justify-center gap-1.5 transition-all cursor-pointer ${
                isFollowing
                  ? 'bg-neutral-100 text-slate-700 border border-neutral-200'
                  : 'bg-black text-white hover:bg-neutral-900 shadow-2xs'
              }`}
            >
              {isFollowing ? (
                <>
                  <UserCheck className="w-4 h-4 stroke-[2.2]" />
                  <span>Mengikuti</span>
                </>
              ) : (
                <>
                  <UserPlus className="w-4 h-4 stroke-[2.2]" />
                  <span>Ikuti</span>
                </>
              )}
            </button>
            <button
              type="button"
              onClick={onDirectMessage}
              className="h-9 px-3.5 rounded-xl text-[13.5px] font-bold text-slate-900 bg-white border border-neutral-200/90 shadow-2xs hover:bg-neutral-50 active:scale-[0.98] transition-transform flex items-center justify-center gap-1.5 cursor-pointer"
            >
              <MessageCircle className="w-4 h-4 stroke-[2]" />
              <span>Pesan</span>
            </button>
          </>
        )}
      </div>
    </div>
  );
};
