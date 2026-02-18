import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    const primaryPurple = Color(0xFF7C5ABF);
    const deepPurple = Color(0xFF2A0E5A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FD),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, Color(0xFF9F7EE6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Asmaul Husna',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => Provider.of<AsmaulHusnaViewModel>(
                      context,
                      listen: false,
                    ).search(value),
                    decoration: const InputDecoration(
                      hintText: 'Cari Nama / Arti...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: primaryPurple),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Konten List
          Expanded(
            child: Consumer<AsmaulHusnaViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryPurple),
                  );
                }

                if (vm.error != null) {
                  return Center(child: Text('Terjadi kesalahan: ${vm.error}'));
                }

                if (vm.items.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }

                // Menggunakan GridView agar lebih hemat tempat dan cantik
                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: vm.items.length,
                  itemBuilder: (context, index) {
                    final item = vm.items[index];
                    return _buildAsmaulCard(item, primaryPurple, deepPurple);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsmaulCard(dynamic item, Color primary, Color deep) {
    return GestureDetector(
      onTap: () => _showDetail(item, primary),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nomor Urut kecil di pojok
            Text(
              '${item.urutan}',
              style: TextStyle(
                color: primary.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Tulisan Arab
            Text(
              item.arab,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A0E5A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            // Nama Latin
            Text(
              item.latin,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            // Arti singkat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.arti,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(dynamic item, Color themeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.arab,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A0E5A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.latin,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Artinya:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              item.arti,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
