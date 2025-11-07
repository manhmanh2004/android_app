import 'package:flutter/material.dart';
import '../api/giangvien_service.dart';

class ThongBaoScreen extends StatefulWidget {
  const ThongBaoScreen({super.key});

  @override
  State<ThongBaoScreen> createState() => _ThongBaoScreenState();
}

class _ThongBaoScreenState extends State<ThongBaoScreen> {
  bool loading = true;
  List<dynamic> thongBaoList = [];
  String _keyword = ''; // 🔍 Từ khóa tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchThongBao();
  }

  /// 📩 Lấy danh sách thông báo (có thể lọc theo từ khóa)
  Future<void> fetchThongBao({String? keyword}) async {
    try {
      setState(() => loading = true);
      final data = await GiangVienService.thongBao(keyword: keyword);

      // 🔹 Sắp xếp thời gian mới nhất
      data.sort((a, b) {
        final tgA = DateTime.tryParse(a['ThoiGianGui'] ?? '') ?? DateTime(0);
        final tgB = DateTime.tryParse(b['ThoiGianGui'] ?? '') ?? DateTime(0);
        return tgB.compareTo(tgA);
      });

      setState(() {
        thongBaoList = data;
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi tải thông báo: $e');
      setState(() => loading = false);
    }
  }

  /// ✅ Cập nhật trạng thái đã đọc
  Future<void> _markAsRead(int maThongBao) async {
    try {
      await GiangVienService.danhDauDaDoc(maThongBao);
      setState(() {
        final idx = thongBaoList.indexWhere(
          (tb) => tb['MaThongBao'] == maThongBao,
        );
        if (idx != -1) thongBaoList[idx]['TrangThaiDoc'] = 1;
      });
    } catch (e) {
      debugPrint('⚠️ Lỗi đánh dấu đã đọc: $e');
    }
  }

  /// 🗑️ Xóa thông báo (có xác nhận)
  Future<void> _deleteThongBao(int maThongBao) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa thông báo này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return; // ❌ Người dùng hủy

    try {
      await GiangVienService.xoaThongBao(maThongBao);
      setState(() {
        thongBaoList.removeWhere((tb) => tb['MaThongBao'] == maThongBao);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑 Xóa thông báo thành công')),
      );
    } catch (e) {
      debugPrint('❌ Lỗi xóa thông báo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Xóa thông báo thất bại')),
      );
    }
  }

  /// 🔎 Khi người dùng nhập từ khóa
  void _onSearchChanged(String value) {
    setState(() => _keyword = value);
    fetchThongBao(keyword: value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                          fetchThongBao(); // load lại tất cả
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔽 Danh sách thông báo
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => fetchThongBao(keyword: _keyword),
                    child: thongBaoList.isEmpty
                        ? const Center(child: Text("Không có thông báo nào."))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            itemCount: thongBaoList.length,
                            itemBuilder: (context, index) {
                              final tb = thongBaoList[index];
                              final maTB = tb['MaThongBao'] ?? 0;
                              final tieuDe = tb['TieuDe'] ?? 'Thông báo chung';
                              final noiDung =
                                  tb['NoiDung'] ?? 'Không có nội dung';
                              final thoiGian = tb['ThoiGianGui'] ?? '';
                              final daDoc = tb['TrangThaiDoc'] == 1;

                              // 🔹 Sử dụng Dismissible để kéo xóa
                              return Dismissible(
                                key: ValueKey(maTB),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  color: Colors.redAccent,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  await _deleteThongBao(maTB);
                                  return false; // đã xử lý trong hàm
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    _markAsRead(maTB);
                                    _showDetail(context, tieuDe, noiDung);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: daDoc
                                          ? Colors.grey[200]
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: daDoc
                                            ? Colors.grey.withOpacity(0.5)
                                            : Colors.black.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      boxShadow: daDoc
                                          ? []
                                          : const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(2, 3),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 📨 Nội dung thông báo
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tieuDe,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: daDoc
                                                      ? Colors.grey[700]
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                noiDung,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: daDoc
                                                      ? Colors.grey[600]
                                                      : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                thoiGian,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: daDoc
                                                      ? Colors.grey[500]
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ❌ Nút xóa nhanh
                                      ],
                                    ),
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

  /// 📜 Hiển thị popup nội dung chi tiết
  void _showDetail(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(fontSize: 15)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
