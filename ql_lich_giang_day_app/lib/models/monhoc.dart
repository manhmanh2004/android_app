// lib/models/monhoc.dart
class MonHoc {
  final int maMonHoc;
  final String tenMonHoc;
  final int soTinChi;
  final int soTiet;
  final int maNganh;

  MonHoc({
    required this.maMonHoc,
    required this.tenMonHoc,
    required this.soTinChi,
    required this.soTiet,
    required this.maNganh,
  });

  factory MonHoc.fromJson(Map<String, dynamic> json) => MonHoc(
        maMonHoc: json['MaMonHoc'],
        tenMonHoc: json['TenMonHoc'],
        soTinChi: json['SoTinChi'],
        soTiet: json['SoTiet'],
        maNganh: json['MaNganh'],
      );

  Map<String, dynamic> toJson() => {
        'MaMonHoc': maMonHoc,
        'TenMonHoc': tenMonHoc,
        'SoTinChi': soTinChi,
        'SoTiet': soTiet,
        'MaNganh': maNganh,
      };
}
