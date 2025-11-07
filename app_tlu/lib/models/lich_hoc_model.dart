class LichHoc {
  final int maBuoiHoc;
  final String tenMonHoc;
  final String caHoc;
  final String tenPhong;
  final String trangThaiBuoiHoc;

  LichHoc({
    required this.maBuoiHoc,
    required this.tenMonHoc,
    required this.caHoc,
    required this.tenPhong,
    required this.trangThaiBuoiHoc,
  });

  factory LichHoc.fromJson(Map<String, dynamic> json) {
    return LichHoc(
      maBuoiHoc: json['MaBuoiHoc'] ?? 0,
      tenMonHoc: json['TenMonHoc'] ?? '',
      caHoc: json['CaHoc'] ?? '',
      tenPhong: json['TenPhong'] ?? '',
      trangThaiBuoiHoc: json['TrangThaiBuoiHoc'] ?? '',
    );
  }
}
