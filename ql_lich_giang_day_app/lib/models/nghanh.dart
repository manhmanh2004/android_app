// lib/models/nganh.dart
class Nganh {
  final int maNganh;
  final String tenNganh;
  final int maKhoa;

  Nganh({required this.maNganh, required this.tenNganh, required this.maKhoa});

  factory Nganh.fromJson(Map<String, dynamic> json) => Nganh(
    maNganh: json['MaNganh'],
    tenNganh: json['TenNganh'],
    maKhoa: json['MaKhoa'],
  );

  Map<String, dynamic> toJson() => {
    'MaNganh': maNganh,
    'TenNganh': tenNganh,
    'MaKhoa': maKhoa,
  };
}
