import 'package:flutter/material.dart';

enum UserRole { guest, customer, admin }

class AuthProvider with ChangeNotifier {
  UserRole _role = UserRole.guest;
  String? _currentUserEmail;
  String? _currentUserName;

  UserRole get role => _role;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  bool get isAuthenticated => _role != UserRole.guest;
  bool get isAdmin => _role == UserRole.admin;
  bool get isCustomer => _role == UserRole.customer;

  // Simple static login check
  Future<bool> login(String email, String password) async {
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().toLowerCase() == 'admin' && password == 'admin123') {
      _role = UserRole.admin;
      _currentUserEmail = 'admin@firesafety.com';
      _currentUserName = 'System Administrator';
      notifyListeners();
      return true;
    } else if (email.trim().isNotEmpty && password.length >= 6) {
      // Allow any email with 6+ char password as a valid customer for simplicity
      _role = UserRole.customer;
      _currentUserEmail = email.trim();
      _currentUserName = email.split('@')[0].toUpperCase();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _role = UserRole.guest;
    _currentUserEmail = null;
    _currentUserName = null;
    notifyListeners();
  }

  void updateProfile(String newName, String newEmail) {
    if (_role == UserRole.customer) {
      _currentUserName = newName;
      _currentUserEmail = newEmail;
      notifyListeners();
    }
  }
}
