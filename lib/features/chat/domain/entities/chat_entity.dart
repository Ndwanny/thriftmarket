import 'package:equatable/equatable.dart';

enum MessageType { text, image, file, order }

class MessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;
  final String? fileUrl;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.fileUrl,
  });

  @override
  List<Object?> get props => [id, chatId, isRead];
}

class ChatEntity extends Equatable {
  final String id;
  final String buyerId;
  final String vendorId;
  final String vendorName;
  final String? vendorLogoUrl;
  final MessageEntity? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  const ChatEntity({
    required this.id,
    required this.buyerId,
    required this.vendorId,
    required this.vendorName,
    this.vendorLogoUrl,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, vendorId, unreadCount];
}
