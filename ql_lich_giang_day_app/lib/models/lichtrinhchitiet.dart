class LichTrinhChiTiet {
  final int maBuoiHoc;
  final int maLHP;
  final String ngayHoc;
  final String caHoc;
  final int? maPhong;
  final String trangThaiBuoiHoc;
  final String? thoiGianMoDD;
  final String? thoiGianDongDD;
  final String? noiDungGiangDay;

  LichTrinhChiTiet({
    required this.maBuoiHoc,
    required this.maLHP,
    required this.ngayHoc,
    required this.caHoc,
    this.maPhong,
    required this.trangThaiBuoiHoc,
    this.thoiGianMoDD,
    this.thoiGianDongDD,
    this.noiDungGiangDay,
  });

  factory LichTrinhChiTiet.fromJson(Map<String, dynamic> json) =>
      LichTrinhChiTiet(
        maBuoiHoc: json['MaBuoiHoc'],
        maLHP: json['MaLHP'],
        ngayHoc: json['NgayHoc'],
        caHoc: json['CaHoc'],
        maPhong: json['MaPhong'],
        trangThaiBuoiHoc: json['TrangThaiBuoiHoc'],
        thoiGianMoDD: json['ThoiGianMoDD'],
        thoiGianDongDD: json['ThoiGianDongDD'],
        noiDungGiangDay: json['NoiDungGiangDay'],
      );

  Map<String, dynamic> toJson() => {
    'MaBuoiHoc': maBuoiHoc,
    'MaLHP': maLHP,
    'NgayHoc': ngayHoc,
    'CaHoc': caHoc,
    'MaPhong': maPhong,
    'TrangThaiBuoiHoc': trangThaiBuoiHoc,
    'ThoiGianMoDD': thoiGianMoDD,
    'ThoiGianDongDD': thoiGianDongDD,
    'NoiDungGiangDay': noiDungGiangDay,
  };
}
