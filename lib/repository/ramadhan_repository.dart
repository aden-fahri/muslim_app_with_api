import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/ramadhan_entry.dart';

class RamadhanRepository {
  final SupabaseClient _client;

  RamadhanRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<RamadhanEntry?> getTodayEntry() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('ramadhan_entries')
        .select()
        .eq('user_id', user.id)
        .eq('date', dateStr)
        .maybeSingle();

    if (response == null || response.isEmpty) {
      return null;
    }

    return RamadhanEntry.fromJson(response);
  }

  Future<void> saveEntry(RamadhanEntry entry) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    final data = {
      ...entry.toJson(),
      'user_id': user.id,
    };

    await _client
        .from('ramadhan_entries')
        .upsert(data, onConflict: 'user_id, date');
  }
}