import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblatModel {
  final double direction; // Heading HP saat ini (dari utara, 0-360)
  final double qiblah; // Arah kiblat dari utara (tetap)
  final double offset; // Selisih: direction - qiblah (untuk rotasi arrow)

  QiblatModel({
    required this.direction,
    required this.qiblah,
    required this.offset,
  });

  // Converter dari package flutter_qiblah (biar independen nanti)
  factory QiblatModel.fromPackage(QiblahDirection data) {
    return QiblatModel(
      direction: data.direction,
      qiblah: data.qiblah,
      offset:
          data.direction - data.qiblah, // atau data.offset kalau package punya
    );
  }

  double get normalizedOffset {
    var off = offset;
    while (off > 180) off -= 360;
    while (off < -180) off += 360;
    return off;
  }
}
