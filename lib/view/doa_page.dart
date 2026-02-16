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
    Future.microtask(() => context.read<DoaViewModel>().fetchDoaList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const deepPurple = Color(0xFF2A0E5A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<DoaViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.error != null) return Center(child: Text('Error: ${vm.error}'));

          return CustomScrollView(
            slivers: [
              // --- Header Pendek dengan Border Radius (Seperti Request) ---
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Margin atas untuk status bar
                  height: 150, // Lebih pendek
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28), // Border radius mewah
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        top: -10,
                        child: Icon(Icons.auto_awesome, 
                            size: 100, color: Colors.white.withOpacity(0.1)),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Kumpulan Doa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${vm.doas.length} DOA PILIHAN',
                              style: const TextStyle(
                                color: Colors.white70,
                                letterSpacing: 2,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- List Doa dengan Fitur Sembunyi (ExpansionTile) ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doa = vm.doas[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colorScheme.surfaceVariant),
                        ),
                        child: Theme(
                          data: theme.copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              doa.doa,
                              style: const TextStyle(
                                color: deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            iconColor: colorScheme.primary,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Divider(height: 20),
                                    // Teks Arab
                                    Text(
                                      doa.ayat,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        height: 2,
                                        fontWeight: FontWeight.bold,
                                        color: deepPurple,
                                        fontFamily: 'Uthmani',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Teks Latin
                                    Text(
                                      doa.latin,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Terjemahan
                                    Text(
                                      doa.artinya,
                                      style: const TextStyle(
                                        color: deepPurple,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: vm.doas.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}