import 'package:equatable/equatable.dart';

/// Loại người gửi tin nhắn
enum SenderType {
  user,
  bot,
  doctor,
}

extension SenderTypeExt on SenderType {
  String get value {
    switch (this) {
      case SenderType.user:
        return 'user';
      case SenderType.bot:
        return 'bot';
      case SenderType.doctor:
        return 'doctor';
    }
  }

  static SenderType fromString(String value) {
    switch (value) {
      case 'user':
        return SenderType.user;
      case 'bot':
        return SenderType.bot;
      case 'doctor':
        return SenderType.doctor;
      default:
        return SenderType.bot;
    }
  }
}

/// Model tin nhắn chat
class ChatMessageModel extends Equatable {
  final String id;
  final String message;
  final String senderId;
  final SenderType senderType;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType; // 'image', 'file', 'audio'

  const ChatMessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderType,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderType: SenderTypeExt.fromString(json['sender_type'] ?? 'bot'),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender_id': senderId,
      'sender_type': senderType.value,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };
  }

  /// Kiểm tra tin nhắn từ người dùng
  bool get isFromUser => senderType == SenderType.user;

  /// Kiểm tra tin nhắn từ bot
  bool get isFromBot => senderType == SenderType.bot;

  @override
  List<Object?> get props => [
        id,
        message,
        senderId,
        senderType,
        timestamp,
        isRead,
        attachmentUrl,
        attachmentType,
      ];
}

/// Model phiên chat
class ChatSessionModel extends Equatable {
  final String id;
  final String userId;
  final String? patientId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isActive;
  final DateTime? createdAt;

  const ChatSessionModel({
    required this.id,
    required this.userId,
    this.patientId,
    this.lastMessage,
    this.lastMessageAt,
    this.isActive = true,
    this.createdAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      patientId: json['patient_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'patient_id': patientId,
      'last_message': lastMessage,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        patientId,
        lastMessage,
        lastMessageAt,
        isActive,
        createdAt,
      ];
}
