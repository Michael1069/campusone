import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = true; // 👈 important
  String? _error;

  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _init(); // 👈 restore session ONCE
  }

  Future<void> _init() async {
    await _authService.restoreSession();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.login(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signup(
        name: name,
        email: email,
        password: password,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
