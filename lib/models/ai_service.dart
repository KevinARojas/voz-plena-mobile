import 'dart:typed_data';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Servicio general de IA para análisis de voz en Voz Plena
/// Carga el modelo `voice_analyzer.tflite` y ejecuta inferencias
class AIService {
  Interpreter? _interpreter;
  bool _mockMode = false;

  /// Inicializa el modelo IA
  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('model/voice_analyzer.tflite');
      print('✅ Modelo IA cargado correctamente.');
    } catch (e) {
      // Si no hay modelo, activamos modo simulado
      _mockMode = true;
      print('⚠️ No se encontró modelo IA. Usando modo simulado.');
    }
  }

  bool get isReady => _interpreter != null || _mockMode;

  /// Ejecuta inferencia sobre muestras de audio (0–1 normalizadas)
  Future<Map<String, double>> analyze(List<double> inputData) async {
    if (_mockMode) return _simulateAI(inputData);

    if (_interpreter == null) {
      throw Exception('Modelo IA no inicializado.');
    }

    final input = Float32List.fromList(
      inputData,
    ).reshape([1, inputData.length]);
    final output = List.filled(3, 0.0).reshape([1, 3]);

    _interpreter!.run(input, output);

    return {
      'volume': output[0][0].clamp(0.0, 1.0),
      'tone': output[0][1].clamp(0.0, 1.0),
      'breathing': output[0][2].clamp(0.0, 1.0),
    };
  }

  /// Modo simulado: genera valores IA “realistas” basados en promedio
  Map<String, double> _simulateAI(List<double> data) {
    final avg = data.isNotEmpty
        ? data.reduce((a, b) => a + b) / data.length
        : 0.5;
    final random = Random();

    return {
      'volume': (avg + random.nextDouble() * 0.2).clamp(0.0, 1.0),
      'tone': (avg + random.nextDouble() * 0.3).clamp(0.0, 1.0),
      'breathing': (1 - avg + random.nextDouble() * 0.1).clamp(0.0, 1.0),
    };
  }

  void dispose() => _interpreter?.close();
}
