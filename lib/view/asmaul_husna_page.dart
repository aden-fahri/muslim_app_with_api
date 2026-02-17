import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // kalau pakai provider
import '../viewmodel/asmaul_husna_view_model.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // load data saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AsmaulHusnaViewModel>(
        context,
        listen: false,
      ).fetchAsmaulHusna();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asmaul Husna'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari latin / arti...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                Provider.of<AsmaulHusnaViewModel>(
                  context,
                  listen: false,
                ).search(value);
              },
            ),
          ),
        ),
      ),
      body: Consumer<AsmaulHusnaViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Terjadi kesalahan: ${vm.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.fetchAsmaulHusna,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (vm.items.isEmpty) {
            return const Center(child: Text('Tidak ada data'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: vm.items.length,
            itemBuilder: (context, index) {
              final item = vm.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: Text(
                      '${item.urutan}',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    item.latin,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.arti),
                  trailing: Text(
                    item.arab,
                    style: const TextStyle(
                      fontFamily: 'Arabic', // pastikan ada font arab di pubspec
                      fontSize: 24,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  onTap: () {
                    // bisa buka dialog detail / audio / penjelasan lebih lanjut
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(item.latin),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arab: ${item.arab}',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 12),
                            Text('Arti: ${item.arti}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
