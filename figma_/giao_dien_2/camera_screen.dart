import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen cho UI camera
      body: Stack(
        children: [
          // 1. Placeholder cho Camera Preview (Antigravity sẽ thay bằng thư viện camera)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[900], 
            child: const Center(
              child: Text(
                'Camera Preview Area', 
                style: TextStyle(color: Colors.white54, fontSize: 16)
              ),
            ),
          ),

          // 2. Overlay Elip mờ (Khung căn chỉnh)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // Dùng hình tròn lớn giả lập góc nhìn bát phở
                border: Border.all(
                  color: const Color(0xFF8CE3BE).withOpacity(0.8), 
                  width: 3
                ),
                color: const Color(0xFF8CE3BE).withOpacity(0.1), // Phủ mờ nhẹ bên trong
              ),
            ),
          ),

          // 3. Scanline (Hiệu ứng quét AI) - Antigravity có thể bọc Animation vào đây
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF8CE3BE),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8CE3BE).withOpacity(0.8),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),

          // 4. Panel hướng dẫn phía dưới
          Positioned(
            bottom: 120, // Nâng lên để không bị vướng Bottom Nav
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: const Text(
                'Căn chỉnh món ăn và thìa/đũa vào\nkhung để bắt đầu quét.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D312F),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}