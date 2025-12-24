import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loggedInKey = 'is_logged_in';

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  /// Restore login state when app starts
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
  }

  /// Simulated login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    await _setLoggedIn(true);
  }

  /// Simulated signup
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    await _setLoggedIn(true);
  }

  /// Logout user
  Future<void> logout() async {
    await _setLoggedIn(false);
  }

  /// Internal helper
  Future<void> _setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      await prefs.setBool(_loggedInKey, true);
    } else {
      await prefs.remove(_loggedInKey);
    }

    _isLoggedIn = value;
  }
}
