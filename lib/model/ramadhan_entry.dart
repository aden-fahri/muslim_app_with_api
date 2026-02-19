class RamadhanEntry {
  final String date; // 'YYYY-MM-DD'
  final Map<String, bool> sholat;

  RamadhanEntry({
    required this.date,
    Map<String, bool>? sholat,
  }) : sholat = sholat ?? {
          'subuh': false,
          'dzuhur': false,
          'ashar': false,
          'maghrib': false,
          'isya': false,
          'dhuha': false,
          'tahajjud': false,
          'tarawih': false,
          'witir': false,
        };

  // Dari Supabase JSON → object
  factory RamadhanEntry.fromJson(Map<String, dynamic> json) {
    final sholatJson = json['sholat'] as Map<String, dynamic>? ?? {};

    return RamadhanEntry(
      date: json['date'] as String,
      sholat: {
        'subuh': sholatJson['subuh'] as bool? ?? false,
        'dzuhur': sholatJson['dzuhur'] as bool? ?? false,
        'ashar': sholatJson['ashar'] as bool? ?? false,
        'maghrib': sholatJson['maghrib'] as bool? ?? false,
        'isya': sholatJson['isya'] as bool? ?? false,
      },
    );
  }

  // Ke format JSON untuk Supabase upsert
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'sholat': sholat,
      // kalau nanti tambah infak/ceramah → tambah di sini
    };
  }

  void operator [](String other) {}
}