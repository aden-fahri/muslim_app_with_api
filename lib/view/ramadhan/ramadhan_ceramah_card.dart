import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/ramadhan_view_model.dart';
import 'ramadhan_ceramah_page.dart';

class RamadhanCeramahCard extends StatelessWidget {
  const RamadhanCeramahCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RamadhanViewModel>(
      builder: (context, vm, child) {
        if (vm.todayEntry == null && !vm.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => vm.loadTodayEntry());
        }

        final count = vm.todayCeramah.length;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: Colors.purple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RamadhanCeramahPage()),
              ),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.record_voice_over, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Catatan Ceramah',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$count ceramah hari ini',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Catat tema & manfaatnya',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
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
}