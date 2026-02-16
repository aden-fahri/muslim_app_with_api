import 'package:flutter/material.dart';
import 'shalat_page.dart';
import 'quran_page.dart';
import 'doa_page.dart';
import 'chat_page.dart';
import 'qiblat_page.dart';

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    ShalatPage(),
    QuranPage(),
    DoaPage(),
    ChatPage(),
    QiblatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Jadwal Shalat',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Al-Qur\'an'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Doa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Asisten AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Kiblat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
