import 'package:flutter/foundation.dart';
import '../model/ramadhan_entry.dart';
import '../repository/ramadhan_repository.dart';

class RamadhanViewModel extends ChangeNotifier {
  final RamadhanRepository _repository;

  RamadhanEntry? _todayEntry;
  bool _isLoading = false;
  String? _error;

  RamadhanViewModel(this._repository);

  RamadhanEntry? get todayEntry => _todayEntry;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter infak & ceramah
  List<Map<String, dynamic>> get todayInfak => _todayEntry?.infak ?? [];
  List<Map<String, dynamic>> get todayCeramah => _todayEntry?.ceramah ?? [];

  int get totalInfakHariIni {
    return todayInfak.fold(0, (sum, item) => sum + (item['nominal'] as int? ?? 0));
  }

  Future<void> loadTodayEntry() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayEntry = await _repository.getTodayEntry();

      if (_todayEntry == null) {
        final today = DateTime.now();
        final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        _todayEntry = RamadhanEntry(date: dateStr);
        await _repository.saveEntry(_todayEntry!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSholat(String waktu, bool value) {
    if (_todayEntry == null) return;

    final newSholat = Map<String, bool>.from(_todayEntry!.sholat);
    newSholat[waktu] = value;

    _todayEntry = RamadhanEntry(
      date: _todayEntry!.date,
      sholat: newSholat,
      infak: _todayEntry!.infak,
      ceramah: _todayEntry!.ceramah,
    );

    notifyListeners();

    _repository.saveEntry(_todayEntry!).catchError((e) {
      _error = 'Gagal simpan: $e';
      notifyListeners();
    });
  }

  Future<void> addInfak({
    required int nominal,
    String? kategori,
    String? catatan,
  }) async {
    if (_todayEntry == null) return;

    final newItem = {
      'nominal': nominal,
      if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
      if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      'created_at': DateTime.now().toIso8601String(),
    };

    final updatedInfak = [..._todayEntry!.infak, newItem];

    _todayEntry = RamadhanEntry(
      date: _todayEntry!.date,
      sholat: _todayEntry!.sholat,
      infak: updatedInfak,
      ceramah: _todayEntry!.ceramah,
    );

    notifyListeners();

    try {
      await _repository.addInfak(_todayEntry!.date, newItem);
    } catch (e) {
      _error = 'Gagal simpan infak: $e';
      notifyListeners();
    }
  }

  Future<void> removeInfak(int index) async {
    if (_todayEntry == null || index < 0 || index >= _todayEntry!.infak.length) {
      return;
    }

    try {
      await _repository.removeInfak(_todayEntry!.date, index);

      final updatedInfak = List<Map<String, dynamic>>.from(_todayEntry!.infak)..removeAt(index);

      _todayEntry = RamadhanEntry(
        date: _todayEntry!.date,
        sholat: _todayEntry!.sholat,
        infak: updatedInfak,
        ceramah: _todayEntry!.ceramah,
      );

      notifyListeners();
    } catch (e) {
      _error = 'Gagal hapus infak: $e';
      notifyListeners();
    }
  }

  // Tambahkan method addCeramah kalau nanti mau (untuk sekarang kosongkan dulu kalau belum dipakai)
  Future<void> addCeramah({
    required String tema,
    String? sumber,
    int? durasiMenit,
  }) async {
    // Implementasi mirip addInfak, tapi untuk ceramah
    // ... (bisa ditambah nanti)
  }
}