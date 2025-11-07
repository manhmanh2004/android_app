import 'package:flutter/material.dart';
import '../api/sinhvien_service.dart';
import 'lichhoc_chitiet_screen.dart';

class LichHocScreen extends StatefulWidget {
  const LichHocScreen({super.key});

  @override
  State<LichHocScreen> createState() => _LichHocScreenState();
}

class _LichHocScreenState extends State<LichHocScreen> {
  List<dynamic> lichHoc = [];
  bool isLoading = true;
  String keyword = '';

  @override
  void initState() {
    super.initState();
    _loadLichHoc();
  }

  Future<void> _loadLichHoc() async {
    setState(() => isLoading = true);
    try {
      final res = await SinhVienService.lichHocHocKy(keyword: keyword);
      setState(() => lichHoc = res);
    } catch (e) {
      debugPrint('⚠️ Lỗi khi tải lịch học: $e');
      setState(() => lichHoc = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: MonHocSearchDelegate(onSelected: (kw) {
                  keyword = kw;
                  _loadLichHoc();
                }),
              );
              if (result != null && result.isNotEmpty) {
                keyword = result;
                _loadLichHoc();
              }
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lichHoc.isEmpty
          ? const Center(child: Text('⛔ Không có lịch học.'))
          : RefreshIndicator(
        onRefresh: _loadLichHoc,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: lichHoc.length,
          itemBuilder: (context, index) {
            final item = lichHoc[index];
            final tenMon = item['TenMonHoc'] ?? 'Không rõ';
            final tenHK = item['TenHK'] ?? '';
            final phong = item['PhongHoc'] ?? 'Chưa rõ';
            final trangThai = item['TrangThai'] ?? '';
            final isDangHoc = trangThai.contains('Đang');

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LichHocChiTietScreen(
                      maLHP: item['MaLHP'].toString(),
                      tenMon: tenMon,
                      hocKy: tenHK,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenMon,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("$tenHK | $phong",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(
                      isDangHoc ? 'Đang học' : 'Đã học',
                      style: TextStyle(
                        color:
                        isDangHoc ? Colors.orange : Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MonHocSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSelected;

  MonHocSearchDelegate({required this.onSelected});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) {
    onSelected(query);
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Nhập tên môn học để tìm kiếm...'),
    );
  }
}
