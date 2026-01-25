import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/doa/doa_model.dart';

class DoaRepository {
  final http.Client _client;
  DoaRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Doa>> getAllDoa() async {
    final targetUrl = 'https://doa-doa-api-ahmadramadhan.fly.dev/api';
    // Pakai allorigins dulu (paling stabil)
    final proxyUrl =
        'https://api.allorigins.win/raw?url=${Uri.encodeComponent(targetUrl)}';
    final url = Uri.parse(proxyUrl);

    print('→ Mulai fetch doa via allorigins: $url');

    try {
      final res = await _client.get(url).timeout(const Duration(seconds: 20));
      print('→ Status: ${res.statusCode}');

      if (res.statusCode != 200) {
        throw Exception('Gagal via proxy: ${res.statusCode}');
      }

      final List<dynamic> jsonList = json.decode(res.body);
      print('→ Jumlah doa diterima: ${jsonList.length}');

      return jsonList
          .map((e) => Doa.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      print('→ ERROR fetch doa: $e');
      print('→ Stack: $stack');
      rethrow;
    }
  }
}
