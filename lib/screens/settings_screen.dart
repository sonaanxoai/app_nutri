import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final TextEditingController _keyController = TextEditingController();
  List<String> _keys = [];

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _keys = prefs.getStringList('gemini_api_keys') ?? [];
    });
  }

  Future<void> _saveKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gemini_api_keys', _keys);
  }

  void _addKey() {
    if (_keyController.text.trim().isNotEmpty) {
      setState(() {
        _keys.add(_keyController.text.trim());
        _keyController.clear();
      });
      _saveKeys();
    }
  }

  void _removeKey(int index) {
    setState(() {
      _keys.removeAt(index);
    });
    _saveKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Cài đặt API Key", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thêm API Key mới",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keyController,
                    decoration: InputDecoration(
                      hintText: "Nhập/Dán API Key từ Google AI Studio",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addKey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8CE3BE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              "Danh sách Key hiện có (${_keys.length})",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _keys.isEmpty
                  ? Center(child: Text("Chưa có Key nào. Hãy thêm để dùng!", style: TextStyle(color: Colors.grey.shade400)))
                  : ListView.builder(
                      itemCount: _keys.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]),
                          child: Row(
                            children: [
                              const Icon(Icons.vpn_key, color: Color(0xFF8CE3BE), size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${_keys[index].substring(0, 8)}...${_keys[index].substring(_keys[index].length - 4)}",
                                  style: GoogleFonts.outfit(color: Colors.black87),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _removeKey(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Mẹo: Bạn nên nạp Key từ các Project Gmail khác nhau để có hạn mức cao nhất.",
                      style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
