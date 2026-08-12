import 'package:flutter/material.dart';

import '../../domain/entities/notification_alert_entity.dart';

/// A dismissible banner that surfaces the most recent live alert.
///
/// Shown at the top of the notifications page when there is at least one
/// unread alert, with a quick "View" action.
class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onTap,
  });

  final NotificationAlertEntity alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _visualFor(alert.type);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(alert.body),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onDismiss,
        ),
      ),
    );
  }

  (IconData, Color) _visualFor(NotificationAlertType type) {
    switch (type) {
      case NotificationAlertType.goal:
        return (Icons.sports_soccer, Colors.green);
      case NotificationAlertType.kickoff:
        return (Icons.play_circle_outline, Colors.blue);
      case NotificationAlertType.halfTime:
        return (Icons.pause_circle_outline, Colors.orange);
      case NotificationAlertType.fullTime:
        return (Icons.stop_circle_outlined, Colors.redAccent);
      case NotificationAlertType.result:
        return (Icons.emoji_events_outlined, Colors.amber);
      case NotificationAlertType.prediction:
        return (Icons.insights, Colors.purple);
      case NotificationAlertType.breakingNews:
        return (Icons.newspaper, Colors.teal);
      case NotificationAlertType.transferNews:
        return (Icons.swap_horiz, Colors.indigo);
    }
  }
}
