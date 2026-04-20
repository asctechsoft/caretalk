import 'package:flutter/material.dart';
import 'package:care_talk/models/user_model.dart';
import 'package:care_talk/core/services/storage_service.dart';
import 'package:care_talk/core/network/api_gateway.dart';
import 'package:logger/logger.dart';

/// Provider quản lý trạng thái xác thực
class AuthProvider extends ChangeNotifier {
  final ApiGateway _api = ApiGateway();
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
    _isLoggedIn = await _storage.isLoggedIn();
    if (_isLoggedIn) {
      final userInfo = await _storage.getUserInfo();
      if (userInfo['userId'] != null) {
        _currentUser = UserModel(
          id: userInfo['userId']!,
          fullName: userInfo['userName'] ?? '',
          email: userInfo['userEmail'] ?? '',
          phone: '',
        );
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
      final response = await _api.login(email: email, password: password);

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;

        if (token != null) {
          await _storage.saveAccessToken(token);
        }

        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
          await _storage.saveUserInfo(
            userId: _currentUser!.id,
            userName: _currentUser!.fullName,
            userEmail: _currentUser!.email,
          );
        }

        await _storage.setLoggedIn(true);
        _isLoggedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response.message ?? 'Đăng nhập thất bại');
        _setLoading(false);
        return false;
      }
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
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _api.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      if (response.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message ?? 'Đăng ký thất bại');
        _setLoading(false);
        return false;
      }
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
      await _api.logout();
    } catch (e) {
      _logger.w('Logout API call failed: $e');
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
    _setLoading(true);

    try {
      final response = await _api.getUserProfile();
      if (response.isSuccess && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);
        await _storage.saveUserInfo(
          userId: _currentUser!.id,
          userName: _currentUser!.fullName,
          userEmail: _currentUser!.email,
        );
      }
    } catch (e) {
      _logger.e('Load profile error: $e');
    }

    _setLoading(false);
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _api.updateUserProfile(profileData: data);
      if (response.isSuccess && response.data != null) {
        _currentUser = UserModel.fromJson(response.data!);
        _setLoading(false);
        return true;
      } else {
        _setError(response.message ?? 'Cập nhật thất bại');
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
