import 'package:flutter/material.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'chat_page.dart';
import 'qiblat_page.dart';
import 'asmaul_husna_page.dart';
import 'dashboard_page.dart';

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    DashboardPage(),
    QuranPage(),
    DoaPage(),
    ChatPage(),
    AsmaulHusnaPage(),
    QiblatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const deepPurple = Color(0xFF2A0E5A);

    return Scaffold(
      // Menggunakan IndexedStack agar state halaman tidak ter-reset saat pindah tab
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), // Ikon lebih modern
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Al-Qur\'an',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.front_hand_rounded),
              label: 'Doa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_alt_rounded),
              label: 'Asisten AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_alt_rounded),
              label: 'Asmaul_hus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Kiblat',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0, // Elevation kita handle manual pakai Container Shadow
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
