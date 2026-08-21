export interface SellerProfile {
  id: string;
  name: string;
  avatar: string;
  classGroup: string; // e.g. 'XII PPLG 1', 'XI DKV 2', 'Guru / Karyawan'
  isVerified: boolean;
  username: string;
}

export interface PostComment {
  id: string;
  postId: string;
  user: {
    id: string;
    name: string;
    avatar: string;
    username: string;
    classGroup: string;
    isVerified?: boolean;
    isAuthor?: boolean; // Badge 'Pembuat' / 'Penjual'
  };
  content: string;
  timestamp: string;
  likesCount: number;
  isLiked?: boolean;
  replies?: PostComment[]; // Nested replies
  threadPart?: number; // e.g. 2, 3
  totalParts?: number; // e.g. 3
  images?: string[]; // Attached images in comment/thread
}

export interface ThreadChainItem {
  id: string;
  partNumber: number; // e.g. 2, 3
  totalParts: number; // e.g. 3
  caption: string;
  images?: string[];
  timestamp?: string;
  likesCount?: number;
  commentsCount?: number;
  isLiked?: boolean;
}

export interface MarketPostItem {
  id: string;
  postType?: 'thread' | 'product'; // 'thread' = Utas Sosial Biasa, 'product' = Barang / Jasa Jualan
  title?: string;
  description?: string; // Deskripsi singkat/spesifikasi khusus produk yang tampil di Bottom Sheet
  seller: SellerProfile;
  caption: string;
  price?: number;
  originalPrice?: number;
  category?: 'Kantin' | 'Fashion' | 'Jasa DKV/PPLG' | 'Elektronik' | 'Lainnya';
  images: string[];
  stock?: number;
  locationTag?: string; // e.g. 'Kantin Depan', 'Gedung PPLG', 'Parkiran Belakang'
  topicTag?: string; // e.g. 'frontend', 'PJBL', 'html-css'
  isOfficialTopic?: boolean; // true = Official Blue Dropdown Topic, false = Custom User Topic
  topicIcon?: 'presentation' | 'threads' | string; // Custom icon indicator ('presentation' for Lucide Presentation, 'threads' for 3-dot)
  likesCount: number;
  commentsCount: number;
  repostsCount: number;
  timestamp: string; // e.g. '10m lalu', '2j lalu', '1hr lalu'
  isLiked?: boolean;
  isReposted?: boolean;
  isSaved?: boolean;
  comments?: PostComment[];
  threadChain?: ThreadChainItem[]; // Chained author thread continuation items (e.g. part 2/3, 3/3 in comments section)
  totalThreadParts?: number; // e.g. 3 (so part 1 shows "1/3")
}

export interface UserReplyThread {
  id: string;
  parentPost: MarketPostItem;
  reply: {
    id: string;
    content: string;
    timestamp: string;
    likesCount: number;
    isLiked?: boolean;
    repostsCount?: number;
    isReposted?: boolean;
    user: {
      name: string;
      username: string;
      avatar: string;
      classGroup?: string;
      isVerified?: boolean;
    };
  };
}
