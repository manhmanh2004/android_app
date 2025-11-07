import 'package:flutter/material.dart';
import '../api/giangvien_service.dart';
import 'login_screen.dart'; // ✅ thêm import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? thongTin;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadThongTin();
  }

  Future<void> _loadThongTin() async {
    try {
      thongTin = await GiangVienService.thongTin();
    } catch (e) {
      debugPrint("❌ Lỗi khi tải thông tin giảng viên: $e");
    }
    if (mounted) setState(() => loading = false);
  }

  void _dangXuat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc muốn đăng xuất khỏi tài khoản không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // đóng dialog

              // ⚠️ Xóa token nếu có (bạn có thể thay bằng SharedPreferences)
              // await AuthService.logout();  // nếu có hàm logout

              // ✅ Quay về LoginScreen và xoá toàn bộ route trước đó
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã đăng xuất thành công ✅")),
              );
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = thongTin ?? {};
    final ten = data['HoTen'] ?? 'Giảng viên';
    final maGV = data['MaGV']?.toString() ?? '—';
    final email = data['Email'] ?? '—';
    final trinhDo = data['TrinhDo'] ?? '—';
    final boMon = data['BoMon'] ?? '—';
    final khoa = data['Khoa'] ?? '—';

    final initials = ten.isNotEmpty
        ? ten.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'GV';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Thông tin cá nhân",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blueGrey.shade100,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              ten,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _infoRow("Mã GV:", maGV),
            _infoRow("Email:", email),
            _infoRow("Trình độ:", trinhDo),
            _infoRow("Bộ môn:", boMon),
            _infoRow("Khoa:", khoa),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _dangXuat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
