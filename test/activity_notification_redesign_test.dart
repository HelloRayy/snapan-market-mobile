import 'package:flutter_test/flutter_test.dart';
import 'package:snapan_market/features/activity/models/activity_notification_model.dart';

void main() {
  group('SNAPS-83: ActivityNotification Dynamic Timestamps & Timeline Grouping', () {
    test('ActivityNotification.fromJson parses created_at and formats dynamic relative time', () {
      final now = DateTime.now();
      
      // 5 minutes ago
      final fiveMinsAgo = now.subtract(const Duration(minutes: 5));
      final json1 = {
        'id': 'notif-1',
        'type': 'system',
        'title': 'Pembaruan Aplikasi Tersedia',
        'message': 'Versi 1.0.30 siap dipasang.',
        'created_at': fiveMinsAgo.toIso8601String(),
        'action_type': 'update_app',
        'action_button_label': 'Perbarui Sekarang',
      };
      final notif1 = ActivityNotification.fromJson(json1);

      expect(notif1.title, 'Pembaruan Aplikasi Tersedia');
      expect(notif1.timeAgo, '5m lalu');
      expect(notif1.timelineGroup, ActivityTimelineGroup.today);
      expect(notif1.hasAction, isTrue);
      expect(notif1.actionButtonLabel, 'Perbarui Sekarang');
    });

    test('Timeline grouping categorizes today, yesterday, thisWeek, and older accurately', () {
      final now = DateTime.now();
      final today = now.subtract(const Duration(hours: 2));
      final yesterday = now.subtract(const Duration(days: 1, hours: 2));
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      final nToday = ActivityNotification.fromJson({
        'id': 'n-today',
        'type': 'system',
        'title': 'Hari ini',
        'message': 'Tes',
        'created_at': today.toIso8601String(),
      });

      final nYesterday = ActivityNotification.fromJson({
        'id': 'n-yesterday',
        'type': 'order',
        'title': 'Kemarin',
        'message': 'Tes',
        'created_at': yesterday.toIso8601String(),
      });

      final nThisWeek = ActivityNotification.fromJson({
        'id': 'n-week',
        'type': 'like',
        'title': 'Minggu ini',
        'message': 'Tes',
        'created_at': threeDaysAgo.toIso8601String(),
      });

      final nOlder = ActivityNotification.fromJson({
        'id': 'n-older',
        'type': 'comment',
        'title': 'Lebih lama',
        'message': 'Tes',
        'created_at': twoWeeksAgo.toIso8601String(),
      });

      expect(nToday.timelineGroup, ActivityTimelineGroup.today);
      expect(nToday.timelineGroup.label, 'Hari Ini');

      expect(nYesterday.timelineGroup, ActivityTimelineGroup.yesterday);
      expect(nYesterday.timelineGroup.label, 'Kemarin');

      expect(nThisWeek.timelineGroup, ActivityTimelineGroup.thisWeek);
      expect(nThisWeek.timelineGroup.label, 'Minggu Ini');

      expect(nOlder.timelineGroup, ActivityTimelineGroup.older);
      expect(nOlder.timelineGroup.label, 'Lebih Lama');
    });

    test('formatRelativeTime produces accurate human readable Indonesian strings', () {
      final now = DateTime.now();
      expect(ActivityNotification.formatRelativeTime(now.subtract(const Duration(seconds: 15))), 'Baru saja');
      expect(ActivityNotification.formatRelativeTime(now.subtract(const Duration(minutes: 42))), '42m lalu');
    });
  });
}
