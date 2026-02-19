class ShalatScheduleResponse {
  final bool status;
  final String? message;
  final List<ShalatDaySchedule> jadwal;

  ShalatScheduleResponse({
    required this.status,
    this.message,
    required this.jadwal,
  });

  factory ShalatScheduleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final jadwalList = (data['jadwal'] as List<dynamic>?) ?? [];

    return ShalatScheduleResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String?,
      jadwal: jadwalList.map((e) => ShalatDaySchedule.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ShalatDaySchedule {
  final String tanggal;
  final String imsak;
  final String subuh;
  final String terbit;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String date;

  ShalatDaySchedule({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.date,
  });

  factory ShalatDaySchedule.fromJson(Map<String, dynamic> json) {
    return ShalatDaySchedule(
      tanggal: json['tanggal']?.toString() ?? '',
      imsak: json['imsak']?.toString() ?? '',
      subuh: json['subuh']?.toString() ?? '',
      terbit: json['terbit']?.toString() ?? '',
      dhuha: json['dhuha']?.toString() ?? '',
      dzuhur: json['dzuhur']?.toString() ?? '',
      ashar: json['ashar']?.toString() ?? '',
      maghrib: json['maghrib']?.toString() ?? '',
      isya: json['isya']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}