import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/shalat_schedule_response.dart';
import '../viewmodel/profile_view_model.dart';
import '../viewmodel/shalat_view_model.dart' hide ShalatPage;
import 'dzikir_dashboard/dzikir_card.dart';
import 'jadwal shalat/jadwal_shalat_card.dart';
import 'profile/profile_page.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'chat_page.dart';
import 'qiblat_page.dart';
import 'asmaul_husna_page.dart';
import 'shalat_page.dart';
import 'ramadhan/ramadhan_dashboard_card.dart';
import 'ramadhan/ramadhan_infak_card.dart';
import 'ramadhan/ramadhan_ceramah_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSchedule();
      Provider.of<ProfileViewModel>(context, listen: false).refreshProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<ProfileViewModel>(context, listen: false).refreshProfile();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refreshSchedule() {
    final now = DateTime.now();
    context.read<ShalatViewModel>().fetchMonthlySchedule(
          cityId: 1206, // Bandung
          year: now.year,
          month: now.month,
        );
  }

  // ── Fungsi untuk mendapatkan sholat berikutnya + countdown ──
  Map<String, dynamic> _getNextPrayerInfo(ShalatDaySchedule today) {
    final now = DateTime.now();
    final prayers = {
      'Subuh': today.subuh,
      'Dzuhur': today.dzuhur,
      'Ashar': today.ashar,
      'Maghrib': today.maghrib,
      'Isya': today.isya,
    };

    for (var entry in prayers.entries) {
      if (entry.value.isEmpty) continue;
      final parts = entry.value.split(':');
      if (parts.length != 2) continue;

      final prayerTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now)) {
        final diff = prayerTime.difference(now);
        return {
          'name': entry.key,
          'time': entry.value,
          'remaining': "- ${diff.inHours}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}",
        };
      }
    }

    // Jika sudah lewat Isya → next = Subuh besok
    final subuhParts = today.subuh.split(':');
    if (subuhParts.length == 2) {
      final tomorrowSubuh = DateTime(
        now.year,
        now.month,
        now.day + 1,
        int.parse(subuhParts[0]),
        int.parse(subuhParts[1]),
      );
      final diff = tomorrowSubuh.difference(now);
      return {
        'name': 'Subuh',
        'time': today.subuh,
        'remaining': "- ${diff.inHours}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}",
      };
    }

    return {'name': '—', 'time': '--:--', 'remaining': ''};
  }

  // ── Fungsi baru: status sholat SAAT INI + menjelang sholat berikutnya ──
  Map<String, dynamic> _getPrayerStatus(ShalatDaySchedule today) {
    final now = DateTime.now();

    final prayerTimes = <String, String>{
      'Imsak': today.imsak,
      'Subuh': today.subuh,
      'Terbit': today.terbit,
      'Dhuha': today.dhuha,
      'Dzuhur': today.dzuhur,
      'Ashar': today.ashar,
      'Maghrib': today.maghrib,
      'Isya': today.isya,
    };

    String? current = '—';
    String? nextName;
    DateTime? nextTime;
    String nextTimeStr = '--:--';
    String remaining = '';

    // Cari sholat terakhir yang sudah lewat (atau sedang berlangsung)
    for (var entry in prayerTimes.entries) {
      if (entry.value.isEmpty) continue;
      final parts = entry.value.split(':');
      if (parts.length != 2) continue;

      try {
        final t = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        if (!t.isAfter(now)) {
          current = entry.key;
        } else if (nextTime == null || t.isBefore(nextTime)) {
          nextName = entry.key;
          nextTime = t;
          nextTimeStr = entry.value;
        }
      } catch (_) {}
    }

    // Jika sudah lewat Isya → next = Subuh besok
    if (nextName == null && today.subuh.isNotEmpty) {
      nextName = 'Subuh';
      final parts = today.subuh.split(':');
      if (parts.length == 2) {
        nextTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
        nextTimeStr = today.subuh; // tampilkan jam subuh hari ini (artinya besok)
      }
    }

    if (nextTime != null) {
      final diff = nextTime.difference(now);
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      final s = diff.inSeconds % 60;
      remaining = "- ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }

    return {
      'current': current,
      'nextName': nextName ?? '—',
      'nextTime': nextTimeStr,
      'remaining': remaining,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Consumer<ShalatViewModel>(
        builder: (context, vm, child) {
          final now = DateTime.now();
          final todayStr = DateFormat('yyyy-MM-dd').format(now);
          final today = vm.schedules.firstWhere(
            (s) => s.date == todayStr,
            orElse: () => ShalatDaySchedule(
              tanggal: '',
              imsak: '',
              subuh: '',
              terbit: '',
              dhuha: '',
              dzuhur: '',
              ashar: '',
              maghrib: '',
              isya: '',
              date: todayStr,
            ),
          );

          final nextPrayer = _getNextPrayerInfo(today);
          final status = _getPrayerStatus(today);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(theme, nextPrayer, status),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menu Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 10,
                        children: [
                          _buildMenuItem(context, Icons.menu_book_rounded, 'Al-Quran', const Color(0xFFFFA502), const QuranPage()),
                          _buildMenuItem(context, Icons.front_hand_rounded, 'Doa', const Color(0xFF2E86DE), const DoaPage()),
                          _buildMenuItem(context, Icons.access_time_filled_rounded, 'Jadwal Shalat', const Color(0xFFF39C12), const ShalatPage()),
                          _buildMenuItem(context, Icons.mosque_rounded, 'Asmaul Husna', const Color(0xFF27AE60), const AsmaulHusnaPage()),
                          _buildMenuItem(context, Icons.psychology_alt_rounded, 'Asisten AI', const Color(0xFF8E44AD), ChatPage()),
                          _buildMenuItem(context, Icons.explore_rounded, 'Kiblat', const Color(0xFFEB4D4B), const QiblatPage()),
                        ],
                      ),

                      const SizedBox(height: 32),

                      _buildSectionHeader(theme, 'Jadwal Shalat', 'Terdekat'),
                      const SizedBox(height: 16),
                      JadwalShalatCard(
                        label: nextPrayer['name'],
                        time: nextPrayer['time'],
                        isNext: true,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ShalatPage()));
                        },
                      ),

                      const SizedBox(height: 32),

                      // Ramadhan Cards
                      const DzikirCard(),
                      const SizedBox(height: 16),
                      const RamadhanDashboardCard(),
                      const SizedBox(height: 16),
                      const RamadhanInfakCard(),
                      const SizedBox(height: 16),
                      const RamadhanCeramahCard(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, Color color, Widget destination) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2A0E5A)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A0E5A))),
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(subtitle, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, Map<String, dynamic> nextPrayer, Map<String, dynamic> status) {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer<ProfileViewModel>(
                builder: (context, vm, child) {
                  final profile = vm.profile;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          child: Text(
                            profile?.avatarInitial ?? '?',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamu\'alaikum',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                            ),
                            Text(
                              profile?.displayName ?? 'Sahabat',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  // TODO: notifikasi
                },
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Bagian waktu sholat yang di-request ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9F7EE6), Color(0xFF7C5ABF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(now),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Kiri: Waktu sekarang + sedang sholat apa
                    Column(
                      children: [
                        const Text(
                          'Waktu Sekarang',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          DateFormat('HH:mm').format(now),
                          style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status['current'] == '—' ? ' ' : 'Sedang ${status['current']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),

                    Container(width: 1, height: 80, color: Colors.white24),

                    // Kanan: Menjelang sholat berikutnya
                    Column(
                      children: [
                        Text(
                          'Menjelang ${status['nextName']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status['nextTime'],
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          status['remaining'],
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}