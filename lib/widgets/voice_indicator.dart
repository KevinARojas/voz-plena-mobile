import 'package:flutter/material.dart';
import '../utils/colors.dart';

class VoiceIndicator extends StatelessWidget {
  final double volume;
  const VoiceIndicator({super.key, required this.volume});

  @override
  Widget build(BuildContext context) {
    final level = (volume * 10).clamp(0, 10).toInt();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.2 + level / 20),
        border: Border.all(
          color: AppColors.primary,
          width: 4 + (level.toDouble() / 2),
        ),
      ),
      child: const Icon(Icons.mic, size: 80, color: Colors.white),
    );
  }
}
