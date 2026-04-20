import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:care_talk/app.dart';

/// Entry point của ứng dụng CareTalk
void main() async {
  // Đảm bảo Flutter binding được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình thanh trạng thái
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Cho phép xoay ngang trên tablet/web, chỉ dọc trên phone
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ─── Firebase Initialization ───────────────────────────────────────
  // TODO: Uncomment khi đã cấu hình Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // ─── Run App ───────────────────────────────────────────────────────
  runApp(const App());
}
