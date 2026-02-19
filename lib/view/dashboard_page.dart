import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/shalat_schedule_response.dart';
import '../viewmodel/shalat_view_model.dart';
import '../view/ramadhan/ramadhan_dashboard_card.dart';

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
    
    // Timer untuk memperbarui UI setiap detik agar sisa waktu & status aktif sinkron
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSchedule();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Penting untuk mencegah memory leak
    super.dispose();
  }

  void _refreshSchedule() {
    final now = DateTime.now();
    context.read<ShalatViewModel>().fetchMonthlySchedule(
          cityId: 1206, // ID Kota Bandung
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
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildMenuItem(context, Icons.menu_book_rounded, 'Al-Quran', Colors.orange, () {}),
                          _buildMenuItem(context, Icons.front_hand_rounded, 'Doa', Colors.blue, () {}),
                          _buildMenuItem(context, Icons.auto_awesome, 'Hadith', Colors.green, () {}),
                          _buildMenuItem(context, Icons.explore_rounded, 'Kiblat', Colors.red, () {}),
                          _buildMenuItem(context, Icons.psychology_alt_rounded, 'Chat AI', Colors.purple, () {}),
                          _buildMenuItem(context, Icons.more_horiz_rounded, 'Lainnya', Colors.grey, () {}),
                        ],
                      ),

                      const SizedBox(height: 32),
                      const RamadhanDashboardCard(),
                      const SizedBox(height: 32),

                      // --- Jadwal Sholat Section (Tanpa Klik) ---
                      _buildSectionHeader(theme, 'Jadwal Sholat', 'Bandung'),
                      const SizedBox(height: 16),
                      _buildPrayerListCard(today, nextPrayer['name']),
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

  Widget _buildHeader(ThemeData theme, Map<String, dynamic> nextPrayer) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
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
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Waktu Sekarang', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          DateFormat('HH:mm').format(DateTime.now()),
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Column(
                      children: [
                        Text('${nextPrayer['name']} Berikutnya', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(
                          nextPrayer['time'],
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2A0E5A))),
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

  // REVISI: Tanpa Material/InkWell agar tidak bisa diklik
  Widget _buildPrayerListCard(ShalatDaySchedule today, String activePrayer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0E5A),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPrayerItem('Subuh', today.subuh, activePrayer == 'Subuh'),
          _buildPrayerItem('Dzuhur', today.dzuhur, activePrayer == 'Dzuhur'),
          _buildPrayerItem('Ashar', today.ashar, activePrayer == 'Ashar'),
          _buildPrayerItem('Maghrib', today.maghrib, activePrayer == 'Maghrib'),
          _buildPrayerItem('Isya', today.isya, activePrayer == 'Isya'),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(String label, String time, bool isActive) {
    return Column(
      children: [
        Text(
          time.isEmpty ? "--:--" : time, 
          style: TextStyle(
            color: isActive ? const Color(0xFFFDCB6E) : Colors.white60, 
            fontSize: 12, 
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal
          )
        ),
        const SizedBox(height: 8),
        Icon(
          isActive ? Icons.wb_sunny_rounded : Icons.circle,
          color: isActive ? const Color(0xFFFDCB6E) : Colors.white12,
          size: isActive ? 20 : 8,
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white38, 
            fontSize: 10
          )
        ),
      ],
    );
  }
}