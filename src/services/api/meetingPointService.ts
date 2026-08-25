import { supabase } from './supabase';
import type { SchoolMeetingPoint } from '@/types/supabase';

/**
 * Fetch seluruh titik temu COD yang aktif di SMKN 8
 */
export async function getAllMeetingPoints(): Promise<SchoolMeetingPoint[]> {
  const { data, error } = await supabase
    .from('school_meeting_points')
    .select('*')
    .eq('is_active', true)
    .order('floor', { ascending: true })
    .order('name', { ascending: true });

  if (error) {
    console.error('Error fetching meeting points:', error.message);
    throw error;
  }

  return data || [];
}

/**
 * Fetch titik temu COD berdasarkan lantai tertentu
 */
export async function getMeetingPointsByFloor(floor: number): Promise<SchoolMeetingPoint[]> {
  const { data, error } = await supabase
    .from('school_meeting_points')
    .select('*')
    .eq('floor', floor)
    .eq('is_active', true)
    .order('name', { ascending: true });

  if (error) {
    console.error(`Error fetching meeting points for floor ${floor}:`, error.message);
    throw error;
  }

  return data || [];
}

/**
 * Fetch detail satu titik temu berdasarkan ID
 */
export async function getMeetingPointById(meetingPointId: string): Promise<SchoolMeetingPoint | null> {
  const { data, error } = await supabase
    .from('school_meeting_points')
    .select('*')
    .eq('id', meetingPointId)
    .maybeSingle();

  if (error) {
    console.error(`Error fetching meeting point ${meetingPointId}:`, error.message);
    throw error;
  }

  return data;
}

/**
 * Fetch titik temu dikelompokkan per kategori area
 */
export async function getMeetingPointsByCategory(category: string): Promise<SchoolMeetingPoint[]> {
  const { data, error } = await supabase
    .from('school_meeting_points')
    .select('*')
    .eq('area_category', category)
    .eq('is_active', true)
    .order('floor', { ascending: true });

  if (error) {
    console.error(`Error fetching meeting points for category ${category}:`, error.message);
    throw error;
  }

  return data || [];
}
