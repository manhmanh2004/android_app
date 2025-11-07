import 'package:flutter/material.dart';
import '../api/sinhvien_service.dart';

class LichHocChiTietScreen extends StatefulWidget {
  final String maLHP;
  final String tenMon;
  final String hocKy;

  const LichHocChiTietScreen({
    super.key,
    required this.maLHP,
    required this.tenMon,
    required this.hocKy,
  });

  @override
  State<LichHocChiTietScreen> createState() => _LichHocChiTietScreenState();
}

class _LichHocChiTietScreenState extends State<LichHocChiTietScreen> {
  List<dynamic> buoiHoc = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChiTiet();
  }

  Future<void> _loadChiTiet() async {
    setState(() => isLoading = true);
    try {
      buoiHoc = await SinhVienService.lichTheoLHP(widget.maLHP);
    } catch (e) {
      debugPrint('⚠️ Lỗi khi tải chi tiết lịch học: $e');
      buoiHoc = [];
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tenMon)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buoiHoc.isEmpty
          ? const Center(child: Text('⛔ Chưa có buổi học nào.'))
          : RefreshIndicator(
        onRefresh: _loadChiTiet,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Thông tin chung
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.tenMon,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Học kỳ: ${widget.hocKy}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Danh sách buổi học',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...buoiHoc.map((e) {
              final ngay = e['NgayHoc'] ?? '';
              final ca = e['CaHoc'] ?? '';
              final phong = e['phong_hoc']?['TenPhong'] ?? 'Chưa rõ';
              final trangThai = e['TrangThaiDD'] ?? 'Chưa điểm danh';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$ngay | Ca $ca',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text('Phòng: $phong'),
                          const SizedBox(height: 2),
                          Text(
                            'Trạng thái: $trangThai',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
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
