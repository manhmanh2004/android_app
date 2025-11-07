import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/giangvien_service.dart';
import 'schedule_screen.dart';
import 'request_screen.dart';
import 'profile_screen.dart';
import 'thongbao_screen.dart';
import 'tien_do_screen.dart'; // ✅ thêm import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? thongTin;
  List<dynamic> lichHomNay = [];
  List<Map<String, dynamic>> tienDo = [];
  List<dynamic> thongBao = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// ✅ Tải tất cả dữ liệu
  Future<void> _loadData() async {
    setState(() => loading = true);
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      thongTin = await GiangVienService.thongTin();
    } catch (e) {
      debugPrint('❌ Lỗi thongTin: $e');
    }

    try {
      lichHomNay = await GiangVienService.lichDayHomNay(now);
    } catch (e) {
      debugPrint('❌ Lỗi lichDayHomNay: $e');
    }

    try {
      tienDo = await GiangVienService.tienDo();
    } catch (e) {
      debugPrint('❌ Lỗi tienDo: $e');
    }

    try {
      thongBao = await GiangVienService.thongBao();
    } catch (e) {
      debugPrint('❌ Lỗi thongBao: $e');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: Text(
          thongTin?['HoTen'] ?? 'Giảng viên',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThongBaoScreen()),
            ),
            child: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/tlu_logo.png'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== LỊCH TRÌNH HÔM NAY ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch trình hôm nay (${DateFormat('dd/MM/yyyy').format(DateTime.now())})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScheduleScreen()),
                    ),
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (lichHomNay.isEmpty)
                const Text(
                  'Không có lịch dạy hôm nay.',
                  style: TextStyle(color: Colors.black54),
                )
              else
                ...lichHomNay.map((item) => _lichCard(item)),

              const SizedBox(height: 24),

              // ====== CHỨC NĂNG CHÍNH ======
              const Text(
                'Chức năng chính',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _actionButton('Lịch chi tiết', context),
                  _actionButton('Điểm danh', context),
                  _actionButton('Nghỉ/dạy bù', context),
                  _actionButton('Thống kê', context),
                ],
              ),
              const SizedBox(height: 24),

              // ====== TIẾN ĐỘ GIẢNG DẠY ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiến độ giảng dạy',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TienDoScreen()),
                      );
                    },
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (tienDo.isEmpty)
                const Text(
                  'Chưa có dữ liệu tiến độ.',
                  style: TextStyle(color: Colors.black54),
                )
              else
                ...tienDo.map((e) => _tienDoCard(e)),

              const SizedBox(height: 24),

              // ====== THÔNG BÁO ======
              const Text(
                'Thông báo nổi bật',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              if (thongBao.isEmpty)
                const Text(
                  '• Không có thông báo mới.',
                  style: TextStyle(color: Colors.black87),
                )
              else
                ...thongBao
                    .take(3)
                    .map(
                      (tb) => Text(
                        '• ${tb['TieuDe'] ?? 'Thông báo'}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== CARD TIẾN ĐỘ GIẢNG DẠY ======
  Widget _tienDoCard(Map<String, dynamic> item) {
    final tenLHP = item['TenLHP'] ?? '---';
    final tenMon = item['TenMonHoc'] ?? '';
    final daDay = item['DaDay'] ?? 0;
    final tongBuoi = item['TongBuoi'] ?? 0;
    final percent = item['TienDo']?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TienDoScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenLHP,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            Text(tenMon, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Đã dạy: $daDay'), Text('Tổng: $tongBuoi')],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percent / 100.0,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 4),
            Text(
              '${percent.toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== CARD LỊCH DẠY HÔM NAY ======
  Widget _lichCard(dynamic item) {
    final mon = item['lop_hoc_phan']?['mon_hoc']?['TenMonHoc'] ?? '---';
    final phong = item['phong_hoc']?['TenPhong'] ?? '---';
    final ca = item['CaHoc'] ?? '';
    final ngay = item['NgayHoc'] ?? '';
    final trangThai = item['TrangThaiBuoiHoc'] ?? 'Chưa dạy';
    final color = (trangThai == 'HoanThanh')
        ? Colors.green
        : (trangThai == 'DangDiemDanh')
        ? Colors.orange
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mon,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text('Phòng: $phong'),
          Text('Ca học: $ca'),
          Text('Ngày: $ngay'),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.circle, color: color, size: 10),
              const SizedBox(width: 6),
              Text(
                trangThai,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ====== NÚT CHỨC NĂNG ======
  static Widget _actionButton(String title, BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        if (title == 'Lịch chi tiết') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScheduleScreen()),
          );
        } else if (title == 'Nghỉ/dạy bù') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RequestScreen()),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: Colors.black54),
      ),
      child: Text(title, style: const TextStyle(color: Colors.black87)),
    );
  }
}
