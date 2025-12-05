import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Initialize - check for auto-login
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final autoLoggedIn = await _authService.tryAutoLogin();
    if (autoLoggedIn) {
      _currentUser = _authService.currentUser;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    int age = 0,
    String? gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
      name: name,
      age: age,
      gender: gender,
    );

    _isLoading = false;

    if (result['success']) {
      _currentUser = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success']) {
      _currentUser = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Update Profile
  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateProfile(updatedUser);

    _isLoading = false;

    if (result['success']) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
