import { supabase } from '@/services/api/supabase';
import type { Database } from '@/types/supabase';

export type ProfileRow = Database['public']['Tables']['profiles']['Row'];
export type MarketPostRow = Database['public']['Tables']['market_posts']['Row'];
export type SchoolMeetingPointRow = Database['public']['Tables']['school_meeting_points']['Row'];

export interface AdminStats {
  totalUsers: number;
  totalPosts: number;
  totalMeetingPoints: number;
  totalOrders: number;
  recentUsers: ProfileRow[];
  recentPosts: (MarketPostRow & { seller?: ProfileRow | null })[];
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
      supabase.from('profiles').select('*').order('created_at', { ascending: false }).limit(5),
      supabase.from('market_posts').select('*, seller:profiles(*)').order('created_at', { ascending: false }).limit(5),
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
    limit?: number;
    offset?: number;
  }): Promise<{ data: ProfileRow[]; count: number }> {
    const { search = '', role = 'all', limit = 20, offset = 0 } = params || {};

    let query = supabase.from('profiles').select('*', { count: 'exact' });

    if (search.trim()) {
      query = query.or(`full_name.ilike.%${search}%,username.ilike.%${search}%,class_group.ilike.%${search}%`);
    }

    if (role && role !== 'all') {
      query = query.eq('role', role as 'buyer' | 'seller' | 'admin');
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
   * Mengubah role profile (buyer, seller, admin)
   */
  async updateProfileRole(userId: string, newRole: 'buyer' | 'seller' | 'admin'): Promise<void> {
    const { error } = await supabase
      .from('profiles')
      .update({ role: newRole })
      .eq('id', userId);

    if (error) throw error;
  },

  /**
   * Toggle status verifikasi siswa (official badge)
   */
  async toggleVerification(userId: string, isVerified: boolean): Promise<void> {
    const { error } = await supabase
      .from('profiles')
      .update({ is_verified: isVerified })
      .eq('id', userId);

    if (error) throw error;
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

    let query = supabase.from('market_posts').select('*, seller:profiles(*)', { count: 'exact' });

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
    const { error } = await supabase
      .from('market_posts')
      .delete()
      .eq('id', postId);

    if (error) throw error;
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
      is_active: boolean;
    }>
  ): Promise<void> {
    const { error } = await supabase
      .from('school_meeting_points')
      .update(updates)
      .eq('id', id);

    if (error) throw error;
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
};
