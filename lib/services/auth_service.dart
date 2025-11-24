import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  Future<User?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = cred.user!.uid;

      await _fire.collection('users').doc(uid).set({
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "email": email.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      await UserService().initUserProgress(uid);

      await UserService().initUserSettings(uid);

      return cred.user;
    } catch (e) {
      print("ERROR REGISTER: $e");
      rethrow;
    }
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return cred.user;
    } catch (e) {
      print("ERROR LOGIN: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? currentUser() => _auth.currentUser;
}
