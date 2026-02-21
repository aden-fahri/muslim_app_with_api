import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/profile_view_model.dart';
import '../../viewmodel/ramadhan_view_model.dart';
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
    // Refresh data saat masuk halaman agar statistik selalu update
    Provider.of<ProfileViewModel>(context, listen: false).refreshProfile();
    Provider.of<RamadhanViewModel>(context, listen: false).loadTodayEntry();
  }

  // --- FUNGSI POP UP LOGOUT (FIX: Sekali klik langsung logout) ---
  void _showLogoutDialog(BuildContext context, ProfileViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Keluar Akun?'),
        content: const Text(
          'Apakah Anda yakin ingin keluar? Anda perlu login kembali untuk mengakses data ibadah Anda.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              // Langkah 1: Tutup Dialog
              Navigator.pop(dialogContext);
              // Langkah 2: Eksekusi Logout (Gunakan context halaman, bukan dialogContext)
              await vm.logout(context);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<ProfileViewModel, RamadhanViewModel>(
      builder: (context, profileVM, ramadhanVM, child) {
        if (profileVM.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final profile = profileVM.profile;
        if (profile == null) {
          return Scaffold(
            body: Center(child: Text(profileVM.errorMessage ?? 'Silakan login')),
          );
        }

        // --- LOGIKA STATISTIK HARIAN ---
        final sholat = ramadhanVM.todayEntry?.sholat ?? {};
        const fardhuKeys = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
        final fardhuDone = sholat.entries
            .where((e) => fardhuKeys.contains(e.key) && e.value)
            .length;
        final fardhuProgress = fardhuDone / 5;

        const sunnahKeys = ['tahajjud', 'dhuha', 'tarawih', 'witir'];
        final sunnahDone = sholat.entries
            .where((e) => sunnahKeys.contains(e.key) && e.value)
            .length;

        return Scaffold(
          appBar: AppBar(title: const Text('Profil')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Profil (Foto & Nama)
              ProfileHeader(profile: profile),
              const SizedBox(height: 24),

              // Bagian 1: Harian
              _buildSectionTitle('Ibadah Hari Ini', colorScheme),
              const SizedBox(height: 12),
              _buildDailyStatsCard(
                  ramadhanVM, fardhuDone, fardhuProgress, sunnahDone, colorScheme),

              const SizedBox(height: 24),

              // Bagian 2: Mingguan
              _buildSectionTitle('Ringkasan 7 Hari Terakhir', colorScheme),
              const SizedBox(height: 12),
              _buildWeeklyStatsCard(ramadhanVM, colorScheme),

              const SizedBox(height: 24),

              // Bagian 3: Pengaturan Akun
              _buildSectionTitle('Pengaturan Akun', colorScheme),
              const SizedBox(height: 8),
              _buildAccountMenu(context, profileVM, profile.email, colorScheme),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildDailyStatsCard(RamadhanViewModel vm, int fardhuDone,
      double progress, int sunnahDone, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow, blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sholat Fardhu',
                    style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7))),
                Text('$fardhuDone / 5 Waktu',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 14, color: colorScheme.tertiary),
                    const SizedBox(width: 4),
                    Text('Sunnah: $sunnahDone dilakukan',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsCard(RamadhanViewModel vm, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _weeklyItem('Sholat', '${vm.totalSholatMingguIni}',
                Icons.check_circle_outlined),
            VerticalDivider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
                indent: 5,
                endIndent: 5),
            _weeklyItem(
                'Infak',
                'Rp ${NumberFormat('#,###').format(vm.totalInfakMingguIni)}',
                Icons.wallet_giftcard_rounded),
            VerticalDivider(
                color: Colors.white.withOpacity(0.3),
                thickness: 1,
                indent: 5,
                endIndent: 5),
            _weeklyItem('Ceramah', '${vm.totalCeramahMingguIni}',
                Icons.menu_book_rounded),
          ],
        ),
      ),
    );
  }

  Widget _weeklyItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildAccountMenu(
      BuildContext context, ProfileViewModel vm, String email, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: colorScheme.shadow, blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.email_outlined, color: colorScheme.primary),
            title: Text(email,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle:
                const Text('Email Terdaftar', style: TextStyle(fontSize: 12)),
          ),
          const Divider(height: 1),
          ProfileMenuItem(
            icon: Icons.edit_note_rounded,
            title: 'Edit Nama Profil',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
          ),
          ProfileMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar Akun',
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () => _showLogoutDialog(context, vm),
          ),
        ],
      ),
    );
  }
}