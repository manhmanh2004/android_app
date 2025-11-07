import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'navigation/navi.dart'; // ✅ thêm navigation chung
import 'screens/flash_screen.dart'; // ✅ màn khởi động
import 'api/api_client.dart'; // nếu có sử dụng API client

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ẩn banner "debug"
      title: 'QL Lịch Giảng TLU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),

      // ✅ Màn hình đầu tiên khi khởi động
      home: const SplashScreen(), // → Splash sẽ điều hướng Login
    );
  }
}
