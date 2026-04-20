import 'package:flutter/material.dart';
import 'package:care_talk/models/chat_message_model.dart';
import 'package:care_talk/core/services/firebase_service.dart';
import 'package:care_talk/core/network/api_gateway.dart';
import 'package:logger/logger.dart';

/// Provider quản lý trạng thái Chat
class ChatProvider extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final ApiGateway _api = ApiGateway();
  final Logger _logger = Logger();

  // ─── State ─────────────────────────────────────────────────────────
  List<ChatMessageModel> _messages = [];
  List<ChatSessionModel> _sessions = [];
  String? _currentSessionId;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isTyping = false; // Bot đang trả lời
  String? _errorMessage;

  // ─── Getters ───────────────────────────────────────────────────────
  List<ChatMessageModel> get messages => _messages;
  List<ChatSessionModel> get sessions => _sessions;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  bool get hasMessages => _messages.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  /// Tạo phiên chat mới
  Future<String?> createSession({required String userId}) async {
    try {
      final sessionId = await _firebase.createDocument(
        collection: 'chat_sessions',
        data: {
          'user_id': userId,
          'is_active': true,
          'last_message': '',
        },
      );

      if (sessionId != null) {
        _currentSessionId = sessionId;
        _messages = [];
        notifyListeners();
      }

      return sessionId;
    } catch (e) {
      _logger.e('Create session error: $e');
      return null;
    }
  }

  /// Chọn phiên chat
  void selectSession(String sessionId) {
    _currentSessionId = sessionId;
    _messages = [];
    notifyListeners();
    loadMessages(sessionId);
  }

  /// Load danh sách sessions
  Future<void> loadSessions({required String userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sessionsData = await _firebase.getDocuments(
        collection: 'chat_sessions',
        filters: [
          QueryFilter(
            field: 'user_id',
            operator: FilterOperator.equals,
            value: userId,
          ),
        ],
        orderBy: 'updated_at',
        descending: true,
      );

      _sessions =
          sessionsData.map((s) => ChatSessionModel.fromJson(s)).toList();
    } catch (e) {
      _logger.e('Load sessions error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════════════════

  /// Load tin nhắn của session
  Future<void> loadMessages(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final messagesData = await _firebase.getDocuments(
        collection: 'chat_sessions/$sessionId/messages',
        orderBy: 'timestamp',
        descending: false,
      );

      _messages =
          messagesData.map((m) => ChatMessageModel.fromJson(m)).toList();
    } catch (e) {
      _logger.e('Load messages error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String message,
    required String senderId,
  }) async {
    if (message.trim().isEmpty) return;

    _isSending = true;
    notifyListeners();

    // Thêm tin nhắn người dùng vào list ngay lập tức (optimistic update)
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      senderId: senderId,
      senderType: SenderType.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    try {
      // Lưu tin nhắn vào Firestore
      if (_currentSessionId != null) {
        await _firebase.sendChatMessage(
          sessionId: _currentSessionId!,
          message: message,
          senderId: senderId,
          senderType: 'user',
        );
      }

      // Gọi API chatbot để lấy phản hồi
      _isTyping = true;
      _isSending = false;
      notifyListeners();

      final response = await _api.sendMessage(
        message: message,
        sessionId: _currentSessionId,
      );

      if (response.isSuccess && response.data != null) {
        final botReply = response.data!['reply'] as String? ??
            'Xin lỗi, tôi không hiểu yêu cầu của bạn.';

        final botMessage = ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: botReply,
          senderId: 'bot',
          senderType: SenderType.bot,
          timestamp: DateTime.now(),
        );
        _messages.add(botMessage);

        // Lưu phản hồi bot vào Firestore
        if (_currentSessionId != null) {
          await _firebase.sendChatMessage(
            sessionId: _currentSessionId!,
            message: botReply,
            senderId: 'bot',
            senderType: 'bot',
          );
        }
      } else {
        _addBotErrorMessage();
      }
    } catch (e) {
      _logger.e('Send message error: $e');
      _addBotErrorMessage();
    }

    _isTyping = false;
    _isSending = false;
    notifyListeners();
  }

  /// Lắng nghe tin nhắn realtime
  void listenToMessages(String sessionId) {
    _firebase.chatMessagesStream(sessionId: sessionId).listen(
      (messagesData) {
        _messages =
            messagesData.map((m) => ChatMessageModel.fromJson(m)).toList();
        notifyListeners();
      },
      onError: (e) {
        _logger.e('Listen messages error: $e');
      },
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────
  void _addBotErrorMessage() {
    _messages.add(ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
      senderId: 'bot',
      senderType: SenderType.bot,
      timestamp: DateTime.now(),
    ));
  }

  /// Xóa toàn bộ state (logout)
  void clear() {
    _messages = [];
    _sessions = [];
    _currentSessionId = null;
    _isLoading = false;
    _isSending = false;
    _isTyping = false;
    _errorMessage = null;
    notifyListeners();
  }
}
