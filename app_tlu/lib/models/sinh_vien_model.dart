class SinhVien {
  final int maSV;
  final String hoTen;
  final String email;
  final String maLopHanhChinh;
  final int namNhapHoc;
  final int soLopDangKy;

  SinhVien({
    required this.maSV,
    required this.hoTen,
    required this.email,
    required this.maLopHanhChinh,
    required this.namNhapHoc,
    required this.soLopDangKy,
  });

  factory SinhVien.fromJson(Map<String, dynamic> json) {
    return SinhVien(
      maSV: json['MaSV'] ?? 0,
      hoTen: json['HoTen'] ?? '',
      email: json['Email'] ?? '',
      maLopHanhChinh: json['MaLopHanhChinh'] ?? '',
      namNhapHoc: json['NamNhapHoc'] ?? 0,
      soLopDangKy: json['SoLopDangKy'] ?? 0,
    );
  }
}
