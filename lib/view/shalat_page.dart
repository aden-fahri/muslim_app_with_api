import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/shalat_schedule_response.dart';
import '../viewmodel/shalat_view_model.dart';

class ShalatPage extends StatefulWidget {
  const ShalatPage({super.key});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update timer setiap detik untuk countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final vm = Provider.of<ShalatViewModel>(context, listen: false);
    final now = DateTime.now();
    vm.fetchMonthlySchedule(
      cityId: 1206, // Bandung
      year: now.year,
      month: now.month,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC), // Mengikuti Theme: surface color
      appBar: AppBar(
        title: const Text('Jadwal Shalat'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Material(
        type: MaterialType.transparency,
        child: Consumer<ShalatViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error != null) {
              return _buildErrorUI(vm);
            }

            // Mencari data hari ini
            final todayStr = DateFormat('yyyy-MM-dd').format(_currentTime);
            final ShalatDaySchedule? todaySchedule = vm.schedules.firstWhere(
              (s) => s.date == todayStr,
              orElse: () => ShalatDaySchedule(
                tanggal: 'Data tidak ditemukan',
                imsak: '', subuh: '', terbit: '', dhuha: '',
                dzuhur: '', ashar: '', maghrib: '', isya: '', date: todayStr,
              ),
            );

            final nextPrayer = _calculateNextPrayer(todaySchedule!);

            return Column(
              children: [
                _buildHeader(nextPrayer),
                const Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 16),
                  child: Text(
                    "Waktu Shalat Hari Ini",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF4A3A6A), // onSurfaceVariant
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Hanya menampilkan item hari ini
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildPrayerRow('Imsak', todaySchedule.imsak, false),
                        _buildPrayerRow('Subuh', todaySchedule.subuh, nextPrayer['name'] == 'Subuh'),
                        _buildPrayerRow('Terbit', todaySchedule.terbit, false),
                        _buildPrayerRow('Dzuhur', todaySchedule.dzuhur, nextPrayer['name'] == 'Dzuhur'),
                        _buildPrayerRow('Ashar', todaySchedule.ashar, nextPrayer['name'] == 'Ashar'),
                        _buildPrayerRow('Maghrib', todaySchedule.maghrib, nextPrayer['name'] == 'Maghrib'),
                        _buildPrayerRow('Isya', todaySchedule.isya, nextPrayer['name'] == 'Isya'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Map<String, String> _calculateNextPrayer(ShalatDaySchedule today) {
    final prayers = {
      'Subuh': today.subuh, 'Dzuhur': today.dzuhur, 
      'Ashar': today.ashar, 'Maghrib': today.maghrib, 'Isya': today.isya,
    };

    DateTime? nextTime;
    String nextName = 'Isya';

    for (var entry in prayers.entries) {
      if (entry.value.isEmpty) continue;
      final parts = entry.value.split(':');
      var candidate = DateTime(_currentTime.year, _currentTime.month, _currentTime.day, int.parse(parts[0]), int.parse(parts[1]));

      if (candidate.isAfter(_currentTime)) {
        nextTime = candidate;
        nextName = entry.key;
        break;
      }
    }

    if (nextTime == null) {
      final parts = today.subuh.split(':');
      nextTime = DateTime(_currentTime.year, _currentTime.month, _currentTime.day + 1, int.parse(parts[0]), int.parse(parts[1]));
      nextName = 'Subuh Besok';
    }

    final diff = nextTime.difference(_currentTime);
    return {
      'name': nextName,
      'countdown': "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}"
    };
  }

  Widget _buildHeader(Map<String, String> nextPrayer) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5ABF), Color(0xFF9F7EE6)], // Primary & Secondary
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5ABF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              nextPrayer['name']!.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nextPrayer['countdown']!,
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "menuju waktu shalat",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(String label, String time, bool isNext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFFE8DEFF) : Colors.white, // primaryContainer jika aktif
        borderRadius: BorderRadius.circular(20),
        border: isNext ? Border.all(color: const Color(0xFF7C5ABF), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded, 
                color: isNext ? const Color(0xFF7C5ABF) : const Color(0xFFB8975A).withOpacity(0.5),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF2A0E5A),
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isNext ? const Color(0xFF7C5ABF) : const Color(0xFF2A0E5A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI(ShalatViewModel vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Color(0xFFB8975A)),
          const SizedBox(height: 16),
          Text('Gagal memuat jadwal: ${vm.error}'),
          TextButton(onPressed: _refreshData, child: const Text('Coba Lagi'))
        ],
      ),
    );
  }
}