import '../api/api_client.dart';

class AuthService {
  /// 🟢 Đăng nhập vào hệ thống
  static Future<Map<String, dynamic>> login(
    String tenDangNhap,
    String matKhau,
  ) async {
    final res = await ApiClient.post('login', {
      'TenDangNhap': tenDangNhap,
      'MatKhau': matKhau,
    });

    if (res['token'] != null) {
      ApiClient.setToken(res['token']);
    }

    // 🟦 Xử lý lấy role (vai trò)
    String? role;
    if (res['user'] != null) {
      role =
          res['user']['TenVaiTro'] ??
          (res['user']['DanhSachVaiTro']?.isNotEmpty == true
              ? res['user']['DanhSachVaiTro'][0]['TenVaiTro']
              : null);
    }

    // 🟩 Trả về dữ liệu gọn gàng cho màn hình Login
    return {'token': res['token'], 'user': res['user'], 'role': role};
  }

  /// 🟢 Lấy thông tin người dùng hiện tại (đã đăng nhập)
  static Future<Map<String, dynamic>> me() async {
    return await ApiClient.get('me');
  }

  /// 🟢 Đăng xuất tài khoản
  static Future<void> logout() async {
    await ApiClient.post('logout', {});
    ApiClient.clearToken();
  }
}
