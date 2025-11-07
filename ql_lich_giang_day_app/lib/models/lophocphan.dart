class LopHocPhan {
  final int maLHP;
  final String tenLHP;
  final int maMonHoc;
  final int maHK;
  final int? maPhongMacDinh;
  final int siSoToiDa;
  final String trangThai;

  LopHocPhan({
    required this.maLHP,
    required this.tenLHP,
    required this.maMonHoc,
    required this.maHK,
    this.maPhongMacDinh,
    required this.siSoToiDa,
    required this.trangThai,
  });

  factory LopHocPhan.fromJson(Map<String, dynamic> json) => LopHocPhan(
    maLHP: json['MaLHP'],
    tenLHP: json['TenLHP'],
    maMonHoc: json['MaMonHoc'],
    maHK: json['MaHK'],
    maPhongMacDinh: json['MaPhongMacDinh'],
    siSoToiDa: json['SiSoToiDa'],
    trangThai: json['TrangThai'],
  );

  Map<String, dynamic> toJson() => {
    'MaLHP': maLHP,
    'TenLHP': tenLHP,
    'MaMonHoc': maMonHoc,
    'MaHK': maHK,
    'MaPhongMacDinh': maPhongMacDinh,
    'SiSoToiDa': siSoToiDa,
    'TrangThai': trangThai,
  };
}
