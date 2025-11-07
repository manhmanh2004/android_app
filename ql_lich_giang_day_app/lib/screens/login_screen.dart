import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import '../api/api_client.dart';
import '../navigation/navi.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  /// 🟢 Hàm đăng nhập
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await AuthService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      final token = res['token'];
      final role = res['role']; // 👈 "GiangVien" hoặc "SinhVien"

      if (token != null) {
        // ✅ Lưu token cho các API sau
        ApiClient.setToken(token);

        // ✅ Lưu token + role vào SharedPreferences để nhớ đăng nhập
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        if (role != null) await prefs.setString('userRole', role);

        if (!mounted) return;

        // ✅ Chuyển sang navigation chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AppNavigation()),
        );
      } else {
        setState(() => _error = 'Sai tên đăng nhập hoặc mật khẩu');
      }
    } catch (e) {
      setState(() => _error = 'Lỗi: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🟦 Tiêu đề
                const Text(
                  'Đăng nhập',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // 🟦 Ô nhập tên đăng nhập
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black45),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🟦 Ô nhập mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black45),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 🟦 Thông báo lỗi (nếu có)
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),

                const SizedBox(height: 20),

                // 🟦 Nút đăng nhập
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // 🟦 Text “Quên mật khẩu?”
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Quên mật khẩu ?',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
