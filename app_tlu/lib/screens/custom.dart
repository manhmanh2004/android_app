import 'package:flutter/material.dart';

typedef OnTabChanged = void Function(int index);

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final OnTabChanged onTabChanged;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: onTabChanged,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch học'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Chuyên cần'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Thông báo'),
      ],
    );
  }
}
