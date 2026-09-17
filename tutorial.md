📋 Bước 1: Kiểm tra môi trường & Thiết bị Android
Mở Terminal tại thư mục D:\code\DATN\sourceCode\AppMobile và thực hiện:

Kiểm tra Flutter & Android SDK:

bash
flutter doctor
(Đảm bảo mục Android toolchain có dấu tích xanh ✅)

Chuẩn bị thiết bị Android:

Cách A: Dùng Máy ảo (Android Emulator)
Mở Android Studio ➔ Device Manager ➔ Nhấn Play để bật 1 máy ảo Android.
Cách B: Dùng Điện thoại thật
Trên điện thoại: Vào Cài đặt ➔ Thông tin điện thoại ➔ Nhấn 7 lần vào Số phiên bản (Build Number) để bật Chế độ nhà phát triển.
Vào Tùy chọn nhà phát triển ➔ Bật Gỡ lỗi USB (USB Debugging).
Cắm cáp USB nối điện thoại với máy tính và chọn "Luôn cho phép gỡ lỗi từ máy tính này".
Kiểm tra thiết bị đã nhận diện chưa:

bash
flutter devices
(Bạn sẽ thấy thiết bị Android xuất hiện trong danh sách).

🚀 Bước 2: Tải các thư viện phụ thuộc (Dependencies)
Tại terminal folder AppMobile, chạy:

bash
flutter pub get
📲 Bước 3: Lệnh khởi chạy ứng dụng
Cách 1: Chạy bằng dòng lệnh (Terminal)
bash
flutter run
Nếu có nhiều thiết bị connected, chạy: flutter run -d <device_id> (Ví dụ: flutter run -d chrome hoặc flutter run -d emulator-5554).
Cách 2: Chạy trực tiếp trong VS Code (Khuyên dùng)
Mở folder AppMobile trong VS Code.
Nhìn xuống góc dưới bên phải thanh trạng thái của VS Code ➔ Chọn thiết bị Android của bạn.
Nhấn phím F5 (hoặc menu Run ➔ Start Debugging).
⚠️ Lưu ý quan trọng khi gọi API Backend Spring Boot:
Đảm bảo Backend đang chạy: Project Spring Boot learninghub đang chạy ở cổng 8080.
Nếu dùng Điện thoại thật:
Điện thoại và máy tính cần kết nối chung 1 mạng Wi-Fi.
API IP 192.168.0.103 đã được thiết lập sẵn trong 

api_endpoints.dart
.
Tính năng Hot Reload: Khi sửa code Flutter, bấm r ở terminal hoặc biểu tượng ⚡ Hot Reload trên thanh công cụ VS Code để cập nhật giao diện ngay lập tức mà không cần build lại.