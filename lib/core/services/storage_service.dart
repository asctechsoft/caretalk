import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý local storage (SharedPreferences)
class StorageService {
  static StorageService? _instance;

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  StorageService._internal();

  // ─── Keys ──────────────────────────────────────────────────────────
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';

  // ═══════════════════════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ═══════════════════════════════════════════════════════════════════
  // USER INFO
  // ═══════════════════════════════════════════════════════════════════

  Future<void> saveUserInfo({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
  }

  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_keyUserId),
      'userName': prefs.getString(_keyUserName),
      'userEmail': prefs.getString(_keyUserEmail),
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // AUTH STATE
  // ═══════════════════════════════════════════════════════════════════

  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ═══════════════════════════════════════════════════════════════════
  // FIRST LAUNCH / ONBOARDING
  // ═══════════════════════════════════════════════════════════════════

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'vi';
  }

  // ═══════════════════════════════════════════════════════════════════
  // GENERIC
  // ═══════════════════════════════════════════════════════════════════

  Future<void> setValue<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  Future<T?> getValue<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  /// Xóa toàn bộ dữ liệu (logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Giữ lại first launch flag
    final isFirst = await isFirstLaunch();
    await prefs.clear();
    if (!isFirst) {
      await setFirstLaunchComplete();
    }
  }
}
