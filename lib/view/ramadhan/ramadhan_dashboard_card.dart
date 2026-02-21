import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/ramadhan_view_model.dart';
import 'ramadhan_sholat_page.dart';

class RamadhanDashboardCard extends StatelessWidget {
  const RamadhanDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RamadhanViewModel>(
      builder: (context, vm, child) {
        // Auto load
        if (vm.todayEntry == null && !vm.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.loadTodayEntry();
          });
        }

        if (vm.isLoading) return _buildLoadingState();
        if (vm.error != null) return _buildErrorState(vm.error!);

        final entry = vm.todayEntry;
        final sholat = entry?.sholat ?? {};

        // Hitung hanya sholat fardhu (5 waktu)
        const fardhuKeys = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
        final fardhuDone = sholat.entries
            .where((e) => fardhuKeys.contains(e.key) && e.value)
            .length;
        const fardhuTotal = 5;
        final fardhuProgress = fardhuTotal > 0 ? fardhuDone / fardhuTotal : 0.0;

        // Hitung sunnah (4 waktu)
        const sunnahKeys = ['tahajjud', 'dhuha', 'tarawih', 'witir'];
        final sunnahDone = sholat.entries
            .where((e) => sunnahKeys.contains(e.key) && e.value)
            .length;
        const sunnahTotal = 4;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RamadhanSholatPage()),
              ),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green[700], shape: BoxShape.circle),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Mutaba\'ah Ramadhan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.green[900]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$fardhuDone dari $fardhuTotal Waktu Fardhu',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Progress Sholat Wajib',
                                style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sunnah: $sunnahDone dari $sunnahTotal',
                                style: TextStyle(fontSize: 13, color: Colors.green[800]),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: fardhuProgress,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.white.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                              ),
                            ),
                            Text(
                              '${(fardhuProgress * 100).toInt()}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[900]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 14, color: Colors.green[800]),
                          const SizedBox(width: 6),
                          Text(
                            'Klik untuk update jurnal harianmu',
                            style: TextStyle(fontSize: 11, color: Colors.green[800], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 160,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: const Center(child: CircularProgressIndicator(color: Colors.green)),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(28)),
      child: Text('Gagal memuat mutaba\'ah: $error', style: const TextStyle(color: Colors.red)),
    );
  }
}