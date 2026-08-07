import { supabase } from './supabase';
import type { Product, Category } from '@/types/supabase';

/**
 * Fetch semua produk aktif
 */
export async function getActiveProducts(): Promise<Product[]> {
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .eq('is_active', true)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Error fetching active products:', error.message);
    throw error;
  }
  return data || [];
}

/**
 * Fetch detail produk berdasarkan ID
 */
export async function getProductById(productId: string): Promise<Product | null> {
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .eq('id', productId)
    .single();

  if (error) {
    console.error(`Error fetching product ${productId}:`, error.message);
    throw error;
  }
  return data;
}

/**
 * Fetch produk berdasarkan kategori ID
 */
export async function getProductsByCategory(categoryId: string): Promise<Product[]> {
  const { data, error } = await supabase
    .from('products')
    .select('*')
    .eq('category_id', categoryId)
    .eq('is_active', true)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching products for category ${categoryId}:`, error.message);
    throw error;
  }
  return data || [];
}

/**
 * Fetch semua kategori
 */
export async function getCategories(): Promise<Category[]> {
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .order('name', { ascending: true });

  if (error) {
    console.error('Error fetching categories:', error.message);
    throw error;
  }
  return data || [];
}
