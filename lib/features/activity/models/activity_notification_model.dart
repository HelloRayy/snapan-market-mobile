enum ActivityType { like, comment, mention, follow, order, system }

enum ActivityTimelineGroup {
  today,
  yesterday,
  thisWeek,
  older;

  String get label {
    switch (this) {
      case ActivityTimelineGroup.today:
        return 'Hari Ini';
      case ActivityTimelineGroup.yesterday:
        return 'Kemarin';
      case ActivityTimelineGroup.thisWeek:
        return 'Minggu Ini';
      case ActivityTimelineGroup.older:
        return 'Lebih Lama';
    }
  }
}

class ActivityNotification {
  final String id;
  final ActivityType type;
  final String actorName;
  final String actorUsername;
  final String actorAvatar;
  final String title;
  final String message;
  final String timeAgo;
  final DateTime? createdAt;
  final String? postThumbnail;
  final String? actionUrl;
  final String? actionType;
  final String? actionButtonLabel;
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
    this.createdAt,
    this.postThumbnail,
    this.actionUrl,
    this.actionType,
    this.actionButtonLabel,
    this.postId,
    this.isRead = false,
  });

  bool get hasAction =>
      actionType != null && actionType != 'none' && actionType!.isNotEmpty;

  ActivityTimelineGroup get timelineGroup {
    if (createdAt == null) return ActivityTimelineGroup.today;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    final dayDiff = today.difference(itemDay).inDays;

    if (dayDiff <= 0) return ActivityTimelineGroup.today;
    if (dayDiff == 1) return ActivityTimelineGroup.yesterday;
    if (dayDiff < 7) return ActivityTimelineGroup.thisWeek;
    return ActivityTimelineGroup.older;
  }

  static String formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m lalu';
    } else if (diff.inHours < 24 && now.day == dt.day) {
      return '${diff.inHours}j lalu';
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final itemDay = DateTime(dt.year, dt.month, dt.day);
      final dayDiff = today.difference(itemDay).inDays;
      if (dayDiff == 1) {
        return 'Kemarin';
      } else if (dayDiff < 7) {
        return '${dayDiff}h lalu';
      } else {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
          'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
        ];
        final monthStr = dt.month >= 1 && dt.month <= 12 ? months[dt.month - 1] : '';
        if (now.year == dt.year) {
          return '${dt.day} $monthStr';
        }
        return '${dt.day} $monthStr ${dt.year}';
      }
    }
  }

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
    final actorUsername = notifType == ActivityType.system ? 'snaps' : (actor?['username']?.toString() ?? '');
    final defaultActorName = notifType == ActivityType.system ? 'Snaps' : (actorUsername.isNotEmpty ? '@$actorUsername' : 'Pengguna');
    final rawActorName = actor?['full_name']?.toString() ?? defaultActorName;
    final actorName = (notifType == ActivityType.system || rawActorName.toLowerCase().contains('admin'))
        ? 'Snaps'
        : rawActorName;
    final actorAvatar = actor?['avatar_url']?.toString() ?? '';

    final rawCreatedAt = json['created_at'];
    DateTime? parsedCreatedAt;
    if (rawCreatedAt != null) {
      if (rawCreatedAt is DateTime) {
        parsedCreatedAt = rawCreatedAt.toLocal();
      } else {
        parsedCreatedAt = DateTime.tryParse(rawCreatedAt.toString())?.toLocal();
      }
    }

    final timeAgo = parsedCreatedAt != null
        ? formatRelativeTime(parsedCreatedAt)
        : (json['time_ago']?.toString() ?? 'Baru saja');

    return ActivityNotification(
      id: json['id']?.toString() ?? '',
      type: notifType,
      actorName: actorName,
      actorUsername: actorUsername,
      actorAvatar: actorAvatar,
      title: json['title']?.toString() ?? 'Notifikasi baru',
      message: json['message']?.toString() ?? '',
      timeAgo: timeAgo,
      createdAt: parsedCreatedAt,
      actionUrl: json['action_url']?.toString(),
      actionType: json['action_type']?.toString(),
      actionButtonLabel: json['action_button_label']?.toString(),
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
      'created_at': createdAt?.toIso8601String(),
      'action_url': actionUrl,
      'action_type': actionType,
      'action_button_label': actionButtonLabel,
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
    DateTime? createdAt,
    String? postThumbnail,
    String? actionUrl,
    String? actionType,
    String? actionButtonLabel,
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
      createdAt: createdAt ?? this.createdAt,
      postThumbnail: postThumbnail ?? this.postThumbnail,
      actionUrl: actionUrl ?? this.actionUrl,
      actionType: actionType ?? this.actionType,
      actionButtonLabel: actionButtonLabel ?? this.actionButtonLabel,
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
    message: 'Menyukai karya kamu: "Source Code Snaps Web App PPLG".',
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
