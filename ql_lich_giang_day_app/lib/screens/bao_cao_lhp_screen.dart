import 'package:flutter/material.dart';

class BaoCaoLHPscreen extends StatelessWidget {
  final String tenLHP;
  final String giangVien;
  final double tienDo;
  final List<Map<String, String>> buoiHoc;

  const BaoCaoLHPscreen({
    super.key,
    required this.tenLHP,
    required this.giangVien,
    required this.tienDo,
    required this.buoiHoc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tenLHP,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧑‍🏫 Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/tlu_logo.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    giangVien,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Mức độ hoàn thành:'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: tienDo / 100,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 6),
            Text(
              '${tienDo.toStringAsFixed(1)}% hoàn thành',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: buoiHoc.length,
                itemBuilder: (context, i) {
                  final b = buoiHoc[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['Tuan'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text('Thời gian: ${b['ThoiGian'] ?? ''}'),
                        Text('Phòng: ${b['Phong'] ?? ''}'),
                        Text('Giảng viên: ${b['GiangVien'] ?? ''}'),
                        Text('Trạng thái: ${b['TrangThai'] ?? ''}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
