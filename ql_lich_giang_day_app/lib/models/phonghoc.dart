// lib/models/phonghoc.dart
class PhongHoc {
  final int maPhong;
  final String tenPhong;
  final int sucChua;
  final String loaiPhong;

  PhongHoc({
    required this.maPhong,
    required this.tenPhong,
    required this.sucChua,
    required this.loaiPhong,
  });

  factory PhongHoc.fromJson(Map<String, dynamic> json) => PhongHoc(
    maPhong: json['MaPhong'],
    tenPhong: json['TenPhong'],
    sucChua: json['SucChua'],
    loaiPhong: json['LoaiPhong'],
  );

  Map<String, dynamic> toJson() => {
    'MaPhong': maPhong,
    'TenPhong': tenPhong,
    'SucChua': sucChua,
    'LoaiPhong': loaiPhong,
  };
}
