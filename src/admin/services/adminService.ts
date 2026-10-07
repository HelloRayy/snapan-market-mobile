import { supabase } from '@/services/api/supabase';
import type { Database } from '@/types/supabase';
import type { RealtimeChannel } from '@supabase/supabase-js';

export type ProfileRow = Database['public']['Tables']['profiles']['Row'];
export type MarketPostRow = Database['public']['Tables']['market_posts']['Row'];
export type SchoolMeetingPointRow = Database['public']['Tables']['school_meeting_points']['Row'];
export type ContentReportRow = Database['public']['Tables']['content_reports']['Row'];

export interface ContentReportWithDetails extends ContentReportRow {
  reporter?: ProfileRow | null;
  post?: (MarketPostRow & { seller?: ProfileRow | null }) | null;
}

export interface GlobalSearchResult {
  users: ProfileRow[];
  posts: (MarketPostRow & { seller?: ProfileRow | null })[];
  spots: SchoolMeetingPointRow[];
}

export interface AdminStats {
  totalUsers: number;
  totalPosts: number;
  totalMeetingPoints: number;
  totalOrders: number;
  recentUsers: ProfileRow[];
  recentPosts: (MarketPostRow & { seller?: ProfileRow | null })[];
}

export interface DeviceSecuritySettings {
  enabled: boolean;
  max_accounts: number;
}

export interface DeviceRecordRow {
  device_id: string;
  device_model: string;
  account_count: number;
  accounts: string[];
  is_whitelisted: boolean;
  is_blocked: boolean;
  notes?: string | null;
  first_registered_at: string;
  last_registered_at: string;
}

export interface DeviceSecurityData {
  settings: DeviceSecuritySettings;
  total_devices: number;
  whitelisted_count: number;
  blocked_count: number;
  devices: DeviceRecordRow[];
}

