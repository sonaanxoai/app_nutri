# 🚀 Kinh Nghiệm Build APK Flutter (Target SDK 34)

Tài liệu này tổng hợp các giải pháp cho các lỗi thường gặp khi build APK, đặc biệt là khi gặp xung đột phiên bản SDK giữa các plugin đời mới và yêu cầu target thấp hơn.

---

## 1. Xử lý xung đột Android SDK (Plugin yêu cầu 35, App yêu cầu 34)
Khi gặp lỗi: *"Your project is configured to compile against Android SDK 34, but plugin X requires 35"*.

**Giải pháp:** Đừng hạ cấp plugin (dễ gây lỗi code). Thay vào đó, hãy **ép (Force)** phiên bản SDK trong file `android/build.gradle`.

Mở file `android/build.gradle` (thư mục gốc Android) và thêm đoạn mã sau vào cuối:

```gradle
subprojects {
    afterEvaluate { project ->
        if (project.plugins.hasPlugin('com.android.application') || 
            project.plugins.hasPlugin('com.android.library')) {
            project.android {
                compileSdk = 34
                buildToolsVersion = "34.0.0"
                defaultConfig {
                    targetSdk = 34
                }
            }
        }
    }
}
```
*Lưu ý: Cách này giúp bạn vẫn dùng được các plugin mới nhất nhưng quy trình build vẫn tuân thủ SDK 34.*

---

## 2. Đồng bộ JDK và Kotlin (Lỗi build ngay lập tức)
Nếu máy bạn cài Java phiên bản rất mới (như JDK 25), các phiên bản Kotlin cũ sẽ không hiểu và gây lỗi `IllegalArgumentException`.

**Giải pháp:** Nâng cấp Kotlin lên bản mới nhất (ví dụ: `2.0.0`) trong `android/settings.gradle`:

```gradle
plugins {
    // ...
    id "org.jetbrains.kotlin.android" version "2.0.0" apply false
}
```

---

## 3. Nâng cấp bộ công cụ Build (AGP & Gradle)
Để hỗ trợ SDK 34/35 và Java mới, cần bộ đôi AGP và Gradle tương xứng:

1.  **AGP (Android Gradle Plugin):** Trong `android/settings.gradle`, dùng bản `8.3.2` trở lên.
2.  **Gradle Wrapper:** Trong `android/gradle/wrapper/gradle-wrapper.properties`, dùng bản `8.7` trở lên:
    ```properties
    distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip
    ```

---

## 4. Lỗi "Namespace not specified" (Lỗi AGP 8+)
Kể từ AGP 8.0, mọi plugin và app phải có thuộc tính `namespace` trong file `build.gradle`.

**Giải pháp:** Tránh dùng các plugin quá cũ (như `pedometer 4.0.0`). Hãy dùng bản mới nhất (ví dụ `4.1.1+`) vì chúng đã được cập nhật namespace sẵn.

---

## 5. Quy trình Build chuẩn (Build 1 lần là được)

Để tránh các lỗi lưu đệm (cache), hãy chạy theo thứ tự:

1.  **Dọn dẹp:** `flutter clean`
2.  **Cập nhật thư viện:** `flutter pub get`
3.  **Build APK:** `flutter build apk --debug` (hoặc `--release` cho bản chính thức).

---

## Summary (Thông số hiện tại của dự án):
| Thành phần | Phiên bản khuyến nghị (Ver 03) |
| :--- | :--- |
| **Compile SDK** | 34 |
| **Target SDK** | 34 |
| **Kotlin** | 2.0.0 |
| **Gradle** | 8.10.2 |
| **AGP** | 8.6.0 |
| **Java** | JDK 22 - 25 |

---

## 6. Tổng hợp "Bí kíp" Build thành công App VinNutri (Ver 03)

Sau khi fix hàng loạt lỗi "Unknown property flutter" và xung đột JDK, đây là cấu hình chuẩn nhất:

### A. Cấu hình Gradle & JDK (Dành cho máy cài JDK 22-25)
Nếu máy bạn dùng Java đời mới (như JDK 25), bạn **BẮT BUỘC** phải nâng cấp Gradle để tránh lỗi không nhận diện được Plugin:
- File `android/gradle/wrapper/gradle-wrapper.properties`:
  ```properties
  distributionUrl=https\://services.gradle.org/distributions/gradle-8.10.2-all.zip
  ```
- File `android/settings.gradle`: Dùng AGP bản mới để đồng bộ:
  ```gradle
  id "com.android.application" version "8.6.0" apply false
  ```

### B. Fix lỗi "Could not get unknown property 'flutter'"
Đây là lỗi ức chế nhất khi Build Flutter 3.24+. Lỗi này xảy ra khi các plugin (như Geolocator) không tự tìm thấy thông số Flutter.
**Giải pháp:** Ép thông số vào ngay trong `android/build.gradle` (file gốc):
```gradle
allprojects {
    repositories { ... }
    // 🔥 Tiêm trực tiếp extension flutter để cứu các plugin đời cũ
    project.ext {
        flutter = [
            compileSdkVersion: 34,
            minSdkVersion: 21,
            targetSdkVersion: 34
        ]
    }
}
```

### C. Ép phiên bản SDK cho toàn bộ Plugin (Subprojects)
Để chắc chắn không có plugin nào đòi SDK 35 (gây lỗi khi upload store hoặc build), dùng đoạn code này trong `android/build.gradle`:
```gradle
subprojects {
    afterEvaluate { project ->
        if (project.extensions.findByName('android') != null) {
            project.android {
                compileSdk 34
                buildToolsVersion = "34.0.0"
                defaultConfig {
                    targetSdk 34
                }
            }
        }
    }
}
```

### D. Lưu ý về Sensors (Pedometer & Geolocator)
- **Pedometer (Đo bước chân):** Ổn định, đo thật qua cảm biến phần cứng. Lưu ý phải cấp quyền `ACTIVITY_RECOGNITION`.
- **Geolocator (GPS):** Đôi khi gây lỗi Build do cấu hình Gradle bên trong plugin quá cũ. Nếu Build lỗi liên tục ở plugin này, hãy cân nhắc dùng Pedometer để đo bước chân thay thế.

## 🚀 Quy trình Build 1-phát-ăn-ngay (Shortcut):
1.  Mở màn hình `local.properties`: Kiểm tra `flutter.sdk` và ép `flutter.targetSdkVersion=34`.
2.  Chạy lệnh:
    ```powershell
    flutter clean
    flutter pub get
    flutter build apk --release
    ```
3.  File output luôn tại: `build\app\outputs\flutter-apk\app-release.apk`

---

## 7. Giải mã lỗi "Must provide Flutter source directory"
Nếu bạn gặp lỗi này khi build, có nghĩa là Plugin Gradle của Flutter không tìm thấy thư mục gốc của app.

**Cách fix:** Kiểm tra file `android/app/build.gradle`. Đảm bảo khối `flutter {}` nằm **ngoài** khối `android {}` và trỏ đúng đường dẫn:
```gradle
flutter {
    source = "../.."
}
```

---
*Cập nhật ngày: 24/04/2026 - By Antigravity AI (VinNutri Finalized)*
