import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api_client.dart';
import 'subject_detail_screen.dart'; // ✅ Mở chi tiết môn học

class ScheduleTodayScreen extends StatefulWidget {
  final String? date; // ✅ Ngày được chọn từ lịch (hoặc null = hôm nay)

  const ScheduleTodayScreen({super.key, this.date});

  @override
  State<ScheduleTodayScreen> createState() => _ScheduleTodayScreenState();
}

class _ScheduleTodayScreenState extends State<ScheduleTodayScreen> {
  bool loading = true;
  List<dynamic> todaySchedules = [];

  @override
  void initState() {
    super.initState();
    fetchTodaySchedules();
  }

  /// 📅 Gọi API lấy danh sách lịch dạy của giảng viên theo ngày
  Future<void> fetchTodaySchedules() async {
    try {
      final selectedDate =
          widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      // 🔹 Gọi API Laravel: /giang-vien/lich-day/{ngay}
      final res = await ApiClient.get('giang-vien/lich-day/$selectedDate');
      final List<dynamic> list = res['data'] ?? [];

      setState(() {
        todaySchedules = list;
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi tải lịch ngày: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final titleDate =
        widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📅 Lịch giảng dạy $titleDate',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: todaySchedules.isEmpty
          ? Center(
              child: Text(
                'Không có buổi học nào trong ngày $titleDate.',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todaySchedules.length,
              itemBuilder: (context, i) {
                final item = todaySchedules[i];

                // ✅ Parse đúng key JSON từ Laravel
                final lopHocPhan = item['lop_hoc_phan'] ?? {};
                final monHoc = lopHocPhan['mon_hoc'] ?? {};
                final phong = item['phong_hoc'] ?? {};

                final tenMon = monHoc['TenMonHoc'] ?? 'Không rõ';
                final tenLop = lopHocPhan['TenLHP'] ?? '-';
                final phongHoc = phong['TenPhong'] ?? '-';
                final caHoc = item['CaHoc'] ?? '-';
                final ngayHoc = item['NgayHoc'] ?? '-';
                final trangThai = item['TrangThaiBuoiHoc'] ?? 'Bình thường';

                // 🎨 Màu theo trạng thái
                Color statusColor;
                switch (trangThai) {
                  case 'HoanThanh':
                    statusColor = Colors.green;
                    break;
                  case 'Nghi':
                    statusColor = Colors.red;
                    break;
                  case 'DayBu':
                    statusColor = Colors.blue;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return InkWell(
                  onTap: () {
                    final maMon =
                        int.tryParse(monHoc['MaMonHoc']?.toString() ?? '0') ??
                        0;
                    final tenMonHoc = monHoc['TenMonHoc'] ?? 'Không rõ';
                    final ngayHoc = item['NgayHoc'] ?? '';

                    // ✅ Chuyển đến chi tiết môn học của ngày hiện tại
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectDetailScreen(
                          maMon: maMon,
                          subjectName: tenMonHoc,
                          selectedDate: ngayHoc, // ✅ Truyền ngày học hôm đó
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tenMon,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Lớp: $tenLop | Phòng: $phongHoc | Ca: $caHoc",
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ngày: $ngayHoc",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          trangThai,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
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
