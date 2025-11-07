import 'package:flutter/material.dart';
import '../api/api_client.dart';

class TeachingReportScreen extends StatefulWidget {
  final Map buoiHoc;

  const TeachingReportScreen({super.key, required this.buoiHoc});

  @override
  State<TeachingReportScreen> createState() => _TeachingReportScreenState();
}

class _TeachingReportScreenState extends State<TeachingReportScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _submitted = false;

  Future<void> submitReport() async {
    setState(() => _loading = true);

    try {
      final res = await ApiClient.post('giang-vien/bao-cao', {
        "MaBuoiHoc": widget.buoiHoc["MaBuoiHoc"],
        "NoiDungGiangDay": _controller.text.trim(),
      });

      setState(() {
        _submitted = true;
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Báo cáo thành công!')),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Gửi báo cáo thất bại: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lop = widget.buoiHoc['lop_hoc_phan']?['TenLHP'] ?? '-';
    final ngay = widget.buoiHoc['NgayHoc'] ?? '-';
    final ca = widget.buoiHoc['CaHoc'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "🧾 Báo cáo buổi học",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📅 Ngày học: $ngay", style: const TextStyle(fontSize: 16)),
            Text("🕐 Ca: $ca", style: const TextStyle(fontSize: 16)),
            Text("🏫 Lớp: $lop", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text(
              "Nhập nội dung giảng dạy:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Ví dụ: Ôn tập chương 3 - Cấu trúc dữ liệu...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitted ? null : submitReport,
                      icon: const Icon(Icons.send),
                      label: Text(
                        _submitted ? "Đã gửi báo cáo" : "Gửi báo cáo",
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _submitted ? Colors.grey : Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
