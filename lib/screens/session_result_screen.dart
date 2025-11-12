import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SessionResultScreen extends StatelessWidget {
  final String type; // Ej: "Volumen", "Tono", "Respiración"
  final double score; // 0.0 - 1.0
  final String feedback;

  const SessionResultScreen({
    super.key,
    required this.type,
    required this.score,
    required this.feedback,
  });

  Color getColor() {
    if (score > 0.75) return AppColors.green;
    if (score > 0.5) return AppColors.primary;
    return AppColors.red;
  }

  String getEmoji() {
    if (score > 0.75) return "🌟";
    if (score > 0.5) return "🙂";
    return "💪";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Resultado del ejercicio",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Text(getEmoji(), style: const TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              Text(
                "${(score * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: getColor(),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  feedback,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (r) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  "Volver al inicio",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
