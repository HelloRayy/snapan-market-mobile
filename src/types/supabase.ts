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
          full_name: string
          username: string | null
          avatar_url: string | null
          class_group: string
          is_verified: boolean
          role: 'buyer' | 'seller' | 'admin'
          verified_sales_count: number
          total_revenue_idr: number
          created_at: string
        }
        Insert: {
          id: string
          full_name: string
          username?: string | null
          avatar_url?: string | null
          class_group?: string
          is_verified?: boolean
          role?: 'buyer' | 'seller' | 'admin'
          verified_sales_count?: number
          total_revenue_idr?: number
          created_at?: string
        }
        Update: {
          id?: string
          full_name?: string
          username?: string | null
          avatar_url?: string | null
          class_group?: string
          is_verified?: boolean
          role?: 'buyer' | 'seller' | 'admin'
          verified_sales_count?: number
          total_revenue_idr?: number
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
        Relationships: [
          {
            foreignKeyName: "reviews_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      market_posts: {
        Row: {
          id: string
          seller_id: string
          post_type: 'thread' | 'product'
          title: string | null
          caption: string
          description: string | null
          price: number
          original_price: number | null
          category: string
          images: string[]
          is_video: boolean
          stock: number
          is_sold_out: boolean
          total_sold_units: number
          location_tag: string | null
          topic_tag: string | null
          is_official_topic: boolean
          topic_icon: string | null
          likes_count: number
          comments_count: number
          reposts_count: number
          created_at: string
        }
        Insert: {
          id?: string
          seller_id: string
          post_type?: 'thread' | 'product'
          title?: string | null
          caption: string
          description?: string | null
          price?: number
          original_price?: number | null
          category?: string
          images?: string[]
          is_video?: boolean
          stock?: number
          is_sold_out?: boolean
          total_sold_units?: number
          location_tag?: string | null
          topic_tag?: string | null
          is_official_topic?: boolean
          topic_icon?: string | null
          likes_count?: number
          comments_count?: number
          reposts_count?: number
          created_at?: string
        }
        Update: {
          id?: string
          seller_id?: string
          post_type?: 'thread' | 'product'
          title?: string | null
          caption?: string
          description?: string | null
          price?: number
          original_price?: number | null
          category?: string
          images?: string[]
          is_video?: boolean
          stock?: number
          is_sold_out?: boolean
          total_sold_units?: number
          location_tag?: string | null
          topic_tag?: string | null
          is_official_topic?: boolean
          topic_icon?: string | null
          likes_count?: number
          comments_count?: number
          reposts_count?: number
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
          parent_comment_id: string | null
          content: string
          images: string[]
          thread_part: number
          total_parts: number
          likes_count: number
          created_at: string
        }
        Insert: {
          id?: string
          post_id: string
          user_id: string
          parent_comment_id?: string | null
          content: string
          images?: string[]
          thread_part?: number
          total_parts?: number
          likes_count?: number
          created_at?: string
        }
        Update: {
          id?: string
          post_id?: string
          user_id?: string
          parent_comment_id?: string | null
          content?: string
          images?: string[]
          thread_part?: number
          total_parts?: number
          likes_count?: number
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
          },
          {
            foreignKeyName: "post_comments_parent_comment_id_fkey"
            columns: ["parent_comment_id"]
            isOneToOne: false
            referencedRelation: "post_comments"
            referencedColumns: ["id"]
          }
        ]
      }
      comment_likes: {
        Row: {
          comment_id: string
          user_id: string
          created_at: string
        }
        Insert: {
          comment_id: string
          user_id: string
          created_at?: string
        }
        Update: {
          comment_id?: string
          user_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "comment_likes_comment_id_fkey"
            columns: ["comment_id"]
            isOneToOne: false
            referencedRelation: "post_comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "comment_likes_user_id_fkey"
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
      post_bookmarks: {
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
            foreignKeyName: "post_bookmarks_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_bookmarks_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      notifications: {
        Row: {
          id: string
          user_id: string
          actor_id: string | null
          type: 'like' | 'comment' | 'reply' | 'order' | 'system'
          title: string
          message: string
          post_id: string | null
          is_read: boolean
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          actor_id?: string | null
          type: 'like' | 'comment' | 'reply' | 'order' | 'system'
          title: string
          message: string
          post_id?: string | null
          is_read?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          actor_id?: string | null
          type?: 'like' | 'comment' | 'reply' | 'order' | 'system'
          title?: string
          message?: string
          post_id?: string | null
          is_read?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "notifications_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "notifications_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          }
        ]
      }
      user_follows: {
        Row: {
          follower_id: string
          following_id: string
          created_at: string
        }
        Insert: {
          follower_id: string
          following_id: string
          created_at?: string
        }
        Update: {
          follower_id?: string
          following_id?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_follows_follower_id_fkey"
            columns: ["follower_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_follows_following_id_fkey"
            columns: ["following_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      post_reposts: {
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
            foreignKeyName: "post_reposts_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "post_reposts_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
      orders: {
        Row: {
          id: string
          order_code: string
          buyer_id: string
          seller_id: string
          post_id: string
          quantity: number
          unit_price: number
          total_price: number
          meeting_point_id: string | null
          meeting_point_name: string
          meeting_time_notes: string | null
          notes_for_seller: string | null
          status: 'pending' | 'in_cod' | 'completed' | 'cancelled' | 'rejected'
          cancelled_by: string | null
          cancel_reason: string | null
          accepted_at: string | null
          completed_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          order_code: string
          buyer_id: string
          seller_id: string
          post_id: string
          quantity?: number
          unit_price: number
          total_price: number
          meeting_point_id?: string | null
          meeting_point_name: string
          meeting_time_notes?: string | null
          notes_for_seller?: string | null
          status?: 'pending' | 'in_cod' | 'completed' | 'cancelled' | 'rejected'
          cancelled_by?: string | null
          cancel_reason?: string | null
          accepted_at?: string | null
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          order_code?: string
          buyer_id?: string
          seller_id?: string
          post_id?: string
          quantity?: number
          unit_price?: number
          total_price?: number
          meeting_point_id?: string | null
          meeting_point_name?: string
          meeting_time_notes?: string | null
          notes_for_seller?: string | null
          status?: 'pending' | 'in_cod' | 'completed' | 'cancelled' | 'rejected'
          cancelled_by?: string | null
          cancel_reason?: string | null
          accepted_at?: string | null
          completed_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_buyer_id_fkey"
            columns: ["buyer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_seller_id_fkey"
            columns: ["seller_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_meeting_point_id_fkey"
            columns: ["meeting_point_id"]
            isOneToOne: false
            referencedRelation: "school_meeting_points"
            referencedColumns: ["id"]
          }
        ]
      }
      school_meeting_points: {
        Row: {
          id: string
          floor: number
          name: string
          area_category: string
          description: string | null
          coordinates_x: number
          coordinates_y: number
          is_active: boolean
          created_at: string
        }
        Insert: {
          id: string
          floor: number
          name: string
          area_category: string
          description?: string | null
          coordinates_x: number
          coordinates_y: number
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          floor?: number
          name?: string
          area_category?: string
          description?: string | null
          coordinates_x?: number
          coordinates_y?: number
          is_active?: boolean
          created_at?: string
        }
        Relationships: []
      }
      order_notifications: {
        Row: {
          id: string
          recipient_id: string
          order_id: string
          title: string
          message: string
          type: string
          is_read: boolean
          created_at: string
        }
        Insert: {
          id?: string
          recipient_id: string
          order_id: string
          title: string
          message: string
          type: string
          is_read?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          recipient_id?: string
          order_id?: string
          title?: string
          message?: string
          type?: string
          is_read?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_notifications_recipient_id_fkey"
            columns: ["recipient_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_notifications_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          }
        ]
      }
      conversations: {
        Row: {
          id: string
          participant_one: string
          participant_two: string
          product_id: string | null
          last_message: string
          last_message_at: string
          created_at: string
        }
        Insert: {
          id?: string
          participant_one: string
          participant_two: string
          product_id?: string | null
          last_message?: string
          last_message_at?: string
          created_at?: string
        }
        Update: {
          id?: string
          participant_one?: string
          participant_two?: string
          product_id?: string | null
          last_message?: string
          last_message_at?: string
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "conversations_participant_one_fkey"
            columns: ["participant_one"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "conversations_participant_two_fkey"
            columns: ["participant_two"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "conversations_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "market_posts"
            referencedColumns: ["id"]
          }
        ]
      }
      direct_messages: {
        Row: {
          id: string
          conversation_id: string
          sender_id: string
          message_text: string
          is_read: boolean
          created_at: string
        }
        Insert: {
          id?: string
          conversation_id: string
          sender_id: string
          message_text: string
          is_read?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          conversation_id?: string
          sender_id?: string
          message_text?: string
          is_read?: boolean
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "direct_messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "conversations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "direct_messages_sender_id_fkey"
            columns: ["sender_id"]
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
      create_in_app_order: {
        Args: {
          p_post_id: string
          p_quantity: number
          p_meeting_point_id: string
          p_meeting_point_name: string
          p_meeting_notes: string
          p_buyer_notes: string
        }
        Returns: { success: boolean; order_id: string; order_code: string }
      }
      get_seller_verified_stats: {
        Args: { target_seller_id: string }
        Returns: { completed_sales_count: number; unique_buyers_count: number; total_revenue_idr: number }
      }
    }
    Enums: {
      order_status_enum: 'pending' | 'in_cod' | 'completed' | 'cancelled' | 'rejected'
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
export type Review = Database['public']['Tables']['reviews']['Row']
export type MarketPost = Database['public']['Tables']['market_posts']['Row']
export type PostLike = Database['public']['Tables']['post_likes']['Row']
export type PostComment = Database['public']['Tables']['post_comments']['Row']
export type CommentLike = Database['public']['Tables']['comment_likes']['Row']
export type CartItem = Database['public']['Tables']['cart_items']['Row']
export type PostBookmark = Database['public']['Tables']['post_bookmarks']['Row']
export type Conversation = Database['public']['Tables']['conversations']['Row']
export type DirectMessage = Database['public']['Tables']['direct_messages']['Row']
export type Notification = Database['public']['Tables']['notifications']['Row']
export type UserFollow = Database['public']['Tables']['user_follows']['Row']
export type PostRepost = Database['public']['Tables']['post_reposts']['Row']

// In-App Order System Types
export type InAppOrder = Database['public']['Tables']['orders']['Row']
export type SchoolMeetingPoint = Database['public']['Tables']['school_meeting_points']['Row']
export type OrderNotification = Database['public']['Tables']['order_notifications']['Row']
export type OrderStatusEnum = Database['public']['Enums']['order_status_enum']

// Extended UI Types matching Frontend Components
export type ProfileWithFollowStats = Profile & {
  followers_count?: number
  following_count?: number
  is_followed_by_user?: boolean
}

export type ProfileWithSalesStats = Profile & {
  verified_sales_count: number
  total_revenue_idr: number
}

export type ReviewWithUser = Review & {
  user: Profile
}

export type MarketPostWithSeller = MarketPost & {
  seller: Profile
  likes_count?: number
  comments_count?: number
  reposts_count?: number
  is_liked_by_user?: boolean
  is_bookmarked_by_user?: boolean
  is_reposted_by_user?: boolean
}

export type PostCommentWithUser = PostComment & {
  user: Profile
  likes_count?: number
  is_liked_by_user?: boolean
  replies?: PostCommentWithUser[]
}

export type CartItemWithPost = CartItem & {
  post: MarketPostWithSeller
}

export type NotificationWithActor = Notification & {
  actor?: Profile | null
  post?: MarketPost | null
}

// In-App Order Extended Types
export type InAppOrderWithDetails = InAppOrder & {
  buyer: Profile
  seller: Profile
  post: MarketPost
  meeting_point?: SchoolMeetingPoint | null
}

export type OrderNotificationWithOrder = OrderNotification & {
  order: InAppOrder
}

export interface SellerVerifiedStats {
  completed_sales_count: number
  unique_buyers_count: number
  total_revenue_idr: number
}

export interface CreateInAppOrderResult {
  success: boolean
  order_id: string
  order_code: string
}

export type MarketPostSortBy = 'latest' | 'cheapest' | 'pricy' | 'popular';

export interface MarketPostFilterOptions {
  query?: string
  category?: string
  post_type?: 'thread' | 'product' | 'all'
  min_price?: number
  max_price?: number
  location_tag?: string
  topic_tag?: string
  sort_by?: MarketPostSortBy
  limit?: number
  offset?: number
}
