import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:async';
import 'dart:convert';

class GeminiService {
  // KHÔNG DÙNG 1.5 - THỬ DÙNG 1.0 PRO VISION (MODEL ĐỜI ĐẦU)
  static final List<String> _models = [
    'gemini-2.5-flash-lite',
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

        final response = await model.generateContent(content).timeout(const Duration(seconds: 60));
        
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
}
