import 'package:flutter/material.dart';
import '../api/api_client.dart'; // ✅ import để gọi API thật

class MakeupRequestScreen extends StatefulWidget {
  final Map<String, dynamic>
  buoiData; // ✅ Dữ liệu buổi học (truyền từ màn trước)

  const MakeupRequestScreen({super.key, required this.buoiData});

  @override
  State<MakeupRequestScreen> createState() => _MakeupRequestScreenState();
}

class _MakeupRequestScreenState extends State<MakeupRequestScreen> {
  final noteCtrl = TextEditingController();
  DateTime? selectedDate;
  int startPeriod = 1;
  int endPeriod = 3;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // ✅ Lấy dữ liệu buổi học
    final phanCong = widget.buoiData['phan_cong'] ?? {};
    final monHoc = phanCong['mon_hoc'] ?? {};
    final lopHoc = phanCong['lop_hoc'] ?? {};
    final phongHoc = widget.buoiData['phong_hoc'] ?? {};

    final tenMon = monHoc['Ten_Mon'] ?? 'Không rõ';
    final tenLop = lopHoc['Ten_Lop'] ?? '-';
    final phong = phongHoc['Ten_Phong'] ?? '-';
    final maBuoiHoc = widget.buoiData['Ma_Buoi_Hoc'];

    final tietList = List.generate(12, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đăng ký dạy bù',
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
            // 🔹 Thông tin buổi học gốc
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
                  Text("Phòng học hiện tại: $phong"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Chọn ngày
            const Text(
              'Chọn ngày dạy bù:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2025, 1, 1),
                  lastDate: DateTime(2026, 12, 31),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    selectedDate != null
                        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                        : "Chưa chọn ngày",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 Chọn tiết
            const Text(
              'Chọn tiết:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: startPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Tiết bắt đầu',
                      border: OutlineInputBorder(),
                    ),
                    items: tietList
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text('Tiết $t'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        startPeriod = v!;
                        if (endPeriod <= startPeriod)
                          endPeriod = startPeriod + 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: endPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Tiết kết thúc',
                      border: OutlineInputBorder(),
                    ),
                    items: tietList
                        .where((t) => t > startPeriod)
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text('Tiết $t'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => endPeriod = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "🕓 Khoảng: Tiết $startPeriod - $endPeriod",
              style: const TextStyle(color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),

            // 🔹 Ghi chú
            const Text(
              'Ghi chú:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập nội dung...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),

            // 🔹 Hành động
            loading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(context, 'Hủy', Colors.red, () {
                        Navigator.pop(context);
                      }),
                      _buildButton(context, 'Hoàn thành', Colors.green, () async {
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng chọn ngày dạy bù.'),
                            ),
                          );
                          return;
                        }

                        setState(() => loading = true);

                        // ✅ body gửi lên Laravel
                        final body = {
                          'Ma_YC_Nghi': widget.buoiData['Ma_YC_Nghi'] ?? 1,
                          'Ma_Buoi_Bu': maBuoiHoc,
                          'Ngay_Bu':
                              "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                          'Tiet_Bat_Dau': startPeriod,
                          'Tiet_Ket_Thuc': endPeriod,
                          'Ghi_Chu': noteCtrl.text.trim().isEmpty
                              ? 'Không có ghi chú'
                              : noteCtrl.text.trim(),
                        };

                        try {
                          final res = await ApiClient.post(
                            '/giang-vien/day-bu',
                            body,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Gửi yêu cầu dạy bù thành công!'),
                            ),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Lỗi khi gửi yêu cầu: $e'),
                            ),
                          );
                        } finally {
                          setState(() => loading = false);
                        }
                      }),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(120, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
