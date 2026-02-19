import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muslim_app/view/home_navigation_page.dart';
import 'package:provider/provider.dart';

// Subabase (database)
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
// login
import 'view/auth/login_page.dart';

//theme
import 'core/theme.dart';

// Shalat (yang sudah ada)
import 'repository/shalat_repository.dart';
import 'viewmodel/shalat_view_model.dart';

// Quran baru
import 'repository/quran_repository.dart';
import 'viewmodel/quran_view_model.dart';

// Doa baru
import 'repository/doa_repository.dart';
import 'viewmodel/doa_view_model.dart';

// Chat baru
import 'repository/chat_repository.dart';
import 'viewmodel/chat_view_model.dart';

// Qiblat baru
import 'repository/qiblat_repository.dart';
import 'services/qiblat_service.dart';
import 'viewmodel/qiblat_view_model.dart';

// Asmaul Husna
import 'repository/asmaul_husna_repository.dart';
import 'viewmodel/asmaul_husna_view_model.dart';

// Ramadhan
import 'repository/ramadhan_repository.dart';
import 'viewmodel/ramadhan_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'YOUR_URL', // URL project
    anonKey:
        'YOUR_ANON_KEY', // anon public key
  );

  // Listener auth state change
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    final session = data.session;

    print('Auth event: $event'); // debug di console

    if (event == AuthChangeEvent.signedIn) {}
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Cek session awal untuk redirect kalau sudah login
    final session = Supabase.instance.client.auth.currentSession;

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

        // Chat
        Provider<ChatRepository>(create: (_) => ChatRepository()),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(context.read<ChatRepository>()),
        ),

        // Qiblat
        Provider<QiblatRepository>(
          create: (_) => QiblatRepository(QiblatService()),
        ),
        ChangeNotifierProvider<QiblatViewModel>(
          create: (context) =>
              QiblatViewModel(context.read<QiblatRepository>()),
        ),

        // Asmaul Husna
        Provider<AsmaulHusnaRepository>(create: (_) => AsmaulHusnaRepository()),
        ChangeNotifierProvider<AsmaulHusnaViewModel>(
          create: (context) =>
              AsmaulHusnaViewModel(context.read<AsmaulHusnaRepository>()),
        ),

        // Catatan Ramadhan
        Provider<RamadhanRepository>(create: (_) => RamadhanRepository()),
        ChangeNotifierProvider<RamadhanViewModel>(
          create: (context) => RamadhanViewModel(context.read<RamadhanRepository>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Muslim App - MVVM',
        theme: unguLightTheme,
        themeMode: ThemeMode.system,
        home: session == null
            ? const LoginPage() // Redirect ke login kalau belum login
            : const HomeNavigationPage(),
      ),
    );
  }
}
