import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/profile_view_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ProfileViewModel>(context, listen: false);
    _controller = TextEditingController(text: vm.profile?.fullName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        // Inisial nama yang aman
        String initial = '?';
        if (vm.profile != null && (vm.profile!.fullName ?? '').isNotEmpty) {
          initial = vm.profile!.fullName![0].toUpperCase();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profil'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar Preview (hanya inisial)
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      // Tooltip "Coming Soon" untuk kamera
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Tooltip(
                          message: 'Fitur upload foto profil segera hadir',
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Input Nama
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Lengkap",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama lengkap kamu...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person_outline, color: colorScheme.primary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    if (_controller.text.trim().isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Nama wajib diisi',
                          style: TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 40),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final newName = _controller.text.trim();
                            if (newName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama tidak boleh kosong')),
                              );
                              return;
                            }

                            await vm.updateName(newName);
                            if (vm.errorMessage == null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profil berhasil diperbarui'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}