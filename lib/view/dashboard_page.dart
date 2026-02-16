import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Tambahkan intl di pubspec.yaml untuk format tanggal
import '../viewmodel/shalat_view_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Simulasi data waktu saat ini
    final String currentTime = DateFormat('HH:mm').format(DateTime.now());
    final String currentDate = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header Section ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Profile & Notif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?u=muslim',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assalamu\'alaikum!',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Mizuki',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // --- Hero Card (Jadwal Shalat Utama) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF9F7EE6),
                          const Color.fromARGB(255, 180, 145, 250),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Atas: Tanggal
                        Text(
                          currentDate,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: const Color(0xFF2A0E5A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kiri: Waktu Sekarang
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Waktu Sekarang',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF2A0E5A,
                                    ).withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  currentTime,
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2A0E5A),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            // Pemisah / Divider Vertikal Tipis
                            Container(
                              width: 1,
                              height: 40,
                              color: const Color(0xFF2A0E5A).withOpacity(0.2),
                            ),
                            // Kanan: Info Shalat Selanjutnya
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Selanjutnya',
                                  style: TextStyle(
                                    color: Color(0xFF2A0E5A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const Text(
                                  'Dzuhur',
                                  style: TextStyle(
                                    color: Color(0xFF2A0E5A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '- 02:45:10',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF2A0E5A,
                                    ).withOpacity(0.8),
                                    fontSize: 12,
                                  ),
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
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Menu Grid (Tetap Elegant) ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      _buildMenuItem(
                        context,
                        Icons.menu_book_rounded,
                        'Al-Quran',
                      ),
                      _buildMenuItem(context, Icons.front_hand_rounded, 'Doa'),
                      _buildMenuItem(context, Icons.auto_awesome, 'Hadith'),
                      _buildMenuItem(context, Icons.explore_rounded, 'Kiblat'),
                      _buildMenuItem(
                        context,
                        Icons.psychology_alt_rounded,
                        'Chat AI',
                      ),
                      _buildMenuItem(
                        context,
                        Icons.more_horiz_rounded,
                        'Lainnya',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- Namaz Timings List (Dark Purple Card) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jadwal Sholat', style: theme.textTheme.titleLarge),
                      Text(
                        'Bandung',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A0E5A),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPrayerTime('Subuh', '04:30', true),
                        _buildPrayerTime('Dzuhur', '12:00', false),
                        _buildPrayerTime('Ashar', '15:15', false),
                        _buildPrayerTime('Maghrib', '18:10', false),
                        _buildPrayerTime('Isya', '19:20', false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5ABF).withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF7C5ABF), size: 32),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A0E5A),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTime(String label, String time, bool isActive) {
    return Column(
      children: [
        Text(
          time,
          style: TextStyle(
            color: isActive ? const Color(0xFFB8975A) : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Icon(
          isActive ? Icons.wb_sunny_rounded : Icons.wb_twilight_rounded,
          color: isActive ? const Color(0xFFB8975A) : Colors.white30,
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
