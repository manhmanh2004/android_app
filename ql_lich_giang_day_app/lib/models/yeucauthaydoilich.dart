class YeuCauThayDoiLich {
  final int maYeuCau;
  final int maGV;
  final int maBuoiHocNguon;
  final String loaiYeuCau;
  final String ngayDeXuat;
  final String? ngayDeNghiBu;
  final String? caDeNghiBu;
  final int? maPhongDeNghi;
  final String? lyDo;
  final String trangThai;

  YeuCauThayDoiLich({
    required this.maYeuCau,
    required this.maGV,
    required this.maBuoiHocNguon,
    required this.loaiYeuCau,
    required this.ngayDeXuat,
    this.ngayDeNghiBu,
    this.caDeNghiBu,
    this.maPhongDeNghi,
    this.lyDo,
    required this.trangThai,
  });

  factory YeuCauThayDoiLich.fromJson(Map<String, dynamic> json) =>
      YeuCauThayDoiLich(
        maYeuCau: json['MaYeuCau'],
        maGV: json['MaGV'],
        maBuoiHocNguon: json['MaBuoiHocNguon'],
        loaiYeuCau: json['LoaiYeuCau'],
        ngayDeXuat: json['NgayDeXuat'],
        ngayDeNghiBu: json['NgayDeNghiBu'],
        caDeNghiBu: json['CaDeNghiBu'],
        maPhongDeNghi: json['MaPhongDeNghi'],
        lyDo: json['LyDo'],
        trangThai: json['TrangThai'],
      );

  Map<String, dynamic> toJson() => {
        'MaYeuCau': maYeuCau,
        'MaGV': maGV,
        'MaBuoiHocNguon': maBuoiHocNguon,
        'LoaiYeuCau': loaiYeuCau,
        'NgayDeXuat': ngayDeXuat,
        'NgayDeNghiBu': ngayDeNghiBu,
        'CaDeNghiBu': caDeNghiBu,
        'MaPhongDeNghi': maPhongDeNghi,
        'LyDo': lyDo,
        'TrangThai': trangThai,
      };
}
