import React, { useState } from 'react';
import { Check, CheckCheck, Play, Pause, MapPin, Tag, Clock } from 'lucide-react';
import { ChatMessage } from '@/types/chat';
import { formatRupiah } from '@/utils/formatters';
import { triggerHaptic } from '@/utils/haptics';

interface ChatBubbleItemProps {
  message: ChatMessage;
  onOpenProduct?: (productId: string) => void;
  onOpenMapLocation?: (zoneId?: string) => void;
  onAcceptOffer?: (messageId: string) => void;
}

export const ChatBubbleItem: React.FC<ChatBubbleItemProps> = ({
  message,
  onOpenProduct,
  onOpenMapLocation,
  onAcceptOffer,
}) => {
  const isMe = message.senderId === 'me';
  const isSystem = message.type === 'system';

  // Voice note play/pause simulation state
  const [isPlayingVoice, setIsPlayingVoice] = useState(false);

  const toggleVoicePlay = () => {
    triggerHaptic('light');
    setIsPlayingVoice((prev) => !prev);
  };

  // System Message (Centered Pill)
  if (isSystem) {
    return (
      <div className="flex justify-center my-3">
        <span className="px-3 py-1 rounded-full bg-neutral-100/90 text-neutral-500 text-[11.5px] font-medium text-center border border-neutral-200/60 shadow-2xs">
          {message.text}
        </span>
      </div>
    );
  }

  // Delivery status icon
  const renderStatus = () => {
    if (!isMe) return null;
    if (message.status === 'read') {
      return <CheckCheck className="w-3.5 h-3.5 text-blue-200 stroke-[2.5]" />;
    }
    if (message.status === 'delivered') {
      return <CheckCheck className="w-3.5 h-3.5 text-white/70 stroke-[2.5]" />;
    }
    return <Check className="w-3.5 h-3.5 text-white/60 stroke-[2.5]" />;
  };

  return (
    <div
      className={`flex flex-col mb-3 ${
        isMe ? 'items-end' : 'items-start'
      } max-w-[85%] sm:max-w-[75%] ${isMe ? 'ml-auto' : 'mr-auto'}`}
    >
      {/* 1. PRODUCT INQUIRY CARD VARIANT */}
      {message.type === 'product_inquiry' && message.productContext && (
        <div
          onClick={() => {
            triggerHaptic('light');
            onOpenProduct?.(message.productContext!.id);
          }}
          className="mb-1.5 p-2.5 rounded-2xl bg-white border border-neutral-200/90 shadow-xs flex items-center gap-2.5 w-full cursor-pointer hover:bg-neutral-50 transition-colors"
        >
          <img
            src={message.productContext.image}
            alt={message.productContext.title}
            className="w-12 h-12 rounded-xl object-cover shrink-0 border border-neutral-100"
          />
          <div className="min-w-0 flex-1">
            <p className="text-[10.5px] font-semibold text-neutral-400 uppercase tracking-wider">
              Produk Ditanyakan
            </p>
            <h5 className="font-bold text-[13px] text-slate-900 truncate leading-snug">
              {message.productContext.title}
            </h5>
            <p className="font-extrabold text-[13px] text-[#1d64ec] mt-0.5">
              {formatRupiah(message.productContext.price)}
            </p>
          </div>
        </div>
      )}

      {/* 2. PRICE OFFER CARD VARIANT */}
      {message.type === 'offer' && message.offer && (
        <div className="mb-1.5 p-3 rounded-2xl bg-gradient-to-br from-amber-50 to-orange-50/70 border border-amber-200 shadow-xs w-full">
          <div className="flex items-center justify-between gap-2 mb-1.5">
            <div className="flex items-center gap-1.5 text-amber-800 font-bold text-[12px]">
              <Tag className="w-3.5 h-3.5" />
              <span>Pengajuan Tawaran Harga</span>
            </div>
            <span
              className={`px-2 py-0.5 rounded-full text-[10.5px] font-extrabold ${
                message.offer.status === 'accepted'
                  ? 'bg-emerald-100 text-emerald-800 border border-emerald-300'
                  : message.offer.status === 'declined'
                  ? 'bg-rose-100 text-rose-800'
                  : 'bg-amber-100 text-amber-800'
              }`}
            >
              {message.offer.status === 'accepted'
                ? '✓ Tawaran Diterima'
                : message.offer.status === 'declined'
                ? '✕ Ditolak'
                : 'Menunggu Konfirmasi'}
            </span>
          </div>

          <div className="flex items-baseline gap-2">
            <span className="text-[18px] font-black text-slate-900">
              {formatRupiah(message.offer.amount)}
            </span>
            <span className="text-[12px] text-neutral-400 line-through">
              {formatRupiah(message.offer.originalPrice)}
            </span>
          </div>

          {!isMe && message.offer.status === 'pending' && (
            <div className="mt-2.5 flex items-center gap-2">
              <button
                type="button"
                onClick={() => onAcceptOffer?.(message.id)}
                className="flex-1 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-[12px] shadow-2xs transition-colors cursor-pointer"
              >
                Terima Tawaran
              </button>
            </div>
          )}
        </div>
      )}

      {/* 3. COD MEETING POINT CARD VARIANT */}
      {message.type === 'meeting_point' && message.meetingPoint && (
        <div
          onClick={() => onOpenMapLocation?.(message.meetingPoint?.zoneId)}
          className="mb-1.5 p-3 rounded-2xl bg-gradient-to-br from-blue-50 to-indigo-50/70 border border-blue-200 shadow-xs w-full cursor-pointer hover:border-blue-300 transition-colors group"
        >
          <div className="flex items-center justify-between gap-2 mb-1">
            <div className="flex items-center gap-1.5 text-[#1d64ec] font-bold text-[12px]">
              <MapPin className="w-4 h-4 stroke-[2.2]" />
              <span>Titik Temu COD Kampus</span>
            </div>
            <span className="px-2 py-0.5 rounded-full bg-blue-100 text-blue-800 text-[10.5px] font-extrabold">
              {message.meetingPoint.status === 'confirmed' ? '✓ Disepakati' : 'Rencana COD'}
            </span>
          </div>

          <h4 className="font-bold text-[14px] text-slate-900 leading-snug group-hover:text-[#1d64ec] transition-colors">
            {message.meetingPoint.spotName}
          </h4>

          <div className="flex items-center gap-1.5 text-[11.5px] text-neutral-600 mt-1">
            <Clock className="w-3.5 h-3.5 text-neutral-400" />
            <span>{message.meetingPoint.timeLabel}</span>
          </div>
        </div>
      )}

      {/* 4. VOICE NOTE VARIANT */}
      {message.type === 'voice' ? (
        <div
          className={`flex items-center gap-3 px-3.5 py-2.5 rounded-[22px] shadow-xs select-none ${
            isMe
              ? 'bg-[#1d64ec] text-white rounded-br-[4px]'
              : 'bg-[#f1f3f5] text-slate-900 rounded-bl-[4px]'
          }`}
        >
          <button
            type="button"
            onClick={toggleVoicePlay}
            className={`w-8 h-8 rounded-full flex items-center justify-center transition-transform active:scale-90 cursor-pointer ${
              isMe ? 'bg-white text-[#1d64ec]' : 'bg-[#1d64ec] text-white'
            }`}
            aria-label={isPlayingVoice ? 'Pause audio' : 'Play audio'}
          >
            {isPlayingVoice ? (
              <Pause className="w-4 h-4 fill-current" />
            ) : (
              <Play className="w-4 h-4 fill-current ml-0.5" />
            )}
          </button>

          {/* Interactive Waveform Simulation Bars */}
          <div className="flex items-center gap-1 h-5">
            {[40, 75, 100, 60, 85, 30, 95, 50, 70, 45, 80, 60].map((h, idx) => (
              <span
                key={idx}
                className={`w-1 rounded-full transition-all duration-150 ${
                  isPlayingVoice ? 'animate-pulse' : ''
                } ${isMe ? 'bg-white/80' : 'bg-neutral-400'}`}
                style={{ height: `${h}%` }}
              />
            ))}
          </div>

          <span
            className={`text-[11.5px] font-semibold ${
              isMe ? 'text-blue-100' : 'text-neutral-500'
            }`}
          >
            {message.voiceDuration || '0:15'}
          </span>

          <span
            className={`text-[10px] ml-1 self-end ${
              isMe ? 'text-blue-200' : 'text-neutral-400'
            }`}
          >
            {message.timestamp}
          </span>
          {renderStatus()}
        </div>
      ) : (
        /* 5. STANDARD TEXT BUBBLE */
        message.text && (
          <div
            className={`relative px-3.5 py-2 rounded-[20px] shadow-2xs text-[14.5px] leading-relaxed break-words ${
              isMe
                ? 'bg-[#1d64ec] text-white rounded-br-[4px]'
                : 'bg-[#f1f3f5] text-slate-900 rounded-bl-[4px]'
            }`}
          >
            <p className="whitespace-pre-wrap">{message.text}</p>
            <div
              className={`flex items-center justify-end gap-1 mt-0.5 text-[10.5px] ${
                isMe ? 'text-blue-100/90' : 'text-neutral-400'
              }`}
            >
              <span>{message.timestamp}</span>
              {renderStatus()}
            </div>
          </div>
        )
      )}
    </div>
  );
};
