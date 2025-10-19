# Hướng dẫn cấu hình Google Sign-In cho Android

## Bước 1: Tạo Google Cloud Console Project

1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Tạo project mới hoặc chọn project hiện có
3. Bật Google Sign-In API:
   - Vào "APIs & Services" > "Library"
   - Tìm "Google Sign-In API" và bật nó

## Bước 2: Tạo OAuth 2.0 Credentials

1. Vào "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Chọn "Android" làm Application type
4. Nhập thông tin:
   - **Name**: Feedia Android App
   - **Package name**: `com.example.feedia` (thay đổi theo package name thực tế)
   - **SHA-1 certificate fingerprint**: (xem hướng dẫn bên dưới)

## Bước 3: Lấy SHA-1 Fingerprint

### Cách 1: Sử dụng keytool (Debug keystore)
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Cách 2: Sử dụng Gradle (trong Android Studio)
```bash
cd android
./gradlew signingReport
```

### Cách 3: Sử dụng Flutter
```bash
cd android
./gradlew signingReport
```

## Bước 4: Cập nhật Google Auth Service

1. Mở file `lib/data/services/google_auth_service.dart`
2. Thay thế `YOUR_GOOGLE_CLIENT_ID` bằng Client ID từ Google Console:
```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com',
  scopes: [
    'email',
    'profile',
  ],
);
```

## Bước 5: Cập nhật AndroidManifest.xml

Thêm meta-data cho Google Sign-In vào `<application>` tag:

```xml
<!-- Google Sign-In -->
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

## Bước 6: Cập nhật build.gradle

Thêm Google Play Services vào `android/app/build.gradle`:

```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

## Bước 7: Test

1. Chạy ứng dụng: `flutter run`
2. Vào trang đăng nhập
3. Click "Tiếp tục với Google"
4. Kiểm tra xem có hiển thị Google Sign-In dialog không

## Lưu ý quan trọng

- **Package name** phải khớp với package name trong `android/app/build.gradle`
- **SHA-1 fingerprint** phải chính xác
- Đảm bảo Google Sign-In API đã được bật
- Test trên thiết bị thật, không phải emulator (trừ khi emulator có Google Play Services)

## Troubleshooting

### Lỗi "DEVELOPER_ERROR"
- Kiểm tra package name có khớp không
- Kiểm tra SHA-1 fingerprint có đúng không
- Đảm bảo đã bật Google Sign-In API

### Lỗi "SIGN_IN_REQUIRED"
- User đã hủy đăng nhập
- Xử lý bình thường trong code

### Lỗi "NETWORK_ERROR"
- Kiểm tra kết nối internet
- Kiểm tra Google Play Services có được cài đặt không


