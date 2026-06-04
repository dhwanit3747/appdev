import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthProvider using Local Storage (SharedPreferences).
///
/// All auth methods set [isLoading] during async work, and set [errorMessage]
/// on failure. The UI should read [errorMessage] after awaiting any method
/// to decide what feedback to show.
class AuthProvider extends ChangeNotifier {
  // ---------- state ----------
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _loadActiveSession();
  }

  // ---------- getters ----------
  AuthUser? get user => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load active user session from SharedPreferences on startup
  Future<void> _loadActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeEmail = prefs.getString('active_local_user');
      if (activeEmail != null) {
        final uid = activeEmail.hashCode.toString();
        _currentUser = AuthUser(uid: uid, email: activeEmail);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading active user session: $e");
    }
  }

  /// Clear any previous error before a new action.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ====================================================================
  //  EMAIL / PASSWORD (LOCAL STORAGE MOCK)
  // ====================================================================

  Future<void> signUp(String email, String password) async {
    _startLoading();
    // Simulate standard network latency for realistic feel
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('local_users_db') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersJson);

      if (users.containsKey(email)) {
        _errorMessage = 'This email is already registered. Try logging in.';
      } else {
        users[email] = password;
        await prefs.setString('local_users_db', json.encode(users));
        
        // Log in immediately
        await prefs.setString('active_local_user', email);
        final uid = email.hashCode.toString();
        _currentUser = AuthUser(uid: uid, email: email);
      }
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
    }
    _stopLoading();
  }

  Future<void> signIn(String email, String password) async {
    _startLoading();
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('local_users_db') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersJson);

      if (!users.containsKey(email)) {
        _errorMessage = 'No account found with this email. Please sign up.';
      } else if (users[email] != password) {
        _errorMessage = 'Incorrect password. Please try again.';
      } else {
        await prefs.setString('active_local_user', email);
        final uid = email.hashCode.toString();
        _currentUser = AuthUser(uid: uid, email: email);
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
    }
    _stopLoading();
  }

  // ====================================================================
  //  PASSWORD RESET (LOCAL SIMULATION)
  // ====================================================================

  Future<void> resetPassword(String email) async {
    _startLoading();
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('local_users_db') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersJson);

      if (!users.containsKey(email)) {
        _errorMessage = 'No account found with this email.';
      } else {
        // Simulates password reset
        debugPrint("Simulated password reset email sent to $email");
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  // ====================================================================
  //  LOGOUT
  // ====================================================================

  Future<void> logout() async {
    _startLoading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_local_user');
      _currentUser = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  // ====================================================================
  //  DELETE ACCOUNT (LOCAL STORAGE MOCK)
  // ====================================================================

  /// Re-authenticate with [password] then delete the account from local database.
  Future<void> deleteAccountWithPassword(String password) async {
    if (_currentUser == null) {
      _errorMessage = 'No user signed in.';
      notifyListeners();
      return;
    }

    _startLoading();
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('local_users_db') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersJson);
      final email = _currentUser!.email;

      if (users[email] != password) {
        _errorMessage = 'Incorrect password. Verification failed.';
      } else {
        users.remove(email);
        await prefs.setString('local_users_db', json.encode(users));
        await prefs.remove('active_local_user');
        _currentUser = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _stopLoading();
  }

  // ====================================================================
  //  HELPERS
  // ====================================================================

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
}

/// Compatibility user model for local authentication.
class AuthUser {
  final String uid;
  final String email;
  AuthUser({required this.uid, required this.email});
}
