export interface UserProfile {
  id: string;
  email: string;
  fullName: string;
  avatarUrl?: string;
  role: 'buyer' | 'seller' | 'admin';
  phone?: string;
  createdAt: string;
}
