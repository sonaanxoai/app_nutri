import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // --- Color Palette (Mint/Pastel Healthy Vibe) ---
  static const Color mintGreen = Color(0xFF8CE3BE); // Xanh mint chủ đạo
  static const Color mintLight = Color(0xFFD8F5E9); // Xanh mint nhạt cho background
  static const Color pastelHighlight = Color(0xFFFFE082); // Vàng pastel nhấn
  static const Color lightBackground = Color(0xFFF4F9F6); // Nền app sáng
  static const Color darkText = Color(0xFF2D312F); // Chữ đậm
  static const Color mediumText = Color(0xFF757D7A); // Chữ phụ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTodaySummary(),
              const SizedBox(height: 24),
              _buildWeeklyChart(),
              const SizedBox(height: 24),
              _buildRecentHistory(),
              const SizedBox(height: 80), // Khoảng trống cho Bottom Navigation (tránh bị che mất)
            ],
          ),
        ),
      ),
    );
  }

  // 1. Header (Tên app & Lời chào)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'VinNutri AI',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: darkText,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Chào Thông!', // Tên đã được cập nhật
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: mediumText,
              ),
            ),
          ],
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: mintGreen, width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?img=11'), // Avatar placeholder
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  // 2. Thẻ tóm tắt Calo hôm nay
  Widget _buildTodaySummary() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hôm nay',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: const [
              Text(
                '635',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: darkText),
              ),
              Text(
                ' / 2000 kcal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: mediumText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Thanh tiến trình (Custom Progress Bar)
          Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: mintLight,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 635 / 2000, // Tỷ lệ phần trăm
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: pastelHighlight,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Biểu đồ thống kê tuần
  Widget _buildWeeklyChart() {
    // Dữ liệu giả lập cho biểu đồ: tỷ lệ chiều cao (0.0 đến 1.0)
    final weeklyData = [
      {'day': 'T2', 'value': 0.5, 'isToday': false},
      {'day': 'T3', 'value': 0.7, 'isToday': false},
      {'day': 'T4', 'value': 0.9, 'isToday': true}, // Hôm nay
      {'day': 'T5', 'value': 0.6, 'isToday': false},
      {'day': 'T6', 'value': 0.8, 'isToday': false},
      {'day': 'T7', 'value': 0.0, 'isToday': false}, // Chưa có data
      {'day': 'CN', 'value': 0.0, 'isToday': false},
    ];

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê tuần này',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 130, // Chiều cao tối đa của biểu đồ
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((data) {
                final double value = data['value'] as double;
                final bool isToday = data['isToday'] as bool;
                final String day = data['day'] as String;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cột dữ liệu
                    Container(
                      width: 24,
                      height: value == 0 ? 0 : 90 * value, // Scale chiều cao cột
                      decoration: BoxDecoration(
                        color: isToday ? pastelHighlight : mintGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Background mờ cho cột trống (tùy chọn)
                    if (value == 0) 
                      Container(
                        width: 24,
                        height: 90, // Viền cho các cột chưa có dữ liệu
                        decoration: BoxDecoration(
                          border: Border.all(color: mintLight, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? darkText : mediumText,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Lịch sử gần đây
  Widget _buildRecentHistory() {
    final recentScans = [
      {'name': 'Xôi lạc', 'calo': '450 kcal', 'time': '2 giờ trước', 'icon': Icons.rice_bowl},
      {'name': 'Phở bò', 'calo': '550 kcal', 'time': '5 giờ trước', 'icon': Icons.ramen_dining},
      {'name': 'Ly sinh tố', 'calo': '180 kcal', 'time': '7 giờ trước', 'icon': Icons.local_drink},
    ];

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử gần đây',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 16),
          ...recentScans.map((scan) => _buildHistoryItem(
                name: scan['name'] as String,
                calo: scan['calo'] as String,
                time: scan['time'] as String,
                icon: scan['icon'] as IconData,
              )),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({required String name, required String calo, required String time, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: lightBackground, // Nền xám nhạt cho item
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Icon(icon, color: mintGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(fontSize: 13, color: mediumText)),
                ],
              ),
            ),
            Text(calo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText)),
          ],
        ),
      ),
    );
  }

  // --- Widget dùng chung cho các khối thông tin (Card) ---
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Đổ bóng nhẹ nhàng
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}