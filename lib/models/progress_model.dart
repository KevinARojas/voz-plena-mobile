// lib/models/progress_model.dart
import 'dart:convert';

class ProgressModel {
  double volumeScore;
  double toneScore;
  double breathingScore;
  DateTime lastUpdated;

  ProgressModel({
    required this.volumeScore,
    required this.toneScore,
    required this.breathingScore,
    required this.lastUpdated,
  });

  /// Promedio general del usuario
  double get averageScore => (volumeScore + toneScore + breathingScore) / 3;

  /// Convierte el objeto a JSON para guardarlo en memoria
  Map<String, dynamic> toJson() => {
    'volumeScore': volumeScore,
    'toneScore': toneScore,
    'breathingScore': breathingScore,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  /// Convierte desde JSON a un objeto ProgressModel
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      volumeScore: (json['volumeScore'] ?? 0).toDouble(),
      toneScore: (json['toneScore'] ?? 0).toDouble(),
      breathingScore: (json['breathingScore'] ?? 0).toDouble(),
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  /// Permite clonar el modelo actual con cambios puntuales
  ProgressModel copyWith({
    double? volumeScore,
    double? toneScore,
    double? breathingScore,
    DateTime? lastUpdated,
  }) {
    return ProgressModel(
      volumeScore: volumeScore ?? this.volumeScore,
      toneScore: toneScore ?? this.toneScore,
      breathingScore: breathingScore ?? this.breathingScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
