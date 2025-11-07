import 'package:flutter/foundation.dart';
import '../api/api_client.dart';

class SinhVienService {
  // ==============================
  // 🧑‍🎓 Thông tin sinh viên
  // ==============================
  static Future<Map<String, dynamic>> thongTin() async {
    final res = await ApiClient.get('sinh-vien/thong-tin');

    if (res is Map && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }

    debugPrint('⚠️ Lỗi dữ liệu hoặc không có key "data": $res');
    return {};
  }

  // ==============================
  // 📊 Tiến độ học tập (tổng quan)
  // ==============================
  static Future<List<dynamic>> tienDo() async {
    final res = await ApiClient.get('sinh-vien/tien-do-tong-quan');

    if (res is! Map) {
      debugPrint('⚠️ Dữ liệu trả về không hợp lệ: $res');
      return [];
    }

    final monHoc = res['MonHoc'];
    if (monHoc is List) return monHoc;

    debugPrint('⚠️ Không có dữ liệu môn học: $res');
    return [];
  }

  // ==============================
  // 📅 Lịch học hôm nay
  // ==============================
  static Future<List<dynamic>> lichHocHomNay() async {
    final res = await ApiClient.get('sinh-vien/lich-hoc/hom-nay');

    if (res is! Map) {
      debugPrint('⚠️ Dữ liệu trả về không hợp lệ: $res');
      return [];
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 📘 Lịch học toàn học kỳ
  // ==============================
  static Future<List<dynamic>> lichHocHocKy({String? keyword}) async {
    final query = (keyword != null && keyword.isNotEmpty)
        ? '?keyword=$keyword'
        : '';
    final res = await ApiClient.get('sinh-vien/lich-hoc$query');

    if (res is! Map) return [];
    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 🕒 Lịch học theo lớp học phần (LHP)
  // ==============================
  static Future<List<dynamic>> lichTheoLHP(String maLHP) async {
    final res = await ApiClient.get('sinh-vien/lichhoc/$maLHP');

    if (res is! Map) {
      debugPrint('⚠️ Dữ liệu trả về không hợp lệ: $res');
      return [];
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 📘 Lịch sử điểm danh theo lớp học phần
  // ==============================
  static Future<List<dynamic>> lichSuDiemDanh(String maLHP) async {
    final res = await ApiClient.get('sinh-vien/lich-su-diem-danh?maLHP=$maLHP');
    if (res is! Map) return [];
    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 🔹 Thống kê chuyên cần
  // ==============================
  static Future<List<dynamic>> thongKeChuyenCan() async {
    final res = await ApiClient.get('sinh-vien/thong-ke-chuyen-can');

    if (res is! Map) {
      debugPrint('⚠️ Dữ liệu thống kê chuyên cần không hợp lệ: $res');
      return [];
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 📘 Chi tiết chuyên cần theo LHP
  // ==============================
  static Future<Map<String, dynamic>> chiTietChuyenCan(int maLHP) async {
    debugPrint("📡 Gọi API: sinh-vien/chi-tiet-chuyen-can?maLHP=$maLHP");

    final res =
    await ApiClient.get('sinh-vien/chi-tiet-chuyen-can?maLHP=$maLHP');
    if (res is! Map) return {};
    final data = res['data'];
    return data is Map<String, dynamic> ? data : {};
  }

  // ==============================
  // 🧾 Lịch sử điểm danh (thống kê)
  // ==============================
  static Future<List<dynamic>> lichSuDiemDanhTheoLHP(int maLHP) async {
    final res = await ApiClient.get(
        'sinh-vien/lich-su-diem-danh?maLHP=${maLHP.toString()}');
    if (res is! Map) return [];
    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 📅 Buổi học đang mở điểm danh
  // ==============================
  static Future<List<dynamic>> buoiHocDangMoDD() async {
    final res = await ApiClient.get('sinh-vien/buoi-hoc/dang-mo-dd');
    if (res is! Map) return [];
    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // ✅ Điểm danh thực hiện
  // ==============================
  static Future<Map<String, dynamic>> diemDanhThucHien(
      int maBuoiHoc, String trangThai) async {
    final res = await ApiClient.post('sinh-vien/diem-danh', {
      'MaBuoiHoc': maBuoiHoc,
      'TrangThaiDD': trangThai,
    });

    return res is Map
        ? Map<String, dynamic>.from(res)
        : {'message': 'Lỗi hệ thống'};
  }

  // ==============================
  // 🔔 Danh sách thông báo
  // ==============================
  static Future<List<dynamic>> thongBao() async {
    final res = await ApiClient.get('sinh-vien/thong-bao');

    if (res is! Map) {
      debugPrint('⚠️ Dữ liệu thông báo không hợp lệ: $res');
      return [];
    }

    final data = res['data'];
    return data is List ? data : [];
  }

  // ==============================
  // 📄 Chi tiết thông báo
  // ==============================
  static Future<Map<String, dynamic>> chiTietThongBao(int maThongBao) async {
    final res =
    await ApiClient.get('sinh-vien/thong-bao/chi-tiet?maThongBao=$maThongBao');

    if (res is! Map) {
      debugPrint('⚠️ Lỗi khi lấy chi tiết thông báo: $res');
      return {};
    }

    final data = res['data'];
    return data is Map<String, dynamic> ? data : {};
  }

  // ==============================
  // ✅ Đánh dấu thông báo đã đọc
  // ==============================
  static Future<bool> danhDauDaDoc(int maThongBao) async {
    try {
      // ⚠️ Thay 5 bằng ID sinh viên thật, bạn có thể lấy từ token hoặc API đăng nhập
      final res = await ApiClient.post(
        'sinh-vien/thong-bao/da-doc',
        {
          'ma_thong_bao': maThongBao,
          'ma_nguoi_nhan': 5, // 👈 thêm dòng này
        },
      );

      if (res is Map && (res['status'] == true || res['success'] == true)) {
        return true;
      }

      debugPrint('⚠️ Lỗi khi đánh dấu đã đọc: $res');
      return false;
    } catch (e) {
      debugPrint('❌ Lỗi kết nối API đánh dấu đã đọc: $e');
      return false;
    }
  }


  // ==============================
  // ✅ Đánh dấu đã đọc thông báo
  // ==============================
  static Future<bool> daDocThongBao({
    required int maThongBao,
    required int maNguoiNhan,
  }) async {
    try {
      final res = await ApiClient.post(
        'sinh-vien/thong-bao/da-doc',
        {
          'ma_thong_bao': maThongBao,
          'ma_nguoi_nhan': maNguoiNhan,
        },
      );

      if (res is Map && res['success'] == true) {
        debugPrint('✅ Thông báo $maThongBao đã đánh dấu là đã đọc.');
        return true;
      }

      debugPrint('⚠️ Không thể đánh dấu đã đọc: $res');
      return false;
    } catch (e) {
      debugPrint('❌ Lỗi khi đánh dấu đã đọc: $e');
      return false;
    }
  }
}
