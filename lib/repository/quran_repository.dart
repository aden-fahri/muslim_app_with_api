import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/quran/surat.dart';

class QuranRepository {
  final http.Client _client;
  QuranRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Surat>> getListSurat() async {
    final url = Uri.parse('https://equran.id/api/v2/surat');

    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil daftar surat: ${res.statusCode}');
    }

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final response = SuratResponse.fromJson(jsonMap);

    if (response.code != 200) {
      throw Exception(response.message);
    }

    return response.data;
  }

  Future<SuratDetail> getDetailSurat(int nomor) async {
    final url = Uri.parse('https://equran.id/api/v2/surat/$nomor');

    final res = await _client.get(url);

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil detail surat: ${res.statusCode}');
    }

    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final response = SuratDetailResponse.fromJson(jsonMap);

    if (response.code != 200) {
      throw Exception(response.message);
    }

    return response.data;
  }
}
