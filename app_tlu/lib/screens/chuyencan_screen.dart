import 'package:flutter/material.dart';
import '../../api/sinhvien_service.dart';
import 'chitiet_chuyencan_screen.dart';

class ChuyenCanScreen extends StatefulWidget {
  const ChuyenCanScreen({Key? key}) : super(key: key);

  @override
  State<ChuyenCanScreen> createState() => _ChuyenCanScreenState();
}

class _ChuyenCanScreenState extends State<ChuyenCanScreen> {
  bool isLoading = true;
  List<dynamic> thongKe = [];

  @override
  void initState() {
    super.initState();
    fetchThongKe();
  }

  Future<void> fetchThongKe() async {
    try {
      final data = await SinhVienService.thongKeChuyenCan();
      setState(() {
        thongKe = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : thongKe.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu chuyên cần'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: thongKe.length,
        itemBuilder: (context, index) {
          final item = thongKe[index];
          final tile = (item['TiLeChuyenCan'] ?? 0).toDouble();
          final tong = item['TongBuoi'] ?? 0;
          final coMat = item['SoBuoiCoMat'] ?? 0;
          final vang = item['SoBuoiVang'] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['TenMonHoc'] ?? 'Tên môn học',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['TenLHP'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: tile / 100,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.green,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chuyên cần: ${tile.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'HK: ${item['TenHK'] ?? ''}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng buổi: $tong'),
                      Text('Có mặt: $coMat'),
                      Text('Vắng: $vang'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // ✅ Ép kiểu int an toàn
                        final maLHP = item['MaLHP'] is int
                            ? item['MaLHP']
                            : int.tryParse(item['MaLHP'].toString()) ?? 0;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChiTietChuyenCanScreen(
                              maLHP: maLHP,
                              tenMon: item['TenMonHoc'] ?? '',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye),
                      label: const Text('Xem chi tiết'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
