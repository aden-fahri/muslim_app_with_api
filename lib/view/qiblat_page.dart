import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/qiblat_view_model.dart';
import '../painters/compass_painter.dart';

class QiblatPage extends StatefulWidget {
  const QiblatPage({super.key});

  @override
  State<QiblatPage> createState() => _QiblatPageState();
}

class _QiblatPageState extends State<QiblatPage> {
  bool _hasVibrated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<QiblatViewModel>().initialize());
  }

  void _triggerHaptic(bool isAligned) {
    if (isAligned && !_hasVibrated) {
      HapticFeedback.mediumImpact();
      _hasVibrated = true;
    } else if (!isAligned) {
      _hasVibrated = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna dari tema ungu agar konsisten
    const primaryPurple = Color(0xFF7C5ABF);
    const deepPurple = Color(0xFF2A0E5A);
    const softPurple = Color(0xFF9F7EE6);
    const goldHighlight = Color(0xFFB8975A);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'KIBLAT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 14,
            color: deepPurple, // Menggunakan warna teks utama tema
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<QiblatViewModel>(
        builder: (context, provider, child) {
          if (provider.error != null || !provider.sensorAvailable) {
            return _buildErrorState(provider.error, primaryPurple);
          }

          if (provider.currentDirection == null) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
            );
          }

          final direction = provider.currentDirection!;
          final isAligned = direction.normalizedOffset.abs() < 2.0;
          _triggerHaptic(isAligned);

          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 1.2,
                colors: [
                  Color(0xFFFDFBFF), // Putih ungu sangat terang
                  Color(0xFFF0E5FF), // Lavender soft (SecondaryContainer)
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // 1. Status Badge
                  _buildStatusBadge(isAligned, primaryPurple, goldHighlight),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Info Tiles (Heading & Qibla)
                  _buildQuickStats(direction, deepPurple, softPurple),

                  // 3. Compass Center
                  Expanded(
                    child: Center(
                      child: _buildCompassVisual(isAligned, direction, primaryPurple, goldHighlight),
                    ),
                  ),

                  // 4. Bottom Angle Display
                  _buildAngleDisplay(isAligned, direction, deepPurple, goldHighlight),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isAligned, Color primary, Color gold) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAligned ? gold.withOpacity(0.1) : primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isAligned ? gold.withOpacity(0.5) : primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAligned ? Icons.check_circle_rounded : Icons.explore_outlined,
            size: 14,
            color: isAligned ? gold : primary.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            isAligned ? 'KIBLAT TERKUNCI' : 'MENCARI ARAH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isAligned ? gold : primary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(direction, Color textColor, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statItem('HEADING', '${direction.direction.toStringAsFixed(0)}°', textColor, subColor),
        Container(height: 25, width: 1.5, color: textColor.withOpacity(0.1)),
        _statItem('KIBLAT', '${direction.qiblah.toStringAsFixed(0)}°', textColor, subColor),
      ],
    );
  }

  Widget _statItem(String label, String value, Color mainColor, Color subColor) {
    return Column(
      children: [
        Text(value, 
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w300, 
            color: mainColor,
          )
        ),
        Text(label, 
          style: TextStyle(
            fontSize: 9, 
            color: subColor.withOpacity(0.8), 
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          )
        ),
      ],
    );
  }

  Widget _buildCompassVisual(bool isAligned, direction, Color primary, Color gold) {
    double size = 280;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsating Glow (Hanya saat selaras)
        if (isAligned) AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Compass Painter
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: CompassPainter(
              heading: direction.direction,
              qiblah: direction.qiblah,
              size: size,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAngleDisplay(bool isAligned, direction, Color deepPurple, Color gold) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: isAligned ? 0 : 1,
              child: Icon(
                direction.normalizedOffset > 0 ? Icons.arrow_right_rounded : Icons.arrow_left_rounded,
                color: deepPurple.withOpacity(0.2), size: 40,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 62, 
                fontWeight: FontWeight.w900,
                color: isAligned ? gold : deepPurple,
                letterSpacing: -2,
              ),
              child: Text('${direction.normalizedOffset.abs().toStringAsFixed(0)}°'),
            ),
            const SizedBox(width: 40, height: 10), 
          ],
        ),
        Text(
          isAligned ? 'POSISI SEMPURNA' : 'SELISIH DERAJAT',
          style: TextStyle(
            color: isAligned ? gold : deepPurple.withOpacity(0.3),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String? error, Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off_outlined, size: 64, color: primary.withOpacity(0.2)),
            const SizedBox(height: 20),
            Text(
              error ?? 'Sensor Magnetometer Tidak Terdeteksi', 
              textAlign: TextAlign.center,
              style: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}