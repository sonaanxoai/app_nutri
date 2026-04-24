import 'dart:typed_data';

class FoodItem {
  final String name;
  final num calories;
  final num protein;
  final num fat;
  final num carbs;
  final num weight;
  final DateTime dateTime;
  final Uint8List? imageBytes;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.weight,
    required this.dateTime,
    this.imageBytes,
  });
}
