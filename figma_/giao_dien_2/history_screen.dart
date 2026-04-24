import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Giữ nguyên Color Palette
  static const Color mintGreen = Color(0xFF8CE3BE);
  static const Color lightBackground = Color(0xFFF4F9F6);
  static const Color darkText = Color(0xFF2D312F);
  static const Color mediumText = Color(0xFF757D7A);

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=11'),
              backgroundColor: mintGreen.withOpacity(0.3),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildDateGroup('Hôm nay, 24/04/2026', [
            {'name': 'Bánh cuốn', 'calo': '650 kcal', 'time': '10:32 AM'},
            {'name': 'Cà phê sữa đá', 'calo': '180 kcal', 'time': '11:15 AM'},
          ]),
          const SizedBox(height: 24),
          _buildDateGroup('Hôm qua, 23/04/2026', [
            {'name': 'Cơm tấm', 'calo': '750 kcal', 'time': '12:10 PM'},
            {'name': 'Chè đậu đen', 'calo': '310 kcal', 'time': '8:45 PM'},
          ]),
          const SizedBox(height: 24),
          _buildDateGroup('22/04/2026', [
            {'name': 'Bún chả', 'calo': '690 kcal', 'time': '1:30 PM'},
          ]),
          const SizedBox(height: 100), // Không gian trống cho Bottom Nav
        ],
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildHistoryCard(item['name']!, item['calo']!, item['time']!)),
      ],
    );
  }

  Widget _buildHistoryCard(String name, String calo, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: lightBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fastfood, color: mintGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 4),
                Text(calo, style: const TextStyle(fontSize: 14, color: mediumText)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: darkText)),
        ],
      ),
    );
  }
}