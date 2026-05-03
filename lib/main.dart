import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:care_talk/firebase_options.dart';
import 'package:care_talk/app.dart';

/// Entry point của ứng dụng CareTalk
void main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Ẩn thanh điều hướng hệ thống (navigation bar) phía dưới, giữ status bar
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top], // chỉ hiện status bar, ẩn nav bar
  );

  // Cấu hình màu thanh trạng thái và navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Cho phép xoay ngang trên tablet/web, chỉ dọc trên phone
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── Firebase Initialization ───────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ─── Run App ───────────────────────────────────────────────────────
  runApp(const App());
}
