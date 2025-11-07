class NguoiDungVaiTro {
  final int maND;
  final int maVaiTro;

  NguoiDungVaiTro({required this.maND, required this.maVaiTro});

  factory NguoiDungVaiTro.fromJson(Map<String, dynamic> json) =>
      NguoiDungVaiTro(maND: json['MaND'], maVaiTro: json['MaVaiTro']);

  Map<String, dynamic> toJson() => {'MaND': maND, 'MaVaiTro': maVaiTro};
}
