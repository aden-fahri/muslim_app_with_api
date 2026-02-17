class AsmaulHusnaResponse {
  final int statusCode;
  final int total;
  final List<AsmaulHusna> data;

  AsmaulHusnaResponse({
    required this.statusCode,
    required this.total,
    required this.data,
  });

  factory AsmaulHusnaResponse.fromJson(Map<String, dynamic> json) {
    return AsmaulHusnaResponse(
      statusCode: json['statusCode'] as int,
      total: json['total'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => AsmaulHusna.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AsmaulHusna {
  final int urutan;
  final String latin;
  final String arab;
  final String arti;

  AsmaulHusna({
    required this.urutan,
    required this.latin,
    required this.arab,
    required this.arti,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      urutan: json['urutan'] as int,
      latin: json['latin'] as String,
      arab: json['arab'] as String,
      arti: json['arti'] as String,
    );
  }

  // untuk search atau tampilan
  String get displayName => "$latin - $arab";
}
