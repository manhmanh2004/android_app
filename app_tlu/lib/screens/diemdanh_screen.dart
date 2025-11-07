import 'package:flutter/material.dart';
import '../api/sinhvien_service.dart';
import 'home_screen.dart';

class DiemDanhScreen extends StatefulWidget {
  final Map<String, dynamic> buoiHoc;

  const DiemDanhScreen({super.key, required this.buoiHoc});

  @override
  State<DiemDanhScreen> createState() => _DiemDanhScreenState();
}

class _DiemDanhScreenState extends State<DiemDanhScreen> {
  bool _isLoading = false;

  Future<void> _thucHienDiemDanh(String trangThai) async {
    setState(() => _isLoading = true);
    final res = await SinhVienService.diemDanhThucHien(
      widget.buoiHoc['MaBuoiHoc'],
      trangThai,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? 'Điểm danh thành công!')),
    );

    // Quay lại màn hình chính
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buoi = widget.buoiHoc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh buổi học'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Môn học: ${buoi['TenMonHoc'] ?? ''}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Ngày học: ${buoi['NgayHoc'] ?? ''}'),
            Text('Ca học: ${buoi['CaHoc'] ?? ''}'),
            Text('Phòng học: ${buoi['TenPhong'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Thời gian điểm danh: ${buoi['ThoiGianMoDD'] ?? ''}'),
            const Spacer(),

            // 4 nút hành động
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('Quay lại', Colors.blue, () {
                    Navigator.pop(context);
                  }),
                  _buildActionButton('Vắng', Colors.red, () {
                    _thucHienDiemDanh('Vang');
                  }),
                  _buildActionButton('Muộn', Colors.amber, () {
                    _thucHienDiemDanh('Muon');
                  }),
                  _buildActionButton('Có mặt', Colors.green, () {
                    _thucHienDiemDanh('CoMat');
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
