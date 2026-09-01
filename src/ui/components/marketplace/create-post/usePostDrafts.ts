import { useState, useCallback } from 'react';
import { triggerHaptic } from '@/utils/haptics';

export interface PostDraftData {
  caption: string;
  images: string[];
  productTitle: string;
  priceInput: string;
  postMode: 'thread' | 'product';
  subThreads: { id: string; caption: string; images: string[] }[];
  selectedTopic: any | null;
  savedAt: string;
}

export function usePostDrafts() {
  const [savedDraft, setSavedDraft] = useState<PostDraftData | null>(null);
  const [showDraftsSheet, setShowDraftsSheet] = useState(false);
  const [showDiscardAlert, setShowDiscardAlert] = useState(false);
  const [showDeleteDraftConfirm, setShowDeleteDraftConfirm] = useState(false);

  const refreshSavedDraft = useCallback(() => {
    try {
      const stored = localStorage.getItem('snapan_thread_draft');
      if (stored) {
        setSavedDraft(JSON.parse(stored));
      } else {
        setSavedDraft(null);
      }
    } catch {
      setSavedDraft(null);
    }
  }, []);

  const saveCurrentDraft = useCallback((draft: Omit<PostDraftData, 'savedAt'>) => {
    try {
      const payload: PostDraftData = {
        ...draft,
        savedAt: new Date().toISOString(),
      };
      localStorage.setItem('snapan_thread_draft', JSON.stringify(payload));
      setSavedDraft(payload);
      triggerHaptic('light');
    } catch (e) {
      console.error('Failed to save post draft:', e);
    }
  }, []);

  const deleteSavedDraft = useCallback(() => {
    try {
      localStorage.removeItem('snapan_thread_draft');
      setSavedDraft(null);
      triggerHaptic('light');
    } catch (e) {
      console.error('Failed to delete draft:', e);
    }
  }, []);

  return {
    savedDraft,
    showDraftsSheet,
    setShowDraftsSheet,
    showDiscardAlert,
    setShowDiscardAlert,
    showDeleteDraftConfirm,
    setShowDeleteDraftConfirm,
    refreshSavedDraft,
    saveCurrentDraft,
    deleteSavedDraft,
  };
}
