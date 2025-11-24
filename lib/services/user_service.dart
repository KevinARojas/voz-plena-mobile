import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _fire = FirebaseFirestore.instance;

  Future<void> initUserProgress(String uid) async {
    await _fire.collection('user_progress').doc(uid).set({
      'volumeScore': 0,
      'toneScore': 0,
      'breathingScore': 0,
      'totalSessions': 0,
      'lastSession': FieldValue.serverTimestamp(),
    });
  }

  Future<void> initUserSettings(String uid) async {
    await _fire.collection('user_settings').doc(uid).set({
      'darkMode': false,
      'language': 'es',
      'notificationsEnabled': true,
    });
  }

  Future<Map<String, dynamic>?> getUserProgress(String uid) async {
    final doc = await _fire.collection('user_progress').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProgress(String uid, Map<String, dynamic> data) async {
    await _fire.collection('user_progress').doc(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUserSettings(String uid) async {
    final doc = await _fire.collection('user_settings').doc(uid).get();
    return doc.data();
  }

  Future<void> updateSettings(String uid, Map<String, dynamic> data) async {
    await _fire.collection('user_settings').doc(uid).update(data);
  }
}
