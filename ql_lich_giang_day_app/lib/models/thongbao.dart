class ThongBao {
  final int maThongBao;
  final String tieuDe;
  final String noiDung;
  final int nguoiGui;
  final String thoiGianGui;

  ThongBao({
    required this.maThongBao,
    required this.tieuDe,
    required this.noiDung,
    required this.nguoiGui,
    required this.thoiGianGui,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) => ThongBao(
    maThongBao: json['MaThongBao'],
    tieuDe: json['TieuDe'],
    noiDung: json['NoiDung'],
    nguoiGui: json['NguoiGui'],
    thoiGianGui: json['ThoiGianGui'],
  );

  Map<String, dynamic> toJson() => {
    'MaThongBao': maThongBao,
    'TieuDe': tieuDe,
    'NoiDung': noiDung,
    'NguoiGui': nguoiGui,
    'ThoiGianGui': thoiGianGui,
  };
}
