class LopHocPhan {
  final String maLHP;
  final String tenLHP;
  final String tenMonHoc;
  final String tenHK;
  final String trangThai;

  LopHocPhan({
    required this.maLHP,
    required this.tenLHP,
    required this.tenMonHoc,
    required this.tenHK,
    required this.trangThai,
  });

  factory LopHocPhan.fromJson(Map<String, dynamic> json) {
    return LopHocPhan(
      maLHP: json['MaLHP'],
      tenLHP: json['TenLHP'],
      tenMonHoc: json['TenMonHoc'],
      tenHK: json['TenHK'],
      trangThai: json['TrangThai'],
    );
  }
}
