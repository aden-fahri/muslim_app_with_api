import 'package:flutter/material.dart';
import 'package:muslim_app/model/profile_model.dart';
import 'package:muslim_app/repository/profile_repository.dart';

import '../view/auth/login_page.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo;

  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileViewModel(this._repo);

  void refreshProfile() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final newProfile = _repo.getCurrentProfile();

    if (newProfile != null) {
      _profile = newProfile;
    } else {
      _profile = null;
      _errorMessage = 'Belum login';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _repo.updateFullName(newName);
    if (success) {
      refreshProfile();
    } else {
      _errorMessage = 'Gagal menyimpan nama';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await _repo.signOut();

    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}