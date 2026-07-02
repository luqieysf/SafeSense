import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserAccount? _currentUser;
  bool         _isLoading = false;
  String?      _errorMessage;

  // ─── Getters ───────────────────────────────────────────────────────────────
  UserAccount? get currentUser    => _currentUser;
  bool         get isLoading      => _isLoading;
  String?      get errorMessage   => _errorMessage;
  bool         get isLoggedIn     => _currentUser != null;
  String       get role           => _currentUser?.role ?? '';

  // ─── Restore session on app open ───────────────────────────────────────────
  Future<void> restoreSession() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return;

    _currentUser = await _authService.fetchAccount(firebaseUser.uid);
    notifyListeners();
  }

  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.login(email, password);
      _setLoading(false);
      return _currentUser != null;
    } catch (e) {
      _setError(_friendlyError(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  // ─── Register ──────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.register(
        name:     name,
        email:    email,
        password: password,
        role:     role,
      );
      _setLoading(false);
      return _currentUser != null;
    } catch (e) {
      // print FULL error so we can see it in terminal
      print('REGISTER ERROR: $e');
      _setError(_friendlyError(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // ─── Reset password ────────────────────────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_friendlyError(e.toString()));
      _setLoading(false);
      return false;
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // converts Firebase error codes into readable messages
  String _friendlyError(String error) {
    if (error.contains('user-not-found'))    return 'No account found with this email.';
    if (error.contains('wrong-password'))    return 'Incorrect password. Please try again.';
    if (error.contains('email-already'))     return 'An account with this email already exists.';
    if (error.contains('weak-password'))     return 'Password must be at least 6 characters.';
    if (error.contains('invalid-email'))     return 'Please enter a valid email address.';
    if (error.contains('network-request'))   return 'No internet connection. Please try again.';
    return 'Something went wrong. Please try again.';
  }
}