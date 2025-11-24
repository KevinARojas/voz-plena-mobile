import 'package:flutter/material.dart';
import '../utils/colors.dart';

class NLPAnalysisScreen extends StatefulWidget {
  const NLPAnalysisScreen({super.key});

  @override
  State<NLPAnalysisScreen> createState() => _NLPAnalysisScreenState();
}

class _NLPAnalysisScreenState extends State<NLPAnalysisScreen> {
  bool _analyzing = false;
  String _transcription = "";
  String _emotion = "";
  double _clarityScore = 0.0;

  Future<void> _analyzeAudio() async {
    setState(() => _analyzing = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _transcription = "Hola, esto es una prueba de voz clara y pausada.";
      _emotion = "Alegre 😊";
      _clarityScore = 0.92;
      _analyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Análisis de voz (PLN)")),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_graph, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            _analyzing
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _analyzeAudio,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.mic, color: Colors.white),
                    label: const Text(
                      "Analizar muestra de voz",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 40),
            if (_transcription.isNotEmpty) ...[
              Text(
                "Transcripción:",
                style: TextStyle(fontSize: 20, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _transcription,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Emoción detectada: $_emotion",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _clarityScore,
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              const SizedBox(height: 8),
              Text("Claridad: ${(100 * _clarityScore).toStringAsFixed(0)}%"),
            ],
          ],
        ),
      ),
    );
  }
}
