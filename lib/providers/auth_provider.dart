import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:care_talk/models/user_model.dart';
import 'package:care_talk/core/services/storage_service.dart';
import 'package:care_talk/core/services/firebase_service.dart';
import 'package:care_talk/core/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Provider quản lý trạng thái xác thực
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storage = StorageService();
  final Logger _logger = Logger();

  // ─── State ─────────────────────────────────────────────────────────
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;

  // ─── Getters ───────────────────────────────────────────────────────
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // ═══════════════════════════════════════════════════════════════════
  // INIT - Kiểm tra trạng thái đăng nhập khi mở app
  // ═══════════════════════════════════════════════════════════════════
  Future<void> init() async {
    // Ưu tiên kiểm tra Firebase Auth session thực sự
    final firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      // Firebase có session hợp lệ → load profile từ Firestore
      _isLoggedIn = true;
      try {
        final userData = await _firebaseService.getDocument(
          collection: 'users',
          documentId: firebaseUser.uid,
        );
        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
        } else {
          // Fallback nếu Firestore chưa có doc
          _currentUser = UserModel(
            id: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            phone: '',
            role: 'patient',
          );
        }
      } catch (e) {
        _logger.e('init() - load Firestore profile error: $e');
        _currentUser = UserModel(
          id: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: '',
          role: 'patient',
        );
      }
    } else {
      // Firebase KHÔNG có session → fallback về StorageService
      _isLoggedIn = await _storage.isLoggedIn();
      if (_isLoggedIn) {
        final userInfo = await _storage.getUserInfo();
        if (userInfo['userId'] != null) {
          _currentUser = UserModel(
            id: userInfo['userId']!,
            fullName: userInfo['userName'] ?? '',
            email: userInfo['userEmail'] ?? '',
            phone: '',
            role: userInfo['userRole'] ?? 'patient',
          );
        }
        // Không có Firebase session thực sự → coi như chưa đăng nhập
        _logger.w(
          'StorageService có session nhưng FirebaseAuth.currentUser = null. Cần đăng nhập lại!',
        );
        _isLoggedIn = false;
        _currentUser = null;
        await _storage.clearAll();
      }
    }

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════════
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Lấy thông tin user từ Firestore
        final userData = await _firebaseService.getDocument(
          collection: 'users',
          documentId: user.uid,
        );

        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
          await _storage.saveUserInfo(
            userId: _currentUser!.id,
            userName: _currentUser!.fullName,
            userEmail: _currentUser!.email,
            userRole: _currentUser!.role,
          );
        }

        // Sync user với Backend Database (bất kể user có tồn tại trước chưa)
        // Backend sẽ tự xử lý nếu đã tồn tại rồi
        try {
          await ApiService().registerFirebase(
            firebaseUid: user.uid,
            email: email,
            phoneNumber: '',
            role: _currentUser?.role ?? 'patient',
            fullName: _currentUser?.fullName ?? user.displayName ?? '',
          );
          _logger.i('✅ Backend sync thành công cho user: ${user.uid}');
        } catch (e) {
          _logger.w('⚠️ Backend sync thất bại (có thể user đã tồn tại): $e');
        }

        await _storage.setLoggedIn(true);
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError('Đăng nhập thất bại');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Login error: ${e.code}');
      String message = 'Đã có lỗi xảy ra';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản với email này';
      } else if (e.code == 'wrong-password') {
        message = 'Mật khẩu không chính xác';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      _setError(message);
      _setLoading(false);
      return false;
    } catch (e) {
      _logger.e('Login error: $e');
      _setError('Đã có lỗi xảy ra. Vui lòng thử lại.');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════════════
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
    String role = 'patient',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Tạo user model
        final newUser = UserModel(
          id: user.uid,
          fullName: fullName,
          email: email,
          phone: phone,
          role: role,
          isProfileComplete: true,
        );

        // Lưu vào Firestore
        await _firebaseService.createDocument(
          collection: 'users',
          documentId: user.uid,
          data: newUser.toJson(),
        );

        // Lưu thêm vào bảng account
        await _firebaseService.createDocument(
          collection: 'account',
          documentId: user.uid,
          data: newUser.toJson(),
        );

        // Sync user với Backend Database
        try {
          await ApiService().registerFirebase(
            firebaseUid: user.uid,
            email: email,
            phoneNumber: phone,
            role: role,
            fullName: fullName,
          );
          _logger.i('✅ Backend sync thành công khi đăng ký: ${user.uid}');
        } catch (e) {
          _logger.w('⚠️ Backend sync thất bại khi đăng ký: $e');
        }

        _setLoading(false);
        return true;
      } else {
        _setError('Đăng ký thất bại');
        _setLoading(false);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Register error: ${e.code}');
      String message = 'Đã có lỗi xảy ra';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      }
      _setError(message);
      _setLoading(false);
      return false;
    } catch (e) {
      _logger.e('Register error: $e');
      _setError('Đã có lỗi xảy ra. Vui lòng thử lại.');
      _setLoading(false);
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════════
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _auth.signOut();
    } catch (e) {
      _logger.w('Logout FirebaseAuth failed: $e');
    }

    await _storage.clearAll();
    _currentUser = null;
    _isLoggedIn = false;
    _setLoading(false);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════
  Future<void> loadProfile() async {
    if (_currentUser == null) return;
    _setLoading(true);

    try {
      final userData = await _firebaseService.getDocument(
        collection: 'users',
        documentId: _currentUser!.id,
      );

      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
        await _storage.saveUserInfo(
          userId: _currentUser!.id,
          userName: _currentUser!.fullName,
          userEmail: _currentUser!.email,
          userRole: _currentUser!.role,
        );
      }
    } catch (e) {
      _logger.e('Load profile error: $e');
    }

    _setLoading(false);
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_currentUser == null) return false;
    _setLoading(true);
    _clearError();

    try {
      final success = await _firebaseService.updateDocument(
        collection: 'users',
        documentId: _currentUser!.id,
        data: data,
      );

      if (success) {
        // Reload profile after update
        await loadProfile();
        _setLoading(false);
        return true;
      } else {
        _setError('Cập nhật thất bại');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _logger.e('Update profile error: $e');
      _setError('Đã có lỗi xảy ra.');
      _setLoading(false);
      return false;
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
