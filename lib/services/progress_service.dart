import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_model.dart';

class ProgressService {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  static const _localKey = 'user_progress_cache';

  String? get _uid => _auth.currentUser?.uid;

  Future<ProgressModel> loadProgress() async {
    if (_uid == null) {
      return ProgressModel(
        volumeScore: 0,
        toneScore: 0,
        breathingScore: 0,
        lastUpdated: DateTime.now(),
      );
    }

    try {
      final doc = await _fire.collection('progress').doc(_uid).get();

      if (doc.exists) {
        final model = ProgressModel.fromJson(doc.data());
        await _saveLocalCache(model);
        return model;
      }

      final initial = ProgressModel(
        volumeScore: 0,
        toneScore: 0,
        breathingScore: 0,
        lastUpdated: DateTime.now(),
      );

      await _fire.collection('progress').doc(_uid).set(initial.toJson());
      await _saveLocalCache(initial);
      return initial;
    } catch (e) {
      return await _loadLocalCache();
    }
  }

  Future<void> updateMetric(String type, double newScore) async {
    final current = await loadProgress();

    double blend(double oldValue, double newValue) =>
        (oldValue * 0.7) + (newValue * 0.3);

    ProgressModel updated;

    switch (type) {
      case 'volume':
        updated = current.copyWith(
          volumeScore: blend(current.volumeScore, newScore),
          lastUpdated: DateTime.now(),
        );
        break;

      case 'tone':
        updated = current.copyWith(
          toneScore: blend(current.toneScore, newScore),
          lastUpdated: DateTime.now(),
        );
        break;

      case 'breathing':
        updated = current.copyWith(
          breathingScore: blend(current.breathingScore, newScore),
          lastUpdated: DateTime.now(),
        );
        break;

      default:
        return;
    }

    await _fire
        .collection('progress')
        .doc(_uid)
        .set(updated.toJson(), SetOptions(merge: true));

    await _saveLocalCache(updated);
  }

  Future<void> updateFromAI(Map<String, double> scores) async {
    final current = await loadProgress();

    double blend(double oldValue, double newValue) =>
        (oldValue * 0.7) + (newValue * 0.3);

    final updated = current.copyWith(
      volumeScore: blend(
        current.volumeScore,
        scores['volume'] ?? current.volumeScore,
      ),
      toneScore: blend(current.toneScore, scores['tone'] ?? current.toneScore),
      breathingScore: blend(
        current.breathingScore,
        scores['breathing'] ?? current.breathingScore,
      ),
      lastUpdated: DateTime.now(),
    );

    await _fire
        .collection('progress')
        .doc(_uid)
        .set(updated.toJson(), SetOptions(merge: true));

    await _saveLocalCache(updated);
  }

  Future<Map<String, double>> getMetrics() async {
    final p = await loadProgress();
    return {
      'volume': p.volumeScore,
      'tone': p.toneScore,
      'breathing': p.breathingScore,
      'average': p.averageScore,
    };
  }

  Future<void> resetProgress() async {
    if (_uid != null) {
      await _fire.collection('progress').doc(_uid).delete();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);
  }

  Future<void> _saveLocalCache(ProgressModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, jsonEncode(model.toJson()));
  }

  Future<ProgressModel> _loadLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_localKey);

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
}
