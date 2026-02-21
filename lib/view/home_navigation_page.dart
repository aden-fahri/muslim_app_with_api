import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_view_model.dart';
import '../viewmodel/ramadhan_view_model.dart';
import 'dashboard_page.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'chat_page.dart';
import 'asmaul_husna_page.dart';
import 'qiblat_page.dart';
import 'shalat_page.dart';

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    const QuranPage(),
    const DoaPage(),
    ChatPage(),
    const AsmaulHusnaPage(),
    const QiblatPage(),
    const ShalatPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refresh profil setiap kali HomeNavigationPage muncul / dependencies berubah
    // Ini akan menangkap kasus setelah login ulang
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    profileVM.refreshProfile();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Optional: refresh lagi saat pindah ke tab Beranda (index 0)
    if (index == 0) {
      Provider.of<ProfileViewModel>(context, listen: false).refreshProfile();
      Provider.of<RamadhanViewModel>(context, listen: false).refreshTodayEntry();
      Provider.of<RamadhanViewModel>(context, listen: false).refreshAllStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
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
              icon: Icon(Icons.mosque_rounded),
              label: 'Asmaul Husna',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Kiblat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled_rounded),
              label: 'Jadwal Shalat',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 10, // Ukuran font diperkecil karena item cukup banyak
          unselectedFontSize: 10,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Tetap gunakan fixed agar label selalu muncul
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}