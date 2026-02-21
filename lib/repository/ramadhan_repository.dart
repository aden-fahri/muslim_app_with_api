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

  Future<void> addInfak(String date, Map<String, dynamic> infakItem) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    // Ambil entry saat ini
    final response = await _client
        .from('ramadhan_entries')
        .select('infak')
        .eq('user_id', user.id)
        .eq('date', date)
        .maybeSingle();

    List<dynamic> currentInfak = [];
    if (response != null && response['infak'] != null) {
      currentInfak = List.from(response['infak']);
    }

    currentInfak.add(infakItem);

    await _client.from('ramadhan_entries').upsert({
      'user_id': user.id,
      'date': date,
      'infak': currentInfak,
    }, onConflict: 'user_id,date');
  }

  Future<void> removeInfak(String date, int index) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User belum login');
    }

    // Ambil data infak saat ini
    final response = await _client
        .from('ramadhan_entries')
        .select('infak')
        .eq('user_id', user.id)
        .eq('date', date)
        .maybeSingle();

    if (response == null || response['infak'] == null) {
      return; // tidak ada data → skip
    }

    List<dynamic> currentInfak = List.from(response['infak']);

    if (index < 0 || index >= currentInfak.length) {
      throw Exception('Index infak tidak valid: $index');
    }

    currentInfak.removeAt(index);

    // Update kembali ke database (hanya field infak)
    await _client.from('ramadhan_entries').upsert({
      'user_id': user.id,
      'date': date,
      'infak': currentInfak,
    }, onConflict: 'user_id,date');
  }

    Future<void> addCeramah(String date, Map<String, dynamic> ceramahItem) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    final response = await _client
        .from('ramadhan_entries')
        .select('ceramah')
        .eq('user_id', user.id)
        .eq('date', date)
        .maybeSingle();

    List<dynamic> currentCeramah = [];
    if (response != null && response['ceramah'] != null) {
      currentCeramah = List.from(response['ceramah']);
    }

    currentCeramah.add(ceramahItem);

    await _client.from('ramadhan_entries').upsert({
      'user_id': user.id,
      'date': date,
      'ceramah': currentCeramah,
    }, onConflict: 'user_id,date');
  }

  Future<void> removeCeramah(String date, int index) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    final response = await _client
        .from('ramadhan_entries')
        .select('ceramah')
        .eq('user_id', user.id)
        .eq('date', date)
        .maybeSingle();

    if (response == null || response['ceramah'] == null) return;

    List<dynamic> currentCeramah = List.from(response['ceramah']);

    if (index < 0 || index >= currentCeramah.length) {
      throw Exception('Index ceramah tidak valid: $index');
    }

    currentCeramah.removeAt(index);

    await _client.from('ramadhan_entries').upsert({
      'user_id': user.id,
      'date': date,
      'ceramah': currentCeramah,
    }, onConflict: 'user_id,date');
  }

  // Ambil data 7 hari terakhir
  Future<List<RamadhanEntry>> getEntriesLast7Days() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 7));
    final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from('ramadhan_entries')
        .select()
        .eq('user_id', user.id)
        .gte('date', startStr)
        .lte('date', endStr)
        .order('date', ascending: true);

    return response.map((json) => RamadhanEntry.fromJson(json)).toList();
  }

  // Ambil SEMUA entry user (untuk total keseluruhan)
  Future<List<RamadhanEntry>> getAllEntries() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('ramadhan_entries')
        .select()
        .eq('user_id', user.id)
        .order('date', ascending: true);

    return response.map((json) => RamadhanEntry.fromJson(json)).toList();
  }

  Future<RamadhanEntry?> getEntryByDate(String dateStr) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('ramadhan_entries')
        .select()
        .eq('user_id', user.id)
        .eq('date', dateStr)
        .maybeSingle();

    if (response == null || response.isEmpty) return null;
    return RamadhanEntry.fromJson(response);
  }
}