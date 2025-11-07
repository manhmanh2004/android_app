// lib/models/khoa.dart
class Khoa {
  final int maKhoa;
  final String tenKhoa;
  final String? moTa;

  Khoa({required this.maKhoa, required this.tenKhoa, this.moTa});

  factory Khoa.fromJson(Map<String, dynamic> json) => Khoa(
    maKhoa: json['MaKhoa'],
    tenKhoa: json['TenKhoa'],
    moTa: json['MoTa'],
  );

  Map<String, dynamic> toJson() => {
    'MaKhoa': maKhoa,
    'TenKhoa': tenKhoa,
    'MoTa': moTa,
  };
}
