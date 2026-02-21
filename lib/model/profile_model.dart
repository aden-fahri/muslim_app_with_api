class Profile {
  final String? fullName;
  final String email;

  Profile({
    this.fullName,
    required this.email,
  });

  String get displayName =>
      (fullName?.trim().isNotEmpty == true) ? fullName!.trim() : 'Pengguna';

  String get avatarInitial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}