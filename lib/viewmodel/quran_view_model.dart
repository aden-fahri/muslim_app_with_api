import 'package:flutter/foundation.dart';
import '../model/quran/surat.dart';
import '../repository/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository _repo;
  QuranViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<Surat> _surats = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Surat> get surats => _surats;

  Future<void> fetchSuratList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surats = await _repo.getListSurat();
    } catch (e) {
      _error = e.toString();
      _surats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  SuratDetail? _suratDetail;
  SuratDetail? get suratDetail => _suratDetail;

  Future<void> fetchDetailSurat(int nomor) async {
    _isLoading = true;
    _error = null;
    _suratDetail = null;
    notifyListeners();

    try {
      _suratDetail = await _repo.getDetailSurat(nomor);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
