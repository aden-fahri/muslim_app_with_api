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

  Future<void> loadTodayEntry() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayEntry = await _repository.getTodayEntry();

      // Jika belum ada entry hari ini → buat default
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
    );

    notifyListeners();

    // Auto save (bisa di-debounce kalau terlalu sering)
    _repository.saveEntry(_todayEntry!).catchError((e) {
      _error = 'Gagal simpan: $e';
      notifyListeners();
    });
  }
}