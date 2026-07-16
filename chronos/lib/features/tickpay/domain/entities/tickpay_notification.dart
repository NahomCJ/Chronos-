import 'package:equatable/equatable.dart';

/// The visual/semantic category of a notification, used to pick its icon.
enum TickpayNotificationType { payment, offer, approval, info }

/// A single entry on the Notifications screen.
class TickpayNotification extends Equatable {
  final TickpayNotificationType type;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final bool isImportant;

  const TickpayNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
    this.isImportant = false,
  });

  @override
  List<Object?> get props =>
      [type, title, message, time, isUnread, isImportant];
}
