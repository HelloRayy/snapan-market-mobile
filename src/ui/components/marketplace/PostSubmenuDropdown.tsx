import React, { useState, useCallback, useMemo } from 'react';
import {
  Bookmark,
  BookmarkCheck,
  Copy,
  BellOff,
  EyeOff,
  Flag,
  Trash2,
  Edit3,
  UserX,
} from 'lucide-react';
import { SubmenuDropdown, SubmenuDropdownItem } from '@/ui/components/ui/SubmenuDropdown';
import { ConfirmActionModal } from '@/ui/components/ui/ConfirmActionModal';
import { ToastNotification } from '@/ui/components/ui/ToastNotification';

export interface PostSubmenuDropdownProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  authorName: string;
  authorUsername?: string;
  isSaved?: boolean;
  onToggleSave?: () => void | Promise<void>;
  onCopyLink?: () => void | Promise<void>;
  onMute?: () => void;
  onHide?: () => void;
  onReport?: () => void;
  isOwner?: boolean;
  onDelete?: () => void | Promise<void>;
  onEdit?: () => void;
  align?: 'left' | 'right';
  placement?: 'auto' | 'top' | 'bottom';
  className?: string;
  triggerRef?: React.RefObject<HTMLElement | null>;
  menuId?: string;
  triggerId?: string;
}

export const PostSubmenuDropdownComponent: React.FC<PostSubmenuDropdownProps> = ({
  isOpen,
  onClose,
  title = 'Opsi Postingan',
  authorName,
  authorUsername,
  isSaved = false,
  onToggleSave,
  onCopyLink,
  onMute,
  onHide,
  onReport,
  isOwner = false,
  onDelete,
  onEdit,
  align = 'right',
  placement = 'auto',
  className = '',
  triggerRef,
  menuId,
  triggerId,
}) => {
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const showToast = useCallback((msg: string) => {
    setToastMessage(msg);
  }, []);

  const handleCopyLink = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    if (onCopyLink) {
      onCopyLink();
    } else {
      navigator.clipboard?.writeText(window.location.href);
      showToast('Tautan berhasil disalin ke papan klip');
    }
  }, [onCopyLink, showToast]);

  const handleToggleSave = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    onToggleSave?.();
    showToast(isSaved ? 'Dihapus dari markah' : 'Disimpan ke markah tersimpan');
  }, [onToggleSave, isSaved, showToast]);

  const handleMute = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    onMute?.();
    showToast(`Notifikasi dari @${authorUsername || authorName} disenyapkan`);
  }, [onMute, authorUsername, authorName, showToast]);

  const handleHide = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    onHide?.();
    showToast('Postingan disembunyikan dari feed Anda');
  }, [onHide, showToast]);

  const handleReport = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    onReport?.();
    showToast('Laporan terkirim, terima kasih atas masukan Anda');
  }, [onReport, showToast]);

  const handleDeleteClick = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    setShowDeleteConfirm(true);
  }, []);

  const handleExecuteDelete = useCallback(() => {
    setShowDeleteConfirm(false);
    onDelete?.();
    showToast('Postingan dihapus');
  }, [onDelete, showToast]);

  const handleEdit = useCallback((e: React.MouseEvent) => {
    e.stopPropagation();
    onEdit?.();
  }, [onEdit]);

  const menuItems = useMemo<SubmenuDropdownItem[]>(() => {
    const items: SubmenuDropdownItem[] = [
      // 1. Bookmark / Save Option
      {
        id: 'bookmark',
        label: isSaved ? 'Hapus dari Markah' : 'Simpan ke Markah',
        icon: isSaved ? BookmarkCheck : Bookmark,
        onClick: handleToggleSave,
      },
      // 2. Copy Link Option
      {
        id: 'copy-link',
        label: 'Salin Tautan',
        icon: Copy,
        onClick: handleCopyLink,
      },
      // 3. User Options Nested Submenu
      {
        id: 'user-options',
        label: 'Opsi Pengguna',
        icon: UserX,
        subTitle: `Pengguna: @${authorUsername || authorName}`,
        subItems: [
          {
            id: 'mute-user',
            label: `Senyapkan @${authorUsername || authorName}`,
            icon: BellOff,
            onClick: handleMute,
          },
          {
            id: 'hide-post',
            label: 'Sembunyikan Postingan',
            icon: EyeOff,
            onClick: handleHide,
          },
        ],
      },
    ];

    // 4. Owner Actions (Edit & Delete)
    if (isOwner) {
      if (onEdit) {
        items.push({
          id: 'edit-post',
          label: 'Edit Postingan',
          icon: Edit3,
          onClick: handleEdit,
        });
      }

      if (onDelete) {
        items.push({
          id: 'delete-post',
          label: 'Hapus Postingan',
          icon: Trash2,
          danger: true,
          onClick: handleDeleteClick,
        });
      }
    }

    // 5. Report Option
    items.push({
      id: 'report-post',
      label: title === 'Opsi Komentar' ? 'Laporkan Komentar' : 'Laporkan Postingan',
      icon: Flag,
      danger: true,
      onClick: handleReport,
    });

    return items;
  }, [
    isSaved,
    handleToggleSave,
    handleCopyLink,
    authorUsername,
    authorName,
    handleMute,
    handleHide,
    isOwner,
    onEdit,
    handleEdit,
    onDelete,
    handleDeleteClick,
    title,
    handleReport,
  ]);

  return (
    <>
      <SubmenuDropdown
        isOpen={isOpen}
        onClose={onClose}
        items={menuItems}
        align={align}
        placement={placement}
        className={className}
        triggerRef={triggerRef}
        menuId={menuId}
        triggerId={triggerId}
      />

      {/* Confirmation Modal for Destructive Delete */}
      <ConfirmActionModal
        isOpen={showDeleteConfirm}
        onClose={() => setShowDeleteConfirm(false)}
        title="Hapus Postingan?"
        description="Tindakan ini tidak dapat dibatalkan. Postingan akan dihapus secara permanen dari server Snapan."
        actions={[
          {
            label: 'Hapus Postingan',
            variant: 'destructive',
            onClick: handleExecuteDelete,
          },
          {
            label: 'Batal',
            variant: 'cancel',
            onClick: () => setShowDeleteConfirm(false),
          },
        ]}
      />

      {/* Floating Action Toast Notification */}
      <ToastNotification
        message={toastMessage}
        onClose={() => setToastMessage(null)}
      />
    </>
  );
};

export const PostSubmenuDropdown = React.memo(PostSubmenuDropdownComponent);
PostSubmenuDropdown.displayName = 'PostSubmenuDropdown';
