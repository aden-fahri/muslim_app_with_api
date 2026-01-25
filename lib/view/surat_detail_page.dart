import 'package:flutter/material.dart';
import 'package:muslim_app/model/quran/surat.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quran_view_model.dart';
// import 'package:audioplayers/audioplayers.dart'; // uncomment kalau pakai audio

class SuratDetailPage extends StatefulWidget {
  final Surat surat;

  const SuratDetailPage({super.key, required this.surat});

  @override
  State<SuratDetailPage> createState() => _SuratDetailPageState();
}

class _SuratDetailPageState extends State<SuratDetailPage> {
  // AudioPlayer? _audioPlayer; // kalau pakai audio

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<QuranViewModel>().fetchDetailSurat(widget.surat.nomor);
    });
    // _audioPlayer = AudioPlayer(); // init kalau pakai
  }

  // @override
  // void dispose() {
  //   _audioPlayer?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.surat.namaLatin} (${widget.surat.nama})'),
      ),
      body: Consumer<QuranViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.suratDetail == null) {
            return const Center(child: Text('Tidak ada data detail'));
          }

          final detail = vm.suratDetail!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Surah
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arti: ${detail.arti}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('Jumlah Ayat: ${detail.jumlahAyat}'),
                        Text('Tempat Turun: ${detail.tempatTurun}'),
                        const SizedBox(height: 8),
                        Text(
                          detail.deskripsi,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // List Ayat
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detail.ayat.length,
                  itemBuilder: (context, index) {
                    final ayat = detail.ayat[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              ayat.teksArab,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 24,
                                fontFamily: 'Uthmani',
                              ), // tambah font Arab di pubspec
                            ),
                            const SizedBox(height: 8),
                            Text('Latin: ${ayat.teksLatin}'),
                            Text('Arti: ${ayat.teksIndonesia}'),
                            // Tombol Audio (opsional)
                            // IconButton(
                            //   icon: const Icon(Icons.play_arrow),
                            //   onPressed: () async {
                            //     await _audioPlayer?.play(UrlSource(ayat.audio));
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
