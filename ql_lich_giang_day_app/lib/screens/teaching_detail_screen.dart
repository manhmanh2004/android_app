import 'package:flutter/material.dart';
import 'attendance_screen.dart';

class TeachingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> buoiHoc;

  const TeachingDetailScreen({super.key, required this.buoiHoc});

  @override
  Widget build(BuildContext context) {
    // 🧠 Lấy dữ liệu từ buoiHoc (chuẩn theo backend Laravel)
    final lopHocPhan = buoiHoc['lop_hoc_phan'] ?? {};
    final mon = lopHocPhan['mon_hoc'] ?? {};
    final phong = buoiHoc['phong_hoc'] ?? {};

    final String tenMon = mon['TenMonHoc'] ?? 'Không rõ';
    final String tenLop = lopHocPhan['TenLHP'] ?? '-';
    final String caHoc = buoiHoc['CaHoc'] ?? '-';
    final String ngayHoc = buoiHoc['NgayHoc'] ?? '-';
    final String phongHoc = phong['TenPhong'] ?? '-';

    final TextEditingController noteCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          tenMon,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/tlu_logo.png'),
          ),
          SizedBox(width: 12),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Thông tin buổi học
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Môn: $tenMon",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text("Lớp: $tenLop"),
                  Text("Ngày học: $ngayHoc"),
                  Text("Ca học: $caHoc"),
                  Text("Phòng: $phongHoc"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Nội dung giảng dạy
            const Text(
              'Nội dung giảng dạy:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung bài học...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Điểm danh sinh viên
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Điểm danh sinh viên:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(buoiHoc: buoiHoc),
                      ),
                    );
                  },
                  child: const Text(
                    'Mở danh sách',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🔹 Các nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionButton('Đăng ký nghỉ dạy', Colors.lightBlue),
                _actionButton('Hủy', Colors.redAccent),
                _actionButton('Lưu nháp', Colors.orange),
                _actionButton('Hoàn thành', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 44,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
