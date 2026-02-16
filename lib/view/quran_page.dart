import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quran_view_model.dart';
import 'surat_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<QuranViewModel>().fetchSuratList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const deepPurple = Color(0xFF2A0E5A); // Warna ungu gelap dari dashboard

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FF),
      body: Consumer<QuranViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }

          return Column(
            children: [
              // --- Header Melengkung (Identik dengan Dashboard) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),

                decoration: BoxDecoration(
                  color: colorScheme.primary,
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
                        const Text(
                          'Al-Qur\'an',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Positioned(
                          right: -20, // Agak lebih keluar supaya efek potongnya terasa
                          top: -15,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 60, // Ukuran diperbesar sedikit agar lebih proporsional
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- List Surat ---
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: vm.surats.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final surat = vm.surats[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuratDetailPage(surat: surat),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C5ABF).withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Nomor Surat (Styling Dashboard)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: colorScheme.primary.withOpacity(0.1),
                                  size: 50,
                                ),
                                Text(
                                  surat.nomor.toString(),
                                  style: TextStyle(
                                    color: deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Nama Surat & Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surat.namaLatin,
                                    style: const TextStyle(
                                      color: deepPurple,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${surat.tempatTurun.toUpperCase()} • ${surat.jumlahAyat} AYAT',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Nama Arab
                            Text(
                              surat.nama,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
