import 'package:flutter/material.dart';
import '../api/api_client.dart';

class LeaveRequestScreen extends StatefulWidget {
  final Map<String, dynamic> buoiData;

  const LeaveRequestScreen({super.key, required this.buoiData});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final reasonCtrl = TextEditingController();
  bool loading = false;

  Future<void> sendLeaveRequest() async {
    final buoi = widget.buoiData;
    final maBuoi = buoi['Ma_Buoi_Hoc'];

    if (reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do nghỉ dạy!')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final res = await ApiClient.post('/giang-vien/nghi-day', {
        "Ma_Buoi_Goc": maBuoi,
        "Ly_Do": reasonCtrl.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Gửi yêu cầu thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Lỗi khi gửi yêu cầu: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phanCong = widget.buoiData['phan_cong'] ?? {};
    final monHoc = phanCong['mon_hoc'] ?? {};
    final lopHoc = phanCong['lop_hoc'] ?? {};
    final phongHoc = widget.buoiData['phong_hoc'] ?? {};

    final tenMon = monHoc['Ten_Mon'] ?? 'Không rõ';
    final tenLop = lopHoc['Ten_Lop'] ?? '-';
    final ngayHoc = widget.buoiData['Ngay_Hoc'] ?? '-';
    final caHoc = widget.buoiData['Ca_Hoc'] ?? '-';
    final phong = phongHoc['Ten_Phong'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng ký nghỉ dạy',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Môn học: $tenMon",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Lớp: $tenLop"),
                  Text("Ngày học: $ngayHoc"),
                  Text("Ca học: $caHoc"),
                  Text("Phòng: $phong"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lý do nghỉ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do nghỉ dạy...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton('Hủy', Colors.red, () => Navigator.pop(context)),
                _buildButton(
                  'Hoàn thành',
                  Colors.green,
                  loading ? null : sendLeaveRequest,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(120, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
