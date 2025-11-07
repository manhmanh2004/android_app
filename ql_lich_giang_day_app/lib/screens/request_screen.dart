import 'package:flutter/material.dart';
import '../api/giangvien_service.dart';
import 'profile_screen.dart';
import 'thongbao_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  List<dynamic> requests = [];
  bool loading = true;
  String _selectedStatus = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests({String? status, String? keyword}) async {
    try {
      setState(() => loading = true);

      List<dynamic> data = [];

      // 🔹 Nếu có trạng thái lọc → dùng API lọc
      if (status != null && status != 'Tất cả') {
        data = await GiangVienService.locYeuCau(trangThai: status);
      } else {
        data = await GiangVienService.danhSachYeuCau();
      }

      // 🔹 Nếu có từ khóa tìm kiếm → lọc tiếp phía client
      if (keyword != null && keyword.isNotEmpty) {
        data = data.where((item) {
          final loai = (item['LoaiYeuCau'] ?? '').toString().toLowerCase();
          final lydo = (item['LyDo'] ?? '').toString().toLowerCase();
          return loai.contains(keyword.toLowerCase()) ||
              lydo.contains(keyword.toLowerCase());
        }).toList();
      }

      setState(() {
        requests = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi khi tải danh sách yêu cầu: $e");
      setState(() => loading = false);
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'DaDuyet':
      case 'Duyet':
        return Colors.green;
      case 'TuChoi':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yêu cầu thay đổi lịch',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔍 Thanh tìm kiếm + Dropdown lọc
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 🔎 Ô tìm kiếm
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo loại yêu cầu hoặc lý do...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      fetchRequests(status: _selectedStatus, keyword: value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 🔽 Lọc theo trạng thái
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                    DropdownMenuItem(
                      value: 'ChoDuyet',
                      child: Text('Chờ duyệt'),
                    ),
                    DropdownMenuItem(value: 'Duyet', child: Text('Đã duyệt')),
                    DropdownMenuItem(value: 'TuChoi', child: Text('Từ chối')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                      fetchRequests(
                        status: value,
                        keyword: _searchController.text,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // 📋 Danh sách yêu cầu
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : requests.isEmpty
                ? const Center(child: Text('Không có yêu cầu nào.'))
                : RefreshIndicator(
                    onRefresh: fetchRequests,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return _RequestCard(
                          teacher: 'Giảng viên hiện tại',
                          title: req['LoaiYeuCau'] == 'Nghi'
                              ? 'Đăng ký nghỉ dạy'
                              : 'Đăng ký dạy bù',
                          subject: req['LoaiYeuCau'] ?? '',
                          details:
                              'Ngày đề xuất: ${req['NgayDeXuat'] ?? ''} | Trạng thái: ${req['TrangThai'] ?? ''}',
                          reason: req['LyDo'] ?? '',
                          proof: '',
                          date: 'Ngày gửi: ${req['NgayDeXuat'] ?? ''}',
                          status: req['TrangThai'] ?? 'Chờ duyệt',
                          color: _statusColor(req['TrangThai']),
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

// 🔸 Thẻ hiển thị 1 yêu cầu thay đổi lịch
class _RequestCard extends StatelessWidget {
  final String teacher;
  final String title;
  final String subject;
  final String details;
  final String reason;
  final String proof;
  final String date;
  final String status;
  final Color color;

  const _RequestCard({
    required this.teacher,
    required this.title,
    required this.subject,
    required this.details,
    required this.reason,
    required this.proof,
    required this.date,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header: tiêu đề + trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            teacher,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(subject, style: const TextStyle(color: Colors.black87)),
          Text(details, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 6),
          Text(reason, style: const TextStyle(color: Colors.black87)),
          if (proof.isNotEmpty)
            Text(
              'Minh chứng: $proof',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
