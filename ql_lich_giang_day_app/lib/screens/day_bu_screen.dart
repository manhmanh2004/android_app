import 'package:flutter/material.dart';
import '../api/api_client.dart';
import 'package:intl/intl.dart';

class DayBuScreen extends StatefulWidget {
  final Map<String, dynamic> buoiHoc;

  const DayBuScreen({super.key, required this.buoiHoc});

  @override
  State<DayBuScreen> createState() => _DayBuScreenState();
}

class _DayBuScreenState extends State<DayBuScreen> {
  final TextEditingController ngayBuCtrl = TextEditingController();
  final TextEditingController phongBuCtrl = TextEditingController();
  final TextEditingController ghiChuCtrl = TextEditingController();
  String? caBu;
  bool loading = false;

  Future<void> _chonNgayBu() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      ngayBuCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _luuYeuCau() async {
    if (ngayBuCtrl.text.isEmpty || caBu == null || phongBuCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin.')),
      );
      return;
    }

    setState(() => loading = true);

    final body = {
      'MaBuoiHocNguon': widget.buoiHoc['MaBuoiHoc'],
      'LoaiYeuCau': 'DayBu',
      'NgayDeNghiBu': ngayBuCtrl.text.trim(),
      'CaDeNghiBu': caBu,
      'MaPhongDeNghi': phongBuCtrl.text.trim(),
      'LyDo': ghiChuCtrl.text.trim(),
    };

    try {
      await ApiClient.post('giang-vien/yeu-cau', body);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Đã gửi yêu cầu dạy bù.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Gửi yêu cầu thất bại.')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mon = widget.buoiHoc['lop_hoc_phan']?['mon_hoc']?['TenMonHoc'] ?? '-';
    final ca = widget.buoiHoc['CaHoc'] ?? '-';
    final ngay = widget.buoiHoc['NgayHoc'] ?? '-';
    final phong = widget.buoiHoc['phong_hoc']?['TenPhong'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký dạy bù"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mon,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Buổi học: Ca $ca | Ngày: $ngay | Phòng: $phong",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Chọn ngày dạy bù:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: ngayBuCtrl,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Chọn ngày...",
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: _chonNgayBu,
            ),
            const SizedBox(height: 10),
            const Text(
              "Chọn ca:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: caBu,
              items: const [
                DropdownMenuItem(value: "Ca1", child: Text("Ca 1")),
                DropdownMenuItem(value: "Ca2", child: Text("Ca 2")),
                DropdownMenuItem(value: "Ca3", child: Text("Ca 3")),
              ],
              onChanged: (v) => setState(() => caBu = v),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Chọn phòng:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: phongBuCtrl,
              decoration: InputDecoration(
                hintText: "Nhập mã phòng...",
                prefixIcon: const Icon(Icons.meeting_room),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ghi chú (nếu có):",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: ghiChuCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Nhập nội dung...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Hủy"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: loading ? null : _luuYeuCau,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Lưu",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
