// lib/models/progress_model.dart
import 'dart:convert';

class ProgressModel {
  final double volumeScore;
  final double toneScore;
  final double breathingScore;
  final DateTime lastUpdated;

  ProgressModel({
    required this.volumeScore,
    required this.toneScore,
    required this.breathingScore,
    required this.lastUpdated,
  });

  /// Returns average score across all metrics.
  double get averageScore => (volumeScore + toneScore + breathingScore) / 3;

  /// Converts model to JSON map for Firestore or local storage.
  Map<String, dynamic> toJson() => {
    'volumeScore': volumeScore,
    'toneScore': toneScore,
    'breathingScore': breathingScore,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  /// Creates model from Firestore (or local) JSON.
  factory ProgressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ProgressModel(
        volumeScore: 0,
        toneScore: 0,
        breathingScore: 0,
        lastUpdated: DateTime.now(),
      );
    }

    return ProgressModel(
      volumeScore: (json['volumeScore'] ?? 0).toDouble(),
      toneScore: (json['toneScore'] ?? 0).toDouble(),
      breathingScore: (json['breathingScore'] ?? 0).toDouble(),
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  /// Creates a modified copy of the current model instance.
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
