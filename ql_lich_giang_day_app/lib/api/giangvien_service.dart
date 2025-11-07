import 'package:flutter/foundation.dart';
import 'package:tlu_be_mobile/api/api_client.dart';

class GiangVienService {
  // ==================== 🧑‍🏫 THÔNG TIN GIẢNG VIÊN ====================
  static Future<Map<String, dynamic>> thongTin() async {
    final res = await ApiClient.get('giang-vien/thong-tin');
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (thongTin): $res');
    return {};
  }

  // ==================== 📅 LỊCH DẠY ====================
  static Future<List<dynamic>> lichDayHomNay(String ngay) async {
    final res = await ApiClient.get('giang-vien/lich-day/$ngay');
    if (res is! Map) return [];
    final data = res['data'];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  /// 🎓 Lọc lịch dạy theo mã môn (MaMon)
  static Future<List<dynamic>> lichTheoMon({String? maMon}) async {
    String url = 'giang-vien/lich-theo-mon';
    if (maMon != null && maMon.trim().isNotEmpty) {
      url += '?MaMon=${Uri.encodeComponent(maMon)}';
    }
    final res = await ApiClient.get(url);
    if (res is! Map) return [];
    final data = res['data'];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  // ==================== 📊 TIẾN ĐỘ GIẢNG DẠY ====================
  // ==================== 📊 TIẾN ĐỘ GIẢNG DẠY ====================
  static Future<List<Map<String, dynamic>>> tienDo() async {
    try {
      final res = await ApiClient.get('giang-vien/tien-do');

      if (res is! Map || res['data'] == null) {
        debugPrint('⚠️ API tiến độ không trả dữ liệu hợp lệ: $res');
        return [];
      }

      final data = res['data'];

      // Nếu trả về List => chuyển tất cả sang Map<String, dynamic>
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) {
          return {
            'MaLHP': e['MaLHP'],
            'TenLHP': e['TenLHP'],
            'TenMonHoc': e['TenMonHoc'],
            'TongBuoi': e['TongBuoi'] ?? 0,
            'DaDay': e['DaDay'] ?? 0,
            'TienDo': e['TienDo'] ?? 0,
          };
        }).toList();
      }

      // Nếu chỉ trả về 1 đối tượng duy nhất
      if (data is Map) {
        return [Map<String, dynamic>.from(data)];
      }

      return [];
    } catch (e) {
      debugPrint('❌ Lỗi khi tải tiến độ giảng dạy: $e');
      return [];
    }
  }

  // ==================== 🔔 THÔNG BÁO ====================

  /// 🔎 Danh sách thông báo (có thể tìm kiếm theo từ khóa)
  static Future<List<dynamic>> thongBao({String? keyword}) async {
    String url = 'giang-vien/thong-bao';
    if (keyword != null && keyword.trim().isNotEmpty) {
      url += '?keyword=${Uri.encodeComponent(keyword)}';
    }

    final res = await ApiClient.get(url);
    if (res is! Map) return [];
    final data = res['data'];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  /// ✅ Đánh dấu thông báo đã đọc
  static Future<Map<String, dynamic>> danhDauDaDoc(int maThongBao) async {
    final res = await ApiClient.post(
      'giang-vien/thong-bao/$maThongBao/doc',
      {},
    );
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (danhDauDaDoc): $res');
    return {};
  }

  /// 🗑️ Xóa thông báo của giảng viên
  static Future<Map<String, dynamic>> xoaThongBao(int maThongBao) async {
    final res = await ApiClient.delete('giang-vien/thong-bao/$maThongBao');
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (xoaThongBao): $res');
    return {};
  }

  // ==================== 🎯 ĐIỂM DANH ====================
  static Future<Map<String, dynamic>> moDiemDanh(
    int maBuoiHoc,
    DateTime thoiGianMo,
    DateTime thoiGianDong,
  ) async {
    final body = {
      'MaBuoiHoc': maBuoiHoc,
      'ThoiGianMoDD': thoiGianMo.toIso8601String(),
      'ThoiGianDongDD': thoiGianDong.toIso8601String(),
    };
    final res = await ApiClient.post('giang-vien/diem-danh/mo', body);
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (moDiemDanh): $res');
    return {};
  }

  static Future<Map<String, dynamic>> ghiDiemDanh(
    int maBuoiHoc,
    List<Map<String, dynamic>> danhSach,
  ) async {
    final res = await ApiClient.post('giang-vien/diem-danh/ghi', {
      'MaBuoiHoc': maBuoiHoc,
      'DanhSach': danhSach,
    });
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (ghiDiemDanh): $res');
    return {};
  }

  static Future<Map<String, dynamic>> dongDiemDanh(int maBuoiHoc) async {
    final res = await ApiClient.post('giang-vien/diem-danh/dong', {
      'MaBuoiHoc': maBuoiHoc,
    });
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (dongDiemDanh): $res');
    return {};
  }

  static Future<dynamic> danhSachDiemDanh(int maBuoiHoc) async {
    final res = await ApiClient.get('giang-vien/diem-danh/$maBuoiHoc');
    return res;
  }

  // ==================== 📤 YÊU CẦU THAY ĐỔI LỊCH ====================

  /// 📋 Danh sách yêu cầu (tất cả)
  static Future<List<dynamic>> danhSachYeuCau() async {
    final res = await ApiClient.get('giang-vien/yeu-cau');
    if (res is! Map) return [];

    final data = res['data'];
    List<dynamic> requests = [];

    if (data is List) {
      requests = data;
    } else if (data is Map) {
      requests = [data];
    }

    // 🔹 Sắp xếp giảm dần theo Ngày đề xuất (mới nhất trước)
    requests.sort((a, b) {
      final dateA = DateTime.tryParse(a['NgayDeXuat'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['NgayDeXuat'] ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA); // giảm dần (mới nhất trước)
    });

    return requests;
  }

  /// 🔍 Lọc yêu cầu theo trạng thái (ChoDuyet / DaDuyet / TuChoi)

  static Future<Map<String, dynamic>> taoYeuCau({
    required int maBuoiHocNguon,
    required String loaiYeuCau, // 'Nghi' hoặc 'DayBu'
    required String lyDo,
    DateTime? ngayDeNghiBu,
    String? caDeNghiBu,
    int? maPhongDeNghi,
  }) async {
    final body = {
      'MaBuoiHocNguon': maBuoiHocNguon,
      'LoaiYeuCau': loaiYeuCau,
      'LyDo': lyDo,
      if (ngayDeNghiBu != null) 'NgayDeNghiBu': ngayDeNghiBu.toIso8601String(),
      if (caDeNghiBu != null) 'CaDeNghiBu': caDeNghiBu,
      if (maPhongDeNghi != null) 'MaPhongDeNghi': maPhongDeNghi,
    };

    final res = await ApiClient.post('giang-vien/yeu-cau', body);
    if (res is Map) return Map<String, dynamic>.from(res);
    debugPrint('⚠️ API không trả Map (taoYeuCau): $res');
    return {};
  }

  // ==================== ⏰ KIỂM TRA TỰ ĐỘNG ĐÓNG ĐIỂM DANH ====================
  static Future<bool> kiemTraDongDiemDanh({
    required int maBuoiHoc,
    required String? thoiGianDongStr,
    DateTime? nowOverride,
  }) async {
    try {
      if (thoiGianDongStr == null || thoiGianDongStr.isEmpty) return false;
      final thoiGianDong = DateTime.parse(thoiGianDongStr);
      final now = nowOverride ?? DateTime.now();

      if (now.isAfter(thoiGianDong)) {
        await dongDiemDanh(maBuoiHoc);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Lỗi kiemTraDongDiemDanh: $e');
      return false;
    }
  }

  /// 🔍 Lọc yêu cầu theo trạng thái + từ khóa + khoảng ngày
  static Future<List<dynamic>> locYeuCau({
    String? trangThai,
    String? keyword,
    DateTime? from,
    DateTime? to,
  }) async {
    String url = 'giang-vien/yeu-cau/loc?';

    if (trangThai != null && trangThai.trim().isNotEmpty) {
      url += 'TrangThai=${Uri.encodeComponent(trangThai)}&';
    }
    if (keyword != null && keyword.trim().isNotEmpty) {
      url += 'keyword=${Uri.encodeComponent(keyword)}&';
    }
    if (from != null) {
      url += 'from=${from.toIso8601String().substring(0, 10)}&';
    }
    if (to != null) {
      url += 'to=${to.toIso8601String().substring(0, 10)}&';
    }

    final res = await ApiClient.get(url);
    if (res is! Map) return [];
    final data = res['data'];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }

  // ==================== 🎓 LỌC LỊCH DẠY THEO NĂM HỌC - HỌC KỲ - MÔN HỌC - KHOẢNG THỜI GIAN ====================
  static Future<List<dynamic>> locLichDay({
    int? namHoc,
    String? hocKy,
    String? maMonHoc,
    String? tenMonHoc,
    DateTime? from,
    DateTime? to,
  }) async {
    String url = 'giang-vien/lich-day/loc?';

    if (namHoc != null) {
      url += 'NamHoc=$namHoc&';
    }
    if (hocKy != null && hocKy.trim().isNotEmpty) {
      url += 'HocKy=${Uri.encodeComponent(hocKy)}&';
    }
    if (maMonHoc != null && maMonHoc.trim().isNotEmpty) {
      url += 'MaMonHoc=${Uri.encodeComponent(maMonHoc)}&';
    }
    if (tenMonHoc != null && tenMonHoc.trim().isNotEmpty) {
      url += 'TenMonHoc=${Uri.encodeComponent(tenMonHoc)}&';
    }
    if (from != null) {
      url += 'from=${from.toIso8601String().substring(0, 10)}&';
    }
    if (to != null) {
      url += 'to=${to.toIso8601String().substring(0, 10)}&';
    }

    final res = await ApiClient.get(url);
    if (res is! Map) return [];

    final data = res['data'];
    if (data is List) return data;
    if (data is Map) return [data];
    return [];
  }
}
