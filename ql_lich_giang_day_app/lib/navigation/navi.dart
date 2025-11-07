import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../screens/student_home_screen.dart';
import '../screens/schedule_today_screen.dart';
import '../screens/request_screen.dart';
import '../screens/schedule_screen.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  String? _userRole; // 🔹 Giảng viên hoặc Sinh viên

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  /// 🧠 Lấy vai trò từ SharedPreferences
  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('userRole');
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Chờ load role xong
    if (_userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔹 Nếu là Giảng viên
    if (_userRole == 'GiangVien') {
      final List<Widget> gvPages = const [
        HomeScreen(key: PageStorageKey('home')),
        ScheduleScreen(key: PageStorageKey('schedule')),
        RequestScreen(key: PageStorageKey('request')),
      ];

      return Scaffold(
        body: IndexedStack(index: _currentIndex, children: gvPages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black45,
          backgroundColor: Colors.white,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Lịch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.request_page_outlined),
              label: 'Yêu cầu',
            ),
          ],
        ),
      );
    }
    // 🔹 Nếu là Sinh viên
    else if (_userRole == 'SinhVien') {
      final List<Widget> svPages = const [
        StudentHomeScreen(key: PageStorageKey('homestudent')),
      ];

      return Scaffold(
        body: IndexedStack(index: _currentIndex, children: svPages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black45,
          backgroundColor: Colors.white,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Lịch',
            ),
          ],
        ),
      );
    }

    // 🔹 Nếu không xác định được vai trò
    return const Scaffold(
      body: Center(child: Text('Không xác định vai trò người dùng.')),
    );
  }
}
