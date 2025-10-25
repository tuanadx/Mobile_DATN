# Hướng dẫn Test Google Sign-In

## Bước 1: Cấu hình Google Cloud Console

1. **Lấy SHA-1 fingerprint:**
   ```bash
   # Chạy script đã tạo
   get_sha1.bat
   
   # Hoặc chạy trực tiếp
   cd android
   gradlew signingReport
   ```

2. **Tạo OAuth 2.0 Credentials:**
   - Truy cập [Google Cloud Console](https://console.cloud.google.com/)
   - Vào "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "OAuth 2.0 Client IDs"
   - Chọn "Android"
   - Package name: `com.example.SaveFood`
   - SHA-1: Copy từ kết quả gradlew signingReport

3. **Cập nhật Google Auth Service:**
   - Mở `lib/data/services/google_auth_service.dart`
   - Thay thế `YOUR_GOOGLE_CLIENT_ID` bằng Client ID từ Google Console

## Bước 2: Test trên thiết bị

1. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

2. **Test flow:**
   - Vào trang đăng nhập
   - Click "Tiếp tục với Google"
   - Kiểm tra Google Sign-In dialog xuất hiện
   - Chọn tài khoản Google
   - Kiểm tra đăng nhập thành công

## Bước 3: Kiểm tra lỗi thường gặp

### Lỗi "DEVELOPER_ERROR"
- **Nguyên nhân:** Package name hoặc SHA-1 không khớp
- **Giải pháp:** 
  - Kiểm tra package name trong `android/app/build.gradle.kts`
  - Kiểm tra SHA-1 fingerprint chính xác
  - Đảm bảo đã bật Google Sign-In API

### Lỗi "SIGN_IN_REQUIRED"
- **Nguyên nhân:** User hủy đăng nhập
- **Giải pháp:** Xử lý bình thường trong code (đã implement)

### Lỗi "NETWORK_ERROR"
- **Nguyên nhân:** Không có internet hoặc Google Play Services
- **Giải pháp:** 
  - Kiểm tra kết nối internet
  - Cài đặt Google Play Services trên thiết bị

## Bước 4: Debug

1. **Kiểm tra logs:**
   ```bash
   flutter logs
   ```

2. **Kiểm tra Google Console:**
   - Vào "APIs & Services" > "Credentials"
   - Xem OAuth 2.0 Client IDs
   - Kiểm tra package name và SHA-1

3. **Test trên emulator:**
   - Sử dụng emulator có Google Play Services
   - Hoặc test trên thiết bị thật

## Bước 5: Production Setup

1. **Tạo Release keystore:**
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Lấy SHA-1 của Release keystore:**
   ```bash
   keytool -list -v -keystore upload-keystore.jks -alias upload
   ```

3. **Thêm SHA-1 Release vào Google Console:**
   - Thêm SHA-1 của release keystore vào OAuth 2.0 credentials

## Lưu ý quan trọng

- **Package name** phải khớp chính xác
- **SHA-1 fingerprint** phải chính xác
- Test trên thiết bị thật để đảm bảo hoạt động
- Đảm bảo Google Sign-In API đã được bật
- Kiểm tra Google Play Services có sẵn trên thiết bị


