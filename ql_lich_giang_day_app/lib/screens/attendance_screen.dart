import 'dart:async';
import 'package:flutter/material.dart';
import '../api/giangvien_service.dart';

class AttendanceScreen extends StatefulWidget {
  final Map<String, dynamic> buoiHoc;

  const AttendanceScreen({super.key, required this.buoiHoc});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<int, String> _trangThai = {};
  bool _loading = false;
  Timer? _autoCheckTimer;

  late int maBuoiHoc;
  late String tenLHP;
  late String tenMon;
  late String ngayHoc;
  late String caHoc;
  List<Map<String, dynamic>> danhSachSV = [];

  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 15);

  @override
  void initState() {
    super.initState();

    final data = widget.buoiHoc;
    maBuoiHoc = data['MaBuoiHoc'];
    tenLHP = data['lop_hoc_phan']?['TenLHP'] ?? '-';
    tenMon = data['lop_hoc_phan']?['mon_hoc']?['TenMonHoc'] ?? '-';
    ngayHoc = data['NgayHoc'] ?? '-';
    caHoc = data['CaHoc'] ?? '-';

    _loadDanhSachSinhVien();
    _batKiemTraTuDong();
  }

  void _batKiemTraTuDong() {
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final daDong = await GiangVienService.kiemTraDongDiemDanh(
        maBuoiHoc: maBuoiHoc,
        thoiGianDongStr: widget.buoiHoc['ThoiGianDongDD'],
      );
      if (daDong && mounted) {
        _showSnack('🔒 Buổi học đã tự động đóng điểm danh!');
        await _loadDanhSachSinhVien();
      }
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  // ================== API ==================

  Future<void> _loadDanhSachSinhVien() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final res = await GiangVienService.danhSachDiemDanh(maBuoiHoc);
      if (!mounted) return;
      danhSachSV = List<Map<String, dynamic>>.from(res['data'] ?? []);

      for (var sv in danhSachSV) {
        final maSV = sv['MaSV'] ?? 0;
        _trangThai[maSV] = sv['TrangThaiDD'] ?? 'ChuaDiemDanh';
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('❌ Lỗi tải danh sách: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _chonThoiGianMoDiemDanh() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Mở điểm danh"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "⏱ Thời gian hiện tại sẽ là thời điểm mở điểm danh.",
                  ),
                  const SizedBox(height: 8),
                  const Text("🕒 Chọn thời gian kết thúc điểm danh:"),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(_endTime.format(context)),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (picked != null) {
                        setStateDialog(() => _endTime = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final now = DateTime.now();
                    final thoiGianMo = now;
                    final thoiGianDong = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _endTime.hour,
                      _endTime.minute,
                    );

                    if (thoiGianDong.isBefore(thoiGianMo)) {
                      _showSnack(
                        '❌ Giờ đóng điểm danh phải sau thời gian hiện tại!',
                      );
                      return;
                    }

                    await _handleAction(
                      () => GiangVienService.moDiemDanh(
                        maBuoiHoc,
                        thoiGianMo,
                        thoiGianDong,
                      ),
                      '🔓 Đã mở điểm danh!',
                    );

                    await _loadDanhSachSinhVien();
                  },
                  child: const Text("Hoàn thành"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _ghiDiemDanh() async {
    final danhSach = danhSachSV.map((sv) {
      final maSV = sv['MaSV'];
      final trangThai = _trangThai[maSV] ?? 'CoMat';
      return {'MaSV': maSV, 'TrangThaiDD': trangThai};
    }).toList();

    await _handleAction(
      () => GiangVienService.ghiDiemDanh(maBuoiHoc, danhSach),
      '📝 Đã lưu điểm danh!',
    );
    await _loadDanhSachSinhVien();
  }

  Future<void> _dongDiemDanh() async {
    await _handleAction(
      () => GiangVienService.dongDiemDanh(maBuoiHoc),
      '🔒 Đã đóng điểm danh!',
    );
    await _loadDanhSachSinhVien();
  }

  // ================== TIỆN ÍCH ==================

  Future<void> _handleAction(
    Future<dynamic> Function() action,
    String successMsg,
  ) async {
    if (!mounted) return;
    try {
      setState(() => _loading = true);
      final res = await action();
      if (!mounted) return;
      _showSnack(res['message'] ?? successMsg);
    } catch (e) {
      if (!mounted) return;
      _showSnack('❌ Lỗi: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================== UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Điểm danh sinh viên'),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _thongTinBuoiHoc(),
                Expanded(child: _danhSachSinhVien()),
                _nutThaoTac(),
              ],
            ),
    );
  }

  Widget _thongTinBuoiHoc() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📚 Lớp: $tenLHP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('📘 Môn: $tenMon'),
          Text('📅 Ngày học: $ngayHoc'),
          Text('🕐 Ca học: $caHoc'),
        ],
      ),
    );
  }

  Widget _danhSachSinhVien() {
    if (danhSachSV.isEmpty) {
      return const Center(
        child: Text(
          'Không có sinh viên nào trong lớp này.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDanhSachSinhVien,
      child: ListView.builder(
        itemCount: danhSachSV.length,
        itemBuilder: (context, index) {
          final sv = danhSachSV[index];
          final maSV = sv['MaSV'];
          final tenSV = sv['HoTen'] ?? 'Sinh viên';
          final trangThai = _trangThai[maSV] ?? 'ChuaDiemDanh';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(tenSV),
              subtitle: Text('Mã SV: $maSV'),
              trailing: DropdownButton<String>(
                value: trangThai,
                items: const [
                  DropdownMenuItem(value: 'CoMat', child: Text('Có mặt')),
                  DropdownMenuItem(value: 'Muon', child: Text('Muộn')),
                  DropdownMenuItem(value: 'Vang', child: Text('Vắng')),
                  DropdownMenuItem(value: 'CoPhep', child: Text('Có phép')),
                  DropdownMenuItem(
                    value: 'ChuaDiemDanh',
                    child: Text('Chưa điểm danh'),
                  ),
                ],
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() => _trangThai[maSV] = value!);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _nutThaoTac() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _actionButton('Mở', Colors.orange, _chonThoiGianMoDiemDanh),
          _actionButton('Lưu', Colors.green, _ghiDiemDanh),
          _actionButton('Đóng', Colors.redAccent, _dongDiemDanh),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(100, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
