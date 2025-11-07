class MonHocTienDo {
  final String tenMonHoc;
  final double tienDo;

  MonHocTienDo({required this.tenMonHoc, required this.tienDo});

  factory MonHocTienDo.fromJson(Map<String, dynamic> json) {
    return MonHocTienDo(
      tenMonHoc: json['TenMonHoc'] ?? '',
      tienDo: (json['TienDo'] ?? 0).toDouble(),
    );
  }
}

class TienDoTongQuan {
  final double chuyenCanTB;
  final List<MonHocTienDo> monHoc;

  TienDoTongQuan({required this.chuyenCanTB, required this.monHoc});

  factory TienDoTongQuan.fromJson(Map<String, dynamic> json) {
    var list = json['MonHoc'] as List? ?? [];
    return TienDoTongQuan(
      chuyenCanTB: (json['ChuyenCanTB'] ?? 0).toDouble(),
      monHoc: list.map((e) => MonHocTienDo.fromJson(e)).toList(),
    );
  }
}
