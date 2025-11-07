class ThongBaoNguoiNhan {
  final int maThongBao;
  final int maNguoiNhan;
  final bool trangThaiDoc;

  ThongBaoNguoiNhan({
    required this.maThongBao,
    required this.maNguoiNhan,
    required this.trangThaiDoc,
  });

  factory ThongBaoNguoiNhan.fromJson(Map<String, dynamic> json) =>
      ThongBaoNguoiNhan(
        maThongBao: json['MaThongBao'],
        maNguoiNhan: json['MaNguoiNhan'],
        trangThaiDoc:
            json['TrangThaiDoc'] == 1 || json['TrangThaiDoc'] == true,
      );

  Map<String, dynamic> toJson() => {
        'MaThongBao': maThongBao,
        'MaNguoiNhan': maNguoiNhan,
        'TrangThaiDoc': trangThaiDoc ? 1 : 0,
      };
}
