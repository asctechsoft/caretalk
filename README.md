# CareTalk

A cross-platform Flutter project.

## Hướng dẫn chạy code (Run Instructions)

### Yêu cầu hệ thống (Prerequisites)
- Đã cài đặt [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Đã cài đặt một IDE như Android Studio hoặc VS Code.
- Đã thiết lập máy ảo (Emulator) hoặc trình duyệt web (Chrome) để chạy code.

### Các bước cài đặt và chạy

1. **Cài đặt các dependencies:**
   Mở terminal tại thư mục gốc của project và chạy lệnh:
   ```bash
   flutter pub get
   ```

2. **Chạy ứng dụng:**
   - **Để chạy trên thiết bị Mobile (Android/iOS):**
     1. Mở máy ảo (Emulator) từ Android Studio / Xcode hoặc kết nối trực tiếp với thiết bị thật của bạn.
     2. Kiểm tra xem Flutter đã nhận thiết bị chưa bằng lệnh:
        ```bash
        flutter devices
        ```
     3. Nếu có nhiều thiết bị, bạn có thể chọn thiết bị để chạy (ví dụ `flutter run -d <device_id>`), hoặc đơn giản chạy lệnh sau để chọn từ danh sách:
        ```bash
        flutter run
        ```
     *(Tuỳ chọn) Nếu bạn muốn build thành file cài đặt (APK) cho hệ điều hành Android:*
     ```bash
     flutter build apk
     ```
     File cài sau khi build xong sẽ nằm ở đường dẫn: `build/app/outputs/flutter-apk/app-release.apk`
     
   - **Để chạy trên Web (Chrome):**
     ```bash
     flutter run -d chrome
     ```

### Deploy lên Firebase (Tùy chọn)
Để deploy ứng dụng lên Firebase Hosting, bạn sử dụng lệnh sau:
```bash
firebase deploy --only hosting
```
