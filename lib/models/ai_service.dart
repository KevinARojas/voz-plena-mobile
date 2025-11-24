import 'dart:typed_data';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';

class AIService {
  Interpreter? _interpreter;
  bool _mockMode = false;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('model/voice_analyzer.tflite');
      print('IA Model loaded successfully.');
    } catch (e) {
      _mockMode = true;
      print('IA Model not found. Using simulated mode.');
    }
  }

  bool get isReady => _interpreter != null || _mockMode;

  Future<Map<String, double>> analyze(List<double> inputData) async {
    if (_mockMode) return _simulateAI(inputData);

    if (_interpreter == null) {
      throw Exception('IA Model not initialized.');
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
