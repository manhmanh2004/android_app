// lib/models/hocky.dart
class HocKy {
  final int maHK;
  final String tenHK;
  final String ngayBatDau;
  final String ngayKetThuc;

  HocKy({
    required this.maHK,
    required this.tenHK,
    required this.ngayBatDau,
    required this.ngayKetThuc,
  });

  factory HocKy.fromJson(Map<String, dynamic> json) => HocKy(
    maHK: json['MaHK'],
    tenHK: json['TenHK'],
    ngayBatDau: json['NgayBatDau'],
    ngayKetThuc: json['NgayKetThuc'],
  );

  Map<String, dynamic> toJson() => {
    'MaHK': maHK,
    'TenHK': tenHK,
    'NgayBatDau': ngayBatDau,
    'NgayKetThuc': ngayKetThuc,
  };
}
