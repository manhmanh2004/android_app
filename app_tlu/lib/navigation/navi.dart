import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class Navi extends StatefulWidget {
  const Navi({super.key});

  @override
  State<Navi> createState() => _NaviState();
}

class _NaviState extends State<Navi> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MainScreen(),
    const Center(child: Text('Tiến độ')),
    const Center(child: Text('Điểm danh')),
    const Center(child: Text('Thông báo')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Tiến độ'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Điểm danh'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
        ],
      ),
    );
  }
}
