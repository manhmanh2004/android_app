import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/api_client.dart';
import 'attendance_screen.dart';
import 'teaching_report_screen.dart';
import 'nghi_day_screen.dart';
import 'day_bu_screen.dart';

/// ===============================
/// 📘 MÀN HÌNH CHI TIẾT MÔN HỌC
/// ===============================
class SubjectDetailScreen extends StatefulWidget {
  final int maMon;
  final String subjectName;
  final String? selectedDate; // ✅ Ngày học được chọn (nếu có)

  const SubjectDetailScreen({
    super.key,
    required this.maMon,
    required this.subjectName,
    this.selectedDate,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool loading = true;
  List<Map<String, dynamic>> sessions = [];

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  /// 🧠 Lấy danh sách buổi học của môn hiện tại (lọc theo ngày nếu có)
  Future<void> fetchSessions() async {
    try {
      final res = await ApiClient.get('giang-vien/lich-day');
      final List<dynamic> data = res['data'] ?? [];

      final filtered = data
          .where((s) {
            final mon = s['lop_hoc_phan']?['mon_hoc'];
            if (mon == null) return false;

            final int? maMonInt = int.tryParse(mon['MaMonHoc'].toString());
            final bool matchMon = maMonInt == widget.maMon;

            if (widget.selectedDate != null &&
                widget.selectedDate!.isNotEmpty) {
              return matchMon && s['NgayHoc'] == widget.selectedDate;
            }
            return matchMon;
          })
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;
      setState(() {
        sessions = filtered;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi khi tải lịch môn học: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  /// 📅 Định dạng ngày học dạng dd/MM/yyyy
  String formatDate(String? ngayHoc) {
    if (ngayHoc == null || ngayHoc.isEmpty) return 'Không rõ';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(ngayHoc));
    } catch (_) {
      return ngayHoc;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subjectName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? const Center(child: Text('Không có buổi học nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final s = sessions[index];
                final lop = s['lop_hoc_phan']?['TenLHP'] ?? '-';
                final phong = s['phong_hoc']?['TenPhong'] ?? '-';
                final ca = s['CaHoc'] ?? '-';
                final ngay = formatDate(s['NgayHoc']);
                final trangThai = s['TrangThaiBuoiHoc'] ?? 'Bình thường';
                final isSelected = widget.selectedDate == s['NgayHoc'];

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            _ActionSelectScreen(buoiHoc: Map.from(s)),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
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
                                "$ngay • $ca",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("Lớp: $lop | Phòng: $phong"),
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

/// ===============================
/// 📘 MÀN HÌNH CHỌN HÀNH ĐỘNG BUỔI HỌC
/// ===============================
class _ActionSelectScreen extends StatelessWidget {
  final Map<String, dynamic> buoiHoc;

  const _ActionSelectScreen({required this.buoiHoc});

  @override
  Widget build(BuildContext context) {
    final lop = buoiHoc['lop_hoc_phan']?['TenLHP'] ?? '-';
    final ngay = buoiHoc['NgayHoc'] ?? '-';
    final ca = buoiHoc['CaHoc'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chọn hành động",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📅 Ngày học: $ngay\n🕐 Ca học: $ca\n🏫 Lớp: $lop",
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 40),

            // 🔹 Điểm danh
            _menuButton(
              context,
              icon: Icons.how_to_reg,
              color: Colors.green,
              title: "Điểm danh sinh viên",
              subtitle: "Mở / ghi / đóng điểm danh cho buổi học",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceScreen(buoiHoc: buoiHoc),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Báo cáo buổi học
            _menuButton(
              context,
              icon: Icons.description,
              color: Colors.blue,
              title: "Báo cáo buổi học",
              subtitle: "Nhập nội dung giảng dạy và hoàn thành buổi học",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeachingReportScreen(buoiHoc: buoiHoc),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Yêu cầu thay đổi lịch
            _menuButton(
              context,
              icon: Icons.edit_calendar,
              color: Colors.orange,
              title: "Tạo yêu cầu thay đổi lịch",
              subtitle: "Nghỉ dạy hoặc đề nghị dạy bù",
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (ctx) => SizedBox(
                    height: 180,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.cancel, color: Colors.red),
                          title: const Text("⛔ Nghỉ dạy"),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NghiDayScreen(buoiHoc: buoiHoc),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.loop, color: Colors.blue),
                          title: const Text("🔁 Đề nghị dạy bù"),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DayBuScreen(buoiHoc: buoiHoc),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 Nút hành động (component)
  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: 22,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
