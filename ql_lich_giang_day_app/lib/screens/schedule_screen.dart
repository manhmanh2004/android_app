import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/giangvien_service.dart';
import '../api/api_client.dart';
import 'schedule_today_screen.dart';
import 'subject_detail_screen.dart';
import 'profile_screen.dart';
import 'thongbao_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedView = 'Hiển thị tất cả môn';
  bool loading = true;
  List<Map<String, dynamic>> subjects = [];
  List<int> _eventDays = [];

  // 📅 Tháng & năm hiện tại
  late int _currentMonth;
  late int _currentYear;

  // 🟢 Bộ lọc môn học
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  String? _selectedHocKy;
  bool _isFiltering = false;

  final List<String> hocKyList = ['HK1', 'HK2', 'Hè'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = now.month;
    _currentYear = now.year;
    _yearController.text = _currentYear.toString();
    fetchSubjectsOfCurrentSemester();
    fetchMonthEvents();
  }

  /// 🧠 Lấy danh sách môn học (tất cả hoặc theo bộ lọc)
  Future<void> fetchSubjectsOfCurrentSemester({
    int? namHoc,
    String? hocKy,
    String? keyword,
  }) async {
    try {
      setState(() => loading = true);

      List<dynamic> data = [];
      if (_isFiltering) {
        // 📘 Gọi API lọc lịch dạy theo bộ lọc
        data = await GiangVienService.locLichDay(
          namHoc: namHoc,
          hocKy: hocKy,
          maMonHoc: keyword,
          tenMonHoc: keyword,
        );
      } else {
        // 📗 Gọi API mặc định (tất cả)
        final res = await ApiClient.get('giang-vien/lich-day');
        data = res['data'] ?? [];
      }

      // 🔹 Lọc và nhóm theo mã môn
      final Map<String, Map<String, dynamic>> uniqueSubjects = {};
      for (var item in data) {
        final monHoc = item['lop_hoc_phan']?['mon_hoc'] ?? {};
        final lop = item['lop_hoc_phan']?['TenLHP'] ?? '-';
        final phong = item['phong_hoc']?['TenPhong'] ?? '-';
        final ngayHoc = item['NgayHoc'] ?? '';

        final maMon = (monHoc['MaMonHoc'] ?? '').toString();
        final tenMon = (monHoc['TenMonHoc'] ?? 'Không rõ').toString();

        if (!uniqueSubjects.containsKey(maMon)) {
          uniqueSubjects[maMon] = {
            'maMon': maMon,
            'name': tenMon,
            'lop': lop,
            'phong': phong,
            'time': ngayHoc,
          };
        }
      }

      setState(() {
        subjects = uniqueSubjects.values.toList();
        loading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi tải danh sách môn học: $e');
      setState(() => loading = false);
    }
  }

  /// 📆 Lấy các ngày trong tháng có lịch học
  Future<void> fetchMonthEvents() async {
    try {
      final res = await ApiClient.get(
        'giang-vien/lich-day-thang/${_currentYear}/${_currentMonth}',
      );
      final List<dynamic> data = res['data'] ?? [];

      _eventDays = data
          .where((item) => item['CoHoc'] == true)
          .map<int>((item) => DateTime.parse(item['Ngay']).day)
          .toList();

      setState(() {});
    } catch (e) {
      debugPrint('❌ Lỗi tải lịch tháng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Lịch giảng dạy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThongBaoScreen()),
              );
            },
            child: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/tlu_logo.png'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Bộ chọn chế độ xem
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedView,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                items: const [
                  DropdownMenuItem(
                    value: 'Hiển thị tất cả môn',
                    child: Text('Hiển thị tất cả môn'),
                  ),
                  DropdownMenuItem(
                    value: 'Hiển thị lịch',
                    child: Text('Hiển thị lịch'),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedView = v!),
              ),
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedView == 'Hiển thị tất cả môn'
                  ? _buildSubjectList()
                  : _buildCalendar(),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Danh sách các môn học (lọc tự động onChanged)
  Widget _buildSubjectList() {
    return Column(
      children: [
        // 🟢 Bộ lọc
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // 🔹 Ô nhập năm học
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Năm',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() => _isFiltering = true);
                    fetchSubjectsOfCurrentSemester(
                      namHoc: int.tryParse(val),
                      hocKy: _selectedHocKy,
                      keyword: _searchController.text,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // 🔹 Dropdown chọn học kỳ
              DropdownButton<String>(
                hint: const Text('Học kỳ'),
                value: _selectedHocKy,
                items: hocKyList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedHocKy = val);
                  _isFiltering = true;
                  fetchSubjectsOfCurrentSemester(
                    namHoc: int.tryParse(_yearController.text),
                    hocKy: val,
                    keyword: _searchController.text,
                  );
                },
              ),
              const SizedBox(width: 8),

              // 🔹 Ô tìm mã hoặc tên môn
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm mã / tên môn...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() => _isFiltering = true);
                    fetchSubjectsOfCurrentSemester(
                      namHoc: int.tryParse(_yearController.text),
                      hocKy: _selectedHocKy,
                      keyword: val,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // 🔹 Nút xóa lọc
              IconButton(
                onPressed: () {
                  setState(() {
                    _isFiltering = false;
                    _selectedHocKy = null;
                    _searchController.clear();
                    _yearController.text = _currentYear.toString();
                  });
                  fetchSubjectsOfCurrentSemester();
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Xóa lọc',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: subjects.isEmpty
              ? const Center(child: Text("Không có môn học."))
              : ListView.builder(
                  key: const ValueKey('list'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subjects.length,
                  itemBuilder: (context, i) {
                    final item = subjects[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubjectDetailScreen(
                              maMon: int.parse(item['maMon'].toString()),
                              subjectName: item['name'],
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Lớp: ${item['lop']}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              "Phòng: ${item['phong']}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              "Ngày gần nhất: ${item['time']}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 🔹 Giao diện lịch
  Widget _buildCalendar() {
    final now = DateTime(_currentYear, _currentMonth);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    return SingleChildScrollView(
      key: const ValueKey('calendar'),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    if (_currentMonth == 1) {
                      _currentMonth = 12;
                      _currentYear--;
                    } else {
                      _currentMonth--;
                    }
                    fetchMonthEvents();
                  });
                },
              ),
              Text(
                "Tháng $_currentMonth / $_currentYear",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    if (_currentMonth == 12) {
                      _currentMonth = 1;
                      _currentYear++;
                    } else {
                      _currentMonth++;
                    }
                    fetchMonthEvents();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (_, i) {
              final day = i + 1;
              final hasEvent = _eventDays.contains(day);

              return InkWell(
                onTap: hasEvent
                    ? () {
                        final selectedDate = DateTime(
                          _currentYear,
                          _currentMonth,
                          day,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ScheduleTodayScreen(
                              date: DateFormat(
                                'yyyy-MM-dd',
                              ).format(selectedDate),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasEvent
                        ? Colors.green.withOpacity(0.25)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasEvent
                          ? Colors.green
                          : Colors.grey.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    "$day",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hasEvent
                          ? Colors.green[900]
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
