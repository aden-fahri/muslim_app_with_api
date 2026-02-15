import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../repository/qiblat_repository.dart';
import '../model/qiblat_model.dart';

class QiblatViewModel extends ChangeNotifier {
  final QiblatRepository _repository;

  bool _sensorAvailable = false;
  QiblatModel? _currentDirection;
  String? _error;
  StreamSubscription<QiblatModel>? _subscription;

  QiblatViewModel(this._repository);

  bool get sensorAvailable => _sensorAvailable;
  QiblatModel? get currentDirection => _currentDirection;
  String? get error => _error;

  double get arrowRotationAngle {
    if (_currentDirection == null) return 0.0;
    // Pakai normalized biar smooth (opsional, tapi recommended)
    final off = _currentDirection!.normalizedOffset;
    return (off * 3.141592653589793 / 180);
  }

  Future<void> initialize() async {
    if (kIsWeb) {
      _error = 'Fitur kiblat tidak tersedia di web/browser';
      notifyListeners();
      return;
    }
    try {
      // Panggil permission dulu
      final granted = await _repository.requestPermissions();
      if (!granted) {
        _error = 'Izin lokasi diperlukan untuk akurasi kiblat';
        notifyListeners();
        return;
      }

      _sensorAvailable = await _repository.checkSensorAvailability();

      if (_sensorAvailable) {
        _subscription = _repository.qiblahStream.listen(
          (direction) {
            _currentDirection = direction;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Error sensor: $e';
            notifyListeners();
          },
        );
      } else {
        _error = 'Perangkat tidak mendukung sensor kompas (magnetometer)';
      }
    } catch (e) {
      _error = 'Gagal inisialisasi: $e';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
