class GiangVien {
  final int maGV;
  final int maND;
  final int maBoMon;
  final String? trinhDo;

  GiangVien({
    required this.maGV,
    required this.maND,
    required this.maBoMon,
    this.trinhDo,
  });

  factory GiangVien.fromJson(Map<String, dynamic> json) => GiangVien(
    maGV: json['MaGV'],
    maND: json['MaND'],
    maBoMon: json['MaBoMon'],
    trinhDo: json['TrinhDo'],
  );

  Map<String, dynamic> toJson() => {
    'MaGV': maGV,
    'MaND': maND,
    'MaBoMon': maBoMon,
    'TrinhDo': trinhDo,
  };
}
