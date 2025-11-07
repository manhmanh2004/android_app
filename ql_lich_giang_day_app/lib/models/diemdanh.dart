class DiemDanh {
  final int maDiemDanh;
  final int maBuoiHoc;
  final int maSV;
  final String trangThaiDD;
  final String? ghiChu;
  final String thoiGianDiemDanh;

  DiemDanh({
    required this.maDiemDanh,
    required this.maBuoiHoc,
    required this.maSV,
    required this.trangThaiDD,
    this.ghiChu,
    required this.thoiGianDiemDanh,
  });

  factory DiemDanh.fromJson(Map<String, dynamic> json) => DiemDanh(
    maDiemDanh: json['MaDiemDanh'],
    maBuoiHoc: json['MaBuoiHoc'],
    maSV: json['MaSV'],
    trangThaiDD: json['TrangThaiDD'],
    ghiChu: json['GhiChu'],
    thoiGianDiemDanh: json['ThoiGianDiemDanh'],
  );

  Map<String, dynamic> toJson() => {
    'MaDiemDanh': maDiemDanh,
    'MaBuoiHoc': maBuoiHoc,
    'MaSV': maSV,
    'TrangThaiDD': trangThaiDD,
    'GhiChu': ghiChu,
    'ThoiGianDiemDanh': thoiGianDiemDanh,
  };
}
