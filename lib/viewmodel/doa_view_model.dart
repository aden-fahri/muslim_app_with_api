import 'package:flutter/foundation.dart';
import '../model/doa/doa_model.dart';
import '../repository/doa_repository.dart';

class DoaViewModel extends ChangeNotifier {
  final DoaRepository _repo;
  DoaViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<Doa> _doas = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Doa> get doas => _doas;

  Future<void> fetchDoaList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doas = await _repo.getAllDoa();
    } catch (e) {
      _error = e.toString();
      _doas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
