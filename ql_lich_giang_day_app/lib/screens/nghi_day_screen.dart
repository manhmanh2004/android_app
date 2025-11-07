import 'package:flutter/material.dart';
import '../api/api_client.dart';

class NghiDayScreen extends StatefulWidget {
  final Map<String, dynamic> buoiHoc;

  const NghiDayScreen({super.key, required this.buoiHoc});

  @override
  State<NghiDayScreen> createState() => _NghiDayScreenState();
}

class _NghiDayScreenState extends State<NghiDayScreen> {
  final TextEditingController lyDoCtrl = TextEditingController();
  bool loading = false;

  Future<void> _luuYeuCau() async {
    if (lyDoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do nghỉ dạy.')),
      );
      return;
    }

    setState(() => loading = true);

    final body = {
      'MaBuoiHocNguon': widget.buoiHoc['MaBuoiHoc'],
      'LoaiYeuCau': 'Nghi',
      'LyDo': lyDoCtrl.text.trim(),
    };

    try {
      await ApiClient.post('giang-vien/yeu-cau', body);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Đã gửi yêu cầu nghỉ dạy.')),
      );
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
        title: const Text("Đăng ký nghỉ dạy"),
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
                    "Ca $ca | Ngày: $ngay | Phòng: $phong",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lý do nghỉ:",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lyDoCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Nhập nội dung ở đây...",
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
