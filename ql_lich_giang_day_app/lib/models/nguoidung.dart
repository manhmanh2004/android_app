class NguoiDung {
  final int maND;
  final String tenDangNhap;
  final String matKhau;
  final String hoTen;
  final String email;
  final bool trangThai;

  NguoiDung({
    required this.maND,
    required this.tenDangNhap,
    required this.matKhau,
    required this.hoTen,
    required this.email,
    required this.trangThai,
  });

  factory NguoiDung.fromJson(Map<String, dynamic> json) => NguoiDung(
    maND: json['MaND'],
    tenDangNhap: json['TenDangNhap'],
    matKhau: json['MatKhau'],
    hoTen: json['HoTen'],
    email: json['Email'],
    trangThai: json['TrangThai'] == 1 || json['TrangThai'] == true,
  );

  Map<String, dynamic> toJson() => {
    'MaND': maND,
    'TenDangNhap': tenDangNhap,
    'MatKhau': matKhau,
    'HoTen': hoTen,
    'Email': email,
    'TrangThai': trangThai,
  };
}
