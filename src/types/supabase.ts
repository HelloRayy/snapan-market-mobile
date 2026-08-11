export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          full_name: string
          avatar_url: string | null
          class_group: string | null
          is_verified: boolean
          role: 'buyer' | 'seller' | 'admin'
          created_at: string
        }
        Insert: {
          id: string
          full_name: string
          avatar_url?: string | null
          class_group?: string | null
          is_verified?: boolean
          role?: 'buyer' | 'seller' | 'admin'
          created_at?: string
        }
        Update: {
          id?: string
          full_name?: string
          avatar_url?: string | null
          class_group?: string | null
          is_verified?: boolean
          role?: 'buyer' | 'seller' | 'admin'
          created_at?: string
        }
        Relationships: []
      }
      categories: {
        Row: {
          id: string
          name: string
          slug: string
          icon: string | null
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          slug: string
          icon?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          slug?: string
          icon?: string | null
          created_at?: string
        }
        Relationships: []
      }
      products: {
        Row: {
          id: string
          name: string
          slug: string | null
          description: string | null
          price: number
          stock: number
          category_id: string | null
          seller_id: string
          image_url: string | null
          rating: number
          sold_count: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          slug?: string | null
          description?: string | null
          price: number
          stock?: number
          category_id?: string | null
          seller_id: string
          image_url?: string | null
          rating?: number
          sold_count?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          slug?: string | null
          description?: string | null
          price?: number
          stock?: number
          category_id?: string | null
          seller_id?: string
          image_url?: string | null
          rating?: number
          sold_count?: number
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      orders: {
        Row: {
          id: string
          buyer_id: string
          total_amount: number
          status: 'pending' | 'paid' | 'processing' | 'shipped' | 'completed' | 'cancelled'
          shipping_address: string
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          buyer_id: string
          total_amount: number
          status?: 'pending' | 'paid' | 'processing' | 'shipped' | 'completed' | 'cancelled'
          shipping_address: string
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          buyer_id?: string
          total_amount?: number
          status?: 'pending' | 'paid' | 'processing' | 'shipped' | 'completed' | 'cancelled'
          shipping_address?: string
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: []
      }
      order_items: {
        Row: {
          id: string
          order_id: string
          product_id: string
          quantity: number
          unit_price: number
          created_at: string
        }
        Insert: {
          id?: string
          order_id: string
          product_id: string
          quantity: number
          unit_price: number
          created_at?: string
        }
        Update: {
          id?: string
          order_id?: string
          product_id?: string
          quantity?: number
          unit_price?: number
          created_at?: string
        }
        Relationships: []
      }
      reviews: {
        Row: {
          id: string
          product_id: string
          user_id: string
          rating: number
          comment: string | null
          created_at: string
        }
        Insert: {
          id?: string
          product_id: string
          user_id: string
          rating: number
          comment?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          product_id?: string
          user_id?: string
          rating?: number
          comment?: string | null
          created_at?: string
        }
        Relationships: []
      }
      market_posts: {
        Row: {
          id: string
          seller_id: string
          caption: string
          images: string[]
          is_video: boolean
          stock: number
          price?: number
          original_price?: number | null
          category?: string
          location_tag?: string | null
          created_at: string
        }
        Insert: {
          id?: string
          seller_id: string
          caption: string
          images?: string[]
          is_video?: boolean
          stock?: number
          price?: number
          original_price?: number | null
          category?: string
          location_tag?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          seller_id?: string
          caption?: string
          images?: string[]
          is_video?: boolean
          stock?: number
          price?: number
          original_price?: number | null
          category?: string
          location_tag?: string | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "market_posts_seller_id_fkey"
            columns: ["seller_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      post_likes: {
        Row: {
          post_id: string
          user_id: string
          created_at: string
        }
        Insert: {
          post_id: string
          user_id: string
          created_at?: string
        }
        Update: {
          post_id?: string
          user_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "post_likes_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_likes_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      post_comments: {
        Row: {
          id: string
          post_id: string
          user_id: string
          content: string
          created_at: string
        }
        Insert: {
          id?: string
          post_id: string
          user_id: string
          content: string
          created_at?: string
        }
        Update: {
          id?: string
          post_id?: string
          user_id?: string
          content?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "post_comments_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_comments_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      cart_items: {
        Row: {
          id: string
          user_id: string
          post_id: string
          quantity: number
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          post_id: string
          quantity?: number
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          post_id?: string
          quantity?: number
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "cart_items_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cart_items_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

// Convenience Type Aliases
export type Profile = Database['public']['Tables']['profiles']['Row']
export type Category = Database['public']['Tables']['categories']['Row']
export type Product = Database['public']['Tables']['products']['Row']
export type Order = Database['public']['Tables']['orders']['Row']
export type OrderItem = Database['public']['Tables']['order_items']['Row']
export type Review = Database['public']['Tables']['reviews']['Row']
export type MarketPost = Database['public']['Tables']['market_posts']['Row']
export type PostLike = Database['public']['Tables']['post_likes']['Row']
export type PostComment = Database['public']['Tables']['post_comments']['Row']
export type CartItem = Database['public']['Tables']['cart_items']['Row']

// Extended UI Types matching Frontend Components
export type MarketPostWithSeller = MarketPost & {
  seller: Profile
  likes_count?: number
  comments_count?: number
  is_liked_by_user?: boolean
}

export type PostCommentWithUser = PostComment & {
  user: Profile
}

export type CartItemWithPost = CartItem & {
  post: MarketPostWithSeller
}
