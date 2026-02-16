import 'package:flutter/material.dart';
import 'package:muslim_app/model/quran/surat.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quran_view_model.dart';

class SuratDetailPage extends StatefulWidget {
  final Surat surat;
  const SuratDetailPage({super.key, required this.surat});

  @override
  State<SuratDetailPage> createState() => _SuratDetailPageState();
}

class _SuratDetailPageState extends State<SuratDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<QuranViewModel>().fetchDetailSurat(widget.surat.nomor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.surat.namaLatin)),
      body: Consumer<QuranViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (vm.suratDetail == null)
            return const Center(child: Text('Data tidak ditemukan'));

          final detail = vm.suratDetail!;

          return CustomScrollView(
            slivers: [
              // --- Header Info Surat ---
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              detail.namaLatin,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              detail.arti,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const Divider(color: Colors.white24, height: 32),
                            Text(
                              '${detail.tempatTurun.toUpperCase()} • ${detail.jumlahAyat} AYAT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (widget.surat.nomor != 1 &&
                                widget.surat.nomor != 9)
                              const Text(
                                "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Uthmani',
                                ),
                              ),
                          ],
                        ),
                      ),
                      // --- Fitur Penjelasan/Deskripsi Surat (Expansion) ---
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: const Text(
                            'Penjelasan Surat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white70,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Text(
                                // Membersihkan tag HTML jika ada di deskripsi
                                detail.deskripsi.replaceAll(
                                  RegExp(r'<[^>]*>|&[^;]+;'),
                                  '',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- List Ayat ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ayat = detail.ayat[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nomor Ayat & Action Bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant.withOpacity(
                                0.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: colorScheme.primary,
                                  child: Text(
                                    ayat.nomorAyat.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 1. Teks Arab
                          Text(
                            ayat.teksArab,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 2,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A0E5A),
                              fontFamily: 'Uthmani',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 2. Teks Latin (KEMBALI ADA)
                          Text(
                            ayat.teksLatin,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 3. Teks Terjemahan/Arti
                          Text(
                            ayat.teksIndonesia,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF2A0E5A),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black12),
                        ],
                      ),
                    );
                  }, childCount: detail.ayat.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
