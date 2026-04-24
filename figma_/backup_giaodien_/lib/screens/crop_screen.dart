import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CropWidget extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) onConfirm;
  final VoidCallback onCancel;

  const CropWidget({
    super.key, 
    required this.imageBytes, 
    required this.onConfirm, 
    required this.onCancel
  });

  @override
  State<CropWidget> createState() => _CropWidgetState();
}

class _CropWidgetState extends State<CropWidget> {
  final TransformationController _controller = TransformationController();
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _handleConfirm() async {
    try {
      // Đợi để đảm bảo render xong
      await Future.delayed(const Duration(milliseconds: 100));
      
      RenderRepaintBoundary? boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        widget.onConfirm(byteData.buffer.asUint8List());
      }
    } catch (e) {
      widget.onConfirm(widget.imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onCancel,
                  ),
                  const Text("Căn chỉnh ảnh", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.check, color: Color(0xFF8CE3BE), size: 32),
                    onPressed: _handleConfirm,
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(
                  "Kéo để di chuyển • Phóng to vào khung",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8CE3BE), width: 2),
              ),
              child: RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  width: 320,
                  height: 320,
                  color: Colors.black,
                  child: ClipRect(
                    child: InteractiveViewer(
                      transformationController: _controller,
                      boundaryMargin: const EdgeInsets.all(200),
                      minScale: 0.1,
                      maxScale: 5.0,
                      child: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              "Món ăn nằm trong khung sẽ được AI phân tích tốt nhất",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
