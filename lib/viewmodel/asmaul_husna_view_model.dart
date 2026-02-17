import 'package:flutter/material.dart';
import '../model/asmaul_husna_model.dart';
import '../repository/asmaul_husna_repository.dart';

class AsmaulHusnaViewModel extends ChangeNotifier {
  final AsmaulHusnaRepository _repository = AsmaulHusnaRepository();

  List<AsmaulHusna> _items = [];
  List<AsmaulHusna> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;

  AsmaulHusnaViewModel(AsmaulHusnaRepository read);
  String? get error => _error;

  Future<void> fetchAsmaulHusna() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllAsmaulHusna();
      _items = response.data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Opsional: fitur pencarian lokal
  void search(String query) {
    if (query.isEmpty) {
      // kembalikan semua data (atau panggil ulang API jika perlu)
      fetchAsmaulHusna();
    } else {
      final lowerQuery = query.toLowerCase();
      _items = _items.where((item) {
        return item.latin.toLowerCase().contains(lowerQuery) ||
            item.arti.toLowerCase().contains(lowerQuery) ||
            item.arab.contains(query);
      }).toList();
      notifyListeners();
    }
  }
}
