class Surat {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;

  Surat({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
  });

  factory Surat.fromJson(Map<String, dynamic> json) {
    return Surat(
      nomor: json['nomor'] as int,
      nama: json['nama'] as String,
      namaLatin: json['namaLatin'] as String,
      jumlahAyat: json['jumlahAyat'] as int,
      tempatTurun: json['tempatTurun'] as String,
      arti: json['arti'] as String,
      deskripsi: json['deskripsi'] as String,
    );
  }
}

class SuratResponse {
  final int code;
  final String message;
  final List<Surat> data;

  SuratResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuratResponse.fromJson(Map<String, dynamic> json) {
    return SuratResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => Surat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final String audio; // URL audio MP3

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: json['nomorAyat'] as int,
      teksArab: json['teksArab'] as String,
      teksLatin: json['teksLatin'] as String,
      teksIndonesia: json['teksIndonesia'] as String,
      audio:
          json['audio']['01']
              as String, // ambil audio pertama (ada beberapa varian)
    );
  }
}

class SuratDetailResponse {
  final int code;
  final String message;
  final SuratDetail data;

  SuratDetailResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuratDetailResponse.fromJson(Map<String, dynamic> json) {
    return SuratDetailResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: SuratDetail.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class SuratDetail extends Surat {
  // extend dari Surat existing
  final List<Ayat> ayat;
  final String audioFull; // audio full surah (opsional)

  SuratDetail({
    required super.nomor,
    required super.nama,
    required super.namaLatin,
    required super.jumlahAyat,
    required super.tempatTurun,
    required super.arti,
    required super.deskripsi,
    required this.ayat,
    required this.audioFull,
  });

  factory SuratDetail.fromJson(Map<String, dynamic> json) {
    final suratBase = Surat.fromJson(json); // reuse model surat
    return SuratDetail(
      nomor: suratBase.nomor,
      nama: suratBase.nama,
      namaLatin: suratBase.namaLatin,
      jumlahAyat: suratBase.jumlahAyat,
      tempatTurun: suratBase.tempatTurun,
      arti: suratBase.arti,
      deskripsi: suratBase.deskripsi,
      ayat: (json['ayat'] as List)
          .map((e) => Ayat.fromJson(e as Map<String, dynamic>))
          .toList(),
      audioFull: json['audioFull']['01'] as String? ?? '', // audio full
    );
  }
}
