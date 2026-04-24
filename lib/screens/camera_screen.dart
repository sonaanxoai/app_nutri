import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';
import '../models/food_item.dart';
import 'crop_screen.dart';

class FoodSnapperScreen extends StatefulWidget {
  final Function(FoodItem) onAdd;
  final VoidCallback onCancel;
  final String userGoal;
  const FoodSnapperScreen({super.key, required this.onAdd, required this.onCancel, this.userGoal = "Tăng cân"});

  @override
  State<FoodSnapperScreen> createState() => FoodSnapperScreenState();
}

class FoodSnapperScreenState extends State<FoodSnapperScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  bool _isCropping = false;
  Map<String, dynamic>? _analysisResults;
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) { print("Camera Error: $e"); }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      setState(() => _imageBytes = bytes);
    } catch (e) { print(e); }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isCropping = true;
        });
      }
    } catch (e) { print("Gallery Error: $e"); }
  }

  void _resetCamera() {
    setState(() {
      _imageBytes = null;
      _analysisResults = null;
      _isAnalyzing = false;
    });
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;
    setState(() {
      _isAnalyzing = true;
      _analysisResults = null;
    });

    try {
      final results = await _geminiService.analyzeFood(_imageBytes!).timeout(
        const Duration(seconds: 140),
        onTimeout: () => throw Exception("Cổng AI đang bận. Vui lòng thử lại."),
      );
      setState(() {
        _analysisResults = results;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.redAccent,
        title: const Text("LỖI AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ĐÓNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.55;
    final squareSize = size.width * 0.75;

    return Scaffold(
      backgroundColor: const Color(0xFF141716),
      body: _isCropping && _imageBytes != null
          ? CropWidget(
              imageBytes: _imageBytes!,
              onConfirm: (cropped) {
                setState(() {
                  _imageBytes = cropped;
                  _isCropping = false;
                });
              },
              onCancel: () {
                setState(() {
                  _isCropping = false;
                });
              },
            )
          : Stack(
              children: [
                // PHẦN NỀN: ẢNH HOẶC CAMERA (CHIẾM TOÀN BỘ BACKGROUND)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: _imageBytes != null 
                        ? Center(child: Image.memory(_imageBytes!, fit: BoxFit.contain))
                        : _buildCameraPreview(),
                  ),
                ),
                
                // Lớp phủ ô vuông và thanh quét (Chỉ hiện khi chưa phân tích và không có DRAG SHEET trùm lên)
                if (_analysisResults == null) ...[
                  _buildSquareOverlayInHalf(size.height, squareSize),
                  if (_isAnalyzing || _imageBytes != null)
                    _buildScanLineInHalf(size.height, squareSize),
                ],
                
                // NỬA DƯỚI: ĐIỀU KHIỂN (Nếu chưa có kết quả)
                if (_analysisResults == null)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: size.height * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black],
                        ),
                      ),
                      child: _buildActionView(),
                    ),
                  ),

                // DRAGGABLE RESULT SHEET (Nếu đã có kết quả)
                if (_analysisResults != null) ...[
                  _buildDraggableResultSheet(),
                  _buildResultFloatingButtons(),
                ],
                
                // Nút đóng cố định ở góc
                Positioned(
                  top: 40, left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45, 
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white), 
                      onPressed: widget.onCancel
                    )
                  ),
                ),

                if (_isAnalyzing) _buildLoadingOverlay(),
              ],
            ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF8CE3BE)));
    }
    return SizedBox.expand(child: CameraPreview(_controller!));
  }

  Widget _buildSquareOverlayInHalf(double height, double size) {
    return Center(
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF8CE3BE).withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildScanLineInHalf(double height, double size) {
    return Center(
      child: AnimatedBuilder(
        animation: _scanController,
        builder: (context, child) {
          return Container(
            width: size, height: size,
            alignment: Alignment(0, -1 + (_scanController.value * 2)),
            child: Container(
              width: size, height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF8CE3BE),
                boxShadow: [BoxShadow(color: const Color(0xFF8CE3BE).withOpacity(0.6), blurRadius: 10, spreadRadius: 2)],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_imageBytes == null) ...[
          const Text("Căn đĩa thức ăn vào khung vuông phía trên", style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _smallAction(Icons.photo_library_rounded, "Thư viện", _pickFromGallery),
              _mainCaptureBtn(),
              const SizedBox(width: 50),
            ],
          ),
        ] else ...[
          Text("Hình ảnh đã sẵn sàng!", style: GoogleFonts.outfit(color: const Color(0xFF8CE3BE), fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _btnAction("QUÉT AI", Icons.document_scanner_rounded, _analyzeImage, const Color(0xFF8CE3BE)),
              _btnAction(null, Icons.crop_rounded, () => setState(() => _isCropping = true), Colors.white24),
              _btnAction("HỦY", Icons.close, widget.onCancel, Colors.white10),
            ],
          ),
        ]
      ],
    );
  }

  Widget _mainCaptureBtn() {
    return GestureDetector(
      onTap: _takePicture,
      child: Container(
        height: 75, width: 75,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), shape: BoxShape.circle),
        child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
      ),
    );
  }

  Widget _smallAction(IconData i, String l, VoidCallback o) {
    return InkWell(onTap: o, child: Column(children: [Icon(i, color: Colors.white, size: 30), const SizedBox(height: 4), Text(l, style: const TextStyle(color: Colors.white, fontSize: 11))]));
  }

  Widget _btnAction(String? l, IconData i, VoidCallback o, Color c) {
    return ElevatedButton.icon(
      onPressed: o, 
      icon: Icon(i, size: 20), 
      label: l != null ? Text(l) : const SizedBox.shrink(), 
      style: ElevatedButton.styleFrom(
        backgroundColor: c, 
        foregroundColor: Colors.white, 
        padding: EdgeInsets.symmetric(horizontal: l != null ? 16 : 12, vertical: 14), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDraggableResultSheet() {
    final List<dynamic> items = _analysisResults!['items'] ?? [];
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, spreadRadius: 10)],
            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
          ),
          child: Column(
            children: [
              // Thanh kéo (Handle)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  width: 40, height: 5,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Text(
                      _analysisResults!['name'] ?? 'Món ăn',
                      style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1D2120)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // CARD NUTRITION (PHONG CÁCH SÁNG)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FBF9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF8CE3BE).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _nutrientStat('Calo', '${_analysisResults!['calories']}', 'kcal', const Color(0xFF2E7D32)),
                          _nutrientStat('Đạm', '${_analysisResults!['protein']}', 'g', const Color(0xFFF57F17)),
                          _nutrientStat(
                            'Carb', 
                            '${_analysisResults!['carbs']}', 
                            'g', 
                            const Color(0xFF0277BD), 
                            onTap: () async {
                              // Hiển thị loading nhẹ
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator(color: const Color(0xFF8CE3BE))),
                              );
                              
                              final advice = await _geminiService.getQuickAdvice(
                                _analysisResults!['name'] ?? 'Món này', 
                                num.tryParse(_analysisResults!['carbs'].toString()) ?? 0,
                                widget.userGoal
                              );
                              
                              if (mounted) {
                                Navigator.pop(context); // Tắt loading
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    title: const Row(
                                      children: [
                                        Icon(Icons.tips_and_updates, color: const Color(0xFF8CE3BE)),
                                        SizedBox(width: 8),
                                        Text("Lời khuyên nhanh"),
                                      ],
                                    ),
                                    content: Text(advice),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đã hiểu")),
                                    ],
                                  ),
                                );
                              }
                            }
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (items.isNotEmpty) ...[
                      const Text("CHI TIẾT THÀNH PHẦN", style: TextStyle(color: Color(0xFF2E7D32), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      ...items.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F5F3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: const Color(0xFF8CE3BE).withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.restaurant_menu, color: Color(0xFF8CE3BE), size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item['name'] ?? '', style: const TextStyle(color: Color(0xFF2D312F), fontWeight: FontWeight.w600))),
                            Text('${item['calories']} kcal', style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                    ],
                    const SizedBox(height: 20),
                    if (_analysisResults!['description'] != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFF8FBF9), borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          _analysisResults!['description'],
                          style: const TextStyle(color: Color(0xFF5A5F5D), fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                    const SizedBox(height: 100), // Để không vướng nút bấm
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nutrientStat(String label, String value, String unit, Color color, {VoidCallback? onTap}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF5A5F5D), fontSize: 12)),
            if (onTap != null)
              GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text("Đề xuất", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(unit, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7), fontWeight: FontWeight.bold)),
      ],
    );
  }

  // NÚT BẤM CỐ ĐỊNH Ở CUỐI (Khi đã có kết quả)
  Widget _buildResultFloatingButtons() {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              final item = FoodItem(
                name: _analysisResults!['name'],
                calories: num.tryParse(_analysisResults!['calories'].toString()) ?? 0,
                protein: num.tryParse(_analysisResults!['protein'].toString()) ?? 0,
                fat: num.tryParse(_analysisResults!['fat'].toString()) ?? 0,
                carbs: num.tryParse(_analysisResults!['carbs'].toString()) ?? 0,
                weight: num.tryParse(_analysisResults!['weight'].toString()) ?? 0,
                dateTime: DateTime.now(),
                imageBytes: _imageBytes,
              );
              widget.onAdd(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8CE3BE), 
              foregroundColor: Colors.black, 
              minimumSize: const Size(double.infinity, 64), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              elevation: 4, shadowColor: const Color(0xFF8CE3BE).withOpacity(0.5),
            ),
            child: const Text("LƯU VÀO NHẬT KÝ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _resetCamera, child: const Text("Hủy & Chụp lại", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator(color: const Color(0xFF8CE3BE))));
  }
}
