import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_account.dart';

class AuthService {
  final FirebaseAuth    _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser       => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserAccount?> login(String email, String password) async {
    final result = await _auth
        .signInWithEmailAndPassword(
      email:    email.trim(),
      password: password.trim(),
    )
        .timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception(
          'Connection timed out. Check your internet connection.'),
    );

    if (result.user == null) return null;

    final doc = await _db
        .collection('users')
        .doc(result.user!.uid)
        .get()
        .timeout(const Duration(seconds: 15));

    if (!doc.exists) return null;
    return UserAccount.fromMap(doc.id, doc.data()!);
  }

  Future<UserAccount?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final result = await _auth
        .createUserWithEmailAndPassword(
      email:    email.trim(),
      password: password.trim(),
    )
        .timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception(
          'Connection timed out. Check your internet connection.'),
    );

    if (result.user == null) return null;

    final account = UserAccount(
      userId:         result.user!.uid,
      name:           name.trim(),
      email:          email.trim(),
      role:           role,
      linkedChildIds: [],
    );

    await _db
        .collection('users')
        .doc(result.user!.uid)
        .set(account.toMap())
        .timeout(const Duration(seconds: 15));

    return account;
  }

  Future<void>         logout()                    async => _auth.signOut();
  Future<void>         resetPassword(String email) async =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<UserAccount?> fetchAccount(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserAccount.fromMap(doc.id, doc.data()!);
  }
}