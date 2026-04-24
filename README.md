# VinNutri AI

Ứng dụng theo dõi dinh dưỡng và sức khỏe thông minh, được hỗ trợ bởi trí tuệ nhân tạo, chuyên dành cho món ăn Việt Nam.

## 📱 Tính năng chính

- **📷 AI Snap**: Chụp ảnh món ăn → AI phân tích và tính toán calo, protein, chất béo, tinh bột tự động
- **📊 Dashboard**: Theo dõi tổng quan calo nạp vào và đốt cháy trong ngày
- **🏃‍♂️ Vận động**: Theo dõi bước chân và calo tiêu thụ khi đi bộ
- **📜 Lịch sử**: Lưu trữ và xem lại các bữa ăn đã ghi nhận
- **👤 Hồ sơ**: Quản lý thông tin cá nhân và mục tiêu sức khỏe

## 🛠️ Công nghệ sử dụng

- **Framework**: Flutter (Dart)
- **AI Engine**: Google Gemini API (phân tích hình ảnh và lời khuyên dinh dưỡng)
- **Camera**: Tích hợp camera để chụp ảnh thực phẩm
- **Charts**: Fl Chart để hiển thị biểu đồ calo
- **Storage**: Shared Preferences để lưu dữ liệu cục bộ
- **Sensors**: Pedometer để theo dõi bước chân

## 🚀 Cài đặt và chạy

### Yêu cầu hệ thống
- Flutter SDK >= 3.5.0
- Dart SDK >= 3.5.0
- Android Studio hoặc VS Code với Flutter extension

### Các bước cài đặt
1. Clone repository:
   ```bash
   git clone https://github.com/sonaanxoai/app_nutri.git
   cd app_nutri
   ```

2. Cài đặt dependencies:
   ```bash
   flutter pub get
   ```

3. Chạy ứng dụng:
   ```bash
   flutter run
   ```

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                 # Điểm vào ứng dụng
├── models/
│   └── food_item.dart        # Model cho món ăn
├── screens/
│   ├── dashboard_screen.dart # Màn hình chính
│   ├── camera_screen.dart    # Màn hình chụp ảnh
│   ├── history_screen.dart   # Lịch sử bữa ăn
│   ├── fitness_screen.dart   # Theo dõi vận động
│   └── profile_screen.dart   # Hồ sơ cá nhân
└── services/
    └── gemini_service.dart   # Tích hợp AI Gemini
```

## 🔑 API Keys

Ứng dụng sử dụng Google Gemini API. Để chạy đầy đủ tính năng AI, cần cấu hình API key trong `lib/services/gemini_service.dart`.

## 📈 Screenshots

### Giao diện tổng quan
![Giao diện tổng quan](images/overview.png)

### Vận động đo sức khỏe
![Vận động đo sức khỏe](images/fitness.png)

### Hồ sơ kế hoạch
![Hồ sơ kế hoạch](images/profile.png)

## 🤝 Đóng góp

Chúng tôi hoan nghênh mọi đóng góp! Vui lòng tạo issue hoặc pull request.

## 📄 Giấy phép

Dự án này được phân phối dưới giấy phép MIT.

---

*Ứng dụng được phát triển trong khuôn khổ dự án học thuật, tập trung vào việc ứng dụng AI vào chăm sóc sức khỏe dinh dưỡng cho người Việt Nam.*
