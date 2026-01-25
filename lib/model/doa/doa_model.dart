class Doa {
  final String id;
  final String doa; 
  final String ayat;
  final String latin;
  final String artinya;

  Doa({
    required this.id,
    required this.doa,
    required this.ayat,
    required this.latin,
    required this.artinya,
  });

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: json['id']?.toString() ?? '',
      doa: json['doa'] as String? ?? 'Tidak ada judul',
      ayat: json['ayat'] as String? ?? '',
      latin: json['latin'] as String? ?? '',
      artinya: json['artinya'] as String? ?? '',
    );
  }
}
