import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final List<FoodItem> history;
  const HistoryScreen({super.key, required this.history});

  static const Color mintGreen = Color(0xFF8CE3BE);
  static const Color lightBackground = Color(0xFFF4F9F6);
  static const Color darkText = Color(0xFF2D312F);
  static const Color mediumText = Color(0xFF757D7A);

  void _showDetail(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.imageBytes != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.memory(item.imageBytes!, width: double.infinity, height: 250, fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                      Text('${item.calories} kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _nutrientInfo("Protein", "${item.protein}g"),
                      _nutrientInfo("Fat", "${item.fat}g"),
                      _nutrientInfo("Carbs", "${item.carbs}g"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Đóng"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: mediumText, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: darkText)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        title: const Text(
          'Lịch sử nạp dinh dưỡng',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: history.isEmpty 
        ? const Center(child: Text("Chưa có lịch sử ăn uống.", style: TextStyle(color: mediumText)))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return _buildHistoryCard(context, item);
            },
          ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, FoodItem item) {
    return GestureDetector(
      onTap: () => _showDetail(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: lightBackground,
                borderRadius: BorderRadius.circular(12),
                image: item.imageBytes != null 
                  ? DecorationImage(image: MemoryImage(item.imageBytes!), fit: BoxFit.cover)
                  : null,
              ),
              child: item.imageBytes == null ? const Icon(Icons.fastfood, color: mintGreen) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 4),
                  Text('${item.calories} kcal', style: const TextStyle(fontSize: 14, color: mediumText)),
                ],
              ),
            ),
            Text(DateFormat('HH:mm').format(item.dateTime), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkText)),
          ],
        ),
      ),
    );
  }
}
