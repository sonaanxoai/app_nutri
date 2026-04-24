# 🏗️ Technical Architecture: VinNutri AI

Dưới đây là sơ đồ kiến trúc và stack kỹ thuật đề xuất để hoàn thành trong 2 ngày:

## 1. Tech Stack
*   **Language:** Kotlin (Modern & Safe).
*   **UI Framework:** Jetpack Compose (Code nhanh, giao diện hiện đại).
*   **Image Processing:** CameraX (Tự động lấy nét, phân tích frame).
*   **AI Engine:** Gemini 1.5 Flash (Xử lý đa phương thức - Vision & Text, tốc độ cực nhanh).
*   **Local Storage:** Room Database (Lưu lịch sử bữa ăn).
*   **Charts:** MPAndroidChart hoặc Compose Charts (Vẽ Dashboard Calo).

## 2. Luồng xử lý AI (The "Brain")
Để giải quyết bài toán "Cái bát to hay nhỏ", ta sẽ dùng kỹ thuật **Contextual Prompting**:

1.  **User chụp ảnh:** Hệ thống lấy Metadata về tiêu cự hoặc dùng Frame Overlay để cố định khoảng cách.
2.  **Prompt gửi Gemini:**
    > "Phân tích ảnh này: 1. Đây là món ăn Việt Nam nào? 2. Dựa vào kích thước tương đối của bát/đĩa so với mặt bàn hoặc thìa/đũa, hãy ước lượng khối lượng (gram). 3. Tính Calo, Protein, Carb, Fat. 4. Trả về định dạng JSON."
3.  **Kết quả:** Hiển thị trực tiếp lên UI (AR Style) để người dùng xác nhận hoặc sửa lại khối lượng.

## 3. Cấu trúc Project (Package Structure)
```text
com.nhom1.vinnutri
├── ui
│   ├── theme (Design System: Green, Healthy, Glassmorphism)
│   ├── components (CameraView, NutritionCard, HistoryItem)
│   ├── screens (HomeScreen, DiaryScreen, DashboardScreen)
├── data
│   ├── local (Room DB: MealEntity, MealDao)
│   ├── remote (GeminiApiService, Retrofit)
│   ├── repository (MealRepository)
├── model (Meal, NutritionInfo)
└── util (ImageUtils, GeminiPromptHelper)
```

## 4. Kế hoạch Code tối nay (Day 1 - Part 1)
Nếu các bạn đồng ý, mình sẽ bắt đầu viết:
1.  `build.gradle.kts` (Dependencies).
2.  `Local Database` (Room).
3.  `CameraX integration` (Màn hình chụp ảnh).
4.  `Gemini Integration` (Interface gọi API).

**Các bạn thấy sao? Mình triển khai ngay chứ?**
