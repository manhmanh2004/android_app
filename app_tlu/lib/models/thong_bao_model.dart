class ThongBao {
  final int maThongBao;
  final String tieuDe;
  final String noiDung;
  final String nguoiGui;
  final String thoiGianGui;
  final bool trangThaiDoc;

  ThongBao({
    required this.maThongBao,
    required this.tieuDe,
    required this.noiDung,
    required this.nguoiGui,
    required this.thoiGianGui,
    required this.trangThaiDoc,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      maThongBao: json['MaThongBao'] ?? 0,
      tieuDe: json['TieuDe'] ?? '',
      noiDung: json['NoiDung'] ?? '',
      nguoiGui: json['NguoiGui'] ?? '',
      thoiGianGui: json['ThoiGianGui'] ?? '',
      trangThaiDoc: (json['TrangThaiDoc'] ?? 0) == 1,
    );
  }
}
