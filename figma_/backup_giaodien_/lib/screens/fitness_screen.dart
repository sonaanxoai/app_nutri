import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

// --- MODEL DỮ LIỆU ---
class WalkSession {
  final DateTime date;
  final int steps;
  final double distanceKm;
  final int calories;
  final int durationMinutes;

  WalkSession({
    required this.date,
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.durationMinutes,
  });
}

class FitnessScreen extends StatefulWidget {
  final Function(WalkSession) onFinished;
  final List<WalkSession> initialHistory;
  
  const FitnessScreen({super.key, required this.onFinished, required this.initialHistory});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> with SingleTickerProviderStateMixin {
  bool _isTracking = false;
  int _stepGoal = 5000;
  int _currentSteps = 0;
  int _currentMinutes = 0;
  double _totalDistanceMeters = 0.0;
  
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;

  double get _currentDistanceKm => _totalDistanceMeters / 1000.0;
  int get _currentCalories => (_currentSteps * 0.04).toInt();

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startWalking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    setState(() {
      _currentSteps = 0;
      _currentMinutes = 0;
      _totalDistanceMeters = 0.0;
      _lastPosition = null;
      _isTracking = true;
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0),
    ).listen((Position position) {
      if (_lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude, _lastPosition!.longitude,
          position.latitude, position.longitude,
        );
        setState(() {
          _totalDistanceMeters += distance;
          _currentSteps = (_totalDistanceMeters / 0.762).toInt();
        });
      }
      _lastPosition = position;
    });

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() => _currentMinutes++);
    });
  }

  void _finishWalking() {
    _timer?.cancel();
    _positionStream?.cancel();

    if (_currentSteps > 5) {
      widget.onFinished(WalkSession(
        date: DateTime.now(),
        steps: _currentSteps,
        distanceKm: _currentDistanceKm,
        calories: _currentCalories,
        durationMinutes: _currentMinutes == 0 ? 1 : _currentMinutes,
      ));
    }
    setState(() => _isTracking = false);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Hôm nay, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_isTracking ? "Đang theo dõi GPS..." : "Vận động", style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isTracking ? _buildTrackingView() : _buildOverviewView(),
      ),
    );
  }

  Widget _buildOverviewView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8CE3BE), Color(0xFF67C29E)]),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mục tiêu hôm nay", style: TextStyle(color: Colors.white70)),
                        Row(
                          children: [
                            Text("$_stepGoal", style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 4),
                            const Text("bước", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.edit_outlined, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startWalking,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.gps_fixed_rounded, color: Color(0xFF67C29E)),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "BẮT ĐẦU VẬN ĐỘNG (GPS)",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(child: Text("Lịch sử GPS", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)), alignment: Alignment.centerLeft),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.initialHistory.length,
            itemBuilder: (context, index) => _buildHistoryCard(widget.initialHistory[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(WalkSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Color(0xFF8CE3BE), size: 30),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_formatDate(session.date), style: const TextStyle(fontWeight: FontWeight.bold)), Text("${session.distanceKm.toStringAsFixed(2)} km • ${session.calories} kcal")])),
          Text("${session.steps} b", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF8CE3BE))),
        ],
      ),
    );
  }

  Widget _metric(String l, String v, String u) {
    return Column(
      children: [
        Text(l, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(v, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(u, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTrackingView() {
    return Padding(
      key: const ValueKey("Tracking"),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text("$_currentSteps", style: GoogleFonts.outfit(fontSize: 60, fontWeight: FontWeight.w900)),
          const Text("bước chân (GPS)", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric("Khoảng cách", "${_currentDistanceKm.toStringAsFixed(2)}", "km"),
              _metric("Thời gian", "$_currentMinutes", "phút"),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _finishWalking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white, 
              minimumSize: const Size(double.infinity, 60), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
            ),
            child: const Text("KẾT THÚC VÀ LƯU", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
