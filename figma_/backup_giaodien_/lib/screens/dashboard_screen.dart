import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'fitness_screen.dart'; 

class DashboardScreen extends StatelessWidget {
  final List<FoodItem> history;
  final List<WalkSession> walkHistory;
  final int burnedCalories;

  const DashboardScreen({
    super.key, 
    required this.history, 
    required this.walkHistory,
    required this.burnedCalories
  });

  static const Color mintGreen = Color(0xFF8CE3BE);
  static const Color mintLight = Color(0xFFD8F5E9);
  static const Color pastelHighlight = Color(0xFFFFE082); 
  static const Color lightBackground = Color(0xFFF4F9F6);
  static const Color darkText = Color(0xFF2D312F);
  static const Color mediumText = Color(0xFF757D7A);
  static const Color fireOrange = Color(0xFFFF8A65); 

  @override
  Widget build(BuildContext context) {
    final num todayCalories = history
        .where((item) => _isSameDay(item.dateTime, DateTime.now()))
        .fold(0.0, (sum, item) => sum + item.calories);
        
    const int goalCalories = 2000;

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
              _buildTodaySummary(todayCalories, goalCalories, burnedCalories),
              const SizedBox(height: 24),
              _buildWeeklyChart(),
              const SizedBox(height: 24),
              _buildRecentHistory(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('VinNutri AI', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: darkText)),
            SizedBox(height: 4),
            Text('Chào Thông!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: mediumText)),
          ],
        ),
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle, border: Border.all(color: mintGreen, width: 2),
            image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?img=11'), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySummary(num current, int goal, int burned) {
    double progress = current / goal;
    if (progress > 1.0) progress = 1.0;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hôm nay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$current', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: darkText)),
              Text(' / $goal kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: mediumText)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(height: 14, decoration: BoxDecoration(color: mintLight, borderRadius: BorderRadius.circular(7))),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(height: 14, decoration: BoxDecoration(color: pastelHighlight, borderRadius: BorderRadius.circular(7))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: fireOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: fireOrange, size: 20),
                const SizedBox(width: 8),
                Text('Đã vận động tiêu hao: ', style: TextStyle(fontSize: 14, color: darkText.withOpacity(0.8), fontWeight: FontWeight.w500)),
                Text('$burned kcal', style: const TextStyle(fontSize: 15, color: fireOrange, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weeklyData = [];
    final List<String> weekDays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayLabel = weekDays[date.weekday % 7];
      final isToday = i == 0;

      final dailyConsumed = history
          .where((item) => _isSameDay(item.dateTime, date))
          .fold(0.0, (sum, item) => sum + item.calories);

      final dailyBurned = walkHistory
          .where((item) => _isSameDay(item.date, date))
          .fold(0.0, (sum, item) => sum + item.calories);

      double consumedRatio = dailyConsumed / 2500;
      double burnedRatio = dailyBurned / 800;
      if (consumedRatio > 1.0) consumedRatio = 1.0;
      if (burnedRatio > 1.0) burnedRatio = 1.0;

      weeklyData.add({
        'day': dayLabel,
        'valueConsumed': consumedRatio,
        'valueBurned': burnedRatio,
        'isToday': isToday,
      });
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thống kê tuần này', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
              Row(children: [_buildLegendItem("Nạp", pastelHighlight), const SizedBox(width: 10), _buildLegendItem("Đốt", mintGreen)])
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((data) {
                final bool isToday = data['isToday'];
                final double vConsumed = (data['valueConsumed'] as num).toDouble();
                final double vBurned = (data['valueBurned'] as num).toDouble();

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        color: isToday ? mintGreen.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday ? Border.all(color: mintGreen.withOpacity(0.3), width: 1) : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(width: 8, height: 90 * vConsumed, decoration: BoxDecoration(color: pastelHighlight, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 3),
                          Container(width: 8, height: 90 * vBurned, decoration: BoxDecoration(color: mintGreen, borderRadius: BorderRadius.circular(4))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(data['day'], style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? mintGreen : mediumText)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 11, color: mediumText, fontWeight: FontWeight.bold))]);
  }

  Widget _buildRecentHistory() {
    final recentItems = history.take(3).toList();
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch sử gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
          const SizedBox(height: 16),
          if (recentItems.isEmpty) const Text("Chưa có lịch sử.", style: TextStyle(color: mediumText))
          else ...recentItems.map((item) => _buildHistoryItem(name: item.name, calo: '${item.calories} kcal', time: 'Hôm nay', icon: Icons.fastfood)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({required String name, required String calo, required String time, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: lightBackground, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: mintGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)), const SizedBox(height: 4), Text(time, style: const TextStyle(fontSize: 13, color: mediumText))])),
          Text(calo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: darkText)),
        ]),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: child,
    );
  }
}
