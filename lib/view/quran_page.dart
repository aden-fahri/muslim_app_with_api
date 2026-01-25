import 'package:flutter/material.dart';
import 'package:muslim_app/view/surat_detail_page.dart';
import 'package:provider/provider.dart';
import '../viewmodel/quran_view_model.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<QuranViewModel>().fetchSuratList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Al-Qur\'an - Daftar Surat')),
      body: Consumer<QuranViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.surats.isEmpty) {
            return const Center(child: Text('Tidak ada data surat'));
          }

          return ListView.builder(
            itemCount: vm.surats.length,
            itemBuilder: (context, index) {
              final surat = vm.surats[index];
              return ListTile(
                leading: CircleAvatar(child: Text(surat.nomor.toString())),
                title: Text(surat.namaLatin),
                subtitle: Text('${surat.nama} • ${surat.arti}'),
                trailing: Text('${surat.jumlahAyat} ayat'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuratDetailPage(surat: surat),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Kamu pilih: ${surat.namaLatin}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
