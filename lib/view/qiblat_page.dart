import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/qiblat_view_model.dart';
import '../painters/compass_painter.dart'; // ← import painter kamu di sini (sesuaikan path)

class QiblatPage extends StatefulWidget {
  const QiblatPage({super.key});

  @override
  State<QiblatPage> createState() => _QiblatPageState();
}

class _QiblatPageState extends State<QiblatPage> {
  @override
  void initState() {
    super.initState();
    // Inisialisasi ViewModel (permission + sensor + stream)
    final provider = Provider.of<QiblatViewModel>(context, listen: false);
    provider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: Consumer<QiblatViewModel>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fitur arah kiblat hanya tersedia di aplikasi mobile (Android/iOS).\n'
                      'Silakan buka app untuk mencobanya.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!provider.sensorAvailable) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Sensor kompas tidak tersedia.\nGunakan perangkat fisik dan izinkan lokasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          if (provider.currentDirection == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final direction = provider.currentDirection!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kompas custom (tanpa asset)
              SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(
                  painter: CompassPainter(
                    heading: direction.direction,
                    qiblah: direction.qiblah,
                    size: 320, // bisa disesuaikan
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Info teks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kiblat: ${direction.qiblah.toStringAsFixed(1)}° dari Utara',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Arah HP sekarang: ${direction.direction.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selisih: ${direction.normalizedOffset.toStringAsFixed(1)}° (putar HP hingga mendekati 0°)',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
