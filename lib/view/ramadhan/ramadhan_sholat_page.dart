import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/ramadhan_view_model.dart';
import '../../viewmodel/shalat_view_model.dart';
import '../../model/shalat_schedule_response.dart';

class RamadhanSholatPage extends StatefulWidget {
  const RamadhanSholatPage({super.key});

  @override
  State<RamadhanSholatPage> createState() => _RamadhanSholatPageState();
}

class _RamadhanSholatPageState extends State<RamadhanSholatPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<RamadhanViewModel>(context, listen: false).refreshTodayEntry();
  } 
  
  Timer? _countdownTimer;
  DateTime _now = DateTime.now();
  String _nextPrayerName = 'Memuat...';
  String _nextPrayerCountdown = '';

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
          _updateNextPrayer();
        });
      }
    });
  }

  void _updateNextPrayer() {
    final vm = Provider.of<ShalatViewModel>(context, listen: false);
    if (vm.schedules.isEmpty) return;

    final todayStr = DateFormat('yyyy-MM-dd').format(_now);
    final today = vm.schedules.firstWhere(
      (s) => s.date == todayStr,
      orElse: () => ShalatDaySchedule(
        tanggal: '', imsak: '', subuh: '', terbit: '', dhuha: '',
        dzuhur: '', ashar: '', maghrib: '', isya: '', date: todayStr,
      ),
    );

    final prayers = {
      'Subuh': today.subuh,
      'Dzuhur': today.dzuhur,
      'Ashar': today.ashar,
      'Maghrib': today.maghrib,
      'Isya': today.isya,
    };

    DateTime? nextTime;
    String? nextName;

    for (var entry in prayers.entries) {
      if (entry.value.isEmpty) continue;
      final parts = entry.value.split(':');
      var candidate = DateTime(_now.year, _now.month, _now.day, 
          int.parse(parts[0]), int.parse(parts[1]));

      if (candidate.isBefore(_now)) {
        if (entry.key == 'Isya') candidate = candidate.add(const Duration(days: 1));
        else continue;
      }

      if (nextTime == null || candidate.isBefore(nextTime)) {
        nextTime = candidate;
        nextName = entry.key;
      }
    }

    if (nextTime != null) {
      final diff = nextTime.difference(_now);
      _nextPrayerName = nextName!;
      _nextPrayerCountdown = "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari tema kamu
    const primaryPurple = Color(0xFF7C5ABF);
    const softPurpleBg = Color(0xFFF8F5FC);
    const deepPurpleText = Color(0xFF2A0E5A);
    const goldAccent = Color(0xFFB8975A);

    return Scaffold(
      backgroundColor: softPurpleBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: deepPurpleText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jurnal Ramadhan',
          style: TextStyle(color: deepPurpleText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer2<RamadhanViewModel, ShalatViewModel>(
        builder: (context, ramadhanVm, shalatVm, child) {
          if (ramadhanVm.isLoading || shalatVm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          final entry = ramadhanVm.todayEntry;
          if (entry == null) return const Center(child: Text('Data tidak ditemukan'));

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            children: [
              // --- Header Countdown Card (Gradient Ungu Tema) ---
              _buildCountdownCard(entry.date, primaryPurple, goldAccent),

              const SizedBox(height: 32),

              // --- Sholat Wajib Section ---
              _buildSectionTitle('Sholat Wajib', deepPurpleText),
              const SizedBox(height: 12),
              _buildPrayerContainer(
                [
                  _prayerItem(ramadhanVm, 'Subuh', _getPrayerTime(shalatVm, 'subuh'), 'subuh', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Dzuhur', _getPrayerTime(shalatVm, 'dzuhur'), 'dzuhur', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Ashar', _getPrayerTime(shalatVm, 'ashar'), 'ashar', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Maghrib', _getPrayerTime(shalatVm, 'maghrib'), 'maghrib', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Isya', _getPrayerTime(shalatVm, 'isya'), 'isya', primaryPurple),
                ],
              ),

              const SizedBox(height: 32),

              // --- Sholat Sunnah Section ---
              _buildSectionTitle('Ibadah Sunnah', deepPurpleText),
              const SizedBox(height: 12),
              _buildPrayerContainer(
                [
                  _prayerItem(ramadhanVm, 'Tahajjud', 'Malam hari', 'tahajjud', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Dhuha', 'Pagi hari', 'dhuha', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Tarawih', 'Setelah Isya', 'tarawih', primaryPurple),
                  _divider(),
                  _prayerItem(ramadhanVm, 'Witir', 'Penutup sholat', 'witir', primaryPurple),
                ],
              ),
              
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Semangat mengejar keberkahan!',
                  style: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountdownCard(String date, Color primary, Color accent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, const Color(0xFF9F7EE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            date, 
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 16),
          const Text(
            'Menuju Waktu Sholat Berikutnya', 
            style: TextStyle(color: Colors.white, fontSize: 14)
          ),
          const SizedBox(height: 8),
          Text(
            _nextPrayerCountdown,
            style: TextStyle(
              color: accent, // Menggunakan warna Gold Soft (0xFFB8975A)
              fontSize: 42, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.5
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _nextPrayerName.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildPrayerContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C5ABF).withOpacity(0.06), 
            blurRadius: 20, 
            offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _prayerItem(RamadhanViewModel vm, String title, String time, String key, Color activeColor) {
    final bool isDone = vm.todayEntry?.sholat[key] ?? false;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        title, 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A0E5A))
      ),
      subtitle: Text(
        time, 
        style: const TextStyle(color: Colors.black45, fontSize: 12)
      ),
      trailing: Checkbox(
        value: isDone,
        activeColor: activeColor,
        checkColor: Colors.white,
        side: const BorderSide(color: Colors.black26, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        onChanged: (val) => vm.updateSholat(key, val!),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 24, endIndent: 24, color: Colors.grey[100]);
  }

  String _getPrayerTime(ShalatViewModel vm, String key) {
    if (vm.schedules.isEmpty) return '--:--';
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final today = vm.schedules.firstWhere(
      (s) => s.date == todayStr, 
      orElse: () => vm.schedules.first
    );
    
    switch (key.toLowerCase()) {
      case 'subuh': return today.subuh;
      case 'dzuhur': return today.dzuhur;
      case 'ashar': return today.ashar;
      case 'maghrib': return today.maghrib;
      case 'isya': return today.isya;
      default: return '--:--';
    }
  }
}