import 'package:flutter/material.dart';

// Import 3 màn hình bạn vừa tạo (nhớ kiểm tra lại đường dẫn import cho đúng nhé)
import 'dashboard_screen.dart';
import 'camera_screen.dart';
import 'history_screen.dart';

void main() {
  runApp(const VinNutriApp());
}

class VinNutriApp extends StatelessWidget {
  const VinNutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VinNutri AI',
      debugShowCheckedModeBanner: false, // Ẩn cái chữ DEBUG đỏ đỏ ở góc đi cho "pro"
      theme: ThemeData(
        primaryColor: const Color(0xFF8CE3BE), // Xanh Mint
        scaffoldBackgroundColor: const Color(0xFFF4F9F6), // Nền sáng
        fontFamily: 'Roboto', // Đổi sang font khác nếu bạn có sẵn trong pubspec.yaml
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Bật app lên là lao thẳng vào màn hình Camera luôn (Index 1)
  int _selectedIndex = 1;

  // Danh sách 3 màn hình tương ứng với Index 0, 1, 2
  final List<Widget> _screens = [
    const DashboardScreen(),
    const CameraScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ nguyên trạng thái các màn hình khi chuyển tab (ví dụ: cuộn lịch sử không bị reset)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      
      // Nút Camera lồi to ở giữa
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(1), // Bấm vào thì chuyển sang Camera (Index 1)
        backgroundColor: const Color(0xFF8CE3BE),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      // Cắm cái nút vào chính giữa thanh BottomNav
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Thanh điều hướng bên dưới
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Tạo vết lõm ở giữa ôm lấy cái nút Camera
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 15,
        child: SizedBox(
          height: 65, // Chiều cao của thanh điều hướng
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Nút Dashboard (Index 0)
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              
              const SizedBox(width: 48), // Chừa ra một khoảng trống ở giữa cho nút Camera chui vào
              
              // Nút Lịch sử (Index 2)
              _buildIconItem(
                icon: Icons.history_rounded,
                label: 'Lịch sử',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo các nút điều hướng (Dashboard / Lịch sử)
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    // Nút nào đang chọn thì tô màu xám đậm, không thì xám nhạt
    final color = isSelected ? const Color(0xFF2D312F) : const Color(0xFFB0B8B4);

    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent, // Tắt hiệu ứng nháy khi bấm để mượt hơn
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Duplicate nhẹ hàm này vì ở trên tớ lỡ đổi tên lúc gọi hàm (fix nhanh lỗi typo)
  Widget _buildIconItem({required IconData icon, required String label, required int index}) {
      return _buildNavItem(icon: icon, label: label, index: index);
  }
}