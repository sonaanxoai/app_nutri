# 🧠 Brainstorming: Android AI App (2-Day Sprint)

Chào hai bạn! Với thế mạnh về **AI và Code**, và mục tiêu báo cáo vào sáng thứ 7 (chỉ còn khoảng 48h), chúng ta cần một ý tưởng "WOW" nhưng khả thi.

Dưới đây là phân tích và định hướng tối ưu nhất:

## 1. So sánh 2 hướng đi

| Tiêu chí | **Hướng 1: AI Nutrition (Cái tớ ăn là gì?)** | **Hướng 2: AI Art & Security (Photo Studio)** |
| :--- | :--- | :--- |
| **Độ "WOW"** | Rất cao, tính ứng dụng thực tế lớn. | Cao ở phần mỹ thuật, mang tính demo kỹ thuật. |
| **Độ khó AI** | Thấp (nếu dùng Gemini API), Cao (nếu tự build). | Cao (Style Transfer & Steganography). |
| **Khả thi (48h)** | **Rất khả thi** (Gemini xử lý hết phần khó). | Khả thi nếu đã có sẵn Model TFLite/Pytorch. |
| **Điểm nhấn** | Dùng AI giải quyết bài toán sức khỏe. | Kết hợp văn hóa (Tranh Đông Hồ) & Bảo mật. |

---

## 2. Ý tưởng Đề xuất: "VinNutri AI - Trợ lý Dinh dưỡng Việt"

Thay vì làm một App Nutrition chung chung, hãy tập trung vào **Món ăn Việt Nam**.

### Cách giải quyết các "nút thắt":
*   **Nhận diện (Phở bò vs Phở gà):** Gemini 1.5 Flash cực giỏi việc này. Ta chỉ cần Prompt: *"Đây là món ăn gì của Việt Nam? Phân tích các thành phần chính nhìn thấy (thịt bò, bánh phở, rau...).*
*   **Ước lượng khối lượng (Volume Estimation):** Để giải quyết bài toán 2D->3D, ta sẽ dùng **"Reference UI"**. Khi chụp, hiện một khung hình mờ (overlay) hình cái bát hoặc cái đĩa. Bảo người dùng khớp bát cơm vào đó.
    *   *Prompt cho Gemini:* "Dựa vào tỷ lệ của cái bát so với đôi đũa/thìa trong ảnh, hãy ước lượng khối lượng và tính Calo cho người Việt."
*   **Database:** Không cần DB nội bộ, lấy trực tiếp kết quả phân tích từ Gemini làm "expert opinion".

### Tính năng chính (MVP):
1.  **AI Snap:** Chụp ảnh -> Nhận diện món ăn -> Xuất Calo/Carb/Protein (Gemini API).
2.  **Daily Log:** Lưu lịch sử ăn uống vào local (Room DB).
3.  **Health Dashboard:** Dashboard biểu đồ (MPAndroidChart) tổng lượng Calo trong ngày.
4.  **AI Advice:** Gợi ý: "Bạn đã ăn đủ đạm, chiều nay nên chạy bộ 20p để tiêu bớt cơm".

---

## 3. Kịch bản "Vibe & Code" trong 48h (Sprint Plan)

### 📅 Chiều & Tối Nay (Thứ 5): Foundation
*   Khởi tạo Project Android (Jetpack Compose).
*   Thiết kế UI/UX (Dùng Material 3, Dark mode cho "pro").
*   Tích hợp CameraX để chụp ảnh.
*   Setup Key Gemini API và gọi thử script nhận diện.

### 📅 Ngày Mai (Thứ 6): Features & Polish
*   **Sáng:** Code logic lưu History (Room DB).
*   **Chiều:** Vẽ biểu đồ Dashboard & AI Advice.
*   **Tối:** Fix bug, làm Slide báo cáo, quay video Demo (phòng trường hợp demo trực tiếp lỗi).

### 📅 Sáng Thứ 7: Báo cáo
*   Tự tin trình bày về cách dùng Generative AI để giải quyết bài toán Volume Estimation (phần mà mọi người nghĩ là khó nhất).

---

## 💡 Câu hỏi cho "Thông & Đạt":
1.  **Về Model Đông Hồ:** Nếu Thông đã có Model `.tflite` chạy được trên Android, chúng ta có thể thêm một tính năng **"Văn hóa"**: Cho phép biến ảnh đồ ăn thành một bức tranh Đông Hồ để khoe lên mạng "thực thần". Đây sẽ là điểm nhấn cực mạnh về sáng tạo!
2.  **Tech Stack:** Các bạn muốn dùng **Java** hay **Kotlin (Compose)**? (Khuyên dùng Compose để UI nhanh và đẹp).

**Chốt ý tưởng này không để mình bắt đầu khởi tạo cấu trúc thư mục và code những file đầu tiên luôn?**
