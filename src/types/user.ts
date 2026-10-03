export type UserRole = 'user' | 'admin' | 'buyer' | 'seller';

export interface UserProfile {
  id: string;
  email: string;
  fullName: string;
  avatarUrl?: string;
  role: UserRole;
  phone?: string;
  createdAt: string;
}
