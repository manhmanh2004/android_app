// lib/models/bomon.dart
class BoMon {
  final int maBoMon;
  final String tenBoMon;
  final int maKhoa;

  BoMon({required this.maBoMon, required this.tenBoMon, required this.maKhoa});

  factory BoMon.fromJson(Map<String, dynamic> json) => BoMon(
    maBoMon: json['MaBoMon'],
    tenBoMon: json['TenBoMon'],
    maKhoa: json['MaKhoa'],
  );

  Map<String, dynamic> toJson() => {
    'MaBoMon': maBoMon,
    'TenBoMon': tenBoMon,
    'MaKhoa': maKhoa,
  };
}
