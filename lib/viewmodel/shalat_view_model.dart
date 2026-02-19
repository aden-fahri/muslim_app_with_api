import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../model/shalat_schedule_response.dart';
import '../repository/shalat_repository.dart';

/// ViewModel
class ShalatViewModel extends ChangeNotifier {
  final ShalatRepository _repo;
  ShalatViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  List<ShalatDaySchedule> _schedules = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ShalatDaySchedule> get schedules => _schedules;

  Future<void> fetchMonthlySchedule({
    required int cityId,
    required int year,
    required int month,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repo.getMonthlySchedule(
        cityId: cityId,
        year: year,
        month: month,
      );
      _schedules = res.jadwal;
    } catch (e) {
      _error = e.toString();
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
/// UI Widget
class ShalatPage extends StatefulWidget {
  const ShalatPage({super.key});

  @override
  State<ShalatPage> createState() => _ShalatPageState();
}

class _ShalatPageState extends State<ShalatPage> {
  String _nextPrayerName = '';
  String _nextPrayerCountdown = '';

  void _updateNextPrayer() {
    final shalatVm = Provider.of<ShalatViewModel>(context, listen: false);

    if (shalatVm.schedules.isEmpty) {
      setState(() {
        _nextPrayerName = 'Memuat jadwal...';
        _nextPrayerCountdown = '';
      });
      return;
    }

    // TODO: logika menghitung shalat berikutnya
    // Misalnya ambil jadwal hari ini, bandingkan dengan DateTime.now()
    // lalu setState untuk _nextPrayerName dan _nextPrayerCountdown
  }

  @override
  Widget build(BuildContext context) {
    final shalatVm = Provider.of<ShalatViewModel>(context);

    if (shalatVm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shalatVm.schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Jadwal sholat belum dimuat'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                shalatVm.fetchMonthlySchedule(
                  cityId: 1206,
                  year: now.year,
                  month: now.month,
                );
              },
              child: const Text('Muat Jadwal Sholat'),
            ),
          ],
        ),
      );
    }

    // Jika jadwal sudah ada
    return ListView.builder(
      itemCount: shalatVm.schedules.length,
      itemBuilder: (context, index) {
        final schedule = shalatVm.schedules[index];
        return ListTile(
          title: Text('Tanggal: ${schedule.date}'),
          subtitle: Text(
            'Subuh: ${schedule.subuh}, Dzuhur: ${schedule.dzuhur}, '
            'Ashar: ${schedule.ashar}, Maghrib: ${schedule.maghrib}, '
            'Isya: ${schedule.isya}',
          ),
        );
      },
    );
  }
}