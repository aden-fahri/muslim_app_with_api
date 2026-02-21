import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../viewmodel/profile_view_model.dart';
import 'components/profile_header.dart';
import 'components/profile_menu_item.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<ProfileViewModel>(context, listen: false).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (vm.profile == null) {
          return Scaffold(
            body: Center(child: Text(vm.errorMessage ?? 'Silakan login')),
          );
        }

        final profile = vm.profile!;

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileHeader(profile: profile),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(profile.email),
                  subtitle: const Text('Email'),
                ),
              ),
              const SizedBox(height: 16),
              ProfileMenuItem(
                icon: Icons.edit,
                title: 'Edit Nama',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),
              ProfileMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () async {
                  await vm.logout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}