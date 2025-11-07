class PhanCong {
  final int maPhanCong;
  final int maLHP;
  final int maGV;
  final String ngayPhanCong;

  PhanCong({
    required this.maPhanCong,
    required this.maLHP,
    required this.maGV,
    required this.ngayPhanCong,
  });

  factory PhanCong.fromJson(Map<String, dynamic> json) => PhanCong(
    maPhanCong: json['MaPhanCong'],
    maLHP: json['MaLHP'],
    maGV: json['MaGV'],
    ngayPhanCong: json['NgayPhanCong'],
  );

  Map<String, dynamic> toJson() => {
    'MaPhanCong': maPhanCong,
    'MaLHP': maLHP,
    'MaGV': maGV,
    'NgayPhanCong': ngayPhanCong,
  };
}
