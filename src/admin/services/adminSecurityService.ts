import { supabase } from '@/services/api/supabase';

export interface AdminActivityLogRow {
  id: string;
  admin_id: string | null;
  admin_email: string;
  action: string;
  target_info: string | null;
  metadata?: Record<string, any>;
  created_at: string;
}

export const ADMIN_SESSION_STORAGE_KEY = 'snaps_admin_active_session_token';

export const adminSecurityService = {
  /**
   * Catat aktivitas audit admin ke tabel admin_activity_logs
   */
  async logActivity(params: {
    adminEmail: string;
    action: string;
    targetInfo?: string;
    metadata?: Record<string, any>;
  }): Promise<void> {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();

      await (supabase.from('admin_activity_logs' as any) as any).insert({
        admin_id: user?.id ?? null,
        admin_email: params.adminEmail,
        action: params.action,
        target_info: params.targetInfo ?? null,
        metadata: params.metadata ?? {},
      });
    } catch (err) {
      console.warn('Gagal mencatat log audit admin:', err);
    }
  },

  /**
   * Mengambil riwayat log aktivitas admin
   */
  async getActivityLogs(limit = 20): Promise<AdminActivityLogRow[]> {
    try {
      const { data, error } = await (supabase.from('admin_activity_logs' as any) as any)
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) {
        console.warn('Tabel admin_activity_logs belum dimigrasi:', error.message);
        return [];
      }
      return (data as AdminActivityLogRow[]) || [];
    } catch {
      return [];
    }
  },

  /**
   * Simpan token sesi baru untuk penegakan Single Active Device
   */
  async registerNewSessionToken(userId: string): Promise<string> {
    const newToken = crypto.randomUUID();
    try {
      await supabase
        .from('profiles')
        .update({ current_admin_session_token: newToken } as any)
        .eq('id', userId);

      localStorage.setItem(ADMIN_SESSION_STORAGE_KEY, newToken);
      return newToken;
    } catch (err) {
      console.warn('Gagal mendaftarkan session token admin:', err);
      localStorage.setItem(ADMIN_SESSION_STORAGE_KEY, newToken);
      return newToken;
    }
  },

  /**
   * Validasi apakah sesi saat ini masih merupakan sesi aktif tunggal
   */
  async validateActiveSession(userId: string): Promise<boolean> {
    const localToken = localStorage.getItem(ADMIN_SESSION_STORAGE_KEY);
    if (!localToken) return true;

    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('current_admin_session_token' as any)
        .eq('id', userId)
        .single();

      if (error || !data) return true;

      const serverToken = (data as any)?.current_admin_session_token;
      if (!serverToken) return true;

      return serverToken === localToken;
    } catch {
      return true;
    }
  },

  /**
   * Hapus token sesi saat logout
   */
  clearLocalSessionToken() {
    localStorage.removeItem(ADMIN_SESSION_STORAGE_KEY);
  },
};
