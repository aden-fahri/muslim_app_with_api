import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:muslim_app/model/profile_model.dart';

class ProfileRepository {
  Profile? getCurrentProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    return Profile(
      fullName: user.userMetadata?['full_name'] as String?,
      email: user.email ?? 'tidak tersedia',
    );
  }

  Future<bool> updateFullName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': trimmed}),
      );
      return true;
    } catch (e) {
      print('Error update nama: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      print('DEBUG: Mulai signOut...');
      await Supabase.instance.client.auth.signOut();
      print('DEBUG: signOut berhasil');
    } catch (e) {
      print('DEBUG: Error signOut: $e');
    }
  }
}