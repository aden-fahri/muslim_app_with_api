import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/ramadhan_view_model.dart';
import 'ramadhan_infak_page.dart';

class RamadhanInfakCard extends StatelessWidget {
  const RamadhanInfakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RamadhanViewModel>(
      builder: (context, vm, child) {
        // Load data jika belum tersedia
        if (vm.todayEntry == null && !vm.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => vm.loadTodayEntry());
        }

        final total = vm.totalInfakHariIni;
        final count = vm.todayInfak.length;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            // Menggunakan Gradient Ungu Lembut agar senada dengan Dashboard
            gradient: const LinearGradient(
              colors: [Color(0xFFF3EFFF), Color(0xFFE8E1FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5ABF).withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RamadhanInfakPage()),
              ),
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C5ABF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.volunteer_activism_rounded, 
                                color: Colors.white, 
                                size: 20
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Tabungan Infak',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: Color(0xFF2A0E5A)
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded, 
                          size: 14, 
                          color: Color(0xFF7C5ABF)
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(total)}',
                          style: const TextStyle(
                            fontSize: 26, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF2A0E5A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ hari ini',
                            style: TextStyle(
                              fontSize: 13, 
                              color: const Color(0xFF2A0E5A).withOpacity(0.5),
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count kali kebaikan telah tercatat',
                      style: TextStyle(
                        fontSize: 12, 
                        color: const Color(0xFF7C5ABF).withOpacity(0.8),
                        fontWeight: FontWeight.w600
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
}