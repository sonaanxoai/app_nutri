import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart'; // Mở lại Geolocator
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  
  // Tracking Stats
  int _currentSteps = 0;
  int _initialSteps = -1;
  int _currentMinutes = 0;
  double _totalDistanceMeters = 0.0;
  
  Timer? _timer;
  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;

  // Map related
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _path = [];
  LatLng? _initialCameraPosition;

  double get _currentDistanceKm => _totalDistanceMeters / 1000.0;
  int get _currentCalories => (_currentSteps * 0.04).toInt();

  @override
  void dispose() {
    _timer?.cancel();
    _stepCountStream?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startWalking() async {
    // 🔥 1. Yêu cầu toàn bộ quyền trên Mobile
    if (!kIsWeb) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.activityRecognition,
        Permission.location,
      ].request();

      if (statuses[Permission.activityRecognition] != PermissionStatus.granted ||
          statuses[Permission.location] != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bạn chưa cấp đủ quyền (Hoạt động & Vị trí) để đo chính xác!"))
          );
        }
        // Vẫn cho phép chạy tiếp (có thể sensor sẽ lỗi sau đó) nhưng cảnh báo
      }
    }

    // Get initial position for map
    if (!kIsWeb) {
      try {
        Position initialPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _initialCameraPosition = LatLng(initialPosition.latitude, initialPosition.longitude);
        });
      } catch (e) {
        debugPrint("Initial position error: $e");
        // Default to Hanoi
        setState(() {
          _initialCameraPosition = const LatLng(21.0285, 105.8542);
        });
      }
    } else {
      setState(() {
        _initialCameraPosition = const LatLng(21.0285, 105.8542);
      });
    }

    setState(() {
      _currentSteps = 0;
      _initialSteps = -1;
      _currentMinutes = 0;
      _totalDistanceMeters = 0.0;
      _lastPosition = null;
      _isTracking = true;
      _path = [];
      _markers = {};
      _polylines = {};
    });

    // 🚀 Chế độ Web: Giả lập hoàn toàn
    if (kIsWeb) {
      _startSimulation();
      return;
    }

    // --- CHẾ ĐỘ MOBILE (Cảm biến thật + GPS) ---

    // 2. Theo dõi Bước chân (Sensor)
    try {
      _stepCountStream = Pedometer.stepCountStream.listen((StepCount event) {
        if (_initialSteps == -1) {
          _initialSteps = event.steps;
        }
        setState(() {
          _currentSteps = event.steps - _initialSteps;
        });
      }, onError: (error) {
        debugPrint("Pedometer Error: $error");
      });
    } catch (e) {
      debugPrint("Pedometer Exception: $e");
    }

    // 3. Theo dõi Vị trí (GPS - Latitude/Longitude)
    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((Position position) {
        if (_lastPosition != null) {
          double distance = Geolocator.distanceBetween(
            _lastPosition!.latitude, _lastPosition!.longitude,
            position.latitude, position.longitude,
          );
          setState(() {
            _totalDistanceMeters += distance;
            // Nếu sensor bước chân bị lỗi, dùng GPS để tính bù bước chân
            if (_currentSteps == 0 && _totalDistanceMeters > 0) {
              _currentSteps = (_totalDistanceMeters / 0.762).toInt();
            }
            _path.add(LatLng(position.latitude, position.longitude));
            _markers.add(Marker(
              markerId: MarkerId(position.timestamp.toString()),
              position: LatLng(position.latitude, position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ));
            _polylines.add(Polyline(
              polylineId: PolylineId(position.timestamp.toString()),
              points: _path,
              color: const Color(0xFF67C29E),
              width: 5,
            ));
          });
        }
        _lastPosition = position;
      });
    } catch (e) {
      debugPrint("GPS Error: $e");
    }

    // 4. Timer đo thời gian
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && timer.tick % 60 == 0) {
        setState(() => _currentMinutes++);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã bắt đầu đo bằng Cảm biến & GPS!"))
    );
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentSteps += 1;
          _totalDistanceMeters += 0.8;
          if (timer.tick % 60 == 0) _currentMinutes++;
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Web mode: Chạy chế độ GIẢ LẬP."))
    );
  }

  void _finishWalking() {
    _timer?.cancel();
    _stepCountStream?.cancel();
    _positionStream?.cancel();

    if (_currentSteps > 0 || _totalDistanceMeters > 5) {
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
        title: Text(_isTracking ? "Đang luyện tập..." : "Sức khỏe", style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold)),
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
              boxShadow: [BoxShadow(color: const Color(0xFF8CE3BE).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mục tiêu hôm nay", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Row(
                          children: [
                            Text("$_stepGoal", style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                            const SizedBox(width: 8),
                            const Text("bước", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.directions_run, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _startWalking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: Colors.black, 
                    minimumSize: const Size(double.infinity, 64), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: Colors.black26,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_filled, color: Color(0xFF67C29E), size: 30),
                      const SizedBox(width: 12),
                      Text("BẮT ĐẦU VẬN ĐỘNG", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900)),
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
          child: Align(child: Text("Lịch sử vận động", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800)), alignment: Alignment.centerLeft),
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
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF8CE3BE).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.history, color: Color(0xFF8CE3BE)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_formatDate(session.date), style: const TextStyle(fontWeight: FontWeight.bold)), Text("${session.distanceKm.toStringAsFixed(2)} km • ${session.calories} kcal", style: const TextStyle(color: Colors.grey, fontSize: 12))])),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${session.steps}", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32))),
              const Text("bước", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String l, String v, String u, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8CE3BE), size: 20),
          const SizedBox(height: 4),
          Text(v, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(u, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrackingView() {
    return Padding(
      key: const ValueKey("Tracking"),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: const Color(0xFF8CE3BE).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Column(
              children: [
                Text("$_currentSteps", style: GoogleFonts.outfit(fontSize: 70, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32))),
                const Text("BƯỚC CHÂN (BẮT ĐẦU)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
             Expanded(child: _metric("KHOẢNG CÁCH", "${_currentDistanceKm.toStringAsFixed(2)}", "KM", Icons.map_outlined)),
             const SizedBox(width: 16),
             Expanded(child: _metric("THỜI GIAN", "$_currentMinutes", "PHÚT", Icons.timer_outlined)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF8CE3BE).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_initialCameraPosition != null) {
                    _mapController!.animateCamera(CameraUpdate.newLatLngZoom(_initialCameraPosition!, 15));
                  }
                },
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: _initialCameraPosition ?? const LatLng(21.0285, 105.8542), // Giữ nguyên vị trí ban đầu
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polylines,
                onCameraIdle: () {
                  if (_mapController != null) {
                    _mapController!.getVisibleRegion().then((bounds) {
                      setState(() {
                        _initialCameraPosition = LatLng(bounds.center.latitude, bounds.center.longitude);
                      });
                    });
                  }
                },
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _finishWalking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252), 
              foregroundColor: Colors.white, 
              minimumSize: const Size(double.infinity, 64), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              elevation: 4,
            ),
            child: const Text("KẾT THÚC VÀ LƯU", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
