import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;

    if (user == null) {
      return {
        'haptics': prefs.getBool('haptics') ?? true,
        'textScale': prefs.getDouble('textScale') ?? 1.0,
        'highContrast': prefs.getBool('highContrast') ?? false,
      };
    }

    final snap = await _db.collection("users").doc(user.uid).get();
    final settings = snap.data()?['settings'];

    if (settings != null) {
      await prefs.setBool("haptics", settings['haptics']);
      await prefs.setDouble("textScale", settings['textScale']);
      await prefs.setBool("highContrast", settings['highContrast']);

      return Map<String, dynamic>.from(settings);
    }

    return {
      'haptics': prefs.getBool('haptics') ?? true,
      'textScale': prefs.getDouble('textScale') ?? 1.0,
      'highContrast': prefs.getBool('highContrast') ?? false,
    };
  }

  static Future<void> save({
    required bool haptics,
    required double textScale,
    required bool highContrast,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptics', haptics);
    await prefs.setDouble('textScale', textScale);
    await prefs.setBool('highContrast', highContrast);

    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'settings': {
          'haptics': haptics,
          'textScale': textScale,
          'highContrast': highContrast,
        },
      }, SetOptions(merge: true));
    }
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection("users").doc(user.uid).set({
        'settings': {'haptics': true, 'textScale': 1.0, 'highContrast': false},
      }, SetOptions(merge: true));
    }
  }
}
