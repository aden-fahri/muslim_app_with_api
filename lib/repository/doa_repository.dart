import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/doa/doa_model.dart';

class DoaRepository {
  final http.Client _client;
  DoaRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Doa>> getAllDoa() async {
    const url = 'https://open-api.my.id/api/doa';
    print('→ Mulai fetch doa dari open-api.my.id: $url');

    try {
      final res = await _client
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 20));
      print('→ Status: ${res.statusCode}');

      if (res.statusCode != 200) {
        throw Exception('Gagal fetch: ${res.statusCode} - ${res.body}');
      }

      final List<dynamic> jsonList = json.decode(res.body);
      print('→ Jumlah doa diterima: ${jsonList.length}');

      return jsonList.map((e) {
        final json = e as Map<String, dynamic>;
        return Doa.fromJson({
          'id': json['id']?.toString() ?? '',
          'doa': json['judul'] as String? ?? 'Tidak ada judul',
          'ayat': json['arab'] as String? ?? '',
          'latin': json['latin'] as String? ?? '',
          'artinya': json['terjemah'] as String? ?? '',
        });
      }).toList();
    } catch (e, stack) {
      print('→ ERROR fetch doa: $e');
      print('→ Stack: $stack');
      rethrow;
    }
  }
}
