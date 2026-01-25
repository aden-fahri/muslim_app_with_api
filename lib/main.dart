import 'package:flutter/material.dart';
import 'package:muslim_app/view/home_navigation_page.dart';
import 'package:provider/provider.dart';

// Shalat (yang sudah ada)
import 'repository/shalat_repository.dart';
import 'viewmodel/shalat_view_model.dart';

// Quran baru
import 'repository/quran_repository.dart';
import 'viewmodel/quran_view_model.dart';

// Doa baru
import 'repository/doa_repository.dart';
import 'viewmodel/doa_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // jadwal sholat
        Provider<ShalatRepository>(create: (_) => ShalatRepository()),
        ChangeNotifierProvider<ShalatViewModel>(
          create: (context) =>
              ShalatViewModel(context.read<ShalatRepository>()),
        ),

        // Quran
        Provider<QuranRepository>(create: (_) => QuranRepository()),
        ChangeNotifierProvider<QuranViewModel>(
          create: (context) => QuranViewModel(context.read<QuranRepository>()),
        ),

        // Doa
        Provider<DoaRepository>(create: (_) => DoaRepository()),
        ChangeNotifierProvider<DoaViewModel>(
          create: (context) => DoaViewModel(context.read<DoaRepository>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Muslim App - MVVM',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color.fromARGB(255, 37, 0, 78)
         
        ),
        home: const HomeNavigationPage(), 
      ),
    );
  }
}
