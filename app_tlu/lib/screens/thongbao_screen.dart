import 'package:flutter/material.dart';
import '../../api/sinhvien_service.dart';
import 'chitiet_thongbao_screen.dart';
import 'package:intl/intl.dart';

class ThongBaoScreen extends StatefulWidget {
  const ThongBaoScreen({Key? key}) : super(key: key);

  @override
  State<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends State<ThongBaoScreen> {
  bool isLoading = true;
  List<dynamic> thongBaoList = [];
  String keyword = '';

  @override
  void initState() {
    super.initState();
    fetchThongBao();
  }

  /// Gọi API lấy danh sách thông báo
  Future<void> fetchThongBao() async {
    try {
      setState(() => isLoading = true);
      final data = await SinhVienService.thongBao();
      setState(() {
        thongBaoList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thông báo: $e')),
      );
    }
  }

  /// Định dạng thời gian gửi
  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = thongBaoList.where((item) {
      final tieude = (item['TieuDe'] ?? '').toString().toLowerCase();
      return tieude.contains(keyword.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm kiếm theo từ khóa',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => keyword = value),
            ),
          ),

          // Danh sách thông báo
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Không có thông báo'))
                : RefreshIndicator(
              onRefresh: fetchThongBao,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final daDoc = item['TrangThaiDoc'] == 1;
                  final tieuDe = item['TieuDe'] ?? 'Không có tiêu đề';
                  final noiDung = item['NoiDung'] ?? '';
                  final nguoiGui = item['NguoiGui'] ?? '';
                  final thoiGian = formatTime(item['ThoiGianGui']);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            tieuDe,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '👤 $nguoiGui',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📅 $thoiGian',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            noiDung,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: daDoc
                                      ? Colors.green.shade50
                                      : Colors.yellow.shade50,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Text(
                                  daDoc ? 'Đã đọc' : 'Chưa đọc',
                                  style: TextStyle(
                                    color: daDoc
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChiTietThongBaoScreen(
                                            thongBao: item,
                                          ),
                                    ),
                                  );
                                  fetchThongBao(); // cập nhật lại danh sách sau khi đọc
                                },
                                child: const Text(
                                  'Xem chi tiết',
                                  style: TextStyle(
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
