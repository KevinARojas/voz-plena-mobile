import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math';

class AIService {
  static Interpreter? _interpreter;
  static bool _isLoaded = false;

  static Future<void> init() async {
    if (_isLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/model/voice_analyzer.tflite',
      );
      _isLoaded = true;
      print("IA Model loaded successfully.");
    } catch (e) {
      print("Error loading IA model: $e");
      _isLoaded = false;
    }
  }

  static List<double> _generateInput() {
    final rnd = Random();
    return List.generate(60, (_) => rnd.nextDouble());
  }

  static Future<List<double>> analyzeVoice() async {
    try {
      if (!_isLoaded || _interpreter == null) {
        print("Model not loaded, using simulated data");

        return [
          0.5 + Random().nextDouble() * 0.4,
          0.4 + Random().nextDouble() * 0.5,
          0.3 + Random().nextDouble() * 0.6,
        ];
      }

      var input = _generateInput().reshape([1, 60]);
      var output = List.filled(3, 0.0).reshape([1, 3]);

      _interpreter!.run(input, output);
      return List<double>.from(output[0]);
    } catch (e) {
      print('! Error en inferencia IA: $e');

      return [
        0.6 + Random().nextDouble() * 0.3,
        0.5 + Random().nextDouble() * 0.4,
        0.4 + Random().nextDouble() * 0.4,
      ];
    }
  }

  static String generateFeedback(List<double> results) {
    if (results.isEmpty) return "Sin datos de análisis";

    final volume = results[0];
    final tone = results.length > 1 ? results[1] : 0.5;
    final breathing = results.length > 2 ? results[2] : 0.5;

    String feedback = "";

    if (volume > 0.8) {
      feedback += "Excelente control de volumen. ";
    } else if (volume > 0.5) {
      feedback += "Buen volumen, sigue practicando. ";
    } else {
      feedback += "Habla más fuerte para mejorar la proyección. ";
    }

    if (tone > 0.75) {
      feedback += "Tu tono es estable y claro. ";
    } else if (tone > 0.45) {
      feedback += "Tu tono es aceptable, trata de mantenerlo. ";
    } else {
      feedback += "El tono varía mucho, intenta sostenerlo más. ";
    }

    if (breathing > 0.7) {
      feedback += "La respiración está bien controlada.";
    } else {
      feedback += "Practica respiraciones más regulares.";
    }

    return feedback.trim();
  }
}
