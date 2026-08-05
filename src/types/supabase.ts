export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          full_name: string | null
          avatar_url: string | null
          role: string
          created_at: string
        }
        Insert: {
          id: string
          full_name?: string | null
          avatar_url?: string | null
          role?: string
          created_at?: string
        }
        Update: {
          id?: string
          full_name?: string | null
          avatar_url?: string | null
          role?: string
          created_at?: string
        }
      }
      products: {
        Row: {
          id: string
          name: string
          price: number
          stock: number
          seller_id: string
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          price: number
          stock?: number
          seller_id: string
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          price?: number
          stock?: number
          seller_id?: string
          created_at?: string
        }
      }
    }
  }
}
