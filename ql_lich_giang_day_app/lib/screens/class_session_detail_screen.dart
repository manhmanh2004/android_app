import 'package:flutter/material.dart';

class ClassSessionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> buoiData; // ✅ Nhận dữ liệu từ màn trước

  const ClassSessionDetailScreen({super.key, required this.buoiData});

  @override
  Widget build(BuildContext context) {
    final phanCong = buoiData['phan_cong'] ?? {};
    final monHoc = phanCong['mon_hoc'] ?? {};
    final lopHoc = phanCong['lop_hoc'] ?? {};
    final phongHoc = buoiData['phong_hoc'] ?? {};

    final tenMon = monHoc['Ten_Mon'] ?? 'Không rõ';
    final tenLop = lopHoc['Ten_Lop'] ?? 'Không rõ';
    final ngayHoc = buoiData['Ngay_Hoc'] ?? '-';
    final caHoc = buoiData['Ca_Hoc'] ?? '-';
    final phong = phongHoc['Ten_Phong'] ?? '-';
    final soTietLt = buoiData['So_Tiet_LT'] ?? '2';
    final soTietTh = buoiData['So_Tiet_TH'] ?? '1';
    final trangThai = buoiData['Trang_Thai'] ?? 'Chưa dạy';
    final tongSv = buoiData['Tong_SV'] ?? 0;
    final vangMat = buoiData['Vang_Mat'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$tenMon ($tenLop)',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$ngayHoc - Ca $caHoc',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('Phòng: $phong'),
              Text('Số tiết: $soTietLt LT / $soTietTh TH'),
              const SizedBox(height: 8),
              Text('Tổng số sinh viên: $tongSv'),
              Text('Số sinh viên vắng mặt: $vangMat'),
              const SizedBox(height: 8),
              Text(
                'Trạng thái: $trangThai',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Ghi chú:'),
              const SizedBox(height: 4),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã lưu thông tin buổi học.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
