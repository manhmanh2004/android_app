class SinhVien {
  final int maSV;
  final int maND;
  final String? maLopHanhChinh;
  final int? namNhapHoc;

  SinhVien({
    required this.maSV,
    required this.maND,
    this.maLopHanhChinh,
    this.namNhapHoc,
  });

  factory SinhVien.fromJson(Map<String, dynamic> json) => SinhVien(
    maSV: json['MaSV'],
    maND: json['MaND'],
    maLopHanhChinh: json['MaLopHanhChinh'],
    namNhapHoc: json['NamNhapHoc'],
  );

  Map<String, dynamic> toJson() => {
    'MaSV': maSV,
    'MaND': maND,
    'MaLopHanhChinh': maLopHanhChinh,
    'NamNhapHoc': namNhapHoc,
  };
}
