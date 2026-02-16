import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/qiblat_view_model.dart';
import '../painters/compass_painter.dart';

class QiblatPage extends StatefulWidget {
  const QiblatPage({super.key});

  @override
  State<QiblatPage> createState() => _QiblatPageState();
}

class _QiblatPageState extends State<QiblatPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<QiblatViewModel>().initialize());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Kiblat Finder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<QiblatViewModel>(
        builder: (context, provider, child) {
          // 1. KONDISI ERROR (TERMASUK BROWSER/NO SENSOR)
          if (provider.error != null || !provider.sensorAvailable) {
            return _buildBrowserWarning(colorScheme, provider.error);
          }

          // 2. KONDISI LOADING
          if (provider.currentDirection == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final direction = provider.currentDirection!;
          final bool isAligned = direction.normalizedOffset.abs() < 3.0;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface,
                  colorScheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Indikator Status Mewah
                _buildStatusHeader(isAligned, colorScheme),

                const SizedBox(height: 40),

                // Kompas Custom Paint dengan Shadow Glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow Effect saat arah benar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isAligned
                                ? Colors.green.withOpacity(0.4)
                                : colorScheme.primary.withOpacity(0.1),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    CustomPaint(
                      size: const Size(300, 300),
                      painter: CompassPainter(
                        heading: direction.direction,
                        qiblah: direction.qiblah,
                        primaryColor: colorScheme.primary,
                        size: 300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Info Cards
                _buildModernInfoCards(direction, colorScheme),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Peringatan Khusus Browser / Sensor Tidak Ada
  Widget _buildBrowserWarning(ColorScheme colorScheme, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.language, size: 80, color: Colors.orange),
            ),
            const SizedBox(height: 24),
            Text(
              'Mode Preview Browser',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error ??
                  'Sensor kompas (Magnetometer) tidak terdeteksi di browser.\n\nSilakan jalankan aplikasi di perangkat Android/iOS asli untuk menggunakan fitur ini secara real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isAligned, ColorScheme colorScheme) {
    return Column(
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: isAligned ? Colors.green : colorScheme.primary,
          ),
          child: Text(isAligned ? 'KIBLAT TEPAT' : 'CARI ARAH'),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isAligned
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isAligned
                ? 'Sempurna untuk Shalat'
                : 'Putar perlahan perangkat Anda',
            style: TextStyle(
              fontSize: 12,
              color: isAligned ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCards(direction, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoTile(
          'Sudut Kiblat',
          '${direction.qiblah.toStringAsFixed(0)}°',
          Icons.explore,
        ),
        const SizedBox(width: 20),
        _infoTile(
          'Selisih',
          '${direction.normalizedOffset.toStringAsFixed(0)}°',
          Icons.sync_alt,
          isHighlight: direction.normalizedOffset.abs() < 5,
        ),
      ],
    );
  }

  Widget _infoTile(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: isHighlight ? Colors.green : Colors.grey),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
