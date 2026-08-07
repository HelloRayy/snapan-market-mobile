import { supabase } from './supabase';
import type { Order, OrderItem } from '@/types/supabase';

export interface CreateOrderItemPayload {
  product_id: string;
  quantity: number;
  unit_price: number;
}

export interface CreateOrderPayload {
  buyer_id: string;
  total_amount: number;
  shipping_address: string;
  notes?: string;
  items: CreateOrderItemPayload[];
}

/**
 * Membuat transaksi order baru beserta rincian item
 */
export async function createOrder(payload: CreateOrderPayload): Promise<Order> {
  const { buyer_id, total_amount, shipping_address, notes, items } = payload;

  // 1. Insert order record
  const { data: orderData, error: orderError } = await supabase
    .from('orders')
    .insert({
      buyer_id,
      total_amount,
      shipping_address,
      notes: notes || null,
      status: 'pending'
    })
    .select()
    .single();

  if (orderError || !orderData) {
    console.error('Error creating order:', orderError?.message);
    throw orderError;
  }

  // 2. Insert order items
  const orderItemsData = items.map((item) => ({
    order_id: orderData.id,
    product_id: item.product_id,
    quantity: item.quantity,
    unit_price: item.unit_price
  }));

  const { error: itemsError } = await supabase
    .from('order_items')
    .insert(orderItemsData);

  if (itemsError) {
    console.error('Error creating order items:', itemsError.message);
    throw itemsError;
  }

  return orderData;
}

/**
 * Fetch riwayat order pengguna berdasarkan buyer_id
 */
export async function getUserOrders(buyerId: string): Promise<Order[]> {
  const { data, error } = await supabase
    .from('orders')
    .select('*')
    .eq('buyer_id', buyerId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching orders for user ${buyerId}:`, error.message);
    throw error;
  }

  return data || [];
}

/**
 * Fetch detail item dari sebuah order
 */
export async function getOrderItems(orderId: string): Promise<OrderItem[]> {
  const { data, error } = await supabase
    .from('order_items')
    .select('*')
    .eq('order_id', orderId);

  if (error) {
    console.error(`Error fetching order items for order ${orderId}:`, error.message);
    throw error;
  }

  return data || [];
}
