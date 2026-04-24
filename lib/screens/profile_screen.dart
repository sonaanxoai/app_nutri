import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/gemini_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String avatarUrl;
  final String userGoal;
  final Function(String, String, String) onUpdate;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.avatarUrl,
    required this.userGoal,
    required this.onUpdate,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Trạng thái Form
  String _gender = 'Nam';
  String _goal = 'Tăng cân';
  late TextEditingController _nameCtrl;
  late TextEditingController _avatarCtrl;
  final TextEditingController _heightCtrl = TextEditingController(text: '170');
  final TextEditingController _weightCtrl = TextEditingController(text: '58');
  final TextEditingController _budgetCtrl = TextEditingController(text: '400.000');
  final TextEditingController _ingredientsCtrl = TextEditingController(text: 'Ức gà, rau xanh, gạo, gia vị cơ bản');

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.userName);
    _avatarCtrl = TextEditingController(text: widget.avatarUrl);
    _goal = widget.userGoal;
  }

  bool _isLoading = false;
  Map<String, dynamic>? _aiPlanResult;

  // Khởi tạo service
  final GeminiService _geminiService = GeminiService();

  Future<void> _generatePlan() async {
    // Tắt bàn phím khi bấm nút
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _aiPlanResult = null;
    });

    try {
      // Gọi AI thật
      final result = await _geminiService.generateDietPlan(
        _heightCtrl.text,
        _weightCtrl.text,
        _budgetCtrl.text,
        _ingredientsCtrl.text,
        _goal,
      );

      if (mounted) {
        setState(() {
          _aiPlanResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _aiPlanResult = {'error': "⚠️ Ôi hỏng! AI đang quá tải hoặc rớt mạng. Chi tiết lỗi:\n$e"};
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _avatarCtrl.text = image.path;
      });
      widget.onUpdate(_nameCtrl.text, _avatarCtrl.text, _goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Hồ sơ & Kế hoạch", style: GoogleFonts.outfit(color: const Color(0xFF2D312F), fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildInputField("Họ và tên", _nameCtrl, Icons.person_outline, isNumber: false),
            const SizedBox(height: 16),
            _buildInputField("Link ảnh đại diện", _avatarCtrl, Icons.image_outlined, isNumber: false),
            const SizedBox(height: 24),
            _buildMetricsSection(),
            const SizedBox(height: 24),
            _buildGoalsSection(),
            const SizedBox(height: 24),
            _buildBudgetSection(),
            const SizedBox(height: 32),
            _buildGenerateButton(),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Color(0xFF8CE3BE)))
            else if (_aiPlanResult != null)
              _buildAIResultCard(),
            const SizedBox(height: 80), // Cách lề dưới cùng
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: _avatarCtrl,
              builder: (context, value, child) {
                return Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    border: Border.all(color: const Color(0xFF8CE3BE), width: 3), 
                    image: DecorationImage(
                      image: NetworkImage(_avatarCtrl.text.isEmpty ? 'https://i.pravatar.cc/150?img=11' : _avatarCtrl.text), 
                      fit: BoxFit.cover
                    )
                  ),
                );
              }
            ),
            Positioned(
              right: 0, bottom: 0,
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFF2D312F), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: _nameCtrl,
              builder: (context, value, child) {
                return Text(value.text.isEmpty ? 'Người dùng' : value.text, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2D312F)));
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF8CE3BE).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Text('Sinh viên', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            )
          ],
        )
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Row(
      children: [
        Expanded(child: _buildInputField("Chiều cao (cm)", _heightCtrl, Icons.height, isNumber: true)),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField("Cân nặng (kg)", _weightCtrl, Icons.monitor_weight_outlined, isNumber: true)),
      ],
    );
  }

  Widget _buildGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mục tiêu & Giới tính", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChoiceChip("Nam", _gender == "Nam", () => setState(() => _gender = "Nam")),
            const SizedBox(width: 10),
            _buildChoiceChip("Nữ", _gender == "Nữ", () => setState(() => _gender = "Nữ")),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChoiceChip("Giảm cân", _goal == "Giảm cân", () {
              setState(() => _goal = "Giảm cân");
              widget.onUpdate(_nameCtrl.text, _avatarCtrl.text, _goal);
            }),
            const SizedBox(width: 10),
            _buildChoiceChip("Giữ dáng", _goal == "Giữ dáng", () {
              setState(() => _goal = "Giữ dáng");
              widget.onUpdate(_nameCtrl.text, _avatarCtrl.text, _goal);
            }),
            const SizedBox(width: 10),
            _buildChoiceChip("Tăng cân", _goal == "Tăng cân", () {
              setState(() => _goal = "Tăng cân");
              widget.onUpdate(_nameCtrl.text, _avatarCtrl.text, _goal);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thiết lập thực đơn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildInputField("Ngân sách 1 tuần (VNĐ)", _budgetCtrl, Icons.account_balance_wallet_outlined, isNumber: true),
        const SizedBox(height: 16),
        TextField(
          controller: _ingredientsCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: "Nguyên liệu đang có / Ưa thích",
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF8CE3BE)),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8CE3BE) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF8CE3BE).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isNumber = true}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (val) {
        if (!isNumber) {
          setState(() {});
          widget.onUpdate(_nameCtrl.text, _avatarCtrl.text, _goal);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: const Color(0xFF8CE3BE)),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _generatePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D312F),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8CE3BE)),
            const SizedBox(width: 8),
            Text("TẠO KẾ HOẠCH", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIResultCard() {
    // Nếu có lỗi (lưu dạng Map với key 'error')
    if (_aiPlanResult!.containsKey('error')) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
        child: Text(_aiPlanResult!['error'], style: const TextStyle(color: Colors.red)),
      );
    }

    final intro = _aiPlanResult!['intro'] ?? '';
    final List<dynamic> sections = _aiPlanResult!['sections'] ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8CE3BE).withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF4CAF50), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Kế hoạch từ VinNutri AI", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Đoạn mở đầu
          Text(intro, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF5A5F5D))),
          const SizedBox(height: 24),

          // Render danh sách các thẻ thu gọn (Expansion Panels)
          ...sections.map((section) => _buildExpandableSection(
            icon: section['icon'] ?? '✨',
            title: section['title'] ?? 'Nội dung',
            content: section['content'] ?? '',
          )).toList(),
        ],
      ),
    );
  }

  // Widget vẽ từng Thẻ thu gọn
  Widget _buildExpandableSection({required String icon, required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9F6), // Màu nền xanh nhạt
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8CE3BE).withOpacity(0.4)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Bỏ đường gạch chân mặc định
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFF2D312F),
          iconColor: const Color(0xFF4CAF50),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          title: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title, 
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2D312F)),
                ),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]
              ),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF424242)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
