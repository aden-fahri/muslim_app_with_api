import 'package:flutter/foundation.dart';
import '../model/dzikir_model.dart';
import '../repository/dzikir_repository.dart';

class DzikirViewModel extends ChangeNotifier {
  final DzikirRepository _repository;

  DzikirModel? _currentDzikir;
  int _selectedIndex = 0;
  String? _error;

  DzikirViewModel(this._repository);

  DzikirModel? get currentDzikir => _currentDzikir;
  int get selectedIndex => _selectedIndex;
  List<DzikirModel> get availableDzikirs => _repository.defaultDzikirs;
  String? get error => _error;

  bool get isCompleted => _currentDzikir?.isCompleted ?? false;

  Future<void> initialize() async {
    try {
      _currentDzikir = await _repository.getCurrentDzikir();
      _selectedIndex = _repository.defaultDzikirs.indexWhere(
        (d) => d.title == _currentDzikir?.title,
      );
      if (_selectedIndex == -1) _selectedIndex = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data dzikir: $e';
      notifyListeners();
    }
  }

  Future<void> increment() async {
    if (_currentDzikir == null) return;

    final newCount = _currentDzikir!.currentCount + 1;
    _currentDzikir = _currentDzikir!.copyWith(currentCount: newCount);

    await _repository.saveCurrentCount(newCount);
    notifyListeners();

    // Optional: tambah efek getar / suara di sini nanti
  }

  Future<void> reset() async {
    if (_currentDzikir == null) return;

    _currentDzikir = _currentDzikir!.copyWith(currentCount: 0);
    await _repository.resetCount();
    notifyListeners();
  }

  Future<void> changeType(int newIndex) async {
    if (newIndex < 0 || newIndex >= _repository.defaultDzikirs.length) return;
    if (newIndex == _selectedIndex) return;

    _selectedIndex = newIndex;
    final selected = _repository.defaultDzikirs[newIndex];

    // Reset count saat ganti jenis dzikir
    _currentDzikir = selected.copyWith(currentCount: 0);

    await _repository.saveSelectedType(newIndex);
    await _repository.saveCurrentCount(0);

    notifyListeners();
  }
}