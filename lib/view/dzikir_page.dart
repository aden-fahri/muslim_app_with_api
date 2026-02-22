import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../model/dzikir_model.dart';
import '../viewmodel/dzikir_view_model.dart';

class DzikirPage extends StatefulWidget {
  const DzikirPage({super.key});

  @override
  State<DzikirPage> createState() => _DzikirPageState();
}

class _DzikirPageState extends State<DzikirPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DzikirViewModel>().initialize());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Palet warna konsisten (bisa diambil dari Theme kalau mau lebih dinamis)
    const primaryPurple = Color(0xFF7C5ABF);
    const deepPurple = Color(0xFF2A0E5A);
    const goldHighlight = Color(0xFFB8975A);
    const lightBg = Color(0xFFFDFBFF);
    const darkBg = Color(0xFFF0E5FF);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'TASBIH DIGITAL',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
            color: deepPurple,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<DzikirViewModel>(
        builder: (context, vm, child) {
          if (vm.error != null) {
            return _buildErrorState(vm.error!, colorScheme);
          }

          if (vm.currentDzikir == null) {
            return const Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          final dzikir = vm.currentDzikir!;
          final isDone = dzikir.isCompleted;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [lightBg, darkBg],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 1. Horizontal Selector (Chip)
                  _buildDzikirSelector(vm, primaryPurple, deepPurple),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // 2. Arabic Text Section
                          _buildArabicSection(dzikir, primaryPurple),

                          const SizedBox(height: 60),

                          // 3. Main Counter Button
                          _buildCounterCircle(vm, dzikir, isDone, primaryPurple, goldHighlight),

                          const SizedBox(height: 60),

                          // 4. Progress & Controls
                          _buildBottomControls(vm, dzikir, isDone, primaryPurple, goldHighlight),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDzikirSelector(DzikirViewModel vm, Color primary, Color deep) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: vm.availableDzikirs.length,
        itemBuilder: (context, index) {
          final d = vm.availableDzikirs[index];
          final isSelected = index == vm.selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                d.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => vm.changeType(index),
              selectedColor: primary,
              backgroundColor: Colors.white.withOpacity(0.9),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : deep.withOpacity(0.7),
              ),
              elevation: isSelected ? 6 : 2,
              pressElevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              side: BorderSide(
                color: isSelected ? primary : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArabicSection(DzikirModel dzikir, Color primary) {
    return Column(
      children: [
        Text(
          dzikir.arabic,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: primary,
            height: 1.4,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            dzikir.translation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black87.withOpacity(0.75),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterCircle(
    DzikirViewModel vm,
    DzikirModel dzikir,
    bool isDone,
    Color primary,
    Color gold,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        vm.increment();

        // Optional: haptic lebih kuat saat selesai target
        if (dzikir.currentCount + 1 >= dzikir.targetCount) {
          HapticFeedback.mediumImpact();
          // Jika ingin confetti: uncomment package confetti dan panggil ConfettiController
          // confettiController.play();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDone ? gold : primary).withOpacity(isDone ? 0.35 : 0.25),
                  blurRadius: isDone ? 60 : 40,
                  spreadRadius: isDone ? 20 : 10,
                ),
              ],
            ),
          ),

          // Progress ring
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: dzikir.progress.clamp(0.0, 1.0),
              strokeWidth: 12,
              backgroundColor: primary.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(isDone ? gold : primary),
              strokeCap: StrokeCap.round,
            ),
          ),

          // Inner counter
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 92,
                    fontWeight: FontWeight.w900,
                    color: isDone ? gold : Colors.black87,
                    height: 1.0,
                  ),
                  child: Text('${dzikir.currentCount}'),
                ),
                const SizedBox(height: 4),
                Text(
                  'dari ${dzikir.targetCount}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    DzikirViewModel vm,
    DzikirModel dzikir,
    bool isDone,
    Color primary,
    Color gold,
  ) {
    return Column(
      children: [
        if (isDone)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: gold, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Alhamdulillah, Selesai!",
                  style: TextStyle(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: vm.reset,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('RESET'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 80, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}