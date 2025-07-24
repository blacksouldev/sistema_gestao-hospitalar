import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  bool get isAuthenticated => _user != null;
  User? get user => _user;

  Future<bool> login(String email, String senha) async {
    final user = await _authService.login(email, senha);
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
