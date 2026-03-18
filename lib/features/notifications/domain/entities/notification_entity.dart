import 'package:equatable/equatable.dart';

enum NotificationType {
  order, payment, promotion, system, chat, review
}

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final String? actionId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.actionRoute,
    this.actionId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, isRead];
}
