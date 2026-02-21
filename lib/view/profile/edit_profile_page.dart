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
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Nama')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            await vm.updateName(_controller.text);
                            if (vm.errorMessage == null && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}