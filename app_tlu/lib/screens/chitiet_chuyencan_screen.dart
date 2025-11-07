import 'package:flutter/material.dart';
import '../../api/sinhvien_service.dart';

class ChiTietChuyenCanScreen extends StatefulWidget {
  final int maLHP;
  final String tenMon;
  const ChiTietChuyenCanScreen({Key? key, required this.maLHP,required this.tenMon,}) : super(key: key);

  @override
  State<ChiTietChuyenCanScreen> createState() => _ChiTietChuyenCanScreenState();
}

class _ChiTietChuyenCanScreenState extends State<ChiTietChuyenCanScreen> {
  bool isLoading = true;
  Map<String, dynamic> chiTiet = {};

  @override
  void initState() {
    super.initState();
    fetchChiTiet();
  }

  Future<void> fetchChiTiet() async {
    try {
      final data = await SinhVienService.chiTietChuyenCan(widget.maLHP);
      setState(() {
        chiTiet = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final buoiHoc = chiTiet['BuoiHoc'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết chuyên cần'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chiTiet.isEmpty
          ? const Center(child: Text('Không có dữ liệu chuyên cần'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin môn học
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Môn học: ${chiTiet['TenMonHoc'] ?? ''}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Lớp học phần: ${chiTiet['TenLHP'] ?? ''}",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text("• Tổng số buổi: ${chiTiet['TongBuoi'] ?? 0}"),
                  Text("• Có mặt: ${chiTiet['SoBuoiCoMat'] ?? 0}"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Row(
              children: [
                Icon(Icons.circle,
                    color: Colors.orange, size: 12),
                SizedBox(width: 8),
                Text(
                  'Danh sách buổi học',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Danh sách buổi học
            if (buoiHoc.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('Chưa có dữ liệu buổi học'),
              )
            else
              ...buoiHoc.map<Widget>((item) {
                final ngay = item['NgayHoc'] ?? '';
                final ca = item['CaHoc'] ?? '';
                final phong = item['PhongHoc'] ?? '';
                final trangThaiBuoi = item['TrangThaiBuoiHoc'] ?? '';
                final trangThaiDD = item['TrangThaiDD'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.red, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '$ngay | $ca | Phòng $phong',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Trạng thái buổi học: $trangThaiBuoi'),
                      Text('Trạng thái điểm danh: $trangThaiDD'),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
