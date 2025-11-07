class VaiTro {
  final int maVaiTro;
  final String tenVaiTro;

  VaiTro({required this.maVaiTro, required this.tenVaiTro});

  factory VaiTro.fromJson(Map<String, dynamic> json) =>
      VaiTro(maVaiTro: json['MaVaiTro'], tenVaiTro: json['TenVaiTro']);

  Map<String, dynamic> toJson() => {
    'MaVaiTro': maVaiTro,
    'TenVaiTro': tenVaiTro,
  };
}
