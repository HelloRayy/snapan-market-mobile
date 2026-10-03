enum ActivityType { like, comment, mention, follow, order, system }

class ActivityNotification {
  final String id;
  final ActivityType type;
  final String actorName;
  final String actorUsername;
  final String actorAvatar;
  final String title;
  final String message;
  final String timeAgo;
  final String? postThumbnail;
  final String? actionUrl;
  final String? actionType;
  final String? postId;
  final bool isRead;

  const ActivityNotification({
    required this.id,
    required this.type,
    required this.actorName,
    required this.actorUsername,
    required this.actorAvatar,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.postThumbnail,
    this.actionUrl,
    this.actionType,
    this.postId,
    this.isRead = false,
  });

  factory ActivityNotification.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString().toLowerCase() ?? 'system';
    ActivityType notifType;
    if (typeStr == 'like') {
      notifType = ActivityType.like;
    } else if (typeStr == 'comment' || typeStr == 'reply') {
      notifType = ActivityType.comment;
    } else if (typeStr == 'mention') {
      notifType = ActivityType.mention;
    } else if (typeStr == 'follow') {
      notifType = ActivityType.follow;
    } else if (typeStr == 'order') {
      notifType = ActivityType.order;
    } else {
      notifType = ActivityType.system;
    }

    final actor = json['actor'] as Map<String, dynamic>?;
    final actorUsername = actor?['username']?.toString() ?? '';
    final defaultActorName = notifType == ActivityType.system ? (json['title']?.toString() ?? 'Pengumuman Resmi') : (actorUsername.isNotEmpty ? '@$actorUsername' : 'Pengguna');
    final actorName = actor?['full_name']?.toString() ?? defaultActorName;
    final actorAvatar = actor?['avatar_url']?.toString() ?? '';

    return ActivityNotification(
      id: json['id']?.toString() ?? '',
      type: notifType,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatar: actorAvatar,
      title: json['title']?.toString() ?? 'Notifikasi baru',
      message: json['message']?.toString() ?? '',
      timeAgo: 'Baru saja',
      actionUrl: json['action_url']?.toString(),
      actionType: json['action_type']?.toString(),
      postId: json['post_id']?.toString(),
      isRead: json['is_read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'actor_name': actorName,
      'actor_username': actorUsername,
      'actor_avatar': actorAvatar,
      'title': title,
      'message': message,
      'time_ago': timeAgo,
      'action_url': actionUrl,
      'action_type': actionType,
      'post_id': postId,
      'is_read': isRead,
    };
  }

  ActivityNotification copyWith({
    String? id,
    ActivityType? type,
    String? actorName,
    String? actorUsername,
    String? actorAvatar,
    String? title,
    String? message,
    String? timeAgo,
    String? postThumbnail,
    String? actionUrl,
    String? actionType,
    String? postId,
    bool? isRead,
  }) {
    return ActivityNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      actorName: actorName ?? this.actorName,
      actorUsername: actorUsername ?? this.actorUsername,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      postThumbnail: postThumbnail ?? this.postThumbnail,
      actionUrl: actionUrl ?? this.actionUrl,
      actionType: actionType ?? this.actionType,
      postId: postId ?? this.postId,
      isRead: isRead ?? this.isRead,
    );
  }
}

const List<ActivityNotification> kMockNotifications = [
  ActivityNotification(
    id: "notif-1",
    type: ActivityType.order,
    actorName: "Bagas Surya A",
    actorUsername: "uiuxbagas",
    actorAvatar: "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&q=80",
    title: "Pesanan COD Baru!",
    message: 'Memesan "Desain UI Landing Page Vokasi". Janji temu di Kantin Utama Lt. 1.',
    timeAgo: "10m lalu",
    postThumbnail: "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=300&q=80",
    isRead: false,
  ),
  ActivityNotification(
    id: "notif-2",
    type: ActivityType.like,
    actorName: "Flo",
    actorUsername: "growthflo",
    actorAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80",
    title: "Menyukai Postingan",
    message: 'Menyukai karya kamu: "Source Code Snapan Market Web App PPLG".',
    timeAgo: "1j lalu",
    postThumbnail: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=300&q=80",
    isRead: false,
  ),
  ActivityNotification(
    id: "notif-3",
    type: ActivityType.comment,
    actorName: "Septiawan Aji",
    actorUsername: "dewakoding",
    actorAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80",
    title: "Mengomentari Utas",
    message: "Keren banget bang arsitektur Supabase RLS-nya! Ada dokumentasinya ga?",
    timeAgo: "3j lalu",
    postThumbnail: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=300&q=80",
    isRead: true,
  ),
  ActivityNotification(
    id: "notif-4",
    type: ActivityType.system,
    actorName: "Snapan Security",
    actorUsername: "system",
    actorAvatar: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=150&q=80",
    title: "Akun Terverifikasi SMKN 8",
    message: "Selamat! Profil Anda telah terverifikasi sebagai Siswa PPLG Angkatan 2024.",
    timeAgo: "1h lalu",
    isRead: true,
  ),
];
