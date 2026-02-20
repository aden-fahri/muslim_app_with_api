import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/shalat_schedule_response.dart';
import '../viewmodel/shalat_view_model.dart' hide ShalatPage;
import 'jadwal shalat/jadwal_shalat_card.dart';
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
    });
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
      final prayerTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );

      if (prayerTime.isAfter(now)) {
        final diff = prayerTime.difference(now);
        return {
          'name': entry.key,
          'time': entry.value,
          'remaining': "- ${diff.inHours}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}"
        };
      }
    }
    return {'name': 'Subuh', 'time': today.subuh, 'remaining': 'Besok'};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Consumer<ShalatViewModel>(
        builder: (context, vm, child) {
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final today = vm.schedules.firstWhere(
            (s) => s.date == todayStr,
            orElse: () => ShalatDaySchedule(
              tanggal: '', imsak: '', subuh: '', terbit: '', dhuha: '',
              dzuhur: '', ashar: '', maghrib: '', isya: '', date: todayStr,
            ),
          );

          final nextPrayer = _getNextPrayerInfo(today);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(theme, nextPrayer),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Menu Grid ---
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

                      // --- Section Jadwal Terdekat ---
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
                      
                      // --- Ramadhan Cards ---
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

  Widget _buildHeader(ThemeData theme, Map<String, dynamic> nextPrayer) {
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
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=mizuki'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assalamu\'alaikum!', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      const Text('Mizuki', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 28),
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
                Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Waktu Sekarang', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(DateFormat('HH:mm').format(DateTime.now()), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Column(
                      children: [
                        Text('${nextPrayer['name']} Berikutnya', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(nextPrayer['time'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(nextPrayer['remaining'], style: const TextStyle(color: Colors.white60, fontSize: 11)),
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