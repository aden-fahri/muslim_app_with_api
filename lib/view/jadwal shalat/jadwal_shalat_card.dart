import 'package:flutter/material.dart';

class JadwalShalatCard extends StatelessWidget {
  final String label;
  final String time;
  final bool isNext;
  final VoidCallback? onTap;

  const JadwalShalatCard({
    super.key,
    required this.label,
    required this.time,
    this.isNext = false,
    this.onTap,
  });

  IconData _getIcon(String label) {
    switch (label.toLowerCase()) {
      case 'imsak': return Icons.wb_twilight_rounded;
      case 'subuh': return Icons.wb_sunny_outlined;
      case 'terbit': return Icons.wb_sunny_rounded;
      case 'dzuhur': return Icons.light_mode_rounded;
      case 'ashar': return Icons.cloud_rounded;
      case 'maghrib': return Icons.nights_stay_rounded;
      case 'isya': return Icons.dark_mode_rounded;
      default: return Icons.access_time_filled_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Memberikan efek klik yang halus
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isNext ? Colors.white : Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              // Border tipis agar terlihat premium (Glass Effect)
              border: Border.all(
                color: isNext ? const Color(0xFF7C5ABF) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isNext 
                    ? const Color(0xFF7C5ABF).withOpacity(0.2) 
                    : Colors.black.withOpacity(0.02),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Bulat dengan Neumorphic style
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isNext ? const Color(0xFF7C5ABF) : const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(label),
                    color: isNext ? Colors.white : const Color(0xFF7C5ABF).withOpacity(0.5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Teks Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                          color: const Color(0xFF2D2D2D),
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isNext)
                        Text(
                          "Sedang berlangsung",
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF7C5ABF).withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),

                // Waktu Shalat
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isNext ? const Color(0xFF7C5ABF).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isNext ? const Color(0xFF7C5ABF) : const Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}