// lib/services/progress_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_model.dart';

class ProgressService {
  static const _key = 'user_progress';

  /// Guarda el progreso completo del usuario
  Future<void> saveProgress(ProgressModel progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(progress.toJson()));
  }

  /// Carga el progreso guardado (o genera uno vacío)
  Future<ProgressModel> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return ProgressModel(
        volumeScore: 0,
        toneScore: 0,
        breathingScore: 0,
        lastUpdated: DateTime.now(),
      );
    }
    return ProgressModel.fromJson(jsonDecode(jsonString));
  }

  /// Actualiza una métrica (volumen, tono, respiración) y promedia con el valor anterior
  Future<void> updateMetric(String type, double newScore) async {
    final progress = await loadProgress();
    ProgressModel updated;

    double _combine(double oldValue, double newValue) {
      // 🧠 Combina el valor anterior y el nuevo de forma suave (ponderado)
      return (oldValue * 0.7) + (newValue * 0.3);
    }

    switch (type) {
      case 'volume':
        updated = progress.copyWith(
          volumeScore: _combine(progress.volumeScore, newScore),
          lastUpdated: DateTime.now(),
        );
        break;
      case 'tone':
        updated = progress.copyWith(
          toneScore: _combine(progress.toneScore, newScore),
          lastUpdated: DateTime.now(),
        );
        break;
      case 'breathing':
        updated = progress.copyWith(
          breathingScore: _combine(progress.breathingScore, newScore),
          lastUpdated: DateTime.now(),
        );
        break;
      default:
        updated = progress;
    }

    await saveProgress(updated);
  }

  /// Permite actualizar múltiples métricas a la vez (desde la IA)
  Future<void> updateFromAI(Map<String, double> scores) async {
    final progress = await loadProgress();
    double _combine(double oldValue, double newValue) =>
        (oldValue * 0.7) + (newValue * 0.3);

    final updated = progress.copyWith(
      volumeScore: _combine(
        progress.volumeScore,
        scores['volume'] ?? progress.volumeScore,
      ),
      toneScore: _combine(
        progress.toneScore,
        scores['tone'] ?? progress.toneScore,
      ),
      breathingScore: _combine(
        progress.breathingScore,
        scores['breathing'] ?? progress.breathingScore,
      ),
      lastUpdated: DateTime.now(),
    );

    await saveProgress(updated);
  }

  /// Obtiene un resumen general del progreso (promedios)
  Future<Map<String, double>> getMetrics() async {
    final p = await loadProgress();
    final avg = (p.volumeScore + p.toneScore + p.breathingScore) / 3;
    return {
      'volume': p.volumeScore,
      'tone': p.toneScore,
      'breathing': p.breathingScore,
      'average': avg,
    };
  }

  /// Reinicia el progreso
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
