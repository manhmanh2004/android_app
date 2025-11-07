import 'package:flutter/material.dart';

class PDTScreen extends StatelessWidget {
  const PDTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '📋 Trang PHÒNG ĐÀO TẠO\n(Phân công, xét duyệt yêu cầu, thống kê, ...)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
