import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Service quản lý tất cả tương tác với Firebase Firestore
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  static FirebaseService? _instance;

  factory FirebaseService() {
    _instance ??= FirebaseService._internal();
    return _instance!;
  }

  FirebaseService._internal();

  // ─── Collection References ─────────────────────────────────────────
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get patientsCollection =>
      _firestore.collection('patients');
  CollectionReference get chatSessionsCollection =>
      _firestore.collection('chat_sessions');
  CollectionReference get messagesCollection =>
      _firestore.collection('messages');
  CollectionReference get appointmentsCollection =>
      _firestore.collection('appointments');

  // ═══════════════════════════════════════════════════════════════════
  // GENERIC CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════════

  /// Tạo document mới
  Future<String?> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      final collectionRef = _firestore.collection(collection);
      DocumentReference docRef;

      if (documentId != null) {
        docRef = collectionRef.doc(documentId);
        await docRef.set({
          ...data,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      } else {
        docRef = await collectionRef.add({
          ...data,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      _logger.d('Document created: ${docRef.id} in $collection');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating document in $collection: $e');
      return null;
    }
  }

  /// Đọc document theo ID
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      _logger.e('Error getting document $documentId from $collection: $e');
      return null;
    }
  }

  /// Đọc danh sách documents
  Future<List<Map<String, dynamic>>> getDocuments({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
    List<QueryFilter>? filters,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Áp dụng filters
      if (filters != null) {
        for (final filter in filters) {
          switch (filter.operator) {
            case FilterOperator.equals:
              query = query.where(filter.field, isEqualTo: filter.value);
              break;
            case FilterOperator.notEquals:
              query = query.where(filter.field, isNotEqualTo: filter.value);
              break;
            case FilterOperator.greaterThan:
              query = query.where(filter.field, isGreaterThan: filter.value);
              break;
            case FilterOperator.lessThan:
              query = query.where(filter.field, isLessThan: filter.value);
              break;
            case FilterOperator.arrayContains:
              query = query.where(filter.field, arrayContains: filter.value);
              break;
            case FilterOperator.whereIn:
              query = query.where(filter.field, whereIn: filter.value as List);
              break;
          }
        }
      }

      // Sắp xếp
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Giới hạn
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>)})
          .toList();
    } catch (e) {
      _logger.e('Error getting documents from $collection: $e');
      return [];
    }
  }

  /// Cập nhật document
  Future<bool> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      _logger.d('Document updated: $documentId in $collection');
      return true;
    } catch (e) {
      _logger.e('Error updating document $documentId in $collection: $e');
      return false;
    }
  }

  /// Xóa document
  Future<bool> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      _logger.d('Document deleted: $documentId from $collection');
      return true;
    } catch (e) {
      _logger.e('Error deleting document $documentId from $collection: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REAL-TIME STREAMS
  // ═══════════════════════════════════════════════════════════════════

  /// Stream theo dõi thay đổi document
  Stream<Map<String, dynamic>?> documentStream({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    });
  }

  /// Stream theo dõi danh sách documents
  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collection,
    String? orderBy,
    bool descending = false,
    int? limit,
    List<QueryFilter>? filters,
  }) {
    Query query = _firestore.collection(collection);

    if (filters != null) {
      for (final filter in filters) {
        switch (filter.operator) {
          case FilterOperator.equals:
            query = query.where(filter.field, isEqualTo: filter.value);
            break;
          case FilterOperator.notEquals:
            query = query.where(filter.field, isNotEqualTo: filter.value);
            break;
          case FilterOperator.greaterThan:
            query = query.where(filter.field, isGreaterThan: filter.value);
            break;
          case FilterOperator.lessThan:
            query = query.where(filter.field, isLessThan: filter.value);
            break;
          case FilterOperator.arrayContains:
            query = query.where(filter.field, arrayContains: filter.value);
            break;
          case FilterOperator.whereIn:
            query = query.where(filter.field, whereIn: filter.value as List);
            break;
        }
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...(doc.data() as Map<String, dynamic>)})
          .toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // CHAT SPECIFIC
  // ═══════════════════════════════════════════════════════════════════

  /// Stream tin nhắn realtime cho một session
  Stream<List<Map<String, dynamic>>> chatMessagesStream({
    required String sessionId,
  }) {
    return _firestore
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...(doc.data())})
              .toList(),
        );
  }

  /// Gửi tin nhắn vào chat session
  Future<String?> sendChatMessage({
    required String sessionId,
    required String message,
    required String senderId,
    required String senderType, // 'user', 'bot', 'doctor'
  }) async {
    try {
      final docRef = await _firestore
          .collection('chat_sessions')
          .doc(sessionId)
          .collection('messages')
          .add({
            'message': message,
            'sender_id': senderId,
            'sender_type': senderType,
            'timestamp': FieldValue.serverTimestamp(),
            'is_read': false,
          });

      // Cập nhật last_message trong session
      await _firestore.collection('chat_sessions').doc(sessionId).update({
        'last_message': message,
        'last_message_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      _logger.e('Error sending chat message: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PATIENT SPECIFIC
  // ═══════════════════════════════════════════════════════════════════

  /// Stream danh sách bệnh nhân đang chờ (realtime)
  Stream<List<Map<String, dynamic>>> waitingPatientsStream() {
    return _firestore
        .collection('patients')
        .where('status', isEqualTo: 'waiting')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...(doc.data())})
              .toList(),
        );
  }
}

// ─── Query Filter Helper ─────────────────────────────────────────────
enum FilterOperator {
  equals,
  notEquals,
  greaterThan,
  lessThan,
  arrayContains,
  whereIn,
}

class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  const QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });
}
