import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../../../core/database/database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  User? _currentUser;

  AuthService._init();

  // Get current logged-in user
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    int age = 0,
    String? gender,
  }) async {
    try {
      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }

      // Validate password length
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters'
        };
      }

      // Check if user already exists
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create new user with hashed password
      final user = User(
        email: email,
        password: _hashPassword(password),
        name: name,
        age: age,
        gender: gender,
      );

      // Insert user into database
      final userId = await _dbHelper.insertUser(user);
      _currentUser = user.copyWith(id: userId);

      return {'success': true, 'message': 'Registration successful', 'user': _currentUser};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Find user by email
      final user = await _dbHelper.getUserByEmail(email);
      
      if (user == null) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.password != hashedPassword) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      _currentUser = user;
      return {'success': true, 'message': 'Login successful', 'user': _currentUser};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(User updatedUser) async {
    try {
      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) {
        return {'success': false, 'message': 'No user logged in'};
      }

      // Verify old password
      final hashedOldPassword = _hashPassword(oldPassword);
      if (_currentUser!.password != hashedOldPassword) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      // Validate new password
      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters'
        };
      }

      // Update password
      final updatedUser = _currentUser!.copyWith(
        password: _hashPassword(newPassword),
      );
      
      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Password change failed: $e'};
    }
  }

  // Auto-login (check if user was previously logged in)
  Future<bool> tryAutoLogin() async {
    // In a real app, you'd use shared_preferences or secure_storage
    // For now, we'll just return false
    return false;
  }
}
