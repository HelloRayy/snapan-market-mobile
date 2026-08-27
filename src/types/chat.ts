export type MessageStatus = 'sending' | 'sent' | 'delivered' | 'read';

export type MessageType =
  | 'text'
  | 'image'
  | 'voice'
  | 'product_inquiry'
  | 'offer'
  | 'meeting_point'
  | 'system';

export interface ChatParticipant {
  id: string;
  name: string;
  username: string;
  avatar: string;
  isVerified?: boolean;
  isOnline?: boolean;
  lastSeen?: string;
  classGroup?: string;
}

export interface ChatProductContext {
  id: string;
  title: string;
  price: number;
  originalPrice?: number;
  image: string;
  locationTag?: string;
}

export interface ChatOfferPayload {
  amount: number;
  originalPrice: number;
  status: 'pending' | 'accepted' | 'declined';
  note?: string;
}

export interface ChatMeetingPointPayload {
  spotName: string;
  zoneId?: string;
  timeLabel: string;
  status: 'proposed' | 'confirmed' | 'completed';
}

export interface ChatMessage {
  id: string;
  threadId: string;
  senderId: 'me' | string;
  text?: string;
  createdAt: string; // ISO string
  timestamp: string; // Display string, e.g. "10:24"
  status: MessageStatus;
  type: MessageType;
  mediaUrl?: string;
  voiceDuration?: string; // e.g. "0:14"
  productContext?: ChatProductContext;
  offer?: ChatOfferPayload;
  meetingPoint?: ChatMeetingPointPayload;
}

export interface ChatThread {
  id: string; // 17-digit numeric hash (e.g. "17845432127501402")
  participant: ChatParticipant;
  productContext?: ChatProductContext;
  unreadCount: number;
  lastMessage: string;
  lastTimestamp: string;
  isSenderLast?: boolean;
  isBuyerConversation?: boolean;
  messages: ChatMessage[];
}
