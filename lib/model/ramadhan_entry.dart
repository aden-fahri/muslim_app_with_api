class RamadhanEntry {
  final String date; // 'YYYY-MM-DD'
  final Map<String, bool> sholat;
  final List<Map<String, dynamic>> infak;
  final List<Map<String, dynamic>> ceramah;

  RamadhanEntry({
    required this.date,
    Map<String, bool>? sholat,
    List<Map<String, dynamic>>? infak,
    List<Map<String, dynamic>>? ceramah,
  })  : sholat = sholat ?? {
          'subuh': false,
          'dzuhur': false,
          'ashar': false,
          'maghrib': false,
          'isya': false,
          'dhuha': false,
          'tahajjud': false,
          'tarawih': false,
          'witir': false,
        },
        infak = infak ?? [],
        ceramah = ceramah ?? [];

  factory RamadhanEntry.fromJson(Map<String, dynamic> json) {
    final sholatJson = json['sholat'] as Map<String, dynamic>? ?? {};
    final infakJson = json['infak'] as List<dynamic>? ?? [];
    final ceramahJson = json['ceramah'] as List<dynamic>? ?? [];

    return RamadhanEntry(
      date: json['date'] as String,
      sholat: {
        'subuh': sholatJson['subuh'] as bool? ?? false,
        'dzuhur': sholatJson['dzuhur'] as bool? ?? false,
        'ashar': sholatJson['ashar'] as bool? ?? false,
        'maghrib': sholatJson['maghrib'] as bool? ?? false,
        'isya': sholatJson['isya'] as bool? ?? false,
        'dhuha': sholatJson['dhuha'] as bool? ?? false,
        'tahajjud': sholatJson['tahajjud'] as bool? ?? false,
        'tarawih': sholatJson['tarawih'] as bool? ?? false,
        'witir': sholatJson['witir'] as bool? ?? false,
      },
      infak: infakJson.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      ceramah: ceramahJson.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sholat': sholat,
      'infak': infak,
      'ceramah': ceramah,
    };
  }
}