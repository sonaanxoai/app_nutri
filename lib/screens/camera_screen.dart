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
