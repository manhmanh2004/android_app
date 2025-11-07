import 'package:flutter/material.dart';
import '../api/sinhvien_service.dart';
import 'custom.dart';
import 'lichhoc_screen.dart';
import 'diemdanh_screen.dart';
import 'chuyencan_screen.dart';
import 'thongbao_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic>? sinhVien;
  List<dynamic> tienDo = [];
  List<dynamic> lichHoc = [];
  List<dynamic> buoiHocDangMo = [];
  List<dynamic> thongBao = [];
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      sinhVien = await SinhVienService.thongTin();
      tienDo = await SinhVienService.tienDo();
      lichHoc = await SinhVienService.lichHocHomNay();
      buoiHocDangMo = await SinhVienService.buoiHocDangMoDD();
      thongBao = await SinhVienService.thongBao();
    } catch (e) {
      debugPrint('❌ Lỗi tải dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải dữ liệu, vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Trang chủ', 'Lịch học','Chuyên Cần', 'Thông báo'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChanged: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  /// 🔹 Quyết định hiển thị theo tab
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return const LichHocScreen();
      case 2:
        return const ChuyenCanScreen();
      case 3:
        return const ThongBaoScreen();
      default:
        return const Center(child: Text('Tính năng đang phát triển...'));
    }
  }

  /// 🏠 Trang chủ
  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //  Chào sinh viên
          Text(
            '👋 Xin chào, ${sinhVien?['HoTen'] ?? 'Sinh viên'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '📘 Lớp: ${sinhVien?['MaLopHanhChinh'] ?? 'Chưa có thông tin'}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          _buildCard(
            '📈 Tiến độ học tập',
            tienDo.map((e) {
              final ten = e['TenMonHoc'] ?? 'Không rõ';
              final td = e['TienDo'] ?? 0;
              return '$ten - Tiến độ: $td%';
            }).toList(),
          ),

          _buildLichHocCard('📅 Lịch học hôm nay', lichHoc),
          _buildDiemDanhCard('🕓 Điểm danh', buoiHocDangMo),
          _buildThongBaoCard('🔔 Thông báo', thongBao),
        ],
      ),
    );
  }

  /// 📦 Thẻ chung
  Widget _buildCard(String title, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Không có dữ liệu.')
            else
              ...items.map((e) => Text('• $e')),
          ],
        ),
      ),
    );
  }

  /// 📅 Lịch học hôm nay
  Widget _buildLichHocCard(String title, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Không có lịch học hôm nay.')
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final e = items[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['TenMonHoc'] ?? 'Không rõ',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Ca: ${e['CaHoc'] ?? ''}'),
                          Text('Phòng: ${e['TenPhong'] ?? ''}'),
                          Text(
                            'Trạng thái: ${e['TrangThaiBuoiHoc'] ?? 'Chưa rõ'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 🕓 Điểm danh
  Widget _buildDiemDanhCard(String title, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Không có buổi học nào đang mở điểm danh.')
            else
              ...items.map((e) {
                final monHoc = e['TenMonHoc'] ?? 'Không rõ';
                final ca = e['CaHoc'] ?? '';
                final phong = e['TenPhong'] ?? '';
                final thoiGianMo = e['ThoiGianMoDD'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monHoc,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Ca học: $ca'),
                      Text('Phòng: $phong'),
                      if (thoiGianMo.isNotEmpty)
                        Text('🕓 Mở lúc: $thoiGianMo',
                            style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),

                      // ✅ Nút chuyển sang màn hình điểm danh
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiemDanhScreen(buoiHoc: e),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Điểm danh ngay'),
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
                );
              }),
          ],
        ),
      ),
    );
  }

  /// 🔔 Thông báo
  Widget _buildThongBaoCard(String title, List<dynamic> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('Không có thông báo mới.')
            else
              ...items.map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ${e['TieuDe'] ?? 'Thông báo'}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${e['NoiDung'] ?? ''}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                ],
              )),
          ],
        ),
      ),
    );
  }
}
