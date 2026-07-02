import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';
import '../services/firestore_service.dart';

class ChildProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  ChildProfile? _childProfile;
  bool          _isLoading  = false;
  String?       _errorMessage;

  ChildProfile? get childProfile => _childProfile;
  bool          get isLoading    => _isLoading;
  String?       get errorMessage => _errorMessage;
  int           get tokenBalance => _childProfile?.tokenBalance ?? 0;
  bool          get isLoggedIn   => _childProfile != null;

  // ── PIN login ────────────────────────────────────────────────────────────
  Future<bool> loginWithPin(String pin) async {
    _setLoading(true);
    _errorMessage = null;

    final child = await _db.findChildByPin(pin);
    if (child == null) {
      _errorMessage = 'Invalid PIN. Please check and try again.';
      _setLoading(false);
      return false;
    }

    _childProfile = child;

    // save session locally so child stays logged in after app restart
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('childId', child.childId);

    _setLoading(false);
    return true;
  }

  // ── Restore child session on app open ────────────────────────────────────
  Future<bool> restoreChildSession() async {
    final prefs   = await SharedPreferences.getInstance();
    final childId = prefs.getString('childId');
    if (childId == null) return false;

    _childProfile = await _db.getChildProfile(childId);
    notifyListeners();
    return _childProfile != null;
  }

  // ── Logout child ─────────────────────────────────────────────────────────
  Future<void> logoutChild() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('childId');
    _childProfile = null;
    notifyListeners();
  }

  // ── Load / save ──────────────────────────────────────────────────────────
  Future<void> loadChild(String childId) async {
    _setLoading(true);
    _childProfile = await _db.getChildProfile(childId);
    _setLoading(false);
  }

  Future<void> saveChildProfile(ChildProfile profile) async {
    _setLoading(true);
    await _db.saveChildProfile(profile);
    _childProfile = profile;
    _setLoading(false);
  }

  Future<void> updateTokenBalance(String childId, int newBalance) async {
    await _db.updateTokenBalance(childId, newBalance);
    if (_childProfile != null) {
      _childProfile = _childProfile!.copyWith(tokenBalance: newBalance);
      notifyListeners();
    }
  }

  void clearChild() {
    _childProfile = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}