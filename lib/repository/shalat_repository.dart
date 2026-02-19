import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/shalat_schedule_response.dart';

class ShalatRepository {
  final http.Client _client;
  ShalatRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<ShalatScheduleResponse> getMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    final url = Uri.parse(
      'https://api.myquran.com/v2/sholat/jadwal/$cityId/$year/$month',
    );

    print('Fetching jadwal from: $url'); // ← tambah ini untuk debug

    final res = await _client.get(url);

    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}'); // ← ini penting, lihat apa yang dikembalikan

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: gagal ambil data');
    }

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;

    // Tambah pengecekan kalau response bukan jadwal
    if (!jsonMap.containsKey('data') || jsonMap['data'] is! Map || !(jsonMap['data'] as Map).containsKey('jadwal')) {
      throw Exception('Response tidak mengandung jadwal sholat: ${jsonMap['data']}');
    }

    final parsed = ShalatScheduleResponse.fromJson(jsonMap);

    if (!parsed.status) {
      throw Exception(parsed.message ?? 'API status = false');
    }

    return parsed;
  }
}
  