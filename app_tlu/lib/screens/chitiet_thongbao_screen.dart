import 'package:flutter/material.dart';
import '../../api/sinhvien_service.dart';
import 'package:intl/intl.dart';

class ChiTietThongBaoScreen extends StatefulWidget {
  final Map<String, dynamic> thongBao;

  const ChiTietThongBaoScreen({Key? key, required this.thongBao})
      : super(key: key);

  @override
  State<ChiTietThongBaoScreen> createState() =>
      _ChiTietThongBaoScreenState();
}

class _ChiTietThongBaoScreenState extends State<ChiTietThongBaoScreen> {
  bool isUpdating = false;
  bool daDoc = false;

  @override
  void initState() {
    super.initState();
    daDoc = widget.thongBao['TrangThaiDoc'] == 1;
  }

  /// Định dạng thời gian hiển thị
  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return timeString;
    }
  }

  /// Gọi API đánh dấu thông báo đã đọc
  Future<void> danhDauDaDoc() async {
    if (isUpdating) return;
    setState(() => isUpdating = true);

    final maThongBao = widget.thongBao['MaThongBao'];
    if (maThongBao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy mã thông báo')),
      );
      setState(() => isUpdating = false);
      return;
    }

    final success = await SinhVienService.danhDauDaDoc(maThongBao);

    setState(() {
      daDoc = success;
      isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          success ? '✅ Đã đánh dấu là đã đọc' : '❌ Lỗi khi đánh dấu thông báo',
        ),
      ),
    );

    // Cập nhật trạng thái để khi quay lại danh sách, có thể refresh
    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final tb = widget.thongBao;
    final tieuDe = tb['TieuDe'] ?? 'Không có tiêu đề';
    final noiDung = tb['NoiDung'] ?? '';
    final nguoiGui = tb['NguoiGui'] ?? 'Không xác định';
    final thoiGian = formatTime(tb['ThoiGianGui']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thông báo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, daDoc),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tieuDe,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('👤 Người gửi: $nguoiGui'),
            Text('🕒 Thời gian: $thoiGian'),
            const Divider(height: 20, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  noiDung,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: daDoc || isUpdating ? null : danhDauDaDoc,
                icon: isUpdating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Icon(
                  daDoc ? Icons.check_circle : Icons.mark_email_read,
                  color: Colors.white,
                ),
                label: Text(
                  daDoc ? 'Đã đọc' : 'Đánh dấu đã đọc',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  daDoc ? Colors.grey : Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
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
  }
}
