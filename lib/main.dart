import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/fitness_screen.dart';
import 'screens/profile_screen.dart';
import 'models/food_item.dart';

void main() {
  runApp(const VinNutriApp());
}

class VinNutriApp extends StatelessWidget {
  const VinNutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VinNutri AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8CE3BE)),
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        useMaterial3: true,
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
  int _selectedIndex = 0; 
  final GlobalKey<FoodSnapperScreenState> _cameraKey = GlobalKey();
  
  // Thông tin người dùng
  String _userName = 'Thông';
  String _avatarUrl = 'https://i.pravatar.cc/150?img=11';
  String _userGoal = 'Tăng cân';
  final List<FoodItem> _history = [
    FoodItem(name: 'Phở Bò', calories: 450, protein: 25, fat: 12, carbs: 60, weight: 650, dateTime: DateTime.now()),
  ];

  final List<WalkSession> _walkHistory = [];

  void _addFood(FoodItem item) {
    setState(() {
      _history.insert(0, item);
      _selectedIndex = 0; 
    });
  }

  void _onWalkFinished(WalkSession session) {
    setState(() {
      _walkHistory.insert(0, session);
      // Chuyển về Dashboard để xem kết quả ngay
      _selectedIndex = 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onProfileUpdate(String newName, String newAvatar, String newGoal) {
    setState(() {
      _userName = newName;
      _avatarUrl = newAvatar;
      _userGoal = newGoal;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tính tổng calo nạp hôm nay
    final num totalConsumed = _history.fold(0, (sum, item) => sum + item.calories);
    
    // Tính tổng calo đốt cháy hôm nay (Logic chuẩn xác)
    int totalBurned = 0;
    final now = DateTime.now();
    for (var session in _walkHistory) {
      if (session.date.year == now.year && 
          session.date.month == now.month && 
          session.date.day == now.day) {
        totalBurned += session.calories;
      }
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(
            history: _history, 
            walkHistory: _walkHistory,
            burnedCalories: totalBurned,
            userName: _userName,
            avatarUrl: _avatarUrl,
          ), 
          FitnessScreen(
            onFinished: _onWalkFinished,
            initialHistory: _walkHistory,
          ), 
          FoodSnapperScreen(
            key: _cameraKey, 
            onAdd: _addFood,
            onCancel: () => setState(() => _selectedIndex = 0),
            userGoal: _userGoal,
          ), 
          HistoryScreen(history: _history), 
          ProfileScreen(
            userName: _userName,
            avatarUrl: _avatarUrl,
            userGoal: _userGoal,
            onUpdate: _onProfileUpdate,
          ),
        ],
      ),
      
      floatingActionButton: Container(
        height: 64, width: 64,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: const Color(0xFF8CE3BE),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.space_dashboard_rounded, label: 'Home', index: 0),
            _buildNavItem(icon: Icons.directions_walk_rounded, label: 'Vận động', index: 1),
            const SizedBox(width: 40),
            _buildNavItem(icon: Icons.history_rounded, label: 'Lịch sử', index: 3),
            _buildNavItem(icon: Icons.person_rounded, label: 'Hồ sơ', index: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFF8CE3BE) : const Color(0xFFB0B8B4);
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }
}

