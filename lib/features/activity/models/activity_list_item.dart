import 'package:snapan_market/features/activity/models/activity_notification_model.dart';

/// Base class for flattened activity list items
abstract class ActivityListItem {}

/// Header separator item indicating timeline grouping (e.g. "HARI INI", "KEMARIN")
class ActivityHeaderItem extends ActivityListItem {
  final String label;

  ActivityHeaderItem(this.label);
}

/// Notification tile wrapper item
class ActivityTileItem extends ActivityListItem {
  final ActivityNotification notification;

  ActivityTileItem(this.notification);
}