export const adminService = {
  /**
   * Cek apakah user saat ini memiliki akses admin / superadmin
   */
  async checkIsAdmin(userId: string): Promise<boolean> {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

      if (error || !data) return false;
      return data.role === 'admin';
    } catch {
      return false;
    }
  },

  /**
   * Mengambil statistik ringkas untuk overview dashboard
   */
  async getAdminStats(): Promise<AdminStats> {
    const [usersRes, postsRes, spotsRes, ordersRes, recentUsersRes, recentPostsRes] = await Promise.all([
      supabase.from('profiles').select('id', { count: 'exact', head: true }),
      supabase.from('market_posts').select('id', { count: 'exact', head: true }),
      supabase.from('school_meeting_points').select('id', { count: 'exact', head: true }),
      supabase.from('orders').select('id', { count: 'exact', head: true }),
      supabase
        .from('profiles')
        .select('id, full_name, username, avatar_url, role, class_group, created_at')
        .order('created_at', { ascending: false })
        .limit(5),
      supabase
        .from('market_posts')
        .select(`
          id,
          title,
          price,
          images,
          category,
          created_at,
          seller:seller_id (
            id,
            full_name,
            username,
            avatar_url,
            role
          )
        `)
        .order('created_at', { ascending: false })
        .limit(5),
    ]);

    return {
      totalUsers: usersRes.count ?? 0,
      totalPosts: postsRes.count ?? 0,
      totalMeetingPoints: spotsRes.count ?? 0,
      totalOrders: ordersRes.count ?? 0,
      recentUsers: (recentUsersRes.data as ProfileRow[]) ?? [],
      recentPosts: (recentPostsRes.data as (MarketPostRow & { seller?: ProfileRow | null })[]) ?? [],
    };
  },

  /**
   * Mengambil daftar profiles siswa dengan pencarian dan filter role
   */
  async getProfiles(params?: {
    search?: string;
    role?: string;
    verification?: 'all' | 'verified' | 'unverified';
    status?: 'all' | 'active' | 'suspended';
    limit?: number;
    offset?: number;
  }): Promise<{ data: ProfileRow[]; count: number }> {
    const {
      search = '',
      role = 'all',
      verification = 'all',
      status = 'all',
      limit = 20,
      offset = 0,
    } = params || {};

    let query = supabase.from('profiles').select('*', { count: 'exact' });

    if (search.trim()) {
      query = query.or(`full_name.ilike.%${search}%,username.ilike.%${search}%,class_group.ilike.%${search}%`);
    }

    if (role && role !== 'all') {
      if (role === 'user') {
        query = query.in('role', ['user', 'buyer', 'seller']);
      } else {
        query = query.eq('role', role as 'user' | 'admin' | 'buyer' | 'seller');
      }
    }

    if (verification === 'verified') {
      query = query.eq('is_verified', true);
    } else if (verification === 'unverified') {
      query = query.eq('is_verified', false);
    }

    if (status === 'suspended') {
      query = query.eq('is_suspended', true);
    } else if (status === 'active') {
      query = query.or('is_suspended.is.null,is_suspended.eq.false');
    }

    query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1);

    const { data, error, count } = await query;
    if (error) throw error;

    return {
      data: (data as ProfileRow[]) || [],
      count: count ?? 0,
    };
  },

  /**
   * Menangguhkan (suspend) akun siswa yang melanggar batas aturan
   */
  async suspendUser(userId: string, reason: string, durationHours: number | null): Promise<void> {
    const trimmedReason = reason.trim();
    if (!trimmedReason) {
      throw new Error('Alasan penangguhan akun wajib diisi.');
    }

    const untilDate =
      durationHours && durationHours > 0
        ? new Date(Date.now() + durationHours * 3600 * 1000).toISOString()
        : null;

    // Coba direct update terlebih dahulu
    const { data, error } = await supabase
      .from('profiles')
      .update({
        is_suspended: true,
        suspended_at: new Date().toISOString(),
        suspended_until: untilDate,
        suspend_reason: trimmedReason,
      })
      .eq('id', userId)
      .select();

    if (error || !data || data.length === 0) {
      // Fallback ke RPC ber-security definer
      const { error: rpcErr } = await (supabase.rpc as any)('admin_suspend_user', {
        target_user_id: userId,
        reason: trimmedReason,
        duration_hours: durationHours,
      });

      if (rpcErr) {
        throw new Error(
          rpcErr.message ||
            'Gagal menangguhkan akun pengguna. Jalankan SQL migration admin di Supabase SQL Editor.'
        );
      }
    }
  },

  /**
   * Memulihkan (unsuspend) akun siswa kembali aktif normal
   */
  async unsuspendUser(userId: string): Promise<void> {
    const { data, error } = await supabase
      .from('profiles')
      .update({
        is_suspended: false,
        suspended_at: null,
        suspended_until: null,
        suspend_reason: null,
      })
      .eq('id', userId)
      .select();

    if (error || !data || data.length === 0) {
      const { error: rpcErr } = await (supabase.rpc as any)('admin_unsuspend_user', {
        target_user_id: userId,
      });

      if (rpcErr) {
        throw new Error(
          rpcErr.message ||
            'Gagal memulihkan akun pengguna. Jalankan SQL migration admin di Supabase SQL Editor.'
        );
      }
    }
  },

  /**
   * Menghapus akun pengguna/siswa secara permanen beserta semua postingan dan relasinya.
   * Username dan NIS akan dibebaskan kembali sehingga dapat digunakan oleh pengguna baru.
   */
  async deleteUser(userId: string): Promise<void> {
    // 1. Coba eksekusi melalui RPC admin_delete_user (Security Definer)
    const { error: rpcErr } = await (supabase.rpc as any)('admin_delete_user', {
      target_user_id: userId,
    });

    if (rpcErr) {
      console.warn('RPC admin_delete_user gagal atau belum dipasang, beralih ke fallback pembersihan bertingkat:', rpcErr);

      // Fallback: Pembersihan bertingkat melalui Client API
      // A. Ambil profil untuk mendapatkan data NIS
      const { data: profile } = await (supabase as any)
        .from('profiles')
        .select('nis, username')
        .eq('id', userId)
        .maybeSingle();

      // B. Bebaskan klaim master data siswa (student_registry)
      if (profile?.nis) {
        await (supabase as any)
          .from('student_registry')
          .update({ is_claimed: false, claimed_by: null, claimed_at: null })
          .eq('nis', profile.nis);
      }
      await (supabase as any)
        .from('student_registry')
        .update({ is_claimed: false, claimed_by: null, claimed_at: null })
        .eq('claimed_by', userId);

      // C. Hapus pesanan (orders) terkait pengguna agar tidak melanggar foreign key restrict
      try {
        await (supabase as any)
          .from('orders')
          .delete()
          .or(`buyer_id.eq.${userId},seller_id.eq.${userId}`);
      } catch (err) {
        console.warn('Orders cleanup warning:', err);
      }

      // D. Hapus semua postingan feed & marketplace milik pengguna
      const { error: postsErr } = await (supabase as any)
        .from('market_posts')
        .delete()
        .eq('seller_id', userId);
      if (postsErr) {
        console.warn('Fallback delete market_posts warning:', postsErr);
      }

      // E. Hapus relasi sosial (likes, comments, follows, notifications)
      try {
        await (supabase as any).from('post_likes').delete().eq('user_id', userId);
        await (supabase as any).from('post_comments').delete().eq('user_id', userId);
        await (supabase as any).from('post_poll_votes').delete().eq('user_id', userId);
        await (supabase as any).from('device_registrations').delete().eq('user_id', userId);
        await (supabase as any).from('fcm_tokens').delete().eq('user_id', userId);
        await (supabase as any).from('follows').delete().or(`follower_id.eq.${userId},following_id.eq.${userId}`);
        await (supabase as any).from('notifications').delete().or(`recipient_id.eq.${userId},actor_id.eq.${userId}`);
      } catch (err) {
        console.warn('Social relations cleanup warning:', err);
      }

      // F. Hapus baris profil dan verifikasi baris yang benar-benar terhapus
      const { data: deletedRows, error: profileErr } = await supabase
        .from('profiles')
        .delete()
        .eq('id', userId)
        .select('id');

      if (profileErr || !deletedRows || deletedRows.length === 0) {
        const isRpcMissing = rpcErr?.code === 'PGRST202' || rpcErr?.message?.includes('admin_delete_user');
        throw new Error(
          isRpcMissing
            ? 'Fungsi database "admin_delete_user" belum dipasang di Supabase. Silakan jalankan script SQL migrasi "supabase_admin_remove_account_feature.sql" di Supabase SQL Editor.'
            : (rpcErr?.message || profileErr?.message || 'Gagal menghapus akun pengguna dari database. Pastikan kebijakan RLS DELETE aktif.')
        );
      }
    }
  },

  /**
   * Mengubah role profile (user, admin)
   */
  async updateProfileRole(userId: string, newRole: 'user' | 'admin' | 'buyer' | 'seller'): Promise<void> {
    const { data, error } = await supabase
      .from('profiles')
      .update({ role: newRole })
      .eq('id', userId)
      .select();

    if (error) throw error;
    if (!data || data.length === 0) {
      const { error: rpcErr } = await (supabase.rpc as any)('admin_update_profile_role', {
        target_user_id: userId,
        new_role: newRole,
      });
      if (rpcErr) {
        throw new Error(
          'Gagal mengubah role: Terhalang Supabase RLS. Jalankan SQL Migration Admin di Supabase SQL Editor.'
        );
      }
    }
  },

  /**
   * Toggle status verifikasi siswa (official badge)
   */
  async toggleVerification(userId: string, isVerified: boolean): Promise<void> {
    const { data, error } = await supabase
      .from('profiles')
      .update({ is_verified: isVerified })
      .eq('id', userId)
      .select();

    if (error) throw error;
    if (!data || data.length === 0) {
      const { error: rpcErr } = await (supabase.rpc as any)('admin_toggle_verification', {
        target_user_id: userId,
        new_status: isVerified,
      });
      if (rpcErr) {
        throw new Error(
          'Gagal verifikasi: Terhalang Supabase RLS. Jalankan SQL Migration Admin di Supabase SQL Editor.'
        );
      }
    }
  },

  /**
   * Mengambil daftar postingan feed untuk moderasi
   */
  async getMarketPosts(params?: {
    search?: string;
    postType?: string;
    limit?: number;
    offset?: number;
  }): Promise<{ data: (MarketPostRow & { seller?: ProfileRow | null })[]; count: number }> {
    const { search = '', postType = 'all', limit = 15, offset = 0 } = params || {};

    let query = supabase.from('market_posts').select('*, seller:seller_id(*)', { count: 'exact' });

    if (search.trim()) {
      query = query.or(`title.ilike.%${search}%,caption.ilike.%${search}%,category.ilike.%${search}%`);
    }

    if (postType && postType !== 'all') {
      query = query.eq('post_type', postType as 'thread' | 'product');
    }

    query = query.order('created_at', { ascending: false }).range(offset, offset + limit - 1);

    const { data, error, count } = await query;
    if (error) throw error;

    return {
      data: (data as (MarketPostRow & { seller?: ProfileRow | null })[]) || [],
      count: count ?? 0,
    };
  },

  /**
   * Takedown / Delete postingan feed
   */
  async deleteMarketPost(postId: string): Promise<void> {
    const { data, error } = await supabase
      .from('market_posts')
      .delete()
      .eq('id', postId)
      .select();

    if (error) throw error;
    if (!data || data.length === 0) {
      const { error: rpcErr } = await (supabase.rpc as any)('admin_delete_post', {
        target_post_id: postId,
      });
      if (rpcErr) {
        throw new Error(
          'Gagal menghapus postingan: Terhalang Supabase RLS. Jalankan SQL Migration Admin di Supabase SQL Editor.'
        );
      }
    }
  },

  /**
   * Mengambil semua titik temu COD SMKN 8
   */
  async getMeetingPoints(): Promise<SchoolMeetingPointRow[]> {
    const { data, error } = await supabase
      .from('school_meeting_points')
      .select('*')
      .order('floor', { ascending: true })
      .order('name', { ascending: true });

    if (error) throw error;
    return (data as SchoolMeetingPointRow[]) || [];
  },

  /**
   * Menambah titik temu COD baru
   */
  async createMeetingPoint(point: {
    floor: number;
    name: string;
    area_category: string;
    description?: string | null;
    coordinates_x: number;
    coordinates_y: number;
    is_active?: boolean;
  }): Promise<SchoolMeetingPointRow> {
    const { data, error } = await supabase
      .from('school_meeting_points')
      .insert({
        id: crypto.randomUUID(),
        floor: point.floor,
        name: point.name,
        area_category: point.area_category,
        description: point.description ?? null,
        coordinates_x: point.coordinates_x,
        coordinates_y: point.coordinates_y,
        is_active: point.is_active ?? true,
      })
      .select()
      .single();

    if (error) throw error;
    return data as SchoolMeetingPointRow;
  },

  /**
   * Mengubah titik temu COD
   */
  async updateMeetingPoint(
    id: string,
    updates: Partial<{
      floor: number;
      name: string;
      area_category: string;
      description: string | null;
      coordinates_x: number;
      coordinates_y: number;
      is_active: boolean;
    }>
  ): Promise<SchoolMeetingPointRow> {
    const { data, error } = await supabase
      .from('school_meeting_points')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data as SchoolMeetingPointRow;
  },

  /**
   * Menghapus titik temu COD
   */
  async deleteMeetingPoint(id: string): Promise<void> {
    const { error } = await supabase
      .from('school_meeting_points')
      .delete()
      .eq('id', id);

    if (error) throw error;
  },

  /**
   * Pencarian global live lintas entitas (profiles, market_posts, school_meeting_points)
   */
  async searchGlobal(query: string): Promise<GlobalSearchResult> {
    const cleanQuery = query.trim();
    if (!cleanQuery) {
      return { users: [], posts: [], spots: [] };
    }

    try {
      const [usersRes, postsRes, spotsRes] = await Promise.all([
        supabase
          .from('profiles')
          .select('id, full_name, username, avatar_url, role, class_group, created_at')
          .or(`full_name.ilike.%${cleanQuery}%,username.ilike.%${cleanQuery}%,class_group.ilike.%${cleanQuery}%`)
          .limit(4),
        supabase
          .from('market_posts')
          .select(`
            id,
            title,
            price,
            images,
            category,
            created_at,
            seller:seller_id (
              id,
              full_name,
              username,
              avatar_url,
              role
            )
          `)
          .or(`title.ilike.%${cleanQuery}%,caption.ilike.%${cleanQuery}%,category.ilike.%${cleanQuery}%`)
          .limit(4),
        supabase
          .from('school_meeting_points')
          .select('id, name, floor, area_category, description, coordinates_x, coordinates_y, is_active')
          .or(`name.ilike.%${cleanQuery}%,area_category.ilike.%${cleanQuery}%`)
          .limit(4),
      ]);

      return {
        users: (usersRes.data as ProfileRow[]) || [],
        posts: (postsRes.data as (MarketPostRow & { seller?: ProfileRow | null })[]) || [],
        spots: (spotsRes.data as SchoolMeetingPointRow[]) || [],
      };
    } catch (err) {
      console.error('Error in searchGlobal:', err);
      return { users: [], posts: [], spots: [] };
    }
  },

  /**
   * Mengambil data laporan konten dari database Supabase (dengan proyeksi kolom teroptimasi & pagination)
   */
  async getContentReports(limit = 100): Promise<ContentReportWithDetails[]> {
    try {
      const { data: dbReports, error: repErr } = await (supabase as any)
        .from('content_reports')
        .select(`
          id,
          post_id,
          reporter_id,
          reason,
          details,
          status,
          created_at,
          resolved_at,
          resolved_by,
          reporter:reporter_id (
            id,
            full_name,
            username,
            avatar_url,
            role,
            class_group
          ),
          post:post_id (
            id,
            title,
            caption,
            price,
            images,
            category,
            created_at,
            seller:seller_id (
              id,
              full_name,
              username,
              avatar_url,
              role
            )
          )
        `)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (!repErr && dbReports) {
        return dbReports as ContentReportWithDetails[];
      }
      return [];
    } catch (e) {
      console.warn('Gagal mengambil content_reports dari database:', e);
      return [];
    }
  },

  /**
   * Mengambil cuplikan notifikasi laporan yang berstatus 'pending' (super ringan untuk AdminHeader)
   */
  async getPendingReportNotifications(limit = 5): Promise<{
    notifications: {
      id: string;
      reason: string;
      details: string | null;
      created_at: string;
      reporterUsername: string | null;
    }[];
    pendingCount: number;
  }> {
    try {
      const { data, count, error } = await (supabase as any)
        .from('content_reports')
        .select(
          `
          id,
          reason,
          details,
          created_at,
          reporter:reporter_id (
            username,
            full_name
          )
        `,
          { count: 'exact' }
        )
        .eq('status', 'pending')
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error || !data) {
        return { notifications: [], pendingCount: 0 };
      }

      const formatted = (data as any[]).map((r) => ({
        id: r.id,
        reason: r.reason,
        details: r.details,
        created_at: r.created_at,
        reporterUsername: r.reporter?.username || r.reporter?.full_name || 'siswa',
      }));

      return {
        notifications: formatted,
        pendingCount: count ?? formatted.length,
      };
    } catch (e) {
      console.warn('Gagal mengambil pending notifications:', e);
      return { notifications: [], pendingCount: 0 };
    }
  },

  /**
   * Mengupdate status laporan di database Supabase
   */
  async updateReportStatus(
    reportId: string,
    status: 'pending' | 'resolved' | 'dismissed',
    adminUserId?: string
  ): Promise<void> {
    try {
      const { error } = await (supabase as any)
        .from('content_reports')
        .update({
          status,
          resolved_at: status !== 'pending' ? new Date().toISOString() : null,
          resolved_by: status !== 'pending' ? adminUserId ?? null : null,
        })
        .eq('id', reportId);

      if (error) {
        // Coba panggil RPC jika RLS membatasi
        await (supabase.rpc as any)('admin_update_report_status', {
          target_report_id: reportId,
          new_status: status,
          admin_user_id: adminUserId,
        });
      }
    } catch (e) {
      console.warn('Update report status fallback:', e);
    }
  },

  /**
   * Mengirim broadcast notifikasi sistem ke pengguna (semua atau target tertentu)
   */
  async sendBroadcastNotification(payload: {
    title: string;
    message: string;
    targetType: 'all' | 'specific_role' | 'single_user';
    targetRole?: string;
    targetUserId?: string;
    soundUrl?: string; // Mock custom sound url / name
    adminId?: string;
    actionUrl?: string;
    actionType?: 'none' | 'update_app' | 'external_url' | 'post_link';
    actionButtonLabel?: string;
  }): Promise<{
    successCount: number;
    targetCount: number;
    fcmSentCount: number;
    fcmFailedCount: number;
    totalTokensFound: number;
  }> {
    try {
      // 1. Ambil target user ID
      let query = supabase.from('profiles').select('id');
      if (payload.targetType === 'single_user' && payload.targetUserId) {
        query = query.eq('id', payload.targetUserId);
      } else if (payload.targetType === 'specific_role' && payload.targetRole) {
        if (payload.targetRole === 'user') {
          query = query.in('role', ['user', 'buyer', 'seller']);
        } else {
          query = query.eq('role', payload.targetRole as any);
        }
      }

      const { data: users, error: userError } = await query;
      if (userError) throw userError;
      if (!users || users.length === 0) {
        return {
          successCount: 0,
          targetCount: 0,
          fcmSentCount: 0,
          fcmFailedCount: 0,
          totalTokensFound: 0,
        };
      }

      // 2. Siapkan records notifikasi untuk diinsert secara batch
      const rows = users.map((u) => ({
        user_id: u.id,
        actor_id: payload.adminId || null,
        type: 'system',
        title: payload.title,
        message: payload.message,
        action_url: payload.actionUrl || null,
        action_type: payload.actionType || 'none',
        is_read: false,
      }));

      const chunkSize = 100;
      let totalInserted = 0;
      for (let i = 0; i < rows.length; i += chunkSize) {
        const chunk = rows.slice(i, i + chunkSize);
        const { error: insertError } = await (supabase as any)
          .from('notifications')
          .insert(chunk);
        if (insertError) {
          console.warn('Batch insert chunk error:', insertError);
        } else {
          totalInserted += chunk.length;
        }
      }

      // 3. Ambil Device Token FCM siswa dan kirimkan push ke Google Firebase Gateway
      let fcmSentCount = 0;
      let fcmFailedCount = 0;
      let totalTokensFound = 0;
      try {
        const userIds = users.map((u) => u.id);
        const { data: fcmRows, error: tokenFetchError } = await (supabase as any)
          .from('user_fcm_tokens')
          .select('fcm_token')
          .in('user_id', userIds);

        if (tokenFetchError) {
          console.warn('Gagal membaca tabel user_fcm_tokens:', tokenFetchError);
        }

        if (fcmRows && fcmRows.length > 0) {
          const tokens = fcmRows
            .map((r: any) => r.fcm_token)
            .filter((t: any) => typeof t === 'string' && t.trim().length > 10);

          totalTokensFound = tokens.length;
          if (tokens.length > 0) {
            const { adminFcmService } = await import('./adminFcmService');
            const fcmRes = await adminFcmService.sendPushNotificationToTokens({
              tokens,
              title: payload.title,
              message: payload.message,
              actionType: payload.actionType,
              actionUrl: payload.actionUrl,
              actionButtonLabel: payload.actionButtonLabel,
            });
            fcmSentCount = fcmRes.success;
            fcmFailedCount = fcmRes.failed;
          }
        }
      } catch (fcmErr) {
        console.warn('FCM dispatch warning (notifikasi database tetap berhasil):', fcmErr);
      }

      return {
        successCount: totalInserted,
        targetCount: users.length,
        fcmSentCount,
        fcmFailedCount,
        totalTokensFound,
      };
    } catch (err: any) {
      console.error('sendBroadcastNotification failed:', err);
      throw new Error(err?.message || 'Gagal mengirim notifikasi broadcast');
    }
  },

  /**
   * Mengambil riwayat pengiriman notifikasi broadcast terkini yang dikelompokkan per sesi siaran.
   * Setiap kali broadcast dikirim ke banyak orang, riwayat menggabungkannya menjadi 1 card
   * dengan jumlah penerima (recipientCount), bukan spam kartu duplikat.
   */
  async getBroadcastHistory(limit = 20): Promise<any[]> {
    try {
      const { data, error } = await (supabase as any)
        .from('notifications')
        .select('id, title, message, type, created_at, action_type, action_url, user_id, actor:actor_id (full_name, username)')
        .eq('type', 'system')
        .order('created_at', { ascending: false })
        .limit(200);

      if (error || !data || data.length === 0) return [];

      // Grouping notifikasi yang memiliki title & message yang sama dalam rentang waktu yang berdekatan (selisih <= 15 detik)
      const grouped: any[] = [];
      data.forEach((item: any) => {
        const itemTime = new Date(item.created_at).getTime();
        const existingGroup = grouped.find((g) => {
          const groupTime = new Date(g.created_at).getTime();
          const isSameContent = g.title === item.title && g.message === item.message;
          const isSameBatch = Math.abs(groupTime - itemTime) <= 15000; // dalam 15 detik yang sama
          return isSameContent && isSameBatch;
        });

        if (existingGroup) {
          existingGroup.recipientCount += 1;
        } else {
          grouped.push({
            ...item,
            recipientCount: 1,
          });
        }
      });

      return grouped.slice(0, limit);
    } catch (e) {
      console.warn('Failed getBroadcastHistory:', e);
      return [];
    }
  },

  /**
   * Menghapus seluruh riwayat broadcast notifikasi sistem
   */
  async deleteAllBroadcastHistory(): Promise<void> {
    try {
      const { error } = await (supabase as any)
        .from('notifications')
        .delete()
        .eq('type', 'system');

      if (error) {
        throw error;
      }
    } catch (e: any) {
      console.error('Failed deleteAllBroadcastHistory:', e);
      throw new Error(e?.message || 'Gagal menghapus seluruh riwayat broadcast.');
    }
  },

  /**
   * Subscribe ke event realtime perubahan laporan konten (INSERT, UPDATE, DELETE)
   */
  subscribeToContentReports(onChange: (payload: any) => void): RealtimeChannel {
    const channelId = `admin-reports-${Math.random().toString(36).substring(2, 8)}`;
    return supabase
      .channel(channelId)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'content_reports',
        },
        (payload) => onChange(payload)
      )
      .subscribe();
  },

  /**
   * Subscribe ke event realtime postingan market (misal takedown atau post baru)
   */
  subscribeToMarketPosts(onChange: (payload: any) => void): RealtimeChannel {
    const channelId = `admin-posts-${Math.random().toString(36).substring(2, 8)}`;
    return supabase
      .channel(channelId)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'market_posts',
        },
        (payload) => onChange(payload)
      )
      .subscribe();
  },

  /**
   * Unsubscribe channel Supabase Realtime secara aman
   */
  async unsubscribeChannel(channel: RealtimeChannel): Promise<void> {
    try {
      await supabase.removeChannel(channel);
    } catch (e) {
      console.warn('Failed to remove channel:', e);
    }
  },

  /**
   * Mengambil data konfigurasi batas pendaftaran dan daftar perangkat unik
   */
  async getDeviceSecurityData(): Promise<DeviceSecurityData> {
    try {
      const { data, error } = await (supabase.rpc as any)('admin_get_device_security_data');
      if (!error && data) {
        return {
          settings: {
            enabled: data.settings?.enabled ?? true,
            max_accounts: data.settings?.max_accounts ?? 3,
          },
          total_devices: data.total_devices || 0,
          whitelisted_count: data.whitelisted_count || 0,
          blocked_count: data.blocked_count || 0,
          devices: Array.isArray(data.devices) ? data.devices : [],
        };
      }
    } catch (e) {
      console.warn('RPC admin_get_device_security_data unavailable, fallback to direct query:', e);
    }

    // Fallback direct table query
    try {
      const { data: settingsRow } = await (supabase as any)
        .from('app_security_settings')
        .select('value')
        .eq('key', 'device_registration_limit')
        .maybeSingle();

      const settings: DeviceSecuritySettings = {
        enabled: settingsRow?.value?.enabled ?? true,
        max_accounts: settingsRow?.value?.max_accounts ?? 3,
      };

      const { data: rawDevices, error: devErr } = await (supabase as any)
        .from('device_registrations')
        .select('*')
        .order('created_at', { ascending: false });

      if (devErr || !rawDevices) {
        return {
          settings,
          total_devices: 0,
          whitelisted_count: 0,
          blocked_count: 0,
          devices: [],
        };
      }

      // Client-side grouping fallback
      const map = new Map<string, DeviceRecordRow>();
      rawDevices.forEach((r: any) => {
        const existing = map.get(r.device_id);
        const uname = r.username || 'user';
        if (existing) {
          if (!existing.accounts.includes(uname)) {
            existing.accounts.push(uname);
            existing.account_count = existing.accounts.length;
          }
          if (r.is_whitelisted) existing.is_whitelisted = true;
          if (r.is_blocked) existing.is_blocked = true;
          if (new Date(r.created_at) > new Date(existing.last_registered_at)) {
            existing.last_registered_at = r.created_at;
          }
          if (new Date(r.created_at) < new Date(existing.first_registered_at)) {
            existing.first_registered_at = r.created_at;
          }
        } else {
          map.set(r.device_id, {
            device_id: r.device_id,
            device_model: r.device_model || 'Unknown Device',
            account_count: 1,
            accounts: [uname],
            is_whitelisted: !!r.is_whitelisted,
            is_blocked: !!r.is_blocked,
            notes: r.notes || null,
            first_registered_at: r.created_at,
            last_registered_at: r.created_at,
          });
        }
      });

      const devices = Array.from(map.values());
      const whitelistedCount = devices.filter((d) => d.is_whitelisted).length;
      const blockedCount = devices.filter((d) => d.is_blocked).length;

      return {
        settings,
        total_devices: devices.length,
        whitelisted_count: whitelistedCount,
        blocked_count: blockedCount,
        devices,
      };
    } catch (err: any) {
      console.error('Failed getDeviceSecurityData:', err);
      return {
        settings: { enabled: true, max_accounts: 3 },
        total_devices: 0,
        whitelisted_count: 0,
        blocked_count: 0,
        devices: [],
      };
    }
  },

  /**
   * Memperbarui konfigurasi global: Saklar On/Off & Batas Maksimal Akun per HP
   */
  async updateDeviceSecuritySettings(enabled: boolean, maxAccounts: number): Promise<boolean> {
    try {
      const { error } = await (supabase.rpc as any)('admin_update_device_security_settings', {
        p_enabled: enabled,
        p_max_accounts: maxAccounts,
      });

      if (!error) return true;

      // Fallback direct update
      const { error: directErr } = await (supabase as any)
        .from('app_security_settings')
        .upsert({
          key: 'device_registration_limit',
          value: { enabled, max_accounts: maxAccounts },
          updated_at: new Date().toISOString(),
        });

      if (directErr) throw directErr;
      return true;
    } catch (e: any) {
      console.error('Failed updateDeviceSecuritySettings:', e);
      throw new Error(e?.message || 'Gagal menyimpan pengaturan keamanan perangkat.');
    }
  },

  /**
   * Mengubah status whitelist perangkat (VIP / Bebas Batas Kuota)
   */
  async toggleDeviceWhitelist(deviceId: string, status: boolean): Promise<boolean> {
    try {
      const { error } = await (supabase.rpc as any)('admin_toggle_device_whitelist', {
        target_device_id: deviceId,
        target_status: status,
      });

      if (!error) return true;

      const { error: directErr } = await (supabase as any)
        .from('device_registrations')
        .update({ is_whitelisted: status })
        .eq('device_id', deviceId);

      if (directErr) throw directErr;
      return true;
    } catch (e: any) {
      console.error('Failed toggleDeviceWhitelist:', e);
      throw new Error(e?.message || 'Gagal mengubah status whitelist perangkat.');
    }
  },

  /**
   * Mengubah status blokir perangkat dari pendaftaran akun baru
   */
  async toggleDeviceBlock(deviceId: string, status: boolean): Promise<boolean> {
    try {
      const { error } = await (supabase.rpc as any)('admin_toggle_device_block', {
        target_device_id: deviceId,
        target_status: status,
      });

      if (!error) return true;

      const { error: directErr } = await (supabase as any)
        .from('device_registrations')
        .update({ is_blocked: status })
        .eq('device_id', deviceId);

      if (directErr) throw directErr;
      return true;
    } catch (e: any) {
      console.error('Failed toggleDeviceBlock:', e);
      throw new Error(e?.message || 'Gagal mengubah status blokir perangkat.');
    }
  },

  /**
   * Mereset riwayat pendaftaran perangkat sehingga kuotanya kembali jadi 0
   */
  async resetDeviceQuota(deviceId: string): Promise<boolean> {
    try {
      const { error } = await (supabase.rpc as any)('admin_reset_device_quota', {
        target_device_id: deviceId,
      });

      if (!error) return true;

      const { error: directErr } = await (supabase as any)
        .from('device_registrations')
        .delete()
        .eq('device_id', deviceId);

      if (directErr) throw directErr;
      return true;
    } catch (e: any) {
      console.error('Failed resetDeviceQuota:', e);
      throw new Error(e?.message || 'Gagal mereset kuota perangkat.');
    }
  },
};
