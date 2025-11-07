class DiemDanh {
  final String monHoc;
  final int soBuoiVang;
  final int tongBuoi;

  DiemDanh({
    required this.monHoc,
    required this.soBuoiVang,
    required this.tongBuoi,
  });

  factory DiemDanh.fromJson(Map<String, dynamic> json) {
    return DiemDanh(
      monHoc: json['MonHoc'] ?? '',
      soBuoiVang: json['SoBuoiVang'] ?? 0,
      tongBuoi: json['TongBuoi'] ?? 0,
    );
  }
}
