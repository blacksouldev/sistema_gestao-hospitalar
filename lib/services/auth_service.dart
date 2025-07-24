import '../models/user.dart';

class AuthService {
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simula requisição

    if (email == 'admin@vidaplus.com' && password == '123456') {
      return User(email: email, token: 'mock-jwt-token');
    }
    return null;
  }
}
