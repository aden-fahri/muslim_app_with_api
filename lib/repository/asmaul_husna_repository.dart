import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/asmaul_husna_model.dart';

class AsmaulHusnaRepository {
  static const String _baseUrl = 'https://asmaul-husna-api.vercel.app/api/all';

  Future<AsmaulHusnaResponse> getAllAsmaulHusna() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return AsmaulHusnaResponse.fromJson(jsonData);
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }
}
