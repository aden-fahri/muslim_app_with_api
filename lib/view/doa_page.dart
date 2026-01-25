import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/doa_view_model.dart';

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DoaViewModel>().fetchDoaList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kumpulan Doa')),
      body: Consumer<DoaViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.doas.isEmpty) {
            return const Center(child: Text('Tidak ada data doa'));
          }

          return ListView.builder(
            itemCount: vm.doas.length,
            itemBuilder: (context, index) {
              final doa = vm.doas[index];
              return ExpansionTile(
                leading: CircleAvatar(child: Text(doa.id)),
                title: Text(doa.doa),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arab:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          doa.ayat,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 12),
                        Text('Latin: ${doa.latin}'),
                        const SizedBox(height: 8),
                        Text('Artinya: ${doa.artinya}'),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
