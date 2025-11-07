class DangKyHocPhan {
  final int maLHP;
  final int maSV;
  final String ngayDangKy;

  DangKyHocPhan({
    required this.maLHP,
    required this.maSV,
    required this.ngayDangKy,
  });

  factory DangKyHocPhan.fromJson(Map<String, dynamic> json) => DangKyHocPhan(
    maLHP: json['MaLHP'],
    maSV: json['MaSV'],
    ngayDangKy: json['NgayDangKy'],
  );

  Map<String, dynamic> toJson() => {
    'MaLHP': maLHP,
    'MaSV': maSV,
    'NgayDangKy': ngayDangKy,
  };
}
