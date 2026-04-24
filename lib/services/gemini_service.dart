import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import 'dart:convert';

class GeminiService {
  // KHÔNG DÙNG 1.5 - THỬ DÙNG 1.0 PRO VISION (MODEL ĐỜI ĐẦU)
  static final List<String> _models = [
    'gemini-2.5-flash-lite',
    'gemini-3-flash-preview',
    'gemini-3.1-flash-lite-preview',
    'gemini-2.0-flash-lite',
  ];

  static const String _apiKey = 'AIzaSyCGw-lktcdERN2OyQsMMatqssI-j8GOZm8';

  Future<Map<String, dynamic>> analyzeFood(Uint8List imageBytes) async {
    final content = [
      Content.multi([
        TextPart("""
Bạn là chuyên gia dinh dưỡng VinNutri AI. Hãy phân tích hình ảnh món ăn này và trả về JSON chuẩn:
{
  "name": "Tên món ăn tổng thể",
  "items": [
    {"name": "Tên thành phần 1", "calories": 0},
    {"name": "Tên thành phần 2", "calories": 0}
  ],
  "calories": 0,
  "protein": 0,
  "fat": 0,
  "carbs": 0,
  "weight": 0,
  "description": "Mô tả chi tiết hơn"
}
Lưu ý: Trả về DUY NHẤT mã JSON.
"""),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    String? lastError;

    for (String modelName in _models) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );

        // Tăng lên 35s để đủ thời gian upload ảnh và xử lý
        final response = await model.generateContent(content).timeout(const Duration(seconds: 35));
        
        if (response.text != null) {
          String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(cleanJson) as Map<String, dynamic>;
        }
      } catch (e) {
        lastError = e.toString();
        print("Model $modelName gặp lỗi: $e");
        continue; 
      }
    }

    throw Exception("Lỗi AI: $lastError");
  }
  // Hàm sinh kế hoạch dinh dưỡng cá nhân hóa (Đã nâng cấp trả về JSON)
  Future<Map<String, dynamic>> generateDietPlan(String height, String weight, String budget, String ingredients, String goal) async {
    final prompt = """
Bạn là một chuyên gia dinh dưỡng thực tế cho sinh viên.
Dựa vào: Cao $height cm, Nặng $weight kg, Mục tiêu: $goal, Ngân sách tuần: $budget VNĐ, Nguyên liệu có: $ingredients.

Hãy trả về DUY NHẤT một mã JSON theo đúng định dạng sau (không markdown, không giải thích thêm):
{
  "intro": "Lời chào và động viên ngắn gọn (khoảng 3-4 câu).",
  "sections": [
    {
      "icon": "📊",
      "title": "Đánh giá nhanh & Mục tiêu Calo",
      "content": "Chi tiết đánh giá BMI và lượng calo cần thiết..."
    },
    {
      "icon": "🛒",
      "title": "Kế hoạch đi chợ ($budget)",
      "content": "Phân bổ chi tiết số tiền mua thực phẩm..."
    },
    {
      "icon": "🍳",
      "title": "Bí quyết nấu ăn ngon rẻ",
      "content": "Cách chế biến không bị khô, ngán..."
    },
    {
      "icon": "🍚",
      "title": "Định lượng chi tiết các bữa",
      "content": "Cụ thể cần ăn mấy bát cơm, bao nhiêu gram thịt..."
    }
  ]
}
""";

    String? lastError;

    for (String modelName in _models) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          // Ép AI trả về JSON chuẩn
          generationConfig: GenerationConfig(responseMimeType: 'application/json'),
        );

        final response = await model.generateContent([Content.text(prompt)]).timeout(const Duration(seconds: 45));
        
        if (response.text != null && response.text!.isNotEmpty) {
          String cleanJson = response.text!.replaceAll('```json', '').replaceAll('```', '').trim();
          return jsonDecode(cleanJson) as Map<String, dynamic>;
        }
      } catch (e) {
        lastError = e.toString();
        print("Model $modelName gặp lỗi: $e");
        continue; 
      }
    }

    throw Exception("Lỗi hệ thống AI: $lastError");
  }
  // Hàm nhận lời khuyên nhanh (ngắn gọn)
  Future<String> getQuickAdvice(String foodName, num foodCarbs, String goal) async {
    final prompt = "Tôi vừa ăn $foodName có $foodCarbs g Carb. Mục tiêu của tôi là $goal. Hãy cho tôi 1 lời khuyên cực kỳ ngắn gọn (dưới 30 từ) về việc cần nạp thêm bao nhiêu Carb nữa trong ngày hôm nay và nên ăn gì.";
    
    try {
      final model = GenerativeModel(model: _models.first, apiKey: _apiKey);
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "Hãy tiếp tục theo dõi thực đơn nhé!";
    } catch (e) {
      return "Cố gắng nạp đủ Carb để đạt mục tiêu $goal bạn nhé!";
    }
  }
}
